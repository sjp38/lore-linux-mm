Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 51BFF6B0036
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 05:42:58 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part4 0/4] Parse SRAT memory affinities earlier.
Date: Thu, 8 Aug 2013 17:41:19 +0800
Message-Id: <1375954883-30225-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The current Linux cannot migrate pages used by the kernel. When doing
memory hotplug, if the memory is used by the kernel, it cannot be 
hot-removed.

In order to prevent bootmem allocator (memblock) from allocating memory 
for the kernel, we have to parse SRAT at earlier time. 

When parsing ACPI tables at the system boot time, the current kernel 
works like this:

setup_arch()
 |->memblock_x86_fill()            /* memblock is ready. */
 |......
 |->acpi_initrd_override()         /* Find all tables specified by users in initrd,
 |                                    and store them in acpi_tables_addr array. */
 |......
 |->acpi_boot_table_init()         /* Find all tables in firmware and install them
                                      into acpi_gbl_root_table_list. Check acpi_tables_addr,
                                      if any table needs to be overrided, override it. */

In previous part3 patches modified it like this:

setup_arch()
 |->memblock_x86_fill()            /* memblock is ready. */
 |......
 |->early_acpi_boot_table_init()   /* Find all tables in firmware and install them 
 |                                    into acpi_gbl_root_table_list. No override. */
 |......
 |->acpi_initrd_override()         /* Find all tables specified by users in initrd,
 |                                    and store them in acpi_tables_addr array. */
 |......
 |->acpi_boot_table_init()         /* Check acpi_tables_addr, if any table needs to 
                                      be overrided, override it. */

We can obtain SRAT earlier now. So this patch-set will do the following things:

1. Try to find user specified SRAT in initrd file, if any, get it.
2. If there is no user specified SRAT in initrd file, to find SRAT 
   in firmware.
3. Parse all memory affinities in SRAT, and find all hotpluggable memory.

In later patches, we will improve memblock to mark and skip hotpluggable
memory when allocating memory.


Tang Chen (4):
  x86: Make get_ramdisk_{image|size}() global.
  x86, acpica, acpi: Try to find if SRAT is overrided earlier.
  x86, acpica, acpi: Try to find SRAT in firmware earlier.
  x86, acpi, numa, mem_hotplug: Find hotpluggable memory in SRAT memory
    affinities.

 arch/x86/include/asm/setup.h   |   21 +++++
 arch/x86/kernel/setup.c        |   28 +++----
 drivers/acpi/acpica/tbxface.c  |   32 ++++++++
 drivers/acpi/osl.c             |  168 ++++++++++++++++++++++++++++++++++++++++
 include/acpi/acpixf.h          |    4 +
 include/linux/acpi.h           |   20 ++++-
 include/linux/memory_hotplug.h |    2 +
 mm/memory_hotplug.c            |   47 +++++++++++-
 8 files changed, 301 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
