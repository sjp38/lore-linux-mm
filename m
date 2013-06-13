Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 46BBA90000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:05 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Date: Thu, 13 Jun 2013 21:02:47 +0800
Message-Id: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Yinghai Lu <yinghai@kernel.org>

No offence, just rebase and resend the patches from Yinghai to help
to push this functionality faster.
Also improve the comments in the patches' log.


One commit that tried to parse SRAT early get reverted before v3.9-rc1.

| commit e8d1955258091e4c92d5a975ebd7fd8a98f5d30f
| Author: Tang Chen <tangchen@cn.fujitsu.com>
| Date:   Fri Feb 22 16:33:44 2013 -0800
|
|    acpi, memory-hotplug: parse SRAT before memblock is ready

It broke several things, like acpi override and fall back path etc.

This patchset is clean implementation that will parse numa info early.
1. keep the acpi table initrd override working by split finding with copying.
   finding is done at head_32.S and head64.c stage,
        in head_32.S, initrd is accessed in 32bit flat mode with phys addr.
        in head64.c, initrd is accessed via kernel low mapping address
        with help of #PF set page table.
   copying is done with early_ioremap just after memblock is setup.
2. keep fallback path working. numaq and ACPI and amd_nmua and dummy.
   seperate initmem_init to two stages.
   early_initmem_init will only extract numa info early into numa_meminfo.
   initmem_init will keep slit and emulation handling.
3. keep other old code flow untouched like relocate_initrd and initmem_init.
   early_initmem_init will take old init_mem_mapping position.
   it call early_x86_numa_init and init_mem_mapping for every nodes.
   For 64bit, we avoid having size limit on initrd, as relocate_initrd
   is still after init_mem_mapping for all memory.
4. last patch will try to put page table on local node, so that memory
   hotplug will be happy.

In short, early_initmem_init will parse numa info early and call
init_mem_mapping to set page table for every nodes's mem.

could be found at:
        git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git for-x86-mm

and it is based on today's Linus tree.

-v2: Address tj's review and split patches to small ones.
-v3: Add some Acked-by from tj, also stop abusing cpio_data for acpi_files info
-v4: fix one typo found by Tang Chen.
     Also added tested-by from Thomas Renninger and Tony.
-v5: Rebase to Linux-3.10.0-rc5 (patch 5 and 21 has been rebased)
     Improve comments in patches' log.
     Improve comment in init_mem_mapping() in patch21.

Yinghai Lu (22):
  x86: Change get_ramdisk_{image|size}() to global
  x86, microcode: Use common get_ramdisk_{image|size}()
  x86, ACPI, mm: Kill max_low_pfn_mapped
  x86, ACPI: Search buffer above 4GB in a second try for acpi initrd
    table override
  x86, ACPI: Increase acpi initrd override tables number limit
  x86, ACPI: Split acpi_initrd_override() into find/copy two steps
  x86, ACPI: Store override acpi tables phys addr in cpio files info
    array
  x86, ACPI: Make acpi_initrd_override_find work with 32bit flat mode
  x86, ACPI: Find acpi tables in initrd early from head_32.S/head64.c
  x86, mm, numa: Move two functions calling on successful path later
  x86, mm, numa: Call numa_meminfo_cover_memory() checking early
  x86, mm, numa: Move node_map_pfn_alignment() to x86
  x86, mm, numa: Use numa_meminfo to check node_map_pfn alignment
  x86, mm, numa: Set memblock nid later
  x86, mm, numa: Move node_possible_map setting later
  x86, mm, numa: Move numa emulation handling down.
  x86, ACPI, numa, ia64: split SLIT handling out
  x86, mm, numa: Add early_initmem_init() stub
  x86, mm: Parse numa info earlier
  x86, mm: Add comments for step_size shift
  x86, mm: Make init_mem_mapping be able to be called several times
  x86, mm, numa: Put pagetable on local node ram for 64bit

 arch/ia64/kernel/setup.c                |    4 +-
 arch/x86/include/asm/acpi.h             |    3 +-
 arch/x86/include/asm/page_types.h       |    2 +-
 arch/x86/include/asm/pgtable.h          |    2 +-
 arch/x86/include/asm/setup.h            |    9 ++
 arch/x86/kernel/head64.c                |    2 +
 arch/x86/kernel/head_32.S               |    4 +
 arch/x86/kernel/microcode_intel_early.c |    8 +-
 arch/x86/kernel/setup.c                 |   86 +++++++-----
 arch/x86/mm/init.c                      |  121 +++++++++++-----
 arch/x86/mm/numa.c                      |  240 ++++++++++++++++++++++++-------
 arch/x86/mm/numa_emulation.c            |    2 +-
 arch/x86/mm/numa_internal.h             |    2 +
 arch/x86/mm/srat.c                      |   11 +-
 drivers/acpi/numa.c                     |   13 +-
 drivers/acpi/osl.c                      |  138 +++++++++++++------
 include/linux/acpi.h                    |   20 ++--
 include/linux/mm.h                      |    3 -
 mm/page_alloc.c                         |   52 +-------
 19 files changed, 476 insertions(+), 246 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
