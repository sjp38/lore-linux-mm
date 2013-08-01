Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 25DD76B003D
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 03:08:14 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 07/18] x86, acpi: Also initialize signature and length when parsing root table.
Date: Thu, 1 Aug 2013 15:06:29 +0800
Message-Id: <1375340800-19332-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Besides the phys addr of the acpi tables, it will be very convenient if
we also have the signature of each table in acpi_gbl_root_table_list at
early time. We can find SRAT easily by comparing the signature.

This patch alse record signature and some other info in
acpi_gbl_root_table_list at early time.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/acpica/tbutils.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/acpi/acpica/tbutils.c b/drivers/acpi/acpica/tbutils.c
index 9d68ffc..5d31887 100644
--- a/drivers/acpi/acpica/tbutils.c
+++ b/drivers/acpi/acpica/tbutils.c
@@ -627,6 +627,7 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
 	u32 i;
 	u32 table_count;
 	struct acpi_table_header *table;
+	struct acpi_table_desc *table_desc;
 	acpi_physical_address address;
 	acpi_physical_address uninitialized_var(rsdt_address);
 	u32 length;
@@ -766,6 +767,27 @@ acpi_tb_parse_root_table(acpi_physical_address rsdp_address)
 	 */
 	acpi_os_unmap_memory(table, length);
 
+	/*
+	 * Also initialize the table entries here, so that later we can use them
+	 * to find SRAT at very eraly time to reserve hotpluggable memory.
+	 */
+	for (i = 2; i < acpi_gbl_root_table_list.current_table_count; i++) {
+		table = acpi_os_map_memory(
+				acpi_gbl_root_table_list.tables[i].address,
+				sizeof(struct acpi_table_header));
+		if (!table)
+			return_ACPI_STATUS(AE_NO_MEMORY);
+
+		table_desc = &acpi_gbl_root_table_list.tables[i];
+
+		table_desc->pointer = NULL;
+		table_desc->length = table->length;
+		table_desc->flags = ACPI_TABLE_ORIGIN_MAPPED;
+		ACPI_MOVE_32_TO_32(table_desc->signature.ascii, table->signature);
+
+		acpi_os_unmap_memory(table, sizeof(struct acpi_table_header));
+	}
+
 	return_ACPI_STATUS(AE_OK);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
