Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A97BD6B0085
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 10:41:12 -0500 (EST)
Date: Wed, 10 Nov 2010 16:40:57 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: BUG: Bad page state in process (current git)
Message-ID: <20101110154057.GA2191@arch.trippelsdorf.de>
References: <20101110152519.GA1626@arch.trippelsdorf.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110152519.GA1626@arch.trippelsdorf.de>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 2010.11.10 at 16:25 +0100, Markus Trippelsdorf wrote:
> This happend twice in the last 24h on my machine:
> 
> Nov  9 20:29:42 arch kernel: BUG: Bad page state in process mutt  pfn:a6869
> Nov  9 20:29:42 arch kernel: page:ffffea000246d6f8 count:0 mapcount:0 mapping:          (null) index:0x0
> Nov  9 20:29:42 arch kernel: page flags: 0x4000000000000008(uptodate)
> Nov  9 20:29:42 arch kernel: Pid: 1794, comm: mutt Not tainted 2.6.37-rc1-00168-gb369291-dirty #72
> Nov  9 20:29:42 arch kernel: Call Trace:
> Nov  9 20:29:42 arch kernel: [<ffffffff810a1d32>] ? bad_page+0x92/0xe0
> Nov  9 20:29:42 arch kernel: [<ffffffff810a2f50>] ? get_page_from_freelist+0x4b0/0x570
> Nov  9 20:29:42 arch kernel: [<ffffffff810a3123>] ? __alloc_pages_nodemask+0x113/0x6b0
> Nov  9 20:29:42 arch kernel: [<ffffffff8109c5f4>] ? find_get_page+0x64/0xb0
> Nov  9 20:29:42 arch kernel: [<ffffffff8109c858>] ? filemap_fault+0x98/0x4b0
> Nov  9 20:29:42 arch kernel: [<ffffffff811807ec>] ? cpumask_any_but+0x2c/0x40
> Nov  9 20:29:42 arch kernel: [<ffffffff810b4acc>] ? do_wp_page+0xbc/0x7e0
> Nov  9 20:29:42 arch kernel: [<ffffffff810b6ab3>] ? handle_mm_fault+0x4e3/0x970
> Nov  9 20:29:42 arch kernel: [<ffffffff8104b1d0>] ? do_page_fault+0x120/0x410
> Nov  9 20:29:42 arch kernel: [<ffffffff8144af8f>] ? page_fault+0x1f/0x30
> Nov  9 20:29:42 arch kernel: [<ffffffff8118a09d>] ? __put_user_4+0x1d/0x30
> Nov  9 20:29:42 arch kernel: [<ffffffff8144af8f>] ? page_fault+0x1f/0x30
> Nov  9 20:29:42 arch kernel: Disabling lock debugging due to kernel taint
> 
> 
> Nov 10 14:35:25 arch kernel: BUG: Bad page state in process firefox-bin  pfn:a049d
> Nov 10 14:35:25 arch kernel: page:ffffea0002310258 count:0 mapcount:0 mapping:          (null) index:0x0
> Nov 10 14:35:25 arch kernel: page flags: 0x4000000000000008(uptodate)
> Nov 10 14:35:25 arch kernel: Pid: 23080, comm: firefox-bin Not tainted 2.6.37-rc1-00168-gb369291-dirty #72
> Nov 10 14:35:25 arch kernel: Call Trace:
> Nov 10 14:35:25 arch kernel: [<ffffffff810a1d32>] ? bad_page+0x92/0xe0
> Nov 10 14:35:25 arch kernel: [<ffffffff810a2f50>] ? get_page_from_freelist+0x4b0/0x570
> Nov 10 14:35:25 arch kernel: [<ffffffff8105325c>] ? enqueue_task_fair+0x14c/0x190
> Nov 10 14:35:25 arch kernel: [<ffffffff810a3123>] ? __alloc_pages_nodemask+0x113/0x6b0
> Nov 10 14:35:25 arch kernel: [<ffffffff8109bb04>] ? file_read_actor+0xc4/0x190
> Nov 10 14:35:25 arch kernel: [<ffffffff8109d788>] ? generic_file_aio_read+0x558/0x6a0
> Nov 10 14:35:25 arch kernel: [<ffffffff810b6c8d>] ? handle_mm_fault+0x6bd/0x970
> Nov 10 14:35:25 arch kernel: [<ffffffff810cda2f>] ? do_sync_read+0xbf/0x100
> Nov 10 14:35:25 arch kernel: [<ffffffff8104b1d0>] ? do_page_fault+0x120/0x410
> Nov 10 14:35:25 arch kernel: [<ffffffff810bbf7f>] ? mmap_region+0x1df/0x4b0
> Nov 10 14:35:25 arch kernel: [<ffffffff81448295>] ? schedule+0x285/0x850
> Nov 10 14:35:25 arch kernel: [<ffffffff8144af8f>] ? page_fault+0x1f/0x30
> Nov 10 14:35:25 arch kernel: Disabling lock debugging due to kernel taint

