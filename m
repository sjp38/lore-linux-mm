Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id E5AF16B0068
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:41:56 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:11:50 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JfmWb41091138
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:11:48 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA71BS9s031426
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 12:11:29 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 04/10] mm: Refer to zones from memory regions
Date: Wed, 07 Nov 2012 01:10:45 +0530
Message-ID: <20121106194037.6560.69740.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
References: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Ankita Garg <gargankita@gmail.com>

With the introduction of memory regions, the node_zones link inside
the node structure is removed. Hence, this patch modifies the VM
code to refer to zones from within memory regions instead of nodes.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h     |    2 -
 include/linux/mmzone.h |    9 ++-
 mm/page_alloc.c        |  128 +++++++++++++++++++++++++++---------------------
 3 files changed, 79 insertions(+), 60 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f57eef0..27fc2d3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1345,7 +1345,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn);
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
-extern void memmap_init_zone(unsigned long, int, unsigned long,
+extern void memmap_init_zone(unsigned long, int, int, unsigned long,
 				unsigned long, enum memmap_context);
 extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6f5d533..4abc7d5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -842,7 +842,8 @@ static inline int is_normal_idx(enum zone_type idx)
 static inline int is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
+	int zone_off = (char *)zone -
+				(char *)zone->zone_mem_region->region_zones;
 	return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
 	       (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
 		zone_movable_is_highmem());
@@ -853,13 +854,13 @@ static inline int is_highmem(struct zone *zone)
 
 static inline int is_normal(struct zone *zone)
 {
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
+	return zone == zone->zone_mem_region->region_zones + ZONE_NORMAL;
 }
 
 static inline int is_dma32(struct zone *zone)
 {
 #ifdef CONFIG_ZONE_DMA32
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
+	return zone == zone->zone_mem_region->region_zones + ZONE_DMA32;
 #else
 	return 0;
 #endif
@@ -868,7 +869,7 @@ static inline int is_dma32(struct zone *zone)
 static inline int is_dma(struct zone *zone)
 {
 #ifdef CONFIG_ZONE_DMA
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
+	return zone == zone->zone_mem_region->region_zones + ZONE_DMA;
 #else
 	return 0;
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c807272..a8e86b5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3797,8 +3797,8 @@ static void setup_zone_migrate_reserve(struct zone *zone)
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
@@ -3808,7 +3808,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
-	z = &NODE_DATA(nid)->node_zones[zone];
+	z = &NODE_DATA(nid)->node_regions[region].region_zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
 		 * There can be holes in boot-time mem_map[]s
@@ -3865,8 +3865,8 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 }
 
 #ifndef __HAVE_ARCH_MEMMAP_INIT
-#define memmap_init(size, nid, zone, start_pfn) \
-	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
+#define memmap_init(size, nid, region, zone, start_pfn) \
+	memmap_init_zone((size), (nid), (region), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
 static int __meminit zone_batchsize(struct zone *zone)
@@ -4045,11 +4045,13 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 					enum memmap_context context)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct mem_region *region = zone->zone_mem_region;
 	int ret;
 	ret = zone_wait_table_init(zone, size);
 	if (ret)
 		return ret;
-	pgdat->nr_zones = zone_idx(zone) + 1;
+	pgdat->nr_node_zone_types = zone_idx(zone) + 1;
+	region->nr_region_zones = zone_idx(zone) + 1;
 
 	zone->zone_start_pfn = zone_start_pfn;
 
@@ -4058,7 +4060,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 			pgdat->node_id,
 			(unsigned long)zone_idx(zone),
 			zone_start_pfn, (zone_start_pfn + size));
-
 	zone_init_free_lists(zone);
 
 	return 0;
@@ -4566,7 +4567,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 			ret = init_currently_empty_zone(zone, zone_start_pfn,
 							size, MEMMAP_EARLY);
 			BUG_ON(ret);
-			memmap_init(size, nid, j, zone_start_pfn);
+			memmap_init(size, nid, region->region, j, zone_start_pfn);
 			zone_start_pfn += size;
 		}
 	}
@@ -4613,13 +4614,17 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 }
 
+/*
+ * Todo: This routine needs more modifications, but not required for the
+ * minimalistic config options, to start with
+ */
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 
 	/* pg_data_t should be reset to zero when it's allocated */
