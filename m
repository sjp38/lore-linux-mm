Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id F07D96B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:19:21 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y13so5178801pdi.28
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 12:19:21 -0700 (PDT)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id rj9si8560377pbc.375.2014.04.28.12.19.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 12:19:12 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 05:19:09 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E33132BB0052
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:19:05 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3SIw5Nm852310
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 04:58:06 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3SJJ4u6007340
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:19:04 +1000
Message-ID: <535EA976.1080402@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 00:48:14 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [BUG] kernel BUG at mm/vmacache.c:85!
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: davidlohr@hp.com, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hi,

I hit this during boot on v3.15-rc3, just once so far.
Subsequent reboots went fine, and a few quick runs of multi-
threaded ebizzy also didn't recreate the problem.

The kernel I was running was v3.15-rc3 + some totally
unrelated cpufreq patches.

The BUG_ON triggered from the following code:

 74 struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
 75 {
 76         int i;
 77 
 78         if (!vmacache_valid(mm))
 79                 return NULL;
 80 
 81         for (i = 0; i < VMACACHE_SIZE; i++) {
 82                 struct vm_area_struct *vma = current->vmacache[i];
 83 
 84                 if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
 85                         BUG_ON(vma->vm_mm != mm);
 86                         return vma;
 87                 }
 88         }
 89 
 90         return NULL;
 91 }

Here is the boot log:

Starting new kernel
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Initializing cgroup subsys cpuacct
Linux version 3.15.0-rc3-freq-dblfix (root@llm233.in.ibm.com) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-3) (GCC) ) #1 SMP Mon Apr 28 13:39:54 EDT 2014
Command line: ro root=UUID=0b808847-f479-46cd-b962-98544ff30c61 rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb console=tty0 console=ttyS1,115200 ignore_loglevel debug no_console_suspend selinux=0 softdog.soft_margin=30000
e820: BIOS-provided physical RAM map:
BIOS-e820: [mem 0x0000000000000100-0x000000000009bfff] usable
BIOS-e820: [mem 0x000000000009c000-0x000000000009ffff] reserved
BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
BIOS-e820: [mem 0x0000000000100000-0x0000000067d34fff] usable
BIOS-e820: [mem 0x0000000067d35000-0x0000000067d35fff] ACPI data
BIOS-e820: [mem 0x0000000067d36000-0x0000000069d29fff] usable
BIOS-e820: [mem 0x0000000069d2a000-0x0000000069dedfff] reserved
BIOS-e820: [mem 0x0000000069dee000-0x000000006a599fff] usable
BIOS-e820: [mem 0x000000006a59a000-0x000000006a5a2fff] ACPI data
BIOS-e820: [mem 0x000000006a5a3000-0x000000006a5bdfff] usable
BIOS-e820: [mem 0x000000006a5be000-0x000000006a5cbfff] ACPI data
BIOS-e820: [mem 0x000000006a5cc000-0x000000006a5e3fff] usable
BIOS-e820: [mem 0x000000006a5e4000-0x000000006a5ebfff] ACPI data
BIOS-e820: [mem 0x000000006a5ec000-0x000000006a5effff] usable
BIOS-e820: [mem 0x000000006a5f0000-0x000000006a5f2fff] ACPI data
BIOS-e820: [mem 0x000000006a5f3000-0x000000006ac25fff] usable
BIOS-e820: [mem 0x000000006ac26000-0x000000006ac26fff] ACPI data
BIOS-e820: [mem 0x000000006ac27000-0x000000006b393fff] usable
BIOS-e820: [mem 0x000000006b394000-0x000000006b394fff] ACPI data
BIOS-e820: [mem 0x000000006b395000-0x000000007e596fff] usable
BIOS-e820: [mem 0x000000007e597000-0x000000007e6a1fff] reserved
BIOS-e820: [mem 0x000000007e6a2000-0x000000007ebc5fff] ACPI NVS
BIOS-e820: [mem 0x000000007ebc6000-0x000000007ec01fff] usable
BIOS-e820: [mem 0x000000007f000000-0x000000007fbfffff] reserved
BIOS-e820: [mem 0x0000000080000000-0x000000008fffffff] reserved
BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
BIOS-e820: [mem 0x0000000100000000-0x000000207fffffff] usable
debug: ignoring loglevel setting.
NX (Execute Disable) protection: active
SMBIOS 2.7 present.
DMI: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
e820: remove [mem 0x000a0000-0x000fffff] usable
No AGP bridge found
e820: last_pfn = 0x2080000 max_arch_pfn = 0x400000000
MTRR default type: write-back
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-FFFFF uncachable
MTRR variable ranges enabled:
  0 base 0000FF800000 mask 3FFFFF800000 write-through
  1 base 000080000000 mask 3FFF80000000 uncachable
  2 base 3C0000000000 mask 3FF800000000 uncachable
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
  8 disabled
  9 disabled
x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
e820: last_pfn = 0x7ec02 max_arch_pfn = 0x400000000
found SMP MP-table at [mem 0x0009c140-0x0009c14f] mapped at [ffff88000009c140]
Base memory trampoline at [ffff880000095000] 95000 size 28672
Using GB pages for direct mapping
init_memory_mapping: [mem 0x00000000-0x000fffff]
 [mem 0x00000000-0x000fffff] page 4k
BRK [0x027c9000, 0x027c9fff] PGTABLE
BRK [0x027ca000, 0x027cafff] PGTABLE
BRK [0x027cb000, 0x027cbfff] PGTABLE
init_memory_mapping: [mem 0x207fe00000-0x207fffffff]
 [mem 0x207fe00000-0x207fffffff] page 1G
init_memory_mapping: [mem 0x207c000000-0x207fdfffff]
 [mem 0x207c000000-0x207fdfffff] page 1G
init_memory_mapping: [mem 0x2000000000-0x207bffffff]
 [mem 0x2000000000-0x207bffffff] page 1G
init_memory_mapping: [mem 0x1000000000-0x1fffffffff]
 [mem 0x1000000000-0x1fffffffff] page 1G
init_memory_mapping: [mem 0x00100000-0x67d34fff]
 [mem 0x00100000-0x001fffff] page 4k
 [mem 0x00200000-0x67bfffff] page 2M
 [mem 0x67c00000-0x67d34fff] page 4k
init_memory_mapping: [mem 0x67d36000-0x69d29fff]
 [mem 0x67d36000-0x67dfffff] page 4k
 [mem 0x67e00000-0x69bfffff] page 2M
 [mem 0x69c00000-0x69d29fff] page 4k
BRK [0x027cc000, 0x027ccfff] PGTABLE
init_memory_mapping: [mem 0x69dee000-0x6a599fff]
 [mem 0x69dee000-0x69dfffff] page 4k
 [mem 0x69e00000-0x6a3fffff] page 2M
 [mem 0x6a400000-0x6a599fff] page 4k
BRK [0x027cd000, 0x027cdfff] PGTABLE
init_memory_mapping: [mem 0x6a5a3000-0x6a5bdfff]
 [mem 0x6a5a3000-0x6a5bdfff] page 4k
init_memory_mapping: [mem 0x6a5cc000-0x6a5e3fff]
 [mem 0x6a5cc000-0x6a5e3fff] page 4k
init_memory_mapping: [mem 0x6a5ec000-0x6a5effff]
 [mem 0x6a5ec000-0x6a5effff] page 4k
init_memory_mapping: [mem 0x6a5f3000-0x6ac25fff]
 [mem 0x6a5f3000-0x6a5fffff] page 4k
 [mem 0x6a600000-0x6abfffff] page 2M
 [mem 0x6ac00000-0x6ac25fff] page 4k
BRK [0x027ce000, 0x027cefff] PGTABLE
init_memory_mapping: [mem 0x6ac27000-0x6b393fff]
 [mem 0x6ac27000-0x6adfffff] page 4k
 [mem 0x6ae00000-0x6b1fffff] page 2M
 [mem 0x6b200000-0x6b393fff] page 4k
init_memory_mapping: [mem 0x6b395000-0x7e596fff]
 [mem 0x6b395000-0x6b3fffff] page 4k
 [mem 0x6b400000-0x7e3fffff] page 2M
 [mem 0x7e400000-0x7e596fff] page 4k
init_memory_mapping: [mem 0x7ebc6000-0x7ec01fff]
 [mem 0x7ebc6000-0x7ec01fff] page 4k
init_memory_mapping: [mem 0x100000000-0xfffffffff]
 [mem 0x100000000-0xfffffffff] page 1G
RAMDISK: [mem 0x7e0f5000-0x7e596fff]
ACPI: RSDP 0x00000000000FDFD0 000024 (v02 IBM   )
ACPI: XSDT 0x000000006B3941C0 0000D4 (v01 IBM    BLADE    00000000      01000013)
ACPI: FACP 0x000000006A5F2000 0000F4 (v04 IBM    BLADE    00000000 MSFT 01000019)
ACPI: DSDT 0x000000006A5C7000 0040E3 (v01 INTEL  TIANO    00000003 MSFT 01000013)
ACPI: FACS 0x000000007E909000 000040
ACPI: TCPA 0x000000006AC26000 000064 (v00                 00000000      00000000)
ACPI: ERST 0x000000006A5F1000 000230 (v01 IBM    BLADE    00000001 MSFT 0100001B)
ACPI: HEST 0x000000006A5F0000 0000F4 (v01 IBM    BLADE    00000001 MSFT 0100001E)
ACPI: HPET 0x000000006A5EB000 000038 (v01 IBM    BLADE    00000001 MSFT 01000017)
ACPI: APIC 0x000000006A5E8000 00016A (v03 IBM    BLADE    00000000 MSFT 01000014)
ACPI: MCFG 0x000000006A5EA000 00003C (v01 IBM    BLADE    00000001 MSFT 01000018)
ACPI: OEM0 0x000000006A5E9000 0002E8 (v03 IBM    XSECSRAT 00000100 MSFT 01000022)
ACPI: OEM1 0x000000006A5E7000 000030 (v01 IBM    IBMERROR 00000001 MSFT 01000013)
ACPI: SLIT 0x000000006A5E6000 000030 (v01 IBM    BLADE    00000001 MSFT 01000020)
ACPI: SRAT 0x000000006A5E5000 0002A8 (v03 IBM    BLADE    00000001 MSFT 0100001A)
ACPI: SLIC 0x000000006A5E4000 000176 (v01 IBM    BLADE    00000000 MSFT 0100001F)
ACPI: SSDT 0x000000006A5C6000 00069F (v02 IBM    CPUSCOPE 00004000 MSFT 01000016)
ACPI: SSDT 0x000000006A5C5000 0006C6 (v02 IBM    CPUWYVRN 00004000 MSFT 01000016)
ACPI: SSDT 0x000000006A59A000 0085E4 (v02 IBM    PSTATEPM 00004000 MSFT 01000016)
ACPI: SSDT 0x000000006A5C0000 00135A (v02 IBM    CPUCSTAT 00004000 MSFT 01000016)
ACPI: SSDT 0x000000006A5C3000 000214 (v02 IBM    WYVRNDEV 00004000 MSFT 01000016)
ACPI: SSDT 0x000000006A5C4000 00009E (v02 IBM    WYVRNGPE 00004000 MSFT 01000016)
ACPI: SSDT 0x000000006A5C2000 00090F (v02 IBM    CPUNOTFY 00004000 MSFT 01000016)
ACPI: SSDT 0x000000006A5BF000 000035 (v01 IBM    S3NAMEOB 00001000 MSFT 01000016)
ACPI: SSDT 0x000000006A5BE000 0000C3 (v01 IBM    SLEEPBTN 00001000 MSFT 01000016)
ACPI: DMAR 0x0000000067D35000 000190 (v01 IBM    BLADE    00000001 MSFT 01000021)
ACPI: Local APIC address 0xfee00000
SRAT: PXM 0 -> APIC 0x00 -> Node 0
SRAT: PXM 0 -> APIC 0x02 -> Node 0
SRAT: PXM 0 -> APIC 0x04 -> Node 0
SRAT: PXM 0 -> APIC 0x06 -> Node 0
SRAT: PXM 0 -> APIC 0x08 -> Node 0
SRAT: PXM 0 -> APIC 0x0a -> Node 0
SRAT: PXM 0 -> APIC 0x0c -> Node 0
SRAT: PXM 0 -> APIC 0x0e -> Node 0
SRAT: PXM 1 -> APIC 0x20 -> Node 1
SRAT: PXM 1 -> APIC 0x22 -> Node 1
SRAT: PXM 1 -> APIC 0x24 -> Node 1
SRAT: PXM 1 -> APIC 0x26 -> Node 1
SRAT: PXM 1 -> APIC 0x28 -> Node 1
SRAT: PXM 1 -> APIC 0x2a -> Node 1
SRAT: PXM 1 -> APIC 0x2c -> Node 1
SRAT: PXM 1 -> APIC 0x2e -> Node 1
SRAT: PXM 0 -> APIC 0x01 -> Node 0
SRAT: PXM 0 -> APIC 0x03 -> Node 0
SRAT: PXM 0 -> APIC 0x05 -> Node 0
SRAT: PXM 0 -> APIC 0x07 -> Node 0
SRAT: PXM 0 -> APIC 0x09 -> Node 0
SRAT: PXM 0 -> APIC 0x0b -> Node 0
SRAT: PXM 0 -> APIC 0x0d -> Node 0
SRAT: PXM 0 -> APIC 0x0f -> Node 0
SRAT: PXM 1 -> APIC 0x21 -> Node 1
SRAT: PXM 1 -> APIC 0x23 -> Node 1
SRAT: PXM 1 -> APIC 0x25 -> Node 1
SRAT: PXM 1 -> APIC 0x27 -> Node 1
SRAT: PXM 1 -> APIC 0x29 -> Node 1
SRAT: PXM 1 -> APIC 0x2b -> Node 1
SRAT: PXM 1 -> APIC 0x2d -> Node 1
SRAT: PXM 1 -> APIC 0x2f -> Node 1
SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
SRAT: Node 0 PXM 0 [mem 0x100000000-0x107fffffff]
SRAT: Node 1 PXM 1 [mem 0x1080000000-0x207fffffff]
NUMA: Initialized distance table, cnt=2
NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x107fffffff] -> [mem 0x00000000-0x107fffffff]
Initmem setup node 0 [mem 0x00000000-0x107fffffff]
  NODE_DATA [mem 0x107ffd9000-0x107fffffff]
