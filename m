Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 765356B0039
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 23:41:06 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part1 5/5] acpi, acpica: Split acpi_initialize_tables() into two parts.
Date: Thu, 8 Aug 2013 11:39:36 +0800
Message-Id: <1375933176-15003-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375933176-15003-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375933176-15003-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch splits acpi_initialize_tables() into two steps, and
introduces two new functions:
    acpi_initialize_tables_firmware() and acpi_tb_root_table_override(),
which work just the same as acpi_initialize_tables() if they are called
in sequence.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/acpica/tbxface.c |   64 ++++++++++++++++++++++++++++++++++++----
 1 files changed, 57 insertions(+), 7 deletions(-)

diff --git a/drivers/acpi/acpica/tbxface.c b/drivers/acpi/acpica/tbxface.c
index 98e4cad..ecaa5e1 100644
--- a/drivers/acpi/acpica/tbxface.c
+++ b/drivers/acpi/acpica/tbxface.c
@@ -72,8 +72,7 @@ acpi_status acpi_allocate_root_table(u32 initial_table_count)
 }
 
 /*******************************************************************************
- *
- * FUNCTION:    acpi_initialize_tables
+ * FUNCTION:    acpi_initialize_tables_firmware
  *
  * PARAMETERS:  initial_table_array - Pointer to an array of pre-allocated
  *                                    struct acpi_table_desc structures. If NULL, the
@@ -86,8 +85,6 @@ acpi_status acpi_allocate_root_table(u32 initial_table_count)
  *
  * RETURN:      Status
  *
- * DESCRIPTION: Initialize the table manager, get the RSDP and RSDT/XSDT.
- *
  * NOTE:        Allows static allocation of the initial table array in order
  *              to avoid the use of dynamic memory in confined environments
  *              such as the kernel boot sequence where it may not be available.
@@ -98,8 +95,8 @@ acpi_status acpi_allocate_root_table(u32 initial_table_count)
  ******************************************************************************/
 
 acpi_status __init
-acpi_initialize_tables(struct acpi_table_desc * initial_table_array,
-		       u32 initial_table_count, u8 allow_resize)
+acpi_initialize_tables_firmware(struct acpi_table_desc * initial_table_array,
+				u32 initial_table_count, u8 allow_resize)
 {
 	acpi_physical_address rsdp_address;
 	acpi_status status;
@@ -144,10 +141,63 @@ acpi_initialize_tables(struct acpi_table_desc * initial_table_array,
 	 * in a common, more useable format.
 	 */
 	status = acpi_tb_root_table_install(rsdp_address);
+
+	return_ACPI_STATUS(status);
+}
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_initialize_tables
+ *
+ * PARAMETERS:  None
+ *
+ * RETURN:      None
+ *
+ * DESCRIPTION: Allow host OS to replace any table installed in global root
+ *              table list.
+ *
+ ******************************************************************************/
+
+void acpi_initialize_tables_override(void)
+{
+	acpi_tb_root_table_override();
+}
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_initialize_tables
+ *
+ * PARAMETERS:  initial_table_array - Pointer to an array of pre-allocated
+ *                                    struct acpi_table_desc structures. If NULL, the
+ *                                    array is dynamically allocated.
+ *              initial_table_count - Size of initial_table_array, in number of
+ *                                    struct acpi_table_desc structures
+ *              allow_resize        - Flag to tell Table Manager if resize of
+ *                                    pre-allocated array is allowed. Ignored
+ *                                    if initial_table_array is NULL.
+ *
+ * RETURN:      Status
+ *
+ * DESCRIPTION: Initialize the table manager, get the RSDP and RSDT/XSDT.
+ *
+ ******************************************************************************/
+
+acpi_status __init
+acpi_initialize_tables(struct acpi_table_desc * initial_table_array,
+		       u32 initial_table_count, u8 allow_resize)
+{
+	acpi_status status;
+
+	status = acpi_initialize_tables_firmware(initial_table_array,
+					initial_table_count, allow_resize);
 	if (ACPI_FAILURE(status))
 		return_ACPI_STATUS(status);
 
-	acpi_tb_root_table_override();
+	/*
+	 * Allow host OS to replace any table installed in global root
+	 * table list.
+	 */
+	acpi_initialize_tables_override();
 
 	return_ACPI_STATUS(AE_OK);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
