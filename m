Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4187B6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:06:08 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id g12so1857545oah.1
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 03:06:08 -0700 (PDT)
Message-ID: <524163CF.3010303@cn.fujitsu.com>
Date: Tue, 24 Sep 2013 18:05:03 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/6] memblock: Introduce bottom-up allocation mode
References: <524162DA.30004@cn.fujitsu.com>
In-Reply-To: <524162DA.30004@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

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
 include/linux/memblock.h |   26 +++++++++++++++++++
 mm/memblock.c            |   63 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 31e95ac..c14bca5 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -19,6 +19,13 @@
 
 #define INIT_MEMBLOCK_REGIONS	128
 
+/* Allocation direction */
+enum {
+	MEMBLOCK_DIRECTION_TOP_DOWN,
+	MEMBLOCK_DIRECTION_BOTTOM_UP,
+	NR_MEMLBOCK_DIRECTIONS
+};
+
 struct memblock_region {
 	phys_addr_t base;
 	phys_addr_t size;
@@ -35,6 +42,7 @@ struct memblock_type {
 };
 
 struct memblock {
+	int current_direction;  /* current allocation direction */
 	phys_addr_t current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
@@ -148,6 +156,24 @@ phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 
 phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);
 
+#ifdef CONFIG_MOVABLE_NODE
+static inline void memblock_set_bottom_up(bool enable)
+{
+	if (enable)
+		memblock.current_direction = MEMBLOCK_DIRECTION_BOTTOM_UP;
+	else
+		memblock.current_direction = MEMBLOCK_DIRECTION_TOP_DOWN;
+}
+
+static inline bool memblock_bottom_up(void)
+{
+	return memblock.current_direction == MEMBLOCK_DIRECTION_BOTTOM_UP;
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
index 3d80c74..5859b8e 100644
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
 
+	.current_direction	= MEMBLOCK_DIRECTION_TOP_DOWN,
 	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
 };
 
@@ -83,6 +86,38 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
 }
 
 /**
+ * __memblock_find_range - find free area utility
+ * @start: start of candidate range
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @size: size of free area to find
+ * @align: alignment of free area to find
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * Utility called from memblock_find_in_range_node(), find free area bottom-up.
+ *
+ * RETURNS:
+ * Found address on success, %0 on failure.
+ */
+static phys_addr_t __init_memblock
+__memblock_find_range(phys_addr_t start, phys_addr_t end, phys_addr_t size,
+		      phys_addr_t align, int nid)
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
  * __memblock_find_range_rev - find free area utility, in reverse order
  * @start: start of candidate range
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
@@ -127,6 +162,10 @@ __memblock_find_range_rev(phys_addr_t start, phys_addr_t end,
  *
  * Find @size free area aligned to @align in the specified range and node.
  *
+ * When allocation direction is bottom-up, the @start should be greater
+ * than the end of the kernel image. Otherwise, it will be trimmed. And also,
+ * if bottom-up allocation failed, will try to allocate memory top-down.
+ *
  * RETURNS:
  * Found address on success, %0 on failure.
  */
@@ -134,6 +173,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 					phys_addr_t end, phys_addr_t size,
 					phys_addr_t align, int nid)
 {
+	int ret;
+
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
 		end = memblock.current_limit;
@@ -142,6 +183,28 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 	start = max_t(phys_addr_t, start, PAGE_SIZE);
 	end = max(start, end);
 
+	if (memblock_bottom_up()) {
+		phys_addr_t bottom_up_start;
+
+		/* make sure we will allocate above the kernel */
+		bottom_up_start = max_t(phys_addr_t, start, __pa_symbol(_end));
+
+		/* ok, try bottom-up allocation first */
+		ret = __memblock_find_range(bottom_up_start, end,
+					    size, align, nid);
+		if (ret)
+			return ret;
+
+		/*
+		 * we always limit bottom-up allocation above the kernel,
+		 * but top-down allocation doesn't have the limit, so
+		 * retrying top-down allocation may succeed when bottom-up
+		 * allocation failed.
+		 */
+		pr_warn("memblock: Failed to allocate memory in bottom up "
+			"direction. Now try top down direction.\n");
+	}
+
 	return __memblock_find_range_rev(start, end, size, align, nid);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
