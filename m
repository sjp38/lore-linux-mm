Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 842F46B00E9
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:32 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:32 -0800 (PST)
Subject: [PATCH RFC 06/15] mm: kill struct mem_cgroup_zone
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:28 +0400
Message-ID: <20120215225728.22050.40517.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Now struct mem_cgroup_zone always points to one book, either root zone->book or
some from memcg. So this fancy pointer can be replaced with direct pointer to
struct book.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |  181 ++++++++++++++++++++++-------------------------------------
 1 files changed, 66 insertions(+), 115 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ba95e83..c59d4f7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -121,11 +121,6 @@ struct scan_control {
 	nodemask_t	*nodemask;
 };
 
-struct mem_cgroup_zone {
-	struct mem_cgroup *mem_cgroup;
-	struct zone *zone;
-};
-
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
@@ -170,45 +165,13 @@ static bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup;
 }
-
-static bool scanning_global_lru(struct mem_cgroup_zone *mz)
-{
-	return !mz->mem_cgroup;
-}
 #else
 static bool global_reclaim(struct scan_control *sc)
 {
 	return true;
 }
-
-static bool scanning_global_lru(struct mem_cgroup_zone *mz)
-{
-	return true;
-}
 #endif
 
-static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
-{
-	if (!scanning_global_lru(mz))
-		return &mem_cgroup_zone_book(mz->zone,
-				mz->mem_cgroup)->reclaim_stat;
-
-	return &mz->zone->book.reclaim_stat;
-}
-
-static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,
-				       enum lru_list lru)
-{
-	if (!scanning_global_lru(mz))
-		return mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-						    zone_to_nid(mz->zone),
-						    zone_idx(mz->zone),
-						    BIT(lru));
-
-	return zone_page_state(mz->zone, NR_LRU_BASE + lru);
-}
-
-
 /*
  * Add a shrinker callback to be called from the vm
  */
