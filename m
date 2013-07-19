Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 57C786B0044
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:01:03 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 13/21] x86, acpi: Try to find SRAT in firmware earlier.
Date: Fri, 19 Jul 2013 15:59:26 +0800
Message-Id: <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch introduce early_acpi_firmware_srat() to find the
phys addr of SRAT provided by firmware. And call it in
reserve_hotpluggable_memory().

Since we have initialized acpi_gbl_root_table_list earlier,
and store all the tables' phys addrs and signatures in it,
it is easy to find the SRAT.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/acpi/acpica/tbxface.c |   34 ++++++++++++++++++++++++++++++++++
 drivers/acpi/osl.c            |   24 ++++++++++++++++++++++++
 include/acpi/acpixf.h         |    4 ++++
 include/linux/acpi.h          |    4 ++++
 mm/memory_hotplug.c           |   10 +++++++---
 5 files changed, 73 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/acpica/tbxface.c b/drivers/acpi/acpica/tbxface.c
index ad11162..95f8d1b 100644
--- a/drivers/acpi/acpica/tbxface.c
+++ b/drivers/acpi/acpica/tbxface.c
@@ -181,6 +181,40 @@ acpi_status acpi_reallocate_root_table(void)
 	return_ACPI_STATUS(status);
 }
 
+/*
+ * acpi_get_table_desc - Get the acpi table descriptor of a specific table.
+ * @signature: The signature of the table to be found.
+ * @out_desc: The out returned descriptor.
+ *
+ * This function iterates acpi_gbl_root_table_list and find the specified
+ * table's descriptor.
+ *
+ * NOTE: The caller has the responsibility to allocate memory for @out_desc.
+ *
+ * Return AE_OK on success, AE_NOT_FOUND if the table is not found.
+ */
+acpi_status acpi_get_table_desc(char *signature,
+				struct acpi_table_desc *out_desc)
+{
+	int pos;
+
+	for (pos = 0;
+	     pos < acpi_gbl_root_table_list.current_table_count;
+	     pos++) {
+		if (!ACPI_COMPARE_NAME
+		    (&(acpi_gbl_root_table_list.tables[pos].signature),
+		    signature))
+			continue;
+
+		memcpy(out_desc, &acpi_gbl_root_table_list.tables[pos],
+		       sizeof(struct acpi_table_desc));
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
index fa6b973..a2e4596 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -53,6 +53,7 @@
 #include <acpi/acpi.h>
 #include <acpi/acpi_bus.h>
 #include <acpi/processor.h>
+#include <acpi/acpixf.h>
 
 #define _COMPONENT		ACPI_OS_SERVICES
 ACPI_MODULE_NAME("osl");
@@ -750,6 +751,29 @@ void __init acpi_initrd_override(void *data, size_t size)
 }
 #endif /* CONFIG_ACPI_INITRD_TABLE_OVERRIDE */
 
+#ifdef CONFIG_ACPI_NUMA
+#include <asm/numa.h>
+#include <linux/memblock.h>
+
+/*
+ * early_acpi_firmware_srat - Get the phys addr of SRAT provide by firmware.
+ *
+ * This function iterate acpi_gbl_root_table_list, find SRAT and return the
+ * phys addr of SRAT.
+ *
+ * Return the phys addr of SRAT, or 0 on error.
+ */
+phys_addr_t __init early_acpi_firmware_srat()
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
index 066873e..15b11d3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -106,10 +106,14 @@ void __init reserve_hotpluggable_memory(void)
 {
 	phys_addr_t srat_paddr;
 
-	/* Try to find if SRAT is overrided */
+	/* Try to find out if SRAT is overrided */
 	srat_paddr = early_acpi_override_srat();
-	if (!srat_paddr)
-		return;
+	if (!srat_paddr) {
+		/* Try to find SRAT from firmware if it wasn't overrided */
+		srat_paddr = early_acpi_firmware_srat();
+		if (!srat_paddr)
+			return;
+	}
 
 	/* Will reserve hotpluggable memory here */
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
