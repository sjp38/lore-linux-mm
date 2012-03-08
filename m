Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 5B7636B00E8
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 13:04:26 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id q16so787924bkw.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 10:04:25 -0800 (PST)
Subject: [PATCH v5 5/7] mm: rework reclaim_stat counters
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 08 Mar 2012 22:04:19 +0400
Message-ID: <20120308180419.27621.88710.stgit@zurg>
In-Reply-To: <20120308175752.27621.54781.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently there is two types of reclaim-stat counters:
recent_scanned (pages picked from from lru),
recent_rotated (pages putted back to active lru).
Reclaimer uses ratio recent_rotated / recent_scanned
for balancing pressure between file and anon pages.

But if we pick page from lru we can either reclaim it or put it back to lru, thus:
recent_scanned == recent_rotated[inactive] + recent_rotated[active] + reclaimed
This can be called "The Law of Conservation of Memory" =)

Thus recent_rotated counters for each lru list is enough, reclaimed pages can be
counted as rotatation into inactive lru. After that reclaimer can use this ratio:
recent_rotated[active] / (recent_rotated[active] + recent_rotated[inactive])

After this patch struct zone_reclaimer_stat has only one array: recent_rotated,
which is directly indexed by lru list index:

before patch:

LRU_ACTIVE_ANON   -> LRU_ACTIVE_ANON   : recent_scanned[ANON]++, recent_rotated[ANON]++
LRU_INACTIVE_ANON -> LRU_ACTIVE_ANON   : recent_scanned[ANON]++, recent_rotated[ANON]++
LRU_ACTIVE_ANON   -> LRU_INACTIVE_ANON : recent_scanned[ANON]++
LRU_INACTIVE_ANON -> LRU_INACTIVE_ANON : recent_scanned[ANON]++

after patch:

LRU_ACTIVE_ANON   -> LRU_ACTIVE_ANON   : recent_rotated[LRU_ACTIVE_ANON]++
LRU_INACTIVE_ANON -> LRU_ACTIVE_ANON   : recent_rotated[LRU_ACTIVE_ANON]++
LRU_ACTIVE_ANON   -> LRU_INACTIVE_ANON : recent_rotated[LRU_INACTIVE_ANON]++
LRU_INACTIVE_ANON -> LRU_INACTIVE_ANON : recent_rotated[LRU_INACTIVE_ANON]++

recent_scanned[ANON] === recent_rotated[LRU_ACTIVE_ANON] + recent_rotated[LRU_INACTIVE_ANON]
recent_rotated[ANON] === recent_rotated[LRU_ACTIVE_ANON]

(and the same for FILE/LRU_ACTIVE_FILE/LRU_INACTIVE_FILE)

v5:
* resolve conflict with "memcg: fix GPF when cgroup removal races with last exit"

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

add/remove: 0/0 grow/shrink: 3/8 up/down: 32/-135 (-103)
function                                     old     new   delta
shrink_mem_cgroup_zone                      1507    1526     +19
free_area_init_node                          852     862     +10
put_page_testzero                             30      33      +3
mem_control_stat_show                        754     750      -4
putback_inactive_pages                       635     629      -6
lru_add_page_tail                            364     349     -15
__pagevec_lru_add_fn                         266     249     -17
lru_deactivate_fn                            500     482     -18
__activate_page                              365     347     -18
update_page_reclaim_stat                      89      64     -25
static.shrink_active_list                    853     821     -32
---
 include/linux/mmzone.h |   11 +++++------
 mm/memcontrol.c        |   29 +++++++++++++++++------------
 mm/page_alloc.c        |    6 ++----
 mm/swap.c              |   29 ++++++++++-------------------
 mm/vmscan.c            |   42 ++++++++++++++++++++++--------------------
 5 files changed, 56 insertions(+), 61 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3370a8c..6d40cc8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -137,12 +137,14 @@ enum lru_list {
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
 	LRU_UNEVICTABLE,
-	NR_LRU_LISTS
+	NR_LRU_LISTS,
+	NR_EVICTABLE_LRU_LISTS = LRU_UNEVICTABLE,
 };
 
 #define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
 
