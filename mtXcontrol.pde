
PFont fontA;
PFont fontLetter;

Matrix matrix;
Arduino arduino;

int border = 10;

int offY = 30;
int offX = 30;

int current_delay = 0;
int current_speed = 15;

boolean record  = true;
boolean keyCtrl = false;
boolean keyMac  =false;
boolean keyAlt  = false;

boolean update = true;
Button[] buttons;

GuiElement[] elements;

int hide_button_index;

/* +++++++++++++++++++++++++++++ */

void setup() {
  matrix = new Matrix(8, 8);
  arduino = new Arduino(this);
  size(780,720); //size(2*offX + matrix.width(), 2*offY + matrix.height() );
  smooth();
  noStroke();
  fontA = loadFont("Courier-Bold-32.vlw");
  fontLetter = loadFont("ArialMT-20.vlw");
  setup_buttons();
}

void setup_buttons() {
  buttons = new Button[50]; // width + height + ???
  int offset = 10;
  int button_index = 0;
  int y_pos = 0;

  color button_color = #333333;
  color button_color_over = #999999;
  int button_size = 15;
  
  for(int i = 0; i < matrix.rows; i++ ) {
    buttons[button_index++] = new RectButton( offX + matrix.width() + offset, offY + i * matrix.rad + matrix.border / 2, button_size, matrix.rad - matrix.border, button_color, button_color_over);
  }
  for(int i = 0; i < matrix.cols; i++ ) {
    buttons[button_index++] = new RectButton( offX + i * matrix.rad + matrix.border / 2, offY + matrix.width() + offset, matrix.rad - matrix.border, button_size, button_color, button_color_over);
  }
  buttons[button_index++] = new SquareButton( offX + matrix.width() + offset, offY + matrix.width() + offset, button_size, button_color, button_color_over );

  int button_x = offX + matrix.width() + offset + 30;
  buttons[button_index++] = new ActionToggleButton( "Mode: RECORD",  "Mode: PLAY",    "10",   button_x, y_pos += 30);
  buttons[button_index++] = new ActionToggleButton( "Matrix: FREE",  "Matrix: SLAVE", "a+10", button_x, y_pos += 30);
  buttons[button_index++] = new FrameChooser(offX, offY + matrix.height() + 40, 59, 10);
    
  hide_button_index = button_index;
  buttons[button_index++] = new TextElement( "Load from:", button_x, y_pos += 30);
  buttons[button_index++] = new ActionButton( "File",      "L", button_x,      y_pos += 30, 65, 25);
  buttons[button_index++] = new ActionButton( "Matrix",  "a+L", button_x + 67, y_pos,       65, 25);
  
  buttons[button_index++] = new TextElement( "Save to:", button_x, y_pos += 30);
  buttons[button_index++] = new ActionButton( "File",      "S", button_x,      y_pos += 30, 65, 25);
  buttons[button_index++] = new ActionButton( "Matrix",  "a+S", button_x + 67, y_pos,       65, 25);

  buttons[button_index++] = new TextElement( "Color:", button_x, y_pos += 40);
  buttons[button_index++] = new ColorButton( button_x, y_pos += 30);
  y_pos += 30;
  PixelColor pc = new PixelColor(); 
  for(int i = 0; i < 8; i++) {
    buttons[button_index++] = new MiniColorButton( button_x + i * 17, y_pos, 14, 14, pc.get_color());
    pc.invert();
  }
  
  buttons[button_index++] = new TextElement( "Frame:", button_x, y_pos += 20);  
  buttons[button_index++] = new ActionButton( "Add",    " ", button_x, y_pos += 30);
  buttons[button_index++] = new ActionButton( "Delete", "D", button_x, y_pos += 30);

  buttons[button_index++] = new ActionButton( "^", "c+38", button_x + 47,  y_pos += 50, 40, 25);
  buttons[button_index++] = new ActionButton( "<", "c+37", button_x,       y_pos += 20, 40, 25);
  buttons[button_index++] = new ActionButton( ">", "c+39", button_x + 94,  y_pos,       40, 25);
  buttons[button_index++] = new ActionButton( "v", "c+40", button_x + 47,  y_pos += 15, 40, 25);

  buttons[button_index++] = new ActionButton( "Paste",  "m+V", button_x, y_pos += 50);
  buttons[button_index++] = new ActionButton( "Copy",   "m+C", button_x, y_pos += 30);
  buttons[button_index++] = new ActionButton( "Fill",   "F", button_x, y_pos += 30);
  buttons[button_index++] = new ActionButton( "Clear",  "C", button_x, y_pos += 30);
}

void draw()
{
  if(update) {
    background(41);
    image(matrix.current_frame_image(), offX, offY);
    for(int i = 0; i < buttons.length; i++ ) {
      if(buttons[i] != null) buttons[i].display( !record && i >= hide_button_index );
    }
    
    if(!record) {
      fill(255); //white
      text( "Speed: " + current_speed, offX + matrix.width() + 65, 110);
    }
    arduino.write_frame(matrix.current_frame());
    update = false;
  }
  if(!record) next_frame();
}



/* +++++++++++++++++++++++++++++ */

void next_frame() {
  if(current_delay < 1) {
    current_delay = current_speed;
    matrix.next_frame();
    update = true;
  }
  current_delay--;
}

/* +++++++++++++++ ACTIONS +++++++++++++++ */
void mouseDragged() {
  if(!record) return;
  update = update || matrix.click(mouseX - offX, mouseY - offY, true);
}

void mousePressed() {
  for(int i = 0; i < buttons.length; i++ ) {
    if( buttons[i] != null ) update = update || buttons[i].pressed();
  }
  if(!record) return;
  update = matrix.click(mouseX - offX, mouseY - offY, false) || update;
}

void mouseMoved() {
  for(int i = 0; i < buttons.length; i++ ) {
    if( buttons[i] != null ) update = update || buttons[i].over();
  }
}

void keyPressed() {
  if(keyCode == 17)  keyCtrl = true; //control
  if(keyCode == 18)  keyAlt  = true; //alt
  if(keyCode == 157) keyMac  = true; //mac

  for(int i = 0; i < buttons.length; i++ ) {
    if(buttons[i] != null ) update = update || buttons[i].key_pressed(keyCode, keyMac, keyCtrl, keyAlt);
  }

  if(keyAlt) {
    if(keyCode == 37) arduino.speed_up();   //arrow left
    if(keyCode == 39) arduino.speed_down(); //arrow right
  }
  else if(keyCtrl) {
    if(keyCode >= 48) matrix.current_frame().set_letter(char(keyCode), fontLetter, matrix.current_color);
    update = true;
  }
  else {
    if(!record) {
      if( keyCode == 37) speed_up();     //arrow left
      if( keyCode == 39) speed_down();   //arrow right
    }
  }
  //println("pressed " + key + " " + keyCode);
}

void keyReleased() {
  if( keyCode == 17 )  keyCtrl = false;
  if( keyCode == 18 )  keyAlt  = false;
  if( keyCode == 157 ) keyMac  = false;
}

/* +++++++++++++++ modes +++++++++++++++ */

void toggle_mode() {
  matrix.current_frame_nr = 0;
  record = !record;
}

void speed_up() {
  if( current_speed < 2 ) return;
  current_speed--;
}

void speed_down() {
  current_speed++;
}


