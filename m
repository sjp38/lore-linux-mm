Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id AD41C6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 04:44:36 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so1548185pbc.27
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 01:44:36 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id l8si426521pao.297.2014.02.06.01.44.34
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 01:44:35 -0800 (PST)
Date: Thu, 6 Feb 2014 17:44:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: WARNING: at arch/x86/kernel/smpboot.c:324 topology_sane()
Message-ID: <20140206094428.GC17971@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Tang,

We noticed the below warning and the first bad commit is

commit e8d1955258091e4c92d5a975ebd7fd8a98f5d30f
Author:     Tang Chen <tangchen@cn.fujitsu.com>
AuthorDate: Fri Feb 22 16:33:44 2013 -0800
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Sat Feb 23 17:50:14 2013 -0800

    acpi, memory-hotplug: parse SRAT before memblock is ready
    
 arch/x86/kernel/setup.c | 13 +++++++++----
 arch/x86/mm/numa.c      |  6 ++++--
 drivers/acpi/numa.c     | 23 +++++++++++++----------
 include/linux/acpi.h    |  8 ++++++++
 4 files changed, 34 insertions(+), 16 deletions(-)

[    0.845092] smpboot: Booting Node   1, Processors  #1
[    0.864812] masked ExtINT on CPU#1
[    0.868706] CPU1: Thermal LVT vector (0xfa) already installed
[    0.875158] ------------[ cut here ]------------
[    0.880330] WARNING: at arch/x86/kernel/smpboot.c:324 topology_sane.isra.2+0x6b/0x7c()
[    0.891505] Hardware name: S2600CP
[    0.895314] sched: CPU #1's llc-sibling CPU #0 is not on the same node! [node: 1 != 0]. Ignoring dependency.

[    0.906295] Modules linked in:
[    0.909927] Pid: 0, comm: swapper/1 Not tainted 3.8.0-06530-ge8d1955 #1
[    0.917314] Call Trace:
[    0.920055]  [<ffffffff81970409>] ? topology_sane.isra.2+0x6b/0x7c
[    0.926963]  [<ffffffff810bcd5d>] warn_slowpath_common+0x81/0x99
[    0.933667]  [<ffffffff810bcdc1>] warn_slowpath_fmt+0x4c/0x4e
[    0.940092]  [<ffffffff8196b565>] ? calibrate_delay+0xae/0x4ba
[    0.946612]  [<ffffffff810508ea>] ? __mcheck_cpu_init_timer+0x4a/0x4f
[    0.953799]  [<ffffffff81970409>] topology_sane.isra.2+0x6b/0x7c
[    0.960509]  [<ffffffff819706e0>] set_cpu_sibling_map+0x28c/0x43a
[    0.967308]  [<ffffffff81970a3c>] start_secondary+0x1ae/0x276
[    0.973742] ---[ end trace db722b2086ba6d20 ]---
[    0.999234]  OK
[    1.001655] smpboot: Booting Node   0, Processors  #2

Full dmesg and kconfig are attached.

Thanks,
Fengguang

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".dmesg"

