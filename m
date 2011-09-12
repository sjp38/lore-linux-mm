Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 69E2F6B0279
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:27 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 09/11] mm: collect LRU list heads into struct lruvec
Date: Mon, 12 Sep 2011 12:57:26 +0200
Message-Id: <1315825048-3437-10-git-send-email-jweiner@redhat.com>
In-Reply-To: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Having a unified structure with a LRU list set for both global zones
and per-memcg zones allows to keep that code simple which deals with
LRU lists and does not care about the container itself.

Once the per-memcg LRU lists directly link struct pages, the isolation
function and all other list manipulations are shared between the memcg
case and the global LRU case.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 include/linux/mm_inline.h |    2 +-
 include/linux/mmzone.h    |   10 ++++++----
 mm/memcontrol.c           |   19 ++++++++-----------
 mm/page_alloc.c           |    2 +-
 mm/swap.c                 |   11 +++++------
 mm/vmscan.c               |   12 ++++++------
 6 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 8f7d247..e6a7ffe 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -33,7 +33,7 @@ __add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
-	__add_page_to_lru_list(zone, page, l, &zone->lru[l].list);
+	__add_page_to_lru_list(zone, page, l, &zone->lruvec.lists[l]);
 }
 
 static inline void
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1ed4116..37970b9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -159,6 +159,10 @@ static inline int is_unevictable_lru(enum lru_list l)
 	return (l == LRU_UNEVICTABLE);
 }
 
+struct lruvec {
+	struct list_head lists[NR_LRU_LISTS];
+};
+
 /* Mask used at gathering information at once (see memcontrol.c) */
 #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
@@ -358,10 +362,8 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;	
-	struct zone_lru {
-		struct list_head list;
-	} lru[NR_LRU_LISTS];
+	spinlock_t		lru_lock;
+	struct lruvec		lruvec;
 
 	struct zone_reclaim_stat reclaim_stat;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 27d78dc..465001c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -130,10 +130,7 @@ struct mem_cgroup_iter_state {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
-	/*
-	 * spin_lock to protect the per cgroup LRU
-	 */
-	struct list_head	lists[NR_LRU_LISTS];
+	struct lruvec		lruvec;
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct mem_cgroup_iter_state iter_state[DEF_PRIORITY + 1];
@@ -944,7 +941,7 @@ struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup *mem,
 	struct page_cgroup *pc;
 
 	mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
-	pc = list_entry(mz->lists[lru].prev, struct page_cgroup, lru);
+	pc = list_entry(mz->lruvec.lists[lru].prev, struct page_cgroup, lru);
 	return lookup_cgroup_page(pc);
 }
 
@@ -997,7 +994,7 @@ void mem_cgroup_rotate_reclaimable_page(struct page *page)
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move_tail(&pc->lru, &mz->lists[lru]);
+	list_move_tail(&pc->lru, &mz->lruvec.lists[lru]);
 }
 
 void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
@@ -1015,7 +1012,7 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move(&pc->lru, &mz->lists[lru]);
+	list_move(&pc->lru, &mz->lruvec.lists[lru]);
 }
 
 void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
@@ -1045,7 +1042,7 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
 	SetPageCgroupAcctLRU(pc);
-	list_add(&pc->lru, &mz->lists[lru]);
+	list_add(&pc->lru, &mz->lruvec.lists[lru]);
 }
 
 /*
@@ -1243,7 +1240,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 
 	BUG_ON(!mem_cont);
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
-	src = &mz->lists[lru];
+	src = &mz->lruvec.lists[lru];
 
 	scan = 0;
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
@@ -3627,7 +3624,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	list = &mz->lists[lru];
+	list = &mz->lruvec.lists[lru];
 
 	loop = MEM_CGROUP_ZSTAT(mz, lru);
 	/* give some margin against EBUSY etc...*/
@@ -4723,7 +4720,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
-			INIT_LIST_HEAD(&mz->lists[l]);
+			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = memcg;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1dba05e..33b25b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4335,7 +4335,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone_pcp_init(zone);
 		for_each_lru(l)
-			INIT_LIST_HEAD(&zone->lru[l].list);
+			INIT_LIST_HEAD(&zone->lruvec.lists[l]);
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..66e8292 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -213,7 +213,7 @@ static void pagevec_move_tail_fn(struct page *page, void *arg)
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		list_move_tail(&page->lru, &zone->lru[lru].list);
+		list_move_tail(&page->lru, &zone->lruvec.lists[lru]);
 		mem_cgroup_rotate_reclaimable_page(page);
 		(*pgmoved)++;
 	}
@@ -457,7 +457,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		list_move_tail(&page->lru, &zone->lru[lru].list);
+		list_move_tail(&page->lru, &zone->lruvec.lists[lru]);
 		mem_cgroup_rotate_reclaimable_page(page);
 		__count_vm_event(PGROTATED);
 	}
@@ -639,7 +639,6 @@ void lru_add_page_tail(struct zone* zone,
 	int active;
 	enum lru_list lru;
 	const int file = 0;
-	struct list_head *head;
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
@@ -659,10 +658,10 @@ void lru_add_page_tail(struct zone* zone,
 		}
 		update_page_reclaim_stat(zone, page_tail, file, active);
 		if (likely(PageLRU(page)))
-			head = page->lru.prev;
+			__add_page_to_lru_list(zone, page_tail, lru,
+					       page->lru.prev);
 		else
-			head = &zone->lru[lru].list;
-		__add_page_to_lru_list(zone, page_tail, lru, head);
+			add_page_to_lru_list(zone, page_tail, lru);
 	} else {
 		SetPageUnevictable(page_tail);
 		add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 053609e..df00195 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1267,8 +1267,8 @@ static unsigned long isolate_pages_global(unsigned long nr,
 		lru += LRU_ACTIVE;
 	if (file)
 		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, file);
+	return isolate_lru_pages(nr, &z->lruvec.lists[lru], dst,
+				 scanned, order, mode, file);
 }
 
 /*
@@ -1631,7 +1631,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		list_move(&page->lru, &zone->lru[lru].list);
+		list_move(&page->lru, &zone->lruvec.lists[lru]);
 		mem_cgroup_add_lru_list(page, lru);
 		pgmoved += hpage_nr_pages(page);
 
@@ -3411,7 +3411,7 @@ retry:
 		enum lru_list l = page_lru_base_type(page);
 
 		__dec_zone_state(zone, NR_UNEVICTABLE);
-		list_move(&page->lru, &zone->lru[l].list);
+		list_move(&page->lru, &zone->lruvec.lists[l]);
 		mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
@@ -3420,7 +3420,7 @@ retry:
 		 * rotate unevictable list
 		 */
 		SetPageUnevictable(page);
-		list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
+		list_move(&page->lru, &zone->lruvec.lists[LRU_UNEVICTABLE]);
 		mem_cgroup_rotate_lru_list(page, LRU_UNEVICTABLE);
 		if (page_evictable(page, NULL))
 			goto retry;
@@ -3490,7 +3490,7 @@ static struct page *lru_tailpage(struct mem_cgroup_zone *mz, enum lru_list lru)
 {
 	if (!scanning_global_lru(mz))
 		return mem_cgroup_lru_to_page(mz->zone, mz->mem_cgroup, lru);
-	return lru_to_page(&mz->zone->lru[lru].list);
+	return lru_to_page(&mz->zone->lruvec.lists[lru]);
 }
 
 /**
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
