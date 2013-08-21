Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 99A496B007B
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:17:07 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 6/8] x86, acpi: Make acpi_initrd_override() available with va or pa.
Date: Wed, 21 Aug 2013 18:15:41 +0800
Message-Id: <1377080143-28455-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

We are using the same trick in previous patch.

Introduce a "bool is_phys" to acpi_initrd_override(). When it
is true, convert all golbal variables va to pa, so that we can
access them on 32bit before paging is enabled.

NOTE: Do not call printk() on 32bit before paging is enabled
      because it will use global variables.

Originally-From: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c |    3 +-
 drivers/acpi/osl.c      |   68 ++++++++++++++++++++++++++++++++++------------
 include/linux/acpi.h    |    4 +-
 3 files changed, 54 insertions(+), 21 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index a189909..1290ea7 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1133,7 +1133,8 @@ void __init setup_arch(char **cmdline_p)
 	reserve_initrd();
 
 #if defined(CONFIG_ACPI) && defined(CONFIG_BLK_DEV_INITRD)
-	acpi_initrd_override((void *)initrd_start, initrd_end - initrd_start);
+	acpi_initrd_override((void *)initrd_start, initrd_end - initrd_start,
+			     false);
 #endif
 
 	reserve_crashkernel();
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index dff7fcc..ccdb5a6 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -566,7 +566,19 @@ void __init early_alloc_acpi_override_tables_buf(void)
 					   PAGE_SIZE, false));
 }
 
-void __init acpi_initrd_override(void *data, size_t size)
+/**
+ * acpi_initrd_override - Initialize acpi_tables_addr with acpi override tables
+ * @data: cpio file address (va or pa)
+ * @size: size of cpio file
+ * @is_phys: true if @data is pa, false otherwise
+ *
+ * This function will find all acpi override tables provided by initrd, and
+ * store the addresses in acpi_tables_addr.
+ *
+ * This function could be called before paging is enabled. Before paging is
+ * enabled, caller should use physical address, and set @is_phys as true.
+ */
+void __init acpi_initrd_override(void *data, size_t size, bool is_phys)
 {
 	int sig, no, table_nr = 0, total_offset = 0;
 	long offset = 0;
@@ -586,10 +598,17 @@ void __init acpi_initrd_override(void *data, size_t size)
 		ACPI_SIG_UEFI, ACPI_SIG_WAET, ACPI_SIG_WDAT, ACPI_SIG_WDDT,
 		ACPI_SIG_WDRT, ACPI_SIG_DSDT, ACPI_SIG_FADT, ACPI_SIG_PSDT,
 		ACPI_SIG_RSDT, ACPI_SIG_XSDT, ACPI_SIG_SSDT, NULL };
+	u64 *acpi_tables_addr_p = &acpi_tables_addr;
+	int *all_tables_size_p = &all_tables_size;
 
 	if (data == NULL || size == 0)
 		return;
 
+	if (is_phys) {
+		acpi_tables_addr_p = (u64 *)__pa_nodebug(&acpi_tables_addr);
+		all_tables_size_p = (int *)__pa_nodebug(&all_tables_size);
+	}
+
 	for (no = 0; no < ACPI_OVERRIDE_TABLES; no++) {
 		file = find_cpio_data(cpio_path, data, size, &offset);
 		if (!file.data)
@@ -599,8 +618,9 @@ void __init acpi_initrd_override(void *data, size_t size)
 		size -= offset;
 
 		if (file.size < sizeof(struct acpi_table_header)) {
-			pr_err("ACPI OVERRIDE: Table smaller than ACPI header [%s%s]\n",
-				cpio_path, file.name);
+			if (!is_phys)
+				pr_err("ACPI OVERRIDE: Table smaller than ACPI header [%s%s]\n",
+					cpio_path, file.name);
 			continue;
 		}
 
@@ -611,36 +631,48 @@ void __init acpi_initrd_override(void *data, size_t size)
 				break;
 
 		if (!table_sigs[sig]) {
-			pr_err("ACPI OVERRIDE: Unknown signature [%s%s]\n",
-				cpio_path, file.name);
+			if (!is_phys)
+				pr_err("ACPI OVERRIDE: Unknown signature [%s%s]\n",
+					cpio_path, file.name);
 			continue;
 		}
 		if (file.size != table->length) {
-			pr_err("ACPI OVERRIDE: File length does not match table length [%s%s]\n",
-				cpio_path, file.name);
+			if (!is_phys)
+				pr_err("ACPI OVERRIDE: File length does not match table length [%s%s]\n",
+					cpio_path, file.name);
 			continue;
 		}
 		if (acpi_table_checksum(file.data, table->length)) {
-			pr_err("ACPI OVERRIDE: Bad table checksum [%s%s]\n",
-				cpio_path, file.name);
+			if (!is_phys)
+				pr_err("ACPI OVERRIDE: Bad table checksum [%s%s]\n",
+					cpio_path, file.name);
 			continue;
 		}
 
-		pr_info("%4.4s ACPI table found in initrd [%s%s][0x%x]\n",
-			table->signature, cpio_path, file.name, table->length);
+		if (!is_phys)
+			pr_info("%4.4s ACPI table found in initrd [%s%s][0x%x]\n",
+				table->signature, cpio_path,
+				file.name, table->length);
 
 		/*
 		 * If the override tables in cpio file exceeds the BRK buffer,
 		 * ignore the current table and go for the next one.
 		 */
-		all_tables_size += table->length;
-		if (all_tables_size > ACPI_OVERRIDE_TABLES_SIZE) {
-			pr_warning("ACPI OVERRIDE: ACPI override tables exceeds buffer size."
-				   " Ignoring table %4.4s\n", table->signature);
-			all_tables_size -= table->length;
+		*all_tables_size_p += table->length;
+		if (*all_tables_size_p > ACPI_OVERRIDE_TABLES_SIZE) {
+			if (!is_phys)
+				pr_warning("ACPI OVERRIDE: ACPI override tables exceeds buffer size."
+					   " Ignoring table %4.4s\n",
+					   table->signature);
+			*all_tables_size_p -= table->length;
 			continue;
 		}
 
+		/*
+		 * file.data is the offset of the table in initrd. If @data is
+		 * pa, then we find pa. If @data is va, then we find va. No need
+		 * to convert.
+		 */
 		early_initrd_files[table_nr].data = file.data;
 		early_initrd_files[table_nr].size = file.size;
 		table_nr++;
@@ -648,8 +680,8 @@ void __init acpi_initrd_override(void *data, size_t size)
 	if (table_nr == 0)
 		return;
 
-	p = __va(acpi_tables_addr);
-
+	p = is_phys ? (char *)(*acpi_tables_addr_p) :
+		      (char *)__va(*acpi_tables_addr_p);
 	for (no = 0; no < table_nr; no++) {
 		memcpy(p + total_offset, early_initrd_files[no].data,
 		       early_initrd_files[no].size);
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 381579e..af4da51 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -80,10 +80,10 @@ typedef int (*acpi_tbl_entry_handler)(struct acpi_subtable_header *header,
 				      const unsigned long end);
 
 #ifdef CONFIG_ACPI_INITRD_TABLE_OVERRIDE
-void acpi_initrd_override(void *data, size_t size);
+void acpi_initrd_override(void *data, size_t size, bool is_phys);
 void early_alloc_acpi_override_tables_buf(void);
 #else
-static inline void acpi_initrd_override(void *data, size_t size)
+static inline void acpi_initrd_override(void *data, size_t size, bool is_phys)
 {
 }
 #endif
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