[    0.000000] Linux version 3.8.0-06530-ge8d1955 (kbuild@xian) (gcc version 4.8.1 (Debian 4.8.1-8) ) #1 SMP Wed Feb 5 08:04:04 CST 2014
[    0.000000] Command line: user=lkp job=/lkp/scheduled/lkp-snb01/bisect_aim7-shared-x86_64-lkp-e8d1955258091e4c92d5a975ebd7fd8a98f5d30f-0.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/vmlinuz-3.8.0-06530-ge8d1955 kconfig=x86_64-lkp commit=e8d1955258091e4c92d5a975ebd7fd8a98f5d30f bm_initrd=/lkp/benchmarks/aim7.cgz modules_initrd=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/modules.cgz max_uptime=695 RESULT_ROOT=/lkp/result/lkp-snb01/micro/aim7/shared/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/0 initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 ip=::::lkp-snb01::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x00000000000907ff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000090800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000b9678fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000b9679000-0x00000000b96f3fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000b96f4000-0x00000000b97e9fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000b97ea000-0x00000000b99ecfff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000b99ed000-0x00000000bac8bfff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bac8c000-0x00000000bac99fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000bac9a000-0x00000000bda00fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bda01000-0x00000000bdc00fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdc01000-0x00000000bdcdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bdce0000-0x00000000bdde6fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000bdde7000-0x00000000bde81fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bde82000-0x00000000bde82fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bde83000-0x00000000bdefafff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdefb000-0x00000000bdefbfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bdefc000-0x00000000bdefdfff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdefe000-0x00000000bdefefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bdeff000-0x00000000bdefffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdf00000-0x00000000bdf1afff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bdf1b000-0x00000000bdfa7fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdfa8000-0x00000000bdffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000be000000-0x00000000cfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed19000-0x00000000fed19fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffa20000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000083fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: Intel Corporation S2600CP/S2600CP, BIOS SE5C600.86B.99.99.x036.091920111209 09/19/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x840000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-through
[    0.000000]   D4000-D7FFF write-protect
[    0.000000]   D8000-E7FFF uncachable
[    0.000000]   E8000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask 3FFF80000000 write-back
[    0.000000]   1 base 000080000000 mask 3FFFC0000000 write-back
[    0.000000]   2 base 000100000000 mask 3FFF00000000 write-back
[    0.000000]   3 base 000200000000 mask 3FFE00000000 write-back
[    0.000000]   4 base 000400000000 mask 3FFC00000000 write-back
[    0.000000]   5 base 000800000000 mask 3FFFC0000000 write-back
[    0.000000]   6 base 0000FF800000 mask 3FFFFF800000 write-protect
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
[    0.000000] e820: last_pfn = 0xbe000 max_arch_pfn = 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fccc0-0x000fcccf] mapped at [ffff8800000fccc0]
[    0.000000]   mpc: fc770-fcbbc
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] ACPI: RSDP 00000000000f0410 00024 (v02 INTEL )
[    0.000000] ACPI: XSDT 00000000bdf18d98 000BC (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: FACP 00000000bdf18918 000F4 (v04 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI BIOS Bug: Warning: Invalid length for FADT/Pm1aControlBlock: 32, using default 16 (20130117/tbfadt-649)
[    0.000000] ACPI: DSDT 00000000bdf00018 168AA (v02 INTEL   S2600CP 00000099 INTL 20100331)
[    0.000000] ACPI: FACS 00000000bdf18f40 00040
[    0.000000] ACPI: APIC 00000000bdf17718 0066A (v03 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SPMI 00000000bdf1ab98 00040 (v05 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: MCFG 00000000bdf1ab18 0003C (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: WDDT 00000000bdf1af18 00040 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SRAT 00000000bdefec18 002A8 (v03 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SLIT 00000000bdf1ae98 00030 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: MSCT 00000000bdf19e18 00090 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: HPET 00000000bdf1ae18 00038 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SSDT 00000000bdf1ad18 0002B (v02 INTEL   S2600CP 00001000 INTL 20100331)
[    0.000000] ACPI: SSDT 00000000b9679018 7A0C4 (v02 INTEL   S2600CP 00004000 INTL 20100331)
[    0.000000] ACPI: DMAR 00000000bdf18618 00150 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: HEST 00000000bde82f18 000A8 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: BERT 00000000bdf1ad98 00030 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: ERST 00000000bde82c98 00230 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: EINJ 00000000bdf18c18 00130 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: SSDT 00000000bdefb018 00F98 (v02 INTEL   S2600CP 00000002 INTL 20100331)
[    0.000000] ACPI: SSDT 00000000bdf1ac98 00045 (v02 INTEL   S2600CP 00000001 INTL 20100331)
[    0.000000] ACPI: SSDT 00000000bdf17e18 00181 (v02 INTEL   S2600CP 00000003 INTL 20100331)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0e -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0f -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x26 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x27 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x28 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x29 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2e -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2f -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0xbfffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x43fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x440000000-0x83fffffff]
[    0.000000] Base memory trampoline at [ffff88000008a000] 8a000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02206000, 0x02206fff] PGTABLE
[    0.000000] BRK [0x02207000, 0x02207fff] PGTABLE
[    0.000000] BRK [0x02208000, 0x02208fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x83fe00000-0x83fffffff]
[    0.000000]  [mem 0x83fe00000-0x83fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x83c000000-0x83fdfffff]
[    0.000000]  [mem 0x83c000000-0x83fdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x800000000-0x83bffffff]
[    0.000000]  [mem 0x800000000-0x83bffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0xb9678fff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0x7fffffff] page 1G
[    0.000000]  [mem 0x80000000-0xb95fffff] page 2M
[    0.000000]  [mem 0xb9600000-0xb9678fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xb96f4000-0xb97e9fff]
[    0.000000]  [mem 0xb96f4000-0xb97e9fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xb99ed000-0xbac8bfff]
[    0.000000]  [mem 0xb99ed000-0xb99fffff] page 4k
[    0.000000]  [mem 0xb9a00000-0xbabfffff] page 2M
[    0.000000]  [mem 0xbac00000-0xbac8bfff] page 4k
[    0.000000] BRK [0x02209000, 0x02209fff] PGTABLE
[    0.000000] BRK [0x0220a000, 0x0220afff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xbac9a000-0xbda00fff]
[    0.000000]  [mem 0xbac9a000-0xbadfffff] page 4k
[    0.000000]  [mem 0xbae00000-0xbd9fffff] page 2M
[    0.000000]  [mem 0xbda00000-0xbda00fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xbdc01000-0xbdcdffff]
[    0.000000]  [mem 0xbdc01000-0xbdcdffff] page 4k
[    0.000000] init_memory_mapping: [mem 0xbdfa8000-0xbdffffff]
[    0.000000]  [mem 0xbdfa8000-0xbdffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x7ffffffff]
[    0.000000]  [mem 0x100000000-0x7ffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x72fc8000-0x7fff2fff]
[    0.000000] NUMA: Initialized distance table, cnt=2
[    0.000000] NUMA: Node 0 [mem 0x00000000-0xbfffffff] + [mem 0x100000000-0x43fffffff] -> [mem 0x00000000-0x43fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x43fffffff]
[    0.000000]   NODE_DATA [mem 0x43fffb000-0x43fffffff]
[    0.000000] Initmem setup node 1 [mem 0x440000000-0x83fffffff]
[    0.000000]   NODE_DATA [mem 0x83fff5000-0x83fff9fff]
[    0.000000]  [ffffea0000000000-ffffea0010ffffff] PMD -> [ffff88042fe00000-ffff88043fdfffff] on node 0
[    0.000000]  [ffffea0011000000-ffffea0020ffffff] PMD -> [ffff88082f600000-ffff88083f5fffff] on node 1
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x83fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0008ffff]
[    0.000000]   node   0: [mem 0x00100000-0xb9678fff]
[    0.000000]   node   0: [mem 0xb96f4000-0xb97e9fff]
[    0.000000]   node   0: [mem 0xb99ed000-0xbac8bfff]
[    0.000000]   node   0: [mem 0xbac9a000-0xbda00fff]
[    0.000000]   node   0: [mem 0xbdc01000-0xbdcdffff]
[    0.000000]   node   0: [mem 0xbdfa8000-0xbdffffff]
[    0.000000]   node   0: [mem 0x100000000-0x43fffffff]
[    0.000000]   node   1: [mem 0x440000000-0x83fffffff]
[    0.000000] On node 0 totalpages: 4184123
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3898 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 12067 pages used for memmap
[    0.000000]   DMA32 zone: 760201 pages, LIFO batch:31
[    0.000000]   Normal zone: 53248 pages used for memmap
[    0.000000]   Normal zone: 3354624 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 4194304
[    0.000000]   Normal zone: 65536 pages used for memmap
[    0.000000]   Normal zone: 4128768 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] ACPI: X2APIC (apic_id[0x00] uid[0x00] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x01] uid[0x01] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x02] uid[0x02] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x03] uid[0x03] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x04] uid[0x04] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x05] uid[0x05] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x06] uid[0x06] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x07] uid[0x07] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x08] uid[0x08] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x09] uid[0x09] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0a] uid[0x0a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0b] uid[0x0b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0c] uid[0x0c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0d] uid[0x0d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0e] uid[0x0e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0f] uid[0x0f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x10] uid[0x10] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x11] uid[0x11] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x12] uid[0x12] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x13] uid[0x13] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x14] uid[0x14] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x15] uid[0x15] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x16] uid[0x16] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x17] uid[0x17] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x18] uid[0x18] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x19] uid[0x19] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1a] uid[0x1a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1b] uid[0x1b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1c] uid[0x1c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1d] uid[0x1d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1e] uid[0x1e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1f] uid[0x1f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x20] uid[0x20] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x21] uid[0x21] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x22] uid[0x22] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x23] uid[0x23] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x24] uid[0x24] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x25] uid[0x25] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x26] uid[0x26] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x27] uid[0x27] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x28] uid[0x28] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x29] uid[0x29] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2a] uid[0x2a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2b] uid[0x2b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2c] uid[0x2c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2d] uid[0x2d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2e] uid[0x2e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2f] uid[0x2f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x30] uid[0x30] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x31] uid[0x31] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x32] uid[0x32] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x33] uid[0x33] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x34] uid[0x34] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x35] uid[0x35] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x36] uid[0x36] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x37] uid[0x37] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x38] uid[0x38] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x39] uid[0x39] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3a] uid[0x3a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3b] uid[0x3b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3c] uid[0x3c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3d] uid[0x3d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3e] uid[0x3e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3f] uid[0x3f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x08] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x0a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x0c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x0e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x20] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x22] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x24] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x26] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x28] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x2a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x2c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x2e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x09] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x0b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x0d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x0f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x21] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x23] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x25] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x27] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x29] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x2b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x2d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x2f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x21] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x22] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x23] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x24] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x25] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x26] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x27] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x28] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x29] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2a] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2b] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2c] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2d] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2e] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2f] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x30] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x31] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x32] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x33] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x34] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x35] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x36] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x37] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x38] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x39] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3a] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3b] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3c] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3d] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3e] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3f] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec3f000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 1, version 32, address 0xfec3f000, GSI 24-47
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec7f000] gsi_base[48])
[    0.000000] IOAPIC[2]: apic_id 2, version 32, address 0xfec7f000, GSI 48-71
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 0, APIC INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 0, APIC INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 0, APIC INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 64 CPUs, 32 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec3f000)
[    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec7f000)
[    0.000000] nr_irqs_gsi: 88
[    0.000000] PM: Registered nosave memory: 0000000000090000 - 0000000000091000
[    0.000000] PM: Registered nosave memory: 0000000000091000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000b9679000 - 00000000b96f4000
[    0.000000] PM: Registered nosave memory: 00000000b97ea000 - 00000000b99ed000
[    0.000000] PM: Registered nosave memory: 00000000bac8c000 - 00000000bac9a000
[    0.000000] PM: Registered nosave memory: 00000000bda01000 - 00000000bdc01000
[    0.000000] PM: Registered nosave memory: 00000000bdce0000 - 00000000bdde7000
[    0.000000] PM: Registered nosave memory: 00000000bdde7000 - 00000000bde82000
[    0.000000] PM: Registered nosave memory: 00000000bde82000 - 00000000bde83000
[    0.000000] PM: Registered nosave memory: 00000000bde83000 - 00000000bdefb000
[    0.000000] PM: Registered nosave memory: 00000000bdefb000 - 00000000bdefc000
[    0.000000] PM: Registered nosave memory: 00000000bdefc000 - 00000000bdefe000
[    0.000000] PM: Registered nosave memory: 00000000bdefe000 - 00000000bdeff000
[    0.000000] PM: Registered nosave memory: 00000000bdeff000 - 00000000bdf00000
[    0.000000] PM: Registered nosave memory: 00000000bdf00000 - 00000000bdf1b000
[    0.000000] PM: Registered nosave memory: 00000000bdf1b000 - 00000000bdfa8000
[    0.000000] PM: Registered nosave memory: 00000000be000000 - 00000000d0000000
[    0.000000] PM: Registered nosave memory: 00000000d0000000 - 00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
[    0.000000] PM: Registered nosave memory: 00000000fec01000 - 00000000fed19000
[    0.000000] PM: Registered nosave memory: 00000000fed19000 - 00000000fed1a000
[    0.000000] PM: Registered nosave memory: 00000000fed1a000 - 00000000fed1c000
[    0.000000] PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
[    0.000000] PM: Registered nosave memory: 00000000fed20000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ffa20000
[    0.000000] PM: Registered nosave memory: 00000000ffa20000 - 0000000100000000
[    0.000000] e820: [mem 0xd0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:64 nr_node_ids:2
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88042fa00000 s80384 r8192 d22016 u131072
[    0.000000] pcpu-alloc: s80384 r8192 d22016 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 02 04 06 08 10 12 14 16 18 20 22 24 26 28 30 
[    0.000000] pcpu-alloc: [0] 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 
[    0.000000] pcpu-alloc: [1] 01 03 05 07 09 11 13 15 17 19 21 23 25 27 29 31 
[    0.000000] pcpu-alloc: [1] 33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 8247491
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: user=lkp job=/lkp/scheduled/lkp-snb01/bisect_aim7-shared-x86_64-lkp-e8d1955258091e4c92d5a975ebd7fd8a98f5d30f-0.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/vmlinuz-3.8.0-06530-ge8d1955 kconfig=x86_64-lkp commit=e8d1955258091e4c92d5a975ebd7fd8a98f5d30f bm_initrd=/lkp/benchmarks/aim7.cgz modules_initrd=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/modules.cgz max_uptime=695 RESULT_ROOT=/lkp/result/lkp-snb01/micro/aim7/shared/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/0 initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 ip=::::lkp-snb01::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 32684308k/34603008k available (9803k kernel code, 1089300k absent, 829400k reserved, 5648k data, 1260k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=64, Nodes=2
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=64.
[    0.000000] NR_IRQS:33024 nr_irqs:2008 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.8.0-06530-ge8d1955 (kbuild@xian) (gcc version 4.8.1 (Debian 4.8.1-8) ) #1 SMP Wed Feb 5 08:04:04 CST 2014
[    0.000000] Command line: user=lkp job=/lkp/scheduled/lkp-snb01/bisect_aim7-shared-x86_64-lkp-e8d1955258091e4c92d5a975ebd7fd8a98f5d30f-0.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/vmlinuz-3.8.0-06530-ge8d1955 kconfig=x86_64-lkp commit=e8d1955258091e4c92d5a975ebd7fd8a98f5d30f bm_initrd=/lkp/benchmarks/aim7.cgz modules_initrd=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/modules.cgz max_uptime=695 RESULT_ROOT=/lkp/result/lkp-snb01/micro/aim7/shared/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/0 initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 ip=::::lkp-snb01::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x00000000000907ff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000090800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000b9678fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000b9679000-0x00000000b96f3fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000b96f4000-0x00000000b97e9fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000b97ea000-0x00000000b99ecfff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000b99ed000-0x00000000bac8bfff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bac8c000-0x00000000bac99fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000bac9a000-0x00000000bda00fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bda01000-0x00000000bdc00fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdc01000-0x00000000bdcdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bdce0000-0x00000000bdde6fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000bdde7000-0x00000000bde81fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bde82000-0x00000000bde82fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bde83000-0x00000000bdefafff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdefb000-0x00000000bdefbfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bdefc000-0x00000000bdefdfff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdefe000-0x00000000bdefefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bdeff000-0x00000000bdefffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdf00000-0x00000000bdf1afff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bdf1b000-0x00000000bdfa7fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bdfa8000-0x00000000bdffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000be000000-0x00000000cfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed19000-0x00000000fed19fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffa20000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000083fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: Intel Corporation S2600CP/S2600CP, BIOS SE5C600.86B.99.99.x036.091920111209 09/19/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x840000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-through
[    0.000000]   D4000-D7FFF write-protect
[    0.000000]   D8000-E7FFF uncachable
[    0.000000]   E8000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask 3FFF80000000 write-back
[    0.000000]   1 base 000080000000 mask 3FFFC0000000 write-back
[    0.000000]   2 base 000100000000 mask 3FFF00000000 write-back
[    0.000000]   3 base 000200000000 mask 3FFE00000000 write-back
[    0.000000]   4 base 000400000000 mask 3FFC00000000 write-back
[    0.000000]   5 base 000800000000 mask 3FFFC0000000 write-back
[    0.000000]   6 base 0000FF800000 mask 3FFFFF800000 write-protect
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
[    0.000000] e820: last_pfn = 0xbe000 max_arch_pfn = 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fccc0-0x000fcccf] mapped at [ffff8800000fccc0]
[    0.000000]   mpc: fc770-fcbbc
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] ACPI: RSDP 00000000000f0410 00024 (v02 INTEL )
[    0.000000] ACPI: XSDT 00000000bdf18d98 000BC (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: FACP 00000000bdf18918 000F4 (v04 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI BIOS Bug: Warning: Invalid length for FADT/Pm1aControlBlock: 32, using default 16 (20130117/tbfadt-649)
[    0.000000] ACPI: DSDT 00000000bdf00018 168AA (v02 INTEL   S2600CP 00000099 INTL 20100331)
[    0.000000] ACPI: FACS 00000000bdf18f40 00040
[    0.000000] ACPI: APIC 00000000bdf17718 0066A (v03 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SPMI 00000000bdf1ab98 00040 (v05 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: MCFG 00000000bdf1ab18 0003C (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: WDDT 00000000bdf1af18 00040 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SRAT 00000000bdefec18 002A8 (v03 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SLIT 00000000bdf1ae98 00030 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: MSCT 00000000bdf19e18 00090 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: HPET 00000000bdf1ae18 00038 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: SSDT 00000000bdf1ad18 0002B (v02 INTEL   S2600CP 00001000 INTL 20100331)
[    0.000000] ACPI: SSDT 00000000b9679018 7A0C4 (v02 INTEL   S2600CP 00004000 INTL 20100331)
[    0.000000] ACPI: DMAR 00000000bdf18618 00150 (v01 INTEL   S2600CP 06222004 INTL 20090903)
[    0.000000] ACPI: HEST 00000000bde82f18 000A8 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: BERT 00000000bdf1ad98 00030 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: ERST 00000000bde82c98 00230 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: EINJ 00000000bdf18c18 00130 (v01 INTEL   S2600CP 00000001 INTL 00000001)
[    0.000000] ACPI: SSDT 00000000bdefb018 00F98 (v02 INTEL   S2600CP 00000002 INTL 20100331)
[    0.000000] ACPI: SSDT 00000000bdf1ac98 00045 (v02 INTEL   S2600CP 00000001 INTL 20100331)
[    0.000000] ACPI: SSDT 00000000bdf17e18 00181 (v02 INTEL   S2600CP 00000003 INTL 20100331)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x06 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x07 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x08 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x09 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0a -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0b -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0c -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0d -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0e -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x0f -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x26 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x27 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x28 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x29 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2a -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2b -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2c -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2d -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2e -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x2f -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0xbfffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x43fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x440000000-0x83fffffff]
[    0.000000] Base memory trampoline at [ffff88000008a000] 8a000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02206000, 0x02206fff] PGTABLE
[    0.000000] BRK [0x02207000, 0x02207fff] PGTABLE
[    0.000000] BRK [0x02208000, 0x02208fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x83fe00000-0x83fffffff]
[    0.000000]  [mem 0x83fe00000-0x83fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x83c000000-0x83fdfffff]
[    0.000000]  [mem 0x83c000000-0x83fdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x800000000-0x83bffffff]
[    0.000000]  [mem 0x800000000-0x83bffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0xb9678fff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0x7fffffff] page 1G
[    0.000000]  [mem 0x80000000-0xb95fffff] page 2M
[    0.000000]  [mem 0xb9600000-0xb9678fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xb96f4000-0xb97e9fff]
[    0.000000]  [mem 0xb96f4000-0xb97e9fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xb99ed000-0xbac8bfff]
[    0.000000]  [mem 0xb99ed000-0xb99fffff] page 4k
[    0.000000]  [mem 0xb9a00000-0xbabfffff] page 2M
[    0.000000]  [mem 0xbac00000-0xbac8bfff] page 4k
[    0.000000] BRK [0x02209000, 0x02209fff] PGTABLE
[    0.000000] BRK [0x0220a000, 0x0220afff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xbac9a000-0xbda00fff]
[    0.000000]  [mem 0xbac9a000-0xbadfffff] page 4k
[    0.000000]  [mem 0xbae00000-0xbd9fffff] page 2M
[    0.000000]  [mem 0xbda00000-0xbda00fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xbdc01000-0xbdcdffff]
[    0.000000]  [mem 0xbdc01000-0xbdcdffff] page 4k
[    0.000000] init_memory_mapping: [mem 0xbdfa8000-0xbdffffff]
[    0.000000]  [mem 0xbdfa8000-0xbdffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x7ffffffff]
[    0.000000]  [mem 0x100000000-0x7ffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x72fc8000-0x7fff2fff]
[    0.000000] NUMA: Initialized distance table, cnt=2
[    0.000000] NUMA: Node 0 [mem 0x00000000-0xbfffffff] + [mem 0x100000000-0x43fffffff] -> [mem 0x00000000-0x43fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x43fffffff]
[    0.000000]   NODE_DATA [mem 0x43fffb000-0x43fffffff]
[    0.000000] Initmem setup node 1 [mem 0x440000000-0x83fffffff]
[    0.000000]   NODE_DATA [mem 0x83fff5000-0x83fff9fff]
[    0.000000]  [ffffea0000000000-ffffea0010ffffff] PMD -> [ffff88042fe00000-ffff88043fdfffff] on node 0
[    0.000000]  [ffffea0011000000-ffffea0020ffffff] PMD -> [ffff88082f600000-ffff88083f5fffff] on node 1
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x83fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0008ffff]
[    0.000000]   node   0: [mem 0x00100000-0xb9678fff]
[    0.000000]   node   0: [mem 0xb96f4000-0xb97e9fff]
[    0.000000]   node   0: [mem 0xb99ed000-0xbac8bfff]
[    0.000000]   node   0: [mem 0xbac9a000-0xbda00fff]
[    0.000000]   node   0: [mem 0xbdc01000-0xbdcdffff]
[    0.000000]   node   0: [mem 0xbdfa8000-0xbdffffff]
[    0.000000]   node   0: [mem 0x100000000-0x43fffffff]
[    0.000000]   node   1: [mem 0x440000000-0x83fffffff]
[    0.000000] On node 0 totalpages: 4184123
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3898 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 12067 pages used for memmap
[    0.000000]   DMA32 zone: 760201 pages, LIFO batch:31
[    0.000000]   Normal zone: 53248 pages used for memmap
[    0.000000]   Normal zone: 3354624 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 4194304
[    0.000000]   Normal zone: 65536 pages used for memmap
[    0.000000]   Normal zone: 4128768 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] ACPI: X2APIC (apic_id[0x00] uid[0x00] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x01] uid[0x01] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x02] uid[0x02] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x03] uid[0x03] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x04] uid[0x04] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x05] uid[0x05] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x06] uid[0x06] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x07] uid[0x07] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x08] uid[0x08] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x09] uid[0x09] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0a] uid[0x0a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0b] uid[0x0b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0c] uid[0x0c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0d] uid[0x0d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0e] uid[0x0e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x0f] uid[0x0f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x10] uid[0x10] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x11] uid[0x11] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x12] uid[0x12] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x13] uid[0x13] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x14] uid[0x14] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x15] uid[0x15] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x16] uid[0x16] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x17] uid[0x17] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x18] uid[0x18] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x19] uid[0x19] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1a] uid[0x1a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1b] uid[0x1b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1c] uid[0x1c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1d] uid[0x1d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1e] uid[0x1e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x1f] uid[0x1f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x20] uid[0x20] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x21] uid[0x21] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x22] uid[0x22] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x23] uid[0x23] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x24] uid[0x24] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x25] uid[0x25] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x26] uid[0x26] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x27] uid[0x27] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x28] uid[0x28] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x29] uid[0x29] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2a] uid[0x2a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2b] uid[0x2b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2c] uid[0x2c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2d] uid[0x2d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2e] uid[0x2e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x2f] uid[0x2f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x30] uid[0x30] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x31] uid[0x31] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x32] uid[0x32] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x33] uid[0x33] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x34] uid[0x34] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x35] uid[0x35] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x36] uid[0x36] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x37] uid[0x37] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x38] uid[0x38] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x39] uid[0x39] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3a] uid[0x3a] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3b] uid[0x3b] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3c] uid[0x3c] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3d] uid[0x3d] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3e] uid[0x3e] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: X2APIC (apic_id[0x3f] uid[0x3f] disabled)
[    0.000000] ACPI: x2apic entry ignored
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x08] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x0a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x0c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x0e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x20] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x22] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x24] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x26] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x28] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x2a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x2c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x2e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x09] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x0b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x0d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x0f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x21] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x23] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x25] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x27] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x29] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x2b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x2d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x2f] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x21] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x22] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x23] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x24] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x25] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x26] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x27] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x28] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x29] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2a] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2b] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2c] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2d] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2e] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x2f] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x30] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x31] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x32] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x33] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x34] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x35] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x36] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x37] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x38] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x39] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3a] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3b] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3c] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3d] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3e] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x3f] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec3f000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 1, version 32, address 0xfec3f000, GSI 24-47
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec7f000] gsi_base[48])
[    0.000000] IOAPIC[2]: apic_id 2, version 32, address 0xfec7f000, GSI 48-71
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 0, APIC INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 0, APIC INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 0, APIC INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 64 CPUs, 32 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] mapped IOAPIC to ffffffffff5f1000 (fec3f000)
[    0.000000] mapped IOAPIC to ffffffffff5f0000 (fec7f000)
[    0.000000] nr_irqs_gsi: 88
[    0.000000] PM: Registered nosave memory: 0000000000090000 - 0000000000091000
[    0.000000] PM: Registered nosave memory: 0000000000091000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000b9679000 - 00000000b96f4000
[    0.000000] PM: Registered nosave memory: 00000000b97ea000 - 00000000b99ed000
[    0.000000] PM: Registered nosave memory: 00000000bac8c000 - 00000000bac9a000
[    0.000000] PM: Registered nosave memory: 00000000bda01000 - 00000000bdc01000
[    0.000000] PM: Registered nosave memory: 00000000bdce0000 - 00000000bdde7000
[    0.000000] PM: Registered nosave memory: 00000000bdde7000 - 00000000bde82000
[    0.000000] PM: Registered nosave memory: 00000000bde82000 - 00000000bde83000
[    0.000000] PM: Registered nosave memory: 00000000bde83000 - 00000000bdefb000
[    0.000000] PM: Registered nosave memory: 00000000bdefb000 - 00000000bdefc000
[    0.000000] PM: Registered nosave memory: 00000000bdefc000 - 00000000bdefe000
[    0.000000] PM: Registered nosave memory: 00000000bdefe000 - 00000000bdeff000
[    0.000000] PM: Registered nosave memory: 00000000bdeff000 - 00000000bdf00000
[    0.000000] PM: Registered nosave memory: 00000000bdf00000 - 00000000bdf1b000
[    0.000000] PM: Registered nosave memory: 00000000bdf1b000 - 00000000bdfa8000
[    0.000000] PM: Registered nosave memory: 00000000be000000 - 00000000d0000000
[    0.000000] PM: Registered nosave memory: 00000000d0000000 - 00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
[    0.000000] PM: Registered nosave memory: 00000000fec01000 - 00000000fed19000
[    0.000000] PM: Registered nosave memory: 00000000fed19000 - 00000000fed1a000
[    0.000000] PM: Registered nosave memory: 00000000fed1a000 - 00000000fed1c000
[    0.000000] PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
[    0.000000] PM: Registered nosave memory: 00000000fed20000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ffa20000
[    0.000000] PM: Registered nosave memory: 00000000ffa20000 - 0000000100000000
[    0.000000] e820: [mem 0xd0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:64 nr_node_ids:2
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88042fa00000 s80384 r8192 d22016 u131072
[    0.000000] pcpu-alloc: s80384 r8192 d22016 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 02 04 06 08 10 12 14 16 18 20 22 24 26 28 30 
[    0.000000] pcpu-alloc: [0] 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 
[    0.000000] pcpu-alloc: [1] 01 03 05 07 09 11 13 15 17 19 21 23 25 27 29 31 
[    0.000000] pcpu-alloc: [1] 33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 
[    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 8247491
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: user=lkp job=/lkp/scheduled/lkp-snb01/bisect_aim7-shared-x86_64-lkp-e8d1955258091e4c92d5a975ebd7fd8a98f5d30f-0.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/vmlinuz-3.8.0-06530-ge8d1955 kconfig=x86_64-lkp commit=e8d1955258091e4c92d5a975ebd7fd8a98f5d30f bm_initrd=/lkp/benchmarks/aim7.cgz modules_initrd=/kernel/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/modules.cgz max_uptime=695 RESULT_ROOT=/lkp/result/lkp-snb01/micro/aim7/shared/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/0 initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 ip=::::lkp-snb01::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 32684308k/34603008k available (9803k kernel code, 1089300k absent, 829400k reserved, 5648k data, 1260k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=64, Nodes=2
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=64.
[    0.000000] NR_IRQS:33024 nr_irqs:2008 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] allocated 134217728 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Enabling automatic NUMA balancing. Configure with numa_balancing= or sysctl
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2693.366 MHz processor
[    0.000029] Calibrating delay loop (skipped), value calculated using timer frequency.. 5386.73 BogoMIPS (lpj=10773464)
[    0.012172] pid_max: default: 65536 minimum: 512
[    0.021723] Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
[    0.043020] Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
[    0.056721] Mount-cache hash table entries: 256
[    0.062598] Initializing cgroup subsys memory
[    0.067607] Initializing cgroup subsys devices
[    0.072657] Initializing cgroup subsys freezer
[    0.078088] Initializing cgroup subsys blkio
[    0.083321] Initializing cgroup subsys perf_event
[    0.089050] Initializing cgroup subsys hugetlb
[    0.094575] CPU: Physical Processor ID: 0
[    0.099507] CPU: Processor Core ID: 0
[    0.104077] mce: CPU supports 20 MCE banks
[    0.109165] CPU0: Thermal LVT vector (0xfa) already installed
[    0.116071] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
[    0.116071] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
[    0.116071] tlb_flushall_shift: 5
[    0.133667] Freeing SMP alternatives: 40k freed
[    0.142443] ACPI: Core revision 20130117
[    0.213749] ACPI: All ACPI Tables successfully acquired
[    0.220244] ftrace: allocating 36865 entries in 145 pages
[    0.263470] Getting VERSION: 1060015
[    0.267919] Getting VERSION: 1060015
[    0.272373] Getting ID: 0
[    0.275759] Getting ID: 0
[    0.279150] Switched APIC routing to physical flat.
[    0.285064] masked ExtINT on CPU#0
[    0.289826] ENABLING IO-APIC IRQs
[    0.293992] init IO_APIC IRQs
[    0.297760]  apic 0 pin 0 not connected
[    0.302512] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:0)
[    0.312211] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)
[    0.321916] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
[    0.331626] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
[    0.341326] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:0 Active:0 Dest:0)
[    0.351031] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:0)
[    0.360729] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:0)
[    0.370427] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
[    0.380126] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:0)
[    0.389818] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:0 Active:0 Dest:0)
[    0.399713] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:0 Active:0 Dest:0)
[    0.409613] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:0)
[    0.419507] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
[    0.429404] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:0)
[    0.439302] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:0)
[    0.449196]  apic 0 pin 16 not connected
[    0.454047]  apic 0 pin 17 not connected
[    0.458892]  apic 0 pin 18 not connected
[    0.463732]  apic 0 pin 19 not connected
[    0.468574]  apic 0 pin 20 not connected
[    0.473417]  apic 0 pin 21 not connected
[    0.478256]  apic 0 pin 22 not connected
[    0.483097]  apic 0 pin 23 not connected
[    0.487947]  apic 1 pin 0 not connected
[    0.492697]  apic 1 pin 1 not connected
[    0.497442]  apic 1 pin 2 not connected
[    0.502194]  apic 1 pin 3 not connected
[    0.506945]  apic 1 pin 4 not connected
[    0.511682]  apic 1 pin 5 not connected
[    0.516422]  apic 1 pin 6 not connected
[    0.521167]  apic 1 pin 7 not connected
[    0.525899]  apic 1 pin 8 not connected
[    0.530641]  apic 1 pin 9 not connected
[    0.535385]  apic 1 pin 10 not connected
[    0.540224]  apic 1 pin 11 not connected
[    0.545062]  apic 1 pin 12 not connected
[    0.549903]  apic 1 pin 13 not connected
[    0.554743]  apic 1 pin 14 not connected
[    0.559580]  apic 1 pin 15 not connected
[    0.564418]  apic 1 pin 16 not connected
[    0.569258]  apic 1 pin 17 not connected
[    0.574107]  apic 1 pin 18 not connected
[    0.578943]  apic 1 pin 19 not connected
[    0.583791]  apic 1 pin 20 not connected
[    0.588630]  apic 1 pin 21 not connected
[    0.593471]  apic 1 pin 22 not connected
[    0.598312]  apic 1 pin 23 not connected
[    0.603156]  apic 2 pin 0 not connected
[    0.607896]  apic 2 pin 1 not connected
[    0.612642]  apic 2 pin 2 not connected
[    0.617389]  apic 2 pin 3 not connected
[    0.622134]  apic 2 pin 4 not connected
[    0.626874]  apic 2 pin 5 not connected
[    0.631620]  apic 2 pin 6 not connected
[    0.636364]  apic 2 pin 7 not connected
[    0.641117]  apic 2 pin 8 not connected
[    0.645858]  apic 2 pin 9 not connected
[    0.650603]  apic 2 pin 10 not connected
[    0.655444]  apic 2 pin 11 not connected
[    0.660288]  apic 2 pin 12 not connected
[    0.665130]  apic 2 pin 13 not connected
[    0.669970]  apic 2 pin 14 not connected
[    0.674813]  apic 2 pin 15 not connected
[    0.679660]  apic 2 pin 16 not connected
[    0.684503]  apic 2 pin 17 not connected
[    0.689349]  apic 2 pin 18 not connected
[    0.694198]  apic 2 pin 19 not connected
[    0.699046]  apic 2 pin 20 not connected
[    0.703894]  apic 2 pin 21 not connected
[    0.708734]  apic 2 pin 22 not connected
[    0.713578]  apic 2 pin 23 not connected
[    0.718563] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.765410] smpboot: CPU0: Intel(R) Xeon(R) CPU E5-2680 0 @ 2.70GHz (fam: 06, model: 2d, stepping: 06)
[    0.776949] TSC deadline timer enabled
[    0.781627] Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge events, Intel PMU driver.
[    0.792466] perf_event_intel: PEBS disabled due to CPU errata, please upgrade microcode
[    0.802266] ... version:                3
[    0.807202] ... bit width:              48
[    0.812244] ... generic registers:      4
[    0.817182] ... value mask:             0000ffffffffffff
[    0.823584] ... max period:             000000007fffffff
[    0.829987] ... fixed-purpose events:   3
[    0.834929] ... event mask:             000000070000000f
[    0.845092] smpboot: Booting Node   1, Processors  #1
[    0.864812] masked ExtINT on CPU#1
[    0.868706] CPU1: Thermal LVT vector (0xfa) already installed
[    0.875158] ------------[ cut here ]------------
[    0.880330] WARNING: at arch/x86/kernel/smpboot.c:324 topology_sane.isra.2+0x6b/0x7c()
[    0.891505] Hardware name: S2600CP
[    0.895314] sched: CPU #1's llc-sibling CPU #0 is not on the same node! [node: 1 != 0]. Ignoring dependency.

