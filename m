Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 020146B009E
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 15:04:04 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so468439wib.6
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 12:04:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r4si13113449wiv.24.2014.06.09.12.04.02
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 12:04:03 -0700 (PDT)
Date: Mon, 9 Jun 2014 15:03:53 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
Message-ID: <20140609150353.75eff02b@redhat.com>
In-Reply-To: <CAE9FiQXpUbAOinEK-1PSFyGKqpC_FHN0sjP0xvD0ChrXR5GdAw@mail.gmail.com>
References: <20140608181436.17de69ac@redhat.com>
	<CAE9FiQXpUbAOinEK-1PSFyGKqpC_FHN0sjP0xvD0ChrXR5GdAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Sun, 8 Jun 2014 18:29:11 -0700
Yinghai Lu <yinghai@kernel.org> wrote:

> On Sun, Jun 8, 2014 at 3:14 PM, Luiz Capitulino <lcapitulino@redhat.com> wrote:
> > In short, I believe this is just dead code for the upstream kernel but this
> > causes a bug for 2.6.32 based kernels.
> >
> > The setup_node_data() function is used to initialize NODE_DATA() for a node.
> > It gets a node id and a memory range. The start address for the memory range
> > is rounded up to ZONE_ALIGN and then it's used to initialize
> > NODE_DATA(nid)->node_start_pfn.
> > The 2.6.32 kernel did use the rounded up range start to register a node's
> > memory range with the bootmem interface by calling init_bootmem_node().
> > A few steps later during bootmem initialization, the 2.6.32 kernel calls
> > free_bootmem_with_active_regions() to initialize the bootmem bitmap. This
> > function goes through all memory ranges read from the SRAT table and try
> > to mark them as usable for bootmem usage. However, before marking a range
> > as usable, mark_bootmem_node() asserts if the memory range start address
> > (as read from the SRAT table) is less than the value registered with
> > init_bootmem_node(). The assertion will trigger whenever the memory range
> > start address is rounded up, as it will always be greater than what is
> > reported in the SRAT table. This is true when the 2.6.32 kernel runs as a
> > HyperV guest on Windows Server 2012. Dropping ZONE_ALIGN solves the
> > problem there.
> 
> What is e820 memmap and srat from HyperV guest?

I think the dmesg below provides this? Let me know otherwise.

