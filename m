Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 701396B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 11:16:44 -0400 (EDT)
Message-ID: <49B68450.9000505@hp.com>
Date: Tue, 10 Mar 2009 11:16:32 -0400
From: "Alan D. Brunelle" <Alan.Brunelle@hp.com>
MIME-Version: 1.0
Subject: PROBLEM: kernel BUG at mm/slab.c:3002!
Content-Type: multipart/mixed;
 boundary="------------070006050408000404030204"
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070006050408000404030204
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Running blktrace & I/O loads cause a kernel BUG at mm/slab.c:3002!.

I'm running some moderate I/O loads (using 12 devices behind a Smart
Array on a 16-way x86_64 box, I'm doing asynchronous direct sequential
reads to each disk in parallel), and whilst attempting to get blktrace
data I routinely run into this.

I first started seeing this in 2.6.29-rc6, so I bumped to 2.6.29-rc7 and
 made a couple of successful runs, then ran into it again. (I've
attached the script I was using, but I'm not sure it's very helpful...)

The environment the system under test is in is rather difficult to
bisect in, but if need be, I can certainly go through the (painful)
motions to do so...

I only ran this a couple of times on 2.6.27.7-4 (SLESS 11 b6 kernel),
and both times it worked there - not sure how far back the problem occurs...

I'm open to any SLAB debug tracing options that may help with this...

Alan D.Brunelle
Hewlett-Packard

--------------070006050408000404030204
Content-Type: text/x-log;
 name="seatpost.log"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
 filename="seatpost.log"

------------[ cut here ]------------
kernel BUG at mm/slab.c:3002!
invalid opcode: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/cpu15/cache/index2/shared_cpu_map
CPU 6 
Modules linked in: xfs exportfs fuse ext2 loop dm_mod sd_mod crc_t10dif bnx2 ipmi_si sg qla2xxx shpchp scsi_transport_fc sr_mod rtc_cmos button container ipmi_msghandler hpilo hpwdt rtc_core pci_hotplug pcspkr rtc_lib cdrom scsi_tgt serio_raw usbhid hid ehci_hcd uhci_hcd ohci_hcd usbcore edd ext3 mbcache jbd fan ide_pci_generic amd74xx ide_core pata_amd thermal processor thermal_sys hwmon cciss ata_generic libata scsi_mod
Pid: 11346, comm: blktrace Tainted: G    B      2.6.29-rc7 #3 ProLiant DL585 G5   
RIP: 0010:[<ffffffff802c5099>]  [<ffffffff802c5099>] cache_alloc_refill+0x107/0x229
RSP: 0018:ffff88081384d9e8  EFLAGS: 00010046
RAX: 0000000000000070 RBX: ffff88187fc01340 RCX: 0000000000000015
RDX: ffff88187c032000 RSI: ffff88187c682000 RDI: ffff88187fc01350
RBP: ffff88081384da28 R08: ffff88187fc01360 R09: 00000000000000d2
R10: ffff8817f4b9eabf R11: 000000000000000a R12: ffff88187c762c00
R13: 0000000000000027 R14: ffff88087fc00040 R15: 00000000000492d0
FS:  00007f3b2d6806f0(0000) GS:ffff88187c7671c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f3b2d022f30 CR3: 000000183c883000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process blktrace (pid: 11346, threadinfo ffff88081384c000, task ffff88082e5ae140)
Stack:
 ffff88081384da78 ffffffff802b7061 000000021384da18 0000000000000002
 ffff88087fc00040 00000000000080d0 0000000000000292 ffff88181f992ec0
 ffff88081384da68 ffffffff802c4cb1 0000000077c6c910 ffff88187a89fc80
