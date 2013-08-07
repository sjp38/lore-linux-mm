Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id EF4766B0096
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 06:53:45 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 00/25] Arrange hotpluggable memory as ZONE_MOVABLE.
Date: Wed, 7 Aug 2013 18:51:51 +0800
Message-Id: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch-set aims to solve some problems at system boot time
to enhance memory hotplug functionality.

[Background]

The Linux kernel cannot migrate pages used by the kernel because
of the kernel direct mapping. Since va = pa + PAGE_OFFSET, if the
physical address is changed, we cannot simply update the kernel
pagetable. On the contrary, we have to update all the pointers
pointing to the virtual address, which is very difficult to do.

In order to do memory hotplug, we should prevent the kernel to use
hotpluggable memory.

In ACPI, there is a table named SRAT(System Resource Affinity Table).
It contains system NUMA info (CPUs, memory ranges, PXM), and also a
flag field indicating which memory ranges are hotpluggable.


[Problem to be solved]

At the very early time when the system is booting, we use a bootmem
allocator, named memblock, to allocate memory for the kernel.
memblock will start to work before the kernel parse SRAT, which
means memblock won't know which memory is hotpluggable before SRAT
is parsed.

So at this time, memblock could allocate hotpluggable memory for
the kernel to use permanently. For example, the kernel may allocate
pagetables in hotpluggable memory, which cannot be freed when the
system is up.

So we have to prevent memblock allocating hotpluggable memory for
the kernel at the early boot time.


[Earlier solutions]

We have tried to parse SRAT earlier, before memblock is ready. To
do this, we also have to do ACPI_INITRD_TABLE_OVERRIDE earlier.
Otherwise the override tables won't be able to effect.

This is not that easy to do because memblock is ready before direct
mapping is setup. So Yinghai split the ACPI_INITRD_TABLE_OVERRIDE
procedure into two steps: find and copy. Please refer to the
following patch-set:
        https://lkml.org/lkml/2013/6/13/587

To this solution, tj gave a lot of comments and the following
suggestions.


[Suggestion from tj]

tj mainly gave the following suggestions:

1. Necessary reordering is OK, but we should not rely on
   reordering to achieve the goal because it makes the kernel
   too fragile.

2. Memory allocated to kernel for temporary usage is OK because
   it will be freed when the system is up. Doing relocation
   for permanent allocated hotpluggable memory will make the
   the kernel more robust.

3. Need to enhance memblock to discover and complain if any
   hotpluggable memory is allocated to kernel.

After a long thinking, we choose not to do the relocation for
the following reasons:

1. It's easy to find out the allocated hotpluggable memory. But
   memblock will merge the adjoined ranges owned by different users
   and used for different purposes. It's hard to find the owners.

2. Different memory has different way to be relocated. I think one
   function for each kind of memory will make the code too messy.

3. Pagetable could be in hotpluggable memory. Relocating pagetable
   is too difficult and risky. We have to update all PUD, PMD pages.
   And also, ACPI_INITRD_TABLE_OVERRIDE and parsing SRAT procedures
   are not long after pagetable is initialized. If we relocate the
   pagetable not long after it was initialized, the code will be
   very ugly.


[Solution in this patch-set]

In this patch-set, we still do the reordering, but in a new way.

1. Improve memblock with flags, so that it is able to differentiate
   memory regions for different usage. And also a MEMBLOCK_HOTPLUG
   flag to mark hotpluggable memory.

2. When memblock is ready (memblock_x86_fill() is called), initialize
   acpi_gbl_root_table_list, fulfill all the ACPI tables' phys addrs.
   Now, we have all the ACPI tables' phys addrs provided by firmware.

3. Check if there is a SRAT in initrd file used to override the one
   provided by firmware. If so, get its phys addr.

4. If no override SRAT in initrd, get the phys addr of the SRAT
   provided by firmware.

   Now, we have the phys addr of the to be used SRAT, the one in
   initrd or the one in firmware.

5. Parse only the memory affinities in SRAT, find out all the
   hotpluggable memory regions and mark them in memblock.memory with
   MEMBLOCK_HOTPLUG flag.

6. The kernel goes through the current path. Any other related parts,
   such as ACPI_INITRD_TABLE_OVERRIDE path, the current parsing ACPI
   tables pathes, global variable numa_meminfo, and so on, are not
   modified. They work as before.

7. Make memblock default allocator skip hotpluggable memory.

8. Introduce movablenode boot option to allow users to enable
   and disable this functionality.


