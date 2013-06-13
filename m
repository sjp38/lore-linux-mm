Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1CBAE900016
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:10 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 05/22] x86, ACPI: Increase acpi initrd override tables number limit
Date: Thu, 13 Jun 2013 21:02:52 +0800
Message-Id: <1371128589-8953-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>

Current number of acpi tables in initrd is limited to 10, which is
too small. 64 would be good enough as we have 35 sigs and could
have several SSDTs.

Two problems in current code prevent us from increasing the 10 tables limit:
1. cpio file info array is put in stack, as every element is 32 bytes, we
   could run out of stack if we increase the array size to 64.
   So we can move it out from stack, and make it global and put it in
   __initdata section.
2. early_ioremap only can remap 256kb one time. Current code is mapping
   10 tables one time. If we increase that limit, the whole size could be
   more than 256kb, and early_ioremap will fail.
   So we can map the tables one by one during copying, instead of mapping
   all of them at one time.

-v2: According to tj, split it out to separated patch, also
     rename array name to acpi_initrd_files.
-v3: Add some comments about mapping table one by one during copying
     per tj.

Signed-off-by: Yinghai <yinghai@kernel.org>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org
Acked-by: Tejun Heo <tj@kernel.org>
Tested-by: Thomas Renninger <trenn@suse.de>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/acpi/osl.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 42c48fc..53dd490 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -569,8 +569,8 @@ static const char * const table_sigs[] = {
 
 #define ACPI_HEADER_SIZE sizeof(struct acpi_table_header)
 
-/* Must not increase 10 or needs code modification below */
-#define ACPI_OVERRIDE_TABLES 10
+#define ACPI_OVERRIDE_TABLES 64
+static struct cpio_data __initdata acpi_initrd_files[ACPI_OVERRIDE_TABLES];
 
 void __init acpi_initrd_override(void *data, size_t size)
 {
@@ -579,7 +579,6 @@ void __init acpi_initrd_override(void *data, size_t size)
 	struct acpi_table_header *table;
 	char cpio_path[32] = "kernel/firmware/acpi/";
 	struct cpio_data file;
-	struct cpio_data early_initrd_files[ACPI_OVERRIDE_TABLES];
 	char *p;
 
 	if (data == NULL || size == 0)
@@ -617,8 +616,8 @@ void __init acpi_initrd_override(void *data, size_t size)
 			table->signature, cpio_path, file.name, table->length);
 
 		all_tables_size += table->length;
-		early_initrd_files[table_nr].data = file.data;
-		early_initrd_files[table_nr].size = file.size;
+		acpi_initrd_files[table_nr].data = file.data;
+		acpi_initrd_files[table_nr].size = file.size;
 		table_nr++;
 	}
 	if (table_nr == 0)
@@ -648,14 +647,19 @@ void __init acpi_initrd_override(void *data, size_t size)
 	memblock_reserve(acpi_tables_addr, all_tables_size);
 	arch_reserve_mem_area(acpi_tables_addr, all_tables_size);
 
-	p = early_ioremap(acpi_tables_addr, all_tables_size);
-
+	/*
+	 * early_ioremap can only remap 256KB at one time. If we map all the
+	 * tables at one time, we will hit the limit. So we need to map tables
+	 * one by one during copying.
+	 */
 	for (no = 0; no < table_nr; no++) {
-		memcpy(p + total_offset, early_initrd_files[no].data,
-		       early_initrd_files[no].size);
-		total_offset += early_initrd_files[no].size;
+		phys_addr_t size = acpi_initrd_files[no].size;
+
+		p = early_ioremap(acpi_tables_addr + total_offset, size);
+		memcpy(p, acpi_initrd_files[no].data, size);
+		early_iounmap(p, size);
+		total_offset += size;
 	}
-	early_iounmap(p, all_tables_size);
 }
 #endif /* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
