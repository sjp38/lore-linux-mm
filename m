Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id E03866B0062
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 03:16:08 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v4 2/6] page_alloc: add movablecore_map kernel parameter
Date: Wed, 19 Dec 2012 16:14:59 +0800
Message-Id: <1355904903-22699-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355904903-22699-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1355904903-22699-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

[What are we doing]
This patch adds a new kernel boot option named movablecore_map to allow
user to specify the range of ZONE_MOVABLE of each node.


[Why do we do this]
The memory used by kernel, such as direct mapping pages, could not be
migrated. As a result, the corresponding memory device could not be
hotplugged. So in order to implement a whole node hotplug feature, we
need to limit the node to only contain movable memory (ZONE_MOVABLE).

This option provide 3 ways to control which memory could be hotplugged.
1. User could specify one or more physical address ranges to inform kernel
   these ranges should be in ZONE_MOVABLE.
   (using movablecore_map=nn[KMG]@ss[KMG])

2. Using the Hot Pluggable bit in flags from SRAT from BIOS, user could just
   leave the configuration work to the kernel.
   (using movablecore_map=acpi)

3. Users with feature known as "hardware memory migration" could migrate
   kernel pages transparently to OS, and these users may just don't use it.

NOTE: We do not use node ids because they could change on each boot.


[How to use]
The option can be used as following:

1. If user want to specify hotpluggable memory ranges by himself, then specify
   as the following:
	movablecore_map=nn[KMG]@ss[KMG]
   In this way, the kernel will check if the ranges are hotpluggable with the
   Hot Pluggable bit in SRAT from ACPI BIOS.
   - If a range is hotpluggable, then from ss to the end of the corresponding
     node will be ZONE_MOVABLE.
   - If a range is not hotpluggable, then the range will be ignored.

2. If user want to leave the configuration work to the kernel, then specify
   as the following:
	movablecore_map=acpi
   In this way, the kernel will get hotplug info from SRAT in ACPI BIOS, and
   auto decide which memory devices could be hotplugged. And all the memory
   on these devices will be in ZONE_MOVABLE.

3. If user didn't specify this option, then the kernel will use all the
   memory on all the nodes evenly. And there is no performance drawback.


This patch also adds functions to parse movablecore_map boot option.
Since the option could be specified more then once, all the maps will
be stored in the global variable movablecore_map.map array.

And also, we keep the array in monotonic increasing order by start_pfn.
And merge all overlapped ranges.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
Tested-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   29 +++++
 include/linux/mm.h                  |   17 +++
 mm/page_alloc.c                     |  211 +++++++++++++++++++++++++++++++++++
 3 files changed, 257 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index ea8e5b4..af6cce0 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1642,6 +1642,35 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
+	movablecore_map=acpi
+			[KNL,X86,IA-64,PPC] This parameter is similar to
+                        memmap except it specifies the memory map of
+                        ZONE_MOVABLE.
+			This option inform the kernel to use Hot Pluggable bit
+			in flags from SRAT from ACPI BIOS to determine which
+			memory devices could be hotplugged. The corresponding
+			memory ranges will be set as ZONE_MOVABLE.
+
+	movablecore_map=nn[KMG]@ss[KMG]
+			[KNL,X86,IA-64,PPC] The kernel will check if the range
+			is hotpluggable with Hot Pluggable bit in SRAT. If not,
+			the range will be ingored. If yes, do the following:
+			- If more ranges are all within one node, then from
+			  lowest ss to the end of the node will be ZONE_MOVABLE.
+			- If a range is within a node, then from ss to the end
+			  of the node will be ZONE_MOVABLE.
+			- If a range covers two or more nodes, then from ss to
+			  the end of the 1st node will be ZONE_MOVABLE, and all
+			  the rest nodes will only have ZONE_MOVABLE.
+			If memmap is specified at the same time, the
+			movablecore_map will be limited within the memmap
+			areas.
+			If kernelcore or movablecore is also specified,
+			movablecore_map will have higher priority to be
+			satisfied. So the administrator should be careful that
+			the amount of movablecore_map areas are not too large.
+			Otherwise kernel won't have enough memory to start.
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7f4f906..3ab1bdb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1361,6 +1361,23 @@ extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
 
