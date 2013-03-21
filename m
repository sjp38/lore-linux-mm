Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 8DD396B0070
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:18:45 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part2 4/4] x86, mm, numa, acpi: Sanitize movablemem_map after memory mapping initialized.
Date: Thu, 21 Mar 2013 17:21:16 +0800
Message-Id: <1363857676-30694-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1363857676-30694-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1363857676-30694-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In order to support allocating pagetable and vmammap pages in local node,
we should initialzie memory mapping without any limitation for memblock first,
using memblock to reserve pagetable and vmemmap pages in local node, and then
sanitize movablemem_map.map[] to limit memblock.

In this way, we can prevent allocation in movable area but with pagetable
and vmemmap pages (used by kernel) in local node.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |  125 ++++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/mm/srat.c |  139 ++++++---------------------------------------------
 2 files changed, 142 insertions(+), 122 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 0c3a278..d0b9c5a 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -738,6 +738,129 @@ static void __init early_x86_numa_init_mapping(void)
 }
 #endif
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+static void __init movablemem_map_handle_srat(struct numa_memblk mb)
+{
+	unsigned long start_pfn = PFN_DOWN(mb.start);
+	unsigned long end_pfn = PFN_UP(mb.end);
+	int nid = mb.nid;
+	bool hotpluggable = mb.hotpluggable;
+
+	/*
+	 * For movablemem_map=acpi:
+	 *
+	 * SRAT:                |_____| |_____| |_________| |_________| ......
+	 * node id:                0       1         1           2
+	 * hotpluggable:           n       y         y           n
+	 * movablemem_map:              |_____| |_________|
+	 *
+	 * Using movablemem_map, we can prevent memblock from allocating memory
+	 * on ZONE_MOVABLE at boot time.
+	 *
+	 * Before parsing SRAT, memblock has already reserve some memory ranges
+	 * for other purposes, such as for kernel image. We cannot prevent
+	 * kernel from using these memory. Furthermore, if all the memory is
+	 * hotpluggable, then the system won't have enough memory to boot. So
+	 * we always set the nodes which the kernel resides in as non-movable
+	 * by not calling this function in sanitize_movablemem_map().
+	 *
+	 * Known problem: We now allocate pagetable and vmemmap pages on local
+	 * node, and reserved them in memblock. But we cannot tell these pages
+	 * from other reserved memory, such as kernel image. Fortunately, the
+	 * reserved memory will not be released into buddy system, so it won't
+	 * impact the ZONE_MOVABLE limitation.
+	 */
+	if (!hotpluggable)
+		return;
+
+	/* If the range is hotpluggable, insert it into movablemem_map. */
+	insert_movablemem_map(start_pfn, end_pfn);
+
+	if (zone_movable_limit[nid])
+		zone_movable_limit[nid] = min(zone_movable_limit[nid],
+					      start_pfn);
+	else
+		zone_movable_limit[nid] = start_pfn;
+}
+
+static void __init movablemem_map_handle_user(struct numa_memblk mb)
+{
+	int overlap;
+	unsigned long start_pfn = PFN_DOWN(mb.start);
+	unsigned long end_pfn = PFN_UP(mb.end);
+	int nid = mb.nid;
+
+	/*
+	 * For movablemem_map=nn[KMG]@ss[KMG]:
+	 *
+	 * SRAT:                |_____| |_____| |_________| |_________| ......
+	 * node id:                0       1         1           2
+	 * user specified:                |__|                 |___|
+	 * movablemem_map:                |___| |_________|    |______| ......
+	 *
+	 * Using movablemem_map, we can prevent memblock from allocating memory
+	 * on ZONE_MOVABLE at boot time.
+	 *
+	 * NOTE: In this case, SRAT info will be ingored. Even if the memory
+	 * range is not hotpluggable in SRAT, it will be inserted into
+	 * movablemem_map. This is useful if firmware is buggy.
+	 */
+	overlap = movablemem_map_overlap(start_pfn, end_pfn);
+	if (overlap >= 0) {
+		/*
+		 * If this range overlaps with movablemem_map, then update
+		 * zone_movable_limit[nid] if it has lower start pfn.
+		 */
+		start_pfn = max(start_pfn,
+				movablemem_map.map[overlap].start_pfn);
+
+		if (!zone_movable_limit[nid] ||
+		    zone_movable_limit[nid] > start_pfn)
+			zone_movable_limit[nid] = start_pfn;
+
+		/* Insert the higher part of the overlapped range. */
+		if (movablemem_map.map[overlap].end_pfn < end_pfn)
+			insert_movablemem_map(start_pfn, end_pfn);
+	} else {
+		/*
+		 * If this is a range higher than zone_movable_limit[nid],
+		 * insert it to movablemem_map because all ranges higher than
+		 * zone_movable_limit[nid] on this node will be ZONE_MOVABLE.
+		 */
+		if (zone_movable_limit[nid] &&
+		    start_pfn > zone_movable_limit[nid])
+			insert_movablemem_map(start_pfn, end_pfn);
+	}
+}
+
+static void __init sanitize_movablemem_map()
+{
+	int i;
+
+	if (movablemem_map.acpi) {
+		for (i = 0; i < numa_meminfo_all.nr_blks; i++) {
+			/*
+			 * In order to ensure the kernel has enough memory to
+			 * boot, we always set the node which the kernel
+			 * resides in as unhotpluggable.
+			 */
+			if (node_isset(numa_meminfo_all.blk[i].nid,
+					movablemem_map.numa_nodes_kernel))
+				continue;
+
+			movablemem_map_handle_srat(numa_meminfo_all.blk[i]);
+		}
+	} else {
+		for (i = 0; i < numa_meminfo_all.nr_blks; i++)
+			movablemem_map_handle_user(numa_meminfo_all.blk[i]);
+	}
+}
+#else		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+static inline void sanitize_movablemem_map()
+{
+}
+#endif		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
 void __init early_initmem_init(void)
 {
 	early_x86_numa_init();
@@ -747,6 +870,8 @@ void __init early_initmem_init(void)
 	load_cr3(swapper_pg_dir);
 	__flush_tlb_all();
 
+	sanitize_movablemem_map();
+
 	early_memtest(0, max_pfn_mapped<<PAGE_SHIFT);
 }
 
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 76c2eb4..2c1f9a6 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -141,132 +141,14 @@ static inline int save_add_info(void) {return 1;}
 static inline int save_add_info(void) {return 0;}
 #endif
 
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-static void __init sanitize_movablemem_map(int nid, u64 start, u64 end,
-					   bool hotpluggable)
-{
-	int overlap, i;
-	unsigned long start_pfn, end_pfn;
-
-	start_pfn = PFN_DOWN(start);
-	end_pfn = PFN_UP(end);
-
-	/*
-	 * For movablemem_map=acpi:
-	 *
-	 * SRAT:                |_____| |_____| |_________| |_________| ......
-	 * node id:                0       1         1           2
-	 * hotpluggable:           n       y         y           n
-	 * movablemem_map:              |_____| |_________|
-	 *
-	 * Using movablemem_map, we can prevent memblock from allocating memory
-	 * on ZONE_MOVABLE at boot time.
-	 *
-	 * Before parsing SRAT, memblock has already reserve some memory ranges
-	 * for other purposes, such as for kernel image. We cannot prevent
-	 * kernel from using these memory, so we need to exclude these memory
-	 * even if it is hotpluggable.
-	 * Furthermore, to ensure the kernel has enough memory to boot, we make
-	 * all the memory on the node which the kernel resides in should be
-	 * un-hotpluggable.
-	 */
-	if (hotpluggable && movablemem_map.acpi) {
-		/* Exclude ranges reserved by memblock. */
-		struct memblock_type *rgn = &memblock.reserved;
-
-		for (i = 0; i < rgn->cnt; i++) {
-			if (end <= rgn->regions[i].base ||
-			    start >= rgn->regions[i].base +
-			    rgn->regions[i].size)
-				continue;
-
-			/*
-			 * If the memory range overlaps the memory reserved by
-			 * memblock, then the kernel resides in this node.
-			 */
-			node_set(nid, movablemem_map.numa_nodes_kernel);
-			zone_movable_limit[nid] = 0;
-
-			return;
-		}
-
-		/*
-		 * If the kernel resides in this node, then the whole node
-		 * should not be hotpluggable.
-		 */
-		if (node_isset(nid, movablemem_map.numa_nodes_kernel)) {
-			zone_movable_limit[nid] = 0;
-			return;
-		}
-
-		/*
-		 * Otherwise, if the range is hotpluggable, and the kernel is
-		 * not on this node, insert it into movablemem_map.
-		 */
-		insert_movablemem_map(start_pfn, end_pfn);
-		if (zone_movable_limit[nid])
-			zone_movable_limit[nid] = min(zone_movable_limit[nid],
-						      start_pfn);
-		else
-			zone_movable_limit[nid] = start_pfn;
-
-		return;
-	}
-
-	/*
-	 * For movablemem_map=nn[KMG]@ss[KMG]:
-	 *
-	 * SRAT:                |_____| |_____| |_________| |_________| ......
-	 * node id:                0       1         1           2
-	 * user specified:                |__|                 |___|
-	 * movablemem_map:                |___| |_________|    |______| ......
-	 *
-	 * Using movablemem_map, we can prevent memblock from allocating memory
-	 * on ZONE_MOVABLE at boot time.
-	 *
-	 * NOTE: In this case, SRAT info will be ingored.
-	 */
-	overlap = movablemem_map_overlap(start_pfn, end_pfn);
-	if (overlap >= 0) {
-		/*
-		 * If this range overlaps with movablemem_map, then update
-		 * zone_movable_limit[nid] if it has lower start pfn.
-		 */
-		start_pfn = max(start_pfn,
-				movablemem_map.map[overlap].start_pfn);
-
-		if (!zone_movable_limit[nid] ||
-		    zone_movable_limit[nid] > start_pfn)
-			zone_movable_limit[nid] = start_pfn;
-
-		/* Insert the higher part of the overlapped range. */
-		if (movablemem_map.map[overlap].end_pfn < end_pfn)
-			insert_movablemem_map(start_pfn, end_pfn);
-	} else {
-		/*
-		 * If this is a range higher than zone_movable_limit[nid],
-		 * insert it to movablemem_map because all ranges higher than
-		 * zone_movable_limit[nid] on this node will be ZONE_MOVABLE.
-		 */
-		if (zone_movable_limit[nid] &&
-		    start_pfn > zone_movable_limit[nid])
-			insert_movablemem_map(start_pfn, end_pfn);
-	}
-}
-#else		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
-static inline void sanitize_movablemem_map(int nid, u64 start, u64 end,
-					   bool hotpluggable)
-{
-}
-#endif		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
-
 /* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
 int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 {
 	u64 start, end;
 	u32 hotpluggable;
-	int node, pxm;
+	int node, pxm, i;
+	struct memblock_type *rgn = &memblock.reserved;
 
 	if (srat_disabled())
 		goto out_err;
@@ -295,14 +177,27 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 
 	node_set(node, numa_nodes_parsed);
 
+	/*
+	 * The data whose life cycle is the same as the node, such as pagetable,
+	 * could be acllocated on local node by memblock. But now, none of them
+	 * has been initialized yet. So the kernel resides in the nodes on which
+	 * memblock has reserved memory.
+	 */
+	for (i = 0; i < rgn->cnt; i++) {
+		if (end <= rgn->regions[i].base ||
+		    start >= rgn->regions[i].base + rgn->regions[i].size)
+			continue;
+
+		node_set(node, movablemem_map.numa_nodes_kernel);
+	}
+
 	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
 	       node, pxm,
 	       (unsigned long long) start, (unsigned long long) end - 1,
 	       hotpluggable ? "Hot Pluggable" : "");
 
-	sanitize_movablemem_map(node, start, end, hotpluggable);
-
 	return 0;
+
 out_err_bad_srat:
 	bad_srat();
 out_err:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
