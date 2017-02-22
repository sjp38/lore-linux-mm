Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 362DF6B0038
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 15:23:00 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id q39so5361234wrb.3
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 12:23:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g16si3916315wmg.156.2017.02.22.12.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 12:22:57 -0800 (PST)
Date: Wed, 22 Feb 2017 15:16:57 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm/vmscan: fix high cpu usage of kswapd if there
Message-ID: <20170222201657.GA6534@cmpxchg.org>
References: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed, Feb 22, 2017 at 05:04:48PM +0800, Jia He wrote:
> When I try to dynamically allocate the hugepages more than system total
> free memory:

> Then the kswapd will take 100% cpu for a long time(more than 3 hours, and
> will not be about to end)

> The root cause is kswapd3 is trying to do relaim again and again but it 
> makes no progress

> At that time, there are no relaimable pages in that node:

Yes, this is a problem with the current kswapd code.

A less artificial scenario that I observed recently was machines with
two NUMA nodes, after being up for 200+ days, getting into a state
where node0 is mostly consumed by anon and some kernel allocations,
leaving less than the high watermark free. The machines don't have
swap, so the anon isn't reclaimable. But also, anon LRU is never even
*scanned*, so the "all unreclaimable" logic doesn't kick in. Kswapd is
spinning at 100% CPU calculating scan counts and checking zone states.

One specific problem with your patch, Jia, is that there might be some
cache pages that are pinned one way or another. That was the case on
our machines, and so reclaimable pages wasn't 0. Even if we check the
reclaimable pages, we need a hard cutoff after X attempts. And then it
sounds pretty much like what the allocator/direct reclaim already does.

Can we use the *exact* same cutoff conditions for direct reclaim and
kswapd, though? I don't think so. For direct reclaim, the goal is the
watermark, to make an allocation happen in the caller. While kswapd
tries to restore the watermarks too, it might never meet them but
still do useful work on behalf of concurrently allocating threads. It
should only stop when it tries and fails to free any pages at all.

The recent removal of the scanned > reclaimable * 6 exit condition
from kswapd was a mistake, we need something like it. But it's also
broken the way we perform reclaim on swapless systems, so instead of
re-instating it, we should remove the remnants and do something new.

Can we simply count the number of balance_pgdat() runs that didn't
reclaim anything and have kswapd sleep after MAX_RECLAIM_RETRIES?

And a follow-up: once it gives up, when should kswapd return to work?
We used to reset NR_PAGES_SCANNED whenever a page gets freed. But
that's a branch in a common allocator path, just to recover kswapd - a
latency tool, not a necessity for functional correctness - from a
situation that's exceedingly pretty rare. How about we leave it
disabled until a direct reclaimer manages to free something?

