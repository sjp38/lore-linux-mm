Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 61C386B0047
	for <linux-mm@kvack.org>; Sat,  3 Dec 2011 04:28:54 -0500 (EST)
Date: Sat, 3 Dec 2011 10:28:45 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111203092845.GA1520@x4.trippels.de>
References: <20111121080554.GB1625@x4.trippels.de>
 <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
 <20111123160353.GA1673@x4.trippels.de>
 <alpine.DEB.2.00.1111231004490.17317@router.home>
 <20111124085040.GA1677@x4.trippels.de>
 <20111202230412.GB12057@homer.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20111202230412.GB12057@homer.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, "Alex, Shi" <alex.shi@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, tj@kernel.org, Alex Deucher <alexander.deucher@amd.com>

On 2011.12.02 at 18:04 -0500, Jerome Glisse wrote:
> On Thu, Nov 24, 2011 at 09:50:40AM +0100, Markus Trippelsdorf wrote:
> > On 2011.11.23 at 10:06 -0600, Christoph Lameter wrote:
> > > On Wed, 23 Nov 2011, Markus Trippelsdorf wrote:
> > > 
> > > > > FIX idr_layer_cache: Marking all objects used
> > > >
> > > > Yesterday I couldn't reproduce the issue at all. But today I've hit
> > > > exactly the same spot again. (CCing the drm list)
> > > 
> > > Well this is looks like write after free.
> > > 
> > > > =============================================================================
> > > > BUG idr_layer_cache: Poison overwritten
> > > > -----------------------------------------------------------------------------
> > > > Object ffff8802156487c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > Object ffff8802156487d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > Object ffff8802156487e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > Object ffff8802156487f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > Object ffff880215648800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
> > > > Object ffff880215648810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > 
> > > And its an integer sized write of 0. If you look at the struct definition
> > > and lookup the offset you should be able to locate the field that
> > > was modified.
> > 
> I really don't think that drm or radeon is guilty. I tried to reproduce
> with rc3+ & rc4+ with slub or slab, did more then 20 kexec cycle with
> same kernel parameter and no issue.
> 
> To confirm that radeon or drm is not to blame can you trigger the issue
> by using nomodeset kernel option (your fb rotate option is then
> useless). If with nomodeset you can trigger the issue can you then try
> to trigger it with KMS enabled and with attached patch (real ugly printk
> debuging)
> 
> Note that i walked over the drm mode init code and i believe the root
> issue is that some code in the kernel do a double idr_remove/destroy
> which trigger the idr slub/slab error. It just happen that radeon/drm
> is call after the idr double free but is not the one guilty.
> 
> Note that i don't understand the idr code much, so my theory can be
> completely wrong but attached patch might help to shed some light.

Thanks for the debugging patch Jerome.
I couldn't trigger the issue with the >>nomodeset<< kernel option yet.
But I've triggered it with KMS enabled and your patch applied:

Linux version 3.2.0-rc4-00089-g621fc1e-dirty (markus@x4.trippels.de) (gcc version 4.7.0 20111201 (experimental) (GCC) ) #137 SMP PREEMPT Sat Dec 3 06:43:05 CET 2011
Command line: root=PARTUUID=6d6a4009-3a90-40df-806a-e63f48189719 init=/sbin/minit rootflags=logbsize=262144 fbcon=rotate:3 drm_kms_helper.poll=0 quiet
KERNEL supported cpus:
  AMD AuthenticAMD
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000100 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000dfe90000 (usable)
 BIOS-e820: 00000000dfe90000 - 00000000dfea8000 (ACPI data)
 BIOS-e820: 00000000dfea8000 - 00000000dfed0000 (ACPI NVS)
 BIOS-e820: 00000000dfed0000 - 00000000dff00000 (reserved)
 BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000220000000 (usable)
NX (Execute Disable) protection: active
DMI present.
DMI: System manufacturer System Product Name/M4A78T-E, BIOS 3406    08/20/2010
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
last_pfn = 0x220000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-EFFFF uncachable
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000000 mask FFFF80000000 write-back
  1 base 000080000000 mask FFFFC0000000 write-back
  2 base 0000C0000000 mask FFFFE0000000 write-back
  3 base 0000F0000000 mask FFFFF8000000 write-combining
  4 disabled
  5 disabled
  6 disabled
  7 disabled
TOM2: 0000000220000000 aka 8704M
x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
last_pfn = 0xdfe90 max_arch_pfn = 0x400000000
initial memory mapped : 0 - 20000000
Base memory trampoline at [ffff88000009d000] 9d000 size 8192
Using GB pages for direct mapping
init_memory_mapping: 0000000000000000-00000000dfe90000
 0000000000 - 00c0000000 page 1G
 00c0000000 - 00dfe00000 page 2M
 00dfe00000 - 00dfe90000 page 4k
kernel direct mapping tables up to dfe90000 @ 1fffd000-20000000
init_memory_mapping: 0000000100000000-0000000220000000
 0100000000 - 0200000000 page 1G
 0200000000 - 0220000000 page 2M