Call Trace:
 [<ffffffff802b7061>] ? alloc_vmap_area+0x1fe/0x211
 [<ffffffff802c4cb1>] kmem_cache_alloc_node+0x9a/0xe6
 [<ffffffff80289a49>] ? relay_open_buf+0x9f/0x23c
 [<ffffffff802c56a2>] __kmalloc_node+0x43/0x45
 [<ffffffff802b79af>] __vmalloc_area_node+0x76/0x14b
 [<ffffffff80289a49>] ? relay_open_buf+0x9f/0x23c
 [<ffffffff802b7b00>] __vmalloc_node+0x7c/0x8c
 [<ffffffff80289a49>] ? relay_open_buf+0x9f/0x23c
 [<ffffffff802b7c34>] vmalloc+0x1f/0x21
 [<ffffffff80289a49>] relay_open_buf+0x9f/0x23c
 [<ffffffff8028a4b3>] relay_open+0x144/0x218
 [<ffffffff8036a643>] do_blk_trace_setup+0x1a4/0x59b
 [<ffffffff8036aa7e>] blk_trace_setup+0x44/0x75
 [<ffffffff8036ad56>] blk_trace_ioctl+0x9a/0xcf
 [<ffffffff802d4685>] ? path_put+0x2c/0x30
 [<ffffffff80361dd8>] blkdev_ioctl+0x803/0x853
 [<ffffffff802d615b>] ? putname+0x30/0x39
 [<ffffffff802d80be>] ? user_path_at+0x5d/0x8c
 [<ffffffff802e2e67>] ? mntput_no_expire+0x31/0x18f
 [<ffffffff802d4685>] ? path_put+0x2c/0x30
 [<ffffffff802f10f3>] block_ioctl+0x38/0x3c
 [<ffffffff802d9690>] vfs_ioctl+0x2a/0x78
 [<ffffffff802d9b24>] do_vfs_ioctl+0x446/0x482
 [<ffffffff8024ff46>] ? do_sigaction+0x166/0x187
 [<ffffffff802d9bb5>] sys_ioctl+0x55/0x77
 [<ffffffff8020c42a>] system_call_fastpath+0x16/0x1b
Code: 00 00 00 48 8b 33 48 39 de 75 14 48 8b 73 20 c7 43 60 01 00 00 00 4c 39 c6 0f 84 a6 00 00 00 8b 46 20 41 3b 86 18 10 00 00 72 33 <0f> 0b eb fe ff c0 41 8b 0c 24 41 8b 96 0c 10 00 00 89 46 20 8b 
RIP  [<ffffffff802c5099>] cache_alloc_refill+0x107/0x229
 RSP <ffff88081384d9e8>
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
hpwdt: An NMI occurred, but unable to determine source.
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.29-rc7 (root@seatpost) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #3 SMP Tue Mar 10 10:15:07 EDT 2009
Command line: root=/dev/cciss/c0d2p3 text resume=/dev/cciss/c0d2p2  vga=0x317 console=ttyS1,115200N8 elevator=deadline sysrq=1 reset_devices irqpoll maxcpus=1  memmap=exactmap memmap=640K@0K memmap=130412K@17024K elfcorehdr=147436K memmap=32K#2095416K
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000100 - 000000000009f400 (usable)
 BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007fe4e000 (usable)
 BIOS-e820: 000000007fe4e000 - 000000007fe56000 (ACPI data)
 BIOS-e820: 000000007fe56000 - 000000007fe57000 (usable)
 BIOS-e820: 000000007fe57000 - 0000000080000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fed00000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee10000 (reserved)
 BIOS-e820: 00000000ffc00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 000000207ffff000 (usable)
last_pfn = 0x207ffff max_arch_pfn = 0x100000000
user-defined physical RAM map:
 user: 0000000000000000 - 00000000000a0000 (usable)
 user: 00000000010a0000 - 0000000008ffb000 (usable)
 user: 000000007fe4e000 - 000000007fe56000 (ACPI data)
