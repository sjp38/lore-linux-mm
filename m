Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 98A536B0039
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 16:18:58 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so3265078pab.26
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:18:58 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so3128581pdj.36
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:18:55 -0700 (PDT)
Message-ID: <52570B94.7020204@gmail.com>
Date: Fri, 11 Oct 2013 04:18:28 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH part1 v7 3/6] x86/mm: Factor out of top-down direct mapping
 setup
References: <52570A6E.2010806@gmail.com>
In-Reply-To: <52570A6E.2010806@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, mina86@mina86.com, Minchan Kim <minchan@kernel.org>, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com
Cc: "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

This patch creates a new function memory_map_top_down to
factor out of the top-down direct memory mapping pagetable
setup. This is also a preparation for the following patch,
which will introduce the bottom-up memory mapping. That said,
we will put the two ways of pagetable setup into separate
functions, and choose to use which way in init_mem_mapping,
which makes the code more clear.

Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/mm/init.c |   60 ++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 40 insertions(+), 20 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 04664cd..ea2be79 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -401,27 +401,28 @@ static unsigned long __init init_range_memory_mapping(
 
 /* (PUD_SHIFT-PMD_SHIFT)/2 */
 #define STEP_SIZE_SHIFT 5
-void __init init_mem_mapping(void)
+
+/**
+ * memory_map_top_down - Map [map_start, map_end) top down
+ * @map_start: start address of the target memory range
+ * @map_end: end address of the target memory range
+ *
+ * This function will setup direct mapping for memory range
+ * [map_start, map_end) in top-down. That said, the page tables
+ * will be allocated at the end of the memory, and we map the
+ * memory in top-down.
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
@@ -436,13 +437,13 @@ void __init init_mem_mapping(void)
 	 * end of RAM in [min_pfn_mapped, max_pfn_mapped) used as new pages
 	 * for page table.
 	 */
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
@@ -453,8 +454,27 @@ void __init init_mem_mapping(void)
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
+	/* setup direct mapping for range [ISA_END_ADDRESS, end) in top-down*/
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