[    0.906295] Modules linked in:
[    0.909927] Pid: 0, comm: swapper/1 Not tainted 3.8.0-06530-ge8d1955 #1
[    0.917314] Call Trace:
[    0.920055]  [<ffffffff81970409>] ? topology_sane.isra.2+0x6b/0x7c
[    0.926963]  [<ffffffff810bcd5d>] warn_slowpath_common+0x81/0x99
[    0.933667]  [<ffffffff810bcdc1>] warn_slowpath_fmt+0x4c/0x4e
[    0.940092]  [<ffffffff8196b565>] ? calibrate_delay+0xae/0x4ba
[    0.946612]  [<ffffffff810508ea>] ? __mcheck_cpu_init_timer+0x4a/0x4f
[    0.953799]  [<ffffffff81970409>] topology_sane.isra.2+0x6b/0x7c
[    0.960509]  [<ffffffff819706e0>] set_cpu_sibling_map+0x28c/0x43a
[    0.967308]  [<ffffffff81970a3c>] start_secondary+0x1ae/0x276
[    0.973742] ---[ end trace db722b2086ba6d20 ]---
[    0.999234]  OK
[    1.001655] smpboot: Booting Node   0, Processors  #2
[    1.018610] masked ExtINT on CPU#2
[    1.022507] CPU2: Thermal LVT vector (0xfa) already installed
 OK
[    1.032253] smpboot: Booting Node   1, Processors  #3
[    1.049296] masked ExtINT on CPU#3
[    1.053190] CPU3: Thermal LVT vector (0xfa) already installed
 OK
[    1.062954] smpboot: Booting Node   0, Processors  #4
[    1.079995] masked ExtINT on CPU#4
[    1.083879] CPU4: Thermal LVT vector (0xfa) already installed
 OK
[    1.093614] smpboot: Booting Node   1, Processors  #5
[    1.110646] masked ExtINT on CPU#5
[    1.114531] CPU5: Thermal LVT vector (0xfa) already installed
 OK
[    1.124215] smpboot: Booting Node   0, Processors  #6
[    1.141232] masked ExtINT on CPU#6
[    1.145124] CPU6: Thermal LVT vector (0xfa) already installed
 OK
[    1.154777] smpboot: Booting Node   1, Processors  #7
[    1.171783] masked ExtINT on CPU#7
[    1.175669] CPU7: Thermal LVT vector (0xfa) already installed
 OK
[    1.185385] smpboot: Booting Node   0, Processors  #8
[    1.203659] masked ExtINT on CPU#8
[    1.207552] CPU8: Thermal LVT vector (0xfa) already installed
 OK
[    1.311813] smpboot: Booting Node   1, Processors  #9
[    1.328837] masked ExtINT on CPU#9
[    1.332738] CPU9: Thermal LVT vector (0xfa) already installed
 OK
[    1.360429] smpboot: Booting Node   0, Processors  #10
[    1.377550] masked ExtINT on CPU#10
[    1.381553] CPU10: Thermal LVT vector (0xfa) already installed
 OK
[    1.391245] smpboot: Booting Node   1, Processors  #11
[    1.408370] masked ExtINT on CPU#11
[    1.412360] CPU11: Thermal LVT vector (0xfa) already installed
 OK
[    1.422081] smpboot: Booting Node   0, Processors  #12
[    1.439200] masked ExtINT on CPU#12
[    1.443199] CPU12: Thermal LVT vector (0xfa) already installed
 OK
[    1.452969] smpboot: Booting Node   1, Processors  #13
[    1.470073] masked ExtINT on CPU#13
[    1.474063] CPU13: Thermal LVT vector (0xfa) already installed
 OK
[    1.483777] smpboot: Booting Node   0, Processors  #14
[    1.500874] masked ExtINT on CPU#14
[    1.504872] CPU14: Thermal LVT vector (0xfa) already installed
 OK
[    1.514562] smpboot: Booting Node   1, Processors  #15
[    1.531644] masked ExtINT on CPU#15
[    1.535635] CPU15: Thermal LVT vector (0xfa) already installed
 OK
[    1.545381] smpboot: Booting Node   0, Processors  #16
[    1.562944] masked ExtINT on CPU#16
[    1.566934] CPU16: Thermal LVT vector (0xfa) already installed
 OK
[    1.576762] smpboot: Booting Node   1, Processors  #17
[    1.593796] masked ExtINT on CPU#17
[    1.597781] CPU17: Thermal LVT vector (0xfa) already installed
 OK
[    1.607548] smpboot: Booting Node   0, Processors  #18
[    1.624689] masked ExtINT on CPU#18
[    1.628668] CPU18: Thermal LVT vector (0xfa) already installed
 OK
[    1.638409] smpboot: Booting Node   1, Processors  #19
[    1.655560] masked ExtINT on CPU#19
[    1.659539] CPU19: Thermal LVT vector (0xfa) already installed
 OK
[    1.669393] smpboot: Booting Node   0, Processors  #20
[    1.686542] masked ExtINT on CPU#20
[    1.690521] CPU20: Thermal LVT vector (0xfa) already installed
 OK
[    1.700370] smpboot: Booting Node   1, Processors  #21
[    1.717495] masked ExtINT on CPU#21
[    1.721474] CPU21: Thermal LVT vector (0xfa) already installed
 OK
[    1.731249] smpboot: Booting Node   0, Processors  #22
[    1.748372] masked ExtINT on CPU#22
[    1.752351] CPU22: Thermal LVT vector (0xfa) already installed
 OK
[    1.762099] smpboot: Booting Node   1, Processors  #23
[    1.779208] masked ExtINT on CPU#23
[    1.783185] CPU23: Thermal LVT vector (0xfa) already installed
 OK
[    1.792980] smpboot: Booting Node   0, Processors  #24
[    1.810074] masked ExtINT on CPU#24
[    1.814060] CPU24: Thermal LVT vector (0xfa) already installed
 OK
[    1.823794] smpboot: Booting Node   1, Processors  #25
[    1.840913] masked ExtINT on CPU#25
[    1.844899] CPU25: Thermal LVT vector (0xfa) already installed
 OK
[    1.854597] smpboot: Booting Node   0, Processors  #26
[    1.871718] masked ExtINT on CPU#26
[    1.875706] CPU26: Thermal LVT vector (0xfa) already installed
 OK
[    1.885402] smpboot: Booting Node   1, Processors  #27
[    1.902533] masked ExtINT on CPU#27
[    1.906511] CPU27: Thermal LVT vector (0xfa) already installed
 OK
[    1.916324] smpboot: Booting Node   0, Processors  #28
[    1.933440] masked ExtINT on CPU#28
[    1.937417] CPU28: Thermal LVT vector (0xfa) already installed
 OK
[    1.947115] smpboot: Booting Node   1, Processors  #29
[    1.964223] masked ExtINT on CPU#29
[    1.968209] CPU29: Thermal LVT vector (0xfa) already installed
 OK
[    1.977931] smpboot: Booting Node   0, Processors  #30
[    1.995035] masked ExtINT on CPU#30
[    1.999022] CPU30: Thermal LVT vector (0xfa) already installed
 OK
[    2.008740] smpboot: Booting Node   1, Processors  #31
[    2.025832] masked ExtINT on CPU#31
[    2.029819] CPU31: Thermal LVT vector (0xfa) already installed

