Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 233986B0037
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 05:39:12 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 00/11] x86, memblock: Allocate memory near kernel image before SRAT parsed.
Date: Tue, 27 Aug 2013 17:37:37 +0800
Message-Id: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch-set is based on tj's suggestion, and not fully tested. 
Just for review and discussion.


[Problem]

The current Linux cannot migrate pages used by the kerenl because
of the kernel direct mapping. In Linux kernel space, va = pa + PAGE_OFFSET.
When the pa is changed, we cannot simply update the pagetable and
keep the va unmodified. So the kernel pages are not migratable.

There are also some other issues will cause the kernel pages not migratable.
For example, the physical address may be cached somewhere and will be used.
It is not to update all the caches.

When doing memory hotplug in Linux, we first migrate all the pages in one
memory device somewhere else, and then remove the device. But if pages are
used by the kernel, they are not migratable. As a result, memory used by
the kernel cannot be hot-removed.

Modifying the kernel direct mapping mechanism is too difficult to do. And
it may cause the kernel performance down and unstable. So we use the following
way to do memory hotplug.


[What we are doing]

In Linux, memory in one numa node is divided into several zones. One of the
zones is ZONE_MOVABLE, which the kernel won't use.

In order to implement memory hotplug in Linux, we are going to arrange all
hotpluggable memory in ZONE_MOVABLE so that the kernel won't use these memory.
To do this, we need ACPI's help.

In ACPI, SRAT(System Resource Affinity Table) contains NUMA info. The memory
affinities in SRAT record every memory range in the system, and also, flags
specifying if the memory range is hotpluggable.
(Please refer to ACPI spec 5.0 5.2.16)

With the help of SRAT, we have to do the following two things to achieve our
goal:

1. When doing memory hot-add, allow the users arranging hotpluggable as
   ZONE_MOVABLE.
   (This has been done by the MOVABLE_NODE functionality in Linux.)

2. when the system is booting, prevent bootmem allocator from allocating
   hotpluggable memory for the kernel before the memory initialization
   finishes.

The problem 2 is the key problem we are going to solve. But before solving it,
we need some preparation. Please see below.


[Preparation]

Bootloader has to load the kernel image into memory. And this memory must be 
unhotpluggable. We cannot prevent this anyway. So in a memory hotplug system, 
we can assume any node the kernel resides in is not hotpluggable.

Before SRAT is parsed, we don't know which memory ranges are hotpluggable. But
memblock has already started to work. In the current kernel, memblock allocates 
the following memory before SRAT is parsed:

setup_arch()
 |->memblock_x86_fill()            /* memblock is ready */
 |......
 |->early_reserve_e820_mpc_new()   /* allocate memory under 1MB */
 |->reserve_real_mode()            /* allocate memory under 1MB */
 |->init_mem_mapping()             /* allocate page tables, about 2MB to map 1GB memory */
 |->dma_contiguous_reserve()       /* specified by user, should be low */
 |->setup_log_buf()                /* specified by user, several mega bytes */
 |->relocate_initrd()              /* could be large, but will be freed after boot, should reorder */
 |->acpi_initrd_override()         /* several mega bytes */
 |->reserve_crashkernel()          /* could be large, should reorder */
 |......
 |->initmem_init()                 /* Parse SRAT */

According to Tejun's advice, before SRAT is parsed, we should try our best to
allocate memory near the kernel image. Since the whole node the kernel resides 
in won't be hotpluggable, and for a modern server, a node may have at least 16GB
memory, allocating several mega bytes memory around the kernel image won't cross
to hotpluggable memory.


[About this patch-set]

So this patch-set does the following:

1. Make memblock be able to allocate memory from low address to high address.
   Also introduce low limit to prevent memblock allocating memory too low.

2. Improve init_mem_mapping() to support allocate page tables from low address 
   to high address.

3. Introduce "movablenode" boot option to enable and disable this functionality.

PS: Reordering of relocate_initrd() and reserve_crashkernel() has not been done 
    yet. acpi_initrd_override() needs to access initrd with virtual address. So 
    relocate_initrd() must be done before acpi_initrd_override().


Tang Chen (11):
  memblock: Rename current_limit to current_limit_high in memblock.
  memblock: Rename memblock_set_current_limit() to
    memblock_set_current_limit_high().
  memblock: Introduce lowest limit in memblock.
  memblock: Introduce memblock_set_current_limit_low() to set lower
    limit of memblock.
  memblock: Introduce allocation order to memblock.
  memblock: Improve memblock to support allocation from lower address.
  x86, memblock: Set lowest limit for memblock_alloc_base_nid().
  x86, acpi, memblock: Use __memblock_alloc_base() in
    acpi_initrd_override()
  mem-hotplug: Introduce movablenode boot option to {en|dis}able using
    SRAT.
  x86, mem-hotplug: Support initialize page tables from low to high.
  x86, mem_hotplug: Allocate memory near kernel image before SRAT is
    parsed.

 Documentation/kernel-parameters.txt |   15 ++++
 arch/arm/mm/mmu.c                   |    2 +-
 arch/arm64/mm/mmu.c                 |    4 +-
 arch/microblaze/mm/init.c           |    2 +-
 arch/powerpc/mm/40x_mmu.c           |    4 +-
 arch/powerpc/mm/44x_mmu.c           |    2 +-
 arch/powerpc/mm/fsl_booke_mmu.c     |    4 +-
 arch/powerpc/mm/hash_utils_64.c     |    4 +-
 arch/powerpc/mm/init_32.c           |    4 +-
 arch/powerpc/mm/ppc_mmu_32.c        |    4 +-
 arch/powerpc/mm/tlb_nohash.c        |    4 +-
 arch/unicore32/mm/mmu.c             |    2 +-
 arch/x86/kernel/setup.c             |   41 ++++++++++-
 arch/x86/mm/init.c                  |  119 ++++++++++++++++++++++++--------
 drivers/acpi/osl.c                  |    4 +-
 include/linux/memblock.h            |   33 ++++++++--
 include/linux/memory_hotplug.h      |    5 ++
 mm/memblock.c                       |  131 +++++++++++++++++++++++++++++-----
 mm/memory_hotplug.c                 |    9 +++
 mm/nobootmem.c                      |    4 +-
 20 files changed, 320 insertions(+), 77 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