I found this in my dmesg:
ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea0003ffffff] PMD -> [ffff8800d0000000-ffff8800d39fffff] on node 0

Full dmesg:

Linux version 2.6.37-rc1-00168-gb369291-dirty (markus@arch.trippelsdorf.de) (gcc version 4.5.1 (GCC) ) #72 SMP PREEMPT Tue Nov 9 15:55:23 CET 2010
Command line: BOOT_IMAGE=/usr/src/linux/arch/x86/boot/bzImage root=/dev/sdb2 fbcon=rotate:3 drm_kms_helper.poll=0 quiet
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000dfe90000 (usable)
 BIOS-e820: 00000000dfe90000 - 00000000dfea8000 (ACPI data)
 BIOS-e820: 00000000dfea8000 - 00000000dfed0000 (ACPI NVS)
 BIOS-e820: 00000000dfed0000 - 00000000dff00000 (reserved)
 BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000120000000 (usable)
NX (Execute Disable) protection: active
DMI present.
DMI: M4A78T-E/System Product Name, BIOS 3303    04/19/2010
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
last_pfn = 0x120000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-EFFFF uncachable
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000000 mask FFFF80000000 write-back
  1 base 000080000000 mask FFFFC0000000 write-back
  2 base 0000C0000000 mask FFFFE0000000 write-back
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
TOM2: 0000000120000000 aka 4608M
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
e820 update range: 00000000e0000000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xdfe90 max_arch_pfn = 0x400000000
initial memory mapped : 0 - 20000000
Using GB pages for direct mapping
init_memory_mapping: 0000000000000000-00000000dfe90000
 0000000000 - 00c0000000 page 1G
 00c0000000 - 00dfe00000 page 2M
 00dfe00000 - 00dfe90000 page 4k
kernel direct mapping tables up to dfe90000 @ 1fffd000-20000000
init_memory_mapping: 0000000100000000-0000000120000000
 0100000000 - 0120000000 page 2M
kernel direct mapping tables up to 120000000 @ dfe8e000-dfe90000
ACPI: RSDP 00000000000fb880 00024 (v02 ACPIAM)
ACPI: XSDT 00000000dfe90100 0005C (v01 041910 XSDT2028 20100419 MSFT 00000097)
ACPI: FACP 00000000dfe90290 000F4 (v03 041910 FACP2028 20100419 MSFT 00000097)
ACPI Warning: Optional field Pm2ControlBlock has zero address or length: 0x0000000000000000/0x1 (20101013/tbfadt-557)
ACPI: DSDT 00000000dfe90450 0E6FE (v01  A1152 A1152000 00000000 INTL 20060113)
ACPI: FACS 00000000dfea8000 00040
ACPI: APIC 00000000dfe90390 0007C (v01 041910 APIC2028 20100419 MSFT 00000097)
ACPI: MCFG 00000000dfe90410 0003C (v01 041910 OEMMCFG  20100419 MSFT 00000097)
ACPI: OEMB 00000000dfea8040 00072 (v01 041910 OEMB2028 20100419 MSFT 00000097)
ACPI: SRAT 00000000dfe9f450 000E8 (v03 AMD    FAM_F_10 00000002 AMD  00000001)
ACPI: HPET 00000000dfe9f540 00038 (v01 041910 OEMHPET  20100419 MSFT 00000097)
ACPI: SSDT 00000000dfe9f580 0088C (v01 A M I  POWERNOW 00000001 AMD  00000001)
ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea0003ffffff] PMD -> [ffff8800d0000000-ffff8800d39fffff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00120000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x000dfe90
    0: 0x00100000 -> 0x00120000
On node 0 totalpages: 1048095
  DMA zone: 56 pages used for memmap
  DMA zone: 2 pages reserved
  DMA zone: 3925 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 898760 pages, LIFO batch:31
  Normal zone: 1792 pages used for memmap
  Normal zone: 129280 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x84] disabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x85] disabled)
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 33, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8300 base: 0xfed00000 min tick: 20
SMP: Allowing 4 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 40
Allocating PCI resources starting at dff00000 (gap: dff00000:20000000)
setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 23 pages/cpu @ffff8800dfc00000 s73536 r0 d20672 u524288
pcpu-alloc: s73536 r0 d20672 u524288 alloc=1*2097152
pcpu-alloc: [0] 0 1 2 3 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1031965
Kernel command line: BOOT_IMAGE=/usr/src/linux/arch/x86/boot/bzImage root=/dev/sdb2 fbcon=rotate:3 drm_kms_helper.poll=0 quiet
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Memory: 4053480k/4718592k available (4399k kernel code, 526212k absent, 138900k reserved, 1730k data, 420k init)
SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Preemptable hierarchical RCU implementation.
	RCU-based detection of stalled CPUs is disabled.
	Verbose stalled-CPUs detection is disabled.
