Date: Fri, 9 Mar 2007 15:06:50 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <Pine.LNX.4.64.0703081135280.3130@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0703091503580.16052@skynet.skynet.ie>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
 <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
 <20070308174004.GB12958@skynet.ie> <Pine.LNX.4.64.0703081135280.3130@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

> Note that I am amazed that the kernbench even worked.

The results without slub_debug were not good except for IA64. x86_64 and 
ppc64 both blew up for a variety of reasons. The IA64 results were

KernBench Comparison
--------------------
                           2.6.21-rc2-mm2-clean       2.6.21-rc2-mm2-slub      %diff
User   CPU time                        1084.64                   1032.93      4.77%
System CPU time                          73.38                     63.14     13.95%
Total  CPU time                        1158.02                   1096.07      5.35%
Elapsed    time                         307.00                    285.62      6.96%

AIM9 Comparison
---------------
                  2.6.21-rc2-mm2-clean        2.6.21-rc2-mm2-slub
  1 creat-clo                425460.75                  438809.64   13348.89  3.14% File Creations and Closes/second
  2 page_test               2097119.26                 3398259.27 1301140.01 62.04% System Allocations & Pages/second
  3 brk_test                7008395.33                 6728755.72 -279639.61 -3.99% System Memory Allocations/second
  4 jmp_test               12226295.31                12254966.21   28670.90  0.23% Non-local gotos/second
  5 signal_test             1271126.28                 1235510.96  -35615.32 -2.80% Signal Traps/second
  6 exec_test                   395.54                     381.18     -14.36 -3.63% Program Loads/second
  7 fork_test                 13218.23                   13211.41      -6.82 -0.05% Task Creations/second
  8 link_test                 64776.04                    7488.13  -57287.91 -88.44% Link/Unlink Pairs/second

An example console log from x86_64 is below. It's not particular clear why 
it went blamo and I haven't had a chance all day to kick it around for a 
bit due to a variety of other hilarity floating around.

Linux version 2.6.21-rc2-mm2-autokern1 (root@bl6-13.ltc.austin.ibm.com) (gcc version 4.1.1 20060525 (Red Hat 4.1.1-1)) #1 SMP Thu Mar 8 12:13:27 CST 2007
Command line: ro root=/dev/VolGroup00/LogVol00 rhgb console=tty0 console=ttyS1,19200 selinux=no autobench_args: root=30726124 ABAT:1173378546 loglevel=8
BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 000000000009d400 (usable)
  BIOS-e820: 000000000009d400 - 00000000000a0000 (reserved)
  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
  BIOS-e820: 0000000000100000 - 000000003ffcddc0 (usable)
  BIOS-e820: 000000003ffcddc0 - 000000003ffd0000 (ACPI data)
  BIOS-e820: 000000003ffd0000 - 0000000040000000 (reserved)
  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
Entering add_active_range(0, 0, 157) 0 entries of 3200 used
Entering add_active_range(0, 256, 262093) 1 entries of 3200 used
end_pfn_map = 1048576
DMI 2.3 present.
ACPI: RSDP 000FDFC0, 0014 (r0 IBM   )
ACPI: RSDT 3FFCFF80, 0034 (r1 IBM    SERBLADE     1000 IBM  45444F43)
ACPI: FACP 3FFCFEC0, 0084 (r2 IBM    SERBLADE     1000 IBM  45444F43)
ACPI: DSDT 3FFCDDC0, 1EA6 (r1 IBM    SERBLADE     1000 INTL  2002025)
ACPI: FACS 3FFCFCC0, 0040
ACPI: APIC 3FFCFE00, 009C (r1 IBM    SERBLADE     1000 IBM  45444F43)
ACPI: SRAT 3FFCFD40, 0098 (r1 IBM    SERBLADE     1000 IBM  45444F43)
ACPI: HPET 3FFCFD00, 0038 (r1 IBM    SERBLADE     1000 IBM  45444F43)
SRAT: PXM 0 -> APIC 0 -> Node 0
SRAT: PXM 0 -> APIC 1 -> Node 0
SRAT: PXM 1 -> APIC 2 -> Node 1
SRAT: PXM 1 -> APIC 3 -> Node 1
SRAT: Node 0 PXM 0 0-40000000
Entering add_active_range(0, 0, 157) 0 entries of 3200 used
Entering add_active_range(0, 256, 262093) 1 entries of 3200 used
NUMA: Using 63 for the hash shift.
Bootmem setup node 0 0000000000000000-000000003ffcd000
Node 0 memmap at 0xffff81003efcd000 size 16773952 first pfn 0xffff81003efcd000
sizeof(struct page) = 64
Zone PFN ranges:
   DMA             0 ->     4096
   DMA32        4096 ->  1048576
   Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
     0:        0 ->      157
     0:      256 ->   262093
