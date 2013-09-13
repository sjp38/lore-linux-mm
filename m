Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C8F6B6B0032
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 05:28:41 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 2/5] memblock: Improve memblock to support allocation from lower address.
Date: Fri, 13 Sep 2013 17:30:52 +0800
Message-Id: <1379064655-20874-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch modifies the memblock_find_in_range_node() to support two
different allocation directions. After this patch, memblock will check
memblock.current_direction, and decide in which direction to allocate
memory.

Now it supports two allocation directions: bottom up and top down.
When direction is top down, it acts as before.
When direction is bottom up, the start address should be greater than
the end of the kernel image. Otherwise, it will be trimmed to kernel
image end address.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/memblock.c |  107 ++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 95 insertions(+), 12 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index f24ca2e..87a7f04 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,6 +20,8 @@
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
 
+#include <asm-generic/sections.h>
+
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 
@@ -84,8 +86,81 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
 }
 
 /**
+ * __memblock_find_range - find free area utility
+ * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @size: size of free area to find
+ * @align: alignment of free area to find
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * Utility called from memblock_find_in_range_node(), find free area from
+ * lower address to higher address.
+ *
+ * RETURNS:
+ * Found address on success, %0 on failure.
+ */
+static phys_addr_t __init_memblock
+__memblock_find_range(phys_addr_t start, phys_addr_t end,
+		      phys_addr_t size, phys_addr_t align, int nid)
+{
+	phys_addr_t this_start, this_end, cand;
+	u64 i;
+
+	for_each_free_mem_range(i, nid, &this_start, &this_end, NULL) {
+		this_start = clamp(this_start, start, end);
+		this_end = clamp(this_end, start, end);
+
+		cand = round_up(this_start, align);
+		if (cand < this_end && this_end - cand >= size)
+			return cand;
+	}
+
+	return 0;
+}
+
+/**
+ * __memblock_find_range_rev - find free area utility, in reverse order
+ * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @size: size of free area to find
+ * @align: alignment of free area to find
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * Utility called from memblock_find_in_range_node(), find free area from
+ * higher address to lower address.
+ *
+ * RETURNS:
+ * Found address on success, %0 on failure.
+ */
+static phys_addr_t __init_memblock
+__memblock_find_range_rev(phys_addr_t start, phys_addr_t end,
+			  phys_addr_t size, phys_addr_t align, int nid)
+{
+	phys_addr_t this_start, this_end, cand;
+	u64 i;
+
+	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
+		this_start = clamp(this_start, start, end);
+		this_end = clamp(this_end, start, end);
+
+		/*
+		 * Just in case that (this_end - size) underflows and cause
+		 * (cand >= this_start) to be true incorrectly.
+		 */
+		if (this_end < size)
+			break;
+
+		cand = round_down(this_end - size, align);
+		if (cand >= this_start)
+			return cand;
+	}
+
+	return 0;
+}
+
+/**
  * memblock_find_in_range_node - find free area in given range and node
- * @start: start of candidate range
+ * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
@@ -93,6 +168,11 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
  *
  * Find @size free area aligned to @align in the specified range and node.
  *
+ * When allocation direction is from low to high, the @start should be greater
+ * than the end of the kernel image. Otherwise, it will be trimmed. And also,
+ * if allocation from low to high failed, will try to allocate memory from high
+ * to low again.
+ *
  * RETURNS:
  * Found address on success, %0 on failure.
  */
@@ -100,8 +180,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 					phys_addr_t end, phys_addr_t size,
 					phys_addr_t align, int nid)
 {
-	phys_addr_t this_start, this_end, cand;
-	u64 i;
+	phys_addr_t ret;
 
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
@@ -111,18 +190,22 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 	start = max_t(phys_addr_t, start, PAGE_SIZE);
 	end = max(start, end);
 
-	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
-		this_start = clamp(this_start, start, end);
-		this_end = clamp(this_end, start, end);
+	if (memblock_direction_bottom_up()) {
+		/*
+		 * MEMBLOCK_ALLOC_ACCESSIBLE is 0, which is less than the end
+		 * of kernel image. So callers specify MEMBLOCK_ALLOC_ACCESSIBLE
+		 * as @start is OK.
+		 */
+		start =	max(start, __pa_symbol(_end)); /* End of kernel image. */
 
-		if (this_end < size)
-			continue;
+		ret = __memblock_find_range(start, end, size, align, nid);
+		if (ret)
+			return ret;
 
-		cand = round_down(this_end - size, align);
-		if (cand >= this_start)
-			return cand;
+		pr_warn("memblock: Failed to allocate memory in bottom up direction. Now try top down direction.\n");
 	}
-	return 0;
+
+	return __memblock_find_range_rev(start, end, size, align, nid);
 }
 
 /**
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
