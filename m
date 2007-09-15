Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=WINDOWS-1252; delsp=yes; format=flowed
Message-Id: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
Content-Transfer-Encoding: 8BIT
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: VM/VFS bug with large amount of memory and file systems?
Date: Sat, 15 Sep 2007 08:27:23 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
Cc: marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

Hi,

Mark Smith reported a OOM condition when he copies a large (46GiB)  
file from an NTFS partition (using the stock kernel driver) to /dev/ 
null (or to a file on ext3, same result).

The machine this runs on has an i386 kernel with 12GiB RAM (yes this  
is not a typo it is 12GiB!).

When you do:

escabot CAD # ls -ltrh
total 49G
-r-------- 1 root root 2.0G Oct  7  2004 RTC26001.GHS
-r-------- 1 root root 2.0G Oct  7  2004 RTC26002.GHS
-r-------- 1 root root 2.0G Oct  7  2004 RTC2604.GHO
-r-------- 1 root root 620M Oct  7  2004 RTC26003.GHS
-r-------- 1 root root    4 Sep 14 09:32 asdf.txt
-r-------- 1 root root    8 Sep 14 09:33 rty.txt
-r-------- 1 root root  42G Sep 14 10:36 bigfile.gho
escabot CAD # cp bigfile.gho /dev/null

It dies with OOM and eventual panic with the message: "Kernel panic -  
not syncing: Out of memory and no killable processes."

If Mark boots with "mem=2G" on the kernel command line and he then  
repeat thes above copy, then the copy succeeds just fine so there is  
nothing inherently wrong with NTFS.

So the OOM happens with 12GiB RAM but not with 2GiB RAM.  I guess  
this is why I have never seen this in my testing.  My laptop only has  
2GiB RAM...