kernel direct mapping tables up to 220000000 @ dfe8e000-dfe90000
ACPI: RSDP 00000000000fb880 00024 (v02 ACPIAM)
ACPI: XSDT 00000000dfe90100 0005C (v01 082010 XSDT1403 20100820 MSFT 00000097)
ACPI: FACP 00000000dfe90290 000F4 (v03 082010 FACP1403 20100820 MSFT 00000097)
ACPI Warning: Optional field Pm2ControlBlock has zero address or length: 0x0000000000000000/0x1 (20110623/tbfadt-560)
ACPI: DSDT 00000000dfe90450 0E6FE (v01  A1152 A1152000 00000000 INTL 20060113)
ACPI: FACS 00000000dfea8000 00040
ACPI: APIC 00000000dfe90390 0007C (v01 082010 APIC1403 20100820 MSFT 00000097)
ACPI: MCFG 00000000dfe90410 0003C (v01 082010 OEMMCFG  20100820 MSFT 00000097)
ACPI: OEMB 00000000dfea8040 00072 (v01 082010 OEMB1403 20100820 MSFT 00000097)
ACPI: SRAT 00000000dfe9f450 000E8 (v01 AMD    FAM_F_10 00000002 AMD  00000001)
ACPI: HPET 00000000dfe9f540 00038 (v01 082010 OEMHPET  20100820 MSFT 00000097)
ACPI: SSDT 00000000dfe9f580 0088C (v01 A M I  POWERNOW 00000001 AMD  00000001)
ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea00077fffff] PMD -> [ffff880217600000-ffff88021e7fffff] on node 0
Zone PFN ranges:
  DMA32    0x00000010 -> 0x00100000
  Normal   0x00100000 -> 0x00220000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x000dfe90
    0: 0x00100000 -> 0x00220000
On node 0 totalpages: 2096671
  DMA32 zone: 14336 pages used for memmap
  DMA32 zone: 2 pages reserved
  DMA32 zone: 902685 pages, LIFO batch:31
  Normal zone: 16128 pages used for memmap
  Normal zone: 1163520 pages, LIFO batch:31
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
ACPI: HPET id: 0x8300 base: 0xfed00000
SMP: Allowing 4 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 40
Allocating PCI resources starting at dff00000 (gap: dff00000:20000000)
setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 23 pages/cpu @ffff88021fc00000 s71808 r0 d22400 u524288
pcpu-alloc: s71808 r0 d22400 u524288 alloc=1*2097152
pcpu-alloc: [0] 0 1 2 3 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2066205
Kernel command line: root=PARTUUID=6d6a4009-3a90-40df-806a-e63f48189719 init=/sbin/minit rootflags=logbsize=262144 fbcon=rotate:3 drm_kms_helper.poll=0 quiet
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Memory: 8181488k/8912896k available (4670k kernel code, 526212k absent, 205196k reserved, 3879k data, 424k init)
Preemptible hierarchical RCU implementation.
	Verbose stalled-CPUs detection is disabled.
NR_IRQS:4352 nr_irqs:712 16
Extended CMOS year: 2000
Console: colour VGA+ 80x25
console [tty0] enabled
hpet clockevent registered
Fast TSC calibration using PIT
Detected 3211.038 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 6422.07 BogoMIPS (lpj=3211038)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 256
ida_get_new_above free idr ffff88021e81e700
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e8334c8
ida_get_new_above free idr ffff88021e833058
ida_get_new_above free idr ffff88021e834da8
ida_get_new_above free idr ffff88021e834da8
ida_get_new_above free idr ffff88021e834da8
ida_get_new_above free idr ffff88021e834da8
ida_get_new_above free idr ffff88021e834da8
ida_get_new_above free idr ffff88021e836700
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
ida_get_new_above free idr ffff88021e836290
tseg: 0000000000
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 6 MCE banks
using AMD E400 aware idle routine
Freeing SMP alternatives: 12k freed
ACPI: Core revision 20110623
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Phenom(tm) II X4 955 Processor stepping 02
Performance Events: AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
System has AMD C1E enabled
Switch to broadcast mode on CPU0
ida_get_new_above free idr ffff88021e897b70
ida_get_new_above free idr ffff88021e8a2290
MCE: In-kernel MCE decoding enabled.
ida_get_new_above free idr ffff88021e8a7938
ida_get_new_above free idr ffff88021e897da8
Booting Node   0, Processors  #1
smpboot cpu 1: start_ip = 9d000
Switch to broadcast mode on CPU1
ida_get_new_above free idr ffff88021e8b0290
 #2
smpboot cpu 2: start_ip = 9d000
Switch to broadcast mode on CPU2
ida_get_new_above free idr ffff88021e8b9938
 #3 Ok.