[    2.038467] Brought up 32 CPUs
[    2.043002] smpboot: Total of 32 processors activated (172421.08 BogoMIPS)
[    2.160645] devtmpfs: initialized
[    2.174047] PM: Registering ACPI NVS region [mem 0xb97ea000-0xb99ecfff] (2109440 bytes)
[    2.183965] PM: Registering ACPI NVS region [mem 0xbda01000-0xbdc00fff] (2097152 bytes)
[    2.193854] PM: Registering ACPI NVS region [mem 0xbdde7000-0xbde81fff] (634880 bytes)
[    2.203583] PM: Registering ACPI NVS region [mem 0xbde83000-0xbdefafff] (491520 bytes)
[    2.213309] PM: Registering ACPI NVS region [mem 0xbdefc000-0xbdefdfff] (8192 bytes)
[    2.222806] PM: Registering ACPI NVS region [mem 0xbdeff000-0xbdefffff] (4096 bytes)
[    2.232303] PM: Registering ACPI NVS region [mem 0xbdf1b000-0xbdfa7fff] (577536 bytes)
[    2.243747] xor: automatically using best checksumming function:
[    2.290931]    avx       :  8890.000 MB/sec
[    2.296093] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    2.304660] NET: Registered protocol family 16
[    2.312766] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    2.322078] ACPI: bus type pci registered
[    2.336553] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xc0000000-0xcfffffff] (base 0xc0000000)
[    2.347812] PCI: MMCONFIG at [mem 0xc0000000-0xcfffffff] reserved in E820
[    2.400864] PCI: Using configuration type 1 for base access
[    2.434090] bio: create slab <bio-0> at 0
[    2.507067] raid6: sse2x1    3146 MB/s
[    2.579751] raid6: sse2x2    4000 MB/s
[    2.652439] raid6: sse2x4    4561 MB/s
[    2.657092] raid6: using algorithm sse2x4 (4561 MB/s)
[    2.663200] raid6: using ssse3x2 recovery algorithm
[    2.669225] ACPI: Added _OSI(Module Device)
[    2.674364] ACPI: Added _OSI(Processor Device)
[    2.679792] ACPI: Added _OSI(3.0 _SCP Extensions)
[    2.685520] ACPI: Added _OSI(Processor Aggregator Device)
[    2.706575] ACPI: EC: Look up EC in DSDT
[    2.726471] ACPI: Executed 1 blocks of module-level executable AML code
[    2.917943] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    2.946397] ACPI: Interpreter enabled
[    2.950961] ACPI: (supports S0 S1ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130117/hwxface-568)
[    2.964542] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20130117/hwxface-568)
[    2.975885] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20130117/hwxface-568)
[    2.987234]  S5)
[    2.989833] ACPI: Using IOAPIC for interrupt routing
[    2.996211] HEST: Table parsing has been initialized.
[    3.002332] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    3.058177] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-7e])
[    3.065562] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    3.073485] acpi PNP0A08:00: Requesting ACPI _OSC control (0x1d)
[    3.081320] acpi PNP0A08:00: ACPI _OSC control (0x15) granted
[    3.088730] acpi PNP0A08:00: host bridge window expanded to [io  0x0000-0xbfff]; [io  0x0000-0xbfff] ignored
[    3.100577] acpi PNP0A08:00: ignoring host bridge window [mem 0x000d0000-0x000d3fff] (conflicts with Adapter ROM [mem 0x000c8000-0x000d15ff])
[    3.115622] acpi PNP0A08:00: ignoring host bridge window [mem 0x000d4000-0x000d7fff] (conflicts with Adapter ROM [mem 0x000d3800-0x000d47ff])
[    3.130786] PCI host bridge to bus 0000:00
[    3.135833] pci_bus 0000:00: root bus resource [bus 00-7e]
[    3.142431] pci_bus 0000:00: root bus resource [io  0x0000-0xbfff]
[    3.149812] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    3.157965] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000c3fff]
[    3.166117] pci_bus 0000:00: root bus resource [mem 0x000c4000-0x000c7fff]
[    3.174268] pci_bus 0000:00: root bus resource [mem 0x000c8000-0x000cbfff]
[    3.182416] pci_bus 0000:00: root bus resource [mem 0x000cc000-0x000cffff]
[    3.190564] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000dbfff]
[    3.198714] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000dffff]
[    3.206863] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e3fff]
[    3.215008] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e7fff]
[    3.223160] pci_bus 0000:00: root bus resource [mem 0x000e8000-0x000ebfff]
[    3.231306] pci_bus 0000:00: root bus resource [mem 0x000ec000-0x000effff]
[    3.239452] pci_bus 0000:00: root bus resource [mem 0x000f0000-0x000fffff]
[    3.247610] pci_bus 0000:00: root bus resource [mem 0xd0000000-0xebffffff]
[    3.255768] pci_bus 0000:00: root bus resource [mem 0x3c0000000000-0x3c007fffffff]
[    3.265093] pci 0000:00:00.0: [8086:3c00] type 00 class 0x060000
[    3.272352] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    3.279674] pci 0000:00:01.0: [8086:3c02] type 01 class 0x060400
[    3.286941] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    3.294263] pci 0000:00:02.0: [8086:3c04] type 01 class 0x060400
[    3.301526] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    3.308841] pci 0000:00:02.2: [8086:3c06] type 01 class 0x060400
[    3.316114] pci 0000:00:02.2: PME# supported from D0 D3hot D3cold
[    3.323428] pci 0000:00:03.0: [8086:3c08] type 01 class 0x060400
[    3.330691] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    3.338015] pci 0000:00:03.2: [8086:3c0a] type 01 class 0x060400
[    3.345282] pci 0000:00:03.2: PME# supported from D0 D3hot D3cold
[    3.352604] pci 0000:00:04.0: [8086:3c20] type 00 class 0x088000
[    3.359810] pci 0000:00:04.0: reg 10: [mem 0xebf90000-0xebf93fff 64bit]
[    3.367783] pci 0000:00:04.1: [8086:3c21] type 00 class 0x088000
[    3.374968] pci 0000:00:04.1: reg 10: [mem 0xebf80000-0xebf83fff 64bit]
[    3.382946] pci 0000:00:04.2: [8086:3c22] type 00 class 0x088000
[    3.390145] pci 0000:00:04.2: reg 10: [mem 0xebf70000-0xebf73fff 64bit]
[    3.398127] pci 0000:00:04.3: [8086:3c23] type 00 class 0x088000
[    3.405317] pci 0000:00:04.3: reg 10: [mem 0xebf60000-0xebf63fff 64bit]
[    3.413294] pci 0000:00:04.4: [8086:3c24] type 00 class 0x088000
[    3.420489] pci 0000:00:04.4: reg 10: [mem 0xebf50000-0xebf53fff 64bit]
[    3.428463] pci 0000:00:04.5: [8086:3c25] type 00 class 0x088000
[    3.435654] pci 0000:00:04.5: reg 10: [mem 0xebf40000-0xebf43fff 64bit]
[    3.443623] pci 0000:00:04.6: [8086:3c26] type 00 class 0x088000
[    3.450817] pci 0000:00:04.6: reg 10: [mem 0xebf30000-0xebf33fff 64bit]
[    3.458787] pci 0000:00:04.7: [8086:3c27] type 00 class 0x088000
[    3.465982] pci 0000:00:04.7: reg 10: [mem 0xebf20000-0xebf23fff 64bit]
[    3.473972] pci 0000:00:05.0: [8086:3c28] type 00 class 0x088000
[    3.481264] pci 0000:00:05.2: [8086:3c2a] type 00 class 0x088000
[    3.488554] pci 0000:00:05.4: [8086:3c2c] type 00 class 0x080020
[    3.495752] pci 0000:00:05.4: reg 10: [mem 0xd0c60000-0xd0c60fff]
[    3.503143] pci 0000:00:11.0: [8086:1d3e] type 01 class 0x060400
[    3.510437] pci 0000:00:11.0: PME# supported from D0 D3hot D3cold
[    3.517769] pci 0000:00:16.0: [8086:1d3a] type 00 class 0x078000
[    3.524971] pci 0000:00:16.0: reg 10: [mem 0xd0c50000-0xd0c5000f 64bit]
[    3.532917] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    3.540231] pci 0000:00:16.1: [8086:1d3b] type 00 class 0x078000
[    3.547429] pci 0000:00:16.1: reg 10: [mem 0xd0c40000-0xd0c4000f 64bit]
[    3.555371] pci 0000:00:16.1: PME# supported from D0 D3hot D3cold
[    3.562693] pci 0000:00:1a.0: [8086:1d2d] type 00 class 0x0c0320
[    3.569893] pci 0000:00:1a.0: reg 10: [mem 0xd0c20000-0xd0c203ff]
[    3.577289] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    3.584605] pci 0000:00:1c.0: [8086:1d10] type 01 class 0x060400
[    3.591885] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    3.599199] pci 0000:00:1c.7: [8086:1d1e] type 01 class 0x060400
[    3.606485] pci 0000:00:1c.7: PME# supported from D0 D3hot D3cold
[    3.613805] pci 0000:00:1d.0: [8086:1d26] type 00 class 0x0c0320
[    3.621003] pci 0000:00:1d.0: reg 10: [mem 0xd0c10000-0xd0c103ff]
[    3.628401] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    3.635708] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    3.642972] pci 0000:00:1f.0: [8086:1d41] type 00 class 0x060100
[    3.650320] pci 0000:00:1f.2: [8086:1d02] type 00 class 0x010601
[    3.657525] pci 0000:00:1f.2: reg 10: [io  0x3070-0x3077]
[    3.664039] pci 0000:00:1f.2: reg 14: [io  0x3060-0x3063]
[    3.670543] pci 0000:00:1f.2: reg 18: [io  0x3050-0x3057]
[    3.677052] pci 0000:00:1f.2: reg 1c: [io  0x3040-0x3043]
[    3.683561] pci 0000:00:1f.2: reg 20: [io  0x3020-0x303f]
[    3.690066] pci 0000:00:1f.2: reg 24: [mem 0xd0c00000-0xd0c007ff]
[    3.697412] pci 0000:00:1f.2: PME# supported from D3hot
[    3.703743] pci 0000:00:1f.3: [8086:1d22] type 00 class 0x0c0500
[    3.710934] pci 0000:00:1f.3: reg 10: [mem 0xebf10000-0xebf100ff 64bit]
[    3.718820] pci 0000:00:1f.3: reg 20: [io  0x3000-0x301f]
[    3.725404] pci 0000:00:01.0: PCI bridge to [bus 01]
[    3.731479] pci 0000:00:02.0: PCI bridge to [bus 02]
[    3.737548] pci 0000:00:02.2: PCI bridge to [bus 03]
[    3.743624] pci 0000:00:03.0: PCI bridge to [bus 04]
[    3.749694] pci 0000:00:03.2: PCI bridge to [bus 05]
[    3.755793] pci 0000:06:00.0: [8086:1d69] type 00 class 0x010700
[    3.762996] pci 0000:06:00.0: reg 10: [mem 0xebc00000-0xebc03fff 64bit pref]
[    3.771355] pci 0000:06:00.0: reg 18: [mem 0xeb800000-0xebbfffff 64bit pref]
[    3.779706] pci 0000:06:00.0: reg 20: [io  0x2000-0x20ff]
[    3.786330] pci 0000:06:00.0: reg 164: [mem 0xebc10000-0xebc13fff 64bit pref]
[    3.794833] pci 0000:06:00.3: [8086:1d70] type 00 class 0x0c0500
[    3.802029] pci 0000:06:00.3: reg 10: [mem 0xd0b00000-0xd0b00fff]
[    3.809356] pci 0000:06:00.3: reg 20: [io  0x2100-0x211f]
[    3.815936] pci 0000:06:00.3: PME# supported from D0 D3hot D3cold
[    3.823264] pci 0000:00:11.0: PCI bridge to [bus 06]
[    3.829267] pci 0000:00:11.0:   bridge window [io  0x2000-0x2fff]
[    3.836548] pci 0000:00:11.0:   bridge window [mem 0xd0b00000-0xd0bfffff]
[    3.844617] pci 0000:00:11.0:   bridge window [mem 0xeb800000-0xebcfffff 64bit pref]
[    3.854214] pci 0000:07:00.0: [8086:1521] type 00 class 0x020000
[    3.861415] pci 0000:07:00.0: reg 10: [mem 0xd0960000-0xd097ffff]
[    3.868718] pci 0000:07:00.0: reg 18: [io  0x1060-0x107f]
[    3.875229] pci 0000:07:00.0: reg 1c: [mem 0xd09b0000-0xd09b3fff]
[    3.882635] pci 0000:07:00.0: PME# supported from D0 D3hot D3cold
[    3.889973] pci 0000:07:00.0: reg 184: [mem 0xd0aa0000-0xd0aa3fff]
[    3.897379] pci 0000:07:00.0: reg 190: [mem 0xd0a80000-0xd0a83fff]
[    3.904815] pci 0000:07:00.1: [8086:1521] type 00 class 0x020000
[    3.912020] pci 0000:07:00.1: reg 10: [mem 0xd0940000-0xd095ffff]
[    3.919323] pci 0000:07:00.1: reg 18: [io  0x1040-0x105f]
[    3.925834] pci 0000:07:00.1: reg 1c: [mem 0xd09a0000-0xd09a3fff]
[    3.933237] pci 0000:07:00.1: PME# supported from D0 D3hot D3cold
[    3.940573] pci 0000:07:00.1: reg 184: [mem 0xd0a60000-0xd0a63fff]
[    3.947978] pci 0000:07:00.1: reg 190: [mem 0xd0a40000-0xd0a43fff]
[    3.955415] pci 0000:07:00.2: [8086:1521] type 00 class 0x020000
[    3.962622] pci 0000:07:00.2: reg 10: [mem 0xd0920000-0xd093ffff]
[    3.969925] pci 0000:07:00.2: reg 18: [io  0x1020-0x103f]
[    3.976436] pci 0000:07:00.2: reg 1c: [mem 0xd0990000-0xd0993fff]
[    3.983842] pci 0000:07:00.2: PME# supported from D0 D3hot D3cold
[    3.991168] pci 0000:07:00.2: reg 184: [mem 0xd0a20000-0xd0a23fff]
[    3.998586] pci 0000:07:00.2: reg 190: [mem 0xd0a00000-0xd0a03fff]
[    4.006027] pci 0000:07:00.3: [8086:1521] type 00 class 0x020000
[    4.013225] pci 0000:07:00.3: reg 10: [mem 0xd0900000-0xd091ffff]
[    4.020533] pci 0000:07:00.3: reg 18: [io  0x1000-0x101f]
[    4.027048] pci 0000:07:00.3: reg 1c: [mem 0xd0980000-0xd0983fff]
[    4.034456] pci 0000:07:00.3: PME# supported from D0 D3hot D3cold
[    4.041787] pci 0000:07:00.3: reg 184: [mem 0xd09e0000-0xd09e3fff]
[    4.049196] pci 0000:07:00.3: reg 190: [mem 0xd09c0000-0xd09c3fff]
[    4.064606] pci 0000:00:1c.0: PCI bridge to [bus 07-08]
[    4.070914] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    4.078193] pci 0000:00:1c.0:   bridge window [mem 0xd0900000-0xd0afffff]
[    4.086348] pci 0000:09:00.0: [102b:0522] type 00 class 0x030000
[    4.093548] pci 0000:09:00.0: reg 10: [mem 0xea000000-0xeaffffff pref]
[    4.101329] pci 0000:09:00.0: reg 14: [mem 0xd0810000-0xd0813fff]
[    4.108624] pci 0000:09:00.0: reg 18: [mem 0xd0000000-0xd07fffff]
[    4.115968] pci 0000:09:00.0: reg 30: [mem 0xd0800000-0xd080ffff pref]
[    4.131747] pci 0000:00:1c.7: PCI bridge to [bus 09]
[    4.137764] pci 0000:00:1c.7:   bridge window [mem 0xd0000000-0xd08fffff]
[    4.145822] pci 0000:00:1c.7:   bridge window [mem 0xea000000-0xeaffffff 64bit pref]
[    4.155411] pci 0000:00:1e.0: PCI bridge to [bus 0a] (subtractive decode)
[    4.172839] pci 0000:00:1e.0:   bridge window [io  0x0000-0xbfff] (subtractive decode)
[    4.182541] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    4.193012] pci 0000:00:1e.0:   bridge window [mem 0x000c0000-0x000c3fff] (subtractive decode)
[    4.203487] pci 0000:00:1e.0:   bridge window [mem 0x000c4000-0x000c7fff] (subtractive decode)
[    4.213956] pci 0000:00:1e.0:   bridge window [mem 0x000c8000-0x000cbfff] (subtractive decode)
[    4.224423] pci 0000:00:1e.0:   bridge window [mem 0x000cc000-0x000cffff] (subtractive decode)
[    4.234897] pci 0000:00:1e.0:   bridge window [mem 0x000d8000-0x000dbfff] (subtractive decode)
[    4.245379] pci 0000:00:1e.0:   bridge window [mem 0x000dc000-0x000dffff] (subtractive decode)
[    4.255854] pci 0000:00:1e.0:   bridge window [mem 0x000e0000-0x000e3fff] (subtractive decode)
[    4.266339] pci 0000:00:1e.0:   bridge window [mem 0x000e4000-0x000e7fff] (subtractive decode)
[    4.276818] pci 0000:00:1e.0:   bridge window [mem 0x000e8000-0x000ebfff] (subtractive decode)
[    4.287291] pci 0000:00:1e.0:   bridge window [mem 0x000ec000-0x000effff] (subtractive decode)
[    4.297766] pci 0000:00:1e.0:   bridge window [mem 0x000f0000-0x000fffff] (subtractive decode)
[    4.308238] pci 0000:00:1e.0:   bridge window [mem 0xd0000000-0xebffffff] (subtractive decode)
[    4.318714] pci 0000:00:1e.0:   bridge window [mem 0x3c0000000000-0x3c007fffffff] (subtractive decode)
[    4.330008] pci_bus 0000:00: on NUMA node 0 (pxm 0)
[    4.336177] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR10._PRT]
[    4.343807] pci 0000:00:01.0: System wakeup disabled by ACPI
[    4.350774] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR12._PRT]
[    4.358395] pci 0000:00:02.0: System wakeup disabled by ACPI
[    4.365345] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR14._PRT]
[    4.372966] pci 0000:00:02.2: System wakeup disabled by ACPI
[    4.379928] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR16._PRT]
[    4.387543] pci 0000:00:03.0: System wakeup disabled by ACPI
[    4.394506] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR18._PRT]
[    4.402118] pci 0000:00:03.2: System wakeup disabled by ACPI
[    4.410907] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EVRP._PRT]
[    4.419120] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    4.426047] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
[    4.433662] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    4.440601] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP08._PRT]
[    4.448214] pci 0000:00:1c.7: System wakeup disabled by ACPI
[    4.455249] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    4.462180] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    4.470187] pci 0000:07:00.0: System wakeup disabled by ACPI
[    4.477518] pci 0000:09:00.0: System wakeup disabled by ACPI
[    4.486261] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15), disabled.
[    4.497020] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10 11 12 14 15), disabled.
[    4.507755] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 10 11 12 14 15), disabled.
[    4.518482] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 10 *11 12 14 15), disabled.
[    4.529218] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 *5 6 10 11 12 14 15), disabled.
[    4.539949] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 *11 12 14 15), disabled.
[    4.550669] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 *10 11 12 14 15), disabled.
[    4.561413] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10 11 12 14 15), disabled.
[    4.572355] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 80-fe])
[    4.579730] ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
[    4.587206] acpi PNP0A08:01: Requesting ACPI _OSC control (0x1d)
[    4.594804] acpi PNP0A08:01: ACPI _OSC control (0x15) granted
[    4.602291] PCI host bridge to bus 0000:80
[    4.607325] pci_bus 0000:80: root bus resource [bus 80-fe]
[    4.613925] pci_bus 0000:80: root bus resource [io  0xc000-0xffff]
[    4.621303] pci_bus 0000:80: root bus resource [mem 0xec000000-0xfbffffff]
[    4.629451] pci_bus 0000:80: root bus resource [mem 0x3c0080000000-0x3c00ffffffff]
[    4.638787] pci 0000:80:02.0: [8086:3c04] type 01 class 0x060400
[    4.646062] pci 0000:80:02.0: PME# supported from D0 D3hot D3cold
[    4.653396] pci 0000:80:04.0: [8086:3c20] type 00 class 0x088000
[    4.660589] pci 0000:80:04.0: reg 10: [mem 0xfbf70000-0xfbf73fff 64bit]
[    4.668555] pci 0000:80:04.1: [8086:3c21] type 00 class 0x088000
[    4.675748] pci 0000:80:04.1: reg 10: [mem 0xfbf60000-0xfbf63fff 64bit]
[    4.683727] pci 0000:80:04.2: [8086:3c22] type 00 class 0x088000
[    4.690927] pci 0000:80:04.2: reg 10: [mem 0xfbf50000-0xfbf53fff 64bit]
[    4.698917] pci 0000:80:04.3: [8086:3c23] type 00 class 0x088000
[    4.706111] pci 0000:80:04.3: reg 10: [mem 0xfbf40000-0xfbf43fff 64bit]
[    4.714099] pci 0000:80:04.4: [8086:3c24] type 00 class 0x088000
[    4.721304] pci 0000:80:04.4: reg 10: [mem 0xfbf30000-0xfbf33fff 64bit]
[    4.729286] pci 0000:80:04.5: [8086:3c25] type 00 class 0x088000
[    4.736480] pci 0000:80:04.5: reg 10: [mem 0xfbf20000-0xfbf23fff 64bit]
[    4.744457] pci 0000:80:04.6: [8086:3c26] type 00 class 0x088000
[    4.751649] pci 0000:80:04.6: reg 10: [mem 0xfbf10000-0xfbf13fff 64bit]
[    4.759630] pci 0000:80:04.7: [8086:3c27] type 00 class 0x088000
[    4.766833] pci 0000:80:04.7: reg 10: [mem 0xfbf00000-0xfbf03fff 64bit]
[    4.774810] pci 0000:80:05.0: [8086:3c28] type 00 class 0x088000
[    4.782106] pci 0000:80:05.2: [8086:3c2a] type 00 class 0x088000
[    4.789411] pci 0000:80:05.4: [8086:3c2c] type 00 class 0x080020
[    4.796604] pci 0000:80:05.4: reg 10: [mem 0xec000000-0xec000fff]
[    4.804050] pci 0000:80:02.0: PCI bridge to [bus 81]
[    4.810081] pci_bus 0000:80: on NUMA node 1 (pxm 1)
[    4.816023] ACPI: PCI Interrupt Routing Table [\_SB_.PCI1.BR44._PRT]
[    4.823637] pci 0000:80:02.0: System wakeup disabled by ACPI
[    4.836931] ACPI: PCI Root Bridge [UCR0] (domain 0000 [bus 7f])
[    4.844021] acpi PNP0A03:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    4.853812] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    4.863591] PCI host bridge to bus 0000:7f
[    4.868633] pci_bus 0000:7f: root bus resource [bus 7f]
[    4.874957] pci 0000:7f:08.0: [8086:3c80] type 00 class 0x088000
[    4.882207] pci 0000:7f:08.3: [8086:3c83] type 00 class 0x088000
[    4.889466] pci 0000:7f:08.4: [8086:3c84] type 00 class 0x088000
[    4.896725] pci 0000:7f:09.0: [8086:3c90] type 00 class 0x088000
[    4.903972] pci 0000:7f:09.3: [8086:3c93] type 00 class 0x088000
[    4.911236] pci 0000:7f:09.4: [8086:3c94] type 00 class 0x088000
[    4.918492] pci 0000:7f:0a.0: [8086:3cc0] type 00 class 0x088000
[    4.925729] pci 0000:7f:0a.1: [8086:3cc1] type 00 class 0x088000
[    4.932959] pci 0000:7f:0a.2: [8086:3cc2] type 00 class 0x088000
[    4.940190] pci 0000:7f:0a.3: [8086:3cd0] type 00 class 0x088000
[    4.947438] pci 0000:7f:0b.0: [8086:3ce0] type 00 class 0x088000
[    4.954675] pci 0000:7f:0b.3: [8086:3ce3] type 00 class 0x088000
[    4.961913] pci 0000:7f:0c.0: [8086:3ce8] type 00 class 0x088000
[    4.969145] pci 0000:7f:0c.1: [8086:3ce8] type 00 class 0x088000
[    4.976375] pci 0000:7f:0c.2: [8086:3ce8] type 00 class 0x088000
[    4.983617] pci 0000:7f:0c.3: [8086:3ce8] type 00 class 0x088000
[    4.990850] pci 0000:7f:0c.6: [8086:3cf4] type 00 class 0x088000
[    4.998089] pci 0000:7f:0c.7: [8086:3cf6] type 00 class 0x088000
[    5.005314] pci 0000:7f:0d.0: [8086:3ce8] type 00 class 0x088000
[    5.012541] pci 0000:7f:0d.1: [8086:3ce8] type 00 class 0x088000
[    5.019778] pci 0000:7f:0d.2: [8086:3ce8] type 00 class 0x088000
[    5.027014] pci 0000:7f:0d.3: [8086:3ce8] type 00 class 0x088000
[    5.034252] pci 0000:7f:0d.6: [8086:3cf5] type 00 class 0x088000
[    5.041484] pci 0000:7f:0e.0: [8086:3ca0] type 00 class 0x088000
[    5.048725] pci 0000:7f:0e.1: [8086:3c46] type 00 class 0x110100
[    5.055973] pci 0000:7f:0f.0: [8086:3ca8] type 00 class 0x088000
[    5.063242] pci 0000:7f:0f.1: [8086:3c71] type 00 class 0x088000
[    5.070504] pci 0000:7f:0f.2: [8086:3caa] type 00 class 0x088000
[    5.077771] pci 0000:7f:0f.3: [8086:3cab] type 00 class 0x088000
[    5.085021] pci 0000:7f:0f.4: [8086:3cac] type 00 class 0x088000
[    5.092279] pci 0000:7f:0f.5: [8086:3cad] type 00 class 0x088000
[    5.099535] pci 0000:7f:0f.6: [8086:3cae] type 00 class 0x088000
[    5.106779] pci 0000:7f:10.0: [8086:3cb0] type 00 class 0x088000
[    5.114041] pci 0000:7f:10.1: [8086:3cb1] type 00 class 0x088000
[    5.121297] pci 0000:7f:10.2: [8086:3cb2] type 00 class 0x088000
[    5.128546] pci 0000:7f:10.3: [8086:3cb3] type 00 class 0x088000
[    5.135800] pci 0000:7f:10.4: [8086:3cb4] type 00 class 0x088000
[    5.143069] pci 0000:7f:10.5: [8086:3cb5] type 00 class 0x088000
[    5.150338] pci 0000:7f:10.6: [8086:3cb6] type 00 class 0x088000
[    5.157587] pci 0000:7f:10.7: [8086:3cb7] type 00 class 0x088000
[    5.164839] pci 0000:7f:11.0: [8086:3cb8] type 00 class 0x088000
[    5.172097] pci 0000:7f:13.0: [8086:3ce4] type 00 class 0x088000
[    5.179339] pci 0000:7f:13.1: [8086:3c43] type 00 class 0x110100
[    5.186582] pci 0000:7f:13.4: [8086:3ce6] type 00 class 0x110100
[    5.193829] pci 0000:7f:13.5: [8086:3c44] type 00 class 0x110100
[    5.201058] pci 0000:7f:13.6: [8086:3c45] type 00 class 0x088000
[    5.208304] ACPI _OSC control for PCIe not granted, disabling ASPM
[    5.219957] ACPI: PCI Root Bridge [UCR1] (domain 0000 [bus ff])
[    5.227051] acpi PNP0A03:01: ACPI _OSC support notification failed, disabling PCIe ASPM
[    5.236850] acpi PNP0A03:01: Unable to request _OSC control (_OSC support mask: 0x08)
[    5.246604] PCI host bridge to bus 0000:ff
[    5.251660] pci_bus 0000:ff: root bus resource [bus ff]
[    5.257984] pci 0000:ff:08.0: [8086:3c80] type 00 class 0x088000
[    5.265227] pci 0000:ff:08.3: [8086:3c83] type 00 class 0x088000
[    5.272487] pci 0000:ff:08.4: [8086:3c84] type 00 class 0x088000
[    5.279750] pci 0000:ff:09.0: [8086:3c90] type 00 class 0x088000
[    5.286992] pci 0000:ff:09.3: [8086:3c93] type 00 class 0x088000
[    5.294246] pci 0000:ff:09.4: [8086:3c94] type 00 class 0x088000
[    5.301507] pci 0000:ff:0a.0: [8086:3cc0] type 00 class 0x088000
[    5.308739] pci 0000:ff:0a.1: [8086:3cc1] type 00 class 0x088000
[    5.315982] pci 0000:ff:0a.2: [8086:3cc2] type 00 class 0x088000
[    5.323217] pci 0000:ff:0a.3: [8086:3cd0] type 00 class 0x088000
[    5.330451] pci 0000:ff:0b.0: [8086:3ce0] type 00 class 0x088000
[    5.337681] pci 0000:ff:0b.3: [8086:3ce3] type 00 class 0x088000
[    5.344915] pci 0000:ff:0c.0: [8086:3ce8] type 00 class 0x088000
[    5.352150] pci 0000:ff:0c.1: [8086:3ce8] type 00 class 0x088000
[    5.359385] pci 0000:ff:0c.2: [8086:3ce8] type 00 class 0x088000
[    5.366621] pci 0000:ff:0c.3: [8086:3ce8] type 00 class 0x088000
[    5.383212] pci 0000:ff:0c.6: [8086:3cf4] type 00 class 0x088000
[    5.390445] pci 0000:ff:0c.7: [8086:3cf6] type 00 class 0x088000
[    5.397669] pci 0000:ff:0d.0: [8086:3ce8] type 00 class 0x088000
[    5.404905] pci 0000:ff:0d.1: [8086:3ce8] type 00 class 0x088000
[    5.412144] pci 0000:ff:0d.2: [8086:3ce8] type 00 class 0x088000
[    5.419376] pci 0000:ff:0d.3: [8086:3ce8] type 00 class 0x088000
[    5.426609] pci 0000:ff:0d.6: [8086:3cf5] type 00 class 0x088000
[    5.433846] pci 0000:ff:0e.0: [8086:3ca0] type 00 class 0x088000
[    5.441089] pci 0000:ff:0e.1: [8086:3c46] type 00 class 0x110100
[    5.448331] pci 0000:ff:0f.0: [8086:3ca8] type 00 class 0x088000
[    5.455596] pci 0000:ff:0f.1: [8086:3c71] type 00 class 0x088000
[    5.462860] pci 0000:ff:0f.2: [8086:3caa] type 00 class 0x088000
[    5.470121] pci 0000:ff:0f.3: [8086:3cab] type 00 class 0x088000
[    5.477378] pci 0000:ff:0f.4: [8086:3cac] type 00 class 0x088000
[    5.484639] pci 0000:ff:0f.5: [8086:3cad] type 00 class 0x088000
[    5.491903] pci 0000:ff:0f.6: [8086:3cae] type 00 class 0x088000
[    5.499144] pci 0000:ff:10.0: [8086:3cb0] type 00 class 0x088000
[    5.506405] pci 0000:ff:10.1: [8086:3cb1] type 00 class 0x088000
[    5.513667] pci 0000:ff:10.2: [8086:3cb2] type 00 class 0x088000
[    5.520926] pci 0000:ff:10.3: [8086:3cb3] type 00 class 0x088000
[    5.528182] pci 0000:ff:10.4: [8086:3cb4] type 00 class 0x088000
[    5.535442] pci 0000:ff:10.5: [8086:3cb5] type 00 class 0x088000
[    5.542696] pci 0000:ff:10.6: [8086:3cb6] type 00 class 0x088000
[    5.549953] pci 0000:ff:10.7: [8086:3cb7] type 00 class 0x088000
[    5.557207] pci 0000:ff:11.0: [8086:3cb8] type 00 class 0x088000
[    5.564459] pci 0000:ff:13.0: [8086:3ce4] type 00 class 0x088000
[    5.571697] pci 0000:ff:13.1: [8086:3c43] type 00 class 0x110100
[    5.578935] pci 0000:ff:13.4: [8086:3ce6] type 00 class 0x110100
[    5.586176] pci 0000:ff:13.5: [8086:3c44] type 00 class 0x110100
[    5.593412] pci 0000:ff:13.6: [8086:3c45] type 00 class 0x088000
[    5.600656] ACPI _OSC control for PCIe not granted, disabling ASPM
[    5.612714] ACPI: Enabled 6 GPEs in block 00 to 3F
[    5.622899] ACPI: No dock devices found.
[    5.628059] vgaarb: device added: PCI:0000:09:00.0,decodes=io+mem,owns=io+mem,locks=none
[    5.637980] vgaarb: loaded
[    5.641459] vgaarb: bridge control possible 0000:09:00.0
[    5.648185] SCSI subsystem initialized
[    5.652841] ACPI: bus type scsi registered
[    5.658148] libata version 3.00 loaded.
[    5.663139] ACPI: bus type usb registered
[    5.668248] usbcore: registered new interface driver usbfs
[    5.674927] usbcore: registered new interface driver hub
[    5.681426] usbcore: registered new device driver usb
[    5.687782] pps_core: LinuxPPS API ver. 1 registered
[    5.693798] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    5.704911] PTP clock support registered
[    5.710054] PCI: Using ACPI for IRQ routing
[    5.721952] PCI: pci_cache_line_size set to 64 bytes
[    5.728373] e820: reserve RAM buffer [mem 0x00090800-0x0009ffff]
[    5.735554] e820: reserve RAM buffer [mem 0xb9679000-0xbbffffff]
[    5.742731] e820: reserve RAM buffer [mem 0xb97ea000-0xbbffffff]
[    5.749908] e820: reserve RAM buffer [mem 0xbac8c000-0xbbffffff]
[    5.757085] e820: reserve RAM buffer [mem 0xbda01000-0xbfffffff]
[    5.764274] e820: reserve RAM buffer [mem 0xbdce0000-0xbfffffff]
[    5.771453] e820: reserve RAM buffer [mem 0xbe000000-0xbfffffff]
[    5.780034] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    5.788191] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    5.797226] Switching to clocksource hpet
[    5.818458] pnp: PnP ACPI init
[    5.822375] ACPI: bus type pnp registered
[    5.827426] pnp 00:00: [dma 4]
[    5.831410] pnp 00:00: Plug and Play ACPI device, IDs PNP0200 (active)
[    5.839297] pnp 00:01: Plug and Play ACPI device, IDs INT0800 (active)
[    5.847334] pnp 00:02: Plug and Play ACPI device, IDs PNP0103 (active)
[    5.855145] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0)
[    5.865152] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    5.873196] system 00:04: [io  0x0680-0x069f] has been reserved
[    5.880299] system 00:04: [io  0xffff] has been reserved
[    5.886715] system 00:04: [io  0xffff] has been reserved
[    5.893123] system 00:04: [io  0xffff] has been reserved
[    5.899548] system 00:04: [io  0x0400-0x0453] has been reserved
[    5.906631] system 00:04: [io  0x0458-0x047f] has been reserved
[    5.913721] system 00:04: [io  0x0500-0x057f] has been reserved
[    5.920815] system 00:04: [io  0x0600-0x061f] has been reserved
[    5.927900] system 00:04: [io  0x0ca2-0x0ca5] has been reserved
[    5.934989] system 00:04: [io  0x0cf9] could not be reserved
[    5.941794] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    5.949880] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)
[    5.959693] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
[    5.967691] system 00:06: [io  0x0454-0x0457] has been reserved
[    5.974791] system 00:06: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    5.984400] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)
[    5.994110] pnp 00:07: [dma 0 disabled]
[    5.999045] pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
[    6.007096] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)
[    6.016804] pnp 00:08: [dma 0 disabled]
[    6.021741] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    6.030433] system 00:09: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    6.038304] system 00:09: [mem 0xebfff000-0xebffffff] has been reserved
[    6.046167] system 00:09: [mem 0xc0000000-0xcfffffff] has been reserved
[    6.054046] system 00:09: [mem 0xfed20000-0xfed3ffff] has been reserved
[    6.061914] system 00:09: [mem 0xebffc000-0xebffdfff] has been reserved
[    6.069783] system 00:09: [mem 0xfbffe000-0xfbffffff] has been reserved
[    6.077657] system 00:09: [mem 0xfed45000-0xfed8ffff] has been reserved
[    6.085525] system 00:09: [mem 0xff000000-0xffffffff] could not be reserved
[    6.093781] system 00:09: [mem 0xfee00000-0xfeefffff] could not be reserved
[    6.102049] system 00:09: [mem 0xfec00000-0xfecfffff] could not be reserved
[    6.110307] system 00:09: [mem 0xd0c70000-0xd0c70fff] has been reserved
[    6.118170] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    6.126838] system 00:0a: [mem 0x00000000-0x0009cfff] could not be reserved
[    6.135110] system 00:0a: Plug and Play ACPI device, IDs PNP0c01 (active)
[    6.143664] pnp: PnP ACPI: found 11 devices
[    6.148809] ACPI: ACPI bus type pnp unregistered
[    6.168070] pci 0000:00:01.0: PCI bridge to [bus 01]
[    6.174105] pci 0000:00:02.0: PCI bridge to [bus 02]
[    6.180137] pci 0000:00:02.2: PCI bridge to [bus 03]
[    6.186162] pci 0000:00:03.0: PCI bridge to [bus 04]
[    6.192190] pci 0000:00:03.2: PCI bridge to [bus 05]
[    6.198222] pci 0000:00:11.0: PCI bridge to [bus 06]
[    6.204240] pci 0000:00:11.0:   bridge window [io  0x2000-0x2fff]
[    6.211533] pci 0000:00:11.0:   bridge window [mem 0xd0b00000-0xd0bfffff]
[    6.219589] pci 0000:00:11.0:   bridge window [mem 0xeb800000-0xebcfffff 64bit pref]
[    6.229092] pci 0000:00:1c.0: PCI bridge to [bus 07-08]
[    6.235405] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    6.242689] pci 0000:00:1c.0:   bridge window [mem 0xd0900000-0xd0afffff]
[    6.250749] pci 0000:00:1c.7: PCI bridge to [bus 09]
[    6.256766] pci 0000:00:1c.7:   bridge window [mem 0xd0000000-0xd08fffff]
[    6.264829] pci 0000:00:1c.7:   bridge window [mem 0xea000000-0xeaffffff 64bit pref]
[    6.274343] pci 0000:00:1e.0: PCI bridge to [bus 0a]
[    6.280377] pci 0000:80:02.0: PCI bridge to [bus 81]
[    6.286469] IOAPIC[1]: Set routing entry (1-23 -> 0x41 -> IRQ 47 Mode:1 Active:1 Dest:0)
[    6.296417] IOAPIC[0]: Set routing entry (0-16 -> 0x51 -> IRQ 16 Mode:1 Active:1 Dest:0)
[    6.306345] IOAPIC[0]: Set routing entry (0-19 -> 0x61 -> IRQ 19 Mode:1 Active:1 Dest:0)
[    6.316255] pci 0000:00:1e.0: setting latency timer to 64
[    6.322827] IOAPIC[2]: Set routing entry (2-23 -> 0x71 -> IRQ 71 Mode:1 Active:1 Dest:0)
[    6.332728] pci_bus 0000:00: resource 4 [io  0x0000-0xbfff]
[    6.339430] pci_bus 0000:00: resource 5 [mem 0x000a0000-0x000bffff]
[    6.346899] pci_bus 0000:00: resource 6 [mem 0x000c0000-0x000c3fff]
[    6.354375] pci_bus 0000:00: resource 7 [mem 0x000c4000-0x000c7fff]
[    6.361856] pci_bus 0000:00: resource 8 [mem 0x000c8000-0x000cbfff]
[    6.369338] pci_bus 0000:00: resource 9 [mem 0x000cc000-0x000cffff]
[    6.376811] pci_bus 0000:00: resource 10 [mem 0x000d8000-0x000dbfff]
[    6.384389] pci_bus 0000:00: resource 11 [mem 0x000dc000-0x000dffff]
[    6.391963] pci_bus 0000:00: resource 12 [mem 0x000e0000-0x000e3fff]
[    6.399533] pci_bus 0000:00: resource 13 [mem 0x000e4000-0x000e7fff]
[    6.407104] pci_bus 0000:00: resource 14 [mem 0x000e8000-0x000ebfff]
[    6.414682] pci_bus 0000:00: resource 15 [mem 0x000ec000-0x000effff]
[    6.422250] pci_bus 0000:00: resource 16 [mem 0x000f0000-0x000fffff]
[    6.429822] pci_bus 0000:00: resource 17 [mem 0xd0000000-0xebffffff]
[    6.437401] pci_bus 0000:00: resource 18 [mem 0x3c0000000000-0x3c007fffffff]
[    6.445745] pci_bus 0000:06: resource 0 [io  0x2000-0x2fff]
[    6.452453] pci_bus 0000:06: resource 1 [mem 0xd0b00000-0xd0bfffff]
[    6.459930] pci_bus 0000:06: resource 2 [mem 0xeb800000-0xebcfffff 64bit pref]
[    6.468855] pci_bus 0000:07: resource 0 [io  0x1000-0x1fff]
[    6.475557] pci_bus 0000:07: resource 1 [mem 0xd0900000-0xd0afffff]
[    6.483028] pci_bus 0000:09: resource 1 [mem 0xd0000000-0xd08fffff]
[    6.490498] pci_bus 0000:09: resource 2 [mem 0xea000000-0xeaffffff 64bit pref]
[    6.499423] pci_bus 0000:0a: resource 4 [io  0x0000-0xbfff]
[    6.506115] pci_bus 0000:0a: resource 5 [mem 0x000a0000-0x000bffff]
[    6.513590] pci_bus 0000:0a: resource 6 [mem 0x000c0000-0x000c3fff]
[    6.521073] pci_bus 0000:0a: resource 7 [mem 0x000c4000-0x000c7fff]
[    6.528549] pci_bus 0000:0a: resource 8 [mem 0x000c8000-0x000cbfff]
[    6.536024] pci_bus 0000:0a: resource 9 [mem 0x000cc000-0x000cffff]
[    6.543505] pci_bus 0000:0a: resource 10 [mem 0x000d8000-0x000dbfff]
[    6.551073] pci_bus 0000:0a: resource 11 [mem 0x000dc000-0x000dffff]
[    6.558646] pci_bus 0000:0a: resource 12 [mem 0x000e0000-0x000e3fff]
[    6.566216] pci_bus 0000:0a: resource 13 [mem 0x000e4000-0x000e7fff]
[    6.573790] pci_bus 0000:0a: resource 14 [mem 0x000e8000-0x000ebfff]
[    6.581373] pci_bus 0000:0a: resource 15 [mem 0x000ec000-0x000effff]
[    6.588948] pci_bus 0000:0a: resource 16 [mem 0x000f0000-0x000fffff]
[    6.596520] pci_bus 0000:0a: resource 17 [mem 0xd0000000-0xebffffff]
[    6.604093] pci_bus 0000:0a: resource 18 [mem 0x3c0000000000-0x3c007fffffff]
[    6.612445] pci_bus 0000:80: resource 4 [io  0xc000-0xffff]
[    6.619149] pci_bus 0000:80: resource 5 [mem 0xec000000-0xfbffffff]
[    6.626619] pci_bus 0000:80: resource 6 [mem 0x3c0080000000-0x3c00ffffffff]
[    6.644362] NET: Registered protocol family 2
[    6.650570] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    6.660996] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    6.669207] TCP: Hash tables configured (established 262144 bind 65536)
[    6.677132] TCP: reno registered
[    6.681312] UDP hash table entries: 16384 (order: 7, 524288 bytes)
[    6.688926] UDP-Lite hash table entries: 16384 (order: 7, 524288 bytes)
[    6.697324] NET: Registered protocol family 1
[    6.702841] RPC: Registered named UNIX socket transport module.
[    6.709925] RPC: Registered udp transport module.
[    6.715657] RPC: Registered tcp transport module.
[    6.721383] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    6.729160] IOAPIC[0]: Set routing entry (0-22 -> 0x81 -> IRQ 22 Mode:1 Active:1 Dest:0)
[    6.739132] IOAPIC[0]: Set routing entry (0-20 -> 0x91 -> IRQ 20 Mode:1 Active:1 Dest:0)
[    6.749145] pci 0000:09:00.0: Boot video device
[    6.754923] PCI: CLS 64 bytes, default 64
[    6.759933] Trying to unpack rootfs image as initramfs...
[   15.004420] Freeing initrd memory: 213164k freed
[   15.089763] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[   15.097457] software IO TLB [mem 0xb5679000-0xb9679000] (64MB) mapped at [ffff8800b5679000-ffff8800b9678fff]
[   15.114747] Scanning for low memory corruption every 60 seconds
[   15.127485] sha1_ssse3: Using AVX optimized SHA-1 implementation
[   15.191281] bounce pool size: 64 pages
[   15.195957] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   15.212820] VFS: Disk quotas dquot_6.5.2
[   15.217884] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   15.228495] NFS: Registering the id_resolver key type
[   15.234626] Key type id_resolver registered
[   15.239770] Key type id_legacy registered
[   15.244747] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   15.253154] ROMFS MTD (C) 2007 Red Hat, Inc.
[   15.258646] fuse init (API version 7.21)
[   15.263885] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[   15.277400] Btrfs loaded
[   15.280707] msgmni has been set to 32768
[   15.289346] NET: Registered protocol family 38
[   15.294796] Key type asymmetric registered
[   15.300072] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[   15.309298] io scheduler noop registered
[   15.314160] io scheduler deadline registered
[   15.319412] io scheduler cfq registered (default)
[   15.325745] pcieport 0000:00:01.0: irq 88 for MSI/MSI-X
[   15.332326] pcieport 0000:00:02.0: irq 89 for MSI/MSI-X
[   15.338877] pcieport 0000:00:02.2: irq 90 for MSI/MSI-X
[   15.345427] pcieport 0000:00:03.0: irq 91 for MSI/MSI-X
[   15.351972] pcieport 0000:00:03.2: irq 92 for MSI/MSI-X
[   15.358555] pcieport 0000:00:11.0: irq 93 for MSI/MSI-X
[   15.365116] pcieport 0000:00:1c.0: irq 94 for MSI/MSI-X
[   15.371673] pcieport 0000:00:1c.7: irq 95 for MSI/MSI-X
[   15.378331] pcieport 0000:80:02.0: irq 96 for MSI/MSI-X
[   15.385064] pcieport 0000:00:01.0: Signaling PME through PCIe PME interrupt
[   15.393329] pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
[   15.401321] pcieport 0000:00:02.0: Signaling PME through PCIe PME interrupt
[   15.409579] pcie_pme 0000:00:02.0:pcie01: service driver pcie_pme loaded
[   15.417584] pcieport 0000:00:02.2: Signaling PME through PCIe PME interrupt
[   15.425841] pcie_pme 0000:00:02.2:pcie01: service driver pcie_pme loaded
[   15.433830] pcieport 0000:00:03.0: Signaling PME through PCIe PME interrupt
[   15.442103] pcie_pme 0000:00:03.0:pcie01: service driver pcie_pme loaded
[   15.450097] pcieport 0000:00:03.2: Signaling PME through PCIe PME interrupt
[   15.458351] pcie_pme 0000:00:03.2:pcie01: service driver pcie_pme loaded
[   15.466338] pcieport 0000:00:11.0: Signaling PME through PCIe PME interrupt
[   15.474597] pci 0000:06:00.0: Signaling PME through PCIe PME interrupt
[   15.482364] pci 0000:06:00.3: Signaling PME through PCIe PME interrupt
[   15.490138] pcie_pme 0000:00:11.0:pcie01: service driver pcie_pme loaded
[   15.498133] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[   15.506380] pci 0000:07:00.0: Signaling PME through PCIe PME interrupt
[   15.514156] pci 0000:07:00.1: Signaling PME through PCIe PME interrupt
[   15.521929] pci 0000:07:00.2: Signaling PME through PCIe PME interrupt
[   15.529700] pci 0000:07:00.3: Signaling PME through PCIe PME interrupt
[   15.537488] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[   15.545477] pcieport 0000:00:1c.7: Signaling PME through PCIe PME interrupt
[   15.553733] pci 0000:09:00.0: Signaling PME through PCIe PME interrupt
[   15.561523] pcie_pme 0000:00:1c.7:pcie01: service driver pcie_pme loaded
[   15.569528] pcieport 0000:80:02.0: Signaling PME through PCIe PME interrupt
[   15.577782] pcie_pme 0000:80:02.0:pcie01: service driver pcie_pme loaded
[   15.585869] ioapic: probe of 0000:00:05.4 failed with error -22
[   15.592988] ioapic: probe of 0000:80:05.4 failed with error -22
[   15.600172] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   15.607113] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   15.615002] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[   15.623549] acpiphp: Slot [2] registered
[   15.628703] acpiphp: Slot [2-1] registered
[   15.634035] acpiphp: Slot [2-2] registered
[   15.639376] acpiphp: Slot [2-3] registered
[   15.644802] intel_idle: MWAIT substates: 0x21120
[   15.650428] intel_idle: v0.4 model 0x2D
[   15.655186] intel_idle: lapic_timer_reliable_states 0xffffffff
[   15.662608] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   15.671729] ACPI: Power Button [PWRF]
[   15.677560] ERST: Error Record Serialization Table (ERST) support is initialized.
[   15.687151] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
[   15.696321] EINJ: Error INJection is initialized.
[   15.702444] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   15.730586] 00:07: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   15.757998] 00:08: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[   15.766349] Non-volatile memory driver v1.3
[   15.777632] brd: module loaded
[   15.784419] loop: module loaded
[   15.788525] lkdtm: No crash points registered, enable through debugfs
[   15.796358] ACPI Warning: 0x0000000000000428-0x000000000000042f SystemIO conflicts with Region \PMIO 1 (20130117/utaddress-251)
[   15.810274] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   15.822507] ACPI Warning: 0x0000000000000530-0x000000000000053f SystemIO conflicts with Region \GPIO 1 (20130117/utaddress-251)
[   15.836365] ACPI Warning: 0x0000000000000530-0x000000000000053f SystemIO conflicts with Region \FBPC 2 (20130117/utaddress-251)
[   15.850244] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   15.862476] ACPI Warning: 0x0000000000000500-0x000000000000052f SystemIO conflicts with Region \GPIO 1 (20130117/utaddress-251)
[   15.876351] ACPI Warning: 0x0000000000000500-0x000000000000052f SystemIO conflicts with Region \FBPC 2 (20130117/utaddress-251)
[   15.890238] ACPI Warning: 0x0000000000000500-0x000000000000052f SystemIO conflicts with Region \_SI_.SIOR 3 (20130117/utaddress-251)
[   15.904610] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   15.916829] lpc_ich: Resource conflict(s) found affecting gpio_ich
[   15.924876] Loading iSCSI transport class v2.0-870.
[   15.932188] Adaptec aacraid driver 1.2-0[29801]-ms
[   15.938619] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[   15.946927] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driver: 8.04.00.08-k.
[   15.957138] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[   15.966301] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[   15.974656] megasas: 06.504.01.00-rc1 Mon. Oct. 1 17:00:00 PDT 2012
[   15.982343] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   15.989727] RocketRAID 3xxx/4xxx Controller driver v1.8
[   15.996535] ahci 0000:00:1f.2: version 3.0
[   16.001642] IOAPIC[0]: Set routing entry (0-21 -> 0x82 -> IRQ 21 Mode:1 Active:1 Dest:0)
[   16.011680] ahci 0000:00:1f.2: irq 97 for MSI/MSI-X
[   16.017634] ahci 0000:00:1f.2: forcing PORTS_IMPL to 0x3f
[   16.024227] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x3f impl SATA mode
[   16.034222] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems apst 
[   16.044020] ahci 0000:00:1f.2: setting latency timer to 64
[   16.052913] scsi0 : ahci
[   16.056471] scsi1 : ahci
[   16.060002] scsi2 : ahci
[   16.063533] scsi3 : ahci
[   16.067049] scsi4 : ahci
[   16.070567] scsi5 : ahci
[   16.074053] ata1: SATA max UDMA/133 abar m2048@0xd0c00000 port 0xd0c00100 irq 97
[   16.083167] ata2: SATA max UDMA/133 abar m2048@0xd0c00000 port 0xd0c00180 irq 97
[   16.092285] ata3: SATA max UDMA/133 abar m2048@0xd0c00000 port 0xd0c00200 irq 97
[   16.101403] ata4: SATA max UDMA/133 abar m2048@0xd0c00000 port 0xd0c00280 irq 97
[   16.109587] tsc: Refined TSC clocksource calibration: 2693.508 MHz
[   16.109591] Switching to clocksource tsc
[   16.122742] ata5: SATA max UDMA/133 abar m2048@0xd0c00000 port 0xd0c00300 irq 97
[   16.131861] ata6: SATA max UDMA/133 abar m2048@0xd0c00000 port 0xd0c00380 irq 97
[   16.142294] tun: Universal TUN/TAP device driver, 1.6
[   16.148406] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   16.156280] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
[   16.164635] Atheros(R) L2 Ethernet Driver - version 2.2.3
[   16.171140] Copyright (c) 2007 Atheros Corporation.
[   16.177608] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[   16.185673] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
[   16.185673]   http://www.scyld.com/network/drivers.html
[   16.200525] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[   16.208877] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   16.216158] e100: Copyright(c) 1999-2006 Intel Corporation
[   16.222863] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   16.240564] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   16.247578] e1000e: Intel(R) PRO/1000 Network Driver - 2.2.14-k
[   16.254674] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[   16.261893] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.1.2-k
[   16.270146] igb: Copyright (c) 2007-2013 Intel Corporation.
[   16.277277] igb 0000:07:00.0: irq 98 for MSI/MSI-X
[   16.283121] igb 0000:07:00.0: irq 99 for MSI/MSI-X
[   16.288965] igb 0000:07:00.0: irq 100 for MSI/MSI-X
[   16.294891] igb 0000:07:00.0: irq 101 for MSI/MSI-X
[   16.300825] igb 0000:07:00.0: irq 102 for MSI/MSI-X
[   16.306758] igb 0000:07:00.0: irq 103 for MSI/MSI-X
[   16.312690] igb 0000:07:00.0: irq 104 for MSI/MSI-X
[   16.318621] igb 0000:07:00.0: irq 105 for MSI/MSI-X
[   16.324569] igb 0000:07:00.0: irq 106 for MSI/MSI-X
[   16.330559] igb 0000:07:00.0: PHY reset is blocked due to SOL/IDER session.
[   16.396075] igb 0000:07:00.0: added PHC on eth0
[   16.401612] igb 0000:07:00.0: Intel(R) Gigabit Ethernet Network Connection
[   16.409760] igb 0000:07:00.0: eth0: (PCIe:5.0Gb/s:Width x4) 00:1e:67:23:d1:f6
[   16.418278] igb 0000:07:00.0: eth0: PBA No: 006600-000
[   16.424494] igb 0000:07:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   16.433853] IOAPIC[0]: Set routing entry (0-17 -> 0x73 -> IRQ 17 Mode:1 Active:1 Dest:0)
[   16.444136] igb 0000:07:00.1: irq 107 for MSI/MSI-X
[   16.450060] igb 0000:07:00.1: irq 108 for MSI/MSI-X
[   16.455998] igb 0000:07:00.1: irq 109 for MSI/MSI-X
[   16.461928] igb 0000:07:00.1: irq 110 for MSI/MSI-X
[   16.467864] igb 0000:07:00.1: irq 111 for MSI/MSI-X
[   16.473793] igb 0000:07:00.1: irq 112 for MSI/MSI-X
[   16.479724] igb 0000:07:00.1: irq 113 for MSI/MSI-X
[   16.485664] igb 0000:07:00.1: irq 114 for MSI/MSI-X
[   16.491595] igb 0000:07:00.1: irq 115 for MSI/MSI-X
[   16.573082] igb 0000:07:00.1: added PHC on eth1
[   16.578616] igb 0000:07:00.1: Intel(R) Gigabit Ethernet Network Connection
[   16.586773] igb 0000:07:00.1: eth1: (PCIe:5.0Gb/s:Width x4) 00:1e:67:23:d1:f7
[   16.595283] igb 0000:07:00.1: eth1: PBA No: 006600-000
[   16.601493] igb 0000:07:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   16.610863] IOAPIC[0]: Set routing entry (0-18 -> 0x54 -> IRQ 18 Mode:1 Active:1 Dest:0)
[   16.621143] igb 0000:07:00.2: irq 116 for MSI/MSI-X
[   16.627077] igb 0000:07:00.2: irq 117 for MSI/MSI-X
[   16.633013] igb 0000:07:00.2: irq 118 for MSI/MSI-X
[   16.638943] igb 0000:07:00.2: irq 119 for MSI/MSI-X
[   16.644873] igb 0000:07:00.2: irq 120 for MSI/MSI-X
[   16.650802] igb 0000:07:00.2: irq 121 for MSI/MSI-X
[   16.656738] igb 0000:07:00.2: irq 122 for MSI/MSI-X
[   16.662664] igb 0000:07:00.2: irq 123 for MSI/MSI-X
[   16.668597] igb 0000:07:00.2: irq 124 for MSI/MSI-X
[   16.754732] igb 0000:07:00.2: added PHC on eth2
[   16.760263] igb 0000:07:00.2: Intel(R) Gigabit Ethernet Network Connection
[   16.768412] igb 0000:07:00.2: eth2: (PCIe:5.0Gb/s:Width x4) 00:1e:67:23:d1:f8
[   16.776927] igb 0000:07:00.2: eth2: PBA No: 006600-000
[   16.783138] igb 0000:07:00.2: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   16.792881] igb 0000:07:00.3: irq 125 for MSI/MSI-X
[   16.798814] igb 0000:07:00.3: irq 126 for MSI/MSI-X
[   16.804745] igb 0000:07:00.3: irq 127 for MSI/MSI-X
[   16.810678] igb 0000:07:00.3: irq 128 for MSI/MSI-X
[   16.816610] igb 0000:07:00.3: irq 129 for MSI/MSI-X
[   16.822535] igb 0000:07:00.3: irq 130 for MSI/MSI-X
[   16.828480] igb 0000:07:00.3: irq 131 for MSI/MSI-X
[   16.834408] igb 0000:07:00.3: irq 132 for MSI/MSI-X
[   16.840334] igb 0000:07:00.3: irq 133 for MSI/MSI-X
[   16.926689] igb 0000:07:00.3: added PHC on eth3
[   16.932223] igb 0000:07:00.3: Intel(R) Gigabit Ethernet Network Connection
[   16.940377] igb 0000:07:00.3: eth3: (PCIe:5.0Gb/s:Width x4) 00:1e:67:23:d1:f9
[   16.948901] igb 0000:07:00.3: eth3: PBA No: 006600-000
[   16.955114] igb 0000:07:00.3: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
[   16.964551] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.11.33-k
[   16.974157] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[   16.981213] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[   16.989673] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   16.996737] sky2: driver version 1.30
[   17.002132] usbcore: registered new interface driver catc
[   17.008710] usbcore: registered new interface driver kaweth
[   17.015409] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
[   17.024701] usbcore: registered new interface driver pegasus
[   17.031570] usbcore: registered new interface driver rtl8150
[   17.038435] usbcore: registered new interface driver asix
[   17.045017] usbcore: registered new interface driver cdc_ether
[   17.052077] usbcore: registered new interface driver cdc_eem
[   17.058946] usbcore: registered new interface driver dm9601
[   17.065738] usbcore: registered new interface driver smsc75xx
[   17.072713] usbcore: registered new interface driver smsc95xx
[   17.079674] usbcore: registered new interface driver gl620a
[   17.086451] usbcore: registered new interface driver net1080
[   17.093319] usbcore: registered new interface driver plusb
[   17.099999] usbcore: registered new interface driver rndis_host
[   17.107162] usbcore: registered new interface driver cdc_subset
[   17.114324] usbcore: registered new interface driver zaurus
[   17.121112] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   17.130321] usbcore: registered new interface driver int51x1
[   17.137189] usbcore: registered new interface driver ipheth
[   17.143972] usbcore: registered new interface driver sierra_net
[   17.151134] usbcore: registered new interface driver cdc_ncm
[   17.157931] Fusion MPT base driver 3.04.20
[   17.162974] Copyright (c) 1999-2008 LSI Corporation
[   17.165066] ata4: failed to resume link (SControl 0)
[   17.165086] ata4: SATA link down (SStatus 0 SControl 0)
[   17.165102] ata2: failed to resume link (SControl 0)
[   17.165123] ata2: SATA link down (SStatus 0 SControl 0)
[   17.165139] ata1: failed to resume link (SControl 0)
[   17.165161] ata1: SATA link down (SStatus 0 SControl 0)
[   17.165179] ata5: failed to resume link (SControl 0)
[   17.165200] ata5: SATA link down (SStatus 0 SControl 0)
[   17.165216] ata3: failed to resume link (SControl 0)
[   17.165236] ata3: SATA link down (SStatus 0 SControl 0)
[   17.165251] ata6: failed to resume link (SControl 0)
[   17.165271] ata6: SATA link down (SStatus 0 SControl 0)
[   17.242688] Fusion MPT SPI Host driver 3.04.20
[   17.248275] Fusion MPT FC Host driver 3.04.20
[   17.253711] Fusion MPT SAS Host driver 3.04.20
[   17.259254] Fusion MPT misc device (ioctl) driver 3.04.20
[   17.265874] mptctl: Registered with Fusion MPT base driver
[   17.272483] mptctl: /dev/mptctl @ (major,minor=10,220)
[   17.279058] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   17.286831] ehci-pci: EHCI PCI platform driver
[   17.292329] ehci-pci 0000:00:1a.0: setting latency timer to 64
[   17.299324] ehci-pci 0000:00:1a.0: EHCI Host Controller
[   17.305763] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
[   17.314895] ehci-pci 0000:00:1a.0: debug port 2
[   17.324336] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[   17.332417] ehci-pci 0000:00:1a.0: irq 22, io mem 0xd0c20000
[   17.348984] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[   17.356210] hub 1-0:1.0: USB hub found
[   17.360870] hub 1-0:1.0: 2 ports detected
[   17.366058] ehci-pci 0000:00:1d.0: setting latency timer to 64
[   17.373056] ehci-pci 0000:00:1d.0: EHCI Host Controller
[   17.379499] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[   17.388640] ehci-pci 0000:00:1d.0: debug port 2
[   17.398091] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[   17.406173] ehci-pci 0000:00:1d.0: irq 20, io mem 0xd0c10000
[   17.424956] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[   17.432161] hub 2-0:1.0: USB hub found
[   17.436821] hub 2-0:1.0: 2 ports detected
[   17.442031] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   17.449512] uhci_hcd: USB Universal Host Controller Interface driver
[   17.457199] Initializing USB Mass Storage driver...
[   17.463229] usbcore: registered new interface driver usb-storage
[   17.470418] USB Mass Storage support registered.
[   17.476119] usbcore: registered new interface driver ums-alauda
[   17.483279] usbcore: registered new interface driver ums-datafab
[   17.490547] usbcore: registered new interface driver ums-freecom
[   17.497812] usbcore: registered new interface driver ums-isd200
[   17.504983] usbcore: registered new interface driver ums-jumpshot
[   17.512352] usbcore: registered new interface driver ums-sddr09
[   17.519510] usbcore: registered new interface driver ums-sddr55
[   17.526682] usbcore: registered new interface driver ums-usbat
[   17.533766] usbcore: registered new interface driver usbtest
[   17.540888] i8042: PNP: No PS/2 controller found. Probing ports directly.
[   17.676836] usb 1-1: new high-speed USB device number 2 using ehci-pci
[   17.813515] hub 1-1:1.0: USB hub found
[   17.818281] hub 1-1:1.0: 6 ports detected
[   17.932723] usb 2-1: new high-speed USB device number 2 using ehci-pci
[   18.058888] i8042: Can't read CTR while initializing i8042
[   18.065488] i8042: probe of i8042 failed with error -5
[   18.069392] hub 2-1:1.0: USB hub found
[   18.069541] hub 2-1:1.0: 8 ports detected
[   18.081606] mousedev: PS/2 mouse device common for all mice
[   18.088731] rtc_cmos 00:05: RTC can wake from S4
[   18.094589] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[   18.101902] rtc_cmos 00:05: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[   18.111495] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   18.118243] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[   18.128030] iTCO_vendor_support: vendor-support=0
[   18.133983] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[   18.147187] md: linear personality registered for level -1
[   18.153799] md: raid0 personality registered for level 0
[   18.160201] md: raid1 personality registered for level 1
[   18.166608] md: raid10 personality registered for level 10
[   18.182576] md: raid6 personality registered for level 6
[   18.188977] md: raid5 personality registered for level 5
[   18.195382] md: raid4 personality registered for level 4
[   18.201787] md: multipath personality registered for level -4
[   18.208692] md: faulty personality registered for level -5
[   18.215636] device-mapper: ioctl: 4.23.1-ioctl (2012-12-18) initialised: dm-devel@redhat.com
[   18.226231] device-mapper: multipath: version 1.5.0 loaded
[   18.232834] device-mapper: multipath round-robin: version 1.0.0 loaded
[   18.240611] EDAC MC: Ver: 3.0.0
[   18.245231] Intel P-state driver initializing.
[   18.250685] Intel pstate controlling: cpu 0
[   18.255840] Intel pstate controlling: cpu 1
[   18.260972] Intel pstate controlling: cpu 2
[   18.266106] Intel pstate controlling: cpu 3
[   18.271241] Intel pstate controlling: cpu 4
[   18.276369] Intel pstate controlling: cpu 5
[   18.281501] Intel pstate controlling: cpu 6
[   18.286640] Intel pstate controlling: cpu 7
[   18.291771] Intel pstate controlling: cpu 8
[   18.296899] Intel pstate controlling: cpu 9
[   18.302045] Intel pstate controlling: cpu 10
[   18.307284] Intel pstate controlling: cpu 11
[   18.312520] Intel pstate controlling: cpu 12
[   18.317758] Intel pstate controlling: cpu 13
[   18.322988] Intel pstate controlling: cpu 14
[   18.328222] Intel pstate controlling: cpu 15
[   18.333447] Intel pstate controlling: cpu 16
[   18.338675] Intel pstate controlling: cpu 17
[   18.340662] usb 2-1.2: new low-speed USB device number 3 using ehci-pci
[   18.351744] Intel pstate controlling: cpu 18
[   18.356973] Intel pstate controlling: cpu 19
[   18.362209] Intel pstate controlling: cpu 20
[   18.367450] Intel pstate controlling: cpu 21
[   18.372668] Intel pstate controlling: cpu 22
[   18.377899] Intel pstate controlling: cpu 23
[   18.383130] Intel pstate controlling: cpu 24
[   18.388362] Intel pstate controlling: cpu 25
[   18.393592] Intel pstate controlling: cpu 26
[   18.398819] Intel pstate controlling: cpu 27
[   18.404060] Intel pstate controlling: cpu 28
[   18.409284] Intel pstate controlling: cpu 29
[   18.414528] Intel pstate controlling: cpu 30
[   18.419756] Intel pstate controlling: cpu 31
[   18.425666] cpuidle: using governor ladder
[   18.431550] cpuidle: using governor menu
[   18.436599] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   18.447376] usbcore: registered new interface driver usbhid
[   18.454064] usbhid: USB HID core driver
[   18.459025] TCP: bic registered
[   18.462985] Initializing XFRM netlink socket
[   18.468533] NET: Registered protocol family 10
[   18.474351] sit: IPv6 over IPv4 tunneling driver
[   18.480263] NET: Registered protocol family 17
[   18.485700] 8021q: 802.1Q VLAN Support v1.8
[   18.491098] sctp: Hash tables configured (established 65536 bind 65536)
[   18.499070] Key type dns_resolver registered
[   18.506822] 
[   18.506822] printing PIC contents
[   18.513001] ... PIC  IMR: ffff
[   18.516856] ... PIC  IRR: 0c20
[   18.520721] ... PIC  ISR: 0000
[   18.524582] ... PIC ELCR: 0e20
[   18.528441] printing local APIC contents on CPU#0/0:
[   18.534435] ... APIC ID:      00000000 (0)
[   18.539463] ... APIC VERSION: 01060015
[   18.544105] ... APIC TASKPRI: 00000000 (00)
[   18.549223] ... APIC PROCPRI: 00000000
[   18.553854] ... APIC LDR: 01000000
[   18.558089] ... APIC DFR: ffffffff
[   18.562324] ... APIC SPIV: 000001ff
[   18.566658] ... APIC ISR field:
[   18.570608] 0000000000000000000000000000000000000000000000000000000000000000
[   18.579574] ... APIC TMR field:
[   18.583522] 0000000000000000000200020000000000020002000000000000000000000000
[   18.592484] ... APIC IRR field:
[   18.596427] 0000000000000000000000000000000000020000000000000000000000000000
[   18.605384] ... APIC ESR: 00000000
[   18.609624] ... APIC ICR: 000000fd
[   18.613862] ... APIC ICR2: 28000000
[   18.618194] ... APIC LVTT: 000400ef
[   18.622527] ... APIC LVTPC: 00000400
[   18.626959] ... APIC LVT0: 00010700
[   18.631292] ... APIC LVT1: 00000400
[   18.635623] ... APIC LVTERR: 000000fe
[   18.640151] ... APIC TMICT: 00000000
[   18.644583] ... APIC TMCCT: 00000000
[   18.649012] ... APIC TDCR: 00000000
[   18.653349] 
[   18.655449] number of MP IRQ sources: 15.
[   18.655707] input: ATEN ATEN  CS-1758/54 as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2:1.0/input/input1
[   18.655815] hid-generic 0003:0557:2220.0001: input: USB HID v1.10 Keyboard [ATEN ATEN  CS-1758/54] on usb-0000:00:1d.0-1.2/in1d.0/usb2/2-1/2-1.2/2-1.2:1.1/input/input2
[   18.684724] hid-generic 0003:0557:2220.0002: input: USB HID v1.10 Mouse [ATEN ATEN  CS-1758/54] on usb-0000:00:1d.0-1.2/input1
[   18.712543] number of IO-APIC #0 registers: 24.
[   18.718052] number of IO-APIC #1 registers: 24.
[   18.723562] number of IO-APIC #2 registers: 24.
[   18.729075] testing the IO APIC.......................
[   18.735272] IO APIC #0......
[   18.738935] .... register #00: 00000000
[   18.743671] .......    : physical APIC id: 00
[   18.748977] .......    : Delivery Type: 0
[   18.753905] .......    : LTS         -speed USB device number 4 using ehci-pci
[   18.766759] .... register #01: 00170020
[   18.771482] .......     : max redirection entries: 17
[   18.777569] .......     : PRQ implemented: 0
[   18.782788] .......     : IO APIC version: 20
[   18.788095] .... IRQ redirection table:
[   18.792813] 1    0    0   0   0    0    0    00
[   18.798325] 0    0    0   0   0    0    0    31
[   18.803838] 0    0    0   0   0    0    0    30
[   18.809343] 0    0    0   0   0    0    0    33
[   18.814857] 0    0    0   0   0    0    0    34
[   18.820375] 0    0    0   0   0    0    0    35
[   18.825887] 0    0    0   0  
[   18.831399] 0    0    0   0   0    0    0    37
[   18.836912] 0    0    0   0   0    0    0    38
[   18.842422] 0    1    0   0   0    0    0    39
[   18.847926] 0    0    0   0   0    0    0    3A
[   18.853424] 0    0    0   0   0    0    0    3B
[   18.854676] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/input/input3
[   18.854792] hid-generic 0003:046B:FF10.0003: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1d.0-1.4/input0
[   18.855784] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.1/input/input4
[   18.855993] hid-generic 0003:046B:FF10.0004: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1d.0-1.4/input1
[   18.923109] 0    0    0   0   0    0    0    3C
[   18.928631] 0    0    0   0   0    0    0    3D
[   18.934143] 0    0    0   0   0    0    0    3E
[   18.939655] 0    0    0   0   0    0    0    3F
[   18.945175] 1    1    0   1   0    0    0    51
[   18.950680] 1    1    0   1   0    0    0    73
[   18.956197] 1    1    0   1   0    0    0    54
[   18.961710] 1    1    0   1   0    0    0    61
[   18.967225] 0    1    0   1   0    0    0    91
[   18.972729] 1    1    0   1   0    0    0    82
[   18.978240] 0    1    0   1   0    0    0    81
[   18.983751] 1    0    0   0   0    0    0    00
[   18.989254] IO APIC #1......
[   18.992914] .... register #00: 01000000
[   18.997647] .......    : physical APIC id: 01
[   19.002953] .......    : Delivery Type: 0
[   19.007878] .......    : LTS          : 0
[   19.012806] .... register #01: 00170020
[   19.017533] .......     : max redirection entries: 17
[   19.023626] .......     : PRQ implemented: 0
[   19.028845] .......     : IO APIC version: 20
[   19.034158] .... register #02: 00000000
[   19.038887] .......     : arbitration: 00
[   19.043813] .... register #03: 00000001
[   19.048554] .......     : Boot DT    : 1
[   19.053377] .... IRQ redirection table:
[   19.058112] 1    0    0   0   0    0    0    00
[   19.063622] 1    0    0   0   0    0    0    00
[   19.069125] 1    0    0   0   0    0    0    00
[   19.074639] 1    0    0   0   0    0    0    00
[   19.080153] 1    0    0   0   0    0    0    00
[   19.085655] 1    0    0   0   0    0    0    00
[   19.091166] 1    0    0   0   0    0    0    00
[   19.096670] 1    0    0   0   0    0    0    00
[   19.102179] 1    0    0   0   0    0    0    00
[   19.107689] 1    0    0   0   0    0    0    00
[   19.113206] 1    0    0   0   0    0    0    00
[   19.118717] 1    0    0   0   0    0    0    00
[   19.124229] 1    0    0   0   0    0    0    00
[   19.129741] 1    0    0   0   0    0    0    00
[   19.135252] 1    0    0   0   0    0    0    00
[   19.140773] 1    0    0   0   0    0    0    00
[   19.146282] 1    0    0   0   0    0    0    00
[   19.151789] 1    0    0   0   0    0    0    00
[   19.157300] 1    0    0   0   0    0    0    00
[   19.171881] 1    0    0   0   0    0    0    00
[   19.177393] 1    0    0   0   0    0    0    00
[   19.182901] 1    0    0   0   0    0    0    00
[   19.188410] 1    0    0   0   0    0    0    00
[   19.193922] 1    1    0   1   0    0    0    41
[   19.199435] IO APIC #2......
[   19.203096] .... register #00: 02000000
[   19.207829] .......    : physical APIC id: 02
[   19.213155] .......    : Delivery Type: 0
[   19.218084] .......    : LTS          : 0
[   19.223013] .... register #01: 00170020
[   19.227744] .......     : max redirection entries: 17
[   19.233843] .......     : PRQ implemented: 0
[   19.239061] .......     : IO APIC version: 20
[   19.244373] .... register #02: 00000000
[   19.249100] .......     : arbitration: 00
[   19.254027] .... register #03: 00000001
[   19.258762] .......     : Boot DT    : 1
[   19.263590] .... IRQ redirection table:
[   19.268324] 1    0    0   0   0    0    0    00
[   19.273836] 1    0    0   0   0    0    0    00
[   19.279345] 1    0    0   0   0    0    0    00
[   19.284859] 1    0    0   0   0    0    0    00
[   19.290367] 1    0    0   0   0    0    0    00
[   19.295882] 1    0    0   0   0    0    0    00
[   19.301393] 1    0    0   0   0    0    0    00
[   19.306905] 1    0    0   0   0    0    0    00
[   19.312414] 1    0    0   0   0    0    0    00
[   19.317931] 1    0    0   0   0    0    0    00
[   19.323442] 1    0    0   0   0    0    0    00
[   19.328953] 1    0    0   0   0    0    0    00
[   19.334465] 1    0    0   0   0    0    0    00
[   19.339977] 1    0    0   0   0    0    0    00
[   19.345498] 1    0    0   0   0    0    0    00
[   19.351010] 1    0    0   0   0    0    0    00
[   19.356515] 1    0    0   0   0    0    0    00
[   19.362023] 1    0    0   0   0    0    0    00
[   19.367532] 1    0    0   0   0    0    0    00
[   19.373034] 1    0    0   0   0    0    0    00
[   19.378545] 1    0    0   0   0    0    0    00
[   19.384051] 1    0    0   0   0    0    0    00
[   19.389562] 1    0    0   0   0    0    0    00
[   19.395074] 1    1    0   1   0    0    0    71
[   19.400584] IRQ to pin mappings:
[   19.404628] IRQ0 -> 0:2
[   19.407954] IRQ1 -> 0:1
[   19.411284] IRQ3 -> 0:3
[   19.414602] IRQ4 -> 0:4
[   19.417928] IRQ5 -> 0:5
[   19.421257] IRQ6 -> 0:6
[   19.424576] IRQ7 -> 0:7
[   19.427899] IRQ8 -> 0:8
[   19.431225] IRQ9 -> 0:9
[   19.434545] IRQ10 -> 0:10
[   19.438056] IRQ11 -> 0:11
[   19.441569] IRQ12 -> 0:12
[   19.445095] IRQ13 -> 0:13
[   19.448616] IRQ14 -> 0:14
[   19.452138] IRQ15 -> 0:15
[   19.455656] IRQ16 -> 0:16
[   19.459177] IRQ17 -> 0:17
[   19.462699] IRQ18 -> 0:18
[   19.466213] IRQ19 -> 0:19
[   19.469725] IRQ20 -> 0:20
[   19.473240] IRQ21 -> 0:21
[   19.476760] IRQ22 -> 0:22
[   19.480267] IRQ47 -> 1:23
[   19.483786] IRQ71 -> 2:23
[   19.487304] .................................... done.
[   19.493783] PM: Hibernation image not present or could not be loaded.
[   19.501481] registered taskstats version 1
[   19.509666] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   19.516846] EDD information not available.
[   19.602395] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   19.611246] 8021q: adding VLAN 0 to HW filter on device eth0
[   19.712099] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   19.719141] 8021q: adding VLAN 0 to HW filter on device eth1
[   19.820036] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready
[   19.827001] 8021q: adding VLAN 0 to HW filter on device eth2
[   19.927978] IPv6: ADDRCONF(NETDEV_UP): eth3: link is not ready
[   19.934941] 8021q: adding VLAN 0 to HW filter on device eth3
[   19.955797] Sending DHCP requests ., OK
[   19.992866] IP-Config: Got DHCP answer from 192.168.1.1, my address is 192.168.1.164
[   20.184920] IP-Config: Complete:
[   20.189045]      device=eth0, hwaddr=00:1e:67:23:d1:f6, ipaddr=192.168.1.164, mask=255.255.255.0, gw=192.168.1.1
[   20.201311]      host=lkp-snb01, domain=lkp.intel.com, nis-domain=(none)
[   20.209296]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
[   20.216899]      nameserver0=192.168.1.1
[   20.223249] Freeing unused kernel memory: 1260k freed
[   20.230287] Write protecting the kernel read-only data: 14336k
[   20.239882] Freeing unused kernel memory: 424k freed
[   20.247474] Freeing unused kernel memory: 364k freed
[   20.538050] ACPI: Requesting acpi_cpufreq
[   20.645321] microcode: CPU0 sig=0x206d6, pf=0x1, revision=0x603
[   20.699559] microcode: CPU1 sig=0x206d6, pf=0x1, revision=0x603
[   20.712440] microcode: CPU2 sig=0x206d6, pf=0x1, revision=0x603
[   20.725434] microcode: CPU3 sig=0x206d6, pf=0x1, revision=0x603
[   20.738490] microcode: CPU4 sig=0x206d6, pf=0x1, revision=0x603
[   20.751609] microcode: CPU5 sig=0x206d6, pf=0x1, revision=0x603
[   20.764699] microcode: CPU6 sig=0x206d6, pf=0x1, revision=0x603
[   20.777700] microcode: CPU7 sig=0x206d6, pf=0x1, revision=0x603
[   20.790598] microcode: CPU8 sig=0x206d6, pf=0x1, revision=0x603
[   20.803702] microcode: CPU9 sig=0x206d6, pf=0x1, revision=0x603
[   20.816702] microcode: CPU10 sig=0x206d6, pf=0x1, revision=0x603
[   20.829861] microcode: CPU11 sig=0x206d6, pf=0x1, revision=0x603
[   20.843077] microcode: CPU12 sig=0x206d6, pf=0x1, revision=0x603
[   20.856440] microcode: CPU13 sig=0x206d6, pf=0x1, revision=0x603
[   20.869598] microcode: CPU14 sig=0x206d6, pf=0x1, revision=0x603
[   20.882759] microcode: CPU15 sig=0x206d6, pf=0x1, revision=0x603
[   20.895981] microcode: CPU16 sig=0x206d6, pf=0x1, revision=0x603
[   20.909158] microcode: CPU17 sig=0x206d6, pf=0x1, revision=0x603
[   20.922289] microcode: CPU18 sig=0x206d6, pf=0x1, revision=0x603
[   20.935340] microcode: CPU19 sig=0x206d6, pf=0x1, revision=0x603
[   20.948579] microcode: CPU20 sig=0x206d6, pf=0x1, revision=0x603
[   20.962261] microcode: CPU21 sig=0x206d6, pf=0x1, revision=0x603
[   20.975261] microcode: CPU22 sig=0x206d6, pf=0x1, revision=0x603
[   20.988579] microcode: CPU23 sig=0x206d6, pf=0x1, revision=0x603
[   21.001656] microcode: CPU24 sig=0x206d6, pf=0x1, revision=0x603
[   21.014766] microcode: CPU25 sig=0x206d6, pf=0x1, revision=0x603
[   21.028119] microcode: CPU26 sig=0x206d6, pf=0x1, revision=0x603
[   21.041234] microcode: CPU27 sig=0x206d6, pf=0x1, revision=0x603
[   21.054719] microcode: CPU28 sig=0x206d6, pf=0x1, revision=0x603
[   21.068247] microcode: CPU29 sig=0x206d6, pf=0x1, revision=0x603
[   21.081507] microcode: CPU30 sig=0x206d6, pf=0x1, revision=0x603
[   21.094793] microcode: CPU31 sig=0x206d6, pf=0x1, revision=0x603
[   21.108293] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba

