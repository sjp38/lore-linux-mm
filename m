Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 736A56B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 21:58:53 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3264984pbb.19
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 18:58:53 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so3320325pde.10
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 18:58:50 -0700 (PDT)
Message-ID: <524E20CB.9090902@gmail.com>
Date: Fri, 04 Oct 2013 09:58:35 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH part1 v6 2/6] memblock: Introduce bottom-up allocation mode
References: <524E2032.4020106@gmail.com>
In-Reply-To: <524E2032.4020106@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com
Cc: "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

The Linux kernel cannot migrate pages used by the kernel. As a result, kernel
pages cannot be hot-removed. So we cannot allocate hotpluggable memory for
the kernel.

ACPI SRAT (System Resource Affinity Table) contains the memory hotplug info.
But before SRAT is parsed, memblock has already started to allocate memory
for the kernel. So we need to prevent memblock from doing this.

In a memory hotplug system, any numa node the kernel resides in should
be unhotpluggable. And for a modern server, each node could have at least
16GB memory. So memory around the kernel image is highly likely unhotpluggable.

So the basic idea is: Allocate memory from the end of the kernel image and
to the higher memory. Since memory allocation before SRAT is parsed won't
be too much, it could highly likely be in the same node with kernel image.

The current memblock can only allocate memory top-down. So this patch introduces
a new bottom-up allocation mode to allocate memory bottom-up. And later
when we use this allocation direction to allocate memory, we will limit
the start address above the kernel.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |   24 +++++++++++++
 mm/memblock.c            |   87 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 108 insertions(+), 3 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 31e95ac..77c60e5 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -35,6 +35,7 @@ struct memblock_type {
 };
 
 struct memblock {
+	bool bottom_up;  /* is bottom up direction? */
 	phys_addr_t current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
@@ -148,6 +149,29 @@ phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 
 phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);
 
+#ifdef CONFIG_MOVABLE_NODE
+/*
+ * Set the allocation direction to bottom-up or top-down.
+ */
+static inline void memblock_set_bottom_up(bool enable)
+{
+	memblock.bottom_up = enable;
+}
+
+/*
+ * Check if the allocation direction is bottom-up or not.
+ * if this is true, that said, memblock will allocate memory
+ * in bottom-up direction.
+ */
+static inline bool memblock_bottom_up(void)
+{
+	return memblock.bottom_up;
+}
+#else
+static inline void memblock_set_bottom_up(bool enable) {}
+static inline bool memblock_bottom_up(void) { return false; }
+#endif
+
 /* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
 #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
 #define MEMBLOCK_ALLOC_ACCESSIBLE	0
diff --git a/mm/memblock.c b/mm/memblock.c
index accff10..04f20f4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,6 +20,8 @@
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
 
+#include <asm-generic/sections.h>
+
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 
@@ -32,6 +34,7 @@ struct memblock memblock __initdata_memblock = {
 	.reserved.cnt		= 1,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
 
+	.bottom_up		= false,
 	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
 };
 
@@ -82,6 +85,38 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
 	return (i < type->cnt) ? i : -1;
 }
 
+/*
+ * __memblock_find_range_bottom_up - find free area utility in bottom-up
+ * @start: start of candidate range
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @size: size of free area to find
+ * @align: alignment of free area to find
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * Utility called from memblock_find_in_range_node(), find free area bottom-up.
+ *
+ * RETURNS:
+ * Found address on success, 0 on failure.
+ */
+static phys_addr_t __init_memblock
+__memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
+				phys_addr_t size, phys_addr_t align, int nid)
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
 /**
  * __memblock_find_range_top_down - find free area utility, in top-down
  * @start: start of candidate range
@@ -93,7 +128,7 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
  * Utility called from memblock_find_in_range_node(), find free area top-down.
  *
  * RETURNS:
- * Found address on success, %0 on failure.
+ * Found address on success, 0 on failure.
  */
 static phys_addr_t __init_memblock
 __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
@@ -127,13 +162,24 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
  *
  * Find @size free area aligned to @align in the specified range and node.
  *
+ * When allocation direction is bottom-up, the @start should be greater
+ * than the end of the kernel image. Otherwise, it will be trimmed. The
+ * reason is that we want the bottom-up allocation just near the kernel
+ * image so it is highly likely that the allocated memory and the kernel
+ * will reside in the same node.
+ *
+ * If bottom-up allocation failed, will try to allocate memory top-down.
+ *
  * RETURNS:
- * Found address on success, %0 on failure.
+ * Found address on success, 0 on failure.
  */
 phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 					phys_addr_t end, phys_addr_t size,
 					phys_addr_t align, int nid)
 {
+	int ret;
+	phys_addr_t kernel_end;
+
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
 		end = memblock.current_limit;
@@ -141,6 +187,41 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 	/* avoid allocating the first page */
 	start = max_t(phys_addr_t, start, PAGE_SIZE);
 	end = max(start, end);
+#ifdef CONFIG_X86
+	kernel_end = __pa_symbol(_end);
+#else
+	kernel_end = __pa(RELOC_HIDE((unsigned long)(_end), 0));
+#endif
+
+	/*
+	 * try bottom-up allocation only when bottom-up mode
+	 * is set and @end is above the kernel image.
+	 */
+	if (memblock_bottom_up() && end > kernel_end) {
+		phys_addr_t bottom_up_start;
+
+		/* make sure we will allocate above the kernel */
+		bottom_up_start = max(start, kernel_end);
+
+		/* ok, try bottom-up allocation first */
+		ret = __memblock_find_range_bottom_up(bottom_up_start, end,
+						      size, align, nid);
+		if (ret)
+			return ret;
+
+		/*
+		 * we always limit bottom-up allocation above the kernel,
+		 * but top-down allocation doesn't have the limit, so
+		 * retrying top-down allocation may succeed when bottom-up
+		 * allocation failed.
+		 *
+		 * bottom-up allocation is expected to be fail very rarely,
+		 * so we use WARN_ONCE() here to see the stack trace if
+		 * fail happens.
+		 */
+		WARN_ONCE(1, "memblock: bottom-up allocation failed, "
+			     "memory hotunplug may be affected\n");
+	}
 
 	return __memblock_find_range_top_down(start, end, size, align, nid);
 }
@@ -155,7 +236,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
  * Find @size free area aligned to @align in the specified range.
  *
  * RETURNS:
- * Found address on success, %0 on failure.
+ * Found address on success, 0 on failure.
  */
 phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
 					phys_addr_t end, phys_addr_t size,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