On node 0 totalpages: 261994
   DMA zone: 64 pages used for memmap
   DMA zone: 2017 pages reserved
   DMA zone: 1916 pages, LIFO batch:0
   DMA32 zone: 4031 pages used for memmap
   DMA32 zone: 253966 pages, LIFO batch:31
   Normal zone: 0 pages used for memmap
   Movable zone: 0 pages used for memmap
ACPI: PM-Timer IO Port: 0x2208
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
Processor #1
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
Processor #2
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
Processor #3
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x0e] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 14, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x0d] address[0xfec10000] gsi_base[24])
IOAPIC[1]: apic_id 13, address 0xfec10000, GSI 24-27
ACPI: IOAPIC (id[0x0c] address[0xfec20000] gsi_base[48])
IOAPIC[2]: apic_id 12, address 0xfec20000, GSI 48-51
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ11 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x10228203 base: 0xfecff000
Using ACPI (MADT) for SMP configuration information
Nosave address range: 000000000009d000 - 000000000009e000
Nosave address range: 000000000009e000 - 00000000000a0000
Nosave address range: 00000000000a0000 - 00000000000e0000
Nosave address range: 00000000000e0000 - 0000000000100000
Allocating PCI resources starting at 50000000 (gap: 40000000:bec00000)
SMP: Allowing 4 CPUs, 0 hotplug CPUs
PERCPU: Allocating 66368 bytes of per cpu data
Built 1 zonelists.  Total pages: 255882
Kernel command line: ro root=/dev/VolGroup00/LogVol00 rhgb console=tty0 console=ttyS1,19200 selinux=no autobench_args: root=30726124 ABAT:1173378546 loglevel=8
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
Marking TSC unstable due to TSCs unsynchronized
time.c: Detected 1993.781 MHz processor.
Console: colour VGA+ 80x25
Checking aperture...
CPU 0: aperture @ dc000000 size 64 MB
CPU 1: aperture @ dc000000 size 64 MB
Memory: 1021548k/1048372k available (2878k kernel code, 26428k reserved, 1472k data, 340k init)
SLUB V4: General Slabs=11, HW alignment=64, Processors=4, Nodes=64
Calibrating delay using timer specific routine.. 3991.49 BogoMIPS (lpj=7982991)
Security Framework v1.0.0 initialized
SELinux:  Disabled at boot.
Capability LSM initialized
Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
Mount-cache hash table entries: 256
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
CPU 0/0 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
SMP alternatives: switching to UP code
ACPI: Core revision 20070126
Using local APIC timer interrupts.
result 12461150
Detected 12.461 MHz APIC timer.
SMP alternatives: switching to SMP code
Booting processor 1/4 APIC 0x1
Initializing CPU#1
Calibrating delay using timer specific routine.. 3987.64 BogoMIPS (lpj=7975295)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
Dual Core AMD Opteron(tm) Processor 270 stepping 02
SMP alternatives: switching to SMP code
Booting processor 2/4 APIC 0x2
Initializing CPU#2
Calibrating delay using timer specific routine.. 3987.64 BogoMIPS (lpj=7975291)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
CPU 2/2 -> Node 0
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 0
Dual Core AMD Opteron(tm) Processor 270 stepping 02
SMP alternatives: switching to SMP code
Booting processor 3/4 APIC 0x3
Initializing CPU#3
Calibrating delay using timer specific routine.. 3987.64 BogoMIPS (lpj=7975292)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
CPU 3/3 -> Node 0
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 1
Dual Core AMD Opteron(tm) Processor 270 stepping 02
Brought up 4 CPUs
migration_cost=413
PM: Adding info for No Bus:platform
NET: Registered protocol family 16
PM: Adding info for No Bus:vtcon0
ACPI: bus type pci registered
PCI: Using configuration type 1
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S4 S5)
ACPI: Using IOAPIC for interrupt routing
PM: Adding info for acpi:acpi_system:00
PM: Adding info for acpi:button_power:00
PM: Adding info for acpi:ACPI0007:00
PM: Adding info for acpi:ACPI0007:01
PM: Adding info for acpi:ACPI0007:02
PM: Adding info for acpi:ACPI0007:03
PM: Adding info for acpi:device:00
PM: Adding info for acpi:PNP0A03:00
PM: Adding info for acpi:device:01
PM: Adding info for acpi:device:02
PM: Adding info for acpi:device:03
PM: Adding info for acpi:device:04
PM: Adding info for acpi:PNP0C02:00
PM: Adding info for acpi:PNP0501:00
PM: Adding info for acpi:PNP0501:01
PM: Adding info for acpi:PNP0000:00
PM: Adding info for acpi:PNP0003:00
PM: Adding info for acpi:PNP0003:01
PM: Adding info for acpi:PNP0003:02
PM: Adding info for acpi:PNP0200:00
PM: Adding info for acpi:PNP0100:00
PM: Adding info for acpi:PNP0B00:00
PM: Adding info for acpi:PNP0800:00
PM: Adding info for acpi:PNP0C04:00
PM: Adding info for acpi:PNP0C02:01
PM: Adding info for acpi:device:05
PM: Adding info for acpi:device:06
PM: Adding info for acpi:device:07
PM: Adding info for acpi:PNP0103:00
PM: Adding info for acpi:device:08
PM: Adding info for acpi:device:09
PM: Adding info for acpi:device:0a
PM: Adding info for acpi:device:0b
PM: Adding info for acpi:device:0c
PM: Adding info for acpi:device:0d
PM: Adding info for acpi:thermal:00
PM: Adding info for acpi:PNP0C0F:00
PM: Adding info for acpi:PNP0C0F:01
PM: Adding info for acpi:PNP0C0F:02
PM: Adding info for acpi:PNP0C0F:03
ACPI: PCI Root Bridge [PCI0] (0000:00)
PM: Adding info for No Bus:pci0000:00
Boot video device is 0000:01:04.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
PM: Adding info for pci:0000:00:06.0
PM: Adding info for pci:0000:00:07.0
PM: Adding info for pci:0000:00:07.3
PM: Adding info for pci:0000:00:0a.0
PM: Adding info for pci:0000:00:0a.1
PM: Adding info for pci:0000:00:0b.0
PM: Adding info for pci:0000:00:0b.1
PM: Adding info for pci:0000:00:18.0
PM: Adding info for pci:0000:00:18.1
PM: Adding info for pci:0000:00:18.2
PM: Adding info for pci:0000:00:18.3
PM: Adding info for pci:0000:00:19.0
PM: Adding info for pci:0000:00:19.1
PM: Adding info for pci:0000:00:19.2
PM: Adding info for pci:0000:00:19.3
PM: Adding info for pci:0000:01:00.0
PM: Adding info for pci:0000:01:00.1
PM: Adding info for pci:0000:01:04.0
PM: Adding info for pci:0000:02:01.0
PM: Adding info for pci:0000:02:01.1
PM: Adding info for pci:0000:02:02.0
ACPI: PCI Interrupt Link [LP00] (IRQs *10)
ACPI: PCI Interrupt Link [LP01] (IRQs *7)
ACPI: PCI Interrupt Link [LP02] (IRQs *9)
ACPI: PCI Interrupt Link [LP03] (IRQs *5)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
PM: Adding info for No Bus:pnp0
PM: Adding info for pnp:00:00
PM: Adding info for pnp:00:01
PM: Adding info for pnp:00:02
PM: Adding info for pnp:00:03
PM: Adding info for pnp:00:04
PM: Adding info for pnp:00:05
PM: Adding info for pnp:00:06
PM: Adding info for pnp:00:07
PM: Adding info for pnp:00:08
PM: Adding info for pnp:00:09
PM: Adding info for pnp:00:0a
PM: Adding info for pnp:00:0b
PM: Adding info for pnp:00:0c
pnp: PnP ACPI: found 13 devices
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
hpet0: at MMIO 0xfecff000, IRQs 2, 8, 0
hpet0: 3 32-bit timers, 14318180 Hz
pnp: 00:01: ioport range 0x510-0x517 has been reserved
Time: hpet clocksource has been installed.
pnp: 00:01: ioport range 0x504-0x507 has been reserved
pnp: 00:01: ioport range 0x500-0x503 has been reserved
pnp: 00:01: ioport range 0x520-0x53f has been reserved
pnp: 00:01: ioport range 0x540-0x547 has been reserved
pnp: 00:01: ioport range 0x460-0x461 has been reserved
pnp: 00:0b: iomem range 0xfec00000-0xffffffff has been reserved
PM: Adding info for No Bus:mem
PM: Adding info for No Bus:kmem
PM: Adding info for No Bus:null
PM: Adding info for No Bus:port
PM: Adding info for No Bus:zero
PM: Adding info for No Bus:full
PM: Adding info for No Bus:random
PM: Adding info for No Bus:urandom
PM: Adding info for No Bus:kmsg
PCI: Bridge: 0000:00:06.0
   IO window: 3000-3fff
   MEM window: fd000000-feafffff
   PREFETCH window: f0000000-fcffffff
