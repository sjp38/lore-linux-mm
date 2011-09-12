Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C002F6B0264
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:10 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 03/11] mm: vmscan: distinguish between memcg triggering reclaim and memcg being scanned
Date: Mon, 12 Sep 2011 12:57:20 +0200
Message-Id: <1315825048-3437-4-git-send-email-jweiner@redhat.com>
In-Reply-To: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Memory cgroup hierarchies are currently handled completely outside of
the traditional reclaim code, which is invoked with a single memory
cgroup as an argument for the whole call stack.

Subsequent patches will switch this code to do hierarchical reclaim,
so there needs to be a distinction between a) the memory cgroup that
is triggering reclaim due to hitting its limit and b) the memory
cgroup that is being scanned as a child of a).

This patch introduces a struct mem_cgroup_zone that contains the
combination of the memory cgroup and the zone being scanned, which is
then passed down the stack instead of the zone argument.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/vmscan.c |  251 +++++++++++++++++++++++++++++++++--------------------------
 1 files changed, 142 insertions(+), 109 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 354f125..92f4e22 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -103,8 +103,11 @@ struct scan_control {
 	 */
 	reclaim_mode_t reclaim_mode;
 
-	/* Which cgroup do we reclaim from */
-	struct mem_cgroup *mem_cgroup;
+	/*
+	 * The memory cgroup that hit its limit and as a result is the
+	 * primary target of this reclaim invocation.
+	 */
+	struct mem_cgroup *target_mem_cgroup;
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -113,6 +116,11 @@ struct scan_control {
 	nodemask_t	*nodemask;
 };
 
+struct mem_cgroup_zone {
+	struct mem_cgroup *mem_cgroup;
+	struct zone *zone;
+};
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
@@ -155,12 +163,12 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 static bool global_reclaim(struct scan_control *sc)
 {
-	return !sc->mem_cgroup;
+	return !sc->target_mem_cgroup;
 }
 
-static bool scanning_global_lru(struct scan_control *sc)
+static bool scanning_global_lru(struct mem_cgroup_zone *mz)
 {
-	return !sc->mem_cgroup;
+	return !mz->mem_cgroup;
 }
 #else
 static bool global_reclaim(struct scan_control *sc)
@@ -168,29 +176,30 @@ static bool global_reclaim(struct scan_control *sc)
 	return true;
 }
 
-static bool scanning_global_lru(struct scan_control *sc)
+static bool scanning_global_lru(struct mem_cgroup_zone *mz)
 {
 	return true;
 }
 #endif
 
-static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
-						  struct scan_control *sc)
+static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
 {
-	if (!scanning_global_lru(sc))
-		return mem_cgroup_get_reclaim_stat(sc->mem_cgroup, zone);
+	if (!scanning_global_lru(mz))
+		return mem_cgroup_get_reclaim_stat(mz->mem_cgroup, mz->zone);
 
-	return &zone->reclaim_stat;
+	return &mz->zone->reclaim_stat;
 }
 
-static unsigned long zone_nr_lru_pages(struct zone *zone,
-				struct scan_control *sc, enum lru_list lru)
+static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,
+				       enum lru_list lru)
 {
-	if (!scanning_global_lru(sc))
-		return mem_cgroup_zone_nr_lru_pages(sc->mem_cgroup,
-				zone_to_nid(zone), zone_idx(zone), BIT(lru));
+	if (!scanning_global_lru(mz))
+		return mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
+						    zone_to_nid(mz->zone),
+						    zone_idx(mz->zone),
+						    BIT(lru));
 
-	return zone_page_state(zone, NR_LRU_BASE + lru);
+	return zone_page_state(mz->zone, NR_LRU_BASE + lru);
 }
 
 
@@ -692,12 +701,13 @@ enum page_references {
 };
 
 static enum page_references page_check_references(struct page *page,
+						  struct mem_cgroup_zone *mz,
 						  struct scan_control *sc)
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
 
-	referenced_ptes = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
+	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
@@ -771,7 +781,7 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct zone *zone,
+				      struct mem_cgroup_zone *mz,
 				      struct scan_control *sc,
 				      int priority,
 				      unsigned long *ret_nr_dirty,
@@ -802,7 +812,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(page_zone(page) != zone);
+		VM_BUG_ON(page_zone(page) != mz->zone);
 
 		sc->nr_scanned++;
 
@@ -836,7 +846,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		references = page_check_references(page, sc);
+		references = page_check_references(page, mz, sc);
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
@@ -1028,7 +1038,7 @@ keep_lumpy:
 	 * will encounter the same problem
 	 */
 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
-		zone_set_flag(zone, ZONE_CONGESTED);
+		zone_set_flag(mz->zone, ZONE_CONGESTED);
 
 	free_page_list(&free_pages);
 