DMI 2.4 present.
last_pfn = 0x8ffb max_arch_pfn = 0x100000000
x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
init_memory_mapping: 0000000000000000-0000000008ffb000
Using GB pages for direct mapping
last_map_addr: 8ffb000 end: 8ffb000
RAMDISK: 08601000 - 08fef000
ACPI: RSDP 000F4F00, 0024 (r2 HP    )
ACPI: XSDT 7FE4ED00, 0074 (r1 HP     ProLiant        2   O     162E)
ACPI: FACP 7FE4ED80, 00F4 (r3 HP     A07             2   O     162E)
FADT: X_PM1a_EVT_BLK.bit_width (16) does not match PM1_EVT_LEN (4)
ACPI: DSDT 7FE4EE80, 4958 (r1 HP         DSDT        1 INTL 20030228)
ACPI: FACS 7FE4E100, 0040
ACPI: SPCR 7FE4E140, 0050 (r1 HP     SPCRRBSU        1   O     162E)
ACPI: HPET 7FE4E1C0, 0038 (r1 HP     ProLiant        2   O     162E)
ACPI: SPMI 7FE4E200, 0040 (r5 HP     ProLiant        1   O     162E)
ACPI: ERST 7FE4E240, 01D0 (r1 HP     ProLiant        1   O     162E)
ACPI: APIC 7FE4E440, 0106 (r1 HP     ProLiant        2             0)
ACPI: SRAT 7FE4E580, 0220 (r1 AMD    HAMMER          1 AMD         1)
ACPI: FFFF 7FE4E980, 0176 (r1 HP     ProLiant        1   O     162E)
ACPI: BERT 7FE4EB00, 0030 (r1 HP     ProLiant        1   O     162E)
ACPI: HEST 7FE4EB40, 018C (r1 HP     ProLiant        1   O     162E)
SRAT: PXM 0 -> APIC 0 -> Node 0
SRAT: PXM 0 -> APIC 1 -> Node 0
SRAT: PXM 0 -> APIC 2 -> Node 0
SRAT: PXM 0 -> APIC 3 -> Node 0
SRAT: PXM 1 -> APIC 4 -> Node 1
SRAT: PXM 1 -> APIC 5 -> Node 1
SRAT: PXM 1 -> APIC 6 -> Node 1
SRAT: PXM 1 -> APIC 7 -> Node 1
SRAT: PXM 2 -> APIC 8 -> Node 2
SRAT: PXM 2 -> APIC 9 -> Node 2
SRAT: PXM 2 -> APIC 10 -> Node 2
SRAT: PXM 2 -> APIC 11 -> Node 2
SRAT: PXM 3 -> APIC 12 -> Node 3
SRAT: PXM 3 -> APIC 13 -> Node 3
SRAT: PXM 3 -> APIC 14 -> Node 3
SRAT: PXM 3 -> APIC 15 -> Node 3
SRAT: Node 0 PXM 0 0-a0000
SRAT: Node 0 PXM 0 100000-80000000
SRAT: Node 0 PXM 0 100000000-880000000
SRAT: Node 1 PXM 1 880000000-1080000000
SRAT: Node 2 PXM 2 1080000000-1880000000
SRAT: Node 3 PXM 3 1880000000-2080000000
Bootmem setup node 0 0000000000000000-0000000008ffb000
  NODE_DATA [000000000004a080 - 000000000006207f]
  bootmap [0000000000063000 -  00000000000641ff] pages 2
(7 early reservations) ==> bootmem [0000000000 - 0008ffb000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0001200000 - 0001afcbac]    TEXT DATA BSS ==> [0001200000 - 0001afcbac]
  #3 [0008601000 - 0008fef000]          RAMDISK ==> [0008601000 - 0008fef000]
  #4 [000009f400 - 0000100000]    BIOS reserved ==> [000009f400 - 0000100000]
  #5 [0000008000 - 0000009000]          PGTABLE ==> [0000008000 - 0000009000]
  #6 [0000009000 - 000004a080]       MEMNODEMAP ==> [0000009000 - 000004a080]
found SMP MP-table at [ffff8800000f4f80] 000f4f80
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x000000a0
    0: 0x000010a0 -> 0x00008ffb