Something like this (untested):

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 96c78d840916..611c5fb52d7b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -149,7 +149,6 @@ enum node_stat_item {
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
-	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
 	PGSCAN_ANON,
 	PGSCAN_FILE,
 	PGSTEAL_ANON,
@@ -630,6 +629,8 @@ typedef struct pglist_data {
 	int kswapd_order;
 	enum zone_type kswapd_classzone_idx;
 
+	int kswapd_failed_runs;
+
 #ifdef CONFIG_COMPACTION
 	int kcompactd_max_order;
 	enum zone_type kcompactd_classzone_idx;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 145005e6dc85..9de49e2710af 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -285,8 +285,8 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 						struct vm_area_struct *vma);
 
 /* linux/mm/vmscan.c */
+#define MAX_RECLAIM_RETRIES 16
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
-extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
diff --git a/mm/internal.h b/mm/internal.h
index 537ac9951f5f..812e1aaf4142 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -78,7 +78,6 @@ extern unsigned long highest_memmap_pfn;
  */
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
-extern bool pgdat_reclaimable(struct pglist_data *pgdat);
 
 /*
  * in mm/rmap.c:
diff --git a/mm/migrate.c b/mm/migrate.c
index c83186c61257..d4f0a499b4e5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1731,9 +1731,6 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
 {
 	int z;
 
-	if (!pgdat_reclaimable(pgdat))
-		return false;
-
 	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
 		struct zone *zone = pgdat->node_zones + z;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c470b8fe28cf..c467a4fff16a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1087,15 +1087,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 {
 	int migratetype = 0;
 	int batch_free = 0;
-	unsigned long nr_scanned;
 	bool isolated_pageblocks;
 
 	spin_lock(&zone->lock);
 	isolated_pageblocks = has_isolate_pageblock(zone);
-	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
-	if (nr_scanned)
-		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
-
 	while (count) {
 		struct page *page;
 		struct list_head *list;
@@ -1147,12 +1142,7 @@ static void free_one_page(struct zone *zone,
 				unsigned int order,
 				int migratetype)
 {
-	unsigned long nr_scanned;
 	spin_lock(&zone->lock);
-	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
-	if (nr_scanned)
-		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
-
 	if (unlikely(has_isolate_pageblock(zone) ||
 		is_migrate_isolate(migratetype))) {
 		migratetype = get_pfnblock_migratetype(page, pfn);
@@ -3388,12 +3378,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 }
 
 /*
- * Maximum number of reclaim retries without any progress before OOM killer
- * is consider as the only way to move forward.
- */
-#define MAX_RECLAIM_RETRIES 16
-
-/*
  * Checks whether it makes sense to retry the reclaim to make a forward progress
  * for the given allocation request.
  * The reclaim feedback represented by did_some_progress (any progress during
@@ -4301,7 +4285,6 @@ void show_free_areas(unsigned int filter)
 #endif
 			" writeback_tmp:%lukB"
 			" unstable:%lukB"
-			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
@@ -4324,8 +4307,8 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_SHMEM)),
 			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
-			node_page_state(pgdat, NR_PAGES_SCANNED),
-			!pgdat_reclaimable(pgdat) ? "yes" : "no");
+		        pgdat->kswapd_failed_runs >= MAX_RECLAIM_RETRIES ?
+				"yes" : "no");
 	}
 
 	for_each_populated_zone(zone) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1b112f291fbe..2b4ce7cd97d8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -212,28 +212,6 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
 	return nr;
 }
 
-unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
-{
-	unsigned long nr;
-
-	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
-
-	if (get_nr_swap_pages() > 0)
-		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
-		      node_page_state_snapshot(pgdat, NR_INACTIVE_ANON) +
-		      node_page_state_snapshot(pgdat, NR_ISOLATED_ANON);
-
-	return nr;
-}
-
-bool pgdat_reclaimable(struct pglist_data *pgdat)
-{
-	return node_page_state_snapshot(pgdat, NR_PAGES_SCANNED) <
-		pgdat_reclaimable_pages(pgdat) * 6;
-}
-
 unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
 	if (!mem_cgroup_disabled())
@@ -1438,10 +1416,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 		}
 
-		/*
-		 * Account for scanned and skipped separetly to avoid the pgdat
-		 * being prematurely marked unreclaimable by pgdat_reclaimable.
-		 */
 		scan++;
 
 		switch (__isolate_lru_page(page, mode)) {
@@ -1728,7 +1702,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	if (global_reclaim(sc)) {
 		__mod_node_page_state(pgdat, PGSCAN_ANON + file, nr_scanned);
-		__mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
 		if (current_is_kswapd())
 			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
 		else
@@ -1916,8 +1889,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 
-	if (global_reclaim(sc))
-		__mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
 	__count_vm_events(PGREFILL, nr_scanned);
 
 	spin_unlock_irq(&pgdat->lru_lock);
@@ -2114,12 +2085,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd()) {
-		if (!pgdat_reclaimable(pgdat))
-			force_scan = true;
-		if (!mem_cgroup_online(memcg))
-			force_scan = true;
-	}
+	if (current_is_kswapd() && !mem_cgroup_online(memcg))
+		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
 
@@ -2593,6 +2560,14 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
+	/*
+	 * Kswapd might have declared a node hopeless after too many
+	 * successless balancing attempts. If we reclaim anything at
+	 * all here, knock it loose.
+	 */
+	if (reclaimable)
+		pgdat->kswapd_failed_runs = 0;
+
 	return reclaimable;
 }
 
@@ -2667,10 +2642,6 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
 
-			if (sc->priority != DEF_PRIORITY &&
-			    !pgdat_reclaimable(zone->zone_pgdat))
-				continue;	/* Let kswapd poll it */
-
 			/*
 			 * If we already have plenty of memory free for
 			 * compaction in this zone, don't free any more.
@@ -2817,8 +2788,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
-		if (!managed_zone(zone) ||
-		    pgdat_reclaimable_pages(pgdat) == 0)
+		if (!managed_zone(zone))
 			continue;
 
 		pfmemalloc_reserve += min_wmark_pages(zone);
@@ -3117,6 +3087,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	if (waitqueue_active(&pgdat->pfmemalloc_wait))
 		wake_up_all(&pgdat->pfmemalloc_wait);
 
+	/* Hopeless node until direct reclaim knocks us free */
+	if (pgdat->kswapd_failed_runs >= MAX_RECLAIM_RETRIES)
+		return true;
+
 	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
@@ -3260,7 +3234,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * If we're getting trouble reclaiming, start doing writepage
 		 * even in laptop mode.
 		 */
-		if (sc.priority < DEF_PRIORITY - 2 || !pgdat_reclaimable(pgdat))
+		if (sc.priority < DEF_PRIORITY - 2)
 			sc.may_writepage = 1;
 
 		/* Call soft limit reclaim before calling shrink_node. */
@@ -3299,6 +3273,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			sc.priority--;
 	} while (sc.priority >= 1);
 
