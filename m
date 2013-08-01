Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id B15B66B003A
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 03:08:14 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 11/18] x86, acpi: Try to find SRAT in firmware earlier.
Date: Thu, 1 Aug 2013 15:06:33 +0800
Message-Id: <1375340800-19332-12-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch introduce early_acpi_firmware_srat() to find the
phys addr of SRAT provided by firmware. And call it in
find_hotpluggable_memory().

Since we have initialized acpi_gbl_root_table_list earlier,
and store all the tables' phys addrs and signatures in it,
it is easy to find the SRAT.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/acpica/tbxface.c |   32 ++++++++++++++++++++++++++++++++
 drivers/acpi/osl.c            |   22 ++++++++++++++++++++++
 include/acpi/acpixf.h         |    4 ++++
 include/linux/acpi.h          |    4 ++++
 mm/memory_hotplug.c           |    8 ++++++--
 5 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/acpica/tbxface.c b/drivers/acpi/acpica/tbxface.c
index ad11162..6a92f12 100644
--- a/drivers/acpi/acpica/tbxface.c
+++ b/drivers/acpi/acpica/tbxface.c
@@ -181,6 +181,38 @@ acpi_status acpi_reallocate_root_table(void)
 	return_ACPI_STATUS(status);
 }
 
+/**
+ * acpi_get_table_desc - Get the acpi table descriptor of a specific table.
+ * @signature: The signature of the table to be found.
+ * @out_desc: The out returned descriptor.
+ *
+ * Iterate over acpi_gbl_root_table_list to find a specific table and then
+ * return its phys addr.
+ *
+ * NOTE: The caller has the responsibility to allocate memory for @out_desc.
+ *
+ * Return AE_OK on success, AE_NOT_FOUND if the table is not found.
+ */
+acpi_status acpi_get_table_desc(char *signature,
+				struct acpi_table_desc *out_desc)
+{
+	struct acpi_table_desc *desc;
+	int pos, count = acpi_gbl_root_table_list.current_table_count;
+
+	for (pos = 0; pos < count; pos++) {
+		desc = &acpi_gbl_root_table_list.tables[pos];
+
+		if (!ACPI_COMPARE_NAME(&desc->signature, signature))
+			continue;
+
+		memcpy(out_desc, desc, sizeof(struct acpi_table_desc));
+
+		return_ACPI_STATUS(AE_OK);
+	}
+
+	return_ACPI_STATUS(AE_NOT_FOUND);
+}
+
 /*******************************************************************************
  *
  * FUNCTION:    acpi_get_table_header
diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index d0b687c..319a274 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -53,6 +53,7 @@
 #include <acpi/acpi.h>
 #include <acpi/acpi_bus.h>
 #include <acpi/processor.h>
+#include <acpi/acpixf.h>
 
 #define _COMPONENT		ACPI_OS_SERVICES
 ACPI_MODULE_NAME("osl");
@@ -757,6 +758,27 @@ void __init acpi_initrd_override(void *data, size_t size)
 }
 #endif /* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
 
+#ifdef CONFIG_ACPI_NUMA
+/*******************************************************************************
+ *
+ * FUNCTION:    early_acpi_firmware_srat
+ *
+ * RETURN:      Phys addr of SRAT on success, 0 on error.
+ *
+ * DESCRIPTION: Get the phys addr of SRAT provided by firmware.
+ *
+ ******************************************************************************/
+phys_addr_t __init early_acpi_firmware_srat(void)
+{
+	struct acpi_table_desc table_desc;
+
+	if (acpi_get_table_desc(ACPI_SIG_SRAT, &table_desc))
+		return 0;
+
+	return table_desc.address;
+}
+#endif	/* CONFIG_ACPI_NUMA */
+
 static void acpi_table_taint(struct acpi_table_header *table)
 {
 	pr_warn(PREFIX
diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
index f5549b5..1d94f89 100644
--- a/include/acpi/acpixf.h
+++ b/include/acpi/acpixf.h
@@ -184,6 +184,10 @@ acpi_status acpi_find_root_pointer(acpi_size *rsdp_address);
 acpi_status acpi_unload_table_id(acpi_owner_id id);
 
 acpi_status
+acpi_get_table_desc(char *signature,
+		    struct acpi_table_desc *out_desc);
+
+acpi_status
 acpi_get_table_header(acpi_string signature,
 		      u32 instance, struct acpi_table_header *out_table_header);
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 17155bc..6fa7543 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -97,6 +97,10 @@ static inline phys_addr_t early_acpi_override_srat(void)
 }
 #endif	/* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
 
+#ifdef CONFIG_ACPI_NUMA
+phys_addr_t early_acpi_firmware_srat(void);
+#endif  /* CONFIG_ACPI_NUMA */
+
 char * __acpi_map_table (unsigned long phys_addr, unsigned long size);
 void __acpi_unmap_table(char *map, unsigned long size);
 int early_acpi_boot_init(void);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 48964bf..4ccffe6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -107,8 +107,12 @@ void __init find_hotpluggable_memory(void)
 
 	/* Try to find if SRAT is overridden */
 	srat_paddr = early_acpi_override_srat();
-	if (!srat_paddr)
-		return;
+	if (!srat_paddr) {
+		/* Try to find SRAT from firmware if it wasn't overridden */
+		srat_paddr = early_acpi_firmware_srat();
+		if (!srat_paddr)
+			return;
+	}
 
 	/* Will parse SRAT and find out hotpluggable memory here */
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