In summary, in order to get hotpluggable memory info as early as possible,
this patch-set only parse memory affinities in SRAT one more time right
after memblock is ready, and leave all the other pathes untouched. With
the hotpluggable memory info, we can arrange hotpluggable memory in
ZONE_MOVABLE to prevent the kernel to use it.

change log v2 RESEND -> v3:
1. As Rafael and Lv Zheng suggested, split acpi global root table list 
   initialization procedure into two steps: install and override. And 
   do the "install" step earlier.
2. Fix some little problems found by Toshi.

change log v2 -> v2 RESEND:
According to Toshi's advice:
1. Rename acpi_invalid_table() to acpi_verify_table().
2. Rename acpi_root_table_init() to early_acpi_boot_table_init().
3. Rename INVALID_TABLE() to ACPI_INVALID_TABLE().
4. Check if ramdisk is present in early_acpi_override_srat().
5. Check if ACPI is disabled in acpi_boot_table_init().
6. Rebased to Linux 3.11-rc3.

change log v1 -> v2:
1. According to Tejun's advice, make ACPI side report which memory regions
   are hotpluggable, and memblock side handle the memory allocation.
2. Change "movablecore=acpi" boot option to "movablenode" boot option.

Thanks. 

Tang Chen (24):
  acpi: Print Hot-Pluggable Field in SRAT.
  earlycpio.c: Fix the confusing comment of find_cpio_data().
  acpi: Remove "continue" in macro INVALID_TABLE().
  acpi: Introduce acpi_verify_initrd() to check if a table is invalid.
  acpi, acpica: Split acpi_tb_install_table() into two parts.
  acpi, acpica: Call two new functions instead of
    acpi_tb_install_table() in acpi_tb_parse_root_table().
  acpi, acpica: Split acpi_tb_parse_root_table() into two parts.
  acpi, acpica: Call two new functions instead of
    acpi_tb_parse_root_table() in acpi_initialize_tables().
  acpi, acpica: Split acpi_initialize_tables() into two parts.
  x86, acpi: Call two new functions instead of acpi_initialize_tables()
    in acpi_table_init().
  x86, acpi: Split acpi_table_init() into two parts.
  x86, acpi: Rename check_multiple_madt() and make it global.
  x86, acpi: Split acpi_boot_table_init() into two parts.
  x86, acpi: Initialize acpi golbal root table list earlier.
  x86: Make get_ramdisk_{image|size}() global.
  x86, acpica, acpi: Try to find if SRAT is overrided earlier.
  x86, acpica, acpi: Try to find SRAT in firmware earlier.
  x86, acpi, numa, mem_hotplug: Find hotpluggable memory in SRAT memory
    affinities.
  x86, numa, mem_hotplug: Skip all the regions the kernel resides in.
  memblock, numa: Introduce flag into memblock.
  memblock, mem_hotplug: Introduce MEMBLOCK_HOTPLUG flag to mark
    hotpluggable regions.
  memblock, mem_hotplug: Make memblock skip hotpluggable regions by
    default.
  mem-hotplug: Introduce movablenode boot option to {en|dis}able using
    SRAT.
  x86, numa, acpi, memory-hotplug: Make movablenode have higher
    priority.

Yasuaki Ishimatsu (1):
  x86: get pg_data_t's memory from other node

 Documentation/kernel-parameters.txt |   15 ++
 arch/x86/include/asm/setup.h        |   21 +++
 arch/x86/kernel/acpi/boot.c         |   32 +++--
 arch/x86/kernel/setup.c             |   42 +++---
 arch/x86/mm/numa.c                  |    5 +-
 arch/x86/mm/srat.c                  |   11 +-
 drivers/acpi/acpica/actables.h      |    2 +
 drivers/acpi/acpica/tbutils.c       |  184 +++++++++++++++++++++++---
 drivers/acpi/acpica/tbxface.c       |  101 +++++++++++++-
 drivers/acpi/osl.c                  |  252 ++++++++++++++++++++++++++++++++---
 drivers/acpi/tables.c               |   29 +++-
 include/acpi/acpixf.h               |    8 +
 include/linux/acpi.h                |   24 +++-
 include/linux/memblock.h            |   13 ++
 include/linux/memory_hotplug.h      |    5 +
 lib/earlycpio.c                     |   27 ++--
 mm/memblock.c                       |   92 +++++++++++--
 mm/memory_hotplug.c                 |  104 ++++++++++++++-
 mm/page_alloc.c                     |   31 ++++-
 19 files changed, 873 insertions(+), 125 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
