Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3A4196B00E7
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:56:31 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so2948567bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:56:30 -0700 (PDT)
Subject: [PATCH v6 3/7] mm: push lru index into shrink_[in]active_list()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 23 Mar 2012 01:56:27 +0400
Message-ID: <20120322215627.27814.4499.stgit@zurg>
In-Reply-To: <20120322214944.27814.42039.stgit@zurg>
References: <20120322214944.27814.42039.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Let's toss lru index through call stack to isolate_lru_pages(),
this is better than its reconstructing from individual bits.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c |   41 +++++++++++++++++------------------------
 1 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f4dca0c..fb6d54e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1127,15 +1127,14 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
  * @nr_scanned:	The number of pages that were scanned.
  * @sc:		The scan_control struct for this reclaim session
  * @mode:	One of the LRU isolation modes
- * @active:	True [1] if isolating active pages
- * @file:	True [1] if isolating file [!anon] pages
+ * @lru		LRU list id for isolating
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct mem_cgroup_zone *mz, struct list_head *dst,
 		unsigned long *nr_scanned, struct scan_control *sc,
-		isolate_mode_t mode, int active, int file)
+		isolate_mode_t mode, enum lru_list lru)
 {
 	struct lruvec *lruvec;
 	struct list_head *src;
@@ -1144,13 +1143,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_lumpy_dirty = 0;
 	unsigned long nr_lumpy_failed = 0;
 	unsigned long scan;
-	int lru = LRU_BASE;
+	int file = is_file_lru(lru);
 
 	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
-	if (active)
-		lru += LRU_ACTIVE;
-	if (file)
-		lru += LRU_FILE;
 	src = &lruvec->lists[lru];
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
@@ -1487,7 +1482,7 @@ static inline bool should_reclaim_stall(unsigned long nr_taken,
  */
 static noinline_for_stack unsigned long
 shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
-		     struct scan_control *sc, int priority, int file)
+		     struct scan_control *sc, int priority, enum lru_list lru)
 {
 	LIST_HEAD(page_list);
 	unsigned long nr_scanned;
@@ -1498,6 +1493,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t isolate_mode = ISOLATE_INACTIVE;
+	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 
@@ -1523,7 +1519,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	spin_lock_irq(&zone->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, mz, &page_list, &nr_scanned,
-				     sc, isolate_mode, 0, file);
+				     sc, isolate_mode, lru);
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1661,7 +1657,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 static void shrink_active_list(unsigned long nr_to_scan,
 			       struct mem_cgroup_zone *mz,
 			       struct scan_control *sc,
-			       int priority, int file)
+			       int priority, enum lru_list lru)
 {
 	unsigned long nr_taken;
 	unsigned long nr_scanned;
@@ -1673,6 +1669,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	unsigned long nr_rotated = 0;
 	isolate_mode_t isolate_mode = ISOLATE_ACTIVE;
+	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
 
 	lru_add_drain();
@@ -1687,17 +1684,14 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	spin_lock_irq(&zone->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, mz, &l_hold, &nr_scanned, sc,
-				     isolate_mode, 1, file);
+				     isolate_mode, lru);
 	if (global_reclaim(sc))
 		zone->pages_scanned += nr_scanned;
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
-	if (file)
-		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
-	else
-		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
@@ -1752,10 +1746,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(zone, &l_active, &l_hold,
-						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive, &l_hold,
-						LRU_BASE   + file * LRU_FILE);
+	move_active_pages_to_lru(zone, &l_active, &l_hold, lru);
+	move_active_pages_to_lru(zone, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
@@ -1855,11 +1847,11 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 
 	if (is_active_lru(lru)) {
 		if (inactive_list_is_low(mz, file))
-			shrink_active_list(nr_to_scan, mz, sc, priority, file);
+			shrink_active_list(nr_to_scan, mz, sc, priority, lru);
 		return 0;
 	}
 
-	return shrink_inactive_list(nr_to_scan, mz, sc, priority, file);
+	return shrink_inactive_list(nr_to_scan, mz, sc, priority, lru);
 }
 
 static int vmscan_swappiness(struct mem_cgroup_zone *mz,
@@ -2110,7 +2102,8 @@ restart:
 	 * rebalance the anon lru active/inactive ratio.
 	 */
 	if (inactive_anon_is_low(mz))
-		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
+		shrink_active_list(SWAP_CLUSTER_MAX, mz,
+				   sc, priority, LRU_ACTIVE_ANON);
 
 	/* reclaim/compaction might need reclaim to continue */
 	if (should_continue_reclaim(mz, nr_reclaimed,
@@ -2550,7 +2543,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc,
 
 		if (inactive_anon_is_low(&mz))
 			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
-					   sc, priority, 0);
+					   sc, priority, LRU_ACTIVE_ANON);
 
 		memcg = mem_cgroup_iter(NULL, memcg, NULL);
 	} while (memcg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