-#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
+#define for_each_evictable_lru(lru) \
+	for (lru = 0; lru < NR_EVICTABLE_LRU_LISTS; lru++)
 
 static inline int is_file_lru(enum lru_list lru)
 {
@@ -165,11 +167,8 @@ struct zone_reclaim_stat {
 	 * mem/swap backed and file backed pages are refeferenced.
 	 * The higher the rotated/scanned ratio, the more valuable
 	 * that cache is.
-	 *
-	 * The anon LRU stats live in [0], file LRU stats in [1]
 	 */
-	unsigned long		recent_rotated[2];
-	unsigned long		recent_scanned[2];
+	unsigned long		recent_rotated[NR_EVICTABLE_LRU_LISTS];
 };
 
 struct lruvec {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6864f57..02af4a6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4183,26 +4183,31 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 
 #ifdef CONFIG_DEBUG_VM
 	{
-		int nid, zid;
+		int nid, zid, lru;
 		struct mem_cgroup_per_zone *mz;
 		struct zone_reclaim_stat *rstat;
-		unsigned long recent_rotated[2] = {0, 0};
-		unsigned long recent_scanned[2] = {0, 0};
+		unsigned long recent_rotated[NR_EVICTABLE_LRU_LISTS];
 
+		memset(recent_rotated, 0, sizeof(recent_rotated));
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 				rstat = &mz->lruvec.reclaim_stat;
-
-				recent_rotated[0] += rstat->recent_rotated[0];
-				recent_rotated[1] += rstat->recent_rotated[1];
-				recent_scanned[0] += rstat->recent_scanned[0];
-				recent_scanned[1] += rstat->recent_scanned[1];
+				for_each_evictable_lru(lru)
+					recent_rotated[lru] +=
+						rstat->recent_rotated[lru];
 			}
-		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
-		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
-		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
-		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
+
+		cb->fill(cb, "recent_rotated_anon",
+				recent_rotated[LRU_ACTIVE_ANON]);
+		cb->fill(cb, "recent_rotated_file",
+				recent_rotated[LRU_ACTIVE_FILE]);
+		cb->fill(cb, "recent_scanned_anon",
+				recent_rotated[LRU_ACTIVE_ANON] +
+				recent_rotated[LRU_INACTIVE_ANON]);
+		cb->fill(cb, "recent_scanned_file",
+				recent_rotated[LRU_ACTIVE_FILE] +
+				recent_rotated[LRU_INACTIVE_FILE]);
 	}
 #endif
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ab2d210..ea40034 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4365,10 +4365,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_pcp_init(zone);
 		for_each_lru(lru)
 			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
-		zone->lruvec.reclaim_stat.recent_rotated[0] = 0;
-		zone->lruvec.reclaim_stat.recent_rotated[1] = 0;
-		zone->lruvec.reclaim_stat.recent_scanned[0] = 0;
-		zone->lruvec.reclaim_stat.recent_scanned[1] = 0;
+		memset(&zone->lruvec.reclaim_stat, 0,
+				sizeof(struct zone_reclaim_stat));
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
diff --git a/mm/swap.c b/mm/swap.c
index 60d14da..9051079 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -277,7 +277,7 @@ void rotate_reclaimable_page(struct page *page)
 }
 
 static void update_page_reclaim_stat(struct zone *zone, struct page *page,
-				     int file, int rotated)
+				     enum lru_list lru)
 {
 	struct zone_reclaim_stat *reclaim_stat;
 
@@ -285,9 +285,7 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
 	if (!reclaim_stat)
 		reclaim_stat = &zone->lruvec.reclaim_stat;
 
-	reclaim_stat->recent_scanned[file]++;
-	if (rotated)
-		reclaim_stat->recent_rotated[file]++;
+	reclaim_stat->recent_rotated[lru]++;
 }
 
 static void __activate_page(struct page *page, void *arg)
@@ -295,7 +293,6 @@ static void __activate_page(struct page *page, void *arg)
 	struct zone *zone = page_zone(page);
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
 		del_page_from_lru_list(zone, page, lru);
 
@@ -304,7 +301,7 @@ static void __activate_page(struct page *page, void *arg)
 		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
 
-		update_page_reclaim_stat(zone, page, file, 1);
+		update_page_reclaim_stat(zone, page, lru);
 	}
 }
 