+#define MOVABLECORE_MAP_MAX MAX_NUMNODES
+struct movablecore_entry {
+	unsigned long start_pfn;    /* start pfn of memory segment */
+	unsigned long end_pfn;      /* end pfn of memory segment */
+};
+
+struct movablecore_map {
+	bool acpi;
+	int nr_map;
+	struct movablecore_entry map[MOVABLECORE_MAP_MAX];
+};
+
+extern int insert_movablecore_map(unsigned long start_pfn,
+				  unsigned long end_pfn);
+extern void remove_movablecore_map(unsigned long start_pfn,
+				   unsigned long end_pfn);
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d037c8b..40d2f4b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -201,6 +201,12 @@ static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+/* Movable memory ranges, will also be used by memblock subsystem. */
+struct movablecore_map movablecore_map = {
+	.acpi = false,
+	.nr_map = 0,
+};
+
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __initdata required_kernelcore;
@@ -5082,6 +5088,211 @@ static int __init cmdline_parse_movablecore(char *p)
 early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
+/**
+ * insert_movablecore_map - Insert a memory range into movablecore_map.map.
+ * @start_pfn: start pfn of the range
+ * @end_pfn: end pfn of the range
+ *
+ * Return 0 on success, -1 if array overflows.
+ *
+ * This function will also merge the overlapped ranges, and sort the array
+ * by start_pfn in monotonic increasing order.
+ */
+int __init insert_movablecore_map(unsigned long start_pfn,
+				  unsigned long end_pfn)
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
+		/* No more insertion if array overflows. */
+		if (movablecore_map.nr_map >= ARRAY_SIZE(movablecore_map.map))
+			return -1;
+
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
+		return 0;
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
+	return 0;
+}
+
+/**
+ * remove_movablecore_map - Remove all the parts overlapped with
+ * [start_pfn, end_pfn) from movablecore_map.map.
+ * @start_pfn: start pfn of the range
+ * @end_pfn: end pfn of the range
+ */
+void __init remove_movablecore_map(unsigned long start_pfn,
+				   unsigned long end_pfn)
+{
+	int pos, overlap;
+
+	/*
+	 * If no item in movablecore_map.map, or using SRAT info,
+	 * any removement is forbidden.
+	 */
+	if (!movablecore_map.nr_map || movablecore_map.acpi)
+		return;
+
+	/*
+	 * pos will be at the 1st overlapped range, or the end
+	 * of the array.
+	 */
+	for (pos = 0; pos < movablecore_map.nr_map; pos++)
+		if (start_pfn < movablecore_map.map[pos].end_pfn)
+			break;
+
+	/* If there is no overlapped range, just return. */
+	if (pos == movablecore_map.nr_map ||
+	    end_pfn < movablecore_map.map[pos].start_pfn)
+		return;
+
+	/* overlap will be at the last overlapped range */
+	for (overlap = pos + 1; overlap < movablecore_map.nr_map; overlap++)
+		if (end_pfn <= movablecore_map.map[overlap].start_pfn)
+			break;
+	overlap--;
+
+	/* pos will be at the 1st removed range */
+	if (start_pfn > movablecore_map.map[pos].start_pfn) {
+		movablecore_map.map[pos].end_pfn = start_pfn;
+		pos++;
+	}
+
+	/* overlap will be at the one next to the last removed range */
+	if (end_pfn < movablecore_map.map[overlap].end_pfn)
+		movablecore_map.map[overlap].start_pfn = end_pfn;
+	else
+		overlap++;
+
+	if (overlap != movablecore_map.nr_map)
+		memmove(&movablecore_map.map[pos],
+			&movablecore_map.map[overlap],
+			sizeof(struct movablecore_entry) *
+			(movablecore_map.nr_map - overlap));
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
+	int ret;
+
+	/* In case size == 0 or start + size overflows */
+	if (start + size <= start)
+		return;
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = PFN_UP(start + size);
+	ret = insert_movablecore_map(start_pfn, end_pfn);
+	if (ret)
+		pr_err("movablecore_map: too many entries;"
+			" ignoring [mem %#010llx-%#010llx]\n",
+			(unsigned long long) start,
+			(unsigned long long) (start + size - 1));
+}
+
+/*
+ * movablecore_map=nn[KMG]@ss[KMG] sets the region of memory to be used as
+ * movable memory.
+ * movablecore_map=acpi means using the SRAT info from BISO to specify which
+ * memory is movable.
+ */
+static int __init cmdline_parse_movablecore_map(char *p)
+{
+	char *oldp;
+	u64 start_at, mem_size;
+
+	if (!p)
+		goto err;
+
+	if (!strncmp(p, "acpi", 4))
+		movablecore_map.acpi = true;
+
+	/*
+	 * If user decide to use info from BIOS, all the other user specified
+	 * ranges will be ingored.
+	 */
+	if (movablecore_map.acpi) {
+		if (movablecore_map.nr_map) {
+			memset(movablecore_map.map, 0,
+				sizeof(struct movablecore_entry)
+				* movablecore_map.nr_map);
+			movablecore_map.nr_map = 0;
+		}
+		return 0;
+	}
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