@@ -1364,13 +1374,14 @@ static int too_many_isolated(struct zone *zone, int file,
  * TODO: Try merging with migrations version of putback_lru_pages
  */
 static noinline_for_stack void
-putback_lru_pages(struct zone *zone, struct scan_control *sc,
-				unsigned long nr_anon, unsigned long nr_file,
-				struct list_head *page_list)
+putback_lru_pages(struct mem_cgroup_zone *mz, struct scan_control *sc,
+		  unsigned long nr_anon, unsigned long nr_file,
+		  struct list_head *page_list)
 {
 	struct page *page;
 	struct pagevec pvec;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	struct zone *zone = mz->zone;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 
 	pagevec_init(&pvec, 1);
 
@@ -1410,15 +1421,17 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 	pagevec_release(&pvec);
 }
 
-static noinline_for_stack void update_isolated_counts(struct zone *zone,
-					struct scan_control *sc,
-					unsigned long *nr_anon,
-					unsigned long *nr_file,
-					struct list_head *isolated_list)
+static noinline_for_stack void
+update_isolated_counts(struct mem_cgroup_zone *mz,
+		       struct scan_control *sc,
+		       unsigned long *nr_anon,
+		       unsigned long *nr_file,
+		       struct list_head *isolated_list)
 {
 	unsigned long nr_active;
+	struct zone *zone = mz->zone;
 	unsigned int count[NR_LRU_LISTS] = { 0, };
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 
 	nr_active = clear_active_flags(isolated_list, count);
 	__count_vm_events(PGDEACTIVATE, nr_active);
@@ -1487,8 +1500,8 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
  * of reclaimed pages
  */
 static noinline_for_stack unsigned long
-shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
-			struct scan_control *sc, int priority, int file)
+shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
+		     struct scan_control *sc, int priority, int file)
 {
 	LIST_HEAD(page_list);
 	unsigned long nr_scanned;
@@ -1499,6 +1512,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
+	struct zone *zone = mz->zone;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1521,13 +1535,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_lock_irq(&zone->lru_lock);
 
-	if (scanning_global_lru(sc)) {
+	if (scanning_global_lru(mz)) {
 		nr_taken = isolate_pages_global(nr_to_scan, &page_list,
 			&nr_scanned, sc->order, reclaim_mode, zone, 0, file);
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_to_scan, &page_list,
 			&nr_scanned, sc->order, reclaim_mode, zone,
-			sc->mem_cgroup, 0, file);
+			mz->mem_cgroup, 0, file);
 	}
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
@@ -1544,17 +1558,17 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		return 0;
 	}
 
-	update_isolated_counts(zone, sc, &nr_anon, &nr_file, &page_list);
+	update_isolated_counts(mz, sc, &nr_anon, &nr_file, &page_list);
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, priority,
+	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
 						&nr_dirty, &nr_writeback);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, zone, sc,
+		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
 					priority, &nr_dirty, &nr_writeback);
 	}
 
@@ -1563,7 +1577,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
+	putback_lru_pages(mz, sc, nr_anon, nr_file, &page_list);
 
 	/*
 	 * If we have encountered a high number of dirty pages under writeback
@@ -1634,8 +1648,10 @@ static void move_active_pages_to_lru(struct zone *zone,
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
 
-static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-			struct scan_control *sc, int priority, int file)
+static void shrink_active_list(unsigned long nr_pages,
+			       struct mem_cgroup_zone *mz,
+			       struct scan_control *sc,
+			       int priority, int file)
 {
 	unsigned long nr_taken;
 	unsigned long pgscanned;
@@ -1644,9 +1660,10 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
 	struct page *page;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	unsigned long nr_rotated = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_ACTIVE;
+	struct zone *zone = mz->zone;
 
 	lru_add_drain();
 
@@ -1656,7 +1673,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 		reclaim_mode |= ISOLATE_CLEAN;
 
 	spin_lock_irq(&zone->lru_lock);
-	if (scanning_global_lru(sc)) {
+	if (scanning_global_lru(mz)) {
 		nr_taken = isolate_pages_global(nr_pages, &l_hold,
 						&pgscanned, sc->order,
 						reclaim_mode, zone,
@@ -1665,7 +1682,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
 						&pgscanned, sc->order,
 						reclaim_mode, zone,
-						sc->mem_cgroup, 1, file);
+						mz->mem_cgroup, 1, file);
 	}
 
 	if (global_reclaim(sc))
@@ -1691,7 +1708,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			continue;
 		}
 
-		if (page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
@@ -1754,10 +1771,8 @@ static int inactive_anon_is_low_global(struct zone *zone)
  * Returns true if the zone does not have enough inactive anon pages,
  * meaning some active anon pages need to be deactivated.
  */
