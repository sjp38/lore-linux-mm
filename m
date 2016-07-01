Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2392F828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:05:39 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a2so87365856lfe.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 13:05:39 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id l9si5045492wjd.75.2016.07.01.13.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 13:05:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 196761C221C
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 21:05:36 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 22/31] mm: convert zone_reclaim to node_reclaim
Date: Fri,  1 Jul 2016 21:01:30 +0100
Message-Id: <1467403299-25786-23-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As reclaim is now per-node based, convert zone_reclaim to be node_reclaim.
It is possible that a node will be reclaimed multiple times if it has
multiple zones but this is unavoidable without caching all nodes traversed
so far.  The documentation and interface to userspace is the same from a
configuration perspective and will will be similar in behaviour unless the
node-local allocation requests were also limited to lower zones.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h   | 18 +++++------
 include/linux/swap.h     |  9 +++---
 include/linux/topology.h |  2 +-
 kernel/sysctl.c          |  4 +--
 mm/internal.h            |  8 ++---
 mm/khugepaged.c          |  4 +--
 mm/page_alloc.c          | 24 ++++++++++-----
 mm/vmscan.c              | 77 ++++++++++++++++++++++++------------------------
 8 files changed, 77 insertions(+), 69 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c1dc3267db49..bb6902b73d16 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -372,14 +372,6 @@ struct zone {
 	unsigned long		*pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
 
-#ifdef CONFIG_NUMA
-	/*
-	 * zone reclaim becomes active if more unmapped pages exist.
-	 */
-	unsigned long		min_unmapped_pages;
-	unsigned long		min_slab_pages;
-#endif /* CONFIG_NUMA */
-
 	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
 	unsigned long		zone_start_pfn;
 
@@ -524,7 +516,6 @@ struct zone {
 } ____cacheline_internodealigned_in_smp;
 
 enum zone_flags {
-	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 };
 
@@ -539,6 +530,7 @@ enum pgdat_flags {
 	PGDAT_WRITEBACK,		/* reclaim scanning has recently found
 					 * many pages under writeback
 					 */
+	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 };
 
 static inline unsigned long zone_end_pfn(const struct zone *zone)
@@ -687,6 +679,14 @@ typedef struct pglist_data {
 	 */
 	unsigned long		totalreserve_pages;
 
+#ifdef CONFIG_NUMA
+	/*
+	 * zone reclaim becomes active if more unmapped pages exist.
+	 */
+	unsigned long		min_unmapped_pages;
+	unsigned long		min_slab_pages;
+#endif /* CONFIG_NUMA */
+
 	/* Write-intensive fields used from the page allocator */
 	ZONE_PADDING(_pad1_)
 	spinlock_t		lru_lock;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2a23ddc96edd..b17cc4830fa6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -326,13 +326,14 @@ extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
 #ifdef CONFIG_NUMA
-extern int zone_reclaim_mode;
+extern int node_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
-extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
+extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
 #else
-#define zone_reclaim_mode 0
-static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
+#define node_reclaim_mode 0
+static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
+				unsigned int order)
 {
 	return 0;
 }
diff --git a/include/linux/topology.h b/include/linux/topology.h
index afce69296ac0..cb0775e1ee4b 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -54,7 +54,7 @@ int arch_update_cpu_topology(void);
 /*
  * If the distance between nodes in a system is larger than RECLAIM_DISTANCE
  * (in whatever arch specific measurement units returned by node_distance())
- * and zone_reclaim_mode is enabled then the VM will only call zone_reclaim()
+ * and node_reclaim_mode is enabled then the VM will only call node_reclaim()
  * on nodes within this distance.
  */
 #define RECLAIM_DISTANCE 30
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index de331c3858e5..6e47ebe5384e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1498,8 +1498,8 @@ static struct ctl_table vm_table[] = {
 #ifdef CONFIG_NUMA
 	{
 		.procname	= "zone_reclaim_mode",
-		.data		= &zone_reclaim_mode,
-		.maxlen		= sizeof(zone_reclaim_mode),
+		.data		= &node_reclaim_mode,
+		.maxlen		= sizeof(node_reclaim_mode),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 		.extra1		= &zero,
diff --git a/mm/internal.h b/mm/internal.h
index 2f80d0343c56..1e21b2d3838d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -433,10 +433,10 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 }
 #endif /* CONFIG_SPARSEMEM */
 
-#define ZONE_RECLAIM_NOSCAN	-2
-#define ZONE_RECLAIM_FULL	-1
-#define ZONE_RECLAIM_SOME	0
-#define ZONE_RECLAIM_SUCCESS	1
+#define NODE_RECLAIM_NOSCAN	-2
+#define NODE_RECLAIM_FULL	-1
+#define NODE_RECLAIM_SOME	0
+#define NODE_RECLAIM_SUCCESS	1
 
 extern int hwpoison_filter(struct page *p);
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d907cdc3dc28..bb49bd1d2d9f 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -672,10 +672,10 @@ static bool khugepaged_scan_abort(int nid)
 	int i;
 
 	/*
-	 * If zone_reclaim_mode is disabled, then no extra effort is made to
+	 * If node_reclaim_mode is disabled, then no extra effort is made to
 	 * allocate memory locally.
 	 */
-	if (!zone_reclaim_mode)
+	if (!node_reclaim_mode)
 		return false;
 
 	/* If there is a count for this node already, it must be acceptable */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b10bee2e5968..eb31f114d0d8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2985,16 +2985,16 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			if (alloc_flags & ALLOC_NO_WATERMARKS)
 				goto try_this_zone;
 
-			if (zone_reclaim_mode == 0 ||
+			if (node_reclaim_mode == 0 ||
 			    !zone_allows_reclaim(ac->preferred_zoneref->zone, zone))
 				continue;
 
-			ret = zone_reclaim(zone, gfp_mask, order);
+			ret = node_reclaim(zone->zone_pgdat, gfp_mask, order);
 			switch (ret) {
-			case ZONE_RECLAIM_NOSCAN:
+			case NODE_RECLAIM_NOSCAN:
 				/* did not scan */
 				continue;
-			case ZONE_RECLAIM_FULL:
+			case NODE_RECLAIM_FULL:
 				/* scanned but unreclaimable */
 				continue;
 			default:
@@ -5991,9 +5991,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
 #ifdef CONFIG_NUMA
 		zone->node = nid;
-		zone->min_unmapped_pages = (freesize*sysctl_min_unmapped_ratio)
+		pgdat->min_unmapped_pages += (freesize*sysctl_min_unmapped_ratio)
 						/ 100;
-		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
+		pgdat->min_slab_pages += (freesize * sysctl_min_slab_ratio) / 100;
 #endif
 		zone->name = zone_names[j];
 		zone->zone_pgdat = pgdat;
@@ -6970,6 +6970,7 @@ int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int rc;
 
@@ -6977,8 +6978,11 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	if (rc)
 		return rc;
 
+	for_each_online_pgdat(pgdat)
+		pgdat->min_slab_pages = 0;
+
 	for_each_zone(zone)
-		zone->min_unmapped_pages = (zone->managed_pages *
+		zone->zone_pgdat->min_unmapped_pages += (zone->managed_pages *
 				sysctl_min_unmapped_ratio) / 100;
 	return 0;
 }
@@ -6986,6 +6990,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int rc;
 
@@ -6993,8 +6998,11 @@ int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
 	if (rc)
 		return rc;
 
+	for_each_online_pgdat(pgdat)
+		pgdat->min_slab_pages = 0;
+
 	for_each_zone(zone)
-		zone->min_slab_pages = (zone->managed_pages *
+		zone->zone_pgdat->min_slab_pages += (zone->managed_pages *
 				sysctl_min_slab_ratio) / 100;
 	return 0;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e02091be0e12..a6b30fe1de89 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3566,12 +3566,12 @@ module_init(kswapd_init)
 
 #ifdef CONFIG_NUMA
 /*
- * Zone reclaim mode
+ * Node reclaim mode
  *
- * If non-zero call zone_reclaim when the number of free pages falls below
+ * If non-zero call node_reclaim when the number of free pages falls below
  * the watermarks.
  */
-int zone_reclaim_mode __read_mostly;
+int node_reclaim_mode __read_mostly;
 
 #define RECLAIM_OFF 0
 #define RECLAIM_ZONE (1<<0)	/* Run shrink_inactive_list on the zone */
@@ -3579,14 +3579,14 @@ int zone_reclaim_mode __read_mostly;
 #define RECLAIM_UNMAP (1<<2)	/* Unmap pages during reclaim */
 
 /*
- * Priority for ZONE_RECLAIM. This determines the fraction of pages
+ * Priority for NODE_RECLAIM. This determines the fraction of pages
  * of a node considered for each zone_reclaim. 4 scans 1/16th of
  * a zone.
  */
-#define ZONE_RECLAIM_PRIORITY 4
+#define NODE_RECLAIM_PRIORITY 4
 
 /*
- * Percentage of pages in a zone that must be unmapped for zone_reclaim to
+ * Percentage of pages in a zone that must be unmapped for node_reclaim to
  * occur.
  */
 int sysctl_min_unmapped_ratio = 1;
@@ -3612,7 +3612,7 @@ static inline unsigned long node_unmapped_file_pages(struct pglist_data *pgdat)
 }
 
 /* Work out how many page cache pages we can reclaim in this reclaim_mode */
-static unsigned long zone_pagecache_reclaimable(struct zone *zone)
+static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 {
 	unsigned long nr_pagecache_reclaimable;
 	unsigned long delta = 0;
@@ -3623,14 +3623,14 @@ static unsigned long zone_pagecache_reclaimable(struct zone *zone)
 	 * pages like swapcache and node_unmapped_file_pages() provides
 	 * a better estimate
 	 */
-	if (zone_reclaim_mode & RECLAIM_UNMAP)
-		nr_pagecache_reclaimable = node_page_state(zone->zone_pgdat, NR_FILE_PAGES);
+	if (node_reclaim_mode & RECLAIM_UNMAP)
+		nr_pagecache_reclaimable = node_page_state(pgdat, NR_FILE_PAGES);
 	else
-		nr_pagecache_reclaimable = node_unmapped_file_pages(zone->zone_pgdat);
+		nr_pagecache_reclaimable = node_unmapped_file_pages(pgdat);
 
 	/* If we can't clean pages, remove dirty pages from consideration */
-	if (!(zone_reclaim_mode & RECLAIM_WRITE))
-		delta += node_page_state(zone->zone_pgdat, NR_FILE_DIRTY);
+	if (!(node_reclaim_mode & RECLAIM_WRITE))
+		delta += node_page_state(pgdat, NR_FILE_DIRTY);
 
 	/* Watch for any possible underflows due to delta */
 	if (unlikely(delta > nr_pagecache_reclaimable))
@@ -3640,23 +3640,24 @@ static unsigned long zone_pagecache_reclaimable(struct zone *zone)
 }
 
 /*
- * Try to free up some pages from this zone through reclaim.
+ * Try to free up some pages from this node through reclaim.
  */
-static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
+static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 {
 	/* Minimum pages needed in order to stay on node */
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
+	int classzone_idx = gfp_zone(gfp_mask);
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
 		.order = order,
-		.priority = ZONE_RECLAIM_PRIORITY,
-		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
-		.may_unmap = !!(zone_reclaim_mode & RECLAIM_UNMAP),
+		.priority = NODE_RECLAIM_PRIORITY,
+		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
+		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
-		.reclaim_idx = zone_idx(zone),
+		.reclaim_idx = classzone_idx,
 	};
 
 	cond_resched();
@@ -3670,13 +3671,13 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
+	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
 		/*
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
 		 */
 		do {
-			shrink_node(zone->zone_pgdat, &sc, zone_idx(zone));
+			shrink_node(pgdat, &sc, classzone_idx);
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
@@ -3686,49 +3687,47 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	return sc.nr_reclaimed >= nr_pages;
 }
 
-int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
+int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 {
-	int node_id;
 	int ret;
 
 	/*
-	 * Zone reclaim reclaims unmapped file backed pages and
+	 * Node reclaim reclaims unmapped file backed pages and
 	 * slab pages if we are over the defined limits.
 	 *
 	 * A small portion of unmapped file backed pages is needed for
 	 * file I/O otherwise pages read by file I/O will be immediately
-	 * thrown out if the zone is overallocated. So we do not reclaim
-	 * if less than a specified percentage of the zone is used by
+	 * thrown out if the node is overallocated. So we do not reclaim
+	 * if less than a specified percentage of the node is used by
 	 * unmapped file backed pages.
 	 */
-	if (zone_pagecache_reclaimable(zone) <= zone->min_unmapped_pages &&
-	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
-		return ZONE_RECLAIM_FULL;
+	if (node_pagecache_reclaimable(pgdat) <= pgdat->min_unmapped_pages &&
+	    sum_zone_node_page_state(pgdat->node_id, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
+		return NODE_RECLAIM_FULL;
 
-	if (!pgdat_reclaimable(zone->zone_pgdat))
-		return ZONE_RECLAIM_FULL;
+	if (!pgdat_reclaimable(pgdat))
+		return NODE_RECLAIM_FULL;
 
 	/*
 	 * Do not scan if the allocation should not be delayed.
 	 */
 	if (!gfpflags_allow_blocking(gfp_mask) || (current->flags & PF_MEMALLOC))
-		return ZONE_RECLAIM_NOSCAN;
+		return NODE_RECLAIM_NOSCAN;
 
 	/*
-	 * Only run zone reclaim on the local zone or on zones that do not
+	 * Only run node reclaim on the local node or on nodes that do not
 	 * have associated processors. This will favor the local processor
 	 * over remote processors and spread off node memory allocations
 	 * as wide as possible.
 	 */
-	node_id = zone_to_nid(zone);
-	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
-		return ZONE_RECLAIM_NOSCAN;
+	if (node_state(pgdat->node_id, N_CPU) && pgdat->node_id != numa_node_id())
+		return NODE_RECLAIM_NOSCAN;
 
-	if (test_and_set_bit(ZONE_RECLAIM_LOCKED, &zone->flags))
-		return ZONE_RECLAIM_NOSCAN;
+	if (test_and_set_bit(PGDAT_RECLAIM_LOCKED, &pgdat->flags))
+		return NODE_RECLAIM_NOSCAN;
 
-	ret = __zone_reclaim(zone, gfp_mask, order);
-	clear_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
+	ret = __node_reclaim(pgdat, gfp_mask, order);
+	clear_bit(PGDAT_RECLAIM_LOCKED, &pgdat->flags);
 
 	if (!ret)
 		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
