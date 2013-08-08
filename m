Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id CFFEB6B0034
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 23:41:04 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part1 2/5] acpi, acpica: Call two new functions instead of acpi_tb_install_table() in acpi_tb_parse_root_table().
Date: Thu, 8 Aug 2013 11:39:33 +0800
Message-Id: <1375933176-15003-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375933176-15003-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375933176-15003-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The previous patch introduced two new functions:
    acpi_tb_install_table_firmware() and acpi_tb_install_table_override().

They are the same as acpi_tb_install_table() if they are called in sequence.

In order to split acpi_tb_parse_root_table(), we call these two functions
instead of acpi_tb_install_table() in acpi_tb_parse_root_table(). This will
keep acpi_tb_parse_root_table() works as before.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/acpica/tbutils.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/acpica/tbutils.c b/drivers/acpi/acpica/tbutils.c
index 2db068c..9bef44b 100644
--- a/drivers/acpi/acpica/tbutils.c
+++ b/drivers/acpi/acpica/tbutils.c
@@ -670,8 +670,13 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
 	 * the header of each table
 	 */
 	for (i = 2; i < acpi_gbl_root_table_list.current_table_count; i++) {
-		acpi_tb_install_table(acpi_gbl_root_table_list.tables[i].
-				      address, NULL, i);
+		/* Install tables in firmware into acpi_gbl_root_table_list */
+		acpi_tb_install_table_firmware(acpi_gbl_root_table_list.
+					       tables[i].address, NULL, i);
+
+		/* Override the installed tables if any */
+		acpi_tb_install_table_override(acpi_gbl_root_table_list.
+					       tables[i].address, NULL, i);
 
 		/* Special case for FADT - get the DSDT and FACS */
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