> Can you post bootlog first 200 lines?

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.15.0-rc6+ (root@amd-6168-8-1.englab.nay.redhat.com) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-3) (GCC) ) #113 SMP Thu May 29 16:28:41 CST 2014
[    0.000000] Command line: ro root=/dev/mapper/vg_dhcp66106105-lv_root rd_NO_LUKS  KEYBOARDTYPE=pc KEYTABLE=us LANG=en_US.UTF-8 rd_NO_MD rd_LVM_LV=vg_dhcp66106105/lv_swap SYSFONT=latarcyrheb-sun16 crashkernel=auto rd_LVM_LV=vg_dhcp66106105/lv_root rd_NO_DM rhgb quiet KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM console=ttyS0,115200
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000003ffeffff] usable
[    0.000000] BIOS-e820: [mem 0x000000003fff0000-0x000000003fffefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000003ffff000-0x000000003fffffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x0000000040200000-0x00000000801fffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.3 present.
[    0.000000] DMI: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[    0.000000] Hypervisor detected: Microsoft HyperV
[    0.000000] HyperV: features 0xe7f, hints 0x2c
[    0.000000] HyperV: LAPIC Timer Frequency: 0x30d40
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x80200 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-DFFFF uncachable
[    0.000000]   E0000-FFFFF write-back
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00000000000 mask 3FF00000000 write-back
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f] mapped at [ffff8800000ff780]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x020eb000, 0x020ebfff] PGTABLE
[    0.000000] BRK [0x020ec000, 0x020ecfff] PGTABLE
[    0.000000] BRK [0x020ed000, 0x020edfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x80000000-0x801fffff]
[    0.000000]  [mem 0x80000000-0x801fffff] page 2M
[    0.000000] BRK [0x020ee000, 0x020eefff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x7c000000-0x7fffffff]
[    0.000000]  [mem 0x7c000000-0x7fffffff] page 2M
[    0.000000] BRK [0x020ef000, 0x020effff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x3ffeffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fdfffff] page 2M
[    0.000000]  [mem 0x3fe00000-0x3ffeffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x40200000-0x7bffffff]
[    0.000000]  [mem 0x40200000-0x7bffffff] page 2M
[    0.000000] RAMDISK: [mem 0x37a8c000-0x37feffff]
[    0.000000] ACPI: RSDP 0x00000000000F56F0 000014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 0x000000003FFF0000 000040 (v01 VRTUAL MICROSFT 05001223 MSFT 00000097)
[    0.000000] ACPI: FACP 0x000000003FFF0200 000081 (v02 VRTUAL MICROSFT 05001223 MSFT 00000097)
[    0.000000] ACPI: DSDT 0x000000003FFF1724 002E78 (v01 MSFTVM MSFTVM02 00000002 INTL 02002026)
[    0.000000] ACPI: FACS 0x000000003FFFF000 000040
[    0.000000] ACPI: WAET 0x000000003FFF1480 000028 (v01 VRTUAL MICROSFT 05001223 MSFT 00000097)
[    0.000000] ACPI: SLIC 0x000000003FFF14C0 000176 (v01 VRTUAL MICROSFT 05001223 MSFT 00000097)
[    0.000000] ACPI: OEM0 0x000000003FFF16C0 000064 (v01 VRTUAL MICROSFT 05001223 MSFT 00000097)
[    0.000000] ACPI: SRAT 0x000000003FFF0600 0000C0 (v02 VRTUAL MICROSFT 00000001 MSFT 00000001)
[    0.000000] ACPI: APIC 0x000000003FFF0300 00024C (v01 VRTUAL MICROSFT 05001223 MSFT 00000097)
[    0.000000] ACPI: OEMB 0x000000003FFFF040 000064 (v01 VRTUAL MICROSFT 05001223 MSFT 00000097)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x02 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x03 -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x3fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x40200000-0x801fffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x3fffffff]
[    0.000000]   NODE_DATA [mem 0x3ffec000-0x3ffeffff]
[    0.000000] Initmem setup node 1 [mem 0x40800000-0x801fffff]
[    0.000000]   NODE_DATA [mem 0x801fb000-0x801fefff]
[    0.000000] crashkernel: memory value expected
[    0.000000]  [ffffea0000000000-ffffea0000ffffff] PMD -> [ffff88003ee00000-ffff88003fdfffff] on node 0
[    0.000000]  [ffffea0001000000-ffffea00021fffff] PMD -> [ffff88007e600000-ffff88007f7fffff] on node 1
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x3ffeffff]
[    0.000000]   node   1: [mem 0x40200000-0x801fffff]
[    0.000000] On node 0 totalpages: 262030
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 4032 pages used for memmap
[    0.000000]   DMA32 zone: 258032 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 262144
[    0.000000]   DMA32 zone: 4096 pages used for memmap
[    0.000000]   DMA32 zone: 262144 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x06] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x08] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x09] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0b] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0c] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0d] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0e] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x0f] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x10] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x11] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x12] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x13] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x14] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x15] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x16] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x17] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x18] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x19] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x1a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x1b] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x1c] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x1d] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x1e] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0x1f] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x21] lapic_id[0x20] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x22] lapic_id[0x21] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x23] lapic_id[0x22] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x24] lapic_id[0x23] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x25] lapic_id[0x24] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x26] lapic_id[0x25] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x27] lapic_id[0x26] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x28] lapic_id[0x27] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x29] lapic_id[0x28] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2a] lapic_id[0x29] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2b] lapic_id[0x2a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2c] lapic_id[0x2b] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2d] lapic_id[0x2c] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2e] lapic_id[0x2d] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2f] lapic_id[0x2e] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x30] lapic_id[0x2f] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x31] lapic_id[0x30] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x32] lapic_id[0x31] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x33] lapic_id[0x32] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x34] lapic_id[0x33] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x35] lapic_id[0x34] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x36] lapic_id[0x35] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x37] lapic_id[0x36] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x38] lapic_id[0x37] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x39] lapic_id[0x38] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3a] lapic_id[0x39] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3b] lapic_id[0x3a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3c] lapic_id[0x3b] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3d] lapic_id[0x3c] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3e] lapic_id[0x3d] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3f] lapic_id[0x3e] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x40] lapic_id[0x3f] disabled)
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] smpboot: Allowing 64 CPUs, 60 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x3fff0000-0x3fffefff]
[    0.000000] PM: Registered nosave memory: [mem 0x3ffff000-0x3fffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x40000000-0x401fffff]
[    0.000000] e820: [mem 0x80200000-0xffffffff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:64 nr_node_ids:2
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88003ea00000 s79616 r8192 d22784 u131072
[    0.000000] pcpu-alloc: s79616 r8192 d22784 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 01 04 06 08 10 12 14 16 18 20 22 24 26 28 30 
[    0.000000] pcpu-alloc: [0] 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 
[    0.000000] pcpu-alloc: [1] 02 03 05 07 09 11 13 15 17 19 21 23 25 27 29 31 
[    0.000000] pcpu-alloc: [1] 33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 515961
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: ro root=/dev/mapper/vg_dhcp66106105-lv_root rd_NO_LUKS  KEYBOARDTYPE=pc KEYTABLE=us LANG=en_US.UTF-8 rd_NO_MD rd_LVM_LV=vg_dhcp66106105/lv_swap SYSFONT=latarcyrheb-sun16 crashkernel=auto rd_LVM_LV=vg_dhcp66106105/lv_root rd_NO_DM rhgb quiet KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM console=ttyS0,115200
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