ACPI: PM-Timer IO Port: 0x908
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x08] enabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0c] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x09] enabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0d] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x0a] enabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0e] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0b] enabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0f] enabled)
ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x08] address[0xd97f0000] gsi_base[0])
IOAPIC[0]: apic_id 8, version 0, address 0xd97f0000, GSI 0-23
ACPI: IOAPIC (id[0x09] address[0xd9fd0000] gsi_base[24])
IOAPIC[1]: apic_id 9, version 0, address 0xd9fd0000, GSI 24-30
ACPI: IOAPIC (id[0x0a] address[0xd9fe0000] gsi_base[31])
IOAPIC[2]: apic_id 10, version 0, address 0xd9fe0000, GSI 31-37
ACPI: IOAPIC (id[0x0b] address[0xd9ff0000] gsi_base[38])
IOAPIC[3]: apic_id 11, version 0, address 0xd9ff0000, GSI 38-61
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 0 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: NMI_SRC (dfl dfl global_irq 28)
ACPI: NMI_SRC (dfl dfl global_irq 35)
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x10228201 base: 0xfed00000
SMP: Allowing 16 CPUs, 0 hotplug CPUs
PM: Registered nosave memory: 00000000000a0000 - 00000000010a0000
Allocating PCI resources starting at 80000000 (gap: 7fe56000:801aa000)
NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:16 nr_node_ids:1
PERCPU: Allocating 65536 bytes of per cpu data
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 32259
Policy zone: DMA32
Kernel command line: root=/dev/cciss/c0d2p3 text resume=/dev/cciss/c0d2p2  vga=0x317 console=ttyS1,115200N8 elevator=deadline sysrq=1 reset_devices irqpoll maxcpus=1  memmap=exactmap memmap=640K@0K memmap=130412K@17024K elfcorehdr=147436K memmap=32K#2095416K
Misrouted IRQ fixup and polling support enabled
This may significantly impact system performance
Initializing CPU#0
PID hash table entries: 512 (order: 9, 4096 bytes)
Extended CMOS year: 2000
Fast TSC calibration using PIT
Detected 2308.603 MHz processor.
Spurious LAPIC timer interrupt on cpu 0
Console: colour dummy device 80x25
console [ttyS1] enabled
allocated 2621440 bytes of page_cgroup
please try cgroup_disable=memory option if you don't want
Checking aperture...
No AGP bridge found
Node 0: aperture @ 20000000 size 64 MB
Node 1: aperture @ 20000000 size 64 MB
Node 2: aperture @ 20000000 size 64 MB
Node 3: aperture @ 20000000 size 64 MB
Memory: 103560k/147436k available (2777k kernel code, 16384k absent, 27492k reserved, 2461k data, 1500k init)
HPET: 3 timers in total, 0 timers will be used for per-cpu timer
Calibrating delay loop (skipped), value calculated using timer frequency.. 4617.19 BogoMIPS (lpj=9234388)
Security Framework initialized
SELinux:  Disabled at boot.
Dentry cache hash table entries: 16384 (order: 5, 131072 bytes)
Inode-cache hash table entries: 8192 (order: 4, 65536 bytes)
Mount-cache hash table entries: 256
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 0/0x9 -> Node 0
CPU: Physical Processor ID: 2
CPU: Processor Core ID: 1
using C1E aware idle routine
SMP alternatives: switching to UP code
ACPI: Core revision 20081204
Setting APIC routing to physical flat
..TIMER: vector=0x30 apic1=0 pin1=0 apic2=-1 pin2=-1
CPU0: Quad-Core AMD Opteron(tm) Processor 8356 stepping 03
Brought up 1 CPUs
Total of 1 processors activated (4617.19 BogoMIPS).
net_namespace: 1840 bytes
Booting paravirtualized kernel on bare hardware
NET: Registered protocol family 16
TOM: 0000000080000000 aka 2048M
TOM2: 0000002080000000 aka 133120M
ACPI: bus type pci registered
PCI: Using configuration type 1 for base access
PCI: Using configuration type 1 for extended access
bio: create slab <bio-0> at 0
ACPI: Interpreter enabled
ACPI: (supports S0 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:02.0: PME# disabled
pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:02.1: PME# disabled
pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0c.0: PME# disabled
pci 0000:00:0d.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0d.0: PME# disabled
pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0e.0: PME# disabled
pci 0000:01:04.0: PME# supported from D0 D3hot D3cold
pci 0000:01:04.0: PME# disabled
pci 0000:01:04.2: PME# supported from D0 D3hot D3cold
pci 0000:01:04.2: PME# disabled
pci 0000:01:04.4: PME# supported from D0 D3hot D3cold
pci 0000:01:04.4: PME# disabled
pci 0000:01:04.6: PME# supported from D0 D3hot D3cold
pci 0000:01:04.6: PME# disabled
pci 0000:00:09.0: transparent bridge
pci 0000:08:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
ACPI: PCI Root Bridge [PCI1] (0000:40)
pci 0000:40:0b.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:40:0b.0: PME# disabled
pci 0000:40:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:40:0c.0: PME# disabled
pci 0000:40:0d.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:40:0d.0: PME# disabled
pci 0000:40:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:40:0e.0: PME# disabled
pci 0000:40:10.0: Enabling HT MSI Mapping
pci 0000:40:11.0: Enabling HT MSI Mapping
pci 0000:4f:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:4c:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:49:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:46:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:41:01.0: PME# supported from D3hot D3cold
pci 0000:41:01.0: PME# disabled
pci 0000:41:02.0: PME# supported from D3hot D3cold
pci 0000:41:02.0: PME# disabled
ACPI: PCI Interrupt Link [LNKW] (IRQs *16)
ACPI: PCI Interrupt Link [LNKX] (IRQs *17)
ACPI: PCI Interrupt Link [LNKY] (IRQs *18)
ACPI: PCI Interrupt Link [LNKZ] (IRQs *19)
ACPI: PCI Interrupt Link [LNU0] (IRQs *22)
ACPI: PCI Interrupt Link [LNU2] (IRQs *23)
ACPI: PCI Interrupt Link [LNKA] (IRQs *54)
ACPI: PCI Interrupt Link [LNKB] (IRQs *55)
ACPI: PCI Interrupt Link [LNKC] (IRQs *56)
ACPI: PCI Interrupt Link [LNKD] (IRQs *57)
PCI: Using ACPI for IRQ routing
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 31
hpet0: 3 comparators, 32-bit 25.000000 MHz counter
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: ioport range 0x408-0x40f has been reserved
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0x700-0x73f has been reserved
system 00:01: ioport range 0x800-0x8fe has been reserved
system 00:01: ioport range 0x900-0x9fe has been reserved
system 00:01: ioport range 0x9ff-0x9ff has been reserved
system 00:01: ioport range 0xa00-0xafe has been reserved
system 00:01: ioport range 0xaff-0xaff has been reserved
system 00:01: ioport range 0xb00-0xbfe has been reserved
system 00:01: ioport range 0xbff-0xbff has been reserved
system 00:01: ioport range 0xc80-0xc83 has been reserved
system 00:01: ioport range 0xcd4-0xcd7 has been reserved
system 00:01: ioport range 0xcf9-0xcf9 could not be reserved
system 00:01: ioport range 0xf50-0xf58 has been reserved
system 00:01: ioport range 0xca0-0xca1 has been reserved
system 00:01: ioport range 0xca4-0xca5 has been reserved
system 00:01: ioport range 0xc00-0xc03 has been reserved
system 00:01: ioport range 0x2f8-0x2ff has been reserved
pci 0000:00:09.0: PCI bridge, secondary bus 0000:01
pci 0000:00:09.0:   IO window: 0x1000-0x2fff
pci 0000:00:09.0:   MEM window: 0xd9800000-0xd99fffff
pci 0000:00:09.0:   PREFETCH window: 0x000000d0000000-0x000000d7ffffff
pci 0000:00:0c.0: PCI bridge, secondary bus 0000:08
pci 0000:00:0c.0:   IO window: 0x5000-0x5fff
pci 0000:00:0c.0:   MEM window: 0xd9d00000-0xd9efffff
pci 0000:00:0c.0:   PREFETCH window: 0x00000080000000-0x000000800fffff
pci 0000:00:0d.0: PCI bridge, secondary bus 0000:05
pci 0000:00:0d.0:   IO window: 0x4000-0x4fff
pci 0000:00:0d.0:   MEM window: 0xd9c00000-0xd9cfffff
pci 0000:00:0d.0:   PREFETCH window: 0x00000080100000-0x000000801fffff
pci 0000:00:0e.0: PCI bridge, secondary bus 0000:02
pci 0000:00:0e.0:   IO window: 0x3000-0x3fff
pci 0000:00:0e.0:   MEM window: 0xd9a00000-0xd9bfffff
pci 0000:00:0e.0:   PREFETCH window: 0x00000080200000-0x000000802fffff
pci 0000:40:0b.0: PCI bridge, secondary bus 0000:4f
pci 0000:40:0b.0:   IO window: 0x9000-0x9fff
pci 0000:40:0b.0:   MEM window: 0xdfe00000-0xdfefffff
pci 0000:40:0b.0:   PREFETCH window: 0x000000d9f00000-0x000000d9ffffff
pci 0000:40:0c.0: PCI bridge, secondary bus 0000:4c
pci 0000:40:0c.0:   IO window: 0x8000-0x8fff
pci 0000:40:0c.0:   MEM window: 0xdfd00000-0xdfdfffff
pci 0000:40:0c.0:   PREFETCH window: 0x000000de000000-0x000000de0fffff
pci 0000:40:0d.0: PCI bridge, secondary bus 0000:49
pci 0000:40:0d.0:   IO window: 0x7000-0x7fff
pci 0000:40:0d.0:   MEM window: 0xdfc00000-0xdfcfffff
pci 0000:40:0d.0:   PREFETCH window: 0x000000de100000-0x000000de1fffff
pci 0000:40:0e.0: PCI bridge, secondary bus 0000:46
pci 0000:40:0e.0:   IO window: 0x6000-0x6fff
pci 0000:40:0e.0:   MEM window: 0xdfa00000-0xdfbfffff
pci 0000:40:0e.0:   PREFETCH window: 0x000000de200000-0x000000de2fffff
pci 0000:40:10.0: PCI bridge, secondary bus 0000:41
pci 0000:40:10.0:   IO window: disabled
pci 0000:40:10.0:   MEM window: 0xda000000-0xddffffff
pci 0000:40:10.0:   PREFETCH window: 0x000000de300000-0x000000de3fffff
pci 0000:40:11.0: PCI bridge, secondary bus 0000:42
pci 0000:40:11.0:   IO window: disabled
pci 0000:40:11.0:   MEM window: disabled
pci 0000:40:11.0:   PREFETCH window: disabled
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 1, 8192 bytes)
TCP established hash table entries: 4096 (order: 4, 65536 bytes)
TCP bind hash table entries: 4096 (order: 4, 65536 bytes)
TCP: Hash tables configured (established 4096 bind 4096)
TCP reno registered
NET: Registered protocol family 1
Unpacking initramfs...<0>Kernel panic - not syncing: invalid compressed format (err=1)

