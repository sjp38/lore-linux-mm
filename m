Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 56A286B0101
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:31:10 -0500 (EST)
Received: by dadv6 with SMTP id v6so7617058dad.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:31:09 -0800 (PST)
Date: Mon, 20 Feb 2012 15:30:45 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/10] mm/memcg: add zone pointer into lruvec
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201529450.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The lruvec is looking rather useful: if we just add a zone pointer
into the lruvec, then we can pass the lruvec pointer around and save
some superfluous arguments and recomputations in various places.

Just occasionally we do want mem_cgroup_from_lruvec() to get back from
lruvec to memcg; but then we can remove all uses of vmscan.c's private
mem_cgroup_zone *mz, passing the lruvec pointer instead.

And while we're there, get_scan_count() can call vmscan_swappiness()
once, instead of twice in a row.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |   23 ++-
 include/linux/mmzone.h     |    1 
 mm/memcontrol.c            |   47 ++++----
 mm/page_alloc.c            |    1 
 mm/vmscan.c                |  203 +++++++++++++++--------------------
 5 files changed, 128 insertions(+), 147 deletions(-)

--- mmotm.orig/include/linux/memcontrol.h	2012-02-18 11:57:20.391524062 -0800
+++ mmotm/include/linux/memcontrol.h	2012-02-18 11:57:28.371524252 -0800
@@ -63,6 +63,7 @@ extern int mem_cgroup_cache_charge(struc
 					gfp_t gfp_mask);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+extern struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec);
 struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
 				       enum lru_list);
 void mem_cgroup_lru_del_list(struct page *, enum lru_list);
@@ -113,13 +114,11 @@ void mem_cgroup_iter_break(struct mem_cg
 /*
  * For memory reclaim.
  */
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
-				    struct zone *zone);
+int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec);
+int mem_cgroup_inactive_file_is_low(struct lruvec *lruvec);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
-unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
-					int nid, int zid, unsigned int lrumask);
+unsigned long mem_cgroup_zone_nr_lru_pages(struct lruvec *lruvec,
+					   unsigned int lrumask);
 struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
@@ -249,6 +248,11 @@ static inline struct lruvec *mem_cgroup_
 	return &zone->lruvec;
 }
 
+static inline struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec)
+{
+	return NULL;
+}
+
 static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
 						     struct page *page,
 						     enum lru_list lru)
@@ -331,20 +335,19 @@ static inline bool mem_cgroup_disabled(v
 }
 
 static inline int
-mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
+mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
 	return 1;
 }
 
 static inline int
-mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
+mem_cgroup_inactive_file_is_low(struct lruvec *lruvec)
 {
 	return 1;
 }
 
 static inline unsigned long
-mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
-				unsigned int lru_mask)
+mem_cgroup_zone_nr_lru_pages(struct lruvec *lruvec, unsigned int lru_mask)
 {
 	return 0;
 }
--- mmotm.orig/include/linux/mmzone.h	2012-02-18 11:57:20.391524062 -0800
+++ mmotm/include/linux/mmzone.h	2012-02-18 11:57:28.371524252 -0800
@@ -173,6 +173,7 @@ struct zone_reclaim_stat {
 };
 
 struct lruvec {
+	struct zone *zone;
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
 };
--- mmotm.orig/mm/memcontrol.c	2012-02-18 11:57:20.391524062 -0800
+++ mmotm/mm/memcontrol.c	2012-02-18 11:57:28.371524252 -0800
@@ -703,14 +703,13 @@ static void mem_cgroup_charge_statistics
 }
 
 unsigned long
-mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
-			unsigned int lru_mask)
+mem_cgroup_zone_nr_lru_pages(struct lruvec *lruvec, unsigned int lru_mask)
 {
 	struct mem_cgroup_per_zone *mz;
 	enum lru_list lru;
 	unsigned long ret = 0;
 
-	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
 
 	for_each_lru(lru) {
 		if (BIT(lru) & lru_mask)
@@ -723,12 +722,14 @@ static unsigned long
 mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 			int nid, unsigned int lru_mask)
 {
+	struct mem_cgroup_per_zone *mz;
 	u64 total = 0;
 	int zid;
 
-	for (zid = 0; zid < MAX_NR_ZONES; zid++)
-		total += mem_cgroup_zone_nr_lru_pages(memcg,
-						nid, zid, lru_mask);
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+		total += mem_cgroup_zone_nr_lru_pages(&mz->lruvec, lru_mask);
+	}
 
 	return total;
 }