Initmem setup node 1 [mem 0x1080000000-0x207fffffff]
  NODE_DATA [mem 0x207ffd2000-0x207fff8fff]
crashkernel: memory value expected
 [ffffea0000000000-ffffea0039bfffff] PMD -> [ffff88103fe00000-ffff881077dfffff] on node 0
 [ffffea0039c00000-ffffea0071bfffff] PMD -> [ffff88203f600000-ffff8820775fffff] on node 1
Zone ranges:
  DMA      [mem 0x00001000-0x00ffffff]
  DMA32    [mem 0x01000000-0xffffffff]
  Normal   [mem 0x100000000-0x207fffffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x00001000-0x0009bfff]
  node   0: [mem 0x00100000-0x67d34fff]
  node   0: [mem 0x67d36000-0x69d29fff]
  node   0: [mem 0x69dee000-0x6a599fff]
  node   0: [mem 0x6a5a3000-0x6a5bdfff]
  node   0: [mem 0x6a5cc000-0x6a5e3fff]
  node   0: [mem 0x6a5ec000-0x6a5effff]
  node   0: [mem 0x6a5f3000-0x6ac25fff]
  node   0: [mem 0x6ac27000-0x6b393fff]
  node   0: [mem 0x6b395000-0x7e596fff]
  node   0: [mem 0x7ebc6000-0x7ec01fff]
  node   0: [mem 0x100000000-0x107fffffff]
  node   1: [mem 0x1080000000-0x207fffffff]
On node 0 totalpages: 16770181
  DMA zone: 56 pages used for memmap
  DMA zone: 22 pages reserved
  DMA zone: 3995 pages, LIFO batch:0
  DMA32 zone: 7018 pages used for memmap
  DMA32 zone: 513258 pages, LIFO batch:31
  Normal zone: 222208 pages used for memmap
  Normal zone: 16252928 pages, LIFO batch:31
On node 1 totalpages: 16777216
  Normal zone: 229376 pages used for memmap
  Normal zone: 16777216 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x06] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x08] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x0a] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x0c] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x0e] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x20] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x22] enabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x24] enabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x26] enabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x28] enabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x2a] enabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x2c] enabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x2e] enabled)
ACPI: LAPIC (acpi_id[0x10] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x11] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x12] lapic_id[0x05] enabled)
ACPI: LAPIC (acpi_id[0x13] lapic_id[0x07] enabled)
ACPI: LAPIC (acpi_id[0x14] lapic_id[0x09] enabled)
ACPI: LAPIC (acpi_id[0x15] lapic_id[0x0b] enabled)
ACPI: LAPIC (acpi_id[0x16] lapic_id[0x0d] enabled)
ACPI: LAPIC (acpi_id[0x17] lapic_id[0x0f] enabled)
ACPI: LAPIC (acpi_id[0x18] lapic_id[0x21] enabled)
ACPI: LAPIC (acpi_id[0x19] lapic_id[0x23] enabled)
ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x25] enabled)
ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x27] enabled)
ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x29] enabled)
ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x2b] enabled)
ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x2d] enabled)
ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x2f] enabled)
ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x09] address[0xfec01000] gsi_base[24])
IOAPIC[1]: apic_id 9, version 32, address 0xfec01000, GSI 24-47
ACPI: IOAPIC (id[0x0a] address[0xfec40000] gsi_base[48])
IOAPIC[2]: apic_id 10, version 32, address 0xfec40000, GSI 48-71
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a701 base: 0xfed00000
smpboot: Allowing 32 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 88
PM: Registered nosave memory: [mem 0x0009c000-0x0009ffff]
PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
PM: Registered nosave memory: [mem 0x67d35000-0x67d35fff]
PM: Registered nosave memory: [mem 0x69d2a000-0x69dedfff]
PM: Registered nosave memory: [mem 0x6a59a000-0x6a5a2fff]
PM: Registered nosave memory: [mem 0x6a5be000-0x6a5cbfff]
PM: Registered nosave memory: [mem 0x6a5e4000-0x6a5ebfff]
PM: Registered nosave memory: [mem 0x6a5f0000-0x6a5f2fff]
PM: Registered nosave memory: [mem 0x6ac26000-0x6ac26fff]
PM: Registered nosave memory: [mem 0x6b394000-0x6b394fff]
PM: Registered nosave memory: [mem 0x7e597000-0x7e6a1fff]
PM: Registered nosave memory: [mem 0x7e6a2000-0x7ebc5fff]
PM: Registered nosave memory: [mem 0x7ec02000-0x7effffff]
PM: Registered nosave memory: [mem 0x7f000000-0x7fbfffff]
PM: Registered nosave memory: [mem 0x7fc00000-0x7fffffff]
PM: Registered nosave memory: [mem 0x80000000-0x8fffffff]
PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
PM: Registered nosave memory: [mem 0xfed20000-0xff7fffff]
PM: Registered nosave memory: [mem 0xff800000-0xffffffff]
e820: [mem 0x90000000-0xfed1bfff] available for PCI devices
setup_percpu: NR_CPUS:8192 nr_cpumask_bits:32 nr_cpu_ids:32 nr_node_ids:2
PERCPU: Embedded 28 pages/cpu @ffff88107fc00000 s83904 r8192 d22592 u131072
pcpu-alloc: s83904 r8192 d22592 u131072 alloc=1*2097152
pcpu-alloc: [0] 00 01 02 03 04 05 06 07 16 17 18 19 20 21 22 23 
pcpu-alloc: [1] 08 09 10 11 12 13 14 15 24 25 26 27 28 29 30 31 
Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 33088717
Policy zone: Normal
Kernel command line: ro root=UUID=0b808847-f479-46cd-b962-98544ff30c61 rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb console=tty0 console=ttyS1,115200 ignore_loglevel debug no_console_suspend selinux=0 softdog.soft_margin=30000
PID hash table entries: 4096 (order: 3, 32768 bytes)
xsave: enabled xstate_bv 0x7, cntxt size 0x340
Checking aperture...
No AGP bridge found
Memory: 132254224K/134189588K available (5874K kernel code, 1378K rwdata, 2768K rodata, 1980K init, 10724K bss, 1935364K reserved)
Hierarchical RCU implementation.
        RCU restricting CPUs from NR_CPUS=8192 to nr_cpu_ids=32.
RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=32
NR_IRQS:524544 nr_irqs:1752 16
Console: colour dummy device 80x25
console [tty0] enabled
console [ttyS1] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:  8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        8191
... CLASSHASH_SIZE:          4096
... MAX_LOCKDEP_ENTRIES:     16384
... MAX_LOCKDEP_CHAINS:      32768
... CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 5855 kB
 per task-struct memory footprint: 1920 bytes
hpet clockevent registered
tsc: Fast TSC calibration using PIT
tsc: Detected 2899.896 MHz processor
Calibrating delay loop (skipped), value calculated using timer frequency.. 5799.79 BogoMIPS (lpj=2899896)
pid_max: default: 32768 minimum: 301
ACPI: Core revision 20140214
ACPI: All ACPI Tables successfully acquired
Security Framework initialized
SELinux:  Disabled at boot.
Dentry cache hash table entries: 16777216 (order: 15, 134217728 bytes)
Inode-cache hash table entries: 8388608 (order: 14, 67108864 bytes)
Mount-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Mountpoint-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
Initializing cgroup subsys net_cls
Initializing cgroup subsys blkio
Initializing cgroup subsys perf_event
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 20 MCE banks
CPU0: Thermal LVT vector (0xfa) already installed
Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
tlb_flushall_shift: 6
Freeing SMP alternatives memory: 20K (ffffffff81d49000 - ffffffff81d4e000)
ftrace: allocating 23188 entries in 91 pages
Switched APIC routing to physical flat.
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
smpboot: CPU0: Intel(R) Xeon(R) CPU E5-2690 0 @ 2.90GHz (fam: 06, model: 2d, stepping: 07)
TSC deadline timer enabled
Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge events, full-width counters, Intel PMU driver.
... version:                3
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             0000ffffffffffff
... fixed-purpose events:   3
... event mask:             000000070000000f
x86: Booting SMP configuration:
.... node  #0, CPUs:        #1
CPU1: Thermal LVT vector (0xfa) already installed
NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
  #2
CPU2: Thermal LVT vector (0xfa) already installed
  #3
CPU3: Thermal LVT vector (0xfa) already installed
  #4
CPU4: Thermal LVT vector (0xfa) already installed
  #5
CPU5: Thermal LVT vector (0xfa) already installed
  #6
CPU6: Thermal LVT vector (0xfa) already installed
  #7
CPU7: Thermal LVT vector (0xfa) already installed

.... node  #1, CPUs:    #8
CPU8: Thermal LVT vector (0xfa) already installed
  #9
CPU9: Thermal LVT vector (0xfa) already installed
 #10
CPU10: Thermal LVT vector (0xfa) already installed
 #11
CPU11: Thermal LVT vector (0xfa) already installed
 #12
CPU12: Thermal LVT vector (0xfa) already installed
 #13
CPU13: Thermal LVT vector (0xfa) already installed
 #14
CPU14: Thermal LVT vector (0xfa) already installed
 #15
CPU15: Thermal LVT vector (0xfa) already installed

.... node  #0, CPUs:   #16
CPU16: Thermal LVT vector (0xfa) already installed
 #17
CPU17: Thermal LVT vector (0xfa) already installed
 #18
