Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DC5368292A
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:30 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bj1so9642454pad.5
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:30 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id 10si3951359pdl.121.2015.02.11.23.30.13
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:14 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 12/16] mm/cma: introduce new zone, ZONE_CMA
Date: Thu, 12 Feb 2015 16:32:16 +0900
Message-Id: <1423726340-4084-13-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, reserved pages for CMA are managed together with normal pages.
To distinguish them, we used migratetype, MIGRATE_CMA, and
do special handlings for this migratetype. But, it turns out that
there are too many problems with this approach and to fix all of them
needs many more hooks to page allocation and reclaim path so
some developers express their discomfort and problems on CMA aren't fixed
for a long time.

To terminate this situation and fix CMA problems, this patch implements
ZONE_CMA. Reserved pages for CMA will be managed in this new zone. This
approach will remove all exisiting hooks for MIGRATE_CMA and many
problems such as watermark check and reserved page utilization are
resolved itself.

This patch only add basic infrastructure of ZONE_CMA. In the following
patch, ZONE_CMA is actually populated and used.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/x86/include/asm/sparsemem.h  |    2 +-
 arch/x86/mm/highmem_32.c          |    3 +++
 include/linux/gfp.h               |   20 ++++++++----------
 include/linux/mempolicy.h         |    2 +-
 include/linux/mmzone.h            |   33 +++++++++++++++++++++++++++--
 include/linux/page-flags-layout.h |    2 ++
 include/linux/vm_event_item.h     |    8 +++++++-
 kernel/power/snapshot.c           |   15 ++++++++++++++
 mm/memory_hotplug.c               |    3 +++
 mm/mempolicy.c                    |    3 ++-
 mm/page_alloc.c                   |   41 +++++++++++++++++++++++++++++++++----
 mm/vmstat.c                       |   10 ++++++++-
 12 files changed, 119 insertions(+), 23 deletions(-)

diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index 4517d6b..ac169a8 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -25,7 +25,7 @@
 #  define MAX_PHYSMEM_BITS	32
 # endif
 #else /* CONFIG_X86_32 */
-# define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
+# define SECTION_SIZE_BITS	28
 # define MAX_PHYSADDR_BITS	44
 # define MAX_PHYSMEM_BITS	46
 #endif
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 4500142..182e2b6 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -133,6 +133,9 @@ void __init set_highmem_pages_init(void)
 		if (!is_highmem(zone))
 			continue;
 
+		if (is_zone_cma(zone))
+			continue;
+
 		zone_start_pfn = zone->zone_start_pfn;
 		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
 
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 41b30fd..619eb20 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -219,19 +219,15 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
  * ZONES_SHIFT must be <= 2 on 32 bit platforms.
  */
 
-#if 16 * ZONES_SHIFT > BITS_PER_LONG
-#error ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
-#endif
-
 #define GFP_ZONE_TABLE ( \
