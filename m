Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 253BE6B0033
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:07:29 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id uz6so4605397obc.19
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 03:07:28 -0700 (PDT)
Message-ID: <52416431.1090107@cn.fujitsu.com>
Date: Tue, 24 Sep 2013 18:06:41 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/6] x86/mm: Factor out of top-down direct mapping setup
References: <524162DA.30004@cn.fujitsu.com>
In-Reply-To: <524162DA.30004@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com
Cc: "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

This patch introduces a new function memory_map_top_down to
factor out of the top-down direct memory mapping pagetable
setup. This is also a preparation for the following patch,
which will introduce the bottom-up memory mapping. That said,
we will put the two ways of pagetable setup into separate
functions, and choose to use which way in init_mem_mapping,
which makes the code more clear.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/mm/init.c |   70 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 44 insertions(+), 26 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 04664cd..73e79e6 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -401,27 +401,27 @@ static unsigned long __init init_range_memory_mapping(
 
 /* (PUD_SHIFT-PMD_SHIFT)/2 */
 #define STEP_SIZE_SHIFT 5
-void __init init_mem_mapping(void)
+
+/**
+ * memory_map_top_down - Map [map_start, map_end) top down
+ * @map_start: start address of the target memory range
+ * @map_end: end address of the target memory range
+ *
+ * This function will setup direct mapping for memory range [map_start, map_end)
+ * in a heuristic way. In the beginning, step_size is small. The more memory we
+ * map memory in the next loop.
+ */
+static void __init memory_map_top_down(unsigned long map_start,
+				       unsigned long map_end)
 {
-	unsigned long end, real_end, start, last_start;
+	unsigned long real_end, start, last_start;
 	unsigned long step_size;
 	unsigned long addr;
 	unsigned long mapped_ram_size = 0;
 	unsigned long new_mapped_ram_size;
 
-	probe_page_size_mask();
-
-#ifdef CONFIG_X86_64
-	end = max_pfn << PAGE_SHIFT;
-#else
-	end = max_low_pfn << PAGE_SHIFT;
-#endif
-
-	/* the ISA range is always mapped regardless of memory holes */
-	init_memory_mapping(0, ISA_END_ADDRESS);
-
 	/* xen has big range in reserved near end of ram, skip it at first.*/
-	addr = memblock_find_in_range(ISA_END_ADDRESS, end, PMD_SIZE, PMD_SIZE);
+	addr = memblock_find_in_range(map_start, map_end, PMD_SIZE, PMD_SIZE);
 	real_end = addr + PMD_SIZE;
 
 	/* step_size need to be small so pgt_buf from BRK could cover it */
@@ -430,19 +430,13 @@ void __init init_mem_mapping(void)
 	min_pfn_mapped = real_end >> PAGE_SHIFT;
 	last_start = start = real_end;
 
-	/*
-	 * We start from the top (end of memory) and go to the bottom.
-	 * The memblock_find_in_range() gets us a block of RAM from the
-	 * end of RAM in [min_pfn_mapped, max_pfn_mapped) used as new pages
-	 * for page table.
-	 */
-	while (last_start > ISA_END_ADDRESS) {
+	while (last_start > map_start) {
 		if (last_start > step_size) {
 			start = round_down(last_start - 1, step_size);
-			if (start < ISA_END_ADDRESS)
-				start = ISA_END_ADDRESS;
+			if (start < map_start)
+				start = map_start;
 		} else
-			start = ISA_END_ADDRESS;
+			start = map_start;
 		new_mapped_ram_size = init_range_memory_mapping(start,
 							last_start);
 		last_start = start;
@@ -453,8 +447,32 @@ void __init init_mem_mapping(void)
 		mapped_ram_size += new_mapped_ram_size;
 	}
 
-	if (real_end < end)
-		init_range_memory_mapping(real_end, end);
+	if (real_end < map_end)
+		init_range_memory_mapping(real_end, map_end);
+}
+
+void __init init_mem_mapping(void)
+{
+	unsigned long end;
+
+	probe_page_size_mask();
+
+#ifdef CONFIG_X86_64
+	end = max_pfn << PAGE_SHIFT;
+#else
+	end = max_low_pfn << PAGE_SHIFT;
+#endif
+
+	/* the ISA range is always mapped regardless of memory holes */
+	init_memory_mapping(0, ISA_END_ADDRESS);
+
+	/*
+	 * We start from the top (end of memory) and go to the bottom.
+	 * The memblock_find_in_range() gets us a block of RAM from the
+	 * end of RAM in [min_pfn_mapped, max_pfn_mapped) used as new pages
+	 * for page table.
+	 */
+	memory_map_top_down(ISA_END_ADDRESS, end);
 
 #ifdef CONFIG_X86_64
 	if (max_pfn > max_low_pfn) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
