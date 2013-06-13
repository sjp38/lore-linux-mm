Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 6E21E900019
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:09 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 07/22] x86, ACPI: Store override acpi tables phys addr in cpio files info array
Date: Thu, 13 Jun 2013 21:02:54 +0800
Message-Id: <1371128589-8953-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>

This patch introduces a file_pos struct to store physaddr. And then changes
acpi_initrd_files[] to file_pos type. Then store physaddr of ACPI tables
in acpi_initrd_files[].

For finding, we will find ACPI tables with physaddr during 32bit flat mode
in head_32.S, because at that time we don't need to setup page table to
access initrd.

For copying, we could use early_ioremap() with physaddr directly before
memory mapping is set.

To keep 32bit and 64bit platforms consistent, use phys_addr for all.

-v2: introduce file_pos to save physaddr instead of abusing cpio_data
     which tj is not happy with.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org
Tested-by: Thomas Renninger <trenn@suse.de>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/acpi/osl.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 6ab6c54..42f79e3 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -570,7 +570,11 @@ static const char * const table_sigs[] = {
 #define ACPI_HEADER_SIZE sizeof(struct acpi_table_header)
 
 #define ACPI_OVERRIDE_TABLES 64
-static struct cpio_data __initdata acpi_initrd_files[ACPI_OVERRIDE_TABLES];
+struct file_pos {
+	phys_addr_t data;
+	phys_addr_t size;
+};
+static struct file_pos __initdata acpi_initrd_files[ACPI_OVERRIDE_TABLES];
 
 void __init acpi_initrd_override_find(void *data, size_t size)
 {
@@ -615,7 +619,7 @@ void __init acpi_initrd_override_find(void *data, size_t size)
 			table->signature, cpio_path, file.name, table->length);
 
 		all_tables_size += table->length;
-		acpi_initrd_files[table_nr].data = file.data;
+		acpi_initrd_files[table_nr].data = __pa_nodebug(file.data);
 		acpi_initrd_files[table_nr].size = file.size;
 		table_nr++;
 	}
@@ -624,7 +628,7 @@ void __init acpi_initrd_override_find(void *data, size_t size)
 void __init acpi_initrd_override_copy(void)
 {
 	int no, total_offset = 0;
-	char *p;
+	char *p, *q;
 
 	if (!all_tables_size)
 		return;
@@ -659,12 +663,15 @@ void __init acpi_initrd_override_copy(void)
 	 * one by one during copying.
 	 */
 	for (no = 0; no < ACPI_OVERRIDE_TABLES; no++) {
+		phys_addr_t addr = acpi_initrd_files[no].data;
 		phys_addr_t size = acpi_initrd_files[no].size;
 
 		if (!size)
 			break;
+		q = early_ioremap(addr, size);
 		p = early_ioremap(acpi_tables_addr + total_offset, size);
-		memcpy(p, acpi_initrd_files[no].data, size);
+		memcpy(p, q, size);
+		early_iounmap(q, size);
 		early_iounmap(p, size);
 		total_offset += size;
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