+	if (!sc.nr_reclaimed)
+		pgdat->kswapd_failed_runs++;
+
 out:
 	/*
 	 * Return the order kswapd stopped reclaiming at as
@@ -3498,6 +3475,10 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
 
+	/* Hopeless node until direct reclaim knocks us free */
+	if (pgdat->kswapd_failed_runs >= MAX_RECLAIM_RETRIES)
+		return;
+
 	/* Only wake kswapd if all zones are unbalanced */
 	for (z = 0; z <= classzone_idx; z++) {
 		zone = pgdat->node_zones + z;
@@ -3768,9 +3749,6 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 	    sum_zone_node_page_state(pgdat->node_id, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
 		return NODE_RECLAIM_FULL;
 
-	if (!pgdat_reclaimable(pgdat))
-		return NODE_RECLAIM_FULL;
-
 	/*
 	 * Do not scan if the allocation should not be delayed.
 	 */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ef3b683f1f56..2e022d537d25 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -954,7 +954,6 @@ const char * const vmstat_text[] = {
 	"nr_unevictable",
 	"nr_isolated_anon",
 	"nr_isolated_file",
-	"nr_pages_scanned",
 	"pgscan_anon",
 	"pgscan_file",
 	"pgsteal_anon",
@@ -1378,7 +1377,6 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
-		   "\n   node_scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu"
 		   "\n        managed  %lu",
@@ -1386,7 +1384,6 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),
-		   node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED),
 		   zone->spanned_pages,
 		   zone->present_pages,
 		   zone->managed_pages);
@@ -1425,7 +1422,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n  node_unreclaimable:  %u"
 		   "\n  start_pfn:           %lu"
 		   "\n  node_inactive_ratio: %u",
-		   !pgdat_reclaimable(zone->zone_pgdat),
+		   zone->zone_pgdat->kswapd_failed_runs >= MAX_RECLAIM_RETRIES,
 		   zone->zone_start_pfn,
 		   zone->zone_pgdat->inactive_ratio);
 	seq_putc(m, '\n');
@@ -1587,26 +1584,11 @@ int vmstat_refresh(struct ctl_table *table, int write,
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
 		val = atomic_long_read(&vm_zone_stat[i]);
 		if (val < 0) {
-			switch (i) {
-			case NR_PAGES_SCANNED:
-				/*
-				 * This is often seen to go negative in
-				 * recent kernels, but not to go permanently
-				 * negative.  Whilst it would be nicer not to
-				 * have exceptions, rooting them out would be
-				 * another task, of rather low priority.
-				 */
-				break;
-			default:
-				pr_warn("%s: %s %ld\n",
-					__func__, vmstat_text[i], val);
-				err = -EINVAL;
-				break;
-			}
+			pr_warn("%s: %s %ld\n",
+				__func__, vmstat_text[i], val);
+			return -EINVAL;
 		}
 	}
-	if (err)
-		return err;
 	if (write)
 		*ppos += *lenp;
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
