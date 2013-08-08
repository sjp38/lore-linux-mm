Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 0471D8D0001
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 04:55:32 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part3 1/5] x86, acpi: Call two new functions instead of acpi_initialize_tables() in acpi_table_init().
Date: Thu, 8 Aug 2013 16:54:02 +0800
Message-Id: <1375952046-28490-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375952046-28490-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375952046-28490-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The previous patches introduces two new functions:
    acpi_initialize_tables_firmware() and acpi_initialize_tables_override(),
which work just the same as acpi_initialize_tables() if they are called
in sequence.

In order to split acpi_table_init() on acpi side, call these two functions
in acpi_table_init().

Since acpi_table_init() is also used in ia64, we keep it works as before.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/tables.c |    5 ++++-
 include/acpi/acpixf.h |    4 ++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index d67a1fe..c8f2d01 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -349,10 +349,13 @@ int __init acpi_table_init(void)
 {
 	acpi_status status;
 
-	status = acpi_initialize_tables(initial_tables, ACPI_MAX_TABLES, 0);
+	status = acpi_initialize_tables_firmware(initial_tables,
+						 ACPI_MAX_TABLES, 0);
 	if (ACPI_FAILURE(status))
 		return 1;
 
+	acpi_initialize_tables_override();
+
 	check_multiple_madt();
 	return 0;
 }
diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
index 22d497e..99c9d7b 100644
--- a/include/acpi/acpixf.h
+++ b/include/acpi/acpixf.h
@@ -115,6 +115,10 @@ extern u32 acpi_rsdt_forced;
  * Initialization
  */
 acpi_status
+acpi_initialize_tables_firmware(struct acpi_table_desc *initial_storage,
+				u32 initial_table_count, u8 allow_resize);
+void acpi_initialize_tables_override(void);
+acpi_status
 acpi_initialize_tables(struct acpi_table_desc *initial_storage,
 		       u32 initial_table_count, u8 allow_resize);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