--------------070006050408000404030204
Content-Type: text/plain;
 name="ver_linux.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ver_linux.txt"

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux seatpost 2.6.29-rc7 #3 SMP Tue Mar 10 10:15:07 EDT 2009 x86_64 x86_64 x86_64 GNU/Linux
 
Gnu C                  4.3
Gnu make               3.81
binutils               2.19
util-linux             2.14.1
mount                  support
module-init-tools      3.4
e2fsprogs              1.41.1
reiserfsprogs          3.6.19
xfsprogs               2.10.1
quota-tools            3.16.
PPP                    2.4.5
Linux C Library        2.9
Dynamic linker (ldd)   2.9
Procps                 3.2.7
Net-tools              1.60
Kbd                    1.14.1
oprofile               0.9.4
Sh-utils               6.12
udev                   128
wireless-tools         30
Modules Loaded         fuse ext2 loop dm_mod sd_mod crc_t10dif bnx2 qla2xxx sg scsi_transport_fc rtc_cmos ipmi_si shpchp sr_mod rtc_core ipmi_msghandler pcspkr rtc_lib serio_raw hpwdt pci_hotplug cdrom button scsi_tgt container hpilo usbhid hid ehci_hcd uhci_hcd ohci_hcd usbcore edd ext3 mbcache jbd fan ide_pci_generic amd74xx ide_core pata_amd thermal processor thermal_sys hwmon cciss ata_generic libata scsi_mod

