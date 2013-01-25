Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 641766B0009
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 04:43:02 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 2/3] acpi, memory-hotplug: Extend movablemem_map ranges to the end of node.
Date: Fri, 25 Jan 2013 17:42:08 +0800
Message-Id: <1359106929-3034-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

When implementing movablemem_map boot option, we introduced an array
movablemem_map.map[] to store the memory ranges to be set as ZONE_MOVABLE.

Since ZONE_MOVABLE is the latst zone of a node, if user didn't specify
the whole node memory range, we need to extend it to the node end so that
we can use it to prevent memblock from allocating memory in the ranges
user didn't specify.

We now implement movablemem_map boot option like this:
        /*
         * For movablemem_map=nn[KMG]@ss[KMG]:
         *
         * SRAT:                |_____| |_____| |_________| |_________| ......
         * node id:                0       1         1           2
         * user specified:                |__|                 |___|
         * movablemem_map:                |___| |_________|    |______| ......
         *
         * Using movablemem_map, we can prevent memblock from allocating memory
         * on ZONE_MOVABLE at boot time.
         *
         * NOTE: In this case, SRAT info will be ingored.
         */

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/srat.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/mm.h |    5 ++++
 mm/page_alloc.c    |   34 +++++++++++++++++++++++++++-
 3 files changed, 95 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 4ddf497..f841d0e 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -141,11 +141,16 @@ static inline int save_add_info(void) {return 1;}
 static inline int save_add_info(void) {return 0;}
 #endif
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+extern struct movablemem_map movablemem_map;
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
 /* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
 int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 {
 	u64 start, end;
+	u32 hotpluggable;
 	int node, pxm;
 
 	if (srat_disabled())
@@ -157,8 +162,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) == 0)
 		return -1;
 
-	if ((ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE) && !save_add_info())
+	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
+	if (hotpluggable && !save_add_info())
 		return -1;
+
 	start = ma->base_address;
 	end = start + ma->length;
 	pxm = ma->proximity_domain;
@@ -178,9 +185,57 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 
 	node_set(node, numa_nodes_parsed);
 
-	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]\n",
+	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
 	       node, pxm,
-	       (unsigned long long) start, (unsigned long long) end - 1);
+	       (unsigned long long) start, (unsigned long long) end - 1,
+	       hotpluggable ? "Hot Pluggable": "");
+
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+	int overlap;
+	unsigned long start_pfn, end_pfn;
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = PFN_UP(end);
+
+	/*
+	 * For movablecore_map=nn[KMG]@ss[KMG]:
+	 *
+	 * SRAT:		|_____| |_____| |_________| |_________| ......
+	 * node id:		   0       1         1           2
+	 * user specified:	          |__|                 |___|
+	 * movablemem_map:		  |___| |_________|    |______| ......
+	 *
+	 * Using movablemem_map, we can prevent memblock from allocating memory
+	 * on ZONE_MOVABLE at boot time.
+	 */
+	overlap = movablemem_map_overlap(start_pfn, end_pfn);
+	if (overlap >= 0) {
+		/*
+		 * If part of this range is in movablemem_map, we need to
+		 * add the range after it to extend the range to the end
+		 * of the node, because from the min address specified to
+		 * the end of the node will be ZONE_MOVABLE.
+		 */
+		start_pfn = max(start_pfn,
+			    movablemem_map.map[overlap].start_pfn);
+		insert_movablemem_map(start_pfn, end_pfn);
+
+		/*
+		 * Set the nodemask, so that if the address range on one node
+		 * is not continuse, we can add the subsequent ranges on the
+		 * same node into movablemem_map.
+		 */
+		node_set(node, movablemem_map.numa_nodes_hotplug);
+	} else {
+		if (node_isset(node, movablemem_map.numa_nodes_hotplug))
+			/*
+			 * Insert the range if we already have movable ranges
+			 * on the same node.
+			 */
+			insert_movablemem_map(start_pfn, end_pfn);
+	}
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
 	return 0;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cef651..e88077a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1368,8 +1368,13 @@ struct movablemem_entry {
 struct movablemem_map {
 	int nr_map;
 	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
+	nodemask_t numa_nodes_hotplug;	/* on which nodes we specify memory */
 };
 
+extern void __init insert_movablemem_map(unsigned long start_pfn,
+					 unsigned long end_pfn);
+extern int __init movablemem_map_overlap(unsigned long start_pfn,
+					 unsigned long end_pfn);
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3978797..bdbce73 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5168,6 +5168,36 @@ early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
 /**
+ * movablemem_map_overlap() - Check if a range overlaps movablemem_map.map[].
+ * @start_pfn:	start pfn of the range to be checked
+ * @end_pfn: 	end pfn of the range to be checked (exclusive)
+ *
+ * This function checks if a given memory range [start_pfn, end_pfn) overlaps
+ * the movablemem_map.map[] array.
+ *
+ * Return: index of the first overlapped element in movablemem_map.map[]
+ *         or -1 if they don't overlap each other.
+ */
+int __init movablemem_map_overlap(unsigned long start_pfn,
+				   unsigned long end_pfn)
+{
+	int overlap;
+
+	if (!movablemem_map.nr_map)
+		return -1;
+
+	for (overlap = 0; overlap < movablemem_map.nr_map; overlap++)
+		if (start_pfn < movablemem_map.map[overlap].end_pfn)
+			break;
+
+	if (overlap == movablemem_map.nr_map ||
+	    end_pfn <= movablemem_map.map[overlap].start_pfn)
+		return -1;
+
+	return overlap;
+}
+
+/**
  * insert_movablemem_map() - Insert a memory range in to movablemem_map.map.
  * @start_pfn:	start pfn of the range
  * @end_pfn:	end pfn of the range
@@ -5175,8 +5205,8 @@ early_param("movablecore", cmdline_parse_movablecore);
  * This function will also merge the overlapped ranges, and sort the array
  * by start_pfn in monotonic increasing order.
  */
-static void __init insert_movablemem_map(unsigned long start_pfn,
-					  unsigned long end_pfn)
+void __init insert_movablemem_map(unsigned long start_pfn,
+				  unsigned long end_pfn)
 {
 	int pos, overlap;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