==> /lkp/lkp/src/tmp/run_log <==
Kernel tests: Boot OK!
PATH=/sbin:/usr/sbin:/bin:/usr/bin

==> /lkp/lkp/src/tmp/err_log <==

==> /lkp/lkp/src/tmp/run_log <==
downloading latest lkp src code
Kernel tests: Boot OK 2!
/lkp/lkp/src/bin/run-lkp
LKP_SRC_DIR=/lkp/lkp/src
RESULT_ROOT=/lkp/result/lkp-snb01/micro/aim7/shared/x86_64-lkp/e8d1955258091e4c92d5a975ebd7fd8a98f5d30f/0
job=/lkp/scheduled/lkp-snb01/bisect_aim7-shared-x86_64-lkp-e8d1955258091e4c92d5a975ebd7fd8a98f5d30f-0.yaml
run-job /lkp/scheduled/lkp-snb01/bisect_aim7-shared-x86_64-lkp-e8d1955258091e4c92d5a975ebd7fd8a98f5d30f-0.yaml
run: pre-test
run: /lkp/lkp/src/monitors/wrapper sched_debug{}
run: /lkp/lkp/src/monitors/event/wait pre-test{}
run: /lkp/lkp/src/monitors/wrapper uptime{}
run: /lkp/lkp/src/monitors/wrapper iostat{}
run: /lkp/lkp/src/monitors/wrapper vmstat{}
run: /lkp/lkp/src/monitors/wrapper numa-numastat{}
run: /lkp/lkp/src/monitors/wrapper numa-vmstat{}
run: /lkp/lkp/src/monitors/wrapper numa-meminfo{}
run: /lkp/lkp/src/monitors/wrapper proc-vmstat{}
run: /lkp/lkp/src/monitors/wrapper meminfo{}
run: /lkp/lkp/src/monitors/wrapper slabinfo{}
run: /lkp/lkp/src/monitors/wrapper interrupts{}
run: /lkp/lkp/src/monitors/wrapper lock_stat{}
run: /lkp/lkp/src/monitors/wrapper softirqs{}
run: /lkp/lkp/src/monitors/wrapper bdi_dev_mapping{}
run: /lkp/lkp/src/monitors/wrapper pmeter{}
run: /lkp/lkp/src/monitors/wrapper diskstats{}
run: /lkp/lkp/src/monitors/wrapper zoneinfo{}
run: /lkp/lkp/src/monitors/wrapper energy{}
run: /usr/bin/time -v -o /lkp/lkp/src/tmp/time /lkp/lkp/src/tests/micro/wrapper aim7{"workfile"=>"workfile.shared"}
geting new job...
downloading kernel image ...
downloading initrds ...
kexecing...
kexec -l /tmp//kernel/x86_64-lkp/v3.14-rc1/vmlinuz-3.14.0-rc1 --initrd=/tmp/initrd-1497 --append="user=lkp job=/lkp/scheduled/lkp-snb01/cyclic_will-it-scale-write1-BASE.yaml ARCH=x86_64 BOOT_IMAGE=/kernel/x86_64-lkp/v3.14-rc1/vmlinuz-3.14.0-rc1 kconfig=x86_64-lkp commit=v3.14-rc1 bm_initrd=/lkp/benchmarks/will-it-scale.cgz modules_initrd=/kernel/x86_64-lkp/38dbfb59d1175ef458d006556061adeaa8751b72/modules.cgz max_uptime=900 RESULT_ROOT=/lkp/result/lkp-snb01/micro/will-it-scale/write1/x86_64-lkp/38dbfb59d1175ef458d006556061adeaa8751b72/2 initrd=/kernel-tests/initrd/lkp-rootfs.cgz root=/dev/ram0 ip=::::lkp-snb01::dhcp oops=panic earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled panic=10 softlockup_panic=1 nmi_watchdog=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal"
[   94.580267] kvm: exiting hardware virtualization
[   94.622718] Starting new kernearly console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc1 (kbuild@cairo) (gcc version 4.8.1 (Debian 4.8.1-8) ) #1 SMP Tue Feb 4 21:00:02 CST 2014

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.8.0-06530-ge8d1955"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.8.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_FHANDLE is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_ALWAYS_USE_PERSISTENT_CLOCK=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_ARCH_USES_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is not set
CONFIG_NUMA_BALANCING=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_MEMCG_KMEM=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_EXPERT=y
CONFIG_HAVE_UID16=y
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_UPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_GENERIC_SIGALTSTACK=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_THROTTLING=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_PARAVIRT_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=512
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=m
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=m
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
CONFIG_ACPI_APEI_EINJ=y
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_SPEEDSTEP_CENTRINO=m
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=m
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_IP_MROUTE=y
# CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
# CONFIG_TCP_CONG_CUBIC is not set
# CONFIG_TCP_CONG_WESTWOOD is not set
# CONFIG_TCP_CONG_HTCP is not set
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
# CONFIG_TCP_CONG_VEGAS is not set
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=y
# CONFIG_NET_SCTPPROBE is not set
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_TCPPROBE is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ATMEL_SSC is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_ISCSI_BOOT_SYSFS is not set
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=4
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
# CONFIG_SCSI_MPT3SAS_LOGGING is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_HIGHBANK is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PCMCIA is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
# CONFIG_MULTICORE_RAID456 is not set
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_MIRROR=y
# CONFIG_DM_RAID is not set
# CONFIG_DM_LOG_USERSPACE is not set
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
CONFIG_DM_DELAY=y
# CONFIG_DM_UEVENT is not set
CONFIG_DM_FLAKEY=y
# CONFIG_DM_VERITY is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=40
CONFIG_FUSION_CTL=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
CONFIG_MII=y
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
CONFIG_TUN=y
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
CONFIG_PCNET32=y
# CONFIG_PCMCIA_NMCLAN is not set
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
# CONFIG_CNIC is not set
CONFIG_TIGON3=y
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
# CONFIG_DE2104X is not set
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=y
CONFIG_WINBOND_840=y
CONFIG_DM9102=y
CONFIG_ULI526X=y
# CONFIG_PCMCIA_XIRCOM is not set
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_IXGBEVF is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
CONFIG_NE2K_PCI=y
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
# CONFIG_8139TOO_8129 is not set
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
CONFIG_VIA_RHINE=y
# CONFIG_VIA_RHINE_MMIO is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_CDC_MBIM is not set
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
# CONFIG_PCMCIA_RAYCS is not set
# CONFIG_AIRO is not set
# CONFIG_ATMEL is not set
# CONFIG_AIRO_CS is not set
# CONFIG_PCMCIA_WL3501 is not set
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
# CONFIG_HOSTAP is not set
# CONFIG_WL_TI is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_UINPUT is not set
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
# CONFIG_N_HDLC is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y
# CONFIG_STALDRV is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_INTEL_MID is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IBMAEM is not set
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_FAIR_SHARE is not set
CONFIG_STEP_WISE=y
# CONFIG_USER_SPACE is not set
# CONFIG_CPU_THERMAL is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_LPC_SCH is not set
CONFIG_LPC_ICH=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_STUB_POULSBO is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_EXYNOS_VIDEO is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SONY is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_DWC3 is not set
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
# CONFIG_OMAP_USB3 is not set
# CONFIG_OMAP_CONTROL_USB is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_RCAR_PHY is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_E752X=y
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I7CORE is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
# CONFIG_EDAC_SBRIDGE is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_DS2404 is not set

#
# on-CPU RTC drivers
#

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_Q10 is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_EFI_VARS is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
CONFIG_GENERIC_ACL=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_F2FS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_ACL is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB2 is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_CPU_STALL_INFO is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_LKDTM=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_DYNAMIC_DEBUG=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_SET_MODULE_RONX=y
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_X86_64=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
# CONFIG_X509_CERTIFICATE_PARSER is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
# CONFIG_KVM_AMD is not set
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
CONFIG_MPILIB=y

--gKMricLos+KVdGMg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