--------------070006050408000404030204
Content-Type: text/x-python;
 name="doit.py"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="doit.py"

#! /usr/bin/env python

import os, sys, tempfile, time
import parse_aiod

dsfs	= 'sdy sdz sdaa sdab sdac sdad sdae sdaf sdag sdah sdai sdaj'.split()

def run_aiod(bs, dsfs, rnd):
	def gen_aiod_cmd(bs, dsfs):
		aiod_cmd= '/usr/local/bin/aiod'
		opts	= '-A 256 -D -I -i 10000000 -l -v'
		xopts	= '-R -b %dk -T 30' % bs
		cmd = '%s %s %s' % (aiod_cmd, opts, xopts)
		if rnd:
			cmd = '%s -z' % cmd
		for path in ['/dev/%s' % dsf for dsf in dsfs]:
			cmd = '%s %s' % (cmd, path)
		return cmd

	(fd, fn) = tempfile.mkstemp()
	fo = os.fdopen(fd, 'w')

	pid = os.fork()
	if pid == 0:
		os.dup2(fo.fileno(), sys.stdout.fileno())
		os.dup2(fo.fileno(), sys.stderr.fileno())
		fo.close()

		cmd = gen_aiod_cmd(bs, dsfs).split(None)
		os.execvp(cmd[0], cmd)
		sys.exit(1)
	else:
		fo.close()
		os.waitpid(pid, 0)

	pa = parse_aiod.parse_aiod(fn)
	mbps = pa.get_mb_per_sec()
	del pa

	os.unlink(fn)
	return mbps

