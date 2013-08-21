Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 9EA9D6B0078
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:17:06 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 4/8] x86, acpi, brk: Extend BRK 256KB to store acpi override tables.
Date: Wed, 21 Aug 2013 18:15:39 +0800
Message-Id: <1377080143-28455-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

When finding acpi override tables in initrd, we need to allocate memory to
store these tables. But at such an early time, we don't have any memory
allocator. The basic idea is to use BRK.

This patch reserves 256KB in BRK, and allocate it to store override tables,
instead of memblock.

This idea is from Yinghai Lu <yinghai@kernel.org>.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c |    5 +++++
 drivers/acpi/osl.c      |   44 ++++++++++++++++++++++----------------------
 include/linux/acpi.h    |    1 +
 3 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 5bfd4c8..51fcd5d 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1061,6 +1061,11 @@ void __init setup_arch(char **cmdline_p)
 
 	early_alloc_pgt_buf();
 
+#if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
+	/* Allocate buffer to store acpi override tables in brk. */
+	early_alloc_acpi_override_tables_buf();
+#endif
+
 	/*
 	 * Need to conclude brk, before memblock_x86_fill()
 	 *  it could use memblock_find_in_range, could overlap with
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 06996d8..4c1baa7 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -48,6 +48,7 @@
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
+#include <asm/setup.h>
 
 #include <acpi/acpi.h>
 #include <acpi/acpi_bus.h>
@@ -556,6 +557,15 @@ u8 __init acpi_table_checksum(u8 *buffer, u32 length)
 /* Must not increase 10 or needs code modification below */
 #define ACPI_OVERRIDE_TABLES 10
 
+/* Reserve 256KB in BRK to store acpi override tables */
+#define ACPI_OVERRIDE_TABLES_SIZE (256 * 1024)
+RESERVE_BRK(acpi_override_tables_alloc, ACPI_OVERRIDE_TABLES_SIZE);
+void __init early_alloc_acpi_override_tables_buf(void)
+{
+	acpi_tables_addr = __pa(extend_brk(ACPI_OVERRIDE_TABLES_SIZE,
+					   PAGE_SIZE));
+}
+
 void __init acpi_initrd_override(void *data, size_t size)
 {
 	int sig, no, table_nr = 0, total_offset = 0;
@@ -619,7 +629,18 @@ void __init acpi_initrd_override(void *data, size_t size)
 		pr_info("%4.4s ACPI table found in initrd [%s%s][0x%x]\n",
 			table->signature, cpio_path, file.name, table->length);
 
+		/*
+		 * If the override tables in cpio file exceeds the BRK buffer,
+		 * ignore the current table and go for the next one.
+		 */
 		all_tables_size += table->length;
+		if (all_tables_size > ACPI_OVERRIDE_TABLES_SIZE) {
+			pr_warning("ACPI OVERRIDE: ACPI override tables exceeds buffer size."
+				   " Ignoring table %4.4s\n", table->signature);
+			all_tables_size -= table->length;
+			continue;
+		}
+
 		early_initrd_files[table_nr].data = file.data;
 		early_initrd_files[table_nr].size = file.size;
 		table_nr++;
@@ -627,34 +648,13 @@ void __init acpi_initrd_override(void *data, size_t size)
 	if (table_nr == 0)
 		return;
 
-	acpi_tables_addr =
-		memblock_find_in_range(0, max_low_pfn_mapped << PAGE_SHIFT,
-				       all_tables_size, PAGE_SIZE);
-	if (!acpi_tables_addr) {
-		WARN_ON(1);
-		return;
-	}
-	/*
-	 * Only calling e820_add_reserve does not work and the
-	 * tables are invalid (memory got used) later.
-	 * memblock_reserve works as expected and the tables won't get modified.
-	 * But it's not enough on X86 because ioremap will
-	 * complain later (used by acpi_os_map_memory) that the pages
-	 * that should get mapped are not marked "reserved".
-	 * Both memblock_reserve and e820_add_region (via arch_reserve_mem_area)
-	 * works fine.
-	 */
-	memblock_reserve(acpi_tables_addr, all_tables_size);
-	arch_reserve_mem_area(acpi_tables_addr, all_tables_size);
-
-	p = early_ioremap(acpi_tables_addr, all_tables_size);
+	p = __va(acpi_tables_addr);
 
 	for (no = 0; no < table_nr; no++) {
 		memcpy(p + total_offset, early_initrd_files[no].data,
 		       early_initrd_files[no].size);
 		total_offset += early_initrd_files[no].size;
 	}
-	early_iounmap(p, all_tables_size);
 }
 #endif /* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 353ba25..381579e 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -81,6 +81,7 @@ typedef int (*acpi_tbl_entry_handler)(struct acpi_subtable_header *header,
 
 #ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
 void acpi_initrd_override(void *data, size_t size);
+void early_alloc_acpi_override_tables_buf(void);
 #else
 static inline void acpi_initrd_override(void *data, size_t size)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
