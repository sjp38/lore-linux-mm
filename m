Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id CFE126B0044
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:01:01 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 07/21] x86, acpi: Initialize ACPI root table list earlier.
Date: Fri, 19 Jul 2013 15:59:20 +0800
Message-Id: <1374220774-29974-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

We have split acpi_table_init() into two steps:
1. Pares RSDT or XSDT, and initialize acpi_gbl_root_table_list.
   This step will record all tables' physical address in memory.
2. Check acpi initrd table override and install all tables into
   acpi_gbl_root_table_list.

This patch does step 1 earlier, right after memblock is ready.

When memblock_x86_fill() is called to fulfill memblock.memory[],
memblock is able to allocate memory.

This patch introduces a new function acpi_root_table_init() to
do step 1, and call this function right after memblock_x86_fill()
is called.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/kernel/acpi/boot.c |   38 +++++++++++++++++++++++---------------
 arch/x86/kernel/setup.c     |    3 +++
 drivers/acpi/tables.c       |    7 +++++--
 include/linux/acpi.h        |    2 ++
 4 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 230c8ea..3da5b3c 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -1491,6 +1491,28 @@ static struct dmi_system_id __initdata acpi_dmi_table_late[] = {
 };
 
 /*
+ * acpi_root_table_init - Initialize acpi_gbl_root_table_list.
+ *
+ * This function will parse RSDT or XSDT, find all tables' phys addr,
+ * initialize acpi_gbl_root_table_list, and record all tables' phys addr
+ * in acpi_gbl_root_table_list.
+ */
+void __init acpi_root_table_init(void)
+{
+	dmi_check_system(acpi_dmi_table);
+
+	/* If acpi_disabled, bail out */
+	if (acpi_disabled)
+		return;
+
+	/* Initialize the ACPI boot-time table parser */
+	if (acpi_table_init()) {
+		disable_acpi();
+		return;
+	}
+}
+
+/*
  * acpi_boot_table_init() and acpi_boot_init()
  *  called from setup_arch(), always.
  *	1. checksums all tables
@@ -1511,21 +1533,7 @@ static struct dmi_system_id __initdata acpi_dmi_table_late[] = {
 
 void __init acpi_boot_table_init(void)
 {
-	dmi_check_system(acpi_dmi_table);
-
-	/*
-	 * If acpi_disabled, bail out
-	 */
-	if (acpi_disabled)
-		return; 
-
-	/*
-	 * Initialize the ACPI boot-time table parser.
-	 */
-	if (acpi_table_init()) {
-		disable_acpi();
-		return;
-	}
+	acpi_install_root_table();
 
 	acpi_table_parse(ACPI_SIG_BOOT, acpi_parse_sbf);
 
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 56f7fcf..38a5952 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1075,6 +1075,9 @@ void __init setup_arch(char **cmdline_p)
 	memblock.current_limit = ISA_END_ADDRESS;
 	memblock_x86_fill();
 
+	/* Initialize ACPI root table */
+	acpi_root_table_init();
+
 	/*
 	 * The EFI specification says that boot service code won't be called
 	 * after ExitBootServices(). This is, in fact, a lie.
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 8860e79..60ecbb8 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -353,10 +353,13 @@ int __init acpi_table_init(void)
 	if (ACPI_FAILURE(status))
 		return 1;
 
-	acpi_tb_install_root_table();
+	return 0;
+}
 
+void __init acpi_install_root_table(void)
+{
+	acpi_tb_install_root_table();
 	check_multiple_madt();
-	return 0;
 }
 
 static int __init acpi_parse_apic_instance(char *str)
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 17b5b59..95f600c 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -92,10 +92,12 @@ void __acpi_unmap_table(char *map, unsigned long size);
 int early_acpi_boot_init(void);
 int acpi_boot_init (void);
 void acpi_boot_table_init (void);
+void acpi_root_table_init(void);
 int acpi_mps_check (void);
 int acpi_numa_init (void);
 
 int acpi_table_init (void);
+void acpi_install_root_table(void);
 int acpi_table_parse(char *id, acpi_tbl_table_handler handler);
 int __init acpi_table_parse_entries(char *id, unsigned long table_size,
 				    int entry_id,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