if __name__ == '__main__':
	def start_bt(dir, dsfs):
		if os.path.exists(dir):
			os.system('/bin/rm -rf ' + dir)
		os.mkdir(dir)
		cmd = '/usr/local/bin/blktrace -D %s -b 1024 -n 6' % dir
		for dsf in dsfs:
			cmd = '%s /dev/%s' % (cmd, dsf)

		pid = os.fork()
		if pid > 0:
			time.sleep(30)
			return pid

		fo = open('%s/bt.out' % dir, 'w')
		os.dup2(fo.fileno(), sys.stdout.fileno())
		os.dup2(fo.fileno(), sys.stderr.fileno())
		fo.close()

		cmd = cmd.split(None)
		os.execvp(cmd[0], cmd)
		sys.exit(1)

	def stop_bt(pid):
		os.kill(pid, 1)
		os.waitpid(pid, 0)

	#bss = [ 4, 8, 16, 32, 64, 128, 256 ]
	bss = [ 32, 64, 128 ]

	print '%3s:' % 'run',
	for bs in bss:
		print '%6d ' % bs,
	print '\n----',
	for bs in bss:
		print '%6s ' % '------', 
	print ''
	for run in range(0, 3):
		print '%3d:' % run,
		sys.stdout.flush()
		for bs in bss:
			pid = start_bt('%03dk_%03d' % (bs, run), dsfs)
			print '%6.2f ' % run_aiod(bs, dsfs, False),
			sys.stdout.flush()
			stop_bt(pid)
		print ''

	sys.exit(0)

--------------070006050408000404030204--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
