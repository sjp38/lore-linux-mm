Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 92E9A6B0071
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 21:34:28 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 2/5] page_alloc: add movable_memmap kernel parameter
Date: Tue, 11 Dec 2012 10:33:24 +0800
Message-Id: <1355193207-21797-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355193207-21797-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1355193207-21797-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

This patch adds functions to parse movablecore_map boot option. Since the
option could be specified more then once, all the maps will be stored in
the global variable movablecore_map.map array.

And also, we keep the array in monotonic increasing order by start_pfn.
And merge all overlapped ranges.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   17 +++++
 include/linux/mm.h                  |   11 +++
 mm/page_alloc.c                     |  126 +++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 9776f06..785f878 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1620,6 +1620,23 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
+	movablecore_map=nn[KMG]@ss[KMG]
+			[KNL,X86,IA-64,PPC] This parameter is similar to
+			memmap except it specifies the memory map of
+			ZONE_MOVABLE.
+			If more areas are all within one node, then from
+			lowest ss to the end of the node will be ZONE_MOVABLE.
+			If an area covers two or more nodes, the area from
+			ss to the end of the 1st node will be ZONE_MOVABLE,
+			and all the rest nodes will only have ZONE_MOVABLE.
+			If memmap is specified at the same time, the
+			movablecore_map will be limited within the memmap
+			areas. If kernelcore or movablecore is also specified,
+			movablecore_map will have higher priority to be
+			satisfied. So the administrator should be careful that
+			the amount of movablecore_map areas are not too large.
+			Otherwise kernel won't have enough memory to start.
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e..29622c2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1328,6 +1328,17 @@ extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
 
+#define MOVABLECORE_MAP_MAX MAX_NUMNODES
+struct movablecore_entry {
+	unsigned long start_pfn;    /* start pfn of memory segment */
+	unsigned long end_pfn;      /* end pfn of memory segment */
+};
+
+struct movablecore_map {
+	int nr_map;
+	struct movablecore_entry map[MOVABLECORE_MAP_MAX];
+};
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8f2c87..1c91d16 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -198,6 +198,9 @@ static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+/* Movable memory ranges, will also be used by memblock subsystem. */
+struct movablecore_map movablecore_map;
+
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __initdata required_kernelcore;
@@ -5003,6 +5006,129 @@ static int __init cmdline_parse_movablecore(char *p)
 early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
+/**
+ * insert_movablecore_map - Insert a memory range in to movablecore_map.map.
+ * @start_pfn: start pfn of the range
+ * @end_pfn: end pfn of the range
+ *
+ * This function will also merge the overlapped ranges, and sort the array
+ * by start_pfn in monotonic increasing order.
+ */
+static void __init insert_movablecore_map(unsigned long start_pfn,
+					  unsigned long end_pfn)
+{
+	int pos, overlap;
+
+	/*
+	 * pos will be at the 1st overlapped range, or the position
+	 * where the element should be inserted.
+	 */
+	for (pos = 0; pos < movablecore_map.nr_map; pos++)
+		if (start_pfn <= movablecore_map.map[pos].end_pfn)
+			break;
+
+	/* If there is no overlapped range, just insert the element. */
+	if (pos == movablecore_map.nr_map ||
+	    end_pfn < movablecore_map.map[pos].start_pfn) {
+		/*
+		 * If pos is not the end of array, we need to move all
+		 * the rest elements backward.
+		 */
+		if (pos < movablecore_map.nr_map)
+			memmove(&movablecore_map.map[pos+1],
+				&movablecore_map.map[pos],
+				sizeof(struct movablecore_entry) *
+				(movablecore_map.nr_map - pos));
+		movablecore_map.map[pos].start_pfn = start_pfn;
+		movablecore_map.map[pos].end_pfn = end_pfn;
+		movablecore_map.nr_map++;
+		return;
+	}
+
+	/* overlap will be at the last overlapped range */
+	for (overlap = pos + 1; overlap < movablecore_map.nr_map; overlap++)
+		if (end_pfn < movablecore_map.map[overlap].start_pfn)
+			break;
+
+	/*
+	 * If there are more ranges overlapped, we need to merge them,
+	 * and move the rest elements forward.
+	 */
+	overlap--;
+	movablecore_map.map[pos].start_pfn = min(start_pfn,
+					movablecore_map.map[pos].start_pfn);
+	movablecore_map.map[pos].end_pfn = max(end_pfn,
+					movablecore_map.map[overlap].end_pfn);
+
+	if (pos != overlap && overlap + 1 != movablecore_map.nr_map)
+		memmove(&movablecore_map.map[pos+1],
+			&movablecore_map.map[overlap+1],
+			sizeof(struct movablecore_entry) *
+			(movablecore_map.nr_map - overlap - 1));
+
+	movablecore_map.nr_map -= overlap - pos;
+}
+
+/**
+ * movablecore_map_add_region - Add a memory range into movablecore_map.
+ * @start: physical start address of range
+ * @end: physical end address of range
+ *
+ * This function transform the physical address into pfn, and then add the
+ * range into movablecore_map by calling insert_movablecore_map().
+ */
+static void __init movablecore_map_add_region(u64 start, u64 size)
+{
+	unsigned long start_pfn, end_pfn;
+
+	/* In case size == 0 or start + size overflows */
+	if (start + size <= start)
+		return;
+
+	if (movablecore_map.nr_map >= ARRAY_SIZE(movablecore_map.map)) {
+		pr_err("movable_memory_map: too many entries;"
+			" ignoring [mem %#010llx-%#010llx]\n",
+			(unsigned long long) start,
+			(unsigned long long) (start + size - 1));
+		return;
+	}
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = PFN_UP(start + size);
+	insert_movablecore_map(start_pfn, end_pfn);
+}
+
+/*
+ * movablecore_map=nn[KMG]@ss[KMG] sets the region of memory to be used as
+ * movable memory.
+ */
+static int __init cmdline_parse_movablecore_map(char *p)
+{
+	char *oldp;
+	u64 start_at, mem_size;
+
+	if (!p)
+		goto err;
+
+	oldp = p;
+	mem_size = memparse(p, &p);
+	if (p == oldp)
+		goto err;
+
+	if (*p == '@') {
+		oldp = ++p;
+		start_at = memparse(p, &p);
+		if (p == oldp || *p != '\0')
+			goto err;
+
+		movablecore_map_add_region(start_at, mem_size);
+		return 0;
+	}
+err:
+	return -EINVAL;
+}
+early_param("movablecore_map", cmdline_parse_movablecore_map);
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 /**
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
