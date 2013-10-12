Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E6A9A6B005C
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:42 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so5855034pdi.27
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:42 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 15/23] mm/sparse: Use memblock apis for early memory allocations
Date: Sat, 12 Oct 2013 17:58:58 -0400
Message-ID: <1381615146-20342-16-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/sparse-vmemmap.c |    5 +++--
 mm/sparse.c         |   24 +++++++++++++-----------
 2 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 27eeab3..c1fb952 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -40,7 +40,7 @@ static void * __init_refok __earlyonly_bootmem_alloc(int node,
 				unsigned long align,
 				unsigned long goal)
 {
-	return __alloc_bootmem_node_high(NODE_DATA(node), size, align, goal);
+	return memblock_early_alloc_try_nid(node, size, align, goal, BOOTMEM_ALLOC_ACCESSIBLE);
 }
 
 static void *vmemmap_buf;
@@ -226,7 +226,8 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 
 	if (vmemmap_buf_start) {
 		/* need to free left buf */
-		free_bootmem(__pa(vmemmap_buf), vmemmap_buf_end - vmemmap_buf);
+		memblock_free_early(__pa(vmemmap_buf),
+				    vmemmap_buf_end - vmemmap_buf);
 		vmemmap_buf = NULL;
 		vmemmap_buf_end = NULL;
 	}
diff --git a/mm/sparse.c b/mm/sparse.c
index 4ac1d7e..1e06a60 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -69,7 +69,7 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 		else
 			section = kzalloc(array_size, GFP_KERNEL);
 	} else {
-		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
+		section = memblock_early_alloc_node(nid, array_size);
 	}
 
 	return section;
@@ -279,7 +279,7 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	limit = goal + (1UL << PA_SECTION_SHIFT);
 	nid = early_pfn_to_nid(goal >> PAGE_SHIFT);
 again:
-	p = ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size,
+	p = memblock_early_alloc_try_nid_nopanic(NODE_DATA(nid), size,
 					  SMP_CACHE_BYTES, goal, limit);
 	if (!p && limit) {
 		limit = 0;
@@ -331,7 +331,7 @@ static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 					 unsigned long size)
 {
-	return alloc_bootmem_node_nopanic(pgdat, size);
+	return memblock_early_alloc_node_nopanic(pgdat->node_id, size);
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
@@ -376,8 +376,9 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid)
 		return map;
 
 	size = PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
-	map = __alloc_bootmem_node_high(NODE_DATA(nid), size,
-					 PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	map = memblock_early_alloc_try_nid(nid, size,
+					   PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
+					   BOOTMEM_ALLOC_ACCESSIBLE);
 	return map;
 }
 void __init sparse_mem_maps_populate_node(struct page **map_map,
@@ -401,8 +402,9 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 	}
 
 	size = PAGE_ALIGN(size);
-	map = __alloc_bootmem_node_high(NODE_DATA(nodeid), size * map_count,
-					 PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	map = memblock_early_alloc_try_nid(nodeid, size * map_count,
+					   PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
+					   BOOTMEM_ALLOC_ACCESSIBLE);
 	if (map) {
 		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 			if (!present_section_nr(pnum))
@@ -545,7 +547,7 @@ void __init sparse_init(void)
 	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
 	 */
 	size = sizeof(unsigned long *) * NR_MEM_SECTIONS;
-	usemap_map = alloc_bootmem(size);
+	usemap_map = memblock_early_alloc(size);
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
 	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
@@ -553,7 +555,7 @@ void __init sparse_init(void)
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
-	map_map = alloc_bootmem(size2);
+	map_map = memblock_early_alloc(size2);
 	if (!map_map)
 		panic("can not allocate map_map\n");
 	alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
@@ -583,9 +585,9 @@ void __init sparse_init(void)
 	vmemmap_populate_print_last();
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-	free_bootmem(__pa(map_map), size2);
+	memblock_free_early(__pa(map_map), size2);
 #endif
-	free_bootmem(__pa(usemap_map), size);
+	memblock_free_early(__pa(usemap_map), size);
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