Below are relevant parts of the dmesg output that Mark sent that show  
what the kernel messages are when this happens.  (I have taken out  
the NTFS debug output to make the log shorter but that does not show  
anything untoward and I can send it on request but it really just  
shows the file being read in and that's all!)

Does anyone have any ideas / want to work with Mark (he is CC:-ed) to  
try and figure out the bug and get it fixed?  I am sure Mark will be  
happy to provide further information/try things out...

If it turns out to be something NTFS is doing wrong I am happy to try  
and fix it but at the moment I assume it is something the VM is doing  
wrong when there is so much RAM available...

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/

<quote from dmesg output>
Sep 13 15:00:22 escabot Linux version 2.6.21-gentoo-r4 (root@escabot)  
(gcc version 4.1.2 (Gentoo 4.1.2 p1.0.1)) #3 SMP PREEMPT Thu Sep 13  
14:44:12 EDT 2007
Sep 13 15:00:22 escabot BIOS-provided physical RAM map:
Sep 13 15:00:22 escabot sanitize start
Sep 13 15:00:22 escabot sanitize end
Sep 13 15:00:22 escabot copy_e820_map() start: 0000000000000000 size:  
000000000009ec00 end: 000000000009ec00 type: 1
Sep 13 15:00:22 escabot copy_e820_map() type is E820_RAM
Sep 13 15:00:22 escabot copy_e820_map() start: 000000000009ec00 size:  
0000000000001400 end: 00000000000a0000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000000f0000 size:  
0000000000010000 end: 0000000000100000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 0000000000100000 size:  
00000000f56f8000 end: 00000000f57f8000 type: 1
Sep 13 15:00:22 escabot copy_e820_map() type is E820_RAM
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000f57f8000 size:  
0000000000008000 end: 00000000f5800000 type: 3
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000fdc00000 size:  
0000000000001000 end: 00000000fdc01000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000fdc10000 size:  
0000000000001000 end: 00000000fdc11000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000fec00000 size:  
0000000000001000 end: 00000000fec01000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000fec10000 size:  
0000000000001000 end: 00000000fec11000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000fec20000 size:  
0000000000001000 end: 00000000fec21000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000fee00000 size:  
0000000000010000 end: 00000000fee10000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 00000000ff800000 size:  
0000000000800000 end: 0000000100000000 type: 2
Sep 13 15:00:22 escabot copy_e820_map() start: 0000000100000000 size:  
00000001fffff000 end: 00000002fffff000 type: 1
Sep 13 15:00:22 escabot copy_e820_map() type is E820_RAM
Sep 13 15:00:22 escabot BIOS-e820: 0000000000000000 -  
000000000009ec00 (usable)
Sep 13 15:00:22 escabot BIOS-e820: 000000000009ec00 -  
00000000000a0000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 00000000000f0000 -  
0000000000100000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 0000000000100000 -  
00000000f57f8000 (usable)
Sep 13 15:00:22 escabot BIOS-e820: 00000000f57f8000 -  
00000000f5800000 (ACPI data)
Sep 13 15:00:22 escabot BIOS-e820: 00000000fdc00000 -  
00000000fdc01000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 00000000fdc10000 -  
00000000fdc11000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 00000000fec00000 -  
00000000fec01000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 00000000fec10000 -  
00000000fec11000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 00000000fec20000 -  
00000000fec21000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 00000000fee00000 -  
00000000fee10000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 00000000ff800000 -  
0000000100000000 (reserved)
Sep 13 15:00:22 escabot BIOS-e820: 0000000100000000 -  
00000002fffff000 (usable)
Sep 13 15:00:22 escabot 11391MB HIGHMEM available.
Sep 13 15:00:22 escabot 896MB LOWMEM available.
Sep 13 15:00:22 escabot found SMP MP-table at 000f4fa0
Sep 13 15:00:22 escabot NX (Execute Disable) protection: active
Sep 13 15:00:22 escabot Entering add_active_range(0, 0, 3145727) 0  
entries of 256 used
Sep 13 15:00:22 escabot Zone PFN ranges:
Sep 13 15:00:22 escabot DMA             0 ->     4096
Sep 13 15:00:22 escabot Normal       4096 ->   229376
Sep 13 15:00:22 escabot HighMem    229376 ->  3145727
Sep 13 15:00:22 escabot early_node_map[1] active PFN ranges
Sep 13 15:00:22 escabot 0:        0 ->  3145727
Sep 13 15:00:22 escabot On node 0 totalpages: 3145727
Sep 13 15:00:22 escabot DMA zone: 32 pages used for memmap
Sep 13 15:00:22 escabot DMA zone: 0 pages reserved
Sep 13 15:00:22 escabot DMA zone: 4064 pages, LIFO batch:0
Sep 13 15:00:22 escabot Normal zone: 1760 pages used for memmap
Sep 13 15:00:22 escabot Normal zone: 223520 pages, LIFO batch:31
Sep 13 15:00:22 escabot HighMem zone: 22783 pages used for memmap
Sep 13 15:00:22 escabot HighMem zone: 2893568 pages, LIFO batch:31
Sep 13 15:00:22 escabot DMI 2.3 present.
Sep 13 15:00:22 escabot ACPI: RSDP 000F4F20, 0024 (r2 HP    )
Sep 13 15:00:22 escabot ACPI: XSDT F57F83E0, 0044 (r1 HP      
A05             2   ?     162E)
Sep 13 15:00:22 escabot ACPI: FACP F57F8460, 00F4 (r3 HP      
A05             2   ?     162E)
Sep 13 15:00:22 escabot ACPI: DSDT F57F8560, 422D (r1 HP          
DSDT        1 MSFT  2000001)
Sep 13 15:00:22 escabot ACPI: FACS F57F80C0, 0040
Sep 13 15:00:22 escabot ACPI: APIC F57F8100, 00B8 (r1 HP      
00000083        2             0)
Sep 13 15:00:22 escabot ACPI: SPCR F57F81E0, 0050 (r1 HP      
SPCRRBSU        1   ?     162E)
Sep 13 15:00:22 escabot ACPI: SRAT F57F8260, 0150 (r1 HP      
A05             1             0)
Sep 13 15:00:22 escabot ACPI: PM-Timer IO Port: 0x908
Sep 13 15:00:22 escabot ACPI: Local APIC address 0xfee00000
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00]  
enabled)
Sep 13 15:00:22 escabot Processor #0 15:1 APIC version 16
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02]  
enabled)
Sep 13 15:00:22 escabot Processor #2 15:1 APIC version 16
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04]  
disabled)
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06]  
disabled)
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01]  
enabled)
Sep 13 15:00:22 escabot Processor #1 15:1 APIC version 16
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03]  
enabled)
Sep 13 15:00:22 escabot Processor #3 15:1 APIC version 16
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05]  
disabled)
Sep 13 15:00:22 escabot ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07]  
disabled)
Sep 13 15:00:22 escabot ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint 
[0x1])
Sep 13 15:00:22 escabot ACPI: IOAPIC (id[0x04] address[0xfec00000]  
gsi_base[0])
Sep 13 15:00:22 escabot IOAPIC[0]: apic_id 4, version 17, address  
0xfec00000, GSI 0-23
Sep 13 15:00:22 escabot ACPI: IOAPIC (id[0x05] address[0xfec10000]  
gsi_base[24])
Sep 13 15:00:22 escabot IOAPIC[1]: apic_id 5, version 17, address  
0xfec10000, GSI 24-27
Sep 13 15:00:22 escabot ACPI: IOAPIC (id[0x06] address[0xfec20000]  
gsi_base[28])
Sep 13 15:00:22 escabot IOAPIC[2]: apic_id 6, version 17, address  
0xfec20000, GSI 28-31
Sep 13 15:00:22 escabot ACPI: IOAPIC (id[0x07] address[0xfdc00000]  
gsi_base[32])
Sep 13 15:00:22 escabot IOAPIC[3]: apic_id 7, version 17, address  
0xfdc00000, GSI 32-35
Sep 13 15:00:22 escabot ACPI: IOAPIC (id[0x08] address[0xfdc10000]  
gsi_base[36])
Sep 13 15:00:22 escabot IOAPIC[4]: apic_id 8, version 17, address  
0xfdc10000, GSI 36-39
Sep 13 15:00:22 escabot ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq  
2 high edge)
Sep 13 15:00:22 escabot ACPI: IRQ0 used by override.
Sep 13 15:00:22 escabot ACPI: IRQ2 used by override.
Sep 13 15:00:22 escabot ACPI: IRQ9 used by override.
Sep 13 15:00:22 escabot Enabling APIC mode:  Flat.  Using 5 I/O APICs
Sep 13 15:00:22 escabot Using ACPI (MADT) for SMP configuration  
information
Sep 13 15:00:22 escabot Allocating PCI resources starting at f6000000  
(gap: f5800000:08400000)
Sep 13 15:00:22 escabot Built 1 zonelists.  Total pages: 3121152
Sep 13 15:00:22 escabot Kernel command line: debug_msgs=1
Sep 13 15:00:22 escabot mapped APIC to ffffd000 (fee00000)
Sep 13 15:00:22 escabot mapped IOAPIC to ffffc000 (fec00000)
Sep 13 15:00:22 escabot mapped IOAPIC to ffffb000 (fec10000)
Sep 13 15:00:22 escabot mapped IOAPIC to ffffa000 (fec20000)
Sep 13 15:00:22 escabot mapped IOAPIC to ffff9000 (fdc00000)
Sep 13 15:00:22 escabot mapped IOAPIC to ffff8000 (fdc10000)
Sep 13 15:00:22 escabot Enabling fast FPU save and restore... done.
Sep 13 15:00:22 escabot Enabling unmasked SIMD FPU exception  
support... done.
Sep 13 15:00:22 escabot Initializing CPU#0
Sep 13 15:00:22 escabot PID hash table entries: 4096 (order: 12,  
16384 bytes)
Sep 13 15:00:22 escabot Detected 2405.604 MHz processor.
Sep 13 15:00:22 escabot Console: colour VGA+ 80x25
Sep 13 15:00:22 escabot Dentry cache hash table entries: 131072  
(order: 7, 524288 bytes)
Sep 13 15:00:22 escabot Inode-cache hash table entries: 65536 (order:  
6, 262144 bytes)
Sep 13 15:00:22 escabot Memory: 12304772k/12582908k available (3439k  
kernel code, 104940k reserved, 977k data, 240k init, 11493340k highmem)
Sep 13 15:00:22 escabot virtual kernel memory layout:
Sep 13 15:00:22 escabot fixmap  : 0xfff4f000 - 0xfffff000   ( 704 kB)
Sep 13 15:00:22 escabot pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
Sep 13 15:00:22 escabot vmalloc : 0xf8800000 - 0xffbfe000   ( 115 MB)
Sep 13 15:00:22 escabot lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
Sep 13 15:00:22 escabot .init : 0xc0558000 - 0xc0594000   ( 240 kB)
Sep 13 15:00:22 escabot .data : 0xc045bce5 - 0xc055014c   ( 977 kB)
Sep 13 15:00:22 escabot .text : 0xc0100000 - 0xc045bce5   (3439 kB)
Sep 13 15:00:22 escabot Checking if this processor honours the WP bit  
even in supervisor mode... Ok.
Sep 13 15:00:22 escabot Calibrating delay using timer specific  
routine.. 4815.63 BogoMIPS (lpj=9631263)
Sep 13 15:00:22 escabot Mount-cache hash table entries: 512
Sep 13 15:00:22 escabot CPU: After generic identify, caps: 178bfbff  
e3d3fbff 00000000 00000000 00000001 00000000 00000002
Sep 13 15:00:22 escabot CPU: L1 I Cache: 64K (64 bytes/line), D cache  
64K (64 bytes/line)
Sep 13 15:00:22 escabot CPU: L2 Cache: 1024K (64 bytes/line)
Sep 13 15:00:22 escabot CPU 0(2) -> Core 0
Sep 13 15:00:22 escabot CPU: After all inits, caps: 178bfbff e3d3fbff  
00000000 00000410 00000001 00000000 00000002
Sep 13 15:00:22 escabot Intel machine check architecture supported.
Sep 13 15:00:22 escabot Intel machine check reporting enabled on CPU#0.
Sep 13 15:00:22 escabot Compat vDSO mapped to ffffe000.
Sep 13 15:00:22 escabot Checking 'hlt' instruction... OK.
Sep 13 15:00:22 escabot Freeing SMP alternatives: 15k freed
Sep 13 15:00:22 escabot ACPI: Core revision 20070126
Sep 13 15:00:22 escabot CPU0: AMD Opteron(tm) Processor 280 stepping 02
Sep 13 15:00:22 escabot Booting processor 1/1 eip 2000
Sep 13 15:00:22 escabot Initializing CPU#1
Sep 13 15:00:22 escabot Calibrating delay using timer specific  
routine.. 4811.22 BogoMIPS (lpj=9622459)
Sep 13 15:00:22 escabot CPU: After generic identify, caps: 178bfbff  
e3d3fbff 00000000 00000000 00000001 00000000 00000002
Sep 13 15:00:22 escabot CPU: L1 I Cache: 64K (64 bytes/line), D cache  
64K (64 bytes/line)
Sep 13 15:00:22 escabot CPU: L2 Cache: 1024K (64 bytes/line)
Sep 13 15:00:22 escabot CPU 1(2) -> Core 1
Sep 13 15:00:22 escabot CPU: After all inits, caps: 178bfbff e3d3fbff  
00000000 00000410 00000001 00000000 00000002
Sep 13 15:00:22 escabot Intel machine check architecture supported.
Sep 13 15:00:22 escabot Intel machine check reporting enabled on CPU#1.
Sep 13 15:00:22 escabot CPU1: AMD Opteron(tm) Processor 280 stepping 02
Sep 13 15:00:22 escabot Booting processor 2/2 eip 2000
Sep 13 15:00:22 escabot Initializing CPU#2
Sep 13 15:00:22 escabot Calibrating delay using timer specific  
routine.. 4811.19 BogoMIPS (lpj=9622384)
Sep 13 15:00:22 escabot CPU: After generic identify, caps: 178bfbff  
e3d3fbff 00000000 00000000 00000001 00000000 00000002
Sep 13 15:00:22 escabot CPU: L1 I Cache: 64K (64 bytes/line), D cache  
64K (64 bytes/line)
Sep 13 15:00:22 escabot CPU: L2 Cache: 1024K (64 bytes/line)
Sep 13 15:00:22 escabot CPU 2(2) -> Core 0
Sep 13 15:00:22 escabot CPU: After all inits, caps: 178bfbff e3d3fbff  
00000000 00000410 00000001 00000000 00000002
Sep 13 15:00:22 escabot Intel machine check architecture supported.
Sep 13 15:00:22 escabot Intel machine check reporting enabled on CPU#2.
Sep 13 15:00:22 escabot CPU2: AMD Opteron(tm) Processor 280 stepping 02
Sep 13 15:00:22 escabot Booting processor 3/3 eip 2000
Sep 13 15:00:22 escabot Initializing CPU#3
Sep 13 15:00:22 escabot Calibrating delay using timer specific  
routine.. 4811.27 BogoMIPS (lpj=9622546)
Sep 13 15:00:22 escabot CPU: After generic identify, caps: 178bfbff  
e3d3fbff 00000000 00000000 00000001 00000000 00000002
Sep 13 15:00:22 escabot CPU: L1 I Cache: 64K (64 bytes/line), D cache  
64K (64 bytes/line)
Sep 13 15:00:22 escabot CPU: L2 Cache: 1024K (64 bytes/line)
Sep 13 15:00:22 escabot CPU 3(2) -> Core 1
Sep 13 15:00:22 escabot CPU: After all inits, caps: 178bfbff e3d3fbff  
00000000 00000410 00000001 00000000 00000002
Sep 13 15:00:22 escabot Intel machine check architecture supported.
Sep 13 15:00:22 escabot Intel machine check reporting enabled on CPU#3.
Sep 13 15:00:22 escabot CPU3: AMD Opteron(tm) Processor 280 stepping 02
Sep 13 15:00:22 escabot Total of 4 processors activated (19249.32  
BogoMIPS).
Sep 13 15:00:22 escabot ENABLING IO-APIC IRQs
Sep 13 15:00:22 escabot ..TIMER: vector=0x31 apic1=0 pin1=2 apic2=0  
pin2=0
Sep 13 15:00:22 escabot Brought up 4 CPUs
Sep 13 15:00:22 escabot migration_cost=4000
Sep 13 15:00:22 escabot NET: Registered protocol family 16
Sep 13 15:00:22 escabot ACPI: bus type pci registered
Sep 13 15:00:22 escabot PCI: PCI BIOS revision 2.10 entry at 0xf0096,  
last bus=6
Sep 13 15:00:22 escabot PCI: Using configuration type 1
Sep 13 15:00:22 escabot Setting up standard PCI resources
Sep 13 15:00:22 escabot ACPI: SSDT F57FD000, 059D (r1 HP         
SSDT0        1 MSFT  2000001)
Sep 13 15:00:22 escabot ACPI: SSDT F57FD700, 059D (r1 HP         
SSDT1        1 MSFT  2000001)
Sep 13 15:00:22 escabot ACPI: SSDT F57FDE00, 059D (r1 HP         
SSDT2        1 MSFT  2000001)
Sep 13 15:00:22 escabot ACPI: SSDT F57FE500, 059D (r1 HP         
SSDT3        1 MSFT  2000001)
Sep 13 15:00:22 escabot ACPI: Interpreter enabled
Sep 13 15:00:22 escabot ACPI: Using IOAPIC for interrupt routing
Sep 13 15:00:22 escabot ACPI: PCI Root Bridge [CFG0] (0000:00)
Sep 13 15:00:22 escabot PCI: Probing PCI hardware (bus 00)
Sep 13 15:00:22 escabot Boot video device is 0000:01:03.0
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Routing Table  
[\_SB_.CFG0._PRT]
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Routing Table  
[\_SB_.CFG0.PCI0._PRT]
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Routing Table  
[\_SB_.CFG0.PCI1._PRT]
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Routing Table  
[\_SB_.CFG0.PCI2._PRT]
Sep 13 15:00:22 escabot ACPI: PCI Root Bridge [CFG1] (0000:04)
Sep 13 15:00:22 escabot PCI: Probing PCI hardware (bus 04)
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Routing Table  
[\_SB_.CFG1.PCI3._PRT]
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Routing Table  
[\_SB_.CFG1.PCI4._PRT]
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Link [LNKA] (IRQs 3 5 *7  
10 11)
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Link [LNKB] (IRQs 3 5 7  
10 11) *15
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Link [LNKC] (IRQs 3 5 7  
*10 11)
Sep 13 15:00:22 escabot ACPI: PCI Interrupt Link [LNKD] (IRQs 3 *5 7  
10 11)
Sep 13 15:00:22 escabot Linux Plug and Play Support v0.97 (c) Adam Belay
Sep 13 15:00:22 escabot pnp: PnP ACPI init
Sep 13 15:00:22 escabot pnp: PnP ACPI: found 10 devices
Sep 13 15:00:22 escabot SCSI subsystem initialized
Sep 13 15:00:22 escabot usbcore: registered new interface driver usbfs
Sep 13 15:00:22 escabot usbcore: registered new interface driver hub
Sep 13 15:00:22 escabot usbcore: registered new device driver usb
Sep 13 15:00:22 escabot PCI: Using ACPI for IRQ routing
Sep 13 15:00:22 escabot PCI: If a device doesn't work, try  
"pci=routeirq".  If it helps, post a report
Sep 13 15:00:22 escabot pnp: 00:01: ioport range 0x230-0x233 has been  
reserved
Sep 13 15:00:22 escabot pnp: 00:01: ioport range 0x260-0x267 has been  
reserved
Sep 13 15:00:22 escabot pnp: 00:01: ioport range 0x4d0-0x4d1 has been  
reserved
Sep 13 15:00:22 escabot PCI: Bridge: 0000:00:03.0
Sep 13 15:00:22 escabot IO window: 4000-4fff
Sep 13 15:00:22 escabot MEM window: f5f00000-f7bfffff
Sep 13 15:00:22 escabot PREFETCH window: f8000000-f80fffff
Sep 13 15:00:22 escabot PCI: Bridge: 0000:00:07.0
Sep 13 15:00:22 escabot IO window: 5000-5fff
Sep 13 15:00:22 escabot MEM window: f7c00000-f7cfffff
Sep 13 15:00:22 escabot PREFETCH window: f8100000-f81fffff
Sep 13 15:00:22 escabot Time: acpi_pm clocksource has been installed.
Sep 13 15:00:22 escabot PCI: Bridge: 0000:00:08.0
Sep 13 15:00:22 escabot IO window: disabled.
Sep 13 15:00:22 escabot MEM window: f7d00000-f7dfffff
Sep 13 15:00:22 escabot PREFETCH window: disabled.
Sep 13 15:00:22 escabot PCI: Bridge: 0000:04:09.0
Sep 13 15:00:22 escabot IO window: 6000-6fff
Sep 13 15:00:22 escabot MEM window: f7e00000-f7efffff
Sep 13 15:00:22 escabot PREFETCH window: f8200000-f82fffff
Sep 13 15:00:22 escabot PCI: Bridge: 0000:04:0a.0
Sep 13 15:00:22 escabot IO window: 7000-7fff
Sep 13 15:00:22 escabot MEM window: f7f00000-f7ffffff
Sep 13 15:00:22 escabot PREFETCH window: f8300000-f83fffff
Sep 13 15:00:22 escabot NET: Registered protocol family 2
Sep 13 15:00:22 escabot IP route cache hash table entries: 32768  
(order: 5, 131072 bytes)
Sep 13 15:00:22 escabot TCP established hash table entries: 131072  
(order: 9, 2097152 bytes)
Sep 13 15:00:22 escabot TCP bind hash table entries: 65536 (order: 7,  
786432 bytes)
Sep 13 15:00:22 escabot TCP: Hash tables configured (established  
131072 bind 65536)
Sep 13 15:00:22 escabot TCP reno registered
Sep 13 15:00:22 escabot checking if image is initramfs...it isn't (no  
cpio magic); looks like an initrd
Sep 13 15:00:22 escabot Freeing initrd memory: 689k freed
Sep 13 15:00:22 escabot Machine check exception polling timer started.
Sep 13 15:00:22 escabot audit: initializing netlink socket (disabled)
Sep 13 15:00:22 escabot audit(1189695589.692:1): initialized
Sep 13 15:00:22 escabot highmem bounce pool size: 64 pages
Sep 13 15:00:22 escabot Installing knfsd (copyright (C) 1996  
okir@monad.swb.de).
Sep 13 15:00:22 escabot NTFS driver 2.1.28 [Flags: R/W DEBUG].
Sep 13 15:00:22 escabot SGI XFS with ACLs, large block numbers, no  
debug enabled
Sep 13 15:00:22 escabot SGI XFS Quota Management subsystem
Sep 13 15:00:22 escabot io scheduler noop registered
Sep 13 15:00:22 escabot io scheduler anticipatory registered (default)
Sep 13 15:00:22 escabot io scheduler deadline registered
Sep 13 15:00:22 escabot io scheduler cfq registered
Sep 13 15:00:22 escabot Linux agpgart interface v0.102 (c) Dave Jones
Sep 13 15:00:22 escabot [drm] Initialized drm 1.1.0 20060810
Sep 13 15:00:22 escabot input: Power Button (FF) as /class/input/input0
Sep 13 15:00:22 escabot ACPI: Power Button (FF) [PWRF]
Sep 13 15:00:22 escabot Serial: 8250/16550 driver $Revision: 1.90 $ 4  
ports, IRQ sharing disabled
Sep 13 15:00:22 escabot serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a  
16550A
Sep 13 15:00:22 escabot serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a  
16550A
Sep 13 15:00:22 escabot 00:07: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
Sep 13 15:00:22 escabot Floppy drive(s): fd0 is 1.44M
Sep 13 15:00:22 escabot FDC 0 is a National Semiconductor PC87306
Sep 13 15:00:22 escabot RAMDISK driver initialized: 16 RAM disks of  
4096K size 1024 blocksize
Sep 13 15:00:22 escabot loop: loaded (max 8 devices)
Sep 13 15:00:22 escabot Intel(R) PRO/1000 Network Driver - version  
7.3.20-k2
Sep 13 15:00:22 escabot Copyright (c) 1999-2006 Intel Corporation.
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:05:07.0[A] -> GSI 34  
(level, low) -> IRQ 16
Sep 13 15:00:22 escabot e1000: 0000:05:07.0: e1000_probe: (PCI-X: 
100MHz:64-bit) 00:11:0a:5b:21:98
Sep 13 15:00:22 escabot e1000: eth0: e1000_probe: Intel(R) PRO/1000  
Network Connection
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:05:07.1[B] -> GSI 35  
(level, low) -> IRQ 17
Sep 13 15:00:22 escabot e1000: 0000:05:07.1: e1000_probe: (PCI-X: 
100MHz:64-bit) 00:11:0a:5b:21:99
Sep 13 15:00:22 escabot e1000: eth1: e1000_probe: Intel(R) PRO/1000  
Network Connection
Sep 13 15:00:22 escabot tg3.c:v3.75.2 (June 5, 2007)
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 28  
(level, low) -> IRQ 18
Sep 13 15:00:22 escabot eth2: Tigon3 [partno(N/A) rev 2100 PHY(5704)]  
(PCIX:133MHz:64-bit) 10/100/1000Base-T Ethernet 00:16:35:3b:6b:74
Sep 13 15:00:22 escabot eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF 
[1] WireSpeed[1] TSOcap[0]
Sep 13 15:00:22 escabot eth2: dma_rwctrl[769f4000] dma_mask[64-bit]
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:03:06.1[B] -> GSI 29  
(level, low) -> IRQ 19
Sep 13 15:00:22 escabot eth3: Tigon3 [partno(N/A) rev 2100 PHY(5704)]  
(PCIX:133MHz:64-bit) 10/100/1000Base-T Ethernet 00:16:35:3b:6b:73
Sep 13 15:00:22 escabot eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF 
[0] WireSpeed[1] TSOcap[1]
Sep 13 15:00:22 escabot eth3: dma_rwctrl[769f4000] dma_mask[64-bit]
Sep 13 15:00:22 escabot Uniform Multi-Platform E-IDE driver Revision:  
7.00alpha2
Sep 13 15:00:22 escabot ide: Assuming 33MHz system bus speed for PIO  
modes; override with idebus=xx
Sep 13 15:00:22 escabot Probing IDE interface ide0...
Sep 13 15:00:22 escabot hda: CD-224E, ATAPI CD/DVD-ROM drive
Sep 13 15:00:22 escabot Probing IDE interface ide1...
Sep 13 15:00:22 escabot ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Sep 13 15:00:22 escabot hda: ATAPI 24X CD-ROM drive, 128kB Cache
Sep 13 15:00:22 escabot Uniform CD-ROM driver Revision: 3.20
Sep 13 15:00:22 escabot megaraid cmm: 2.20.2.7 (Release Date: Sun Jul  
16 00:01:03 EST 2006)
Sep 13 15:00:22 escabot megaraid: 2.20.5.1 (Release Date: Thu Nov 16  
15:32:35 EST 2006)
Sep 13 15:00:22 escabot st: Version 20070203, fixed bufsize 32768, s/ 
g segs 256
Sep 13 15:00:22 escabot SCSI Media Changer driver v0.25
Sep 13 15:00:22 escabot usbmon: debugfs is not available
Sep 13 15:00:22 escabot ohci_hcd: 2006 August 04 USB 1.1 'Open' Host  
Controller (OHCI) Driver
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:01:00.0[D] -> GSI 19  
(level, low) -> IRQ 20
Sep 13 15:00:22 escabot ohci_hcd 0000:01:00.0: OHCI Host Controller
Sep 13 15:00:22 escabot ohci_hcd 0000:01:00.0: new USB bus  
registered, assigned bus number 1
Sep 13 15:00:22 escabot ohci_hcd 0000:01:00.0: irq 20, io mem 0xf7bf0000
Sep 13 15:00:22 escabot usb usb1: configuration #1 chosen from 1 choice
Sep 13 15:00:22 escabot hub 1-0:1.0: USB hub found
Sep 13 15:00:22 escabot hub 1-0:1.0: 3 ports detected
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:01:00.1[D] -> GSI 19  
(level, low) -> IRQ 20
Sep 13 15:00:22 escabot ohci_hcd 0000:01:00.1: OHCI Host Controller
Sep 13 15:00:22 escabot ohci_hcd 0000:01:00.1: new USB bus  
registered, assigned bus number 2
Sep 13 15:00:22 escabot ohci_hcd 0000:01:00.1: irq 20, io mem 0xf7be0000
Sep 13 15:00:22 escabot usb usb2: configuration #1 chosen from 1 choice
Sep 13 15:00:22 escabot hub 2-0:1.0: USB hub found
Sep 13 15:00:22 escabot hub 2-0:1.0: 3 ports detected
Sep 13 15:00:22 escabot usbcore: registered new interface driver usblp
Sep 13 15:00:22 escabot drivers/usb/class/usblp.c: v0.13: USB Printer  
Device Class driver
Sep 13 15:00:22 escabot Initializing USB Mass Storage driver...
Sep 13 15:00:22 escabot usbcore: registered new interface driver usb- 
storage
Sep 13 15:00:22 escabot USB Mass Storage support registered.
Sep 13 15:00:22 escabot usbcore: registered new interface driver usbhid
Sep 13 15:00:22 escabot drivers/usb/input/hid-core.c: v2.6:USB HID  
core driver
Sep 13 15:00:22 escabot PNP: PS/2 Controller  
[PNP0303:KBD,PNP0f0e:PS2M] at 0x60,0x64 irq 1,12
Sep 13 15:00:22 escabot serio: i8042 KBD port at 0x60,0x64 irq 1
Sep 13 15:00:22 escabot serio: i8042 AUX port at 0x60,0x64 irq 12
Sep 13 15:00:22 escabot mice: PS/2 mouse device common for all mice
Sep 13 15:00:22 escabot input: AT Translated Set 2 keyboard as /class/ 
input/input1
Sep 13 15:00:22 escabot oprofile: using NMI interrupt.
Sep 13 15:00:22 escabot TCP cubic registered
Sep 13 15:00:22 escabot NET: Registered protocol family 1
Sep 13 15:00:22 escabot NET: Registered protocol family 17
Sep 13 15:00:22 escabot Starting balanced_irq
Sep 13 15:00:22 escabot Using IPI Shortcut mode
Sep 13 15:00:22 escabot input: ImExPS/2 Logitech Explorer Mouse as / 
class/input/input2
Sep 13 15:00:22 escabot RAMDISK: Compressed image found at block 0
Sep 13 15:00:22 escabot VFS: Mounted root (ext2 filesystem).
Sep 13 15:00:22 escabot QLogic Fibre Channel HBA Driver
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:05:08.0[A] -> GSI 32  
(level, low) -> IRQ 21
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: Found an ISP2312, irq  
21, iobase 0xf8834000
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: Configuring PCI space...
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: Configure NVRAM  
parameters...
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: Verifying loaded RISC  
code...
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: Allocated (412 KB) for  
firmware dump...
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: Waiting for LIP to  
complete...
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: LOOP UP detected (2 Gbps).
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: Topology - (F_Port),  
Host Loop address 0xffff
Sep 13 15:00:22 escabot scsi0 : qla2xxx
Sep 13 15:00:22 escabot qla2300 0000:05:08.0:
Sep 13 15:00:22 escabot QLogic Fibre Channel HBA Driver: 8.01.07-fo
Sep 13 15:00:22 escabot QLogic QLA2340 -
Sep 13 15:00:22 escabot ISP2312: PCI-X (100 MHz) @ 0000:05:08.0 hdma 
+, host#=0, fw=3.03.19 IPX
Sep 13 15:00:22 escabot scsi 0:0:0:0: Direct-Access     SUN       
CSM200_R         0619 PQ: 0 ANSI: 5
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: scsi(0:0:0:0): Enabled  
tagged queuing, queue depth 32.
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] 104857600 512-byte hardware  
sectors (53687 MB)
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] Write Protect is off
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] Mode Sense: 77 00 10 08
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] Write cache: enabled, read  
cache: enabled, supports DPO and FUA
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] 104857600 512-byte hardware  
sectors (53687 MB)
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] Write Protect is off
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] Mode Sense: 77 00 10 08
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] Write cache: enabled, read  
cache: enabled, supports DPO and FUA
Sep 13 15:00:22 escabot sda: sda1 sda2 sda3
Sep 13 15:00:22 escabot sd 0:0:0:0: [sda] Attached SCSI disk
Sep 13 15:00:22 escabot sd 0:0:0:0: Attached scsi generic sg0 type 0
Sep 13 15:00:22 escabot scsi 0:0:0:1: Direct-Access     SUN       
CSM200_R         0619 PQ: 0 ANSI: 5
Sep 13 15:00:22 escabot qla2300 0000:05:08.0: scsi(0:0:0:1): Enabled  
tagged queuing, queue depth 32.
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] 104857600 512-byte hardware  
sectors (53687 MB)
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] Write Protect is off
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] Mode Sense: 77 00 10 08
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] Write cache: enabled, read  
cache: enabled, supports DPO and FUA
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] 104857600 512-byte hardware  
sectors (53687 MB)
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] Write Protect is off
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] Mode Sense: 77 00 10 08
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] Write cache: enabled, read  
cache: enabled, supports DPO and FUA
Sep 13 15:00:22 escabot sdb: sdb1
Sep 13 15:00:22 escabot sd 0:0:0:1: [sdb] Attached SCSI disk
Sep 13 15:00:22 escabot sd 0:0:0:1: Attached scsi generic sg1 type 0
Sep 13 15:00:22 escabot ACPI: PCI Interrupt 0000:06:09.0[A] -> GSI 36  
(level, low) -> IRQ 22
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: Found an ISP2312, irq  
22, iobase 0xf8836000
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: Configuring PCI space...
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: Configure NVRAM  
parameters...
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: Verifying loaded RISC  
code...
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: Allocated (412 KB) for  
firmware dump...
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: Waiting for LIP to  
complete...
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: LIP reset occured (f8f7).
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: LIP occured (f8f7).
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: LIP reset occured (f7f7).
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: LOOP UP detected (2 Gbps).
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: Topology - (F_Port),  
Host Loop address 0xffff
Sep 13 15:00:22 escabot scsi1 : qla2xxx
Sep 13 15:00:22 escabot qla2300 0000:06:09.0:
Sep 13 15:00:22 escabot QLogic Fibre Channel HBA Driver: 8.01.07-fo
Sep 13 15:00:22 escabot QLogic QLA2340 -
Sep 13 15:00:22 escabot ISP2312: PCI-X (133 MHz) @ 0000:06:09.0 hdma 
+, host#=1, fw=3.03.19 IPX
Sep 13 15:00:22 escabot scsi 1:0:0:0: Sequential-Access IBM       
ULTRIUM-TD3      54K1 PQ: 0 ANSI: 3
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: scsi(1:0:0:0): Enabled  
tagged queuing, queue depth 32.
Sep 13 15:00:22 escabot st 1:0:0:0: Attached scsi tape st0
Sep 13 15:00:22 escabot st 1:0:0:0: st0: try direct i/o: yes  
(alignment 512 B)
Sep 13 15:00:22 escabot st 1:0:0:0: Attached scsi generic sg2 type 1
Sep 13 15:00:22 escabot scsi 1:0:0:1: Medium Changer    SPECTRA   
PYTHON           2000 PQ: 0 ANSI: 3
Sep 13 15:00:22 escabot ch0: type #1 (mt): 0x1+1 [medium transport]
Sep 13 15:00:22 escabot ch0: type #2 (st): 0x1000+30 [storage]
Sep 13 15:00:22 escabot ch0: type #3 (ie): 0x10+0 [import/export]
Sep 13 15:00:22 escabot ch0: type #4 (dt): 0x100+2 [data transfer]
Sep 13 15:00:22 escabot ch0: dt 0x100: ID/LUN unknown
Sep 13 15:00:22 escabot ch0: dt 0x101: ID/LUN unknown
Sep 13 15:00:22 escabot ch0: INITIALIZE ELEMENT STATUS, may take some  
time ...
Sep 13 15:00:22 escabot ch0: ... finished
Sep 13 15:00:22 escabot ch 1:0:0:1: Attached scsi changer ch0
Sep 13 15:00:22 escabot ch 1:0:0:1: Attached scsi generic sg3 type 8
Sep 13 15:00:22 escabot scsi 1:0:1:0: Sequential-Access IBM       
ULTRIUM-TD3      54K1 PQ: 0 ANSI: 3
Sep 13 15:00:22 escabot qla2300 0000:06:09.0: scsi(1:0:1:0): Enabled  
tagged queuing, queue depth 32.
Sep 13 15:00:22 escabot st 1:0:1:0: Attached scsi tape st1
Sep 13 15:00:22 escabot st 1:0:1:0: st1: try direct i/o: yes  
(alignment 512 B)
Sep 13 15:00:22 escabot st 1:0:1:0: Attached scsi generic sg4 type 1
Sep 13 15:00:22 escabot kjournald starting.  Commit interval 5 seconds
Sep 13 15:00:22 escabot EXT3-fs: mounted filesystem with ordered data  
mode.
Sep 13 15:00:22 escabot Freeing unused kernel memory: 240k freed
Sep 13 15:00:22 escabot EXT3 FS on sda3, internal journal
Sep 13 15:00:22 escabot kjournald starting.  Commit interval 5 seconds
Sep 13 15:00:22 escabot EXT3 FS on sdb1, internal journal
Sep 13 15:00:22 escabot EXT3-fs: mounted filesystem with ordered data  
mode.
Sep 13 15:00:22 escabot Adding 2008116k swap on /dev/sda2.   
Priority:-1 extents:1 across:2008116k
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.0 at offset b (was 164814e4, writing d00e11)
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.0 at offset 3 (was 804000, writing 804010)
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.0 at offset 2 (was 2000000, writing 2000010)
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.0 at offset 1 (was 2b00000, writing 2b00146)
Sep 13 15:00:22 escabot tg3: eth2: Link is up at 1000 Mbps, full duplex.
Sep 13 15:00:22 escabot tg3: eth2: Flow control is on for TX and on  
for RX.
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.1 at offset b (was 164814e4, writing d00e11)
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.1 at offset 3 (was 804000, writing 804010)
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.1 at offset 2 (was 2000000, writing 2000010)
Sep 13 15:00:22 escabot PM: Writing back config space on device  
0000:03:06.1 at offset 1 (was 2b00000, writing 2b00146)
Sep 13 15:00:25 escabot st0: Block limits 1 - 16777215 bytes.
Sep 13 15:00:25 escabot st1: Block limits 1 - 16777215 bytes.
Sep 13 15:00:25 escabot tg3: eth3: Link is up at 1000 Mbps, full duplex.
Sep 13 15:00:25 escabot tg3: eth3: Flow control is on for TX and on  
for RX.
Sep 13 15:04:16 escabot scsi 0:0:0:2: Direct-Access     SUN       
CSM200_R         0619 PQ: 0 ANSI: 5
Sep 13 15:04:16 escabot qla2300 0000:05:08.0: scsi(0:0:0:2): Enabled  
tagged queuing, queue depth 32.
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] 1048576000 512-byte  
hardware sectors (536871 MB)
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] Write Protect is off
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] Mode Sense: 77 00 10 08
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] Write cache: enabled, read  
cache: enabled, supports DPO and FUA
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] 1048576000 512-byte  
hardware sectors (536871 MB)
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] Write Protect is off
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] Mode Sense: 77 00 10 08
Sep 13 15:04:16 escabot sd 0:0:0:2: [sdc] Write cache: enabled, read  
cache: enabled, supports DPO and FUA
Sep 13 15:04:19 escabot sdc: sdc1
Sep 13 15:04:19 escabot sd 0:0:0:2: [sdc] Attached SCSI disk
Sep 13 15:04:19 escabot sd 0:0:0:2: Attached scsi generic sg5 type 0
Sep 13 15:04:24 escabot sd 0:0:0:2: [sdc] 1048576000 512-byte  
hardware sectors (536871 MB)
Sep 13 15:04:24 escabot sd 0:0:0:2: [sdc] Write Protect is off
Sep 13 15:04:24 escabot sd 0:0:0:2: [sdc] Mode Sense: 77 00 10 08
Sep 13 15:04:24 escabot sd 0:0:0:2: [sdc] Write cache: enabled, read  
cache: enabled, supports DPO and FUA
Sep 13 15:04:24 escabot sdc: sdc1
Sep 13 15:04:29 escabot NTFS volume version 3.1.
Sep 13 15:31:25 escabot init invoked oom-killer: gfp_mask=0xd0,  
order=0, oomkilladj=0
Sep 13 15:31:25 escabot [<c0149ea8>] out_of_memory+0x158/0x1b0
Sep 13 15:31:25 escabot [<c014b7b0>] __alloc_pages+0x2a0/0x300
Sep 13 15:31:25 escabot [<c01729aa>] core_sys_select+0x1fa/0x2f0
Sep 13 15:31:25 escabot [<c0162a21>] cache_alloc_refill+0x2e1/0x500
Sep 13 15:31:25 escabot [<c0162736>] kmem_cache_alloc+0x46/0x50
Sep 13 15:31:25 escabot [<c016e238>] getname+0x28/0xf0
Sep 13 15:31:25 escabot [<c016fe5e>] __user_walk_fd+0x1e/0x60
Sep 13 15:31:25 escabot [<c0168e29>] cp_new_stat64+0xf9/0x110
Sep 13 15:31:25 escabot [<c0169152>] vfs_stat_fd+0x22/0x60
Sep 13 15:31:25 escabot [<c016922f>] sys_stat64+0xf/0x30
Sep 13 15:31:25 escabot [<c0124956>] do_gettimeofday+0x36/0xf0
Sep 13 15:31:25 escabot [<c0120bbf>] sys_time+0xf/0x30
Sep 13 15:31:25 escabot [<c0102b10>] sysenter_past_esp+0x5d/0x81
Sep 13 15:31:25 escabot =======================
Sep 13 15:31:25 escabot Mem-info:
Sep 13 15:31:25 escabot DMA per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    1: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    2: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    3: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot Normal per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd: 143    
Cold: hi:   62, btch:  15 usd:  56
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  31    
Cold: hi:   62, btch:  15 usd:  53
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:   8    
Cold: hi:   62, btch:  15 usd:  54
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:  99    
Cold: hi:   62, btch:  15 usd:  58
Sep 13 15:31:25 escabot HighMem per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd:   1    
Cold: hi:   62, btch:  15 usd:  10
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  23    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:  18    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:   9    
Cold: hi:   62, btch:  15 usd:  12
Sep 13 15:31:25 escabot Active:8078 inactive:1776744 dirty:10338  
writeback:0 unstable:0
Sep 13 15:31:25 escabot free:1090395 slab:198893 mapped:988  
pagetables:129 bounce:0
Sep 13 15:31:25 escabot DMA free:3560kB min:68kB low:84kB high:100kB  
active:0kB inactive:0kB present:16256kB pages_scanned:0  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 873 12176
Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB high: 
5616kB active:0kB inactive:3160kB present:894080kB pages_scanned:5336  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 90424
Sep 13 15:31:25 escabot HighMem free:4354372kB min:512kB low:12640kB  
high:24768kB active:32312kB inactive:7103816kB present:11574272kB  
pages_scanned:0 all_unreclaimable? no
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 0
Sep 13 15:31:25 escabot DMA: 4*4kB 3*8kB 0*16kB 0*32kB 1*64kB 1*128kB  
1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3560kB
Sep 13 15:31:25 escabot Normal: 44*4kB 18*8kB 6*16kB 1*32kB 6*64kB  
2*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3648kB
Sep 13 15:31:25 escabot HighMem: 1*4kB 0*8kB 0*16kB 37914*32kB  
43188*64kB 1628*128kB 5*256kB 247*512kB 30*1024kB 1*2048kB 2*4096kB =  
4354372kB
Sep 13 15:31:25 escabot Swap cache: add 983, delete 972, find 0/1,  
race 0+0
Sep 13 15:31:25 escabot Free swap  = 2004216kB
Sep 13 15:31:25 escabot Total swap = 2008116kB
Sep 13 15:31:25 escabot Free swap:       2004216kB
Sep 13 15:31:25 escabot syslog-ng invoked oom-killer: gfp_mask=0xd0,  
order=0, oomkilladj=0
Sep 13 15:31:25 escabot [<c0149ea8>] out_of_memory+0x158/0x1b0
Sep 13 15:31:25 escabot [<c014b7b0>] __alloc_pages+0x2a0/0x300
Sep 13 15:31:25 escabot [<c0162a21>] cache_alloc_refill+0x2e1/0x500
Sep 13 15:31:25 escabot [<c0162736>] kmem_cache_alloc+0x46/0x50
Sep 13 15:31:25 escabot [<c016e238>] getname+0x28/0xf0
Sep 13 15:31:25 escabot [<c016fe5e>] __user_walk_fd+0x1e/0x60
Sep 13 15:31:25 escabot [<c0169152>] vfs_stat_fd+0x22/0x60
Sep 13 15:31:25 escabot [<c012f460>] autoremove_wake_function+0x0/0x50
Sep 13 15:31:25 escabot [<c0123928>] __capable+0x8/0x20
Sep 13 15:31:25 escabot [<c02d02ef>] cap_syslog+0x1f/0x30
Sep 13 15:31:25 escabot [<c0123928>] __capable+0x8/0x20
Sep 13 15:31:25 escabot [<c011d026>] do_syslog+0x3b6/0x3e0
Sep 13 15:31:25 escabot [<c016922f>] sys_stat64+0xf/0x30
Sep 13 15:31:25 escabot [<c0124956>] do_gettimeofday+0x36/0xf0
Sep 13 15:31:25 escabot [<c0120bbf>] sys_time+0xf/0x30
Sep 13 15:31:25 escabot [<c0102b10>] sysenter_past_esp+0x5d/0x81
Sep 13 15:31:25 escabot =======================
Sep 13 15:31:25 escabot Mem-info:
Sep 13 15:31:25 escabot DMA per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    1: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    2: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    3: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot Normal per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd: 143    
Cold: hi:   62, btch:  15 usd:  56
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  31    
Cold: hi:   62, btch:  15 usd:  53
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:   8    
Cold: hi:   62, btch:  15 usd:  54
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:  99    
Cold: hi:   62, btch:  15 usd:  58
Sep 13 15:31:25 escabot HighMem per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd:   1    
Cold: hi:   62, btch:  15 usd:  10
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  23    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:  18    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:   9    
Cold: hi:   62, btch:  15 usd:  12
Sep 13 15:31:25 escabot Active:8078 inactive:1776744 dirty:10338  
writeback:0 unstable:0
Sep 13 15:31:25 escabot free:1090395 slab:198893 mapped:988  
pagetables:129 bounce:0
Sep 13 15:31:25 escabot DMA free:3560kB min:68kB low:84kB high:100kB  
active:0kB inactive:0kB present:16256kB pages_scanned:0  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 873 12176
Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB high: 
5616kB active:0kB inactive:3160kB present:894080kB pages_scanned:5336  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 90424
Sep 13 15:31:25 escabot HighMem free:4354372kB min:512kB low:12640kB  
high:24768kB active:32312kB inactive:7103816kB present:11574272kB  
pages_scanned:0 all_unreclaimable? no
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 0
Sep 13 15:31:25 escabot DMA: 4*4kB 3*8kB 0*16kB 0*32kB 1*64kB 1*128kB  
1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3560kB
Sep 13 15:31:25 escabot Normal: 44*4kB 18*8kB 6*16kB 1*32kB 6*64kB  
2*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3648kB
Sep 13 15:31:25 escabot HighMem: 1*4kB 0*8kB 0*16kB 37914*32kB  
43188*64kB 1628*128kB 5*256kB 247*512kB 30*1024kB 1*2048kB 2*4096kB =  
4354372kB
Sep 13 15:31:25 escabot Swap cache: add 983, delete 972, find 0/1,  
race 0+0
Sep 13 15:31:25 escabot Free swap  = 2004216kB
Sep 13 15:31:25 escabot Total swap = 2008116kB
Sep 13 15:31:25 escabot Free swap:       2004216kB
Sep 13 15:31:25 escabot 3145727 pages of RAM
Sep 13 15:31:25 escabot 2916351 pages of HIGHMEM
Sep 13 15:31:25 escabot 69112 reserved pages
Sep 13 15:31:25 escabot 1781351 pages shared
Sep 13 15:31:25 escabot 11 pages swap cached
Sep 13 15:31:25 escabot 10338 pages dirty
Sep 13 15:31:25 escabot 0 pages writeback
Sep 13 15:31:25 escabot 988 pages mapped
Sep 13 15:31:25 escabot 198893 pages slab
Sep 13 15:31:25 escabot 129 pages pagetables
Sep 13 15:31:25 escabot Out of memory: kill process 5771 (mysqld)  
score 35692 or a child
Sep 13 15:31:25 escabot Killed process 5771 (mysqld)
Sep 13 15:31:25 escabot init invoked oom-killer: gfp_mask=0xd0,  
order=0, oomkilladj=0
Sep 13 15:31:25 escabot [<c0149ea8>] out_of_memory+0x158/0x1b0
Sep 13 15:31:25 escabot [<c014b7b0>] __alloc_pages+0x2a0/0x300
Sep 13 15:31:25 escabot [<c01729aa>] core_sys_select+0x1fa/0x2f0
Sep 13 15:31:25 escabot [<c0162a21>] cache_alloc_refill+0x2e1/0x500
Sep 13 15:31:25 escabot [<c0162736>] kmem_cache_alloc+0x46/0x50
Sep 13 15:31:25 escabot [<c016e238>] getname+0x28/0xf0
Sep 13 15:31:25 escabot [<c016fe5e>] __user_walk_fd+0x1e/0x60
Sep 13 15:31:25 escabot [<c0168e29>] cp_new_stat64+0xf9/0x110
Sep 13 15:31:25 escabot [<c0169152>] vfs_stat_fd+0x22/0x60
Sep 13 15:31:25 escabot [<c016922f>] sys_stat64+0xf/0x30
Sep 13 15:31:25 escabot [<c0124956>] do_gettimeofday+0x36/0xf0
Sep 13 15:31:25 escabot [<c0120bbf>] sys_time+0xf/0x30
Sep 13 15:31:25 escabot [<c0102b10>] sysenter_past_esp+0x5d/0x81
Sep 13 15:31:25 escabot =======================
Sep 13 15:31:25 escabot Mem-info:
Sep 13 15:31:25 escabot DMA per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    1: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    2: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    3: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot Normal per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd: 143    
Cold: hi:   62, btch:  15 usd:  56
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  31    
Cold: hi:   62, btch:  15 usd:  53
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:   8    
Cold: hi:   62, btch:  15 usd:  54
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:  99    
Cold: hi:   62, btch:  15 usd:  58
Sep 13 15:31:25 escabot HighMem per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd:   1    
Cold: hi:   62, btch:  15 usd:  10
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  23    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:  18    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:   9    
Cold: hi:   62, btch:  15 usd:  12
Sep 13 15:31:25 escabot Active:8078 inactive:1776744 dirty:10338  
writeback:0 unstable:0
Sep 13 15:31:25 escabot free:1090395 slab:198893 mapped:988  
pagetables:129 bounce:0
Sep 13 15:31:25 escabot DMA free:3560kB min:68kB low:84kB high:100kB  
active:0kB inactive:0kB present:16256kB pages_scanned:0  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 873 12176
Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB high: 
5616kB active:0kB inactive:3160kB present:894080kB pages_scanned:5336  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 90424
Sep 13 15:31:25 escabot HighMem free:4354372kB min:512kB low:12640kB  
high:24768kB active:32312kB inactive:7103816kB present:11574272kB  
pages_scanned:0 all_unreclaimable? no
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 0
Sep 13 15:31:25 escabot DMA: 4*4kB 3*8kB 0*16kB 0*32kB 1*64kB 1*128kB  
1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3560kB
Sep 13 15:31:25 escabot Normal: 44*4kB 18*8kB 6*16kB 1*32kB 6*64kB  
2*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3648kB
Sep 13 15:31:25 escabot HighMem: 1*4kB 0*8kB 0*16kB 37914*32kB  
43188*64kB 1628*128kB 5*256kB 247*512kB 30*1024kB 1*2048kB 2*4096kB =  
4354372kB
Sep 13 15:31:25 escabot Swap cache: add 983, delete 972, find 0/1,  
race 0+0
Sep 13 15:31:25 escabot Free swap  = 2004216kB
Sep 13 15:31:25 escabot Total swap = 2008116kB
Sep 13 15:31:25 escabot Free swap:       2004216kB
Sep 13 15:31:25 escabot 3145727 pages of RAM
Sep 13 15:31:25 escabot 2916351 pages of HIGHMEM
Sep 13 15:31:25 escabot 69112 reserved pages
Sep 13 15:31:25 escabot 1781351 pages shared
Sep 13 15:31:25 escabot 11 pages swap cached
Sep 13 15:31:25 escabot 10338 pages dirty
Sep 13 15:31:25 escabot 0 pages writeback
Sep 13 15:31:25 escabot 988 pages mapped
Sep 13 15:31:25 escabot 198893 pages slab
Sep 13 15:31:25 escabot 129 pages pagetables
Sep 13 15:31:25 escabot Out of memory: kill process 5789 (mysqld)  
score 35692 or a child
Sep 13 15:31:25 escabot Killed process 5789 (mysqld)
Sep 13 15:31:25 escabot syslog-ng invoked oom-killer: gfp_mask=0xd0,  
order=0, oomkilladj=0
Sep 13 15:31:25 escabot [<c0149ea8>] out_of_memory+0x158/0x1b0
Sep 13 15:31:25 escabot [<c014b7b0>] __alloc_pages+0x2a0/0x300
Sep 13 15:31:25 escabot [<c0162a21>] cache_alloc_refill+0x2e1/0x500
Sep 13 15:31:25 escabot [<c0162736>] kmem_cache_alloc+0x46/0x50
Sep 13 15:31:25 escabot [<c016e238>] getname+0x28/0xf0
Sep 13 15:31:25 escabot [<c016fe5e>] __user_walk_fd+0x1e/0x60
Sep 13 15:31:25 escabot [<c0169152>] vfs_stat_fd+0x22/0x60
Sep 13 15:31:25 escabot [<c012f460>] autoremove_wake_function+0x0/0x50
Sep 13 15:31:25 escabot [<c0123928>] __capable+0x8/0x20
Sep 13 15:31:25 escabot [<c02d02ef>] cap_syslog+0x1f/0x30
Sep 13 15:31:25 escabot [<c0123928>] __capable+0x8/0x20
Sep 13 15:31:25 escabot [<c011d026>] do_syslog+0x3b6/0x3e0
Sep 13 15:31:25 escabot [<c016922f>] sys_stat64+0xf/0x30
Sep 13 15:31:25 escabot [<c0124956>] do_gettimeofday+0x36/0xf0
Sep 13 15:31:25 escabot [<c0120bbf>] sys_time+0xf/0x30
Sep 13 15:31:25 escabot [<c0102b10>] sysenter_past_esp+0x5d/0x81
Sep 13 15:31:25 escabot =======================
Sep 13 15:31:25 escabot Mem-info:
Sep 13 15:31:25 escabot DMA per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    1: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    2: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    3: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot Normal per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd: 143    
Cold: hi:   62, btch:  15 usd:  56
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  31    
Cold: hi:   62, btch:  15 usd:  53
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:   8    
Cold: hi:   62, btch:  15 usd:  54
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd: 130    
Cold: hi:   62, btch:  15 usd:  58
Sep 13 15:31:25 escabot HighMem per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd:   1    
Cold: hi:   62, btch:  15 usd:  10
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  23    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:  18    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd: 162    
Cold: hi:   62, btch:  15 usd:  12
Sep 13 15:31:25 escabot Active:2311 inactive:1776744 dirty:10338  
writeback:0 unstable:0
Sep 13 15:31:25 escabot free:1096030 slab:198893 mapped:915  
pagetables:92 bounce:0
Sep 13 15:31:25 escabot DMA free:3560kB min:68kB low:84kB high:100kB  
active:0kB inactive:0kB present:16256kB pages_scanned:0  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 873 12176
Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB high: 
5616kB active:0kB inactive:3160kB present:894080kB pages_scanned:5336  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 90424
Sep 13 15:31:25 escabot HighMem free:4376912kB min:512kB low:12640kB  
high:24768kB active:9244kB inactive:7103816kB present:11574272kB  
pages_scanned:0 all_unreclaimable? no
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 0
Sep 13 15:31:25 escabot DMA: 4*4kB 3*8kB 0*16kB 0*32kB 1*64kB 1*128kB  
1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3560kB
Sep 13 15:31:25 escabot Normal: 44*4kB 18*8kB 6*16kB 1*32kB 6*64kB  
2*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3648kB
Sep 13 15:31:25 escabot HighMem: 107*4kB 42*8kB 39*16kB 37944*32kB  
43216*64kB 1640*128kB 15*256kB 253*512kB 35*1024kB 2*2048kB 3*4096kB  
= 4376940kB
Sep 13 15:31:25 escabot Swap cache: add 983, delete 972, find 0/1,  
race 0+0
Sep 13 15:31:25 escabot Free swap  = 2004216kB
Sep 13 15:31:25 escabot Total swap = 2008116kB
Sep 13 15:31:25 escabot Free swap:       2004216kB
Sep 13 15:31:25 escabot 3145727 pages of RAM
Sep 13 15:31:25 escabot 2916351 pages of HIGHMEM
Sep 13 15:31:25 escabot 69112 reserved pages
Sep 13 15:31:25 escabot 1780992 pages shared
Sep 13 15:31:25 escabot 11 pages swap cached
Sep 13 15:31:25 escabot 10338 pages dirty
Sep 13 15:31:25 escabot 0 pages writeback
Sep 13 15:31:25 escabot 915 pages mapped
Sep 13 15:31:25 escabot 198893 pages slab
Sep 13 15:31:25 escabot 92 pages pagetables
Sep 13 15:31:25 escabot Out of memory: kill process 5857 (bacula-dir)  
score 379 or a child
Sep 13 15:31:25 escabot Killed process 5857 (bacula-dir)
Sep 13 15:31:25 escabot init invoked oom-killer: gfp_mask=0xd0,  
order=0, oomkilladj=0
Sep 13 15:31:25 escabot [<c0149ea8>] out_of_memory+0x158/0x1b0
Sep 13 15:31:25 escabot [<c014b7b0>] __alloc_pages+0x2a0/0x300
Sep 13 15:31:25 escabot [<c01729aa>] core_sys_select+0x1fa/0x2f0
Sep 13 15:31:25 escabot [<c0162a21>] cache_alloc_refill+0x2e1/0x500
Sep 13 15:31:25 escabot [<c0162736>] kmem_cache_alloc+0x46/0x50
Sep 13 15:31:25 escabot [<c016e238>] getname+0x28/0xf0
Sep 13 15:31:25 escabot [<c016fe5e>] __user_walk_fd+0x1e/0x60
Sep 13 15:31:25 escabot [<c0168e29>] cp_new_stat64+0xf9/0x110
Sep 13 15:31:25 escabot [<c0169152>] vfs_stat_fd+0x22/0x60
Sep 13 15:31:25 escabot [<c016922f>] sys_stat64+0xf/0x30
Sep 13 15:31:25 escabot [<c0124956>] do_gettimeofday+0x36/0xf0
Sep 13 15:31:25 escabot [<c0120bbf>] sys_time+0xf/0x30
Sep 13 15:31:25 escabot [<c0102b10>] sysenter_past_esp+0x5d/0x81
Sep 13 15:31:25 escabot =======================
Sep 13 15:31:25 escabot Mem-info:
Sep 13 15:31:25 escabot DMA per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    1: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    2: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot CPU    3: Hot: hi:    0, btch:   1 usd:   0    
Cold: hi:    0, btch:   1 usd:   0
Sep 13 15:31:25 escabot Normal per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd: 151    
Cold: hi:   62, btch:  15 usd:  56
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  31    
Cold: hi:   62, btch:  15 usd:  53
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:   8    
Cold: hi:   62, btch:  15 usd:  54
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd: 130    
Cold: hi:   62, btch:  15 usd:  58
Sep 13 15:31:25 escabot HighMem per-cpu:
Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd:  63    
Cold: hi:   62, btch:  15 usd:  10
Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  23    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:  18    
Cold: hi:   62, btch:  15 usd:   1
Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd: 162    
Cold: hi:   62, btch:  15 usd:  12
Sep 13 15:31:25 escabot Active:2238 inactive:1776744 dirty:10338  
writeback:0 unstable:0
Sep 13 15:31:25 escabot free:1096030 slab:198893 mapped:842  
pagetables:92 bounce:0
Sep 13 15:31:25 escabot DMA free:3560kB min:68kB low:84kB high:100kB  
active:0kB inactive:0kB present:16256kB pages_scanned:0  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 873 12176
Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB high: 
5616kB active:0kB inactive:3160kB present:894080kB pages_scanned:5336  
all_unreclaimable? yes
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 90424
Sep 13 15:31:25 escabot HighMem free:4376912kB min:512kB low:12640kB  
high:24768kB active:8952kB inactive:7103816kB present:11574272kB  
pages_scanned:0 all_unreclaimable? no
Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 0
Sep 13 15:31:25 escabot DMA: 4*4kB 3*8kB 0*16kB 0*32kB 1*64kB 1*128kB  
1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3560kB
Sep 13 15:31:25 escabot Normal: 44*4kB 18*8kB 6*16kB 1*32kB 6*64kB  
2*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3648kB
Sep 13 15:31:25 escabot HighMem: 107*4kB 42*8kB 39*16kB 37944*32kB  
43216*64kB 1640*128kB 15*256kB 253*512kB 35*1024kB 2*2048kB 3*4096kB  
= 4376940kB
Sep 13 15:31:25 escabot Swap cache: add 983, delete 972, find 0/1,  
race 0+0
Sep 13 15:31:25 escabot Free swap  = 2004644kB
Sep 13 15:31:25 escabot Total swap = 2008116kB
Sep 13 15:31:25 escabot Free swap:       2004644kB
Sep 13 15:31:25 escabot 3145727 pages of RAM
Sep 13 15:31:25 escabot 2916351 pages of HIGHMEM
Sep 13 15:31:25 escabot 69112 reserved pages
Sep 13 15:31:25 escabot 1780742 pages shared
Sep 13 15:31:25 escabot 11 pages swap cached
Sep 13 15:31:25 escabot 10338 pages dirty
Sep 13 15:31:25 escabot 0 pages writeback
Sep 13 15:31:25 escabot 842 pages mapped
Sep 13 15:31:25 escabot 198893 pages slab
Sep 13 15:31:25 escabot 92 pages pagetables
Sep 13 15:31:25 escabot Out of memory: kill process 5868 (bacula-sd)  
score 350 or a child
Sep 13 15:31:25 escabot Killed process 5868 (bacula-sd)
Sep 13 15:31:25 escabot 3145727 pages of RAM
Sep 13 15:31:25 escabot 2916351 pages of HIGHMEM
Sep 13 15:31:25 escabot 69112 reserved pages
Sep 13 15:31:25 escabot 1780407 pages shared
Sep 13 15:31:25 escabot 11 pages swap cached
Sep 13 15:31:25 escabot 10338 pages dirty
Sep 13 15:31:25 escabot 0 pages writeback
Sep 13 15:31:25 escabot 842 pages mapped
Sep 13 15:31:25 escabot 198893 pages slab
Sep 13 15:31:25 escabot 92 pages pagetables
Sep 13 15:31:25 escabot Out of memory: kill process 6032 (sshd) score  
223 or a child
Sep 13 15:31:25 escabot Killed process 6180 (sshd)
</quote>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
