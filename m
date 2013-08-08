Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id D2AA68D0001
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 04:55:33 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part3 0/5] acpi, acpica: Initialize acpi_gbl_root_table_list earlier and override it later.
Date: Thu, 8 Aug 2013 16:54:01 +0800
Message-Id: <1375952046-28490-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

In order to prevent bootmem allocator (memblock) from allocating hotpluggable 
memory for the kernel, we need to obtain SRAT earlier.

In part1 patch-set, we have split acpi_gbl_root_table_list initialization into
two steps: install and override.

This patch-set will do install step earlier. This will help us to find SRAT provided 
by firmware earlier in later patches. 

The current kernel looks like this:

setup_arch()
 |->acpi_initrd_override()         /* Find all tables specified by users in initrd,
 |                                    and store them in acpi_tables_addr array. */
 |......
 |->acpi_boot_table_init()         /* Find all tables in firmware and install them
                                      into acpi_gbl_root_table_list. Check acpi_tables_addr,
                                      if any table needs to be overrided, override it. */

After this patch-set, the kernel will look like this:

setup_arch()
 |->early_acpi_boot_table_init()   /* Find all tables in firmware and install them 
 |                                    into acpi_gbl_root_table_list. No override. */
 |
 |->acpi_initrd_override()         /* Find all tables specified by users in initrd,
 |                                    and store them in acpi_tables_addr array. */
 |......
 |->acpi_boot_table_init()         /* Check acpi_tables_addr, if any table needs to 
                                      be overrided, override it. */


Tang Chen (5):
  x86, acpi: Call two new functions instead of acpi_initialize_tables()
    in acpi_table_init().
  x86, acpi: Split acpi_table_init() into two parts.
  x86, acpi: Rename check_multiple_madt() and make it global.
  x86, acpi: Split acpi_boot_table_init() into two parts.
  x86, acpi: Initialize acpi golbal root table list earlier.

 arch/x86/kernel/acpi/boot.c |   32 ++++++++++++++++++++------------
 arch/x86/kernel/setup.c     |    8 +++++++-
 drivers/acpi/tables.c       |   29 +++++++++++++++++++++++------
 include/acpi/acpixf.h       |    4 ++++
 include/linux/acpi.h        |    4 ++++
 5 files changed, 58 insertions(+), 19 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