-	(ZONE_NORMAL << 0 * ZONES_SHIFT)				      \
-	| (OPT_ZONE_DMA << ___GFP_DMA * ZONES_SHIFT)			      \
-	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * ZONES_SHIFT)		      \
-	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * ZONES_SHIFT)		      \
-	| (ZONE_NORMAL << ___GFP_MOVABLE * ZONES_SHIFT)			      \
-	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * ZONES_SHIFT)	      \
-	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * ZONES_SHIFT)   \
-	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * ZONES_SHIFT)   \
+	((u64)ZONE_NORMAL << 0 * ZONES_SHIFT)				      \
+	| ((u64)OPT_ZONE_DMA << ___GFP_DMA * ZONES_SHIFT)		      \
+	| ((u64)OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * ZONES_SHIFT)	      \
+	| ((u64)OPT_ZONE_DMA32 << ___GFP_DMA32 * ZONES_SHIFT)		      \
+	| ((u64)ZONE_NORMAL << ___GFP_MOVABLE * ZONES_SHIFT)		      \
+	| ((u64)OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * ZONES_SHIFT)  \
+	| ((u64)ZONE_MOVABLE << (___GFP_MOVABLE|___GFP_HIGHMEM) * ZONES_SHIFT)\
+	| ((u64)OPT_ZONE_DMA32 << (___GFP_MOVABLE|___GFP_DMA32) * ZONES_SHIFT)\
 )
 
 /*
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 3d385c8..ed01227 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -157,7 +157,7 @@ extern enum zone_type policy_zone;
 
 static inline void check_highest_zone(enum zone_type k)
 {
-	if (k > policy_zone && k != ZONE_MOVABLE)
+	if (k > policy_zone && k != ZONE_MOVABLE && !is_zone_cma_idx(k))
 		policy_zone = k;
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 90237f2..991e20e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -319,6 +319,9 @@ enum zone_type {
 	ZONE_HIGHMEM,
 #endif
 	ZONE_MOVABLE,
+#ifdef CONFIG_CMA
+	ZONE_CMA,
+#endif
 	__MAX_NR_ZONES
 };
 
@@ -854,8 +857,33 @@ static inline int zone_movable_is_highmem(void)
 #endif
 }
 
+static inline int is_zone_cma_idx(enum zone_type idx)
+{
+#ifdef CONFIG_CMA
+	return idx == ZONE_CMA;
+#else
+	return 0;
+#endif
+}
+
+static inline int is_zone_cma(struct zone *zone)
+{
+	int zone_idx = zone_idx(zone);
+
+	return is_zone_cma_idx(zone_idx);
+}
+
+static inline int zone_cma_is_highmem(void)
+{
+#ifdef CONFIG_HIGHMEM
+	return 1;
+#else
+	return 0;
+#endif
+}
+
 /**
- * is_highmem - helper function to quickly check if a struct zone is a 
+ * is_highmem - helper function to quickly check if a struct zone is a
  *              highmem zone or not.  This is an attempt to keep references
  *              to ZONE_{DMA/NORMAL/HIGHMEM/etc} in general code to a minimum.
  * @zone - pointer to struct zone variable
@@ -866,7 +894,8 @@ static inline int is_highmem(struct zone *zone)
 	int idx = zone_idx(zone);
 
 	return (idx == ZONE_HIGHMEM ||
-		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
+		(idx == ZONE_MOVABLE && zone_movable_is_highmem()) ||
+		(is_zone_cma_idx(idx) && zone_cma_is_highmem()));
 #else
 	return 0;
 #endif
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index da52366..77b078c 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -17,6 +17,8 @@
 #define ZONES_SHIFT 1
 #elif MAX_NR_ZONES <= 4
 #define ZONES_SHIFT 2
+#elif MAX_NR_ZONES <= 8
+#define ZONES_SHIFT 3
 #else
 #error ZONES_SHIFT -- too many zones configured adjust calculation
 #endif
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 730334c..9e4e07a 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -19,7 +19,13 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
+#ifdef CONFIG_CMA
+#define CMA_ZONE(xx) , xx##_CMA
+#else
+#define CMA_ZONE(xx)
+#endif
+
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE CMA_ZONE(xx)
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 791a618..0e875e8 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -520,6 +520,13 @@ static int create_mem_extents(struct list_head *list, gfp_t gfp_mask)
 		unsigned long zone_start, zone_end;
 		struct mem_extent *ext, *cur, *aux;
 
+		/*
+		 * ZONE_CMA is a virtual zone and it's spanned is subset of
+		 * other zone, so we don't need to make another mem_extents.
+		*/
+		if (is_zone_cma(zone))
+			continue;
+
 		zone_start = zone->zone_start_pfn;
 		zone_end = zone_end_pfn(zone);
 