@@ -482,7 +479,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
-	update_page_reclaim_stat(zone, page, file, 0);
+	update_page_reclaim_stat(zone, page, lru);
 }
 
 /*
@@ -646,9 +643,7 @@ EXPORT_SYMBOL(__pagevec_release);
 void lru_add_page_tail(struct zone* zone,
 		       struct page *page, struct page *page_tail)
 {
-	int uninitialized_var(active);
 	enum lru_list lru;
-	const int file = 0;
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
@@ -660,12 +655,9 @@ void lru_add_page_tail(struct zone* zone,
 	if (page_evictable(page_tail, NULL)) {
 		if (PageActive(page)) {
 			SetPageActive(page_tail);
-			active = 1;
 			lru = LRU_ACTIVE_ANON;
-		} else {
-			active = 0;
+		} else
 			lru = LRU_INACTIVE_ANON;
-		}
 	} else {
 		SetPageUnevictable(page_tail);
 		lru = LRU_UNEVICTABLE;
@@ -687,8 +679,8 @@ void lru_add_page_tail(struct zone* zone,
 		list_move_tail(&page_tail->lru, list_head);
 	}
 
-	if (!PageUnevictable(page))
-		update_page_reclaim_stat(zone, page_tail, file, active);
+	if (!is_unevictable_lru(lru))
+		update_page_reclaim_stat(zone, page_tail, lru);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
@@ -696,18 +688,17 @@ static void __pagevec_lru_add_fn(struct page *page, void *arg)
 {
 	enum lru_list lru = (enum lru_list)arg;
 	struct zone *zone = page_zone(page);
-	int file = is_file_lru(lru);
-	int active = is_active_lru(lru);
 
 	VM_BUG_ON(PageActive(page));
 	VM_BUG_ON(PageUnevictable(page));
 	VM_BUG_ON(PageLRU(page));
 
 	SetPageLRU(page);
-	if (active)
+	if (is_active_lru(lru))
 		SetPageActive(page);
+
 	add_page_to_lru_list(zone, page, lru);
-	update_page_reclaim_stat(zone, page, file, active);
+	update_page_reclaim_stat(zone, page, lru);
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0966f11..ab5c0f6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1348,11 +1348,7 @@ putback_inactive_pages(struct mem_cgroup_zone *mz,
 		SetPageLRU(page);
 		lru = page_lru(page);
 		add_page_to_lru_list(zone, page, lru);
-		if (is_active_lru(lru)) {
-			int file = is_file_lru(lru);
-			int numpages = hpage_nr_pages(page);
-			reclaim_stat->recent_rotated[file] += numpages;
-		}
+		reclaim_stat->recent_rotated[lru] += hpage_nr_pages(page);
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
@@ -1533,8 +1529,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	spin_lock_irq(&zone->lru_lock);
 
-	reclaim_stat->recent_scanned[0] += nr_anon;
-	reclaim_stat->recent_scanned[1] += nr_file;
+	/*
+	 * Count reclaimed pages as rotated, this helps balance scan pressure
+	 * between file and anonymous pages in get_scan_ratio.
+	 */
+	reclaim_stat->recent_rotated[lru] += nr_reclaimed;
 
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
@@ -1672,8 +1671,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (global_reclaim(sc))
 		zone->pages_scanned += nr_scanned;
 
-	reclaim_stat->recent_scanned[file] += nr_taken;
-
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
@@ -1728,7 +1725,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 * helps balance scan pressure between file and anonymous pages in
 	 * get_scan_ratio.
 	 */
-	reclaim_stat->recent_rotated[file] += nr_rotated;
+	reclaim_stat->recent_rotated[lru] += nr_rotated;
 
 	move_active_pages_to_lru(zone, &l_active, &l_hold, lru);
 	move_active_pages_to_lru(zone, &l_inactive, &l_hold, lru - LRU_ACTIVE);
@@ -1861,6 +1858,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	unsigned long *recent_rotated = reclaim_stat->recent_rotated;
 	u64 fraction[2], denominator;
 	enum lru_list lru;
 	int noswap = 0;
@@ -1926,14 +1924,16 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 * anon in [0], file in [1]
 	 */
 	spin_lock_irq(&mz->zone->lru_lock);
-	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
-		reclaim_stat->recent_scanned[0] /= 2;
-		reclaim_stat->recent_rotated[0] /= 2;
+	if (unlikely(recent_rotated[LRU_INACTIVE_ANON] +
+		     recent_rotated[LRU_ACTIVE_ANON] > anon / 4)) {
+		recent_rotated[LRU_INACTIVE_ANON] /= 2;
+		recent_rotated[LRU_ACTIVE_ANON] /= 2;
 	}
 
-	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
-		reclaim_stat->recent_scanned[1] /= 2;
-		reclaim_stat->recent_rotated[1] /= 2;
+	if (unlikely(recent_rotated[LRU_INACTIVE_FILE] +
+		     recent_rotated[LRU_ACTIVE_FILE] > file / 4)) {
+		recent_rotated[LRU_INACTIVE_FILE] /= 2;
+		recent_rotated[LRU_ACTIVE_FILE] /= 2;
 	}
 
 	/*
@@ -1941,11 +1941,13 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 * proportional to the fraction of recently scanned pages on
 	 * each list that were recently referenced and in active use.
 	 */
-	ap = (anon_prio + 1) * (reclaim_stat->recent_scanned[0] + 1);
-	ap /= reclaim_stat->recent_rotated[0] + 1;
+	ap = (anon_prio + 1) * (recent_rotated[LRU_INACTIVE_ANON] +
+				recent_rotated[LRU_ACTIVE_ANON] + 1);
+	ap /= recent_rotated[LRU_ACTIVE_ANON] + 1;
 
-	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
-	fp /= reclaim_stat->recent_rotated[1] + 1;
+	fp = (file_prio + 1) * (recent_rotated[LRU_INACTIVE_FILE] +
+				recent_rotated[LRU_ACTIVE_FILE] + 1);
+	fp /= recent_rotated[LRU_ACTIVE_FILE] + 1;
 	spin_unlock_irq(&mz->zone->lru_lock);
 
 	fraction[0] = ap;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
