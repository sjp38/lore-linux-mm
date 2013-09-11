Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3B6666B003A
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 06:05:31 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 6/9] x86, acpi: Support allocate memory from bottom upwards in acpi_initrd_override().
Date: Wed, 11 Sep 2013 18:07:34 +0800
Message-Id: <1378894057-30946-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, toshi.kani@hp.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

During early boot, if the bottom up mode is set, just
try allocating bottom up from the end of kernel image,
and if that fails, do normal top down allocation.

So in function acpi_initrd_override(), we add the
above logic.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/acpi/osl.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index e5f416c..978dcfa 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -632,6 +632,15 @@ void __init acpi_initrd_override(void *data, size_t size)
 	if (table_nr == 0)
 		return;
 
+	if (memblock_direction_bottom_up()) {
+		acpi_tables_addr = memblock_alloc_bottom_up(
+					MEMBLOCK_ALLOC_ACCESSIBLE,
+					max_low_pfn_mapped << PAGE_SHIFT,
+					all_tables_size, PAGE_SIZE);
+		if (acpi_tables_addr)
+			goto success;
+	}
+
 	acpi_tables_addr =
 		memblock_find_in_range(0, max_low_pfn_mapped << PAGE_SHIFT,
 				       all_tables_size, PAGE_SIZE);
@@ -639,6 +648,8 @@ void __init acpi_initrd_override(void *data, size_t size)
 		WARN_ON(1);
 		return;
 	}
+
+success:
 	/*
 	 * Only calling e820_add_reserve does not work and the
 	 * tables are invalid (memory got used) later.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
