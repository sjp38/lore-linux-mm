Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id F08656B0039
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 06:05:31 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 8/9] x86, mem-hotplug: Support initialize page tables from low to high.
Date: Wed, 11 Sep 2013 18:07:36 +0800
Message-Id: <1378894057-30946-9-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, toshi.kani@hp.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

init_mem_mapping() is called before SRAT is parsed. And memblock will allocate
memory for page tables. To prevent page tables being allocated within hotpluggable
memory, we will allocate page tables from the end of kernel image to the higher
memory.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/mm/init.c |  133 ++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 104 insertions(+), 29 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 04664cd..7dae4e3 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -54,11 +54,23 @@ __ref void *alloc_low_pages(unsigned int num)
 		unsigned long ret;
 		if (min_pfn_mapped >= max_pfn_mapped)
 			panic("alloc_low_page: ran out of memory");
+
+		if (memblock_direction_bottom_up()) {
+			ret = memblock_alloc_bottom_up(
+						MEMBLOCK_ALLOC_ACCESSIBLE,
+						max_pfn_mapped << PAGE_SHIFT,
+						PAGE_SIZE * num, PAGE_SIZE);
+			if (ret)
+				goto reserve;
+		}
+
 		ret = memblock_find_in_range(min_pfn_mapped << PAGE_SHIFT,
 					max_pfn_mapped << PAGE_SHIFT,
 					PAGE_SIZE * num , PAGE_SIZE);
 		if (!ret)
 			panic("alloc_low_page: can not alloc memory");
+
+reserve:
 		memblock_reserve(ret, PAGE_SIZE * num);
 		pfn = ret >> PAGE_SHIFT;
 	} else {
@@ -401,13 +413,79 @@ static unsigned long __init init_range_memory_mapping(
 
 /* (PUD_SHIFT-PMD_SHIFT)/2 */
 #define STEP_SIZE_SHIFT 5
-void __init init_mem_mapping(void)
+
+#ifdef CONFIG_MOVABLE_NODE
+/**
+ * memory_map_from_low - Map [start, end) from low to high
+ * @start: start address of the target memory range
+ * @end: end address of the target memory range
+ *
+ * This function will setup direct mapping for memory range [start, end) in a
+ * heuristic way. In the beginning, step_size is small. The more memory we map
+ * memory in the next loop.
+ */
+static void __init memory_map_from_low(unsigned long start, unsigned long end)
+{
+	unsigned long next, new_mapped_ram_size;
+	unsigned long mapped_ram_size = 0;
+	/* step_size need to be small so pgt_buf from BRK could cover it */
+	unsigned long step_size = PMD_SIZE;
+
+	while (start < end) {
+		if (end - start > step_size) {
+			next = round_up(start + 1, step_size);
+			if (next > end)
+				next = end;
+		} else
+			next = end;
+
+		new_mapped_ram_size = init_range_memory_mapping(start, next);
+		min_pfn_mapped = start >> PAGE_SHIFT;
+		start = next;
+
+		if (new_mapped_ram_size > mapped_ram_size)
+			step_size <<= STEP_SIZE_SHIFT;
+		mapped_ram_size += new_mapped_ram_size;
+	}
+}
+#endif /* CONFIG_MOVABLE_NODE */
+
+/**
+ * memory_map_from_high - Map [start, end) from high to low
+ * @start: start address of the target memory range
+ * @end: end address of the target memory range
+ *
+ * This function is similar to memory_map_from_low() except it maps memory
+ * from high to low.
+ */
+static void __init memory_map_from_high(unsigned long start, unsigned long end)
 {
-	unsigned long end, real_end, start, last_start;
-	unsigned long step_size;
-	unsigned long addr;
+	unsigned long prev, new_mapped_ram_size;
 	unsigned long mapped_ram_size = 0;
-	unsigned long new_mapped_ram_size;
+	/* step_size need to be small so pgt_buf from BRK could cover it */
+	unsigned long step_size = PMD_SIZE;
+
+	while (start < end) {
+		if (end > step_size) {
+			prev = round_down(end - 1, step_size);
+			if (prev < start)
+				prev = start;
+		} else
+			prev = start;
+
+		new_mapped_ram_size = init_range_memory_mapping(prev, end);
+		min_pfn_mapped = prev >> PAGE_SHIFT;
+		end = prev;
+
+		if (new_mapped_ram_size > mapped_ram_size)
+			step_size <<= STEP_SIZE_SHIFT;
+		mapped_ram_size += new_mapped_ram_size;
+	}
+}
+
+void __init init_mem_mapping(void)
+{
+	unsigned long end;
 
 	probe_page_size_mask();
 
@@ -417,45 +495,42 @@ void __init init_mem_mapping(void)
 	end = max_low_pfn << PAGE_SHIFT;
 #endif
 
-	/* the ISA range is always mapped regardless of memory holes */
-	init_memory_mapping(0, ISA_END_ADDRESS);
+	max_pfn_mapped = 0; /* will get exact value next */
+	min_pfn_mapped = end >> PAGE_SHIFT;
+
+#ifdef CONFIG_MOVABLE_NODE
+	unsigned long kernel_end;
+
+	if (memblock_direction_bottom_up()) {
+		kernel_end = round_up(__pa_symbol(_end), PMD_SIZE);
+
+		memory_map_from_low(kernel_end, end);
+		memory_map_from_low(ISA_END_ADDRESS, kernel_end);
+		goto out;
+	}
+#endif /* CONFIG_MOVABLE_NODE */
+
+	unsigned long addr, real_end;
 
 	/* xen has big range in reserved near end of ram, skip it at first.*/
 	addr = memblock_find_in_range(ISA_END_ADDRESS, end, PMD_SIZE, PMD_SIZE);
 	real_end = addr + PMD_SIZE;
 
-	/* step_size need to be small so pgt_buf from BRK could cover it */
-	step_size = PMD_SIZE;
-	max_pfn_mapped = 0; /* will get exact value next */
-	min_pfn_mapped = real_end >> PAGE_SHIFT;
-	last_start = start = real_end;
-
 	/*
 	 * We start from the top (end of memory) and go to the bottom.
 	 * The memblock_find_in_range() gets us a block of RAM from the
 	 * end of RAM in [min_pfn_mapped, max_pfn_mapped) used as new pages
 	 * for page table.
 	 */
-	while (last_start > ISA_END_ADDRESS) {
-		if (last_start > step_size) {
-			start = round_down(last_start - 1, step_size);
-			if (start < ISA_END_ADDRESS)
-				start = ISA_END_ADDRESS;
-		} else
-			start = ISA_END_ADDRESS;
-		new_mapped_ram_size = init_range_memory_mapping(start,
-							last_start);
-		last_start = start;
-		min_pfn_mapped = last_start >> PAGE_SHIFT;
-		/* only increase step_size after big range get mapped */
-		if (new_mapped_ram_size > mapped_ram_size)
-			step_size <<= STEP_SIZE_SHIFT;
-		mapped_ram_size += new_mapped_ram_size;
-	}
+	memory_map_from_high(ISA_END_ADDRESS, real_end);
 
 	if (real_end < end)
 		init_range_memory_mapping(real_end, end);
 
+out:
+	/* the ISA range is always mapped regardless of memory holes */
+	init_memory_mapping(0, ISA_END_ADDRESS);
+
 #ifdef CONFIG_X86_64
 	if (max_pfn > max_low_pfn) {
 		/* can we preseve max_low_pfn ?*/
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
