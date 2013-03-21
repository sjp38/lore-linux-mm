Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 566DA6B0036
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:18:27 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RESEND PATCH part1 3/9] x86, mm, numa, acpi: Add movable_memmap boot option.
Date: Thu, 21 Mar 2013 17:20:49 +0800
Message-Id: <1363857655-30658-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1363857655-30658-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1363857655-30658-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add functions to parse movablemem_map boot option. Since the option
could be specified more then once, all the maps will be stored in the
global array movablemem_map.map[].

And also, we keep the array in monotonic increasing order by start_pfn.
And merge all overlapped ranges.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   21 ++++++
 include/linux/mm.h                  |   11 +++
 mm/page_alloc.c                     |  131 +++++++++++++++++++++++++++++++++++
 3 files changed, 163 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 4609e81..dd3a36a 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1649,6 +1649,27 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
+	movablemem_map=nn[KMG]@ss[KMG]
+			[KNL,X86,IA-64,PPC] This parameter is similar to
+			memmap except it specifies the memory map of
+			ZONE_MOVABLE.
+			If user specifies memory ranges, the info in SRAT will
+			be ingored. And it works like the following:
+			- If more ranges are all within one node, then from
+			  lowest ss to the end of the node will be ZONE_MOVABLE.
+			- If a range is within a node, then from ss to the end
+			  of the node will be ZONE_MOVABLE.
+			- If a range covers two or more nodes, then from ss to
+			  the end of the 1st node will be ZONE_MOVABLE, and all
+			  the rest nodes will only have ZONE_MOVABLE.
+			If memmap is specified at the same time, the
+			movablemem_map will be limited within the memmap
+			areas. If kernelcore or movablecore is also specified,
+			movablemem_map will have higher priority to be
+			satisfied. So the administrator should be careful that
+			the amount of movablemem_map areas are not too large.
+			Otherwise kernel won't have enough memory to start.
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1c79b10..9c068d5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1332,6 +1332,17 @@ extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
 
+#define MOVABLEMEM_MAP_MAX MAX_NUMNODES
+struct movablemem_entry {
+	unsigned long start_pfn;    /* start pfn of memory segment */
+	unsigned long end_pfn;      /* end pfn of memory segment (exclusive) */
+};
+
+struct movablemem_map {
+	int nr_map;
+	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
+};
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f368db4..27fcd29 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -202,6 +202,9 @@ static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+/* Movable memory ranges, will also be used by memblock subsystem. */
+struct movablemem_map movablemem_map;
+
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __initdata required_kernelcore;
@@ -5061,6 +5064,134 @@ static int __init cmdline_parse_movablecore(char *p)
 early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
+/**
+ * insert_movablemem_map - Insert a memory range in to movablemem_map.map.
+ * @start_pfn:	start pfn of the range
+ * @end_pfn:	end pfn of the range
+ *
+ * This function will also merge the overlapped ranges, and sort the array
+ * by start_pfn in monotonic increasing order.
+ */
+static void __init insert_movablemem_map(unsigned long start_pfn,
+					  unsigned long end_pfn)
+{
+	int pos, overlap;
+
+	/*
+	 * pos will be at the 1st overlapped range, or the position
+	 * where the element should be inserted.
+	 */
+	for (pos = 0; pos < movablemem_map.nr_map; pos++)
+		if (start_pfn <= movablemem_map.map[pos].end_pfn)
+			break;
+
+	/* If there is no overlapped range, just insert the element. */
+	if (pos == movablemem_map.nr_map ||
+	    end_pfn < movablemem_map.map[pos].start_pfn) {
+		/*
+		 * If pos is not the end of array, we need to move all
+		 * the rest elements backward.
+		 */
+		if (pos < movablemem_map.nr_map)
+			memmove(&movablemem_map.map[pos+1],
+				&movablemem_map.map[pos],
+				sizeof(struct movablemem_entry) *
+				(movablemem_map.nr_map - pos));
+		movablemem_map.map[pos].start_pfn = start_pfn;
+		movablemem_map.map[pos].end_pfn = end_pfn;
+		movablemem_map.nr_map++;
+		return;
+	}
+
+	/* overlap will be at the last overlapped range */
+	for (overlap = pos + 1; overlap < movablemem_map.nr_map; overlap++)
+		if (end_pfn < movablemem_map.map[overlap].start_pfn)
+			break;
+
+	/*
+	 * If there are more ranges overlapped, we need to merge them,
+	 * and move the rest elements forward.
+	 */
+	overlap--;
+	movablemem_map.map[pos].start_pfn = min(start_pfn,
+					movablemem_map.map[pos].start_pfn);
+	movablemem_map.map[pos].end_pfn = max(end_pfn,
+					movablemem_map.map[overlap].end_pfn);
+
+	if (pos != overlap && overlap + 1 != movablemem_map.nr_map)
+		memmove(&movablemem_map.map[pos+1],
+			&movablemem_map.map[overlap+1],
+			sizeof(struct movablemem_entry) *
+			(movablemem_map.nr_map - overlap - 1));
+
+	movablemem_map.nr_map -= overlap - pos;
+}
+
+/**
+ * movablemem_map_add_region - Add a memory range into movablemem_map.
+ * @start:	physical start address of range
+ * @end:	physical end address of range
+ *
+ * This function transform the physical address into pfn, and then add the
+ * range into movablemem_map by calling insert_movablemem_map().
+ */
+static void __init movablemem_map_add_region(u64 start, u64 size)
+{
+	unsigned long start_pfn, end_pfn;
+
+	/* In case size == 0 or start + size overflows */
+	if (start + size <= start)
+		return;
+
+	if (movablemem_map.nr_map >= ARRAY_SIZE(movablemem_map.map)) {
+		pr_err("movablemem_map: too many entries; "
+		       "ignoring [mem %#010llx-%#010llx]\n",
+		       (unsigned long long) start,
+		       (unsigned long long) (start + size - 1));
+		return;
+	}
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = PFN_UP(start + size);
+	insert_movablemem_map(start_pfn, end_pfn);
+}
+
+/*
+ * cmdline_parse_movablemem_map - Parse boot option movablemem_map.
+ * @p:	The boot option of the following format:
+ *	movablemem_map=nn[KMG]@ss[KMG]
+ *
+ * This option sets the memory range [ss, ss+nn) to be used as movable memory.
+ *
+ * Return: 0 on success or -EINVAL on failure.
+ */
+static int __init cmdline_parse_movablemem_map(char *p)
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
+		movablemem_map_add_region(start_at, mem_size);
+		return 0;
+	}
+err:
+	return -EINVAL;
+}
+early_param("movablemem_map", cmdline_parse_movablemem_map);
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