@@ -1003,13 +1004,24 @@ struct lruvec *mem_cgroup_zone_lruvec(st
 {
 	struct mem_cgroup_per_zone *mz;
 
-	if (mem_cgroup_disabled())
+	if (!memcg || mem_cgroup_disabled())
 		return &zone->lruvec;
 
 	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
 	return &mz->lruvec;
 }
 
+struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec)
+{
+	struct mem_cgroup_per_zone *mz;
+
+	if (mem_cgroup_disabled())
+		return NULL;
+
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	return mz->memcg;
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -1161,19 +1173,15 @@ int task_in_mem_cgroup(struct task_struc
 	return ret;
 }
 
-int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
+int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
 	unsigned long inactive_ratio;
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
 	unsigned long inactive;
 	unsigned long active;
 	unsigned long gb;
 
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_ANON));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_ANON));
+	inactive = mem_cgroup_zone_nr_lru_pages(lruvec, BIT(LRU_INACTIVE_ANON));
+	active = mem_cgroup_zone_nr_lru_pages(lruvec, BIT(LRU_ACTIVE_ANON));
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -1184,17 +1192,13 @@ int mem_cgroup_inactive_anon_is_low(stru
 	return inactive * inactive_ratio < active;
 }
 
-int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *zone)
+int mem_cgroup_inactive_file_is_low(struct lruvec *lruvec)
 {
 	unsigned long active;
 	unsigned long inactive;
-	int zid = zone_idx(zone);
-	int nid = zone_to_nid(zone);
 
-	inactive = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-						BIT(LRU_INACTIVE_FILE));
-	active = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
-					      BIT(LRU_ACTIVE_FILE));
+	inactive = mem_cgroup_zone_nr_lru_pages(lruvec, BIT(LRU_INACTIVE_FILE));
+	active = mem_cgroup_zone_nr_lru_pages(lruvec, BIT(LRU_ACTIVE_FILE));
 
 	return (active > inactive);
 }
@@ -4755,6 +4759,7 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
+		mz->lruvec.zone = &NODE_DATA(node)->node_zones[zone];
 		for_each_lru(lru)
 			INIT_LIST_HEAD(&mz->lruvec.lists[lru]);
 		mz->usage_in_excess = 0;
--- mmotm.orig/mm/page_alloc.c	2012-02-18 11:57:20.395524062 -0800
+++ mmotm/mm/page_alloc.c	2012-02-18 11:57:28.375524252 -0800
@@ -4365,6 +4365,7 @@ static void __paginginit free_area_init_
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
+		zone->lruvec.zone = zone;
 		for_each_lru(lru)
 			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
 		zone->lruvec.reclaim_stat.recent_rotated[0] = 0;
--- mmotm.orig/mm/vmscan.c	2012-02-18 11:57:20.395524062 -0800
+++ mmotm/mm/vmscan.c	2012-02-18 11:57:28.375524252 -0800
@@ -115,11 +115,6 @@ struct scan_control {
 	nodemask_t	*nodemask;
 };
 
-struct mem_cgroup_zone {
-	struct mem_cgroup *mem_cgroup;
-	struct zone *zone;
-};
-
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 #ifdef ARCH_HAS_PREFETCH
@@ -171,21 +166,12 @@ static bool global_reclaim(struct scan_c
 }
 #endif
 
-static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
-{
-	return &mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup)->reclaim_stat;
-}
-
-static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,
-				       enum lru_list lru)
+static unsigned long zone_nr_lru_pages(struct lruvec *lruvec, enum lru_list lru)
 {
 	if (!mem_cgroup_disabled())
-		return mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-						    zone_to_nid(mz->zone),
-						    zone_idx(mz->zone),
-						    BIT(lru));
+		return mem_cgroup_zone_nr_lru_pages(lruvec, BIT(lru));
 
