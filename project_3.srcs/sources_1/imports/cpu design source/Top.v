`timescale 1ns / 1ps
module top(
input [4:0]btn_i,
input [15:0]sw_i,
input clk,
input rstn,
output [7:0]disp_an_o,
output [7:0]disp_seg_o,
output [15:0]led_o
);
//U1_PCPU
    wire MIO_ready;
    wire[31:0] inst_in;
    wire[31:0] Data_in;
    wire mem_w;
    wire[31:0] PC_out;
    wire[31:0] Addr_out;
    wire[31:0] Data_out;
    wire[2:0] dm_ctrl;
    wire CPU_MIO;
    wire INT;
    
//U2_ROM_D
    wire[9:0] a;
    wire[31:0] spo;
    
//U3_dm_controller
    wire [31:0]Addr_in;
    wire [31:0]Data_write;
    wire [31:0]Data_read_from_dm;
    wire [31:0]Data_read;
    wire [31:0]Data_write_to_dm;
    wire [3:0]wea_mem;
    
//U4_RAM_B
    wire [9:0] addra;
    wire [31:0] dina;
    wire [3:0] wea;
    wire [31:0] douta;
    
//U4_MIO_BUS
    wire [4:0]BTN;
    wire [31:0]PC;
    wire [31:0]Cpu_data2bus;
    wire [31:0]addr_bus;
    wire [31:0]ram_data_out;
    wire [15:0]led_out;
    wire counter0_out;
    wire counter1_out;
    wire counter2_out;
    wire [31:0]Cpu_data4bus;
    wire [31:0]ram_data_in;
    wire [9:0]ram_addr;
    wire data_ram_we;
    wire GPIOf0000000_we;
    wire GPIOe0000000_we;
    wire counter_we;
    wire [31:0]Peripheral_in;
    
//U5_Multi_8CH32
    wire [2:0]Switch;
    wire [63:0]point_in;
    wire [31:0]data0;
    wire [31:0]data1;
    wire [31:0]data2;
    wire [31:0]data3;
    wire [31:0]data4;
    wire [31:0]data5;
    wire [31:0]data6;
    wire [31:0]data7;
    wire [7:0]point_out;
    wire [7:0]LE_out;
    wire [31:0]Disp_num;
    
//U6_SSeg7        
    wire SW0;           
    wire flash;         
    wire [31:0]Hexs;    
    wire [7:0]point;    
     
    wire [7:0]seg_an;  
    wire [7:0]seg_sout;
    
//U7_SPIO
    wire [31:0]P_Data;
    wire [1:0]counter_set;
    wire [15:0]LED_out;
    wire [15:0]led;
    wire [13:0]GPIOf0;
    
//U8_clk_div
    wire SW2;
    wire[31:0] clkdiv;
    wire Clk_CPU;
    
    //U9_Counter_x
	wire clk0;
	wire clk1;
	wire clk2;
	wire [31:0] counter_val;
	wire [1:0] counter_ch;
	wire counter0_OUT;
	wire counter1_OUT;
	wire counter2_OUT;
	
	//U10

    wire [4:0] BTN_out;
    wire [15:0] SW_out;
    
wire counter_out;

SCPU U1_PCPU(
         .clk(Clk_CPU),                 // input:  cpu clock
         .reset(~rstn),                 // input:  reset
         .MIO_ready(CPU_MIO),
         .inst_in(spo),             // input:  instruction
         .Data_in(Data_read),        // input:  data to cpu  
         .mem_w(mem_w),       // output: memory write signal
         .PC_out(PC_out),                   // output: PC
         .Addr_out(Addr_out),          // output: address from cpu to memory
         .Data_out(Cpu_data2bus),        // output: data from cpu to memory
         .dm_ctrl(dm_ctrl),
         .CPU_MIO(CPU_MIO),
         .INT(counter0_OUT)
         );

dist_mem_gen_0 U2_ROMD(
.a(PC_out[11:2]),
.spo(spo)
);

RAM_B U3_RAM_B(
.addra(ram_addr),
.clka(~clk),
.dina(Data_write_to_dm),
.wea(wea_mem),
.douta(douta)
);

dm_controller U3_dm_controller(
.Addr_in(Addr_out),
.Data_read_from_dm(Cpu_data4bus),
.Data_write(ram_data_in),
.dm_ctrl(dm_ctrl),
.mem_w(mem_w),
.Data_read(Data_read),
.Data_write_to_dm(Data_write_to_dm),
.wea_mem(wea_mem)
);

MIO_BUS U4_MIO_BUS(
.clk(clk),
.rst(~rstn),
.BTN(BTN_out),
.SW(SW_out),
.mem_w(mem_w),
.Cpu_data2bus(Cpu_data2bus),
.addr_bus(Addr_out),
.ram_data_out(douta),
.led_out(LED_out),
.counter_out(32'b0),
.counter0_out(counter0_OUT),
.counter1_out(counter1_OUT),
.counter2_out(counter2_OUT),
.PC(PC),
.Cpu_data4bus(Cpu_data4bus),
.ram_data_in(ram_data_in),
.ram_addr(ram_addr),
.data_ram_we(data_ram_we),
.GPIOf0000000_we(GPIOf0000000_we),
.GPIOe0000000_we(GPIOe0000000_we),
.counter_we(counter_we),
.Peripheral_in(Peripheral_in)
);

Multi_8CH32 U5_Multi_8CH32(
.clk(~Clk_CPU),
.rst(~rstn),
.EN(GPIOe0000000_we),
.Switch(SW_out[7:5]),
.point_in({clkdiv[31:0],clkdiv[31:0]}),
.LES(~64'h00000000),
.data0(Peripheral_in),
.data1({1'b0,1'b0,PC_out[31:2]}),
.data2(spo),
.data3(32'b0),
.data4(Addr_out),
.data5(Cpu_data2bus),
.data6(Cpu_data4bus),
.data7(PC_out),
.point_out(point_out),
.LE_out(LE_out),
.Disp_num(Disp_num)
);

SSeg7 U6_SSeg7(
.Hexs(Disp_num),
.LES(LE_out),
.SW0(SW_out[0]),
.clk(clk),
.flash(clkdiv[10]),
.point(point_out),
.rst(~rstn),
.seg_an(disp_an_o),
.seg_sout(disp_seg_o)
);

SPIO U7_SPIO(
.EN(GPIOf0000000_we),
.P_Data(Peripheral_in),
.clk(~Clk_CPU),
.rst(~rstn),
.LED_out(LED_out),
.counter_set(counter_ch),
.led(led_o),
.GPIOf0(GPIOf0)
);

clk_div U8_clk_div(
.SW2(SW_out[2]),
.clk(clk),
.rst(~rstn),
.Clk_CPU(Clk_CPU),
.clkdiv(clkdiv)
);

Counter_x U9_Counter_x(
.clk(~Clk_CPU),
.clk0(clkdiv[6]),
.clk1(clkdiv[9]),
.clk2(clkdiv[11]),
.counter_ch(counter_ch),
.counter_val(Peripheral_in),
.counter_we(counter_we),
.rst(~rstn),
.counter0_OUT(counter0_OUT),
.counter1_OUT(counter1_OUT),
.counter2_OUT(counter2_OUT),
.counter_out(counter_out)
);

Enter U10_Enter(
.BTN(btn_i[4:0]),
.SW(sw_i[15:0]),
.clk(clk),
.BTN_out(BTN_out),
.SW_out(SW_out)
);


endmodule