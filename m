Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id E24D76B007D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:17:07 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 7/8] x86, acpi, brk: Make early_alloc_acpi_override_tables_buf() available with va/pa.
Date: Wed, 21 Aug 2013 18:15:42 +0800
Message-Id: <1377080143-28455-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

We are using the same trick in previous patch.

Introduce a "bool is_phys" to early_alloc_acpi_override_tables_buf(). When it
is true, convert all golbal variables va to pa, so that we can access them on
32bit before paging is enabled.

NOTE: Do not call printk() on 32bit before paging is enabled
      because it will use global variables.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c |    2 +-
 drivers/acpi/osl.c      |   11 ++++++++---
 include/linux/acpi.h    |    2 +-
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 1290ea7..5729cd2 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1071,7 +1071,7 @@ void __init setup_arch(char **cmdline_p)
 
 #if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
 	/* Allocate buffer to store acpi override tables in brk. */
-	early_alloc_acpi_override_tables_buf();
+	early_alloc_acpi_override_tables_buf(false);
 #endif
 
 	/*
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index ccdb5a6..25ba68d 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -560,10 +560,15 @@ u8 __init acpi_table_checksum(u8 *buffer, u32 length)
 /* Reserve 256KB in BRK to store acpi override tables */
 #define ACPI_OVERRIDE_TABLES_SIZE (256 * 1024)
 RESERVE_BRK(acpi_override_tables_alloc, ACPI_OVERRIDE_TABLES_SIZE);
-void __init early_alloc_acpi_override_tables_buf(void)
+void __init early_alloc_acpi_override_tables_buf(bool is_phys)
 {
-	acpi_tables_addr = __pa(extend_brk(ACPI_OVERRIDE_TABLES_SIZE,
-					   PAGE_SIZE, false));
+	u64 *acpi_tables_addr_p;
+
+	acpi_tables_addr_p = is_phys ? (u64 *)__pa_nodebug(&acpi_tables_addr) :
+				       (u64 *)&acpi_tables_addr;
+
+	*acpi_tables_addr_p = __pa_nodebug(extend_brk(ACPI_OVERRIDE_TABLES_SIZE,
+					      PAGE_SIZE, is_phys));
 }
 
 /**
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index af4da51..17f2e8e 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -81,7 +81,7 @@ typedef int (*acpi_tbl_entry_handler)(struct acpi_subtable_header *header,
 
 #ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
 void acpi_initrd_override(void *data, size_t size, bool is_phys);
-void early_alloc_acpi_override_tables_buf(void);
+void early_alloc_acpi_override_tables_buf(bool is_phys);
 #else
 static inline void acpi_initrd_override(void *data, size_t size, bool is_phys)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