@@ -772,7 +735,7 @@ static enum page_references page_check_references(struct page *page,
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct mem_cgroup_zone *mz,
+				      struct book *book,
 				      struct scan_control *sc,
 				      int priority,
 				      unsigned long *ret_nr_dirty,
@@ -803,7 +766,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(page_zone(page) != mz->zone);
+		VM_BUG_ON(page_zone(page) != book_zone(book));
 
 		sc->nr_scanned++;
 
@@ -1029,7 +992,7 @@ keep_lumpy:
 	 * will encounter the same problem
 	 */
 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
-		zone_set_flag(mz->zone, ZONE_CONGESTED);
+		zone_set_flag(book_zone(book), ZONE_CONGESTED);
 
 	free_hot_cold_page_list(&free_pages, 1);
 
@@ -1144,7 +1107,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
  * Appropriate locks must be held before calling this function.
  *
  * @nr_to_scan:	The number of pages to look through on the list.
- * @mz:		The mem_cgroup_zone to pull pages from.
+ * @book	The struct book to pull pages from.
  * @dst:	The temp list to put pages on to.
  * @nr_scanned:	The number of pages that were scanned.
  * @order:	The caller's attempted allocation order
@@ -1155,11 +1118,10 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
-		struct mem_cgroup_zone *mz, struct list_head *dst,
+		struct book *book, struct list_head *dst,
 		unsigned long *nr_scanned, int order, isolate_mode_t mode,
 		int active, int file)
 {
-	struct book *book;
 	struct list_head *src;
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1168,7 +1130,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long scan;
 	int lru = LRU_BASE;
 
-	book = mem_cgroup_zone_book(mz->zone, mz->mem_cgroup);
 	if (active)
 		lru += LRU_ACTIVE;
 	if (file)
@@ -1376,11 +1337,11 @@ static int too_many_isolated(struct zone *zone, int file,
 }
 
 static noinline_for_stack void
-putback_inactive_pages(struct mem_cgroup_zone *mz,
+putback_inactive_pages(struct book *book,
 		       struct list_head *page_list)
 {
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
-	struct zone *zone = mz->zone;
+	struct zone_reclaim_stat *reclaim_stat = &book->reclaim_stat;
+	struct zone *zone = book_zone(book);
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1427,13 +1388,13 @@ putback_inactive_pages(struct mem_cgroup_zone *mz,
 }
 
 static noinline_for_stack void
-update_isolated_counts(struct mem_cgroup_zone *mz,
+update_isolated_counts(struct book *book,
 		       struct list_head *page_list,
 		       unsigned long *nr_anon,
 		       unsigned long *nr_file)
 {
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
-	struct zone *zone = mz->zone;
+	struct zone_reclaim_stat *reclaim_stat = &book->reclaim_stat;
+	struct zone *zone = book_zone(book);
 	unsigned int count[NR_LRU_LISTS] = { 0, };
 	unsigned long nr_active = 0;
 	struct page *page;
@@ -1517,7 +1478,7 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
  * of reclaimed pages
  */
 static noinline_for_stack unsigned long
-shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
+shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 		     struct scan_control *sc, int priority, int file)
 {
 	LIST_HEAD(page_list);
@@ -1529,7 +1490,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
-	struct zone *zone = mz->zone;
+	struct zone *zone = book_zone(book);
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1552,7 +1513,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_lru_pages(nr_to_scan, mz, &page_list,
+	nr_taken = isolate_lru_pages(nr_to_scan, book, &page_list,
 				     &nr_scanned, sc->order,
 				     reclaim_mode, 0, file);
 	if (global_reclaim(sc)) {
@@ -1570,20 +1531,20 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 		return 0;
 	}
 
-	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);
+	update_isolated_counts(book, &page_list, &nr_anon, &nr_file);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
+	nr_reclaimed = shrink_page_list(&page_list, book, sc, priority,
 						&nr_dirty, &nr_writeback);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
+		nr_reclaimed += shrink_page_list(&page_list, book, sc,
 					priority, &nr_dirty, &nr_writeback);
 	}
 
@@ -1593,7 +1554,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_inactive_pages(mz, &page_list);
+	putback_inactive_pages(book, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
@@ -1708,7 +1669,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 }
 
 static void shrink_active_list(unsigned long nr_to_scan,
-			       struct mem_cgroup_zone *mz,
+			       struct book *book,
 			       struct scan_control *sc,
 			       int priority, int file)
 {
@@ -1719,10 +1680,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
 	struct page *page;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	struct zone_reclaim_stat *reclaim_stat = &book->reclaim_stat;
 	unsigned long nr_rotated = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_ACTIVE;
-	struct zone *zone = mz->zone;
+	struct zone *zone = book_zone(book);
 
 	lru_add_drain();
 
@@ -1733,7 +1694,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_lru_pages(nr_to_scan, mz, &l_hold,
+	nr_taken = isolate_lru_pages(nr_to_scan, book, &l_hold,
 				     &nr_scanned, sc->order,
 				     reclaim_mode, 1, file);
 	if (global_reclaim(sc))
@@ -1811,12 +1772,11 @@ static void shrink_active_list(unsigned long nr_to_scan,
  * Returns true if the zone does not have enough inactive anon pages,
  * meaning some active anon pages need to be deactivated.
  */
-static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
+static int inactive_anon_is_low(struct book *book,
 				struct scan_control *sc)
 {
 	unsigned long active, inactive;
 	unsigned int ratio;
-	struct book *book;
 
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -1826,18 +1786,17 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
 		return 0;
 
 	if (global_reclaim(sc))
-		ratio = mz->zone->inactive_ratio;
+		ratio = book_zone(book)->inactive_ratio;
 	else
 		ratio = mem_cgroup_inactive_ratio(sc->target_mem_cgroup);
 
-	book = mem_cgroup_zone_book(mz->zone, mz->mem_cgroup);
 	active = book->pages_count[NR_ACTIVE_ANON];
 	inactive = book->pages_count[NR_INACTIVE_ANON];
 
 	return inactive * ratio < active;
 }
 #else
-static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz,
+static inline int inactive_anon_is_low(struct book *book,
 				       struct scan_control *sc)
 {
 	return 0;
@@ -1858,40 +1817,38 @@ static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz,
  * This uses a different ratio than the anonymous pages, because
  * the page cache uses a use-once replacement algorithm.
  */
-static int inactive_file_is_low(struct mem_cgroup_zone *mz)
+static int inactive_file_is_low(struct book *book)
 {
 	unsigned long active, inactive;
-	struct book *book;
 
-	book = mem_cgroup_zone_book(mz->zone, mz->mem_cgroup);
 	active = book->pages_count[NR_ACTIVE_FILE];
 	inactive = book->pages_count[NR_INACTIVE_FILE];
 
 	return inactive < active;
 }
 
-static int inactive_list_is_low(struct mem_cgroup_zone *mz,
+static int inactive_list_is_low(struct book *book,
 				struct scan_control *sc, int file)
 {
 	if (file)
-		return inactive_file_is_low(mz);
+		return inactive_file_is_low(book);
 	else
-		return inactive_anon_is_low(mz, sc);
+		return inactive_anon_is_low(book, sc);
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-				 struct mem_cgroup_zone *mz,
+				 struct book *book,
 				 struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(mz, sc, file))
-			shrink_active_list(nr_to_scan, mz, sc, priority, file);
+		if (inactive_list_is_low(book, sc, file))
+			shrink_active_list(nr_to_scan, book, sc, priority, file);
 		return 0;
 	}
 
-	return shrink_inactive_list(nr_to_scan, mz, sc, priority, file);
+	return shrink_inactive_list(nr_to_scan, book, sc, priority, file);
 }
 
 static int vmscan_swappiness(struct scan_control *sc)
@@ -1909,17 +1866,18 @@ static int vmscan_swappiness(struct scan_control *sc)
  *
  * nr[0] = anon pages to scan; nr[1] = file pages to scan
  */
-static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
+static void get_scan_count(struct book *book, struct scan_control *sc,
 			   unsigned long *nr, int priority)
 {
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	struct zone_reclaim_stat *reclaim_stat = &book->reclaim_stat;
 	u64 fraction[2], denominator;
 	enum lru_list lru;
 	int noswap = 0;
 	bool force_scan = false;
+	struct zone *zone = book_zone(book);
 
 	/*
 	 * If the zone or memcg is small, nr[l] can be 0.  This
@@ -1931,7 +1889,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd() && mz->zone->all_unreclaimable)
+	if (current_is_kswapd() && zone->all_unreclaimable)
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
@@ -1945,16 +1903,16 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 		goto out;
 	}
 
-	anon  = zone_nr_lru_pages(mz, LRU_ACTIVE_ANON) +
-		zone_nr_lru_pages(mz, LRU_INACTIVE_ANON);
-	file  = zone_nr_lru_pages(mz, LRU_ACTIVE_FILE) +
-		zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
+	anon  = book->pages_count[LRU_ACTIVE_ANON] +
+		book->pages_count[LRU_INACTIVE_ANON];
+	file  = book->pages_count[LRU_ACTIVE_FILE] +
+		book->pages_count[LRU_INACTIVE_FILE];
 
 	if (global_reclaim(sc)) {
-		free  = zone_page_state(mz->zone, NR_FREE_PAGES);
+		free  = zone_page_state(zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
-		if (unlikely(file + free <= high_wmark_pages(mz->zone))) {
+		if (unlikely(file + free <= high_wmark_pages(zone))) {
 			fraction[0] = 1;
 			fraction[1] = 0;
 			denominator = 1;
@@ -1980,7 +1938,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&mz->zone->lru_lock);
+	spin_lock_irq(&zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -2001,7 +1959,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&mz->zone->lru_lock);
+	spin_unlock_irq(&zone->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -2011,7 +1969,7 @@ out:
 		int file = is_file_lru(lru);
 		unsigned long scan;
 
-		scan = zone_nr_lru_pages(mz, lru);
+		scan = book->pages_count[lru];
 		if (priority || noswap) {
 			scan >>= priority;
 			if (!scan && force_scan)
@@ -2029,7 +1987,7 @@ out:
  * back to the allocator and call try_to_compact_zone(), we ensure that
  * there are enough free pages for it to be likely successful
  */
-static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
+static inline bool should_continue_reclaim(struct book *book,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
 					struct scan_control *sc)
@@ -2069,15 +2027,15 @@ static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
+	inactive_lru_pages = book->pages_count[LRU_INACTIVE_FILE];
 	if (nr_swap_pages > 0)
-		inactive_lru_pages += zone_nr_lru_pages(mz, LRU_INACTIVE_ANON);
+		inactive_lru_pages += book->pages_count[LRU_INACTIVE_ANON];
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(mz->zone, sc->order)) {
+	switch (compaction_suitable(book_zone(book), sc->order)) {
 	case COMPACT_PARTIAL:
 	case COMPACT_CONTINUE:
 		return false;
@@ -2089,8 +2047,8 @@ static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
-				   struct scan_control *sc)
+static void shrink_book(int priority, struct book *book,
+			struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -2102,7 +2060,7 @@ static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
 restart:
 	nr_reclaimed = 0;
 	nr_scanned = sc->nr_scanned;
-	get_scan_count(mz, sc, nr, priority);
+	get_scan_count(book, sc, nr, priority);
 
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
@@ -2114,7 +2072,7 @@ restart:
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    mz, sc, priority);
+							    book, sc, priority);
 			}
 		}
 		/*
@@ -2135,11 +2093,11 @@ restart:
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(mz, sc))
-		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
+	if (inactive_anon_is_low(book, sc))
+		shrink_active_list(SWAP_CLUSTER_MAX, book, sc, priority, 0);
 
 	/* reclaim/compaction might need reclaim to continue */
-	if (should_continue_reclaim(mz, nr_reclaimed,
+	if (should_continue_reclaim(book, nr_reclaimed,
 					sc->nr_scanned - nr_scanned, sc))
 		goto restart;
 
@@ -2155,18 +2113,17 @@ static void shrink_zone(int priority, struct zone *zone,
 		.priority = priority,
 	};
 	struct mem_cgroup *memcg;
+	struct book *book;
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
-		struct mem_cgroup_zone mz = {
-			.mem_cgroup = memcg,
-			.zone = zone,
-		};
+		book = mem_cgroup_zone_book(zone, memcg);
 
 		if (!global_reclaim(sc))
 			sc->current_mem_cgroup = memcg;
 
-		shrink_mem_cgroup_zone(priority, &mz, sc);
+		shrink_book(priority, book, sc);
+
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -2483,10 +2440,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.target_mem_cgroup = memcg,
 		.current_mem_cgroup = memcg,
 	};
-	struct mem_cgroup_zone mz = {
-		.mem_cgroup = memcg,
-		.zone = zone,
-	};
+	struct book *book = mem_cgroup_zone_book(zone, memcg);
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2502,7 +2456,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_mem_cgroup_zone(0, &mz, &sc);
+	shrink_book(0, book, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2563,13 +2517,10 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc,
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct mem_cgroup_zone mz = {
-			.mem_cgroup = memcg,
-			.zone = zone,
-		};
+		struct book *book = mem_cgroup_zone_book(zone, memcg);
 
-		if (inactive_anon_is_low(&mz, sc))
-			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
+		if (inactive_anon_is_low(book, sc))
+			shrink_active_list(SWAP_CLUSTER_MAX, book,
 					   sc, priority, 0);
 
 		memcg = mem_cgroup_iter(NULL, memcg, NULL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
