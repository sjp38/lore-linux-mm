Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B77BB6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 16:26:04 -0500 (EST)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 08/10] mm: collect LRU list heads into struct lruvec
Date: Tue,  8 Nov 2011 22:23:26 +0100
Message-Id: <1320787408-22866-9-git-send-email-jweiner@redhat.com>
In-Reply-To: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
References: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Having a unified structure with a LRU list set for both global zones
and per-memcg zones allows to keep that code simple which deals with
LRU lists and does not care about the container itself.

Once the per-memcg LRU lists directly link struct pages, the isolation
function and all other list manipulations are shared between the memcg
case and the global LRU case.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/mm_inline.h |    2 +-
 include/linux/mmzone.h    |   10 ++++++----
 mm/memcontrol.c           |   17 +++++++----------
 mm/page_alloc.c           |    2 +-
 mm/swap.c                 |   11 +++++------
 mm/vmscan.c               |   10 +++++-----
 6 files changed, 25 insertions(+), 27 deletions(-)

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
index 188cb2f..9b97bed 100644
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
index bf84e2b..22f25b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -132,10 +132,7 @@ struct mem_cgroup_reclaim_iter {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
-	/*
-	 * spin_lock to protect the per cgroup LRU
-	 */
-	struct list_head	lists[NR_LRU_LISTS];
+	struct lruvec		lruvec;
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
@@ -995,7 +992,7 @@ void mem_cgroup_rotate_reclaimable_page(struct page *page)
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move_tail(&pc->lru, &mz->lists[lru]);
+	list_move_tail(&pc->lru, &mz->lruvec.lists[lru]);
 }
 
 void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
@@ -1013,7 +1010,7 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move(&pc->lru, &mz->lists[lru]);
+	list_move(&pc->lru, &mz->lruvec.lists[lru]);
 }
 
 void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
@@ -1043,7 +1040,7 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
 	SetPageCgroupAcctLRU(pc);
-	list_add(&pc->lru, &mz->lists[lru]);
+	list_add(&pc->lru, &mz->lruvec.lists[lru]);
 }
 
 /*
@@ -1241,7 +1238,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 
 	BUG_ON(!mem_cont);
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
-	src = &mz->lists[lru];
+	src = &mz->lruvec.lists[lru];
 
 	scan = 0;
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
@@ -3628,7 +3625,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	list = &mz->lists[lru];
+	list = &mz->lruvec.lists[lru];
 
 	loop = MEM_CGROUP_ZSTAT(mz, lru);
 	/* give some margin against EBUSY etc...*/
@@ -4724,7 +4721,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
-			INIT_LIST_HEAD(&mz->lists[l]);
+			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = memcg;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..9310f31 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4341,7 +4341,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone_pcp_init(zone);
 		for_each_lru(l)
-			INIT_LIST_HEAD(&zone->lru[l].list);
+			INIT_LIST_HEAD(&zone->lruvec.lists[l]);
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;
diff --git a/mm/swap.c b/mm/swap.c
index a91caf7..5de4443 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -236,7 +236,7 @@ static void pagevec_move_tail_fn(struct page *page, void *arg)
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		list_move_tail(&page->lru, &zone->lru[lru].list);
+		list_move_tail(&page->lru, &zone->lruvec.lists[lru]);
 		mem_cgroup_rotate_reclaimable_page(page);
 		(*pgmoved)++;
 	}
@@ -480,7 +480,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		list_move_tail(&page->lru, &zone->lru[lru].list);
+		list_move_tail(&page->lru, &zone->lruvec.lists[lru]);
 		mem_cgroup_rotate_reclaimable_page(page);
 		__count_vm_event(PGROTATED);
 	}
@@ -662,7 +662,6 @@ void lru_add_page_tail(struct zone* zone,
 	int active;
 	enum lru_list lru;
 	const int file = 0;
-	struct list_head *head;
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
@@ -682,10 +681,10 @@ void lru_add_page_tail(struct zone* zone,
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
index e214e02..174deff 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1262,8 +1262,8 @@ static unsigned long isolate_pages_global(unsigned long nr,
 		lru += LRU_ACTIVE;
 	if (file)
 		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, file);
+	return isolate_lru_pages(nr, &z->lruvec.lists[lru], dst,
+				 scanned, order, mode, file);
 }
 
 /*
@@ -1642,7 +1642,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		list_move(&page->lru, &zone->lru[lru].list);
+		list_move(&page->lru, &zone->lruvec.lists[lru]);
 		mem_cgroup_add_lru_list(page, lru);
 		pgmoved += hpage_nr_pages(page);
 
@@ -3459,7 +3459,7 @@ retry:
 		enum lru_list l = page_lru_base_type(page);
 
 		__dec_zone_state(zone, NR_UNEVICTABLE);
-		list_move(&page->lru, &zone->lru[l].list);
+		list_move(&page->lru, &zone->lruvec.lists[l]);
 		mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
@@ -3468,7 +3468,7 @@ retry:
 		 * rotate unevictable list
 		 */
 		SetPageUnevictable(page);
-		list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
+		list_move(&page->lru, &zone->lruvec.lists[LRU_UNEVICTABLE]);
 		mem_cgroup_rotate_lru_list(page, LRU_UNEVICTABLE);
 		if (page_evictable(page, NULL))
 			goto retry;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