@@ -1060,6 +1067,14 @@ unsigned int snapshot_additional_pages(struct zone *zone)
 {
 	unsigned int rtree, nodes;
 
+	/*
+	 * Estimation of needed pages for ZONE_CMA is already reflected
+	 * when calculating other zones since ZONE_CMA is a virtual zone and
+	 * it's span is subset of other zone.
+	 */
+	if (is_zone_cma(zone))
+		return 0;
+
 	rtree = nodes = DIV_ROUND_UP(zone->spanned_pages, BM_BITS_PER_BLOCK);
 	rtree += DIV_ROUND_UP(rtree * sizeof(struct rtree_node),
 			      LINKED_PAGE_DATA_SIZE);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1bf4807..569ce48 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1694,6 +1694,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (zone_idx(zone) <= ZONE_NORMAL && !can_offline_normal(zone, nr_pages))
 		goto out;
 
+	if (is_zone_cma(zone))
+		goto out;
+
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn,
 				       MIGRATE_MOVABLE, true);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e58725a..be21b5b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1666,7 +1666,8 @@ static int apply_policy_zone(struct mempolicy *policy, enum zone_type zone)
 {
 	enum zone_type dynamic_policy_zone = policy_zone;
 
-	BUG_ON(dynamic_policy_zone == ZONE_MOVABLE);
+	BUG_ON(dynamic_policy_zone == ZONE_MOVABLE ||
+		is_zone_cma_idx(dynamic_policy_zone));
 
 	/*
 	 * if policy->v.nodes has movable memory only,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6030525f..443f854 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -186,6 +186,9 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
 	 32,
 #endif
 	 32,
+#ifdef CONFIG_CMA
+	 32,
+#endif
 };
 
 EXPORT_SYMBOL(totalram_pages);
@@ -202,6 +205,9 @@ static char * const zone_names[MAX_NR_ZONES] = {
 	 "HighMem",
 #endif
 	 "Movable",
+#ifdef CONFIG_CMA
+	 "CMA",
+#endif
 };
 
 int min_free_kbytes = 1024;
@@ -4106,6 +4112,15 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	unsigned long pfn;
 	struct zone *z;
 
+	/*
+	 * ZONE_CMA is virtual zone and it's pages are belong to other zone
+	 * now. Intialization of them will be done together with initialization
+	 * of pages on the other zones. Later, we will move these pages
+	 * to ZONE_CMA and reset zone attribute.
+	 */
+	if (is_zone_cma_idx(zone))
+		return;
+
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;
 
@@ -4541,7 +4556,7 @@ static void __init find_usable_zone_for_movable(void)
 {
 	int zone_index;
 	for (zone_index = MAX_NR_ZONES - 1; zone_index >= 0; zone_index--) {
-		if (zone_index == ZONE_MOVABLE)
+		if (zone_index == ZONE_MOVABLE || is_zone_cma_idx(zone_index))
 			continue;
 
 		if (arch_zone_highest_possible_pfn[zone_index] >
@@ -4833,8 +4848,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
-	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
+	unsigned long zone_start_pfn = pgdat->node_start_pfn;
+	unsigned long first_zone_start_pfn = zone_start_pfn;
+	unsigned long last_zone_end_pfn = zone_start_pfn;
 
 	pgdat_resize_init(pgdat);
 #ifdef CONFIG_NUMA_BALANCING
@@ -4858,6 +4875,16 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 		lruvec_init(&zone->lruvec);
 
+		if (is_zone_cma_idx(j)) {
+			BUG_ON(j != MAX_NR_ZONES - 1);
+
+			zone_start_pfn = first_zone_start_pfn;
+			size = last_zone_end_pfn - first_zone_start_pfn;
+			realsize = freesize = 0;
+			memmap_pages = 0;
+			goto init_zone;
+		}
+
 		size = zone_spanned_pages_in_node(nid, j, node_start_pfn,
 						  node_end_pfn, zones_size);
 		realsize = freesize = size - zone_absent_pages_in_node(nid, j,
@@ -4896,6 +4923,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 			nr_kernel_pages -= memmap_pages;
 		nr_all_pages += freesize;
 
+init_zone:
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
 		/*
@@ -4924,6 +4952,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		BUG_ON(ret);
 		memmap_init(size, nid, j, zone_start_pfn);
 		zone_start_pfn += size;
+		last_zone_end_pfn = zone_start_pfn;
 	}
 }
 
@@ -5332,7 +5361,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	arch_zone_lowest_possible_pfn[0] = find_min_pfn_with_active_regions();
 	arch_zone_highest_possible_pfn[0] = max_zone_pfn[0];
 	for (i = 1; i < MAX_NR_ZONES; i++) {
-		if (i == ZONE_MOVABLE)
+		if (i == ZONE_MOVABLE || is_zone_cma_idx(i))
 			continue;
 		arch_zone_lowest_possible_pfn[i] =
 			arch_zone_highest_possible_pfn[i-1];
@@ -5341,6 +5370,10 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	}
 	arch_zone_lowest_possible_pfn[ZONE_MOVABLE] = 0;
 	arch_zone_highest_possible_pfn[ZONE_MOVABLE] = 0;
+#ifdef CONFIG_CMA
+	arch_zone_lowest_possible_pfn[ZONE_CMA] = 0;
+	arch_zone_highest_possible_pfn[ZONE_CMA] = 0;
+#endif
 
 	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
 	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
@@ -5349,7 +5382,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	/* Print out the zone ranges */
 	printk("Zone ranges:\n");
 	for (i = 0; i < MAX_NR_ZONES; i++) {
-		if (i == ZONE_MOVABLE)
+		if (i == ZONE_MOVABLE || is_zone_cma_idx(i))
 			continue;
 		printk(KERN_CONT "  %-8s ", zone_names[i]);
 		if (arch_zone_lowest_possible_pfn[i] ==
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7a4ac8e..b362b8f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -747,8 +747,16 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 #define TEXT_FOR_HIGHMEM(xx)
 #endif
 
+#ifdef CONFIG_CMA
+#define TEXT_FOR_CMA(xx) xx "_cma",
+#else
+#define TEXT_FOR_CMA(xx)
+#endif
+
+
 #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
-					TEXT_FOR_HIGHMEM(xx) xx "_movable",
+					TEXT_FOR_HIGHMEM(xx) xx "_movable", \
+					TEXT_FOR_CMA(xx)
 
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
