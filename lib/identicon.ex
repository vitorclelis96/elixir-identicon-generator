defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """
  @type string_input :: String
  @type image :: Identicon.Image.t()

  def main(string_input) do
    data =
      string_input
      |> hash_input
      |> pick_color
      |> build_grid
      |> filter_odd_squares

    build_image()
    |> draw(data)
    |> :egd.render
    |> :egd.save("Test.png")
  end

  @doc """
    Get the position of the square, based on the index position in the list.
    You should use get_initial_x_y/1 instead.

  ## Examples
      iex> Identicon.get_initial_x_y(5, 0)
      {0, 50}
  """
  @spec get_initial_x_y(number, number) :: {number, number}
  def get_initial_x_y(index, y) do
    case index > 4 do
      true -> get_initial_x_y((index - 5), (y+50))
      false -> {(index * 50), y}
    end
  end

   @doc """
    Get the position of the square, based on the index position in the list.
    You should use get_initial_x_y/1 when you need to use this function.

  ## Examples
      iex> Identicon.get_initial_x_y(5)
      {0, 50}
  """
  @spec get_initial_x_y(number) :: {number, number}
  def get_initial_x_y(index) do
    get_initial_x_y(index, 0)
  end

  @spec draw(pid, Identicon.Image.t()) :: pid
  def draw(image, %Identicon.Image{color: color, grid: grid} = _data) do
    Enum.map(grid, fn {_value, index} ->
      draw_rectangle(image, color, get_initial_x_y(index))
    end)
    image
  end

  def draw_rectangle(image, color, {initial_x, initial_y}) do
    :egd.filledRectangle(image, {initial_x, initial_y}, {(initial_x + 50), (initial_y + 50)}, :egd.color(color))
  end

  @spec build_image :: pid
  def build_image() do
    :egd.create(250, 250)
  end

  @spec hash_input(String) :: binary
  def hash_input(input) do
    hex_list = :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{
      hex: hex_list
    }
  end

  @spec filter_odd_squares(Identicon.Image.t()) :: Identicon.Image.t()
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn {value, _index} ->
      rem(value, 2) == 0
    end)

    Map.put(image, :grid, grid)
  end

  @spec pick_color(image) :: image
  def pick_color(image) do
    %Identicon.Image{hex: [red, green, blue | _tail]} = image

    # %Identicon.Image{image | color: {red, green, blue}}
    Map.put(image, :color, {red, green, blue})
  end

  @spec build_grid(image) :: image
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    Map.put(image, :grid, grid)
  end

  # Deprecated
  @spec color_grid({integer, integer}) :: [index: integer, colored: boolean]
  def color_grid(grid) do
    { value, index } = grid
    case rem(value, 2) == 0 do
      true -> [ index: index, colored: true ]
      false -> [ index: index, colored: false ]
    end
  end

  @spec mirror_row([any]) :: [any]
  def mirror_row(row) do
    [first, second, _tail] = row
    row ++ [second, first]
  end

  def test() do
    image = :egd.create(250, 250)
    :egd.filledRectangle(image, { 50, 0 }, { 100, 50 }, :egd.color({0, 0, 0}) )
    image |> :egd.render |> :egd.save("Test.png")
  end

  @spec check_grid(image) :: image | String
  def check_grid(image) do
    case length(List.flatten(image.grid)) == 25 do
      true -> image
      false -> "Invalid image"
    end
  end
end