NR_IRQS:384
Extended CMOS year: 2000
spurious 8259A interrupt: IRQ7.
Console: colour VGA+ 80x25
console [tty0] enabled
hpet clockevent registered
Fast TSC calibration using PIT
Detected 3211.079 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 6422.15 BogoMIPS (lpj=3211079)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 256
tseg: 0000000000
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
using C1E aware idle routine
Performance Events: AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
Freeing SMP alternatives: 16k freed
ACPI: Core revision 20101013
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Phenom(tm) II X4 955 Processor stepping 02
System has AMD C1E enabled
Switch to broadcast mode on CPU0
MCE: In-kernel MCE decoding enabled.
Booting Node   0, Processors  #1
Switch to broadcast mode on CPU1
 #2
Switch to broadcast mode on CPU2
 #3 Ok.
Brought up 4 CPUs
Total of 4 processors activated (25687.02 BogoMIPS).
Switch to broadcast mode on CPU3
NET: Registered protocol family 16
node 0 link 0: io port [1000, ffffff]
TOM: 00000000e0000000 aka 3584M
Fam 10h mmconf [e0000000, efffffff]
node 0 link 0: mmio [a0000, bffff]
node 0 link 0: mmio [e0000000, efffffff] ==> none
node 0 link 0: mmio [f0000000, fbcfffff]
node 0 link 0: mmio [fbd00000, fbefffff]
node 0 link 0: mmio [fbf00000, ffefffff]
TOM2: 0000000120000000 aka 4608M
bus: [00, 07] on node 0 link 0
bus: 00 index 0 [io  0x0000-0xffff]
bus: 00 index 1 [mem 0x000a0000-0x000bffff]
bus: 00 index 2 [mem 0xf0000000-0xffffffff]
bus: 00 index 3 [mem 0x120000000-0xfcffffffff]
ACPI: bus type pci registered
PCI: Using configuration type 1 for base access
PCI: Using configuration type 1 for extended access
mtrr: your CPUs had inconsistent fixed MTRR settings
mtrr: probably your BIOS does not setup all CPUs.
mtrr: corrected configuration.
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Executed 3 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7]
pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff]
pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff]
pci_root PNP0A03:00: host bridge window [mem 0x000d0000-0x000dffff]
pci_root PNP0A03:00: host bridge window [mem 0xdff00000-0xdfffffff]
pci_root PNP0A03:00: host bridge window [mem 0xf0000000-0xfebfffff]
pci 0000:00:00.0: [1022:9600] type 0 class 0x000600
pci 0000:00:01.0: [1022:9602] type 1 class 0x000604
pci 0000:00:11.0: [1002:4390] type 0 class 0x000101
pci 0000:00:11.0: reg 10: [io  0xc000-0xc007]
pci 0000:00:11.0: reg 14: [io  0xb000-0xb003]
pci 0000:00:11.0: reg 18: [io  0xa000-0xa007]
pci 0000:00:11.0: reg 1c: [io  0x9000-0x9003]
pci 0000:00:11.0: reg 20: [io  0x8000-0x800f]
pci 0000:00:11.0: reg 24: [mem 0xfbcffc00-0xfbcfffff]
pci 0000:00:11.0: set SATA to AHCI mode
pci 0000:00:12.0: [1002:4397] type 0 class 0x000c03
pci 0000:00:12.0: reg 10: [mem 0xfbcfd000-0xfbcfdfff]
pci 0000:00:12.1: [1002:4398] type 0 class 0x000c03
pci 0000:00:12.1: reg 10: [mem 0xfbcfe000-0xfbcfefff]
pci 0000:00:12.2: [1002:4396] type 0 class 0x000c03
pci 0000:00:12.2: reg 10: [mem 0xfbcff800-0xfbcff8ff]
pci 0000:00:12.2: supports D1 D2
pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
pci 0000:00:12.2: PME# disabled
pci 0000:00:13.0: [1002:4397] type 0 class 0x000c03
pci 0000:00:13.0: reg 10: [mem 0xfbcfb000-0xfbcfbfff]
pci 0000:00:13.1: [1002:4398] type 0 class 0x000c03
pci 0000:00:13.1: reg 10: [mem 0xfbcfc000-0xfbcfcfff]
pci 0000:00:13.2: [1002:4396] type 0 class 0x000c03
pci 0000:00:13.2: reg 10: [mem 0xfbcff400-0xfbcff4ff]
pci 0000:00:13.2: supports D1 D2
pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
pci 0000:00:13.2: PME# disabled
pci 0000:00:14.0: [1002:4385] type 0 class 0x000c05
pci 0000:00:14.1: [1002:439c] type 0 class 0x000101
pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
pci 0000:00:14.1: reg 20: [io  0xff00-0xff0f]
pci 0000:00:14.3: [1002:439d] type 0 class 0x000601
pci 0000:00:14.4: [1002:4384] type 1 class 0x000604
pci 0000:00:14.5: [1002:4399] type 0 class 0x000c03
pci 0000:00:14.5: reg 10: [mem 0xfbcfa000-0xfbcfafff]
pci 0000:00:18.0: [1022:1200] type 0 class 0x000600
pci 0000:00:18.1: [1022:1201] type 0 class 0x000600
pci 0000:00:18.2: [1022:1202] type 0 class 0x000600
pci 0000:00:18.3: [1022:1203] type 0 class 0x000600
pci 0000:00:18.4: [1022:1204] type 0 class 0x000600
pci 0000:01:05.0: [1002:9614] type 0 class 0x000300
pci 0000:01:05.0: reg 10: [mem 0xf0000000-0xf7ffffff pref]
pci 0000:01:05.0: reg 14: [io  0xd000-0xd0ff]
pci 0000:01:05.0: reg 18: [mem 0xfbee0000-0xfbeeffff]
pci 0000:01:05.0: reg 24: [mem 0xfbd00000-0xfbdfffff]
pci 0000:01:05.0: supports D1 D2
pci 0000:01:05.1: [1002:960f] type 0 class 0x000403
pci 0000:01:05.1: reg 10: [mem 0xfbefc000-0xfbefffff]
pci 0000:01:05.1: supports D1 D2
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
pci 0000:02:05.0: [10ec:8169] type 0 class 0x000200
pci 0000:02:05.0: reg 10: [io  0xe800-0xe8ff]
pci 0000:02:05.0: reg 14: [mem 0xfbfffc00-0xfbfffcff]
pci 0000:02:05.0: reg 30: [mem 0xfbfc0000-0xfbfdffff pref]
pci 0000:02:05.0: supports D1 D2
pci 0000:02:05.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:02:05.0: PME# disabled
pci 0000:00:14.4: PCI bridge to [bus 02-02] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0xe000-0xefff]
pci 0000:00:14.4:   bridge window [mem 0xfbf00000-0xfbffffff]
pci 0000:00:14.4:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xdff00000-0xdfffffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xf0000000-0xfebfffff] (subtractive decode)
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PC._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs *4 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 4 *7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 4 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 4 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 4 7 10 11 12 14 15) *0, disabled.
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
Advanced Linux Sound Architecture Driver Version 1.0.23.
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
reserve RAM buffer: 00000000dfe90000 - 00000000dfffffff 
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 32-bit 14.318180 MHz counter
Switching to clocksource hpet
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: [bus 00-ff]
pnp 00:00: [io  0x0cf8-0x0cff]
pnp 00:00: [io  0x0000-0x0cf7 window]
pnp 00:00: [io  0x0d00-0xffff window]
pnp 00:00: [mem 0x000a0000-0x000bffff window]
pnp 00:00: [mem 0x000d0000-0x000dffff window]
pnp 00:00: [mem 0xdff00000-0xdfffffff window]
pnp 00:00: [mem 0xf0000000-0xfebfffff window]
pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
pnp 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:02: [dma 4]
pnp 00:02: [io  0x0000-0x000f]
pnp 00:02: [io  0x0081-0x0083]
pnp 00:02: [io  0x0087]
pnp 00:02: [io  0x0089-0x008b]
pnp 00:02: [io  0x008f]
pnp 00:02: [io  0x00c0-0x00df]
pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:03: [io  0x0070-0x0071]
pnp 00:03: [irq 8]
pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:04: [io  0x0061]
pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:05: [io  0x00f0-0x00ff]
pnp 00:05: [irq 13]
pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:06: [mem 0xfed00000-0xfed003ff]
pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:07: [io  0x0060]
pnp 00:07: [io  0x0064]
pnp 00:07: [mem 0xfec00000-0xfec00fff]
pnp 00:07: [mem 0xfee00000-0xfee00fff]
pnp 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:08: [io  0x0010-0x001f]
pnp 00:08: [io  0x0022-0x003f]
pnp 00:08: [io  0x0062-0x0063]
pnp 00:08: [io  0x0065-0x006f]
pnp 00:08: [io  0x0072-0x007f]
pnp 00:08: [io  0x0080]
pnp 00:08: [io  0x0084-0x0086]
pnp 00:08: [io  0x0088]
pnp 00:08: [io  0x008c-0x008e]
pnp 00:08: [io  0x0090-0x009f]
pnp 00:08: [io  0x00a2-0x00bf]
pnp 00:08: [io  0x00b1]
pnp 00:08: [io  0x00e0-0x00ef]
pnp 00:08: [io  0x04d0-0x04d1]
pnp 00:08: [io  0x040b]
pnp 00:08: [io  0x04d6]
pnp 00:08: [io  0x0c00-0x0c01]
pnp 00:08: [io  0x0c14]
pnp 00:08: [io  0x0c50-0x0c51]
pnp 00:08: [io  0x0c52]
pnp 00:08: [io  0x0c6c]
pnp 00:08: [io  0x0c6f]
pnp 00:08: [io  0x0cd0-0x0cd1]
pnp 00:08: [io  0x0cd2-0x0cd3]
pnp 00:08: [io  0x0cd4-0x0cd5]
pnp 00:08: [io  0x0cd6-0x0cd7]
pnp 00:08: [io  0x0cd8-0x0cdf]
pnp 00:08: [io  0x0b00-0x0b3f]
pnp 00:08: [io  0x0800-0x089f]
pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:08: [io  0x0b00-0x0b0f]
pnp 00:08: [io  0x0b20-0x0b3f]
pnp 00:08: [io  0x0900-0x090f]
pnp 00:08: [io  0x0910-0x091f]
pnp 00:08: [io  0xfe00-0xfefe]
pnp 00:08: [io  0x0060]
pnp 00:08: [io  0x0064]
pnp 00:08: [mem 0xdff00000-0xdfffffff]
pnp 00:08: [mem 0xffb80000-0xffbfffff]
pnp 00:08: [mem 0xfec10000-0xfec1001f]
pnp 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:09: [io  0x0230-0x023f]
pnp 00:09: [io  0x0290-0x029f]
pnp 00:09: [io  0x0f40-0x0f4f]
pnp 00:09: [io  0x0a30-0x0a3f]
pnp 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0a: [mem 0xe0000000-0xefffffff]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0b: [mem 0x00000000-0x0009ffff]
pnp 00:0b: [mem 0x000c0000-0x000cffff]
pnp 00:0b: [mem 0x000e0000-0x000fffff]
pnp 00:0b: [mem 0x00100000-0xdfefffff]
pnp 00:0b: [mem 0xfec00000-0xffffffff]
pnp 00:0b: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
system 00:07: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:07: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:08: [io  0x04d0-0x04d1] has been reserved
system 00:08: [io  0x040b] has been reserved
system 00:08: [io  0x04d6] has been reserved
system 00:08: [io  0x0c00-0x0c01] has been reserved
system 00:08: [io  0x0c14] has been reserved
system 00:08: [io  0x0c50-0x0c51] has been reserved
system 00:08: [io  0x0c52] has been reserved
system 00:08: [io  0x0c6c] has been reserved
system 00:08: [io  0x0c6f] has been reserved
system 00:08: [io  0x0cd0-0x0cd1] has been reserved
system 00:08: [io  0x0cd2-0x0cd3] has been reserved
system 00:08: [io  0x0cd4-0x0cd5] has been reserved
system 00:08: [io  0x0cd6-0x0cd7] has been reserved
system 00:08: [io  0x0cd8-0x0cdf] has been reserved
system 00:08: [io  0x0b00-0x0b3f] has been reserved
system 00:08: [io  0x0800-0x089f] has been reserved
system 00:08: [io  0x0b00-0x0b0f] has been reserved
system 00:08: [io  0x0b20-0x0b3f] has been reserved
system 00:08: [io  0x0900-0x090f] has been reserved
system 00:08: [io  0x0910-0x091f] has been reserved
system 00:08: [io  0xfe00-0xfefe] has been reserved
system 00:08: [mem 0xdff00000-0xdfffffff] has been reserved
system 00:08: [mem 0xffb80000-0xffbfffff] has been reserved
system 00:08: [mem 0xfec10000-0xfec1001f] has been reserved
system 00:09: [io  0x0230-0x023f] has been reserved
system 00:09: [io  0x0290-0x029f] has been reserved
system 00:09: [io  0x0f40-0x0f4f] has been reserved
system 00:09: [io  0x0a30-0x0a3f] has been reserved
system 00:0a: [mem 0xe0000000-0xefffffff] has been reserved
system 00:0b: [mem 0x00000000-0x0009ffff] could not be reserved
system 00:0b: [mem 0x000c0000-0x000cffff] has been reserved
system 00:0b: [mem 0x000e0000-0x000fffff] could not be reserved
system 00:0b: [mem 0x00100000-0xdfefffff] could not be reserved
system 00:0b: [mem 0xfec00000-0xffffffff] could not be reserved
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
pci 0000:00:14.4: PCI bridge to [bus 02-02]
pci 0000:00:14.4:   bridge window [io  0xe000-0xefff]
pci 0000:00:14.4:   bridge window [mem 0xfbf00000-0xfbffffff]
pci 0000:00:14.4:   bridge window [mem pref disabled]
pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: resource 8 [mem 0xdff00000-0xdfffffff]
pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfebfffff]
pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
pci_bus 0000:01: resource 1 [mem 0xfbd00000-0xfbefffff]
pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff 64bit pref]
pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
pci_bus 0000:02: resource 1 [mem 0xfbf00000-0xfbffffff]
pci_bus 0000:02: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:02: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:02: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:02: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:02: resource 8 [mem 0xdff00000-0xdfffffff]
pci_bus 0000:02: resource 9 [mem 0xf0000000-0xfebfffff]
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
UDP hash table entries: 2048 (order: 4, 65536 bytes)
UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
NET: Registered protocol family 1
pci 0000:00:01.0: MSI quirk detected; subordinate MSI disabled
pci 0000:01:05.0: Boot video device
PCI: CLS 64 bytes, default 64
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff8800db48b000 - ffff8800df48b000
software IO TLB at phys 0xdb48b000 - 0xdf48b000
kvm: Nested Virtualization enabled
kvm: Nested Paging enabled
msgmni has been set to 7916
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler cfq registered (default)
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: acpi_idle registered with cpuidle
ACPI: processor limited to max C-state 1
Real Time Clock Driver v1.12b
Linux agpgart interface v0.103
[drm] Initialized drm 1.1.0 20060810
[drm] radeon defaulting to kernel modesetting.
[drm] radeon kernel modesetting enabled.
radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
radeon 0000:01:05.0: setting latency timer to 64
[drm] initializing kernel modesetting (RS780 0x1002:0x9614).
[drm] register mmio base: 0xFBEE0000
[drm] register mmio size: 65536
ATOM BIOS: 113
radeon 0000:01:05.0: VRAM: 128M 0xC0000000 - 0xC7FFFFFF (128M used)
radeon 0000:01:05.0: GTT: 512M 0xA0000000 - 0xBFFFFFFF
[drm] Detected VRAM RAM=128M, BAR=128M
[drm] RAM width 32bits DDR
[TTM] Zone  kernel: Available graphics memory: 2026748 kiB.
[TTM] Initializing pool allocator.
[drm] radeon: 128M of VRAM memory ready
[drm] radeon: 512M of GTT memory ready.
[drm] radeon: irq initialized.
[drm] GART: num cpu pages 131072, num gpu pages 131072
[drm] Loading RS780 Microcode
radeon 0000:01:05.0: WB enabled
[drm] ring test succeeded in 1 usecs
[drm] radeon: ib pool ready.
[drm] ib test succeeded in 0 usecs
[drm] Enabling audio support
[drm] Radeon Display Connectors
[drm] Connector 0:
[drm]   VGA
[drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
[drm]   Encoders:
[drm]     CRT1: INTERNAL_KLDSCP_DAC1
[drm] Connector 1:
[drm]   DVI-D
[drm]   HPD3
[drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
[drm]   Encoders:
[drm]     DFP3: INTERNAL_KLDSCP_LVTMA
[drm] radeon: power management initialized
[drm] fb mappable at 0xF0141000
[drm] vram apper at 0xF0000000
[drm] size 7258112
[drm] fb depth is 24
[drm]    pitch is 6912
Console: switching to colour frame buffer device 131x105
fb0: radeondrmfb frame buffer device
drm: registered panic notifier
[drm] Initialized radeon 2.7.0 20080528 for 0000:01:05.0 on minor 0
loop: module loaded
ahci 0000:00:11.0: version 3.0
ahci 0000:00:11.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
ahci 0000:00:11.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
ata1: SATA max UDMA/133 irq_stat 0x00400000, PHY RDY changed
ata2: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd80 irq 22
ata3: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe00 irq 22
ata4: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe80 irq 22
pata_atiixp 0000:00:14.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pata_atiixp 0000:00:14.1: setting latency timer to 64
scsi4 : pata_atiixp
scsi5 : pata_atiixp
ata5: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xff00 irq 14
ata6: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xff08 irq 15
PPP generic driver version 2.4.2
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:05.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
r8169 0000:02:05.0: (unregistered net_device): no PCI Express capability
r8169 0000:02:05.0: eth0: RTL8110s at 0xffffc90000436c00, 00:08:54:36:f2:2f, XID 04000000 IRQ 20
usbmon: debugfs is not available
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:12.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ehci_hcd 0000:00:12.2: EHCI Host Controller
ehci_hcd 0000:00:12.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:12.2: applying AMD SB600/SB700 USB freeze workaround
ehci_hcd 0000:00:12.2: debug port 1
ehci_hcd 0000:00:12.2: irq 17, io mem 0xfbcff800
ehci_hcd 0000:00:12.2: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci_hcd 0000:00:13.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ehci_hcd 0000:00:13.2: EHCI Host Controller
ehci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:13.2: applying AMD SB600/SB700 USB freeze workaround
ehci_hcd 0000:00:13.2: debug port 1
ehci_hcd 0000:00:13.2: irq 19, io mem 0xfbcff400
ehci_hcd 0000:00:13.2: USB 2.0 started, EHCI 1.00
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:12.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:12.0: OHCI Host Controller
ohci_hcd 0000:00:12.0: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:12.0: irq 16, io mem 0xfbcfd000
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 3 ports detected
ohci_hcd 0000:00:12.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:12.1: OHCI Host Controller
ohci_hcd 0000:00:12.1: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:12.1: irq 16, io mem 0xfbcfe000
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.0: irq 18, io mem 0xfbcfb000
ata5.00: ATAPI: HL-DT-STDVD-RAM GH22NP20, 1.03, max UDMA/66
ata5.00: configured for UDMA/66
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 6
ohci_hcd 0000:00:13.1: irq 18, io mem 0xfbcfc000
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 3 ports detected
ohci_hcd 0000:00:14.5: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:14.5: OHCI Host Controller
ohci_hcd 0000:00:14.5: new USB bus registered, assigned bus number 7
ohci_hcd 0000:00:14.5: irq 18, io mem 0xfbcfa000
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
usbcore: registered new interface driver usbserial
USB Serial support registered for generic
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata3.00: ATA-8: OCZ-VERTEX, 1.6, max UDMA/133
ata3.00: 62533296 sectors, multi 1: LBA48 NCQ (depth 31/32), AA
ata3.00: configured for UDMA/133
Refined TSC clocksource calibration: 3210.828 MHz.
Switching to clocksource tsc
usb 4-1: new full speed USB device using ohci_hcd and address 2
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-7: SAMSUNG HD103UJ, 1AA01118, max UDMA7
ata1.00: 1953525168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD103UJ  1AA0 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 2:0:0:0: Direct-Access     ATA      OCZ-VERTEX       1.6  PQ: 0 ANSI: 5
sd 2:0:0:0: [sdb] 62533296 512-byte logical blocks: (32.0 GB/29.8 GiB)
sd 2:0:0:0: Attached scsi generic sg1 type 0
sd 2:0:0:0: [sdb] Write Protect is off
sd 2:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
scsi 4:0:0:0: CD-ROM            HL-DT-ST DVD-RAM GH22NP20 1.03 PQ: 0 ANSI: 5
 sdb: sdb1 sdb2
sd 2:0:0:0: [sdb] Attached SCSI disk
sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
cdrom: Uniform CD-ROM driver Revision: 3.20
sr 4:0:0:0: Attached scsi CD-ROM sr0
sr 4:0:0:0: Attached scsi generic sg2 type 5
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
usb 4-2: new full speed USB device using ohci_hcd and address 3
usb 4-3: new low speed USB device using ohci_hcd and address 4
usbcore: registered new interface driver usbserial_generic
usbserial: USB Serial Driver core
USB Serial support registered for GSM modem (1-port)
usbcore: registered new interface driver option
option: v0.7.2:USB Driver for GSM modems
PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
i2c /dev entries driver
cpuidle: using governor ladder
cpuidle: using governor menu
input: C-Media USB Headphone Set   as /devices/pci0000:00/0000:00:12.1/usb4/4-1/4-1:1.3/input/input2
generic-usb 0003:0D8C:000C.0001: input,hidraw0: USB HID v1.00 Device [C-Media USB Headphone Set  ] on usb-0000:00:12.1-1/input3
input: Logitech USB Receiver as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.0/input/input3
generic-usb 0003:046D:C52B.0002: input,hidraw1: USB HID v1.11 Keyboard [Logitech USB Receiver] on usb-0000:00:12.1-2/input0
input: Logitech USB Receiver as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.1/input/input4
generic-usb 0003:046D:C52B.0003: input,hiddev0,hidraw2: USB HID v1.11 Mouse [Logitech USB Receiver] on usb-0000:00:12.1-2/input1
generic-usb 0003:046D:C52B.0004: hiddev0,hidraw3: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:12.1-2/input2
input: HID 046a:0011 as /devices/pci0000:00/0000:00:12.1/usb4/4-3/4-3:1.0/input/input5
generic-usb 0003:046A:0011.0005: input,hidraw4: USB HID v1.10 Keyboard [HID 046a:0011] on usb-0000:00:12.1-3/input0
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
usbcore: registered new interface driver snd-usb-audio
ALSA device list:
  #0: C-Media USB Headphone Set   at usb-0000:00:12.1-1, full speed
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
ctnetlink v0.93: registering with nfnetlink.
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
NET: Registered protocol family 17
powernow-k8: Found 1 AMD Phenom(tm) II X4 955 Processor (4 cpu cores) (version 2.20.00)
powernow-k8:    0 : pstate 0 (3200 MHz)
powernow-k8:    1 : pstate 1 (2500 MHz)
powernow-k8:    2 : pstate 2 (2100 MHz)
powernow-k8:    3 : pstate 3 (800 MHz)
EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
VFS: Mounted root (ext4 filesystem) readonly on device 8:18.
Freeing unused kernel memory: 420k freed
udev[836]: starting version 163
EXT4-fs (sdb2): re-mounted. Opts: (null)
EXT4-fs (sdb2): re-mounted. Opts: (null)
EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
Adding 200808k swap on /dev/sda3.  Priority:-1 extents:1 across:200808k 
r8169 0000:02:05.0: eth0: link up
-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
