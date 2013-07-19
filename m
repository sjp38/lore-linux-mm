Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 792F46B0039
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:01:00 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 06/21] x86, acpi: Split acpi_boot_table_init() into two parts.
Date: Fri, 19 Jul 2013 15:59:19 +0800
Message-Id: <1374220774-29974-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

In ACPI, SRAT(System Resource Affinity Table) contains NUMA info.
The memory affinities in SRAT record every memory range in the
system, and also, flags specifying if the memory range is
hotpluggable.
(Please refer to ACPI spec 5.0 5.2.16)

memblock starts to work at very early time, and SRAT has not been
parsed. So we don't know which memory is hotpluggable. In order
to use memblock to reserve hotpluggable memory, we need to obtain
SRAT memory affinity info earlier.

In the current acpi_boot_table_init(), it does the following:
1. Parse RSDT, so that we can find all the tables.
2. Initialize acpi_gbl_root_table_list, an array of acpi table
   descriptorsused to store each table's address, length, signature,
   and so on.
3. Check if there is any table in initrd intending to override
   tables from firmware. If so, override the firmware tables.
4. Initialize all the data in acpi_gbl_root_table_list.

In order to parse SRAT at early time, we need to do similar job as
step 1 and 2 above earlier to obtain SRAT. It will be very convenient
if we have acpi_gbl_root_table_list initialized. We can use address
and signature to find SRAT.

Since step 1 and 2 allocates no memory, it is OK to do these two
steps earlier.

But step 3 will check acpi initrd table override, not just SRAT,
but also all the other tables. So it is better to keep it untouched.

This patch splits acpi_boot_table_init() into two steps:
1. Parse RSDT, which cannot be overrided, and initialize
   acpi_gbl_root_table_list. (step 1 + 2 above)
2. Install all ACPI tables into acpi_gbl_root_table_list.
   (step 3 + 4 above)

In later patches, we will do step 1 + 2 earlier.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/acpi/acpica/tbutils.c |   25 ++++++++++++++++++++++---
 drivers/acpi/tables.c         |    2 ++
 include/acpi/acpixf.h         |    2 ++
 3 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/acpica/tbutils.c b/drivers/acpi/acpica/tbutils.c
index ce3d5db..9d68ffc 100644
--- a/drivers/acpi/acpica/tbutils.c
+++ b/drivers/acpi/acpica/tbutils.c
@@ -766,9 +766,30 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
 	 */
 	acpi_os_unmap_memory(table, length);
 
+	return_ACPI_STATUS(AE_OK);
+}
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_tb_install_root_table
+ *
+ * DESCRIPTION: This function installs all the ACPI tables in RSDT into
+ *              acpi_gbl_root_table_list.
+ *
+ ******************************************************************************/
+
+void __init
+acpi_tb_install_root_table()
+{
+	int i;
+
 	/*
 	 * Complete the initialization of the root table array by examining
-	 * the header of each table
+	 * the header of each table.
+	 *
+	 * First two entries in the table array are reserved for the DSDT
+	 * and FACS, which are not actually present in the RSDT/XSDT - they
+	 * come from the FADT.
 	 */
 	for (i = 2; i < acpi_gbl_root_table_list.current_table_count; i++) {
 		acpi_tb_install_table(acpi_gbl_root_table_list.tables[i].
@@ -782,6 +803,4 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
 			acpi_tb_parse_fadt(i);
 		}
 	}
-
-	return_ACPI_STATUS(AE_OK);
 }
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index d67a1fe..8860e79 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -353,6 +353,8 @@ int __init acpi_table_init(void)
 	if (ACPI_FAILURE(status))
 		return 1;
 
+	acpi_tb_install_root_table();
+
 	check_multiple_madt();
 	return 0;
 }
diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
index 454881e..f5549b5 100644
--- a/include/acpi/acpixf.h
+++ b/include/acpi/acpixf.h
@@ -116,6 +116,8 @@ acpi_status
 acpi_initialize_tables(struct acpi_table_desc *initial_storage,
 		       u32 initial_table_count, u8 allow_resize);
 
+void acpi_tb_install_root_table(void);
+
 acpi_status __init acpi_initialize_subsystem(void);
 
 acpi_status acpi_enable_subsystem(u32 flags);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
