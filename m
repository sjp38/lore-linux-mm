Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E2A866B0069
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:37:24 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 06/11] X86, numa, acpi, memory-hotplug: Add hotpluggable ranges to movablemem_map.
Date: Fri, 5 Apr 2013 17:39:56 +0800
Message-Id: <1365154801-473-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, jiang.liu@huawei.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When parsing SRAT, we are able to know which memory ranges are hotpluggable,
and we add them to movablemem_map. So movablemem_map could be used to prevent
memblock from allocating memory in area which will be set as ZONE_MOVABLE later.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   39 ++++++++++++++++++++++
 include/linux/mm.h |    4 ++
 mm/page_alloc.c    |   92 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 135 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 26d1800..73e7934 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -725,6 +725,43 @@ static void __init early_x86_numa_init_mapping(void)
 }
 #endif
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+/**
+ * early_mem_hotplug_init - Add hotpluggable memory ranges to movablemem_map.
+ *
+ * This function scan numa_meminfo.blk[], and add all the hotpluggable memory 
+ * ranges to movablemem_map. movablemem_map can be used to prevent memblock
+ * from allocating memory in area which will be set as ZONE_MOVABLE later, so
+ * this function should be called after memory mapping is initialized because
+ * we will put pagetable pages in local node even if the memory of that node is
+ * hotpluggable.
+ *
+ * If users specify movablemem_map=acpi, then:
+ *
+ * SRAT:                |_____| |_____| |_________| |_________| ......
+ * node id:                0       1         1           2
+ * hotpluggable:           n       y         y           n
+ * movablemem_map:              |_____| |_________|
+ */
+static void __init early_mem_hotplug_init()
+{
+	int i;
+
+	if (!movablemem_map.acpi)
+		return;
+
+	for (i = 0; i < numa_meminfo.nr_blks; i++) {
+		if (numa_meminfo.blk[i].hotpluggable)
+			movablemem_map_add_region(numa_meminfo.blk[i].start,
+						  numa_meminfo.blk[i].end);
+	}
+}
+#else          /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+static inline void early_mem_hotplug_init()
+{
+}
+#endif         /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
 void __init early_initmem_init(void)
 {
 	early_x86_numa_init();
@@ -734,6 +771,8 @@ void __init early_initmem_init(void)
 	load_cr3(swapper_pg_dir);
 	__flush_tlb_all();
 
+	early_mem_hotplug_init();
+
 	early_memtest(0, max_pfn_mapped<<PAGE_SHIFT);
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 52c3558..7468221 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1344,6 +1344,10 @@ struct movablemem_map {
 	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
 };
 
+extern struct movablemem_map movablemem_map;
+
+extern void __init movablemem_map_add_region(u64 start, u64 size);
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 475fd8b..2a7904f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5068,6 +5068,98 @@ early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
 /**
+ * insert_movablemem_map - Insert a memory range in to movablemem_map.map.
+ * @start_pfn: start pfn of the range
+ * @end_pfn:   end pfn of the range
+ *
+ * This function will also merge the overlapped ranges, and sort the array
+ * by start_pfn in monotonic increasing order.
+ */
+static void __init insert_movablemem_map(unsigned long start_pfn,
+					 unsigned long end_pfn)
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
+ * @start:     physical start address of range
+ * @end:       physical end address of range
+ *
+ * This function transform the physical address into pfn, and then add the
+ * range into movablemem_map by calling insert_movablemem_map().
+ */
+void __init movablemem_map_add_region(u64 start, u64 size)
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
+/**
  * cmdline_parse_movablemem_map - Parse boot option movablemem_map.
  * @p:	The boot option of the following format:
  *	movablemem_map=acpi
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