smpboot cpu 3: start_ip = 9d000
Brought up 4 CPUs
Total of 4 processors activated (25687.09 BogoMIPS).
Switch to broadcast mode on CPU3
ida_get_new_above free idr ffff88021e8b9938
ida_get_new_above free idr ffff88021e8b9938
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
devtmpfs: initialized
ida_get_new_above free idr ffff88021e833700
ida_get_new_above free idr ffff88021e833938
ida_get_new_above free idr ffff88021e833b70
ida_get_new_above free idr ffff88021e833da8
ida_get_new_above free idr ffff88021e830058
ida_get_new_above free idr ffff88021e830290
ida_get_new_above free idr ffff88021e8304c8
ida_get_new_above free idr ffff88021e830700
ida_get_new_above free idr ffff88021e830938
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e830da8
ida_get_new_above free idr ffff88021e8a24c8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
NET: Registered protocol family 16
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
node 0 link 0: io port [1000, ffffff]
TOM: 00000000e0000000 aka 3584M
Fam 10h mmconf [e0000000, efffffff]
node 0 link 0: mmio [a0000, bffff]
node 0 link 0: mmio [e0000000, efffffff] ==> none
node 0 link 0: mmio [f0000000, fbcfffff]
node 0 link 0: mmio [fbd00000, fbefffff]
node 0 link 0: mmio [fbf00000, ffefffff]
TOM2: 0000000220000000 aka 8704M
bus: [00, 07] on node 0 link 0
bus: 00 index 0 [io  0x0000-0xffff]
bus: 00 index 1 [mem 0x000a0000-0x000bffff]
bus: 00 index 2 [mem 0xf0000000-0xffffffff]
bus: 00 index 3 [mem 0x220000000-0xfcffffffff]
Extended Config Space enabled on 1 nodes
ida_get_new_above free idr ffff88021e944da8
ACPI: bus type pci registered
PCI: Using configuration type 1 for base access
PCI: Using configuration type 1 for extended access
bio: create slab <bio-0> at 0
ida_get_new_above free idr ffff88021e944da8
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ida_get_new_above free idr ffff88021e944da8
ACPI: EC: Look up EC in DSDT
ACPI: Executed 3 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ida_get_new_above free idr ffff88021e944da8
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
pci 0000:00:06.0: [1022:9606] type 1 class 0x000604
pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
pci 0000:00:06.0: PME# disabled
pci 0000:00:11.0: [1002:4391] type 0 class 0x000106
pci 0000:00:11.0: reg 10: [io  0xc000-0xc007]
pci 0000:00:11.0: reg 14: [io  0xb000-0xb003]
pci 0000:00:11.0: reg 18: [io  0xa000-0xa007]
pci 0000:00:11.0: reg 1c: [io  0x9000-0x9003]
pci 0000:00:11.0: reg 20: [io  0x8000-0x800f]
pci 0000:00:11.0: reg 24: [mem 0xfbcffc00-0xfbcfffff]
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
pci 0000:02:00.0: [1969:1026] type 0 class 0x000200
pci 0000:02:00.0: reg 10: [mem 0xfbfc0000-0xfbffffff 64bit]
pci 0000:02:00.0: reg 18: [io  0xec00-0xec7f]
pci 0000:02:00.0: PME# supported from D3hot D3cold
pci 0000:02:00.0: PME# disabled
pci 0000:00:06.0: PCI bridge to [bus 02-02]
pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
pci 0000:00:14.4: PCI bridge to [bus 03-03] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xdff00000-0xdfffffff] (subtractive decode)
pci 0000:00:14.4:   bridge window [mem 0xf0000000-0xfebfffff] (subtractive decode)
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE6._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0PC._PRT]
 pci0000:00: Unable to request _OSC control (_OSC support mask: 0x19)
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea87700
ida_get_new_above free idr ffff88021ea87938
ida_get_new_above free idr ffff88021ea87b70
ida_get_new_above free idr ffff88021ea87da8
ida_get_new_above free idr ffff88021e944058
ida_get_new_above free idr ffff88021e944290
ida_get_new_above free idr ffff88021e9444c8
ida_get_new_above free idr ffff88021e944700
ida_get_new_above free idr ffff88021e944938
ida_get_new_above free idr ffff88021e944b70
ida_get_new_above free idr ffff88021e944da8
ACPI: PCI Interrupt Link [LNKA] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKB] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 4 7 10 11 12 14 15) *0, disabled.
ida_get_new_above free idr ffff88021e944da8
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
Advanced Linux Sound Architecture Driver Version 1.0.24.
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
reserve RAM buffer: 00000000dfe90000 - 00000000dfffffff 
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 32-bit 14.318180 MHz counter
Switching to clocksource hpet
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
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
system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
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
system 00:07: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:07: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
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
system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: [io  0x0000-0xffffffffffffffff disabled]
pnp 00:09: [io  0x0230-0x023f]
pnp 00:09: [io  0x0290-0x029f]
pnp 00:09: [io  0x0f40-0x0f4f]
pnp 00:09: [io  0x0a30-0x0a3f]
system 00:09: [io  0x0230-0x023f] has been reserved
system 00:09: [io  0x0290-0x029f] has been reserved
system 00:09: [io  0x0f40-0x0f4f] has been reserved
system 00:09: [io  0x0a30-0x0a3f] has been reserved
system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0a: [mem 0xe0000000-0xefffffff]
system 00:0a: [mem 0xe0000000-0xefffffff] has been reserved
system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0b: [mem 0x00000000-0x0009ffff]
pnp 00:0b: [mem 0x000c0000-0x000cffff]
pnp 00:0b: [mem 0x000e0000-0x000fffff]
pnp 00:0b: [mem 0x00100000-0xdfefffff]
pnp 00:0b: [mem 0xfec00000-0xffffffff]
system 00:0b: [mem 0x00000000-0x0009ffff] could not be reserved
system 00:0b: [mem 0x000c0000-0x000cffff] could not be reserved
system 00:0b: [mem 0x000e0000-0x000fffff] could not be reserved
system 00:0b: [mem 0x00100000-0xdfefffff] could not be reserved
system 00:0b: [mem 0xfec00000-0xffffffff] could not be reserved
system 00:0b: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea87700
ida_get_new_above free idr ffff88021ea87938
ida_get_new_above free idr ffff88021ea87b70
ida_get_new_above free idr ffff88021ea87da8
ida_get_new_above free idr ffff88021e944058
ida_get_new_above free idr ffff88021e944290
ida_get_new_above free idr ffff88021e9444c8
ida_get_new_above free idr ffff88021e944700
ida_get_new_above free idr ffff88021e944938
ida_get_new_above free idr ffff88021e944b70
ida_get_new_above free idr ffff88021e944da8
PCI: max bus depth: 1 pci_try_num: 2
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
pci 0000:00:06.0: PCI bridge to [bus 02-02]
pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
pci 0000:00:14.4: PCI bridge to [bus 03-03]
pci 0000:00:06.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
pci 0000:00:06.0: setting latency timer to 64
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
pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000dffff]
pci_bus 0000:03: resource 8 [mem 0xdff00000-0xdfffffff]
pci_bus 0000:03: resource 9 [mem 0xf0000000-0xfebfffff]
NET: Registered protocol family 2
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
UDP hash table entries: 4096 (order: 5, 131072 bytes)
UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
ida_get_new_above free idr ffff88021e944da8
NET: Registered protocol family 1
ida_get_new_above free idr ffff88021e944da8
pci 0000:00:01.0: MSI quirk detected; subordinate MSI disabled
pci 0000:01:05.0: Boot video device
PCI: CLS 64 bytes, default 64
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff8800dbe8e000 - ffff8800dfe8e000
software IO TLB at phys 0xdbe8e000 - 0xdfe8e000
kvm: Nested Virtualization enabled
kvm: Nested Paging enabled
ida_get_new_above free idr ffff88021e8b04c8
perf: AMD IBS detected (0x0000001f)
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
SGI XFS with security attributes, large block/inode numbers, no debug enabled
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
msgmni has been set to 15979
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021ea874c8
input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: processor limited to max C-state 1
ida_get_new_above free idr ffff88021e8b9058
ida_get_new_above free idr ffff88021e8b9058
[drm] Initialized drm 1.1.0 20060810
[drm] radeon defaulting to kernel modesetting.
[drm] radeon kernel modesetting enabled.
radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
radeon 0000:01:05.0: setting latency timer to 64
drm_get_pci_dev 348
drm_get_pci_dev 354
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
[drm] initializing kernel modesetting (RS780 0x1002:0x9614 0x1043:0x834D).
[drm] register mmio base: 0xFBEE0000
[drm] register mmio size: 65536
ATOM BIOS: 113
radeon 0000:01:05.0: VRAM: 128M 0x00000000C0000000 - 0x00000000C7FFFFFF (128M used)
radeon 0000:01:05.0: GTT: 512M 0x00000000A0000000 - 0x00000000BFFFFFFF
[drm] Detected VRAM RAM=128M, BAR=128M
[drm] RAM width 32bits DDR
[TTM] Zone  kernel: Available graphics memory: 4090750 kiB.
[TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[TTM] Initializing pool allocator.
[drm] radeon: 128M of VRAM memory ready
[drm] radeon: 512M of GTT memory ready.
[drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[drm] Driver supports precise vblank timestamp query.
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
ida_get_new_above free idr ffff880216f7b058
[drm] radeon: irq initialized.
[drm] GART: num cpu pages 131072, num gpu pages 131072
[drm] Loading RS780 Microcode
[drm] PCIE GART of 512M enabled (table at 0x00000000C0040000).
radeon 0000:01:05.0: WB enabled
[drm] ring test succeeded in 0 usecs
[drm] radeon: ib pool ready.
[drm] ib test succeeded in 0 usecs
[drm] allocating idr ffff88021eba1a70 -1330597712 idr 1
[drm] allocating idr ffff8802167b5998 -1330597712 idr 2
[drm] allocating idr ffff8802167b5900 -1330597712 idr 3
[drm] allocating idr ffff8802167b5868 -1330597712 idr 4
[drm] allocating idr ffff8802167b57d0 -1330597712 idr 5
[drm] allocating idr ffff8802167b5738 -1330597712 idr 6
[drm] allocating idr ffff8802167b56a0 -1330597712 idr 7
[drm] allocating idr ffff8802167b5608 -1330597712 idr 8
[drm] allocating idr ffff8802167b5570 -1330597712 idr 9
[drm] allocating idr ffff88021eb98018 -858993460 idr 10
[drm] allocating idr ffff8802167c4018 -858993460 idr 11
[drm] allocating idr ffff88021eb9f778 -522133280 idr 12
[drm] allocating idr ffff8802167e6dd8 -1061109568 idr 13
[drm] allocating idr ffff88021eb9f560 -522133280 idr 14
[drm] allocating idr ffff8802167e65c0 -1061109568 idr 15
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
[drm] allocating idr ffff8802167b9818 -1145324613 idr 16
[drm] allocating idr ffff88021e8b4198 -555819298 idr 17
[drm] allocating idr ffff88021e8b4080 -555819298 idr 18
[drm] allocating idr ffff8802167c7eb8 -555819298 idr 19
[drm] allocating idr ffff8802167c7da0 -555819298 idr 20
[drm] allocating idr ffff8802167c7c88 -555819298 idr 21
[drm] allocating idr ffff8802167c7b70 -555819298 idr 22
[drm] allocating idr ffff8802167c7a58 -555819298 idr 23
[drm] allocating idr ffff8802167c7940 -555819298 idr 24
[drm] allocating idr ffff8802167c7828 -555819298 idr 25
[drm] allocating idr ffff8802167c7710 -555819298 idr 26
[drm] allocating idr ffff8802167c75f8 -555819298 idr 27
[drm] allocating idr ffff8802167c74e0 -555819298 idr 28
[drm] allocating idr ffff8802167c73c8 -555819298 idr 29
[drm] allocating idr ffff8802167c72b0 -555819298 idr 30
[drm] allocating idr ffff8802167c7198 -555819298 idr 31
[drm] remove idr ffff8802167c7da0 0 idr 20
idr_remove free idr ffff8802167b44c8
[drm] allocating idr ffff8802167c7da0 -555819298 idr 20
[drm] allocating idr ffff88021eb9f1e8 -67372037 idr 32
[drm] fb mappable at 0xF0142000
[drm] vram apper at 0xF0000000
[drm] size 7299072
[drm] fb depth is 24
[drm]    pitch is 6912
fbcon: radeondrmfb (fb0) is primary device
[drm] allocating idr ffff8802167c7080 -555819298 idr 33
[drm] remove idr ffff8802167c7080 -555819298 idr 33
idr_remove free idr ffff8802167b44c8
Console: switching to colour frame buffer device 131x105
fb0: radeondrmfb frame buffer device
drm: registered panic notifier
[drm] Initialized radeon 2.12.0 20080528 for 0000:01:05.0 on minor 0
loop: module loaded
ida_get_new_above free idr ffff8802167b44c8
ahci 0000:00:11.0: version 3.0
ahci 0000:00:11.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
ahci 0000:00:11.0: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167dada8
ida_get_new_above free idr ffff8802167d9058
ida_get_new_above free idr ffff8802167d9290
ida_get_new_above free idr ffff8802167d94c8
ida_get_new_above free idr ffff8802167d9700
ida_get_new_above free idr ffff8802167d9938
ida_get_new_above free idr ffff8802167d9b70
ida_get_new_above free idr ffff8802167d9da8
ida_get_new_above free idr ffff8802167b8058
ida_get_new_above free idr ffff8802167b8290
ida_get_new_above free idr ffff8802167b84c8
ida_get_new_above free idr ffff8802167b44c8
------------[ cut here ]------------
WARNING: at mm/slab.c:1931 check_poison_obj+0xcc/0x220()
Hardware name: System Product Name
Slab corruption: files_cache start=ffff88021eb8e600, len=704
Pid: 5, comm: kworker/u:0 Not tainted 3.2.0-rc4-00089-g621fc1e-dirty #137
Call Trace:
 [<ffffffff81060f0a>] warn_slowpath_common+0x6a/0xa0
 [<ffffffff81060fa1>] warn_slowpath_fmt+0x41/0x60
 [<ffffffff810db30c>] check_poison_obj+0xcc/0x220
 [<ffffffff810fefee>] ? dup_fd+0x2e/0x300
 [<ffffffff810db4e5>] cache_alloc_debugcheck_after.isra.59+0x85/0x1c0
 [<ffffffff810fefee>] ? dup_fd+0x2e/0x300
 [<ffffffff810db904>] kmem_cache_alloc+0x64/0xc0
 [<ffffffff810fefee>] dup_fd+0x2e/0x300
 [<ffffffff8105fb91>] copy_process+0x991/0x10c0
 [<ffffffff810603ef>] do_fork+0xef/0x240
 [<ffffffff810828a5>] ? sched_clock_local+0x25/0xa0
 [<ffffffff8103aeac>] kernel_thread+0x6c/0x80
 [<ffffffff81075640>] ? proc_cap_handler+0x180/0x180
 [<ffffffff8148ee70>] ? gs_change+0xb/0xb
 [<ffffffff810757c8>] __call_usermodehelper+0x28/0x80
 [<ffffffff81076456>] process_one_work+0x116/0x3c0
 [<ffffffff810757a0>] ? call_usermodehelper_freeinfo+0x40/0x40
 [<ffffffff810774fe>] worker_thread+0x13e/0x2e0
 [<ffffffff810773c0>] ? flush_workqueue_prep_cwqs+0x200/0x200
 [<ffffffff8107c467>] kthread+0x87/0xa0
 [<ffffffff8148ee74>] kernel_thread_helper+0x4/0x10
 [<ffffffff8107c3e0>] ? kthread_flush_work_fn+0x20/0x20
 [<ffffffff8148ee70>] ? gs_change+0xb/0xb
---[ end trace b6eea21c7bdaf786 ]---
Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Last user: [<ffffffff810fedb8>](free_fdtable_rcu+0xd8/0x120)
200: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
Prev obj: start=ffff88021eb8e328, len=704
Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
Last user: [<ffffffff810fefee>](dup_fd+0x2e/0x300)
000: 00 00 00 00 5a 5a 5a 5a 38 e3 b8 1e 02 88 ff ff  ....ZZZZ8.......
010: 40 00 00 00 5a 5a 5a 5a c0 e3 b8 1e 02 88 ff ff  @...ZZZZ........
Next obj: start=ffff88021eb8e8d8, len=704
Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Last user: [<ffffffff810fedb8>](free_fdtable_rcu+0xd8/0x120)
000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd00 irq 22
ata2: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd80 irq 22
ata3: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe00 irq 22
ata4: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe80 irq 22
ata5: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff00 irq 22
ata6: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff80 irq 22
ida_get_new_above free idr ffff88021e8a2700
ida_get_new_above free idr ffff88021e8a2938
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2da8
ida_get_new_above free idr ffff88021e897058
ida_get_new_above free idr ffff88021e897290
pata_atiixp 0000:00:14.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
scsi6 : pata_atiixp
scsi7 : pata_atiixp
ata7: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xff00 irq 14
ata8: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xff08 irq 15
ida_get_new_above free idr ffff88021e8974c8
ida_get_new_above free idr ffff88021e897700
ATL1E 0000:02:00.0: BAR 0: set to [mem 0xfbfc0000-0xfbffffff 64bit] (PCI address [0xfbfc0000-0xfbffffff])
ATL1E 0000:02:00.0: BAR 2: set to [io  0xec00-0xec7f] (PCI address [0xec00-0xec7f])
ATL1E 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ATL1E 0000:02:00.0: setting latency timer to 64
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:12.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ehci_hcd 0000:00:12.2: EHCI Host Controller
ehci_hcd 0000:00:12.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
QUIRK: Enable AMD PLL fix
ehci_hcd 0000:00:12.2: applying AMD SB600/SB700 USB freeze workaround
ehci_hcd 0000:00:12.2: debug port 1
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ehci_hcd 0000:00:12.2: irq 17, io mem 0xfbcff800
ehci_hcd 0000:00:12.2: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci_hcd 0000:00:13.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ehci_hcd 0000:00:13.2: EHCI Host Controller
ehci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
ehci_hcd 0000:00:13.2: applying AMD SB600/SB700 USB freeze workaround
ehci_hcd 0000:00:13.2: debug port 1
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ehci_hcd 0000:00:13.2: irq 19, io mem 0xfbcff400
ehci_hcd 0000:00:13.2: USB 2.0 started, EHCI 1.00
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:12.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:12.0: OHCI Host Controller
ohci_hcd 0000:00:12.0: new USB bus registered, assigned bus number 3
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ida_get_new_above free idr ffff88021e8a2b70
ohci_hcd 0000:00:12.0: irq 16, io mem 0xfbcfd000
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 3 ports detected
ida_get_new_above free idr ffff880216004290
ida_get_new_above free idr ffff8802160044c8
ida_get_new_above free idr ffff880216004700
ida_get_new_above free idr ffff880216004938
ida_get_new_above free idr ffff880216004b70
ida_get_new_above free idr ffff880216004da8
ida_get_new_above free idr ffff88021ea87058
ida_get_new_above free idr ffff88021ea87290
ida_get_new_above free idr ffff88021ea874c8
ida_get_new_above free idr ffff88021e8a2700
ida_get_new_above free idr ffff88021e8a2938
ida_get_new_above free idr ffff88021e8a2b70
ohci_hcd 0000:00:12.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:12.1: OHCI Host Controller
ohci_hcd 0000:00:12.1: new USB bus registered, assigned bus number 4
ida_get_new_above free idr ffff88021e8a2b70
ohci_hcd 0000:00:12.1: irq 16, io mem 0xfbcfe000
ida_get_new_above free idr ffff88021e8b9b70
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 5
ida_get_new_above free idr ffff88021e8b9b70
ohci_hcd 0000:00:13.0: irq 18, io mem 0xfbcfb000
ata7.00: ATAPI: HL-DT-STDVD-RAM GH22NP20, 1.03, max UDMA/66
ida_get_new_above free idr ffff88021e8a7b70
ata7.00: configured for UDMA/66
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 3 ports detected
ohci_hcd 0000:00:13.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 6
ida_get_new_above free idr ffff88021e8b9b70
ohci_hcd 0000:00:13.1: irq 18, io mem 0xfbcfc000
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 3 ports detected
ohci_hcd 0000:00:14.5: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:14.5: OHCI Host Controller
ohci_hcd 0000:00:14.5: new USB bus registered, assigned bus number 7
ida_get_new_above free idr ffff88021e8b9b70
ohci_hcd 0000:00:14.5: irq 18, io mem 0xfbcfa000
ata2: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata3.00: ATA-8: OCZ-VERTEX, 1.6, max UDMA/133
ata3.00: 62533296 sectors, multi 1: LBA48 NCQ (depth 31/32), AA
ata3.00: configured for UDMA/133
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
usbcore: registered new interface driver usblp
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
ida_get_new_above free idr ffff88021e8b9b70
usbcore: registered new interface driver usbserial
USB Serial support registered for generic
ata1.00: ATA-8: ST1500DL003-9VT16L, CC32, max UDMA/133
ata1.00: 2930277168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
ida_get_new_above free idr ffff88021e9354c8
scsi 0:0:0:0: Direct-Access     ATA      ST1500DL003-9VT1 CC32 PQ: 0 ANSI: 5
ida_get_new_above free idr ffff8802160044c8
ida_get_new_above free idr ffff88021e897b70
sd 0:0:0:0: [sda] 2930277168 512-byte logical blocks: (1.50 TB/1.36 TiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: Attached scsi generic sg0 type 0
ida_get_new_above free idr ffff88021e9354c8
scsi 2:0:0:0: Direct-Access     ATA      OCZ-VERTEX       1.6  PQ: 0 ANSI: 5
ida_get_new_above free idr ffff880216004058
sd 2:0:0:0: [sdb] 62533296 512-byte logical blocks: (32.0 GB/29.8 GiB)
sd 2:0:0:0: [sdb] Write Protect is off
sd 2:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 2:0:0:0: Attached scsi generic sg1 type 0
sd 2:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
ida_get_new_above free idr ffff88021e935058
scsi 6:0:0:0: CD-ROM            HL-DT-ST DVD-RAM GH22NP20 1.03 PQ: 0 ANSI: 5
 sdb: sdb1 sdb2
 sda: unknown partition table
sd 0:0:0:0: [sda] Attached SCSI disk
sd 2:0:0:0: [sdb] Attached SCSI disk
sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
cdrom: Uniform CD-ROM driver Revision: 3.20
sr 6:0:0:0: Attached scsi CD-ROM sr0
ida_get_new_above free idr ffff88021e8b9da8
sr 6:0:0:0: Attached scsi generic sg2 type 5
Refined TSC clocksource calibration: 3210.827 MHz.
Switching to clocksource tsc
usb 4-1: new full-speed USB device number 2 using ohci_hcd
usb 4-2: new full-speed USB device number 3 using ohci_hcd
ida_get_new_above free idr ffff8802161c34c8
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3938
ida_get_new_above free idr ffff8802161c3b70
ida_get_new_above free idr ffff8802161c3da8
ida_get_new_above free idr ffff880216117058
ida_get_new_above free idr ffff880216117290
ida_get_new_above free idr ffff8802161174c8
ida_get_new_above free idr ffff880216117700
ida_get_new_above free idr ffff880216117938
ida_get_new_above free idr ffff880216117b70
ida_get_new_above free idr ffff88021e8b9da8
usb 4-3: new low-speed USB device number 4 using ohci_hcd
usbcore: registered new interface driver usbserial_generic
usbserial: USB Serial Driver core
USB Serial support registered for GSM modem (1-port)
usbcore: registered new interface driver option
option: v0.7.2:USB Driver for GSM modems
i8042: PNP: No PS/2 controller found. Probing ports directly.
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff88021e8b9da8
ida_get_new_above free idr ffff88021e8b9da8
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mousedev: PS/2 mouse device common for all mice
rtc_cmos 00:03: RTC can wake from S4
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff880216131da8
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
ida_get_new_above free idr ffff880216131da8
rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
i2c /dev entries driver
ida_get_new_above free idr ffff88021626c700
ida_get_new_above free idr ffff88021626c290
EDAC MC: Ver: 2.1.0
AMD64 EDAC driver v3.4.0
EDAC amd64: DRAM ECC enabled.
EDAC amd64: F10h detected (node 0).
EDAC MC: DCT0 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC MC: DCT1 chip selects:
EDAC amd64: MC: 0:  1024MB 1:  1024MB
EDAC amd64: MC: 2:  1024MB 3:  1024MB
EDAC amd64: MC: 4:     0MB 5:     0MB
EDAC amd64: MC: 6:     0MB 7:     0MB
EDAC amd64: using x4 syndromes.
EDAC amd64: MCT channel count: 2
EDAC amd64: CS0: Unbuffered DDR3 RAM
EDAC amd64: CS1: Unbuffered DDR3 RAM
EDAC amd64: CS2: Unbuffered DDR3 RAM
EDAC amd64: CS3: Unbuffered DDR3 RAM
EDAC MC0: Giving out device to 'amd64_edac' 'F10h': DEV 0000:00:18.2
EDAC PCI0: Giving out device to module 'amd64_edac' controller 'EDAC PCI controller': DEV '0000:00:18.2' (POLLED)
cpuidle: using governor ladder
cpuidle: using governor menu
input: C-Media USB Headphone Set   as /devices/pci0000:00/0000:00:12.1/usb4/4-1/4-1:1.3/input/input2
generic-usb 0003:0D8C:000C.0001: input,hidraw0: USB HID v1.00 Device [C-Media USB Headphone Set  ] on usb-0000:00:12.1-1/input3
logitech-djreceiver 0003:046D:C52B.0004: hiddev0,hidraw1: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:12.1-2/input2
input: Logitech Unifying Device. Wireless PID:101b as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.2/0003:046D:C52B.0004/input/input3
logitech-djdevice 0003:046D:C52B.0006: input,hidraw2: USB HID v1.11 Mouse [Logitech Unifying Device. Wireless PID:101b] on usb-0000:00:12.1-2:1
input: HID 046a:0011 as /devices/pci0000:00/0000:00:12.1/usb4/4-3/4-3:1.0/input/input4
generic-usb 0003:046A:0011.0005: input,hidraw3: USB HID v1.10 Keyboard [HID 046a:0011] on usb-0000:00:12.1-3/input0
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
usbcore: registered new interface driver snd-usb-audio
ALSA device list:
  #0: C-Media USB Headphone Set at usb-0000:00:12.1-1, full speed
Netfilter messages via NETLINK v0.30.
ida_get_new_above free idr ffff8802161c3700
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ctnetlink v0.93: registering with nfnetlink.
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
NET: Registered protocol family 17
ida_get_new_above free idr ffff8802161c3700
registered taskstats version 1
rtc_cmos 00:03: setting system clock to 2011-12-03 05:53:40 UTC (1322891620)
powernow-k8: Found 1 AMD Phenom(tm) II X4 955 Processor (4 cpu cores) (version 2.20.00)
powernow-k8:    0 : pstate 0 (3200 MHz)
powernow-k8:    1 : pstate 1 (2500 MHz)
powernow-k8:    2 : pstate 2 (2100 MHz)
powernow-k8:    3 : pstate 3 (800 MHz)
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff88021e935058
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802167b44c8
XFS (sdb2): Mounting Filesystem
XFS (sdb2): Ending clean mount
VFS: Mounted root (xfs filesystem) readonly on device 8:18.
ida_get_new_above free idr ffff8802161c3700
devtmpfs: mounted
Freeing unused kernel memory: 424k freed
Write protecting the kernel read-only data: 8192k
Freeing unused kernel memory: 1464k freed
Freeing unused kernel memory: 392k freed
ida_get_new_above free idr ffff8802167b44c8
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
ida_get_new_above free idr ffff8802161c3700
XFS (sda): Mounting Filesystem
XFS (sda): Ending clean mount
ATL1E 0000:02:00.0: irq 40 for MSI/MSI-X
ida_get_new_above free idr ffff88021626c290
ida_get_new_above free idr ffff88021626c290
ida_get_new_above free idr ffff88021626c290
ida_get_new_above free idr ffff88021626c290
ida_get_new_above free idr ffff88021626c290
ida_get_new_above free idr ffff88021626c290
ida_get_new_above free idr ffff88021626c290
ATL1E 0000:02:00.0: eth0: NIC Link is Up <100 Mbps Full Duplex>
ATL1E 0000:02:00.0: eth0: NIC Link is Up <100 Mbps Full Duplex>
udevd[797]: starting version 171
ida_get_new_above free idr ffff88021e896058
ida_get_new_above free idr ffff88021e8b0700
Adding 2097148k swap on /var/tmp/swap/swapfile.  Priority:-1 extents:2 across:2634672k 
ida_get_new_above free idr ffff88021e8b8058
ida_get_new_above free idr ffff88021e896290
ida_get_new_above free idr ffff88021e8b8290
ida_get_new_above free idr ffff88021e8b84c8
ida_get_new_above free idr ffff88021e8b8700
ida_get_new_above free idr ffff88021e8b8938
ida_get_new_above free idr ffff88021e8b8b70
ida_get_new_above free idr ffff88021e8b8da8
ida_get_new_above free idr ffff88021e8b0290
ida_get_new_above free idr ffff88021e8a7da8
ida_get_new_above free idr ffff88021e8a6058
ida_get_new_above free idr ffff88021e8a6290

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
