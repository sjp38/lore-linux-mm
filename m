Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2C128D003B
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:04 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCW0Ab009964
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVr8p3612812
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVqCu003621
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:52 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 04/10] mm: Refer to zones from memory regions
Date: Fri, 27 May 2011 18:01:32 +0530
Message-Id: <1306499498-14263-5-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

With the introduction of memory regions, the node_zone link inside
the node structure is removed. Hence, this patch modifies the VM
code to refer to zones from within memory regions instead of nodes.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 include/linux/mm.h     |    2 +-
 include/linux/mmzone.h |    8 ++--
 mm/page_alloc.c        |   87 +++++++++++++++++++++++++++--------------------
 3 files changed, 55 insertions(+), 42 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e4e7869..1b8839d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1390,7 +1390,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn);
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
-extern void memmap_init_zone(unsigned long, int, unsigned long,
+extern void memmap_init_zone(unsigned long, int, int, unsigned long,
 				unsigned long, enum memmap_context);
 extern void setup_per_zone_wmarks(void);
 extern void calculate_zone_inactive_ratio(struct zone *zone);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3f13dc8..bc3e3fd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -753,7 +753,7 @@ static inline int is_normal_idx(enum zone_type idx)
 static inline int is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
+	int zone_off = (char *)zone - (char *)zone->zone_mem_region->zones;
 	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
 	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
 		zone_movable_is_highmem());
@@ -764,13 +764,13 @@ static inline int is_highmem(struct zone *zone)
 
 static inline int is_normal(struct zone *zone)
 {
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
+	return zone == zone->zone_mem_region->zones + ZONE_NORMAL;
 }
 
 static inline int is_dma32(struct zone *zone)
 {
 #ifdef CONFIG_ZONE_DMA32
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
+	return zone == zone->zone_mem_region->zones + ZONE_DMA32;
 #else
 	return 0;
 #endif
@@ -779,7 +779,7 @@ static inline int is_dma32(struct zone *zone)
 static inline int is_dma(struct zone *zone)
 {
 #ifdef CONFIG_ZONE_DMA
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
+	return zone == zone->zone_mem_region->zones + ZONE_DMA;
 #else
 	return 0;
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a21e067..3c48635 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -892,7 +892,7 @@ static int move_freepages_block(struct zone *zone, struct page *page,
 	end_pfn = start_pfn + pageblock_nr_pages - 1;
 
 	/* Do not cross zone boundaries */
-	if (start_pfn < zone->zone_start_pfn)
+	if (start_pfn <= zone->zone_start_pfn)
 		start_page = page;
 	if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
 		return 0;
@@ -2462,7 +2462,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 #ifdef CONFIG_HIGHMEM
 	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
 	val->freehigh = zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
-			NR_FREE_PAGES);
+							NR_FREE_PAGES);
 #else
 	val->totalhigh = 0;
 	val->freehigh = 0;
@@ -3396,8 +3396,8 @@ static void setup_zone_migrate_reserve(struct zone *zone)
  * up by free_all_bootmem() once the early boot process is
  * done. Non-atomic initialization, single-pass.
  */
-void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
-		unsigned long start_pfn, enum memmap_context context)
+void __meminit memmap_init_zone(unsigned long size, int nid, int region,
+		unsigned long zone, unsigned long start_pfn, enum memmap_context context)
 {
 	struct page *page;
 	unsigned long end_pfn = start_pfn + size;
@@ -3407,7 +3407,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
-	z = &NODE_DATA(nid)->node_zones[zone];
+	z = &NODE_DATA(nid)->mem_regions[region].zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
 		 * There can be holes in boot-time mem_map[]s
@@ -3464,8 +3464,8 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 }
 
 #ifndef __HAVE_ARCH_MEMMAP_INIT
