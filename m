Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9EADD900001
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 04:55:34 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part3 4/5] x86, acpi: Split acpi_boot_table_init() into two parts.
Date: Thu, 8 Aug 2013 16:54:05 +0800
Message-Id: <1375952046-28490-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375952046-28490-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375952046-28490-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch splits acpi_boot_table_init() into two steps,
so that we can do each step separately in later patches.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/kernel/acpi/boot.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 2627a81..ddb0bc1 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -1529,11 +1529,15 @@ void __init acpi_boot_table_init(void)
 	/*
 	 * Initialize the ACPI boot-time table parser.
 	 */
-	if (acpi_table_init()) {
+	if (acpi_table_init_firmware()) {
 		disable_acpi();
 		return;
 	}
 
+	acpi_table_init_override();
+
+	acpi_check_multiple_madt();
+
 	acpi_table_parse(ACPI_SIG_BOOT, acpi_parse_sbf);
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