-static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
+static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 {
-	int low;
-
 	/*
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
@@ -1765,15 +1780,14 @@ static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 	if (!total_swap_pages)
 		return 0;
 
-	if (scanning_global_lru(sc))
-		low = inactive_anon_is_low_global(zone);
-	else
-		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup, zone);
-	return low;
+	if (!scanning_global_lru(mz))
+		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
+						       mz->zone);
+
+	return inactive_anon_is_low_global(mz->zone);
 }
 #else
-static inline int inactive_anon_is_low(struct zone *zone,
-					struct scan_control *sc)
+static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 {
 	return 0;
 }
@@ -1791,8 +1805,7 @@ static int inactive_file_is_low_global(struct zone *zone)
 
 /**
  * inactive_file_is_low - check if file pages need to be deactivated
- * @zone: zone to check
- * @sc:   scan control of this context
+ * @mz: memory cgroup and zone to check
  *
  * When the system is doing streaming IO, memory pressure here
  * ensures that active file pages get deactivated, until more
@@ -1804,45 +1817,44 @@ static int inactive_file_is_low_global(struct zone *zone)
  * This uses a different ratio than the anonymous pages, because
  * the page cache uses a use-once replacement algorithm.
  */
-static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
+static int inactive_file_is_low(struct mem_cgroup_zone *mz)
 {
-	int low;
+	if (!scanning_global_lru(mz))
+		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
+						       mz->zone);
 
-	if (scanning_global_lru(sc))
-		low = inactive_file_is_low_global(zone);
-	else
-		low = mem_cgroup_inactive_file_is_low(sc->mem_cgroup, zone);
-	return low;
+	return inactive_file_is_low_global(mz->zone);
 }
 
-static int inactive_list_is_low(struct zone *zone, struct scan_control *sc,
-				int file)
+static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
 {
 	if (file)
-		return inactive_file_is_low(zone, sc);
+		return inactive_file_is_low(mz);
 	else
-		return inactive_anon_is_low(zone, sc);
+		return inactive_anon_is_low(mz);
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-	struct zone *zone, struct scan_control *sc, int priority)
+				 struct mem_cgroup_zone *mz,
+				 struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(zone, sc, file))
-		    shrink_active_list(nr_to_scan, zone, sc, priority, file);
+		if (inactive_list_is_low(mz, file))
+		    shrink_active_list(nr_to_scan, mz, sc, priority, file);
 		return 0;
 	}
 
-	return shrink_inactive_list(nr_to_scan, zone, sc, priority, file);
+	return shrink_inactive_list(nr_to_scan, mz, sc, priority, file);
 }
 
-static int vmscan_swappiness(struct scan_control *sc)
+static int vmscan_swappiness(struct mem_cgroup_zone *mz,
+			     struct scan_control *sc)
 {
-	if (scanning_global_lru(sc))
+	if (global_reclaim(sc))
 		return vm_swappiness;
-	return mem_cgroup_swappiness(sc->mem_cgroup);
+	return mem_cgroup_swappiness(mz->mem_cgroup);
 }
 
 /*
@@ -1853,13 +1865,13 @@ static int vmscan_swappiness(struct scan_control *sc)
  *
  * nr[0] = anon pages to scan; nr[1] = file pages to scan
  */
-static void get_scan_count(struct zone *zone, struct scan_control *sc,
-					unsigned long *nr, int priority)
+static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
+			   unsigned long *nr, int priority)
 {
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	u64 fraction[2], denominator;
 	enum lru_list l;
 	int noswap = 0;
@@ -1889,16 +1901,16 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 		goto out;
 	}
 