-	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
+	WARN_ON(pgdat->nr_node_zone_types || pgdat->classzone_idx);
 
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
@@ -5109,35 +5114,38 @@ static void calculate_totalreserve_pages(void)
 {
 	struct pglist_data *pgdat;
 	unsigned long reserve_pages = 0;
+	struct mem_region *region;
 	enum zone_type i, j;
 
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
+			for_each_mem_region_in_node(region, pgdat->node_id) {
+				struct zone *zone = region->region_zones + i;
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
-			/*
-			 * Lowmem reserves are not available to
-			 * GFP_HIGHUSER page cache allocations and
-			 * kswapd tries to balance zones to their high
-			 * watermark.  As a result, neither should be
-			 * regarded as dirtyable memory, to prevent a
-			 * situation where reclaim has to clean pages
-			 * in order to balance the zones.
-			 */
-			zone->dirty_balance_reserve = max;
+				if (max > zone->present_pages)
+					max = zone->present_pages;
+				reserve_pages += max;
+				/*
+				 * Lowmem reserves are not available to
+				 * GFP_HIGHUSER page cache allocations and
+				 * kswapd tries to balance zones to their high
+				 * watermark.  As a result, neither should be
+				 * regarded as dirtyable memory, to prevent a
+				 * situation where reclaim has to clean pages
+				 * in order to balance the zones.
+				 */
+				zone->dirty_balance_reserve = max;
+			}
 		}
 	}
 	dirty_balance_reserve = reserve_pages;
@@ -5154,27 +5162,30 @@ static void setup_per_zone_lowmem_reserve(void)
 {
 	struct pglist_data *pgdat;
 	enum zone_type j, idx;
+	struct mem_region *region;
 
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
-			struct zone *zone = pgdat->node_zones + j;
-			unsigned long present_pages = zone->present_pages;
+			for_each_mem_region_in_node(region, pgdat->node_id) {
+				struct zone *zone = region->region_zones + j;
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
+					lower_zone = region->region_zones + idx;
+					lower_zone->lowmem_reserve[j] = present_pages /
+						sysctl_lowmem_reserve_ratio[idx];
+					present_pages += lower_zone->present_pages;
+				}
 			}
 		}
 	}
@@ -6159,13 +6170,16 @@ void dump_page(struct page *page)
 /* reset zone->present_pages */
 void reset_zone_present_pages(void)
 {
+	struct mem_region *region;
 	struct zone *z;
 	int i, nid;
 
 	for_each_node_state(nid, N_HIGH_MEMORY) {
 		for (i = 0; i < MAX_NR_ZONES; i++) {
-			z = NODE_DATA(nid)->node_zones + i;
-			z->present_pages = 0;
+			for_each_mem_region_in_node(region, nid) {
+				z = region->region_zones + i;
+				z->present_pages = 0;
+			}
 		}
 	}
 }
@@ -6177,15 +6191,19 @@ void fixup_zone_present_pages(int nid, unsigned long start_pfn,
 	struct zone *z;
 	unsigned long zone_start_pfn, zone_end_pfn;
 	int i;
+	struct mem_region *region;
 
 	for (i = 0; i < MAX_NR_ZONES; i++) {
-		z = NODE_DATA(nid)->node_zones + i;
-		zone_start_pfn = z->zone_start_pfn;
-		zone_end_pfn = zone_start_pfn + z->spanned_pages;
-
-		/* if the two regions intersect */
-		if (!(zone_start_pfn >= end_pfn	|| zone_end_pfn <= start_pfn))
-			z->present_pages += min(end_pfn, zone_end_pfn) -
-					    max(start_pfn, zone_start_pfn);
+		for_each_mem_region_in_node(region, nid) {
+			z = region->region_zones + i;
+			zone_start_pfn = z->zone_start_pfn;
+			zone_end_pfn = zone_start_pfn + z->spanned_pages;
+
+			/* if the two regions intersect */
+			if (!(zone_start_pfn >= end_pfn	||
+						zone_end_pfn <= start_pfn))
+				z->present_pages += min(end_pfn, zone_end_pfn) -
+						    max(start_pfn, zone_start_pfn);
+		}
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
