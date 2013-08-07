Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 631CC6B00C0
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 07:13:41 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 14/25] x86, acpi: Initialize acpi golbal root table list earlier.
Date: Wed, 7 Aug 2013 18:52:05 +0800
Message-Id: <1375872736-4822-15-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

As the previous patches split the acpi_gbl_root_table_list initialization
procedure into two steps: install and override, this patch does the "install"
steps earlier, right after memblock is ready.

In this way, we are able to find SRAT in firmware earlier. And then, we can
prevent memblock from allocating hotpluggable memory for the kernel.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/kernel/acpi/boot.c |   30 +++++++++++++++++-------------
 arch/x86/kernel/setup.c     |    8 +++++++-
 include/linux/acpi.h        |    1 +
 3 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index ddb0bc1..30daefd 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -1497,6 +1497,23 @@ static struct dmi_system_id __initdata acpi_dmi_table_late[] = {
 	{}
 };
 
+void __init early_acpi_boot_table_init(void)
+{
+	dmi_check_system(acpi_dmi_table);
+
+	/*
+	 * If acpi_disabled, bail out
+	 */
+	if (acpi_disabled)
+		return; 
+
+	/*
+	 * Initialize the ACPI boot-time table parser.
+	 */
+	if (acpi_table_init_firmware())
+		disable_acpi();
+}
+
 /*
  * acpi_boot_table_init() and acpi_boot_init()
  *  called from setup_arch(), always.
@@ -1504,9 +1521,6 @@ static struct dmi_system_id __initdata acpi_dmi_table_late[] = {
  *	2. enumerates lapics
  *	3. enumerates io-apics
  *
- * acpi_table_init() is separate to allow reading SRAT without
- * other side effects.
- *
  * side effects of acpi_boot_init:
  *	acpi_lapic = 1 if LAPIC found
  *	acpi_ioapic = 1 if IOAPIC found
@@ -1518,22 +1532,12 @@ static struct dmi_system_id __initdata acpi_dmi_table_late[] = {
 
 void __init acpi_boot_table_init(void)
 {
-	dmi_check_system(acpi_dmi_table);
-
 	/*
 	 * If acpi_disabled, bail out
 	 */
 	if (acpi_disabled)
 		return; 
 
-	/*
-	 * Initialize the ACPI boot-time table parser.
-	 */
-	if (acpi_table_init_firmware()) {
-		disable_acpi();
-		return;
-	}
-
 	acpi_table_init_override();
 
 	acpi_check_multiple_madt();
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index f8ec578..fdb5a26 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1074,6 +1074,12 @@ void __init setup_arch(char **cmdline_p)
 	memblock_x86_fill();
 
 	/*
+	 * Parse the ACPI tables from firmware for possible boot-time SMP
+	 * configuration.
+	 */
+	early_acpi_boot_table_init();
+
+	/*
 	 * The EFI specification says that boot service code won't be called
 	 * after ExitBootServices(). This is, in fact, a lie.
 	 */
@@ -1130,7 +1136,7 @@ void __init setup_arch(char **cmdline_p)
 	io_delay_init();
 
 	/*
-	 * Parse the ACPI tables for possible boot-time SMP configuration.
+	 * Finish parsing the ACPI tables.
 	 */
 	acpi_boot_table_init();
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 44a3e5f..c5e7b2a 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -91,6 +91,7 @@ char * __acpi_map_table (unsigned long phys_addr, unsigned long size);
 void __acpi_unmap_table(char *map, unsigned long size);
 int early_acpi_boot_init(void);
 int acpi_boot_init (void);
+void early_acpi_boot_table_init (void);
 void acpi_boot_table_init (void);
 int acpi_mps_check (void);
 int acpi_numa_init (void);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