-	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
-	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+	anon  = zone_nr_lru_pages(mz, LRU_ACTIVE_ANON) +
+		zone_nr_lru_pages(mz, LRU_INACTIVE_ANON);
+	file  = zone_nr_lru_pages(mz, LRU_ACTIVE_FILE) +
+		zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
 
 	if (global_reclaim(sc)) {
-		free  = zone_page_state(zone, NR_FREE_PAGES);
+		free  = zone_page_state(mz->zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
-		if (unlikely(file + free <= high_wmark_pages(zone))) {
+		if (unlikely(file + free <= high_wmark_pages(mz->zone))) {
 			fraction[0] = 1;
 			fraction[1] = 0;
 			denominator = 1;
@@ -1910,8 +1922,8 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	 * With swappiness at 100, anonymous and file have the same priority.
 	 * This scanning priority is essentially the inverse of IO cost.
 	 */
-	anon_prio = vmscan_swappiness(sc);
-	file_prio = 200 - vmscan_swappiness(sc);
+	anon_prio = vmscan_swappiness(mz, sc);
+	file_prio = 200 - vmscan_swappiness(mz, sc);
 
 	/*
 	 * OK, so we have swap space and a fair amount of page cache
@@ -1924,7 +1936,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(&mz->zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1945,7 +1957,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(&mz->zone->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -1955,7 +1967,7 @@ out:
 		int file = is_file_lru(l);
 		unsigned long scan;
 
-		scan = zone_nr_lru_pages(zone, sc, l);
+		scan = zone_nr_lru_pages(mz, l);
 		if (priority || noswap) {
 			scan >>= priority;
 			if (!scan && force_scan)
@@ -1973,7 +1985,7 @@ out:
  * back to the allocator and call try_to_compact_zone(), we ensure that
  * there are enough free pages for it to be likely successful
  */
-static inline bool should_continue_reclaim(struct zone *zone,
+static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
 					struct scan_control *sc)
@@ -2013,14 +2025,14 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON) +
-				zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+	inactive_lru_pages = zone_nr_lru_pages(mz, LRU_INACTIVE_ANON) +
+				zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(zone, sc->order)) {
+	switch (compaction_suitable(mz->zone, sc->order)) {
 	case COMPACT_PARTIAL:
 	case COMPACT_CONTINUE:
 		return false;
@@ -2032,8 +2044,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
+				   struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -2045,7 +2057,7 @@ static void shrink_zone(int priority, struct zone *zone,
 restart:
 	nr_reclaimed = 0;
 	nr_scanned = sc->nr_scanned;
-	get_scan_count(zone, sc, nr, priority);
+	get_scan_count(mz, sc, nr, priority);
 
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
@@ -2057,7 +2069,7 @@ restart:
 				nr[l] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(l, nr_to_scan,
-							    zone, sc, priority);
+							    mz, sc, priority);
 			}
 		}
 		/*
@@ -2078,17 +2090,28 @@ restart:
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(zone, sc))
-		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
+	if (inactive_anon_is_low(mz))
+		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
 
 	/* reclaim/compaction might need reclaim to continue */
-	if (should_continue_reclaim(zone, nr_reclaimed,
+	if (should_continue_reclaim(mz, nr_reclaimed,
 					sc->nr_scanned - nr_scanned, sc))
 		goto restart;
 
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
+static void shrink_zone(int priority, struct zone *zone,
+			struct scan_control *sc)
+{
+	struct mem_cgroup_zone mz = {
+		.mem_cgroup = sc->target_mem_cgroup,
+		.zone = zone,
+	};
+
+	shrink_mem_cgroup_zone(priority, &mz, sc);
+}
+
 /*
  * This is the direct reclaim path, for page-allocating processes.  We only
  * try to reclaim pages from zones which will satisfy the caller's allocation
@@ -2206,7 +2229,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
 		if (!priority)
-			disable_swap_token(sc->mem_cgroup);
+			disable_swap_token(sc->target_mem_cgroup);
 		shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
@@ -2290,7 +2313,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_unmap = 1,
 		.may_swap = 1,
 		.order = order,
-		.mem_cgroup = NULL,
+		.target_mem_cgroup = NULL,
 		.nodemask = nodemask,
 	};
 	struct shrink_control shrink = {
@@ -2322,7 +2345,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.order = 0,
-		.mem_cgroup = mem,
+		.target_mem_cgroup = mem,
 	};
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2360,7 +2383,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.order = 0,
-		.mem_cgroup = mem_cont,
+		.target_mem_cgroup = mem_cont,
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
@@ -2390,6 +2413,18 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 }
 #endif
 
+static void age_active_anon(struct zone *zone, struct scan_control *sc,
+			    int priority)
+{
+	struct mem_cgroup_zone mz = {
+		.mem_cgroup = NULL,
+		.zone = zone,
+	};
+
+	if (inactive_anon_is_low(&mz))
+		shrink_active_list(SWAP_CLUSTER_MAX, &mz, sc, priority, 0);
+}
+
 /*
  * pgdat_balanced is used when checking if a node is balanced for high-order
  * allocations. Only zones that meet watermarks and are in a zone allowed
@@ -2510,7 +2545,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 */
 		.nr_to_reclaim = ULONG_MAX,
 		.order = order,
-		.mem_cgroup = NULL,
+		.target_mem_cgroup = NULL,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2549,9 +2584,7 @@ loop_again:
 			 * Do some background aging of the anon list, to give
 			 * pages a chance to be referenced before reclaiming.
 			 */
-			if (inactive_anon_is_low(zone, &sc))
-				shrink_active_list(SWAP_CLUSTER_MAX, zone,
-							&sc, priority, 0);
+			age_active_anon(zone, &sc, priority);
 
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