-	return zone_page_state(mz->zone, NR_LRU_BASE + lru);
+	return zone_page_state(lruvec->zone, NR_LRU_BASE + lru);
 }
 
 
@@ -688,13 +674,13 @@ enum page_references {
 };
 
 static enum page_references page_check_references(struct page *page,
-						  struct mem_cgroup_zone *mz,
+						  struct mem_cgroup *memcg,
 						  struct scan_control *sc)
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
 
-	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
+	referenced_ptes = page_referenced(page, 1, memcg, &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
@@ -750,12 +736,13 @@ static enum page_references page_check_r
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct mem_cgroup_zone *mz,
+				      struct lruvec *lruvec,
 				      struct scan_control *sc,
 				      int priority,
 				      unsigned long *ret_nr_dirty,
 				      unsigned long *ret_nr_writeback)
 {
+	struct mem_cgroup *memcg = mem_cgroup_from_lruvec(lruvec);
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
@@ -781,7 +768,7 @@ static unsigned long shrink_page_list(st
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(page_zone(page) != mz->zone);
+		VM_BUG_ON(page_zone(page) != lruvec->zone);
 
 		sc->nr_scanned++;
 
@@ -815,7 +802,7 @@ static unsigned long shrink_page_list(st
 			}
 		}
 
-		references = page_check_references(page, mz, sc);
+		references = page_check_references(page, memcg, sc);
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
@@ -1007,7 +994,7 @@ keep_lumpy:
 	 * will encounter the same problem
 	 */
 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
-		zone_set_flag(mz->zone, ZONE_CONGESTED);
+		zone_set_flag(lruvec->zone, ZONE_CONGESTED);
 
 	free_hot_cold_page_list(&free_pages, 1);
 
@@ -1122,7 +1109,7 @@ int __isolate_lru_page(struct page *page
  * Appropriate locks must be held before calling this function.
  *
  * @nr_to_scan:	The number of pages to look through on the list.
- * @mz:		The mem_cgroup_zone to pull pages from.
+ * @lruvec:	The mem_cgroup/zone lruvec to pull pages from.
  * @dst:	The temp list to put pages on to.
  * @nr_scanned:	The number of pages that were scanned.
  * @sc:		The scan_control struct for this reclaim session
@@ -1133,11 +1120,10 @@ int __isolate_lru_page(struct page *page
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
-		struct mem_cgroup_zone *mz, struct list_head *dst,
+		struct lruvec *lruvec, struct list_head *dst,
 		unsigned long *nr_scanned, struct scan_control *sc,
 		isolate_mode_t mode, int active, int file)
 {
-	struct lruvec *lruvec;
 	struct list_head *src;
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1146,7 +1132,6 @@ static unsigned long isolate_lru_pages(u
 	unsigned long scan;
 	int lru = LRU_BASE;
 
-	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
 	if (active)
 		lru += LRU_ACTIVE;
 	if (file)
@@ -1344,11 +1329,10 @@ static int too_many_isolated(struct zone
 }
 
 static noinline_for_stack void
-putback_inactive_pages(struct mem_cgroup_zone *mz,
-		       struct list_head *page_list)
+putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 {
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
-	struct zone *zone = mz->zone;
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	struct zone *zone = lruvec->zone;
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1395,12 +1379,9 @@ putback_inactive_pages(struct mem_cgroup
 }
 
 static noinline_for_stack void
-update_isolated_counts(struct mem_cgroup_zone *mz,
-		       struct list_head *page_list,
-		       unsigned long *nr_anon,
-		       unsigned long *nr_file)
+update_isolated_counts(struct zone *zone, struct list_head *page_list,
+		       unsigned long *nr_anon, unsigned long *nr_file)
 {
-	struct zone *zone = mz->zone;
 	unsigned int count[NR_LRU_LISTS] = { 0, };
 	unsigned long nr_active = 0;
 	struct page *page;
@@ -1486,9 +1467,11 @@ static inline bool should_reclaim_stall(
  * of reclaimed pages
  */
 static noinline_for_stack unsigned long
-shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
+shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		     struct scan_control *sc, int priority, int file)
 {
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	struct zone *zone = lruvec->zone;
 	LIST_HEAD(page_list);
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
@@ -1498,8 +1481,6 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t isolate_mode = ISOLATE_INACTIVE;
-	struct zone *zone = mz->zone;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1522,31 +1503,29 @@ shrink_inactive_list(unsigned long nr_to
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_lru_pages(nr_to_scan, mz, &page_list, &nr_scanned,
-				     sc, isolate_mode, 0, file);
+	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
+				     &nr_scanned, sc, isolate_mode, 0, file);
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
-			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
-					       nr_scanned);
+			__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scanned);
 		else
-			__count_zone_vm_events(PGSCAN_DIRECT, zone,
-					       nr_scanned);
+			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 
 	if (nr_taken == 0)
 		return 0;
 
-	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);
+	update_isolated_counts(zone, &page_list, &nr_anon, &nr_file);
 
-	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
+	nr_reclaimed = shrink_page_list(&page_list, lruvec, sc, priority,
 						&nr_dirty, &nr_writeback);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
+		nr_reclaimed += shrink_page_list(&page_list, lruvec, sc,
 					priority, &nr_dirty, &nr_writeback);
 	}
 
@@ -1559,7 +1538,7 @@ shrink_inactive_list(unsigned long nr_to
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_inactive_pages(mz, &page_list);
+	putback_inactive_pages(lruvec, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
@@ -1659,10 +1638,13 @@ static void move_active_pages_to_lru(str
 }
 
 static void shrink_active_list(unsigned long nr_to_scan,
-			       struct mem_cgroup_zone *mz,
+			       struct lruvec *lruvec,
 			       struct scan_control *sc,
 			       int priority, int file)
 {
+	struct mem_cgroup *memcg = mem_cgroup_from_lruvec(lruvec);
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	struct zone *zone = lruvec->zone;
 	unsigned long nr_taken;
 	unsigned long nr_scanned;
 	unsigned long vm_flags;
@@ -1670,10 +1652,8 @@ static void shrink_active_list(unsigned
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
 	struct page *page;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	unsigned long nr_rotated = 0;
 	isolate_mode_t isolate_mode = ISOLATE_ACTIVE;
-	struct zone *zone = mz->zone;
 
 	lru_add_drain();
 
@@ -1684,8 +1664,8 @@ static void shrink_active_list(unsigned
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_lru_pages(nr_to_scan, mz, &l_hold, &nr_scanned, sc,
-				     isolate_mode, 1, file);
+	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
+				     &nr_scanned, sc, isolate_mode, 1, file);
 	if (global_reclaim(sc))
 		zone->pages_scanned += nr_scanned;
 
@@ -1717,7 +1697,7 @@ static void shrink_active_list(unsigned
 			}
 		}
 
-		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags)) {
+		if (page_referenced(page, 0, memcg, &vm_flags)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
@@ -1776,13 +1756,12 @@ static int inactive_anon_is_low_global(s
 
 /**
  * inactive_anon_is_low - check if anonymous pages need to be deactivated
- * @zone: zone to check
- * @sc:   scan control of this context
+ * @lruvec: The mem_cgroup/zone lruvec to check
  *
  * Returns true if the zone does not have enough inactive anon pages,
  * meaning some active anon pages need to be deactivated.
  */
-static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
+static int inactive_anon_is_low(struct lruvec *lruvec)
 {
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -1792,13 +1771,12 @@ static int inactive_anon_is_low(struct m
 		return 0;
 
 	if (!mem_cgroup_disabled())
-		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
-						       mz->zone);
+		return mem_cgroup_inactive_anon_is_low(lruvec);
 
-	return inactive_anon_is_low_global(mz->zone);
+	return inactive_anon_is_low_global(lruvec->zone);
 }
 #else
-static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz)
+static inline int inactive_anon_is_low(struct lruvec *lruvec)
 {
 	return 0;
 }
@@ -1816,7 +1794,7 @@ static int inactive_file_is_low_global(s
 
 /**
  * inactive_file_is_low - check if file pages need to be deactivated
- * @mz: memory cgroup and zone to check
+ * @lruvec: The mem_cgroup/zone lruvec to check
  *
  * When the system is doing streaming IO, memory pressure here
  * ensures that active file pages get deactivated, until more
@@ -1828,44 +1806,44 @@ static int inactive_file_is_low_global(s
  * This uses a different ratio than the anonymous pages, because
  * the page cache uses a use-once replacement algorithm.
  */
-static int inactive_file_is_low(struct mem_cgroup_zone *mz)
+static int inactive_file_is_low(struct lruvec *lruvec)
 {
 	if (!mem_cgroup_disabled())
-		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
-						       mz->zone);
+		return mem_cgroup_inactive_file_is_low(lruvec);
 
-	return inactive_file_is_low_global(mz->zone);
+	return inactive_file_is_low_global(lruvec->zone);
 }
 
-static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
+static int inactive_list_is_low(struct lruvec *lruvec, int file)
 {
 	if (file)
-		return inactive_file_is_low(mz);
+		return inactive_file_is_low(lruvec);
 	else
-		return inactive_anon_is_low(mz);
+		return inactive_anon_is_low(lruvec);
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-				 struct mem_cgroup_zone *mz,
+				 struct lruvec *lruvec,
 				 struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(mz, file))
-			shrink_active_list(nr_to_scan, mz, sc, priority, file);
+		if (inactive_list_is_low(lruvec, file))
+			shrink_active_list(nr_to_scan, lruvec, sc, priority,
+									file);
 		return 0;
 	}
 
-	return shrink_inactive_list(nr_to_scan, mz, sc, priority, file);
+	return shrink_inactive_list(nr_to_scan, lruvec, sc, priority, file);
 }
 
-static int vmscan_swappiness(struct mem_cgroup_zone *mz,
+static int vmscan_swappiness(struct lruvec *lruvec,
 			     struct scan_control *sc)
 {
 	if (global_reclaim(sc))
 		return vm_swappiness;
-	return mem_cgroup_swappiness(mz->mem_cgroup);
+	return mem_cgroup_swappiness(mem_cgroup_from_lruvec(lruvec));
 }
 
 /*
@@ -1876,13 +1854,14 @@ static int vmscan_swappiness(struct mem_
  *
  * nr[0] = anon pages to scan; nr[1] = file pages to scan
  */
-static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
+static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 			   unsigned long *nr, int priority)
 {
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	struct zone *zone = lruvec->zone;
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	u64 fraction[2], denominator;
 	enum lru_list lru;
 	int noswap = 0;
@@ -1898,7 +1877,7 @@ static void get_scan_count(struct mem_cg
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd() && mz->zone->all_unreclaimable)
+	if (current_is_kswapd() && zone->all_unreclaimable)
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
@@ -1912,16 +1891,16 @@ static void get_scan_count(struct mem_cg
 		goto out;
 	}
 
-	anon  = zone_nr_lru_pages(mz, LRU_ACTIVE_ANON) +
-		zone_nr_lru_pages(mz, LRU_INACTIVE_ANON);
-	file  = zone_nr_lru_pages(mz, LRU_ACTIVE_FILE) +
-		zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
+	anon  = zone_nr_lru_pages(lruvec, LRU_ACTIVE_ANON) +
+		zone_nr_lru_pages(lruvec, LRU_INACTIVE_ANON);
+	file  = zone_nr_lru_pages(lruvec, LRU_ACTIVE_FILE) +
+		zone_nr_lru_pages(lruvec, LRU_INACTIVE_FILE);
 
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
@@ -1933,8 +1912,8 @@ static void get_scan_count(struct mem_cg
 	 * With swappiness at 100, anonymous and file have the same priority.
 	 * This scanning priority is essentially the inverse of IO cost.
 	 */
-	anon_prio = vmscan_swappiness(mz, sc);
-	file_prio = 200 - vmscan_swappiness(mz, sc);
+	anon_prio = vmscan_swappiness(lruvec, sc);
+	file_prio = 200 - anon_prio;
 
 	/*
 	 * OK, so we have swap space and a fair amount of page cache
@@ -1947,7 +1926,7 @@ static void get_scan_count(struct mem_cg
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&mz->zone->lru_lock);
+	spin_lock_irq(&zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1968,7 +1947,7 @@ static void get_scan_count(struct mem_cg
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&mz->zone->lru_lock);
+	spin_unlock_irq(&zone->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -1978,7 +1957,7 @@ out:
 		int file = is_file_lru(lru);
 		unsigned long scan;
 
-		scan = zone_nr_lru_pages(mz, lru);
+		scan = zone_nr_lru_pages(lruvec, lru);
 		if (priority || noswap) {
 			scan >>= priority;
 			if (!scan && force_scan)
@@ -1996,7 +1975,7 @@ out:
  * back to the allocator and call try_to_compact_zone(), we ensure that
  * there are enough free pages for it to be likely successful
  */
-static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
+static inline bool should_continue_reclaim(struct lruvec *lruvec,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
 					struct scan_control *sc)
@@ -2036,15 +2015,16 @@ static inline bool should_continue_recla
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
+	inactive_lru_pages = zone_nr_lru_pages(lruvec, LRU_INACTIVE_FILE);
 	if (nr_swap_pages > 0)
-		inactive_lru_pages += zone_nr_lru_pages(mz, LRU_INACTIVE_ANON);
+		inactive_lru_pages += zone_nr_lru_pages(lruvec,
+							LRU_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(mz->zone, sc->order)) {
+	switch (compaction_suitable(lruvec->zone, sc->order)) {
 	case COMPACT_PARTIAL:
 	case COMPACT_CONTINUE:
 		return false;
@@ -2056,7 +2036,7 @@ static inline bool should_continue_recla
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
+static void shrink_mem_cgroup_zone(int priority, struct lruvec *lruvec,
 				   struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
@@ -2069,7 +2049,7 @@ static void shrink_mem_cgroup_zone(int p
 restart:
 	nr_reclaimed = 0;
 	nr_scanned = sc->nr_scanned;
-	get_scan_count(mz, sc, nr, priority);
+	get_scan_count(lruvec, sc, nr, priority);
 
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
@@ -2081,7 +2061,7 @@ restart:
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    mz, sc, priority);
+							lruvec, sc, priority);
 			}
 		}
 		/*
@@ -2107,11 +2087,11 @@ restart:
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(mz))
-		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
+	if (inactive_anon_is_low(lruvec))
+		shrink_active_list(SWAP_CLUSTER_MAX, lruvec, sc, priority, 0);
 
 	/* reclaim/compaction might need reclaim to continue */
-	if (should_continue_reclaim(mz, nr_reclaimed,
+	if (should_continue_reclaim(lruvec, nr_reclaimed,
 					sc->nr_scanned - nr_scanned, sc))
 		goto restart;
 
@@ -2130,12 +2110,9 @@ static void shrink_zone(int priority, st
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
-		struct mem_cgroup_zone mz = {
-			.mem_cgroup = memcg,
-			.zone = zone,
-		};
+		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-		shrink_mem_cgroup_zone(priority, &mz, sc);
+		shrink_mem_cgroup_zone(priority, lruvec, sc);
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -2463,10 +2440,7 @@ unsigned long mem_cgroup_shrink_node_zon
 		.order = 0,
 		.target_mem_cgroup = memcg,
 	};
-	struct mem_cgroup_zone mz = {
-		.mem_cgroup = memcg,
-		.zone = zone,
-	};
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2482,7 +2456,7 @@ unsigned long mem_cgroup_shrink_node_zon
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_mem_cgroup_zone(0, &mz, &sc);
+	shrink_mem_cgroup_zone(0, lruvec, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2543,13 +2517,10 @@ static void age_active_anon(struct zone
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct mem_cgroup_zone mz = {
-			.mem_cgroup = memcg,
-			.zone = zone,
-		};
+		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-		if (inactive_anon_is_low(&mz))
-			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
+		if (inactive_anon_is_low(lruvec))
+			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, priority, 0);
 
 		memcg = mem_cgroup_iter(NULL, memcg, NULL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