CPU18: Thermal LVT vector (0xfa) already installed
 #19
CPU19: Thermal LVT vector (0xfa) already installed
 #20
CPU20: Thermal LVT vector (0xfa) already installed
 #21
CPU21: Thermal LVT vector (0xfa) already installed
 #22
CPU22: Thermal LVT vector (0xfa) already installed
 #23
CPU23: Thermal LVT vector (0xfa) already installed

.... node  #1, CPUs:   #24
CPU24: Thermal LVT vector (0xfa) already installed
 #25
CPU25: Thermal LVT vector (0xfa) already installed
 #26
CPU26: Thermal LVT vector (0xfa) already installed
 #27
CPU27: Thermal LVT vector (0xfa) already installed
 #28
CPU28: Thermal LVT vector (0xfa) already installed
 #29
CPU29: Thermal LVT vector (0xfa) already installed
 #30
CPU30: Thermal LVT vector (0xfa) already installed
 #31
CPU31: Thermal LVT vector (0xfa) already installed
x86: Booted up 2 nodes, 32 CPUs
smpboot: Total of 32 processors activated (185765.85 BogoMIPS)
devtmpfs: initialized
PM: Registering ACPI NVS region [mem 0x7e6a2000-0x7ebc5fff] (5390336 bytes)
regulator-dummy: no parameters
NET: Registered protocol family 16
cpuidle: using governor ladder
cpuidle: using governor menu
ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
ACPI: bus type PCI registered
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0x80000000-0x8fffffff] (base 0x80000000)
PCI: MMCONFIG at [mem 0x80000000-0x8fffffff] reserved in E820
PCI: Using configuration type 1 for base access
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: Interpreter enabled
ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20140214/hwxface-580)
ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20140214/hwxface-580)
ACPI: (supports S0 S1 S3 S5)
ACPI: Using IOAPIC for interrupt routing
HEST: Table parsing has been initialized.
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
ACPI: PCI Root Bridge [IOH0] (domain 0000 [bus 00-7f])
acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
acpi PNP0A08:00: _OSC: platform does not support [AER]
acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
acpi PNP0A08:00: host bridge window expanded to [io  0x0000-0x0cf7]; [io  0x0000-0x0cf7] ignored
acpi PNP0A08:00: host bridge window expanded to [io  0x0000-0x0cf7]; [??? 0x00000000-0x00000cf7 flags 0x0] ignored
acpi PNP0A08:00: host bridge window expanded to [io  0x0000-0x0cf7]; [io  0x0000-0x0cf7] ignored
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [bus 00-7f]
pci_bus 0000:00: root bus resource [io  0x1000-0xbfff]
pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfedfffff]
pci_bus 0000:00: root bus resource [mem 0xc4000000-0xfbff7fff]
pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
pci_bus 0000:00: root bus resource [mem 0x3c0000000000-0x3c007fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0080000000-0x3c00ffffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0100000000-0x3c017fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0180000000-0x3c01ffffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0200000000-0x3c027fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0280000000-0x3c02ffffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0300000000-0x3c037fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0380000000-0x3c03ffffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0400000000-0x3c047fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0480000000-0x3c04ffffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0500000000-0x3c057fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0580000000-0x3c05ffffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0600000000-0x3c067fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0680000000-0x3c06ffffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0700000000-0x3c077fffffff]
pci_bus 0000:00: root bus resource [mem 0x3c0780000000-0x3c07ffffffff]
pci 0000:00:00.0: [8086:3c00] type 00 class 0x060000
pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: [8086:3c02] type 01 class 0x060400
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: System wakeup disabled by ACPI
pci 0000:00:02.0: [8086:3c04] type 01 class 0x060400
pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
pci 0000:00:02.0: System wakeup disabled by ACPI
pci 0000:00:03.0: [8086:3c08] type 01 class 0x060400
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: System wakeup disabled by ACPI
pci 0000:00:04.0: [8086:3c20] type 00 class 0x088000
pci 0000:00:04.0: reg 0x10: [mem 0xfb81c000-0xfb81ffff 64bit]
pci 0000:00:04.1: [8086:3c21] type 00 class 0x088000
pci 0000:00:04.1: reg 0x10: [mem 0xfb818000-0xfb81bfff 64bit]
pci 0000:00:04.2: [8086:3c22] type 00 class 0x088000
pci 0000:00:04.2: reg 0x10: [mem 0xfb814000-0xfb817fff 64bit]
pci 0000:00:04.3: [8086:3c23] type 00 class 0x088000
pci 0000:00:04.3: reg 0x10: [mem 0xfb810000-0xfb813fff 64bit]
pci 0000:00:04.4: [8086:3c24] type 00 class 0x088000
pci 0000:00:04.4: reg 0x10: [mem 0xfb80c000-0xfb80ffff 64bit]
pci 0000:00:04.5: [8086:3c25] type 00 class 0x088000
pci 0000:00:04.5: reg 0x10: [mem 0xfb808000-0xfb80bfff 64bit]
pci 0000:00:04.6: [8086:3c26] type 00 class 0x088000
pci 0000:00:04.6: reg 0x10: [mem 0xfb804000-0xfb807fff 64bit]
pci 0000:00:04.7: [8086:3c27] type 00 class 0x088000
pci 0000:00:04.7: reg 0x10: [mem 0xfb800000-0xfb803fff 64bit]
pci 0000:00:05.0: [8086:3c28] type 00 class 0x088000
pci 0000:00:05.2: [8086:3c2a] type 00 class 0x088000
pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.0: [8086:1d2d] type 00 class 0x0c0320
pci 0000:00:1a.0: reg 0x10: [mem 0xc5e01000-0xc5e013ff]
pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.0: System wakeup disabled by ACPI
pci 0000:00:1c.0: [8086:1d10] type 01 class 0x060400
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: System wakeup disabled by ACPI
pci 0000:00:1c.4: [8086:1d18] type 01 class 0x060400
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: System wakeup disabled by ACPI
pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
pci 0000:00:1d.0: reg 0x10: [mem 0xc5e00000-0xc5e003ff]
pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.0: System wakeup disabled by ACPI
pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
pci 0000:00:1e.0: System wakeup disabled by ACPI
pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
pci 0000:00:1f.3: [8086:1d22] type 00 class 0x0c0500
pci 0000:00:1f.3: reg 0x10: [mem 0xfb821000-0xfb8210ff 64bit]
pci 0000:00:1f.3: reg 0x20: [io  0x4000-0x401f]
pci 0000:00:01.0: PCI bridge to [bus 0c-10]
pci 0000:11:00.0: [15b3:1003] type 00 class 0x020000
pci 0000:11:00.0: reg 0x10: [mem 0xc5d00000-0xc5dfffff 64bit]
pci 0000:11:00.0: reg 0x18: [mem 0xfb000000-0xfb7fffff 64bit pref]
pci 0000:11:00.0: reg 0x30: [mem 0xfff00000-0xffffffff pref]
pci 0000:00:02.0: PCI bridge to [bus 11-15]
pci 0000:00:02.0:   bridge window [mem 0xc5d00000-0xc5dfffff]
pci 0000:00:02.0:   bridge window [mem 0xfb000000-0xfb7fffff 64bit pref]
pci 0000:16:00.0: [1077:2532] type 00 class 0x0c0400
pci 0000:16:00.0: reg 0x10: [io  0x3200-0x32ff]
pci 0000:16:00.0: reg 0x14: [mem 0xc5c00000-0xc5c03fff 64bit]
pci 0000:16:00.0: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
pci 0000:16:00.1: [1077:2532] type 00 class 0x0c0400
pci 0000:16:00.1: reg 0x10: [io  0x3000-0x30ff]
pci 0000:16:00.1: reg 0x14: [mem 0xc5c04000-0xc5c07fff 64bit]
pci 0000:16:00.1: reg 0x30: [mem 0xfffc0000-0xffffffff pref]
pci 0000:00:03.0: PCI bridge to [bus 16-1a]
pci 0000:00:03.0:   bridge window [io  0x3000-0x3fff]
pci 0000:00:03.0:   bridge window [mem 0xc5c00000-0xc5cfffff]
pci 0000:00:03.0:   bridge window [mem 0xc5f00000-0xc5ffffff 64bit pref]
pci 0000:00:11.0: PCI bridge to [bus 1b]
pci 0000:00:11.0:   bridge window [io  0x2000-0x2fff]
pci 0000:00:11.0:   bridge window [mem 0xc5b00000-0xc5bfffff]
pci 0000:01:00.0: [1912:0013] type 01 class 0x060400
pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PCI bridge to [bus 01-05]
pci 0000:00:1c.0:   bridge window [mem 0xc5000000-0xc59fffff]
pci 0000:00:1c.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:02:00.0: [1912:0013] type 01 class 0x060400
pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
pci 0000:02:01.0: [1912:0013] type 01 class 0x060400
pci 0000:02:01.0: PME# supported from D0 D3hot D3cold
pci 0000:01:00.0: PCI bridge to [bus 02-05]
pci 0000:01:00.0:   bridge window [mem 0xc5000000-0xc59fffff]
pci 0000:01:00.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:03:00.0: [1912:0012] type 01 class 0x060400
pci 0000:02:00.0: PCI bridge to [bus 03-04]
pci 0000:02:00.0:   bridge window [mem 0xc5000000-0xc58fffff]
pci 0000:02:00.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:04:00.0: [102b:0534] type 00 class 0x030000
pci 0000:04:00.0: reg 0x10: [mem 0xc4000000-0xc4ffffff pref]
pci 0000:04:00.0: reg 0x14: [mem 0xc5800000-0xc5803fff]
pci 0000:04:00.0: reg 0x18: [mem 0xc5000000-0xc57fffff]
pci 0000:03:00.0: PCI bridge to [bus 04]
pci 0000:03:00.0:   bridge window [mem 0xc5000000-0xc58fffff]
pci 0000:03:00.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:02:01.0: PCI bridge to [bus 05]
pci 0000:02:01.0:   bridge window [mem 0xc5900000-0xc59fffff]
pci 0000:06:00.0: [1000:0070] type 00 class 0x010700
pci 0000:06:00.0: reg 0x10: [io  0x1000-0x10ff]
pci 0000:06:00.0: reg 0x14: [mem 0xc5a40000-0xc5a43fff 64bit]
pci 0000:06:00.0: reg 0x1c: [mem 0xc5a00000-0xc5a3ffff 64bit]
pci 0000:06:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
pci 0000:06:00.0: supports D1 D2
pci 0000:00:1c.4: PCI bridge to [bus 06]
pci 0000:00:1c.4:   bridge window [io  0x1000-0x1fff]
pci 0000:00:1c.4:   bridge window [mem 0xc5a00000-0xc5afffff]
pci 0000:00:1c.4:   bridge window [mem 0xc6000000-0xc60fffff 64bit pref]
pci 0000:00:1e.0: PCI bridge to [bus 1c] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x1000-0xbfff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0xc4000000-0xfbff7fff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0000000000-0x3c007fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0080000000-0x3c00ffffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0100000000-0x3c017fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0180000000-0x3c01ffffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0200000000-0x3c027fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0280000000-0x3c02ffffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0300000000-0x3c037fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0380000000-0x3c03ffffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0400000000-0x3c047fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0480000000-0x3c04ffffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0500000000-0x3c057fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0580000000-0x3c05ffffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0600000000-0x3c067fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0680000000-0x3c06ffffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0700000000-0x3c077fffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x3c0780000000-0x3c07ffffffff] (subtractive decode)
pci_bus 0000:00: on NUMA node 0
acpi PNP0A08:00: Disabling ASPM (FADT indicates it is unsupported)
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Root Bridge [IOH1] (domain 0000 [bus 80-ff])
acpi PNP0A08:01: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
acpi PNP0A08:01: _OSC: platform does not support [AER]
acpi PNP0A08:01: _OSC: OS now controls [PCIeHotplug PME PCIeCapability]
PCI host bridge to bus 0000:80
pci_bus 0000:80: root bus resource [bus 80-ff]
pci_bus 0000:80: root bus resource [io  0xc000-0xffff]
pci_bus 0000:80: root bus resource [mem 0x90000000-0xc3ff7fff]
pci_bus 0000:80: root bus resource [mem 0x3c0800000000-0x3c087fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0880000000-0x3c08ffffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0900000000-0x3c097fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0980000000-0x3c09ffffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0a00000000-0x3c0a7fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0a80000000-0x3c0affffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0b00000000-0x3c0b7fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0b80000000-0x3c0bffffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0c00000000-0x3c0c7fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0c80000000-0x3c0cffffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0d00000000-0x3c0d7fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0d80000000-0x3c0dffffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0e00000000-0x3c0e7fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0e80000000-0x3c0effffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0f00000000-0x3c0f7fffffff]
pci_bus 0000:80: root bus resource [mem 0x3c0f80000000-0x3c0fffffffff]
pci 0000:80:00.0: [8086:3c01] type 01 class 0x060400
pci 0000:80:00.0: PME# supported from D0 D3hot D3cold
pci 0000:80:01.0: [8086:3c02] type 01 class 0x060400
pci 0000:80:01.0: PME# supported from D0 D3hot D3cold
pci 0000:80:01.0: System wakeup disabled by ACPI
pci 0000:80:01.1: [8086:3c03] type 01 class 0x060400
pci 0000:80:01.1: PME# supported from D0 D3hot D3cold
pci 0000:80:02.0: [8086:3c04] type 01 class 0x060400
pci 0000:80:02.0: PME# supported from D0 D3hot D3cold
pci 0000:80:02.0: System wakeup disabled by ACPI
pci 0000:80:02.2: [8086:3c06] type 01 class 0x060400
pci 0000:80:02.2: PME# supported from D0 D3hot D3cold
pci 0000:80:02.2: System wakeup disabled by ACPI
pci 0000:80:03.0: [8086:3c08] type 01 class 0x060400
pci 0000:80:03.0: PME# supported from D0 D3hot D3cold
pci 0000:80:03.0: System wakeup disabled by ACPI
pci 0000:80:04.0: [8086:3c20] type 00 class 0x088000
pci 0000:80:04.0: reg 0x10: [mem 0xc3ff4000-0xc3ff7fff 64bit]
pci 0000:80:04.1: [8086:3c21] type 00 class 0x088000
pci 0000:80:04.1: reg 0x10: [mem 0xc3ff0000-0xc3ff3fff 64bit]
pci 0000:80:04.2: [8086:3c22] type 00 class 0x088000
pci 0000:80:04.2: reg 0x10: [mem 0xc3fec000-0xc3feffff 64bit]
pci 0000:80:04.3: [8086:3c23] type 00 class 0x088000
pci 0000:80:04.3: reg 0x10: [mem 0xc3fe8000-0xc3febfff 64bit]
pci 0000:80:04.4: [8086:3c24] type 00 class 0x088000
pci 0000:80:04.4: reg 0x10: [mem 0xc3fe4000-0xc3fe7fff 64bit]
pci 0000:80:04.5: [8086:3c25] type 00 class 0x088000
pci 0000:80:04.5: reg 0x10: [mem 0xc3fe0000-0xc3fe3fff 64bit]
pci 0000:80:04.6: [8086:3c26] type 00 class 0x088000
pci 0000:80:04.6: reg 0x10: [mem 0xc3fdc000-0xc3fdffff 64bit]
pci 0000:80:04.7: [8086:3c27] type 00 class 0x088000
pci 0000:80:04.7: reg 0x10: [mem 0xc3fd8000-0xc3fdbfff 64bit]
pci 0000:80:05.0: [8086:3c28] type 00 class 0x088000
pci 0000:80:05.2: [8086:3c2a] type 00 class 0x088000
pci 0000:80:00.0: PCI bridge to [bus 81-85]
pci 0000:80:01.0: PCI bridge to [bus 86-8a]
pci 0000:80:01.1: PCI bridge to [bus 8b-8f]
pci 0000:80:02.0: PCI bridge to [bus 90-94]
pci 0000:80:02.2: PCI bridge to [bus 95-99]
pci 0000:80:03.0: PCI bridge to [bus 9a-9e]
pci_bus 0000:80: on NUMA node 1
acpi PNP0A08:01: Disabling ASPM (FADT indicates it is unsupported)
ACPI: Enabled 2 GPEs in block 00 to 3F
vgaarb: device added: PCI:0000:04:00.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
vgaarb: bridge control possible 0000:04:00.0
SCSI subsystem initialized
libata version 3.00 loaded.
ACPI: bus type USB registered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: Discovered peer bus 7f
PCI: root bus 7f: using default resources
PCI: Probing PCI hardware (bus 7f)
PCI host bridge to bus 0000:7f
pci_bus 0000:7f: root bus resource [io  0x0000-0xffff]
pci_bus 0000:7f: root bus resource [mem 0x00000000-0x3fffffffffff]
pci_bus 0000:7f: No busn resource found for root bus, will use [bus 7f-ff]
pci_bus 0000:7f: busn_res: can not insert [bus 7f-ff] under domain [bus 00-ff] (conflicts with (null) [bus 00-7f])
pci 0000:7f:08.0: [8086:3c80] type 00 class 0x088000
pci 0000:7f:08.2: [8086:3c41] type 00 class 0x110100
pci 0000:7f:08.3: [8086:3c83] type 00 class 0x088000
pci 0000:7f:08.4: [8086:3c84] type 00 class 0x088000
pci 0000:7f:09.0: [8086:3c90] type 00 class 0x088000
pci 0000:7f:09.2: [8086:3c42] type 00 class 0x110100
pci 0000:7f:09.3: [8086:3c93] type 00 class 0x088000
pci 0000:7f:09.4: [8086:3c94] type 00 class 0x088000
pci 0000:7f:0a.0: [8086:3cc0] type 00 class 0x088000
pci 0000:7f:0a.1: [8086:3cc1] type 00 class 0x088000
pci 0000:7f:0a.2: [8086:3cc2] type 00 class 0x088000
pci 0000:7f:0a.3: [8086:3cd0] type 00 class 0x088000
pci 0000:7f:0b.0: [8086:3ce0] type 00 class 0x088000
pci 0000:7f:0b.3: [8086:3ce3] type 00 class 0x088000
pci 0000:7f:0c.0: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0c.1: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0c.2: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0c.3: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0c.6: [8086:3cf4] type 00 class 0x088000
pci 0000:7f:0c.7: [8086:3cf6] type 00 class 0x088000
pci 0000:7f:0d.0: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0d.1: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0d.2: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0d.3: [8086:3ce8] type 00 class 0x088000
pci 0000:7f:0d.6: [8086:3cf5] type 00 class 0x088000
pci 0000:7f:0e.0: [8086:3ca0] type 00 class 0x088000
pci 0000:7f:0e.1: [8086:3c46] type 00 class 0x110100
pci 0000:7f:0f.0: [8086:3ca8] type 00 class 0x088000
pci 0000:7f:0f.1: [8086:3c71] type 00 class 0x088000
pci 0000:7f:0f.2: [8086:3caa] type 00 class 0x088000
pci 0000:7f:0f.3: [8086:3cab] type 00 class 0x088000
pci 0000:7f:0f.4: [8086:3cac] type 00 class 0x088000
pci 0000:7f:0f.5: [8086:3cad] type 00 class 0x088000
pci 0000:7f:0f.6: [8086:3cae] type 00 class 0x088000
pci 0000:7f:10.0: [8086:3cb0] type 00 class 0x088000
pci 0000:7f:10.1: [8086:3cb1] type 00 class 0x088000
pci 0000:7f:10.2: [8086:3cb2] type 00 class 0x088000
pci 0000:7f:10.3: [8086:3cb3] type 00 class 0x088000
pci 0000:7f:10.4: [8086:3cb4] type 00 class 0x088000
pci 0000:7f:10.5: [8086:3cb5] type 00 class 0x088000
pci 0000:7f:10.6: [8086:3cb6] type 00 class 0x088000
pci 0000:7f:10.7: [8086:3cb7] type 00 class 0x088000
pci 0000:7f:11.0: [8086:3cb8] type 00 class 0x088000
pci 0000:7f:13.0: [8086:3ce4] type 00 class 0x088000
pci 0000:7f:13.1: [8086:3c43] type 00 class 0x110100
pci 0000:7f:13.4: [8086:3ce6] type 00 class 0x110100
pci 0000:7f:13.5: [8086:3c44] type 00 class 0x110100
pci 0000:7f:13.6: [8086:3c45] type 00 class 0x088000
pci_bus 0000:7f: busn_res: [bus 7f-ff] end is updated to 7f
pci_bus 0000:7f: busn_res: can not insert [bus 7f] under domain [bus 00-ff] (conflicts with (null) [bus 00-7f])
PCI: Discovered peer bus ff
PCI: root bus ff: using default resources
PCI: Probing PCI hardware (bus ff)
PCI host bridge to bus 0000:ff
pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
pci_bus 0000:ff: root bus resource [mem 0x00000000-0x3fffffffffff]
pci_bus 0000:ff: No busn resource found for root bus, will use [bus ff-ff]
pci_bus 0000:ff: busn_res: can not insert [bus ff] under domain [bus 00-ff] (conflicts with (null) [bus 80-ff])
pci 0000:ff:08.0: [8086:3c80] type 00 class 0x088000
pci 0000:ff:08.2: [8086:3c41] type 00 class 0x110100
pci 0000:ff:08.3: [8086:3c83] type 00 class 0x088000
pci 0000:ff:08.4: [8086:3c84] type 00 class 0x088000
pci 0000:ff:09.0: [8086:3c90] type 00 class 0x088000
pci 0000:ff:09.2: [8086:3c42] type 00 class 0x110100
pci 0000:ff:09.3: [8086:3c93] type 00 class 0x088000
pci 0000:ff:09.4: [8086:3c94] type 00 class 0x088000
pci 0000:ff:0a.0: [8086:3cc0] type 00 class 0x088000
pci 0000:ff:0a.1: [8086:3cc1] type 00 class 0x088000
pci 0000:ff:0a.2: [8086:3cc2] type 00 class 0x088000
pci 0000:ff:0a.3: [8086:3cd0] type 00 class 0x088000
pci 0000:ff:0b.0: [8086:3ce0] type 00 class 0x088000
pci 0000:ff:0b.3: [8086:3ce3] type 00 class 0x088000
pci 0000:ff:0c.0: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0c.1: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0c.2: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0c.3: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0c.6: [8086:3cf4] type 00 class 0x088000
pci 0000:ff:0c.7: [8086:3cf6] type 00 class 0x088000
pci 0000:ff:0d.0: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0d.1: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0d.2: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0d.3: [8086:3ce8] type 00 class 0x088000
pci 0000:ff:0d.6: [8086:3cf5] type 00 class 0x088000
pci 0000:ff:0e.0: [8086:3ca0] type 00 class 0x088000
pci 0000:ff:0e.1: [8086:3c46] type 00 class 0x110100
pci 0000:ff:0f.0: [8086:3ca8] type 00 class 0x088000
pci 0000:ff:0f.1: [8086:3c71] type 00 class 0x088000
pci 0000:ff:0f.2: [8086:3caa] type 00 class 0x088000
pci 0000:ff:0f.3: [8086:3cab] type 00 class 0x088000
pci 0000:ff:0f.4: [8086:3cac] type 00 class 0x088000
pci 0000:ff:0f.5: [8086:3cad] type 00 class 0x088000
pci 0000:ff:0f.6: [8086:3cae] type 00 class 0x088000
pci 0000:ff:10.0: [8086:3cb0] type 00 class 0x088000
pci 0000:ff:10.1: [8086:3cb1] type 00 class 0x088000
pci 0000:ff:10.2: [8086:3cb2] type 00 class 0x088000
pci 0000:ff:10.3: [8086:3cb3] type 00 class 0x088000
pci 0000:ff:10.4: [8086:3cb4] type 00 class 0x088000
pci 0000:ff:10.5: [8086:3cb5] type 00 class 0x088000
pci 0000:ff:10.6: [8086:3cb6] type 00 class 0x088000
pci 0000:ff:10.7: [8086:3cb7] type 00 class 0x088000
pci 0000:ff:11.0: [8086:3cb8] type 00 class 0x088000
pci 0000:ff:13.0: [8086:3ce4] type 00 class 0x088000
pci 0000:ff:13.1: [8086:3c43] type 00 class 0x110100
pci 0000:ff:13.4: [8086:3ce6] type 00 class 0x110100
pci 0000:ff:13.5: [8086:3c44] type 00 class 0x110100
pci 0000:ff:13.6: [8086:3c45] type 00 class 0x088000
pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
pci_bus 0000:ff: busn_res: can not insert [bus ff] under domain [bus 00-ff] (conflicts with (null) [bus 80-ff])
PCI: pci_cache_line_size set to 64 bytes
e820: reserve RAM buffer [mem 0x0009c000-0x0009ffff]
e820: reserve RAM buffer [mem 0x67d35000-0x67ffffff]
e820: reserve RAM buffer [mem 0x69d2a000-0x6bffffff]
e820: reserve RAM buffer [mem 0x6a59a000-0x6bffffff]
e820: reserve RAM buffer [mem 0x6a5be000-0x6bffffff]
e820: reserve RAM buffer [mem 0x6a5e4000-0x6bffffff]
e820: reserve RAM buffer [mem 0x6a5f0000-0x6bffffff]
e820: reserve RAM buffer [mem 0x6ac26000-0x6bffffff]
e820: reserve RAM buffer [mem 0x6b394000-0x6bffffff]
e820: reserve RAM buffer [mem 0x7e597000-0x7fffffff]
e820: reserve RAM buffer [mem 0x7ec02000-0x7fffffff]
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
hpet0: 8 comparators, 64-bit 14.318180 MHz counter
Switched to clocksource hpet
pnp: PnP ACPI init
ACPI: bus type PNP registered
pnp 00:00: Plug and Play ACPI device, IDs PNP0003 (active)
pnp 00:01: [dma 4]
pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:05: Plug and Play ACPI device, IDs PNP0103 (active)
system 00:06: [io  0x0500-0x053f] has been reserved
system 00:06: [io  0x0400-0x047f] has been reserved
system 00:06: [io  0x0800-0x081f] has been reserved
system 00:06: [mem 0xfed1c000-0xfed8bffe] could not be reserved
system 00:06: [mem 0xff000000-0xffffffff] could not be reserved
system 00:06: [mem 0xfee00000-0xfeefffff] has been reserved
system 00:06: [mem 0xfed1b000-0xfed1bfff] has been reserved
system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
system 00:07: [io  0x0cc0] has been reserved
system 00:07: [io  0x0cc1] has been reserved
system 00:07: Plug and Play ACPI device, IDs IPI0001 PNP0c02 (active)
system 00:08: [io  0x0c80-0x0c9f] has been reserved
system 00:08: [io  0x0cc2-0x0cc3] has been reserved
system 00:08: [io  0x0ca0-0x0caf] has been reserved
system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0a: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0b: Plug and Play ACPI device, IDs PNP0c31 (active)
system 00:0c: [io  0x0cb0-0x0cbf] has been reserved
system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
system 00:0d: [mem 0xfbff8000-0xfbffafff] has been reserved
system 00:0d: [mem 0xc3ff8000-0xc3ffafff] has been reserved
system 00:0d: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp: PnP ACPI: found 14 devices
ACPI: bus type PNP unregistered
pci 0000:11:00.0: can't claim BAR 6 [mem 0xfff00000-0xffffffff pref]: no compatible bridge window
pci 0000:16:00.0: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
pci 0000:16:00.1: can't claim BAR 6 [mem 0xfffc0000-0xffffffff pref]: no compatible bridge window
pci 0000:06:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
pci 0000:00:01.0: PCI bridge to [bus 0c-10]
pci 0000:11:00.0: BAR 6: can't assign mem pref (size 0x100000)
pci 0000:00:02.0: PCI bridge to [bus 11-15]
pci 0000:00:02.0:   bridge window [mem 0xc5d00000-0xc5dfffff]
pci 0000:00:02.0:   bridge window [mem 0xfb000000-0xfb7fffff 64bit pref]
pci 0000:16:00.0: BAR 6: assigned [mem 0xc5f00000-0xc5f3ffff pref]
pci 0000:16:00.1: BAR 6: assigned [mem 0xc5f40000-0xc5f7ffff pref]
pci 0000:00:03.0: PCI bridge to [bus 16-1a]
pci 0000:00:03.0:   bridge window [io  0x3000-0x3fff]
pci 0000:00:03.0:   bridge window [mem 0xc5c00000-0xc5cfffff]
pci 0000:00:03.0:   bridge window [mem 0xc5f00000-0xc5ffffff 64bit pref]
pci 0000:00:11.0: PCI bridge to [bus 1b]
pci 0000:00:11.0:   bridge window [io  0x2000-0x2fff]
pci 0000:00:11.0:   bridge window [mem 0xc5b00000-0xc5bfffff]
pci 0000:03:00.0: PCI bridge to [bus 04]
pci 0000:03:00.0:   bridge window [mem 0xc5000000-0xc58fffff]
pci 0000:03:00.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:02:00.0: PCI bridge to [bus 03-04]
pci 0000:02:00.0:   bridge window [mem 0xc5000000-0xc58fffff]
pci 0000:02:00.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:02:01.0: PCI bridge to [bus 05]
pci 0000:02:01.0:   bridge window [mem 0xc5900000-0xc59fffff]
pci 0000:01:00.0: PCI bridge to [bus 02-05]
pci 0000:01:00.0:   bridge window [mem 0xc5000000-0xc59fffff]
pci 0000:01:00.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:00:1c.0: PCI bridge to [bus 01-05]
pci 0000:00:1c.0:   bridge window [mem 0xc5000000-0xc59fffff]
pci 0000:00:1c.0:   bridge window [mem 0xc4000000-0xc4ffffff 64bit pref]
pci 0000:06:00.0: BAR 6: assigned [mem 0xc6000000-0xc607ffff pref]
pci 0000:00:1c.4: PCI bridge to [bus 06]
pci 0000:00:1c.4:   bridge window [io  0x1000-0x1fff]
pci 0000:00:1c.4:   bridge window [mem 0xc5a00000-0xc5afffff]
pci 0000:00:1c.4:   bridge window [mem 0xc6000000-0xc60fffff 64bit pref]
pci 0000:00:1e.0: PCI bridge to [bus 1c]
pci_bus 0000:00: resource 4 [io  0x1000-0xbfff]
pci_bus 0000:00: resource 5 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 6 [mem 0xfed40000-0xfedfffff]
pci_bus 0000:00: resource 7 [mem 0xc4000000-0xfbff7fff]
pci_bus 0000:00: resource 8 [io  0x0000-0x0cf7]
pci_bus 0000:00: resource 9 [mem 0x3c0000000000-0x3c007fffffff]
pci_bus 0000:00: resource 10 [mem 0x3c0080000000-0x3c00ffffffff]
pci_bus 0000:00: resource 11 [mem 0x3c0100000000-0x3c017fffffff]
pci_bus 0000:00: resource 12 [mem 0x3c0180000000-0x3c01ffffffff]
pci_bus 0000:00: resource 13 [mem 0x3c0200000000-0x3c027fffffff]
pci_bus 0000:00: resource 14 [mem 0x3c0280000000-0x3c02ffffffff]
pci_bus 0000:00: resource 15 [mem 0x3c0300000000-0x3c037fffffff]
pci_bus 0000:00: resource 16 [mem 0x3c0380000000-0x3c03ffffffff]
pci_bus 0000:00: resource 17 [mem 0x3c0400000000-0x3c047fffffff]
pci_bus 0000:00: resource 18 [mem 0x3c0480000000-0x3c04ffffffff]
pci_bus 0000:00: resource 19 [mem 0x3c0500000000-0x3c057fffffff]
pci_bus 0000:00: resource 20 [mem 0x3c0580000000-0x3c05ffffffff]
pci_bus 0000:00: resource 21 [mem 0x3c0600000000-0x3c067fffffff]
pci_bus 0000:00: resource 22 [mem 0x3c0680000000-0x3c06ffffffff]
pci_bus 0000:00: resource 23 [mem 0x3c0700000000-0x3c077fffffff]
pci_bus 0000:00: resource 24 [mem 0x3c0780000000-0x3c07ffffffff]
pci_bus 0000:11: resource 1 [mem 0xc5d00000-0xc5dfffff]
pci_bus 0000:11: resource 2 [mem 0xfb000000-0xfb7fffff 64bit pref]
pci_bus 0000:16: resource 0 [io  0x3000-0x3fff]
pci_bus 0000:16: resource 1 [mem 0xc5c00000-0xc5cfffff]
pci_bus 0000:16: resource 2 [mem 0xc5f00000-0xc5ffffff 64bit pref]
pci_bus 0000:1b: resource 0 [io  0x2000-0x2fff]
pci_bus 0000:1b: resource 1 [mem 0xc5b00000-0xc5bfffff]
pci_bus 0000:01: resource 1 [mem 0xc5000000-0xc59fffff]
pci_bus 0000:01: resource 2 [mem 0xc4000000-0xc4ffffff 64bit pref]
pci_bus 0000:02: resource 1 [mem 0xc5000000-0xc59fffff]
pci_bus 0000:02: resource 2 [mem 0xc4000000-0xc4ffffff 64bit pref]
pci_bus 0000:03: resource 1 [mem 0xc5000000-0xc58fffff]
pci_bus 0000:03: resource 2 [mem 0xc4000000-0xc4ffffff 64bit pref]
pci_bus 0000:04: resource 1 [mem 0xc5000000-0xc58fffff]
pci_bus 0000:04: resource 2 [mem 0xc4000000-0xc4ffffff 64bit pref]
pci_bus 0000:05: resource 1 [mem 0xc5900000-0xc59fffff]
pci_bus 0000:06: resource 0 [io  0x1000-0x1fff]
pci_bus 0000:06: resource 1 [mem 0xc5a00000-0xc5afffff]
pci_bus 0000:06: resource 2 [mem 0xc6000000-0xc60fffff 64bit pref]
pci_bus 0000:1c: resource 4 [io  0x1000-0xbfff]
pci_bus 0000:1c: resource 5 [mem 0x000a0000-0x000bffff]
pci_bus 0000:1c: resource 6 [mem 0xfed40000-0xfedfffff]
pci_bus 0000:1c: resource 7 [mem 0xc4000000-0xfbff7fff]
pci_bus 0000:1c: resource 8 [io  0x0000-0x0cf7]
pci_bus 0000:1c: resource 9 [mem 0x3c0000000000-0x3c007fffffff]
pci_bus 0000:1c: resource 10 [mem 0x3c0080000000-0x3c00ffffffff]
pci_bus 0000:1c: resource 11 [mem 0x3c0100000000-0x3c017fffffff]
pci_bus 0000:1c: resource 12 [mem 0x3c0180000000-0x3c01ffffffff]
pci_bus 0000:1c: resource 13 [mem 0x3c0200000000-0x3c027fffffff]
pci_bus 0000:1c: resource 14 [mem 0x3c0280000000-0x3c02ffffffff]
pci_bus 0000:1c: resource 15 [mem 0x3c0300000000-0x3c037fffffff]
pci_bus 0000:1c: resource 16 [mem 0x3c0380000000-0x3c03ffffffff]
pci_bus 0000:1c: resource 17 [mem 0x3c0400000000-0x3c047fffffff]
pci_bus 0000:1c: resource 18 [mem 0x3c0480000000-0x3c04ffffffff]
pci_bus 0000:1c: resource 19 [mem 0x3c0500000000-0x3c057fffffff]
pci_bus 0000:1c: resource 20 [mem 0x3c0580000000-0x3c05ffffffff]
pci_bus 0000:1c: resource 21 [mem 0x3c0600000000-0x3c067fffffff]
pci_bus 0000:1c: resource 22 [mem 0x3c0680000000-0x3c06ffffffff]
pci_bus 0000:1c: resource 23 [mem 0x3c0700000000-0x3c077fffffff]
pci_bus 0000:1c: resource 24 [mem 0x3c0780000000-0x3c07ffffffff]
pci 0000:80:00.0: PCI bridge to [bus 81-85]
pci 0000:80:01.0: PCI bridge to [bus 86-8a]
pci 0000:80:01.1: PCI bridge to [bus 8b-8f]
pci 0000:80:02.0: PCI bridge to [bus 90-94]
pci 0000:80:02.2: PCI bridge to [bus 95-99]
pci 0000:80:03.0: PCI bridge to [bus 9a-9e]
pci_bus 0000:80: resource 4 [io  0xc000-0xffff]
pci_bus 0000:80: resource 5 [mem 0x90000000-0xc3ff7fff]
pci_bus 0000:80: resource 6 [mem 0x3c0800000000-0x3c087fffffff]
pci_bus 0000:80: resource 7 [mem 0x3c0880000000-0x3c08ffffffff]
pci_bus 0000:80: resource 8 [mem 0x3c0900000000-0x3c097fffffff]
pci_bus 0000:80: resource 9 [mem 0x3c0980000000-0x3c09ffffffff]
pci_bus 0000:80: resource 10 [mem 0x3c0a00000000-0x3c0a7fffffff]
pci_bus 0000:80: resource 11 [mem 0x3c0a80000000-0x3c0affffffff]
pci_bus 0000:80: resource 12 [mem 0x3c0b00000000-0x3c0b7fffffff]
pci_bus 0000:80: resource 13 [mem 0x3c0b80000000-0x3c0bffffffff]
pci_bus 0000:80: resource 14 [mem 0x3c0c00000000-0x3c0c7fffffff]
pci_bus 0000:80: resource 15 [mem 0x3c0c80000000-0x3c0cffffffff]
pci_bus 0000:80: resource 16 [mem 0x3c0d00000000-0x3c0d7fffffff]
pci_bus 0000:80: resource 17 [mem 0x3c0d80000000-0x3c0dffffffff]
pci_bus 0000:80: resource 18 [mem 0x3c0e00000000-0x3c0e7fffffff]
pci_bus 0000:80: resource 19 [mem 0x3c0e80000000-0x3c0effffffff]
pci_bus 0000:80: resource 20 [mem 0x3c0f00000000-0x3c0f7fffffff]
pci_bus 0000:80: resource 21 [mem 0x3c0f80000000-0x3c0fffffffff]
pci_bus 0000:7f: resource 4 [io  0x0000-0xffff]
pci_bus 0000:7f: resource 5 [mem 0x00000000-0x3fffffffffff]
pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
pci_bus 0000:ff: resource 5 [mem 0x00000000-0x3fffffffffff]
NET: Registered protocol family 2
TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP: reno registered
UDP hash table entries: 65536 (order: 11, 10485760 bytes)
UDP-Lite hash table entries: 65536 (order: 11, 10485760 bytes)
NET: Registered protocol family 1
pci 0000:04:00.0: Boot video device
PCI: CLS 64 bytes, default 64
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 4744K (ffff88007e0f5000 - ffff88007e597000)
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
software IO TLB [mem 0x7a0f5000-0x7e0f5000] (64MB) mapped at [ffff88007a0f5000-ffff88007e0f4fff]
futex hash table entries: 8192 (order: 8, 1048576 bytes)
Initialise system trusted keyring
audit: initializing netlink subsys (disabled)
audit: type=2000 audit(1398707104.154:1): initialized
bounce pool size: 64 pages
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 32768
Key type asymmetric registered
Asymmetric key parser 'x509' registered
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
pcieport 0000:00:01.0: irq 88 for MSI/MSI-X
pcieport 0000:00:02.0: irq 89 for MSI/MSI-X
pcieport 0000:00:03.0: irq 90 for MSI/MSI-X
pcieport 0000:00:11.0: irq 91 for MSI/MSI-X
pcieport 0000:00:1c.0: irq 92 for MSI/MSI-X
pcieport 0000:00:1c.4: irq 93 for MSI/MSI-X
pcieport 0000:80:00.0: device [8086:3c01] has invalid IRQ; check vendor BIOS
pcieport 0000:80:00.0: irq 94 for MSI/MSI-X
pcieport 0000:80:01.0: irq 95 for MSI/MSI-X
pcieport 0000:80:01.1: irq 96 for MSI/MSI-X
pcieport 0000:80:02.0: irq 97 for MSI/MSI-X
pcieport 0000:80:02.2: irq 98 for MSI/MSI-X
pcieport 0000:80:03.0: irq 99 for MSI/MSI-X
pcieport 0000:00:01.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
pci 0000:11:00.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
pci 0000:16:00.0: Signaling PME through PCIe PME interrupt
pci 0000:16:00.1: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:11.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:11.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
pcieport 0000:01:00.0: Signaling PME through PCIe PME interrupt
pcieport 0000:02:00.0: Signaling PME through PCIe PME interrupt
pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
pci 0000:04:00.0: Signaling PME through PCIe PME interrupt
pcieport 0000:02:01.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:1c.4: Signaling PME through PCIe PME interrupt
pci 0000:06:00.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:1c.4:pcie01: service driver pcie_pme loaded
pcieport 0000:80:00.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:80:00.0:pcie01: service driver pcie_pme loaded
pcieport 0000:80:01.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:80:01.0:pcie01: service driver pcie_pme loaded
pcieport 0000:80:01.1: Signaling PME through PCIe PME interrupt
pcie_pme 0000:80:01.1:pcie01: service driver pcie_pme loaded
pcieport 0000:80:02.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:80:02.0:pcie01: service driver pcie_pme loaded
pcieport 0000:80:02.2: Signaling PME through PCIe PME interrupt
pcie_pme 0000:80:02.2:pcie01: service driver pcie_pme loaded
pcieport 0000:80:03.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:80:03.0:pcie01: service driver pcie_pme loaded
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
intel_idle: MWAIT substates: 0x21120
intel_idle: v0.4 model 0x2D
intel_idle: lapic_timer_reliable_states 0xffffffff
ipmi message handler version 39.2
IPMI System Interface driver.
ipmi_si: probing via SMBIOS
ipmi_si: SMBIOS: io 0xcc0 regsize 1 spacing 1 irq 0
ipmi_si: Adding SMBIOS-specified kcs state machine
ipmi_si: Trying SMBIOS-specified kcs state machine at i/o address 0xcc0, slave address 0x20, irq 0
ipmi_si ipmi_si.0: Found new BMC (man_id: 0x004f4d, prod_id: 0x0141, dev_id: 0x20)
ipmi_si ipmi_si.0: IPMI kcs interface initialized
input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input0
ACPI: Sleep Button [SLPB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ERST: Can not request [mem 0x7e90f000-0x7e910bff] for ERST.
GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
00:09: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
00:0a: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
tpm_tis 00:0b: 1.2 TPM (device-id 0xFE, rev-id 71)
brd: module loaded
loop: module loaded
libphy: Fixed MDIO Bus: probed
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci-pci: EHCI PCI platform driver
ehci-pci 0000:00:1a.0: EHCI Host Controller
ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
ehci-pci 0000:00:1a.0: debug port 2
ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
ehci-pci 0000:00:1a.0: irq 16, io mem 0xc5e01000
ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 3.15.0-rc3-freq-dblfix ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ehci-pci 0000:00:1d.0: EHCI Host Controller
ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
ehci-pci 0000:00:1d.0: debug port 2
ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
ehci-pci 0000:00:1d.0: irq 23, io mem 0xc5e00000
ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 3.15.0-rc3-freq-dblfix ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 8 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci-pci: OHCI PCI platform driver
uhci_hcd: USB Universal Host Controller Interface driver
i8042: PNP: No PS/2 controller found. Probing ports directly.
usb 1-1: new high-speed USB device number 2 using ehci-pci
usb 1-1: New USB device found, idVendor=8087, idProduct=0024
usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
hub 1-1:1.0: USB hub found
hub 1-1:1.0: 6 ports detected
usb 2-1: new high-speed USB device number 2 using ehci-pci
usb 2-1: New USB device found, idVendor=8087, idProduct=0024
usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
hub 2-1:1.0: USB hub found
hub 2-1:1.0: 8 ports detected
usb 2-1.1: new high-speed USB device number 3 using ehci-pci
i8042: Can't read CTR while initializing i8042
tsc: Refined TSC clocksource calibration: 2899.999 MHz
i8042: probe of i8042 failed with error -5
mousedev: PS/2 mouse device common for all mice
usb 2-1.1: New USB device found, idVendor=ffff, idProduct=0248
usb 2-1.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 2-1.1: Product: Gadget USB HUB
usb 2-1.1: Manufacturer: no manufacturer
usb 2-1.1: SerialNumber: 0123456789
hub 2-1.1:1.0: USB hub found
hub 2-1.1:1.0: 6 ports detected
rtc_cmos 00:02: RTC can wake from S4
rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
hidraw: raw HID events driver (C) Jiri Kosina
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
drop_monitor: Initializing network drop monitor service
TCP: cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
Loading compiled-in X.509 certificates
Loaded X.509 cert 'Magrathea: Glacier signing key: ec2e910cfe4cd6ba44144a69a3f347f97155aa21'
registered taskstats version 1
rtc_cmos 00:02: setting system clock to 2014-04-28 17:45:11 UTC (1398707111)
Freeing unused kernel memory: 1980K (ffffffff81b5a000 - ffffffff81d49000)
Write protecting the kernel read-only data: 10240k
Freeing unused kernel memory: 260K (ffff8800015bf000 - ffff880001600000)
Freeing unused kernel memory: 1328K (ffff8800018b4000 - ffff880001a00000)
dracut: dracut-0ivation
usb 2-1.1.5: new high-speed USB device number 4 using ehci-pci
udev: starting version 147
udevd (255): /proc/255/oom_adj is deprecated, please use /proc/255/oom_score_adj instead.
usb 2-1.1.5: device descriptor read/64, error -71
dracut: Starting plymouth daemon
raid_class: module verification failed: signature and/or  required key missing - tainting kernel
mpt2sas version 16.100.00.00 loaded
scsi0 : Fusion MPT SAS Host
mpt2sas0: 64 BIT PCI BUS DMA ADDRESSING SUPPORTED, total mem (132262556 kB)
mpt2sas 0000:06:00.0: irq 100 for MSI/MSI-X
mpt2sas0-msix0: PCI-MSI-X enabled: IRQ 100
mpt2sas0: iomem(0x00000000c5a40000), mapped(0xffffc9001e298000), size(16384)
mpt2sas0: ioport(0x0000000000001000), size(256)
usb 2-1.1.5: device descriptor read/64, error -71
mpt2sas0: Allocated physical memory: size(4235 kB)
mpt2sas0: Current Controller Queue Depth(1867), Max Controller Queue Depth(2040)
mpt2sas0: Scatter Gather Elements per IO(128)
mpt2sas0: LSISAS2004: FWVersion(10.00.11.00), ChipRevision(0x03), BiosVersion(07.19.00.00)
mpt2sas0: Protocol=(Initiator), Capabilities=(Raid,TLR,EEDP,Snapshot Buffer,Diag Trace Buffer,Task Set Full,NCQ)
mpt2sas0: sending port enable !!
usb 2-1.1.5: new high-speed USB device number 6 using ehci-pci
Switched to clocusb 2-1.1.5: New USB device found, idVendor=04b3, idProduct=4010
usb 2-1.1.5: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 2-1.1.5: Product: RNDIS/Ethernet Gadget
usb 2-1.1.5: Manufacturer: IBM
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
mpt2sas0: host_add: handle(0x0001), sas_addr(0x5005076056434d90), phys(4)
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
FATAL: Module scsi_wait_scan not found.
mpt2sas0: port enable: SUCCESS
scsi 0:1:0:0: Direct-Access     LSI      Logical Volume   3000 PQ: 0 ANSI: 6
scsi 0:1:0:0: RAID0: handle(0x00b5), wwid(0x02c5d3368a5aef06), pd_count(1), type(SSP)
scsi 0:1:0:0: qdepth(254), tagged(1), simple(0), ordered(0), scsi_level(7), cmd_que(1)
scsi 0:0:0:0: Direct-Access     IBM-ESXS ST9500620SS      BD2C PQ: 0 ANSI: 6
scsi 0:0:0:0: SSP: handle(0x0005), sas_addr(0x5000c500559ffab5), phy(0), device_name(0x5000c500559ffab4)
scsi 0:0:0:0: SSP: enclosure_logical_id(0x5005076056434d90), slot(0)
scsi 0:0:0:0: qdepth(254), tagged(1), simple(0), ordered(0), scsi_level(7), cmd_que(1)
sd 0:1:0:0: [sda] 974608384 512-byte logical blocks: (498 GB/464 GiB)
sd 0:1:0:0: [sda] Write Protect is off
sd 0:1:0:0: [sda] Mode Sense: 03 00 00 08
sd 0:1:0:0: [sda] No Caching mode page found
sd 0:1:0:0: [sda] Assuming drive cache: write through
 sda: sda1 sda2 sda3 sda4
sd 0:1:0:0: [sda] Attached SCSI disk
random: nonblocking pool is initialized
EXT4-fs (sda2): INFO: recovery required on readonly filesystem
EXT4-fs (sda2): write access will be enabled during recovery
EXT4-fs (sda2): recovery complete
EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
dracut: Mounted root filesystem /dev/sda2
dracut: Switching root
                Welcome to Red Hat Enterprise Linux Server
Starting udev: udev: starting version 147
WARNING! power/level is deprecated; use power/control instead
udevd-work[1140]: '/etc/init.d/kdump restart' unexpected exit with status 0x0006

logger[13445]: segfault at 50000000 ip 0000000050000000 sp 00007fff4735df28 error 14 in ld-2.12.so[3c8ca00000+20000]
traps: kdump[11939] general protection ip:42c6a4 sp:7fff7d1f6900 error:0 in bash[400000+d4000]
udevd-work[1359]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

kdump[12253]: segfault at 49 ip 000000000043b730 sp 00007fffb35bc268 error 4kdump[14181]: segfault at 59 ip 000000000043e5ff sp 00007fffb35bb290 error 4 in bash[400000+d4000]
kdump[13482]: segfault at 50000000 ip 00000000004387b3 sp 00007fffc4f8fe40 error 4 in bash[400000+d4000]

 in bash[400000+d4000]traps: kdump[11617] general protection ip:44014b sp:7fff2c7dc098 error:0 in bash[400000+d4000]

udevd-work[1418]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

udevd-work[3888]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

udevd-work[3679]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

kdump[11798]: segfault at 5000000c ip 000000000044ec51 sp 00007fff1b1b3370 error 4 in bash[400000+d4000]
kdump[14414]: segfault at 4ffffff8 ip 0000003c8d27bc0d sp 00007fff2cc39800 error 4traps: kdump[8856] general protection ip:3c8d27aaa9 sp:7fffcaf28158 error:0 in libc-2.12.so[3c8d200000+18a000]

udevd-work[4099] in libc-2.12.so[3c8d200000+18a000]: '/etc/init.d/k
dump restart' unexpected exit wikdump[10671]: segfault at 8 ip 000000000043b748 sp 00007fff0f2e9de8 error 4th status 0x000b in bash[400000+d4000]


device-mapper: uevent: version 1.0.3
udevd-work[1536]device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

udevd-work[2304]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

udevd-work[1111]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

udevd-work[1728]: '/etc/init.d/kdump restart' unexpected exit with status 0x0006

udevd-work[6407]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

udevd-work[1050]: '/etc/init.d/kdump restart' unexpected exit with status 0x000b

------------[ cut here ]------------
kernel BUG at mm/vmacache.c:85!
invalid opcode: 0000 [#1] SMP 
Modules linked in: dm_mod acpi_cpufreq(+) ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 13 PID: 8147 Comm: udevd Tainted: G            E 3.15.0-rc3-freq-dblfix #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
task: ffff8810372be810 ti: ffff881030eec000 task.ti: ffff881030eec000
RIP: 0010:[<ffffffff8116253a>]  [<ffffffff8116253a>] vmacache_find+0xaa/0xc0
RSP: 0000:ffff881030eedde8  EFLAGS: 00010286
RAX: ffff881034151690 RBX: 00007f53adcdaf00 RCX: 0000000000000001
RDX: 0000000000000001 RSI: 00007f53adcdaf00 RDI: ffff88103d5704c0
RBP: ffff881030eedde8 R08: ffff8810372be810 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000001fd3 R12: ffff88103d5704c0
R13: 00007f53ada65a40 R14: ffff881030eedf58 R15: ffff88103d5704c0
FS:  00007f53acf937a0(0000) GS:ffff88207fca0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f53adcdaf00 CR3: 000000103207a000 CR4: 00000000000407e0
Stack:
 ffff881030eede18 ffffffff8116ecd0 ffffffff815b3470 0000000000000246
 00000000000000a9 00007f53adcdaf00 ffff881030eedf38 ffffffff815b349b
 ffff881030eede58 ffffffff81099c8c 0000000000000002 ffff8810372be810
Call Trace:
 [<ffffffff8116ecd0>] find_vma+0x20/0x80
 [<ffffffff815b3470>] ? __do_page_fault+0x150/0x4d0
 [<ffffffff815b349b>] __do_page_fault+0x17b/0x4d0
 [<ffffffff81099c8c>] ? remove_wait_queue+0x3c/0x50
 [<ffffffff810540fc>] ? do_wait+0x14c/0x280
 [<ffffffff810542de>] ? SyS_wait4+0xae/0x100
 [<ffffffff812aebcd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff815b38ec>] do_page_fault+0xc/0x10
 [<ffffffff815afd92>] page_fault+0x22/0x30
Code: 0b 48 39 30 77 06 48 3b 70 08 72 15 83 c2 01 83 fa 04 75 dd 31 c0 eb 86 66 0f 1f 84 00 00 00 00 00 48 3b 78 40 0f 84 73 ff ff ff <0f> 0b 0f 1f 40 00 eb fa 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 
RIP  [<ffffffff8116253a>] vmacache_find+0xaa/0xc0
 RSP <ffff881030eedde8>
---[ end trace c9769a416ad4acd4 ]---
------------[ cut here ]------------
kernel BUG at mm/vmacache.c:85!
invalid opcode: 0000 [#2] SMP 
Modules linked in: dm_mod acpi_cpufreq(+) ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 13 PID: 8147 Comm: udevd Tainted: G      D     E 3.15.0-rc3-freq-dblfix #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
task: ffff8810372be810 ti: ffff881030eec000 task.ti: ffff881030eec000
RIP: 0010:[<ffffffff8116253a>]  [<ffffffff8116253a>] vmacache_find+0xaa/0xc0
RSP: 0000:ffff881030eed948  EFLAGS: 00010286
RAX: ffff881034151690 RBX: 0000000052000008 RCX: 0000000000000001
RDX: 0000000000000001 RSI: 0000000052000008 RDI: ffff88103d5704c0
RBP: ffff881030eed948 R08: ffff8810372be810 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000001fd3 R12: ffff88103d5704c0
R13: ffff88103ddeb9c0 R14: ffff881030eedab8 R15: ffff88103d5704c0
FS:  00007f53acf937a0(0000) GS:ffff88207fca0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000052000008 CR3: 000000103207a000 CR4: 00000000000407e0
Stack:
 ffff881030eed978 ffffffff8116ecd0 ffffffff815b3470 0000000000000246
 0000000000000028 0000000052000008 ffff881030eeda98 ffffffff815b349b
 ffffffff815b3970 ffffffff82605824 0000000000000000 ffff8810372be810
Call Trace:
 [<ffffffff8116ecd0>] find_vma+0x20/0x80
 [<ffffffff815b3470>] ? __do_page_fault+0x150/0x4d0
 [<ffffffff815b349b>] __do_page_fault+0x17b/0x4d0
 [<ffffffff815b3970>] ? notifier_call_chain+0x80/0x80
 [<ffffffff81081c18>] ? finish_task_switch+0x48/0x120
 [<ffffffff81081c55>] ? finish_task_switch+0x85/0x120
 [<ffffffff810794a1>] ? lock_hrtimer_base+0x31/0x60
 [<ffffffff812aebcd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff815b38ec>] do_page_fault+0xc/0x10
 [<ffffffff815afd92>] page_fault+0x22/0x30
 [<ffffffff810dbd60>] ? acct_collect+0x60/0x1b0
 [<ffffffff810dbd4b>] ? acct_collect+0x4b/0x1b0
 [<ffffffff810531e5>] do_exit+0x355/0x490
 [<ffffffff815b0991>] oops_end+0xa1/0xf0
 [<ffffffff81006f9b>] die+0x5b/0x90
 [<ffffffff815b04c3>] do_trap+0xc3/0x170
 [<ffffffff81004825>] ? do_invalid_op+0xa5/0xb0
 [<ffffffff81004815>] do_invalid_op+0x95/0xb0
 [<ffffffff8116253a>] ? vmacache_find+0xaa/0xc0
 [<ffffffff812aebcd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff815afb8c>] ? restore_args+0x30/0x30
 [<ffffffff815b9cf8>] invalid_op+0x18/0x20
 [<ffffffff8116253a>] ? vmacache_find+0xaa/0xc0
 [<ffffffff8116ecd0>] find_vma+0x20/0x80
 [<ffffffff815b3470>] ? __do_page_fault+0x150/0x4d0
 [<ffffffff815b349b>] __do_page_fault+0x17b/0x4d0
 [<ffffffff81099c8c>] ? remove_wait_queue+0x3c/0x50
 [<ffffffff810540fc>] ? do_wait+0x14c/0x280
 [<ffffffff810542de>] ? SyS_wait4+0xae/0x100
 [<ffffffff812aebcd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff815b38ec>] do_page_fault+0xc/0x10
 [<ffffffff815afd92>] page_fault+0x22/0x30
Code: 0b 48 39 30 77 06 48 3b 70 08 72 15 83 c2 01 83 fa 04 75 dd 31 c0 eb 86 66 0f 1f 84 00 00 00 00 00 48 3b 78 40 0f 84 73 ff ff ff <0f> 0b 0f 1f 40 00 eb fa 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 
RIP  [<ffffffff8116253a>] vmacache_find+0xaa/0xc0
 RSP <ffff881030eed948>
---[ end trace c9769a416ad4acd5 ]---
Fixing recursive fault but reboot is needed!
mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
mlx4_core: Initializing 0000:11:00.0
mlx4_core 0000:11:00.0: PCIe link speed is 8.0GT/s, device supports 8.0GT/s
mlx4_core 0000:11:00.0: PCIe link width is x8, device supports x8
mlx4_core 0000:11:00.0: irq 101 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 102 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 103 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 104 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 105 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 106 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 107 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 108 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 109 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 110 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 111 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 112 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 113 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 114 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 115 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 116 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 117 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 118 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 119 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 120 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 121 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 122 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 123 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 124 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 125 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 126 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 127 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 128 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 129 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 130 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 131 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 132 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 133 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 134 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 135 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 136 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 137 for MSI/MSI-X
mlx4_core 0000:11:00.0: irq 138 for MSI/MSI-X
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
dca service started, version 1.12.1
PTP clock support registered
mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.2-1 (Feb 2014)
ioatdma: Intel(R) QuickData Technology Driver 4.00
mlx4_en 0000:11:00.0: Activating port:1
ioatdma 0000:00:04.0: irq 139 for MSI/MSI-X
ioatdma 0000:00:04.1: irq 140 for MSI/MSI-X
ioatdma 0000:00:04.2: irq 141 for MSI/MSI-X
ioatdma 0000:00:04.3: irq 142 for MSI/MSI-X
ioatdma 0000:00:04.4: irq 143 for MSI/MSI-X
ioatdma 0000:00:04.5: irq 144 for MSI/MSI-X
ioatdma 0000:00:04.6: irq 145 for MSI/MSI-X
ioatdma 0000:00:04.7: irq 146 for MSI/MSI-X
ioatdma 0000:80:04.0: irq 147 for MSI/MSI-X
ioatdma 0000:80:04.1: irq 148 for MSI/MSI-X
ioatdma 0000:80:04.2: irq 149 for MSI/MSI-X
ioatdma 0000:80:04.3: irq 150 for MSI/MSI-X
ioatdma 0000:80:04.4: irq 151 for MSI/MSI-X
ioatdma 0000:80:04.5: irq 152 for MSI/MSI-X
ioatdma 0000:80:04.6: irq 153 for MSI/MSI-X
ioatdma 0000:80:04.7: irq 154 for MSI/MSI-X
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
mlx4_en: eth0: Using 256 TX rings
mlx4_en: eth0: Using 8 RX rings
mlx4_en: eth0:   frag:0 - size:1526 prefix:0 align:0 stride:1536
mlx4_en: eth0: Initializing port
mlx4_en 0000:11:00.0: Activating port:2
mlx4_en: eth1: Using 256 TX rings
mlx4_en: eth1: Using 8 RX rings
mlx4_en: eth1:   frag:0 - size:1526 prefix:0 align:0 stride:1536
mlx4_en: eth1: Initializing port
show_signal_msg: 7 callbacks suppressed
udevd[1056]: segfault at 10 ip 00007f53acfba0ca sp 00007fffd4039d10 error 4udevd[7746]: segfault at 7fffd403c730 ip 00007f53acfc3697 sp 00007fffd403c6c0 error 7 in udevd[7f53acfb0000+1f000]
general protection fault: 0000 [#3] SMP 
Modules linked in: i2c_core lpc_ich mfd_core shpchp ioatdma mlx4_en ptp dca pps_core mlx4_core dm_mod acpi_cpufreq ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 0 PID: 7746 Comm: udevd Tainted: G      D     E 3.15.0-rc3-freq-dblfix #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
task: ffff88103de4c0d0 ti: ffff881031bd6000 task.ti: ffff881031bd6000
RIP: 0010:[<ffffffff810dbd60>]  [<ffffffff810dbd60>] acct_collect+0x60/0x1b0
RSP: 0000:ffff881031bd7d18  EFLAGS: 00010282
RAX: 9e00000005f9e8fd RBX: 000000000000000b RCX: 0000000000000001
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff881033a6f6e8
RBP: ffff881031bd7d38 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000001e42 R12: 0000000000cb0000
R13: ffff88103dd54b80 R14: ffff88103de4c0d0 R15: ffff88103582e348
FS:  00007f53acf937a0(0000) GS:ffff88107fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fffd403c730 CR3: 0000001033a12000 CR4: 00000000000407f0
Stack:
 ffff88103de4c0d0 ffff88103de4cc18 000000000000000b 0000000000000001
 ffff881031bd7d78 ffffffff810531e5 00000000000000cd 0000000000000000
 000000000000000b ffff88103de4c0d0 ffff88103dd54b80 ffff88103de4c0d0
Call Trace:
 [<ffffffff810531e5>] do_exit+0x355/0x490
 [<ffffffff8105337e>] do_group_exit+0x5e/0xd0
 [<ffffffff810654be>] get_signal_to_deliver+0x22e/0x470
 [<ffffffff810039ab>] do_signal+0x4b/0x140
 [<ffffffff815a9b02>] ? printk+0x4d/0x4f
 [<ffffffff81061563>] ? __set_current_blocked+0x53/0x60
 [<ffffffff81003b05>] do_notify_resume+0x65/0x90
 [<ffffffff812aeb8e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff815afc02>] retint_signal+0x46/0x84
Code: 00 74 58 49 8b be 78 07 00 00 48 81 c7 98 00 00 00 e8 95 21 4d 00 49 8b 86 78 07 00 00 48 8b 00 48 85 c0 74 16 66 0f 1f 44 00 00 <4c> 03 60 08 4c 2b 20 48 8b 40 10 48 85 c0 75 f0 65 48 8b 04 25 
RIP  [<ffffffff810dbd60>] acct_collect+0x60/0x1b0
 RSP <ffff881031bd7d18>
---[ end trace c9769a416ad4acd6 ]---
Fixing recursive fault but reboot is needed!
general protection fault: 0000 [#4] SMP 
Modules linked in: i2c_core lpc_ich mfd_core shpchp ioatdma mlx4_en ptp dca pps_core mlx4_core dm_mod acpi_cpufreq ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 2 PID: 895 Comm: udevd Tainted: G      D     E 3.15.0-rc3-freq-dblfix #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
task: ffff88203de22890 ti: ffff88203ebf6000 task.ti: ffff88203ebf6000
RIP: 0010:[<ffffffff81162b64>]  [<ffffffff81162b64>] vma_interval_tree_insert_after+0x34/0x90
RSP: 0018:ffff88203ebf7d50  EFLAGS: 00010282
RAX: 9e00000005f9e5fd RBX: ffff881031a0c2f8 RCX: ffff88203d52ba40
RDX: 000000000000001e RSI: 9e00000005f9e5a5 RDI: ffff881031a0c2f8
RBP: ffff88203ebf7d50 R08: ffff882077c8b358 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff882077c8b2f8
R13: ffff88103d734ec0 R14: ffff881034054e78 R15: ffff881034054e88
FS:  00007f53acf937a0(0000) GS:ffff88107fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f53addc9000 CR3: 000000203e889000 CR4: 00000000000407e0
Stack:
 ffff88203ebf7dd0 ffffffff8104e549 ffff88203dd76998 ffff88203d52b9e8
 ffff88203dd76998 ffff88103d734f58 ffff88203dd76900 ffff881034054e98
 ffff881034054ea0 ffff88203d52ba58 ffff88103d734ec0 ffff88103d734ec0
Call Trace:
 [<ffffffff8104e549>] dup_mmap+0x209/0x3f0
 [<ffffffff8104ec3c>] dup_mm+0xcc/0x170
 [<ffffffff8105009c>] copy_process+0x122c/0x1260
 [<ffffffff814c6bc9>] ? release_sock+0x99/0xa0
 [<ffffffff81055ded>] ? __local_bh_enable_ip+0x6d/0xd0
 [<ffffffff81050581>] do_fork+0x61/0x220
 [<ffffffff814c6ecb>] ? sock_setsockopt+0xbb/0x740
 [<ffffffff815af56b>] ? _raw_spin_unlock+0x2b/0x40
 [<ffffffff81050756>] SyS_clone+0x16/0x20
 [<ffffffff815b89b9>] stub_clone+0x69/0x90
 [<ffffffff815b8612>] ? system_call_fastpath+0x16/0x1b
Code: 48 8b 47 08 48 2b 07 48 89 d1 48 8b 97 98 00 00 00 4c 8d 46 60 48 c1 e8 0c 48 8d 54 02 ff 48 8b 46 60 48 85 c0 74 1b 48 8d 70 a8 <48> 39 56 70 73 04 48 89 56 70 48 8b 46 68 48 85 c0 75 e9 4c 8d 
RIP  [<ffffffff81162b64>] vma_interval_tree_insert_after+0x34/0x90
 RSP <ffff88203ebf7d50>
---[ end trace c9769a416ad4acd7 ]---
udevd[5534]: segfault at 7fffd3841fa0 ip 00007f53ac84c447 sp 00007fffd3841930 error 6 in libc-2.12.so[7f53ac7dc000+18a000]
udevd[5526]: segfault at 7fffd3841fa0 ip 00007f53ac84c447 sp 00007fffd3841930 error 6 in libc-2.12.so[7f53ac7dc000+18a000]
i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
udevd[10197]: segfault at 7f53add10418 ip 00007f53ac855d5d sp 00007fffd403ddb0 error 6 in libc-2.12.so[7f53ac7dc000+18a000]
BUG: unable to handle kernel paging request at 0000000052000008
IP: [<ffffffff810dbd60>] acct_collect+0x60/0x1b0
PGD 0 
Oops: 0000 [#5] SMP 
Modules linked in: i2c_i801 i2c_core lpc_ich mfd_core shpchp ioatdma mlx4_en ptp dca pps_core mlx4_core dm_mod acpi_cpufreq ext4(E) jbd2(E) mbcache(E) sd_mod(E) crc_t10dif(E) crct10dif_common(E) mpt2sas(E) scsi_transport_sas(E) raid_class(E)
CPU: 6 PID: 10197 Comm: udevd Tainted: G      D     E 3.15.0-rc3-freq-dblfix #1
Hardware name: IBM  -[8737R2A]-/00AE502, BIOS -[B2E120QUS-1.20]- 11/14/2012
task: ffff881038ada410 ti: ffff88103020e000 task.ti: ffff88103020e000
RIP: 0010:[<ffffffff810dbd60>]  [<ffffffff810dbd60>] acct_collect+0x60/0x1b0
RSP: 0000:ffff88103020fd18  EFLAGS: 00010206
RAX: 0000000052000000 RBX: 000000000000000b RCX: 0000000000000001
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff881034c5e568
RBP: ffff88103020fd38 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 00000000000027d5 R12: 9e000000069d62fd
R13: ffff88103d60a100 R14: ffff881038ada410 R15: ffff881034fd9548
FS:  00007f53acf937a0(0000) GS:ffff88107fcc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000052000008 CR3: 0000001030194000 CR4: 00000000000407e0
Stack:
 ffff881038ada410 ffff881038adaf58 000000000000000b 0000000000000001
 ffff88103020fd78 ffffffff810531e5 00000000000000cd 0000000000000000
 000000000000000b ffff881038ada410 ffff88103d60a100 ffff881038ada410
Call Trace:
 [<ffffffff810531e5>] do_exit+0x355/0x490
 [<ffffffff8105337e>] do_group_exit+0x5e/0xd0
 [<ffffffff810654be>] get_signal_to_deliver+0x22e/0x470
 [<ffffffff810039ab>] do_signal+0x4b/0x140
 [<ffffffff815a9b02>] ? printk+0x4d/0x4f
 [<ffffffff815af56b>] ? _raw_spin_unlock+0x2b/0x40
 [<ffffffff81003b05>] do_notify_resume+0x65/0x90
 [<ffffffff812aeb8e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff815afc02>] retint_signal+0x46/0x84
Code: 00 74 58 49 8b be 78 07 00 00 48 81 c7 98 00 00 00 e8 95 21 4d 00 49 8b 86 78 07 00 00 48 8b 00 48 85 c0 74 16 66 0f 1f 44 00 00 <4c> 03 60 08 4c 2b 20 48 8b 40 10 48 85 c0 75 f0 65 48 8b 04 25 
RIP  [<ffffffff810dbd60>] acct_collect+0x60/0x1b0
 RSP <ffff88103020fd18>
CR2: 0000000052000008
---[ end trace c9769a416ad4acd8 ]---
Fixing recursive fault but reboot is needed!

 in udevd[7f53acfb0000+1f000]
mlx4_en: eth0: Link Up


Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
