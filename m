Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 99B8B6B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 23:41:02 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part1 0/5] acpica: Split acpi_gbl_root_table_list initialization into two parts.
Date: Thu, 8 Aug 2013 11:39:31 +0800
Message-Id: <1375933176-15003-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

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


[How we do this]

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
   (This is what we are going to do. And we need to do some modification in
    ACPICA. See below.)


[About this patch-set]

There is a bootmem allocator named memblock in Linux. memblock starts to work
at very early time, and SRAT has not been parsed. So we don't know which memory
is hotpluggable. In order to prevent memblock from allocating hotpluggable
memory for the kernel, we need to obtain SRAT memory affinity info earlier.

In the current Linux kernel, the acpica code iterates acpi_gbl_root_table_list,
and install all the acpi tables into it at boot time. Then, it tries to find
if there is any override table in global array acpi_tables_addr. If any, reinstall
the override table into acpi_gbl_root_table_list.

In Linux, global array acpi_tables_addr can be fulfilled by ACPI_INITRD_TABLE_OVERRIDE
mechanism, which allows users to specify their own ACPI tables in initrd file, and
override the ones from firmware.

The whole procedure looks like the following:

setup_arch()
 |->   ......                                     /* Setup direct mapping pagetables */
 |->acpi_initrd_override()                        /* Store all override tables in acpi_tables_addr. */
 |...
 |->acpi_boot_table_init()
    |->acpi_table_init()
       |                                                                                  (Linux code)
......................................................................................................
       |                                                                                 (ACPICA code)
       |->acpi_initialize_tables()
          |->acpi_tb_parse_root_table()           /* Parse RSDT or XSDT, find all tables in firmware */
             |->for (each item in acpi_gbl_root_table_list)
                |->acpi_tb_install_table()
                   |->   ......                   /* Install one single table */
                   |->acpi_tb_table_override()    /* Override one single table */

It does the table installation and overriding one by one.

In order to find SRAT at earlier time, we want to initialize acpi_gbl_root_table_list
earlier. But at the same time, keep ACPI_INITRD_TABLE_OVERRIDE procedure works as well.

The basic idea is, split the acpi_gbl_root_table_list initialization procedure into
two steps:
1. Install all tables from firmware, not one by one.
2. Override any table if necessary, not one by one.

After this patch-set, it will work like this:

setup_arch()
 |->     ......                                   /* Install all tables from firmware (Step 1) */
 |->     ......                                   /* Try to find if any override SRAT in initrd file, if yes, use it */
 |->     ......                                   /* Use the SRAT from firmware */
 |->     ......                                   /* memblock starts to work */
 |->     ......
 |->acpi_initrd_override()                        /* Initialize acpi_tables_addr with all override table. */
 |...
 |->     ......                                   /* Do the table override work for all tables (Step 2) */


In order to achieve this goal, we have to split all the following functions:

ACPICA:
    acpi_tb_install_table()
    acpi_tb_parse_root_table()
    acpi_initialize_tables()

Linux acpi:
    acpi_table_init()
    acpi_boot_table_init()

Since ACPICA code is not just used by the Linux, so we should keep the ACPICA
side interfaces unmodified, and introduce new functions used in Linux.


Tang Chen (5):
  acpi, acpica: Split acpi_tb_install_table() into two parts.
  acpi, acpica: Call two new functions instead of
    acpi_tb_install_table() in acpi_tb_parse_root_table().
  acpi, acpica: Split acpi_tb_parse_root_table() into two parts.
  acpi, acpica: Call two new functions instead of
    acpi_tb_parse_root_table() in acpi_initialize_tables().
  acpi, acpica: Split acpi_initialize_tables() into two parts.

 drivers/acpi/acpica/actables.h |    2 +
 drivers/acpi/acpica/tbutils.c  |  184 +++++++++++++++++++++++++++++++++++-----
 drivers/acpi/acpica/tbxface.c  |   69 ++++++++++++++--
 3 files changed, 228 insertions(+), 27 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