PCI: Bridge: 0000:00:0a.0
   IO window: 4000-4fff
   MEM window: ee000000-efffffff
   PREFETCH window: 50000000-500fffff
PCI: Bridge: 0000:00:0b.0
   IO window: 5000-ffff
   MEM window: disabled.
   PREFETCH window: disabled.
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
TCP established hash table entries: 131072 (order: 10, 5242880 bytes)
TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 1602k freed
PM: Adding info for No Bus:mcelog
PM: Adding info for No Bus:msr0
PM: Adding info for No Bus:msr1
PM: Adding info for No Bus:msr2
PM: Adding info for No Bus:msr3
PM: Adding info for No Bus:cpu0
PM: Adding info for No Bus:cpu1
PM: Adding info for No Bus:cpu2
PM: Adding info for No Bus:cpu3
PM: Adding info for platform:pcspkr
audit: initializing netlink socket (disabled)
audit(1173357216.800:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
PM: Adding info for platform:vesafb.0
ACPI: Processor [CPU3] (supports 8 throttling states)
ACPI: Processor [CPU2] (supports 8 throttling states)
ACPI: Processor [CPU1] (supports 8 throttling states)
ACPI: Processor [CPU0] (supports 8 throttling states)
PM: Adding info for No Bus:tty
PM: Adding info for No Bus:console
PM: Adding info for No Bus:ptmx
PM: Adding info for No Bus:tty0
PM: Adding info for No Bus:vcs
PM: Adding info for No Bus:vcsa
PM: Adding info for No Bus:tty1
PM: Adding info for No Bus:tty2
PM: Adding info for No Bus:tty3
PM: Adding info for No Bus:tty4
PM: Adding info for No Bus:tty5
PM: Adding info for No Bus:tty6
PM: Adding info for No Bus:tty7
PM: Adding info for No Bus:tty8
PM: Adding info for No Bus:tty9
PM: Adding info for No Bus:tty10
PM: Adding info for No Bus:tty11
PM: Adding info for No Bus:tty12
PM: Adding info for No Bus:tty13
PM: Adding info for No Bus:tty14
PM: Adding info for No Bus:tty15
PM: Adding info for No Bus:tty16
PM: Adding info for No Bus:tty17
PM: Adding info for No Bus:tty18
PM: Adding info for No Bus:tty19
PM: Adding info for No Bus:tty20
PM: Adding info for No Bus:tty21
PM: Adding info for No Bus:tty22
PM: Adding info for No Bus:tty23
PM: Adding info for No Bus:tty24
PM: Adding info for No Bus:tty25
PM: Adding info for No Bus:tty26
PM: Adding info for No Bus:tty27
PM: Adding info for No Bus:tty28
PM: Adding info for No Bus:tty29
PM: Adding info for No Bus:tty30
PM: Adding info for No Bus:tty31
PM: Adding info for No Bus:tty32
PM: Adding info for No Bus:tty33
PM: Adding info for No Bus:tty34
PM: Adding info for No Bus:tty35
PM: Adding info for No Bus:tty36
PM: Adding info for No Bus:tty37
PM: Adding info for No Bus:tty38
PM: Adding info for No Bus:tty39
PM: Adding info for No Bus:tty40
PM: Adding info for No Bus:tty41
PM: Adding info for No Bus:tty42
PM: Adding info for No Bus:tty43
PM: Adding info for No Bus:tty44
PM: Adding info for No Bus:tty45
PM: Adding info for No Bus:tty46
PM: Adding info for No Bus:tty47
PM: Adding info for No Bus:tty48
PM: Adding info for No Bus:tty49
PM: Adding info for No Bus:tty50
PM: Adding info for No Bus:tty51
PM: Adding info for No Bus:tty52
PM: Adding info for No Bus:tty53
PM: Adding info for No Bus:tty54
PM: Adding info for No Bus:tty55
PM: Adding info for No Bus:tty56
PM: Adding info for No Bus:tty57
PM: Adding info for No Bus:tty58
PM: Adding info for No Bus:tty59
PM: Adding info for No Bus:tty60
PM: Adding info for No Bus:tty61
PM: Adding info for No Bus:tty62
PM: Adding info for No Bus:tty63
PM: Adding info for No Bus:rtc
Real Time Clock Driver v1.12ac
PM: Adding info for No Bus:hpet
hpet_resources: 0xfecff000 is busy
Linux agpgart interface v0.102 (c) Dave Jones
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
PM: Adding info for platform:serial8250
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
PM: Adding info for No Bus:ttyS0
erial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
PM: Adding info for No Bus:ttyS1
PM: Adding info for No Bus:ttyS2
PM: Adding info for No Bus:ttyS3
PM: Removing info for No Bus:ttyS0
00:02: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
PM: Adding info for No Bus:ttyS0
PM: Removing info for No Bus:ttyS1
00:03: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
PM: Adding info for No Bus:ttyS1
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
tg3.c:v3.74 (February 20, 2007)
ACPI: PCI Interrupt 0000:02:01.0[A] -> GSI 24 (level, low) -> IRQ 24
PM: Adding info for No Bus:eth0
eth0: Tigon3 [partno(BCM95704A41) rev 2100 PHY(serdes)] (PCIX:100MHz:64-bit) 1000Base-SX Ethernet 00:11:25:75:af:6e
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[0] TSOcap[0] 
eth0: dma_rwctrl[769f4000] dma_mask[64-bit]
ACPI: PCI Interrupt 0000:02:01.1[B] -> GSI 25 (level, low) -> IRQ 25
PM: Adding info for No Bus:eth1
eth1: Tigon3 [partno(BCM95704A41) rev 2100 PHY(serdes)] (PCIX:100MHz:64-bit) 1000Base-SX Ethernet 00:11:25:75:af:6f
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[0] TSOcap[1] 
eth1: dma_rwctrl[769f4000] dma_mask[64-bit]
PM: Adding info for No Bus:lo
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
Probing IDE interface ide0...
Probing IDE interface ide1...
ide-floppy driver 0.99.newide
Fusion MPT base driver 3.04.04
Copyright (c) 1999-2007 LSI Logic Corporation
Fusion MPT SPI Host driver 3.04.04
ACPI: PCI Interrupt 0000:02:02.0[A] -> GSI 26 (level, low) -> IRQ 26
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities={Initiator}
scsi0 : ioc0: LSI53C1030, FwRev=01032700h, Ports=1, MaxQ=222, IRQ=26
PM: Adding info for No Bus:host0
PM: Adding info for No Bus:target0:0:0
scsi 0:0:0:0: Direct-Access     IBM-ESXS ST973401LC    FN B41D PQ: 0 ANSI: 4
  target0:0:0: Beginning Domain Validation
  target0:0:0: Ending Domain Validation
  target0:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU RTI WRFLOW PCOMP (6.25 ns, offset 63)
PM: Adding info for scsi:0:0:0:0
SCSI device sda: 143374000 512-byte hdwr sectors (73407 MB)
sda: Write Protect is off
sda: Mode Sense: b3 00 10 08
SCSI device sda: write cache: disabled, read cache: enabled, supports DPO and FUA
SCSI device sda: 143374000 512-byte hdwr sectors (73407 MB)
sda: Write Protect is off
sda: Mode Sense: b3 00 10 08
SCSI device sda: write cache: disabled, read cache: enabled, supports DPO and FUA
  sda: sda1 sda2
sd 0:0:0:0: Attached scsi disk sda
sd 0:0:0:0: Attached scsi generic sg0 type 0
PM: Adding info for No Bus:target0:0:1
PM: Removing info for No Bus:target0:0:1
PM: Adding info for No Bus:target0:0:2
PM: Removing info for No Bus:target0:0:2
PM: Adding info for No Bus:target0:0:3
PM: Removing info for No Bus:target0:0:3
PM: Adding info for No Bus:target0:0:4
PM: Removing info for No Bus:target0:0:4
PM: Adding info for No Bus:target0:0:5
PM: Removing info for No Bus:target0:0:5
PM: Adding info for No Bus:target0:0:6
PM: Removing info for No Bus:target0:0:6
PM: Adding info for No Bus:target0:0:8
PM: Removing info for No Bus:target0:0:8
PM: Adding info for No Bus:target0:0:9
PM: Removing info for No Bus:target0:0:9
PM: Adding info for No Bus:target0:0:10
PM: Removing info for No Bus:target0:0:10
PM: Adding info for No Bus:target0:0:11
PM: Removing info for No Bus:target0:0:11
PM: Adding info for No Bus:target0:0:12
PM: Removing info for No Bus:target0:0:12
PM: Adding info for No Bus:target0:0:13
PM: Removing info for No Bus:target0:0:13
PM: Adding info for No Bus:target0:0:14
PM: Removing info for No Bus:target0:0:14
PM: Adding info for No Bus:target0:0:15
PM: Removing info for No Bus:target0:0:15
PM: Adding info for No Bus:target0:1:0
PM: Removing info for No Bus:target0:1:0
PM: Adding info for No Bus:target0:1:1
PM: Removing info for No Bus:target0:1:1
PM: Adding info for No Bus:target0:1:2
PM: Removing info for No Bus:target0:1:2
PM: Adding info for No Bus:target0:1:3
PM: Removing info for No Bus:target0:1:3
PM: Adding info for No Bus:target0:1:4
PM: Removing info for No Bus:target0:1:4
PM: Adding info for No Bus:target0:1:5
PM: Removing info for No Bus:target0:1:5
PM: Adding info for No Bus:target0:1:6
PM: Removing info for No Bus:target0:1:6
PM: Adding info for No Bus:target0:1:8
PM: Removing info for No Bus:target0:1:8
PM: Adding info for No Bus:target0:1:9
PM: Removing info for No Bus:target0:1:9
PM: Adding info for No Bus:target0:1:10
PM: Removing info for No Bus:target0:1:10
PM: Adding info for No Bus:target0:1:11
PM: Removing info for No Bus:target0:1:11
PM: Adding info for No Bus:target0:1:12
PM: Removing info for No Bus:target0:1:12
PM: Adding info for No Bus:target0:1:13
PM: Removing info for No Bus:target0:1:13
PM: Adding info for No Bus:target0:1:14
PM: Removing info for No Bus:target0:1:14
PM: Adding info for No Bus:target0:1:15
PM: Removing info for No Bus:target0:1:15
Fusion MPT FC Host driver 3.04.04
Fusion MPT SAS Host driver 3.04.04
Fusion MPT misc device (ioctl) driver 3.04.04
PM: Adding info for No Bus:mptctl
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor=10,220)
Fusion MPT LAN driver 3.04.04
mptlan: ioc0: PortNum=0, ProtocolFlags=08h (Itlb)
mptlan: ioc0: Hmmm... LAN protocol seems to be disabled on this adapter port!
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ACPI: PCI Interrupt 0000:01:00.0[D] -> GSI 19 (level, low) -> IRQ 19
ohci_hcd 0000:01:00.0: OHCI Host Controller
ohci_hcd 0000:01:00.0: new USB bus registered, assigned bus number 1
ohci_hcd 0000:01:00.0: irq 19, io mem 0xfeaff000
usb usb1: new device found, idVendor=0000, idProduct=0000
usb usb1: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: OHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.21-rc2-mm2-autokern1 ohci_hcd
usb usb1: SerialNumber: 0000:01:00.0
PM: Adding info for usb:usb1
PM: Adding info for No Bus:usbdev1.1_ep00
usb usb1: configuration #1 chosen from 1 choice
PM: Adding info for usb:1-0:1.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 3 ports detected
PM: Adding info for No Bus:usbdev1.1_ep81
PM: Adding info for No Bus:usbdev1.1
ACPI: PCI Interrupt 0000:01:00.1[D] -> GSI 19 (level, low) -> IRQ 19
ohci_hcd 0000:01:00.1: OHCI Host Controller
ohci_hcd 0000:01:00.1: new USB bus registered, assigned bus number 2
ohci_hcd 0000:01:00.1: irq 19, io mem 0xfeafe000
usb usb2: new device found, idVendor=0000, idProduct=0000
usb usb2: new device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: OHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.21-rc2-mm2-autokern1 ohci_hcd
usb usb2: SerialNumber: 0000:01:00.1
PM: Adding info for usb:usb2
PM: Adding info for No Bus:usbdev2.1_ep00
usb usb2: configuration #1 chosen from 1 choice
PM: Adding info for usb:2-0:1.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
PM: Adding info for No Bus:usbdev2.1_ep81
PM: Adding info for No Bus:usbdev2.1
USB Universal Host Controller Interface driver v3.0
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
usbcore: registered new interface driver libusual
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
PNP: No PS/2 controller found. Probing ports directly.
PM: Adding info for platform:i8042
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
PM: Adding info for serio:serio0
PM: Adding info for serio:serio1
mice: PS/2 mouse device common for all mice
async_tx: api initialized (sync-only)
xor: automatically using best checksumming function: generic_sse
    generic_sse:  6105.000 MB/sec