-#define memmap_init(size, nid, zone, start_pfn) \
-	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
+#define memmap_init(size, nid, region, zone, start_pfn) \
+	memmap_init_zone((size), (nid), (region), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
 static int zone_batchsize(struct zone *zone)
@@ -3584,7 +3584,7 @@ static noinline __init_refok
 int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 {
 	int i;
-	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct pglist_data *pgdat = NODE_DATA(zone->node);
 	size_t alloc_size;
 
 	/*
@@ -3670,20 +3670,22 @@ __meminit int init_currently_empty_zone(struct zone *zone,
 					enum memmap_context context)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct mem_region_list_data *mem_region = zone->zone_mem_region;
 	int ret;
 	ret = zone_wait_table_init(zone, size);
 	if (ret)
 		return ret;
 	pgdat->nr_zones = zone_idx(zone) + 1;
+	mem_region->nr_zones = zone_idx(zone) + 1;
 
 	zone->zone_start_pfn = zone_start_pfn;
-
+/*
 	mminit_dprintk(MMINIT_TRACE, "memmap_init",
 			"Initialising map node %d zone %lu pfns %lu -> %lu\n",
 			pgdat->node_id,
 			(unsigned long)zone_idx(zone),
 			zone_start_pfn, (zone_start_pfn + size));
-
+*/
 	zone_init_free_lists(zone);
 
 	return 0;
@@ -4365,7 +4367,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 			ret = init_currently_empty_zone(zone, zone_start_pfn,
 							size, MEMMAP_EARLY);
 			BUG_ON(ret);
-			memmap_init(size, nid, j, zone_start_pfn);
+			memmap_init(size, nid, i, j, zone_start_pfn);
 			zone_start_pfn += size;
 		}
 	}
@@ -4412,6 +4414,9 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 }
 
+/* TO DO: This routine needs modification, but not required for panda board
+ * to start with
+ */
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
@@ -5014,24 +5019,28 @@ static void calculate_totalreserve_pages(void)
 	struct pglist_data *pgdat;
 	unsigned long reserve_pages = 0;
 	enum zone_type i, j;
+	int p;
 
 	for_each_online_pgdat(pgdat) {
 		for (i = 0; i < MAX_NR_ZONES; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-			unsigned long max = 0;
-
-			/* Find valid and maximum lowmem_reserve in the zone */
-			for (j = i; j < MAX_NR_ZONES; j++) {
-				if (zone->lowmem_reserve[j] > max)
-					max = zone->lowmem_reserve[j];
-			}
+			for_each_mem_region_in_nid(p, pgdat->node_id) {
+				mem_region_t *mem_region = &pgdat->mem_regions[p];
+				struct zone *zone = mem_region->zones + i;
+				unsigned long max = 0;
+
+				/* Find valid and maximum lowmem_reserve in the zone */
+				for (j = i; j < MAX_NR_ZONES; j++) {
+					if (zone->lowmem_reserve[j] > max)
+						max = zone->lowmem_reserve[j];
+				}
 
-			/* we treat the high watermark as reserved pages. */
-			max += high_wmark_pages(zone);
+				/* we treat the high watermark as reserved pages. */
+				max += high_wmark_pages(zone);
 
-			if (max > zone->present_pages)
-				max = zone->present_pages;
-			reserve_pages += max;
+				if (max > zone->present_pages)
+					max = zone->present_pages;
+				reserve_pages += max;
+			}
 		}
 	}
 	totalreserve_pages = reserve_pages;
@@ -5047,27 +5056,31 @@ static void setup_per_zone_lowmem_reserve(void)
 {
 	struct pglist_data *pgdat;
 	enum zone_type j, idx;
+	int p;
 
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
-			struct zone *zone = pgdat->node_zones + j;
-			unsigned long present_pages = zone->present_pages;
+			for_each_mem_region_in_nid(p, pgdat->node_id) {
+				mem_region_t *mem_region = &pgdat->mem_regions[p];
+				struct zone *zone = mem_region->zones + j;
+				unsigned long present_pages = zone->present_pages;
 
-			zone->lowmem_reserve[j] = 0;
+				zone->lowmem_reserve[j] = 0;
 
-			idx = j;
-			while (idx) {
-				struct zone *lower_zone;
+				idx = j;
+				while (idx) {
+					struct zone *lower_zone;
 
-				idx--;
+					idx--;
 
-				if (sysctl_lowmem_reserve_ratio[idx] < 1)
-					sysctl_lowmem_reserve_ratio[idx] = 1;
+					if (sysctl_lowmem_reserve_ratio[idx] < 1)
+						sysctl_lowmem_reserve_ratio[idx] = 1;
 
-				lower_zone = pgdat->node_zones + idx;
-				lower_zone->lowmem_reserve[j] = present_pages /
-					sysctl_lowmem_reserve_ratio[idx];
-				present_pages += lower_zone->present_pages;
+					lower_zone = mem_region->zones + idx;
+					lower_zone->lowmem_reserve[j] = present_pages /
+						sysctl_lowmem_reserve_ratio[idx];
+					present_pages += lower_zone->present_pages;
+				}
 			}
 		}
 	}
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
