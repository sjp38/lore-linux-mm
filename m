Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A28D66B00A5
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 06:53:48 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 07/25] acpi, acpica: Split acpi_tb_parse_root_table() into two parts.
Date: Wed, 7 Aug 2013 18:51:58 +0800
Message-Id: <1375872736-4822-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch splits acpi_tb_parse_root_table() into two steps, and
introduces two new functions:
    acpi_tb_root_table_install() and acpi_tb_root_table_override().

They are just the same as acpi_tb_parse_root_table() if they are
called in sequence.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/acpica/tbutils.c |   57 ++++++++++++++++++++++++++++++++++++++--
 1 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/acpica/tbutils.c b/drivers/acpi/acpica/tbutils.c
index 9bef44b..8ed9b9a 100644
--- a/drivers/acpi/acpica/tbutils.c
+++ b/drivers/acpi/acpica/tbutils.c
@@ -503,14 +503,16 @@ acpi_tb_get_root_table_entry(u8 *table_entry, u32 table_entry_size)
 
 /*******************************************************************************
  *
- * FUNCTION:    acpi_tb_parse_root_table
+ * FUNCTION:    acpi_tb_root_table_install
  *
  * PARAMETERS:  rsdp                    - Pointer to the RSDP
  *
  * RETURN:      Status
  *
  * DESCRIPTION: This function is called to parse the Root System Description
- *              Table (RSDT or XSDT)
+ *              Table (RSDT or XSDT), and install all the system description
+ *              tables defined in the root table into the global root table
+ *              list.
  *
  * NOTE:        Tables are mapped (not copied) for efficiency. The FACS must
  *              be mapped and cannot be copied because it contains the actual
@@ -519,7 +521,7 @@ acpi_tb_get_root_table_entry(u8 *table_entry, u32 table_entry_size)
  ******************************************************************************/
 
 acpi_status __init
-acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
+acpi_tb_root_table_install(acpi_physical_address rsdp_address)
 {
 	struct acpi_table_rsdp *rsdp;
 	u32 table_entry_size;
@@ -673,7 +675,31 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
 		/* Install tables in firmware into acpi_gbl_root_table_list */
 		acpi_tb_install_table_firmware(acpi_gbl_root_table_list.
 					       tables[i].address, NULL, i);
+	}
+
+	return_ACPI_STATUS(AE_OK);
+}
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_tb_root_table_override
+ *
+ * PARAMETERS:  None
+ *
+ * RETURN:      None
+ *
+ * DESCRIPTION: This function is called to allow the host OS to replace any
+ *              table that has been installed into the global root table
+ *              list.
+ *
+ ******************************************************************************/
 
+void __init
+acpi_tb_root_table_override(void)
+{
+	int i;
+
+	for (i = 2; i < acpi_gbl_root_table_list.current_table_count; i++) {
 		/* Override the installed tables if any */
 		acpi_tb_install_table_override(acpi_gbl_root_table_list.
 					       tables[i].address, NULL, i);
@@ -686,6 +712,31 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
 			acpi_tb_parse_fadt(i);
 		}
 	}
+}
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_tb_parse_root_table
+ *
+ * PARAMETERS:  rsdp                    - Pointer to the RSDP
+ *
+ * RETURN:      Status
+ *
+ * DESCRIPTION: This function is called to parse the Root System Description
+ *              Table (RSDT or XSDT)
+ *
+ ******************************************************************************/
+
+acpi_status __init
+acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
+{
+	acpi_status status;
+
+	status = acpi_tb_root_table_install(rsdp_address);
+	if (ACPI_FAILURE(status))
+		return_ACPI_STATUS(status);
+
+	acpi_tb_root_table_override();
 
 	return_ACPI_STATUS(AE_OK);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