xor: using function: generic_sse (6105.000 MB/sec)
PM: Adding info for No Bus:device-mapper
device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
powernow-k8: Found 4 Dual Core AMD Opteron(tm) Processor 270 processors (version 2.00.00)
powernow-k8: MP systems not supported by PSB BIOS structure
powernow-k8: MP systems not supported by PSB BIOS structure
powernow-k8: MP systems not supported by PSB BIOS structure
powernow-k8: MP systems not supported by PSB BIOS structure
Freeing unused kernel memory: 340k freed
Write protecting the kernel read-only data: 984k
Red Hat nash version 5.0.32 starting
Mounting proc filesystem
Mounting sysfs filesystem
Creating /dev
Creating initial device nodes
Setting up hotplug.
Creating block device nodes.
Making device-mapper control node
Scanning logical volumes
   Reading all physical volumes.  This may take a while...
   Found volume group "VolGroup00" using metadata type lvm2
Activating logical volumes
   4 logical volume(s) in volume group "VolGroup00" now active
Creating root device.
Mounting root filesystem.
kjournald starting.  Commit interval 5 seconds
Setting up otherEXT3-fs: mounted filesystem with ordered data mode.
  filesystems.
Setting up new root fs
no fstab.sys, mounting internal defaults
Switching to new root and running init.
unmounting old /dev
unmounting old /proc
unmounting old /sys
PM: Adding info for No Bus:vcs1
PM: Adding info for No Bus:vcsa1
PM: Removing info for No Bus:vcs1
PM: Removing info for No Bus:vcsa1
INIT: version 2.86 booting
                 Welcome to Fedora Core
                 Press 'I' to enter interactive startup.
Setting clock  (localtime): Thu Mar  8 12:33:58 CST 2007 [  OK  ]
Starting udev: [  OK  ]
Setting hostname bl6-13.ltc.austin.ibm.com:  [  OK  ]
Setting up Logical Volume Management:   4 logical volume(s) in volume group "VolGroup00" now active
[  OK  ]
Checking filesystems
Checking all file systems.
[/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a /dev/VolGroup00/LogVol00 
/dev/VolGroup00/LogVol00: clean, 363818/7929856 files, 3638923/7929856 blocks
[/sbin/fsck.ext3 (1) -- /boot] fsck.ext3 -a /dev/sda1 
/boot: clean, 85/512512 files, 81422/512064 blocks
[  OK  ]
Remounting root filesystem in read-write mode:  [  OK  ]
Mounting local filesystems:  [  OK  ]
Enabling local filesystem quotas:  [  OK  ]
Enabling swap space:  [  OK  ]
INIT: Entering runlevel: 3
Entering non-interactive startup
Starting readahead_early:  Starting background readahead: [  OK  ]
[  OK  ]
FATAL: Error inserting acpi_cpufreq (/lib/modules/2.6.21-rc2-mm2-autokern1/kernel/arch/x86_64/kernel/cpufreq/acpi-cpufreq.ko): No such device
Bringing up loopback interface:  [  OK  ]
Bringing up interface eth1:  [  OK  ]
Starting system logger: [  OK  ]
Starting kernel logger: [  OK  ]
Starting irqbalance: [  OK  ]
Starting portmap: [  OK  ]
Starting NFS statd: [  OK  ]
Starting RPC idmapd: [  OK  ]
Starting kdump:  No kdump kernel image found.[WARNING]
Tried to locate /boot/vmlinux--kdump[  OK  ]
Starting system message bus: [  OK  ]
Starting Bluetooth services:[  OK  ][  OK  ]
Mounting other filesystems:  [  OK  ]
Starting hidd: [  OK  ]
Starting automount: [  OK  ]
Starting smartd: [  OK  ]
Starting acpi daemon: [  OK  ]
Starting hpiod: [  OK  ]
Starting hpssd: [  OK  ]
Starting cups: [  OK  ]
Starting sshd: [  OK  ]
Starting sendmail: [  OK  ]
Starting sm-client: [  OK  ]
Starting console mouse services: [  OK  ]
Starting crond: [  OK  ]
Starting xfs: [  OK  ]
Starting anacron: [  OK  ]
Starting atd: [  OK  ]
Starting Avahi daemon: general protection fault: 0000 [1] SMP 
last sysfs file: class/net/eth1/address
CPU 3 
Modules linked in: ipv6 hidp rfcomm l2cap bluetooth sunrpc video button battery asus_acpi ac lp parport_pc parport nvram pcspkr amd_rng rng_core i2c_amd756 i2c_core
Pid: 0, comm: swapper Not tainted 2.6.21-rc2-mm2-autokern1 #1
RIP: 0010:[<ffffffff80483dbc>]  [<ffffffff80483dbc>] inet_putpeer+0x10/0x53
RSP: 0018:ffff810001813ec0  EFLAGS: 00010202
RAX: ffff810001623500 RBX: e805b300000003bf RCX: ffff8100039c8438
RDX: ffff81000219c280 RSI: ffff81000104bf80 RDI: ffffffff80622970
RBP: ffff81000219c280 R08: 0000000000000003 R09: ffff810002f54100
R10: 00000000fc000106 R11: ffff8100039c83c0 R12: 0000000000000000
R13: 0000000000000003 R14: 0000000000000000 R15: 0000000000000000
FS:  00002ab1c24786f0(0000) GS:ffff810001401680(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00002ab1c2217000 CR3: 0000000003be8000 CR4: 00000000000006e0
Process swapper (pid: 0, threadinfo ffff81000162e000, task ffff810001623500)
Stack:  ffff810002eb3600 ffffffff80483bfe ffff810001628000 ffff810002e88200
  ffff81000219c280 ffffffff8046c03b ffff81000219c500 ffff81000104bf80
  0000000000000001 ffffffff804801a8 0000000000000001 ffffffff8025d8e2
Call Trace:
  <IRQ>  [<ffffffff80483bfe>] ipv4_dst_destroy+0x2c/0x58
  [<ffffffff8046c03b>] dst_destroy+0x85/0xdf
  [<ffffffff804801a8>] dst_rcu_free+0x19/0x29
  [<ffffffff8025d8e2>] __rcu_process_callbacks+0x122/0x18a
  [<ffffffff8023722b>] __do_softirq+0x55/0xc3
  [<ffffffff8020acfc>] call_softirq+0x1c/0x28
  [<ffffffff8020c095>] do_softirq+0x2c/0x7d
  [<ffffffff80218ae6>] smp_apic_timer_interrupt+0x49/0x5f
  [<ffffffff80208ca4>] default_idle+0x0/0x3d
  [<ffffffff8020a7a6>] apic_timer_interrupt+0x66/0x70
  <EOI>  [<ffffffff80208ccd>] default_idle+0x29/0x3d
  [<ffffffff80208d6c>] cpu_idle+0x8b/0xae


Code: f0 ff 4b 2c 0f 94 c0 84 c0 74 2b 48 8b 05 ba eb 19 00 48 c7 
RIP  [<ffffffff80483dbc>] inet_putpeer+0x10/0x53
  RSP <ffff810001813ec0>
Kernel panic - not syncing: Aiee, killing interrupt handler!
-- 0:conmux-control -- time-stamp -- Mar/08/07 10:34:35 --
-- 0:conmux-control -- time-stamp -- Mar/08/07 10:47:37 --
(bot:conmon-payload) disconnected

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
