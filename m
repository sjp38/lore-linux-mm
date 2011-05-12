Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D128900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:54:50 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc patch 5/6] memcg: remove global LRU list
Date: Thu, 12 May 2011 16:53:57 +0200
Message-Id: <1305212038-15445-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since the VM now has means to do global reclaim from the per-memcg lru
lists, the global LRU list is no longer required.

It saves two linked list pointers per page, since all pages are now
only on one list.  Also, the memcg lru lists now directly link pages
instead of page_cgroup descriptors, which gets rid of finding the way
back from the page_cgroup to the page.

A big change in behaviour is that pages are no longer aged on a global
level.  Instead, they are aged with respect to the other pages in the
same memcg, where the aging speed is determined by global memory
pressure and size of the memcg itself.

[ TO EVALUATE: this should bring more fairness to reclaim in setups
with differently sized memcgs, and distribute pressure proportionally
among memcgs instead of reclaiming only from the one that has the
oldest pages on a global level.  There is potential unfairness if
unused pages are hiding in small memcgs that are never scanned and
reclaim going only for a single, much bigger memcg.  The severeness of
this also scales with the number of memcgs wrt amount of physical
memory, so it again boils down to the question of what the sane
maximum number of memcgs on the system is ].

The patch introduces an lruvec structure that exists for both global
zones and for each zone per memcg.  All lru operations are now done in
generic code, with the memcg lru primitives only doing accounting and
returning the proper lruvec for the currently scanned memcg on
isolation, or for the respective page on putback.

The code that scans and rescues unevictable pages in a specific zone
had to be converted to iterate over all memcgs as well.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h  |   52 ++++-----
 include/linux/mm_inline.h   |   15 ++-
 include/linux/mmzone.h      |   10 +-
 include/linux/page_cgroup.h |   35 ------
 mm/memcontrol.c             |  251 +++++++++++++++---------------------------
 mm/page_alloc.c             |    2 +-
 mm/page_cgroup.c            |   39 +------
 mm/swap.c                   |   20 ++--
 mm/vmscan.c                 |  149 ++++++++++++--------------
 9 files changed, 213 insertions(+), 360 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a4c84db..65163c2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -20,6 +20,7 @@
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
 #include <linux/cgroup.h>
+#include <linux/mmzone.h>
 struct mem_cgroup;
 struct page_cgroup;
 struct page;
@@ -30,13 +31,6 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
 };
 
-extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
-					struct list_head *dst,
-					unsigned long *scanned, int order,
-					int mode, struct zone *z,
-					struct mem_cgroup *mem_cont,
-					int active, int file);
-
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -60,13 +54,13 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
-extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
-extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru(struct page *page);
-extern void mem_cgroup_move_lists(struct page *page,
-				  enum lru_list from, enum lru_list to);
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
+				       enum lru_list);
+void mem_cgroup_lru_del_list(struct zone *, struct page *, enum lru_list);
+void mem_cgroup_lru_del(struct zone *, struct page *);
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
+					 enum lru_list, enum lru_list);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -210,33 +204,35 @@ static inline int mem_cgroup_shmem_charge_fallback(struct page *page,
 	return 0;
 }
 
-static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
+static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
+						    struct mem_cgroup *mem)
 {
+	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
+static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
+						     struct page *page,
+						     enum lru_list lru)
 {
-	return ;
+	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
+static inline void mem_cgroup_lru_del_list(struct zone *zone,
+					   struct page *page,
+					   enum lru_list lru)
 {
-	return ;
 }
 
-static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
+static inline void mem_cgroup_lru_del(struct zone *zone, struct page *page)
 {
-	return ;
 }
 
-static inline void mem_cgroup_del_lru(struct page *page)
-{
-	return ;
-}
-
-static inline void
-mem_cgroup_move_lists(struct page *page, enum lru_list from, enum lru_list to)
+static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
+						       struct page *page,
+						       enum lru_list from,
+						       enum lru_list to)
 {
+	return &zone->lruvec;
 }
 
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 8f7d247..ca794f3 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -25,23 +25,28 @@ static inline void
 __add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
 		       struct list_head *head)
 {
+	/* NOTE! Caller must ensure @head is on the right lruvec! */
+	mem_cgroup_lru_add_list(zone, page, l);
 	list_add(&page->lru, head);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
-	mem_cgroup_add_lru_list(page, l);
 }
 
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
-	__add_page_to_lru_list(zone, page, l, &zone->lru[l].list);
+	struct lruvec *lruvec;
+
+	lruvec = mem_cgroup_lru_add_list(zone, page, l);
+	list_add(&page->lru, &lruvec->lists[l]);
+	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
 }
 
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
+	mem_cgroup_lru_del_list(zone, page, l);
 	list_del(&page->lru);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
-	mem_cgroup_del_lru_list(page, l);
 }
 
 /**
@@ -64,7 +69,6 @@ del_page_from_lru(struct zone *zone, struct page *page)
 {
 	enum lru_list l;
 
-	list_del(&page->lru);
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
 		l = LRU_UNEVICTABLE;
@@ -75,8 +79,9 @@ del_page_from_lru(struct zone *zone, struct page *page)
 			l += LRU_ACTIVE;
 		}
 	}
+	mem_cgroup_lru_del_list(zone, page, l);
+	list_del(&page->lru);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
-	mem_cgroup_del_lru_list(page, l);
 }
 
 /**
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e56f835..c2ddce5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -158,6 +158,10 @@ static inline int is_unevictable_lru(enum lru_list l)
 	return (l == LRU_UNEVICTABLE);
 }
 
+struct lruvec {
+	struct list_head lists[NR_LRU_LISTS];
+};
+
 enum zone_watermarks {
 	WMARK_MIN,
 	WMARK_LOW,
@@ -344,10 +348,8 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;	
-	struct zone_lru {
-		struct list_head list;
-	} lru[NR_LRU_LISTS];
+	spinlock_t		lru_lock;
+	struct lruvec		lruvec;
 
 	struct zone_reclaim_stat reclaim_stat;
 
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 961ecc7..2e7cbc5 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -31,7 +31,6 @@ enum {
 struct page_cgroup {
 	unsigned long flags;
 	struct mem_cgroup *mem_cgroup;
-	struct list_head lru;		/* per cgroup LRU list */
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
@@ -49,7 +48,6 @@ static inline void __init page_cgroup_init(void)
 #endif
 
 struct page_cgroup *lookup_page_cgroup(struct page *page);
-struct page *lookup_cgroup_page(struct page_cgroup *pc);
 
 #define TESTPCGFLAG(uname, lname)			\
 static inline int PageCgroup##uname(struct page_cgroup *pc)	\
@@ -122,39 +120,6 @@ static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
 	local_irq_restore(*flags);
 }
 
-#ifdef CONFIG_SPARSEMEM
-#define PCG_ARRAYID_WIDTH	SECTIONS_SHIFT
-#else
-#define PCG_ARRAYID_WIDTH	NODES_SHIFT
-#endif
-
-#if (PCG_ARRAYID_WIDTH > BITS_PER_LONG - NR_PCG_FLAGS)
-#error Not enough space left in pc->flags to store page_cgroup array IDs
-#endif
-
-/* pc->flags: ARRAY-ID | FLAGS */
-
-#define PCG_ARRAYID_MASK	((1UL << PCG_ARRAYID_WIDTH) - 1)
-
-#define PCG_ARRAYID_OFFSET	(BITS_PER_LONG - PCG_ARRAYID_WIDTH)
-/*
- * Zero the shift count for non-existent fields, to prevent compiler
- * warnings and ensure references are optimized away.
- */
-#define PCG_ARRAYID_SHIFT	(PCG_ARRAYID_OFFSET * (PCG_ARRAYID_WIDTH != 0))
-
-static inline void set_page_cgroup_array_id(struct page_cgroup *pc,
-					    unsigned long id)
-{
-	pc->flags &= ~(PCG_ARRAYID_MASK << PCG_ARRAYID_SHIFT);
-	pc->flags |= (id & PCG_ARRAYID_MASK) << PCG_ARRAYID_SHIFT;
-}
-
-static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)
-{
-	return (pc->flags >> PCG_ARRAYID_SHIFT) & PCG_ARRAYID_MASK;
-}
-
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d762706..f5d90ba 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -134,10 +134,7 @@ struct mem_cgroup_stat_cpu {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
-	/*
-	 * spin_lock to protect the per cgroup LRU
-	 */
-	struct list_head	lists[NR_LRU_LISTS];
+	struct lruvec		lruvec;
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
@@ -834,6 +831,24 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 	return (mem == root_mem_cgroup);
 }
 
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone, struct mem_cgroup *mem)
+{
+	struct mem_cgroup_per_zone *mz;
+	int nid, zid;
+
+	/* Pages are on the zone's own lru lists */
+	if (mem_cgroup_disabled())
+		return &zone->lruvec;
+
+	if (!mem)
+		mem = root_mem_cgroup;
+
+	nid = zone_to_nid(zone);
+	zid = zone_idx(zone);
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	return &mz->lruvec;
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -848,10 +863,43 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
  * When moving account, the page is not on LRU. It's isolated.
  */
 
-void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
+struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
+				       enum lru_list lru)
 {
+	struct mem_cgroup_per_zone *mz;
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+
+	if (mem_cgroup_disabled())
+		return &zone->lruvec;
+
+	pc = lookup_page_cgroup(page);
+	VM_BUG_ON(PageCgroupAcctLRU(pc));
+	if (PageCgroupUsed(pc)) {
+		/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+		smp_rmb();
+		mem = pc->mem_cgroup;
+	} else {
+		/*
+		 * If the page is uncharged, add it to the root's lru.
+		 * Either it will be freed soon, or it will get
+		 * charged again and the charger will relink it to the
+		 * right list.
+		 */
+		mem = root_mem_cgroup;
+	}
+	mz = page_cgroup_zoneinfo(mem, page);
+	/* huge page split is done under lru_lock. so, we have no races. */
+	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
+	SetPageCgroupAcctLRU(pc);
+	return &mz->lruvec;
+}
+
+void mem_cgroup_lru_del_list(struct zone *zone, struct page *page,
+			     enum lru_list lru)
+{
 	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
 
 	if (mem_cgroup_disabled())
 		return;
@@ -867,83 +915,21 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
-	VM_BUG_ON(list_empty(&pc->lru));
-	list_del_init(&pc->lru);
 }
 
-void mem_cgroup_del_lru(struct page *page)
+void mem_cgroup_lru_del(struct zone *zone, struct page *page)
 {
-	mem_cgroup_del_lru_list(page, page_lru(page));
+	mem_cgroup_lru_del_list(zone, page, page_lru(page));
 }
 
-/*
- * Writeback is about to end against a page which has been marked for immediate
- * reclaim.  If it still appears to be reclaimable, move it to the tail of the
- * inactive list.
- */
-void mem_cgroup_rotate_reclaimable_page(struct page *page)
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
+					 struct page *page,
+					 enum lru_list from,
+					 enum lru_list to)
 {
-	struct mem_cgroup_per_zone *mz;
-	struct page_cgroup *pc;
-	enum lru_list lru = page_lru(page);
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(page);
-	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move_tail(&pc->lru, &mz->lists[lru]);
-}
-
-void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(page);
-	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move(&pc->lru, &mz->lists[lru]);
-}
-
-void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
-{
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
-
-	if (mem_cgroup_disabled())
-		return;
-	pc = lookup_page_cgroup(page);
-	VM_BUG_ON(PageCgroupAcctLRU(pc));
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	/* huge page split is done under lru_lock. so, we have no races. */
-	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
-	SetPageCgroupAcctLRU(pc);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
-		return;
-	list_add(&pc->lru, &mz->lists[lru]);
+	/* TODO: could be optimized, especially if from == to */
+	mem_cgroup_lru_del_list(zone, page, from);
+	return mem_cgroup_lru_add_list(zone, page, to);
 }
 
 /*
@@ -975,7 +961,7 @@ static void mem_cgroup_lru_del_before_commit(struct page *page)
 	 * is guarded by lock_page() because the page is SwapCache.
 	 */
 	if (!PageCgroupUsed(pc))
-		mem_cgroup_del_lru_list(page, page_lru(page));
+		del_page_from_lru(zone, page);
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
@@ -989,22 +975,11 @@ static void mem_cgroup_lru_add_after_commit(struct page *page)
 	if (likely(!PageLRU(page)))
 		return;
 	spin_lock_irqsave(&zone->lru_lock, flags);
-	/* link when the page is linked to LRU but page_cgroup isn't */
 	if (PageLRU(page) && !PageCgroupAcctLRU(pc))
-		mem_cgroup_add_lru_list(page, page_lru(page));
+		add_page_to_lru_list(zone, page, page_lru(page));
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
-
-void mem_cgroup_move_lists(struct page *page,
-			   enum lru_list from, enum lru_list to)
-{
-	if (mem_cgroup_disabled())
-		return;
-	mem_cgroup_del_lru_list(page, from);
-	mem_cgroup_add_lru_list(page, to);
-}
-
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 {
 	int ret;
@@ -1063,6 +1038,9 @@ int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
 	unsigned long present_pages[2];
 	unsigned long inactive_ratio;
 
+	if (!memcg)
+		memcg = root_mem_cgroup;
+
 	inactive_ratio = calc_inactive_ratio(memcg, present_pages);
 
 	inactive = present_pages[0];
@@ -1079,6 +1057,9 @@ int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
 	unsigned long active;
 	unsigned long inactive;
 
+	if (!memcg)
+		memcg = root_mem_cgroup;
+
 	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
 	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
 
@@ -1091,8 +1072,12 @@ unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 {
 	int nid = zone_to_nid(zone);
 	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+	struct mem_cgroup_per_zone *mz;
+
+	if (!memcg)
+		memcg = root_mem_cgroup;
 
+	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
@@ -1101,8 +1086,12 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 {
 	int nid = zone_to_nid(zone);
 	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+	struct mem_cgroup_per_zone *mz;
+
+	if (!memcg)
+		memcg = root_mem_cgroup;
 
+	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 	return &mz->reclaim_stat;
 }
 
@@ -1124,67 +1113,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return &mz->reclaim_stat;
 }
 
-unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
-					struct list_head *dst,
-					unsigned long *scanned, int order,
-					int mode, struct zone *z,
-					struct mem_cgroup *mem_cont,
-					int active, int file)
-{
-	unsigned long nr_taken = 0;
-	struct page *page;
-	unsigned long scan;
-	LIST_HEAD(pc_list);
-	struct list_head *src;
-	struct page_cgroup *pc, *tmp;
-	int nid = zone_to_nid(z);
-	int zid = zone_idx(z);
-	struct mem_cgroup_per_zone *mz;
-	int lru = LRU_FILE * file + active;
-	int ret;
-
-	BUG_ON(!mem_cont);
-	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
-	src = &mz->lists[lru];
-
-	scan = 0;
-	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
-		if (scan >= nr_to_scan)
-			break;
-
-		if (unlikely(!PageCgroupUsed(pc)))
-			continue;
-
-		page = lookup_cgroup_page(pc);
-
-		if (unlikely(!PageLRU(page)))
-			continue;
-
-		scan++;
-		ret = __isolate_lru_page(page, mode, file);
-		switch (ret) {
-		case 0:
-			list_move(&page->lru, dst);
-			mem_cgroup_del_lru(page);
-			nr_taken += hpage_nr_pages(page);
-			break;
-		case -EBUSY:
-			/* we don't affect global LRU but rotate in our LRU */
-			mem_cgroup_rotate_lru_list(page, page_lru(page));
-			break;
-		default:
-			break;
-		}
-	}
-
-	*scanned = scan;
-
-	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
-				      0, 0, 0, mode);
-
-	return nr_taken;
-}
-
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -3458,22 +3386,23 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 				int node, int zid, enum lru_list lru)
 {
-	struct zone *zone;
 	struct mem_cgroup_per_zone *mz;
-	struct page_cgroup *pc, *busy;
 	unsigned long flags, loop;
 	struct list_head *list;
+	struct page *busy;
+	struct zone *zone;
 	int ret = 0;
 
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(mem, node, zid);
-	list = &mz->lists[lru];
+	list = &mz->lruvec.lists[lru];
 
 	loop = MEM_CGROUP_ZSTAT(mz, lru);
 	/* give some margin against EBUSY etc...*/
 	loop += 256;
 	busy = NULL;
 	while (loop--) {
+		struct page_cgroup *pc;
 		struct page *page;
 
 		ret = 0;
@@ -3482,16 +3411,16 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			break;
 		}
-		pc = list_entry(list->prev, struct page_cgroup, lru);
-		if (busy == pc) {
-			list_move(&pc->lru, list);
+		page = list_entry(list->prev, struct page, lru);
+		if (busy == page) {
+			list_move(&page->lru, list);
 			busy = NULL;
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			continue;
 		}
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-		page = lookup_cgroup_page(pc);
+		pc = lookup_page_cgroup(page);
 
 		ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
 		if (ret == -ENOMEM)
@@ -3499,7 +3428,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 
 		if (ret == -EBUSY || ret == -EINVAL) {
 			/* found lock contention or "pc" is obsolete. */
-			busy = pc;
+			busy = page;
 			cond_resched();
 		} else
 			busy = NULL;
@@ -4519,7 +4448,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
-			INIT_LIST_HEAD(&mz->lists[l]);
+			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = mem;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9f8a97b..4099e8c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4262,7 +4262,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone_pcp_init(zone);
 		for_each_lru(l) {
-			INIT_LIST_HEAD(&zone->lru[l].list);
+			INIT_LIST_HEAD(&zone->lruvec.lists[l]);
 			zone->reclaim_stat.nr_saved_scan[l] = 0;
 		}
 		zone->reclaim_stat.recent_rotated[0] = 0;
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 9905501..313e1d7 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -11,12 +11,10 @@
 #include <linux/swapops.h>
 #include <linux/kmemleak.h>
 
-static void __meminit init_page_cgroup(struct page_cgroup *pc, unsigned long id)
+static void __meminit init_page_cgroup(struct page_cgroup *pc)
 {
 	pc->flags = 0;
-	set_page_cgroup_array_id(pc, id);
 	pc->mem_cgroup = NULL;
-	INIT_LIST_HEAD(&pc->lru);
 }
 static unsigned long total_usage;
 
@@ -42,19 +40,6 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return base + offset;
 }
 
-struct page *lookup_cgroup_page(struct page_cgroup *pc)
-{
-	unsigned long pfn;
-	struct page *page;
-	pg_data_t *pgdat;
-
-	pgdat = NODE_DATA(page_cgroup_array_id(pc));
-	pfn = pc - pgdat->node_page_cgroup + pgdat->node_start_pfn;
-	page = pfn_to_page(pfn);
-	VM_BUG_ON(pc != lookup_page_cgroup(page));
-	return page;
-}
-
 static int __init alloc_node_page_cgroup(int nid)
 {
 	struct page_cgroup *base, *pc;
@@ -75,7 +60,7 @@ static int __init alloc_node_page_cgroup(int nid)
 		return -ENOMEM;
 	for (index = 0; index < nr_pages; index++) {
 		pc = base + index;
-		init_page_cgroup(pc, nid);
+		init_page_cgroup(pc);
 	}
 	NODE_DATA(nid)->node_page_cgroup = base;
 	total_usage += table_size;
@@ -117,19 +102,6 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return section->page_cgroup + pfn;
 }
 
-struct page *lookup_cgroup_page(struct page_cgroup *pc)
-{
-	struct mem_section *section;
-	struct page *page;
-	unsigned long nr;
-
-	nr = page_cgroup_array_id(pc);
-	section = __nr_to_section(nr);
-	page = pfn_to_page(pc - section->page_cgroup);
-	VM_BUG_ON(pc != lookup_page_cgroup(page));
-	return page;
-}
-
 static void *__init_refok alloc_page_cgroup(size_t size, int nid)
 {
 	void *addr = NULL;
@@ -167,12 +139,9 @@ static int __init_refok init_section_page_cgroup(unsigned long pfn)
 	struct page_cgroup *base, *pc;
 	struct mem_section *section;
 	unsigned long table_size;
-	unsigned long nr;
 	int nid, index;
 
-	nr = pfn_to_section_nr(pfn);
-	section = __nr_to_section(nr);
-
+	section = __pfn_to_section(pfn);
 	if (section->page_cgroup)
 		return 0;
 
@@ -194,7 +163,7 @@ static int __init_refok init_section_page_cgroup(unsigned long pfn)
 
 	for (index = 0; index < PAGES_PER_SECTION; index++) {
 		pc = base + index;
-		init_page_cgroup(pc, nr);
+		init_page_cgroup(pc);
 	}
 
 	section->page_cgroup = base - pfn;
diff --git a/mm/swap.c b/mm/swap.c
index a448db3..12095a0 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -209,12 +209,14 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 static void pagevec_move_tail_fn(struct page *page, void *arg)
 {
 	int *pgmoved = arg;
-	struct zone *zone = page_zone(page);
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		list_move_tail(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_rotate_reclaimable_page(page);
+		struct lruvec *lruvec;
+
+		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
+						   page, lru, lru);
+		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		(*pgmoved)++;
 	}
 }
@@ -417,12 +419,13 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 */
 		SetPageReclaim(page);
 	} else {
+		struct lruvec *lruvec;
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		list_move_tail(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_rotate_reclaimable_page(page);
+		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
+		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		__count_vm_event(PGROTATED);
 	}
 
@@ -594,7 +597,6 @@ void lru_add_page_tail(struct zone* zone,
 	int active;
 	enum lru_list lru;
 	const int file = 0;
-	struct list_head *head;
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
@@ -614,10 +616,10 @@ void lru_add_page_tail(struct zone* zone,
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
index 0e45ceb..0381a5d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -162,34 +162,27 @@ static bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->memcg;
 }
-static bool scanning_global_lru(struct scan_control *sc)
-{
-	return !sc->current_memcg;
-}
 #else
 static bool global_reclaim(struct scan_control *sc) { return 1; }
-static bool scanning_global_lru(struct scan_control *sc) { return 1; }
 #endif
 
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
-	if (!scanning_global_lru(sc))
-		return mem_cgroup_get_reclaim_stat(sc->current_memcg, zone);
-
-	return &zone->reclaim_stat;
+	if (mem_cgroup_disabled())
+		return &zone->reclaim_stat;
+	return mem_cgroup_get_reclaim_stat(sc->current_memcg, zone);
 }
 
 static unsigned long zone_nr_lru_pages(struct zone *zone,
-				struct scan_control *sc, enum lru_list lru)
+				       struct scan_control *sc,
+				       enum lru_list lru)
 {
-	if (!scanning_global_lru(sc))
-		return mem_cgroup_zone_nr_pages(sc->current_memcg, zone, lru);
-
-	return zone_page_state(zone, NR_LRU_BASE + lru);
+	if (mem_cgroup_disabled())
+		return zone_page_state(zone, NR_LRU_BASE + lru);
+	return mem_cgroup_zone_nr_pages(sc->current_memcg, zone, lru);
 }
 
-
 /*
  * Add a shrinker callback to be called from the vm
  */
@@ -1055,15 +1048,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
+			mem_cgroup_lru_del(page_zone(page), page);
 			list_move(&page->lru, dst);
-			mem_cgroup_del_lru(page);
 			nr_taken += hpage_nr_pages(page);
 			break;
 
 		case -EBUSY:
 			/* else it is being freed elsewhere */
 			list_move(&page->lru, src);
-			mem_cgroup_rotate_lru_list(page, page_lru(page));
 			continue;
 
 		default:
@@ -1113,8 +1105,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+				mem_cgroup_lru_del(page_zone(cursor_page),
+						   cursor_page);
 				list_move(&cursor_page->lru, dst);
-				mem_cgroup_del_lru(cursor_page);
 				nr_taken += hpage_nr_pages(page);
 				nr_lumpy_taken++;
 				if (PageDirty(cursor_page))
@@ -1143,19 +1136,22 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	return nr_taken;
 }
 
-static unsigned long isolate_pages_global(unsigned long nr,
-					struct list_head *dst,
-					unsigned long *scanned, int order,
-					int mode, struct zone *z,
-					int active, int file)
+static unsigned long isolate_pages(unsigned long nr,
+				   struct list_head *dst,
+				   unsigned long *scanned, int order,
+				   int mode, struct zone *z,
+				   int active, int file,
+				   struct mem_cgroup *mem)
 {
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(z, mem);
 	int lru = LRU_BASE;
+
 	if (active)
 		lru += LRU_ACTIVE;
 	if (file)
 		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, file);
+	return isolate_lru_pages(nr, &lruvec->lists[lru], dst,
+				 scanned, order, mode, file);
 }
 
 /*
@@ -1403,20 +1399,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 
-	if (scanning_global_lru(sc)) {
-		nr_taken = isolate_pages_global(nr_to_scan,
-			&page_list, &nr_scanned, sc->order,
-			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
-					ISOLATE_BOTH : ISOLATE_INACTIVE,
-			zone, 0, file);
-	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
+	nr_taken = isolate_pages(nr_to_scan,
 			&page_list, &nr_scanned, sc->order,
 			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
-			zone, sc->current_memcg,
-			0, file);
-	}
+			zone, 0, file, sc->current_memcg);
 
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
@@ -1491,13 +1478,15 @@ static void move_active_pages_to_lru(struct zone *zone,
 	pagevec_init(&pvec, 1);
 
 	while (!list_empty(list)) {
+		struct lruvec *lruvec;
+
 		page = lru_to_page(list);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_add_lru_list(page, lru);
+		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
+		list_move(&page->lru, &lruvec->lists[lru]);
 		pgmoved += hpage_nr_pages(page);
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
@@ -1528,17 +1517,10 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	if (scanning_global_lru(sc)) {
-		nr_taken = isolate_pages_global(nr_pages, &l_hold,
-						&pgscanned, sc->order,
-						ISOLATE_ACTIVE, zone,
-						1, file);
-	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
-						&pgscanned, sc->order,
-						ISOLATE_ACTIVE, zone,
-						sc->current_memcg, 1, file);
-	}
+	nr_taken = isolate_pages(nr_pages, &l_hold,
+				 &pgscanned, sc->order,
+				 ISOLATE_ACTIVE, zone,
+				 1, file, sc->current_memcg);
 
 	if (global_reclaim(sc))
 		zone->pages_scanned += pgscanned;
@@ -1628,8 +1610,6 @@ static int inactive_anon_is_low_global(struct zone *zone)
  */
 static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 {
-	int low;
-
 	/*
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
@@ -1637,11 +1617,9 @@ static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 	if (!total_swap_pages)
 		return 0;
 
-	if (scanning_global_lru(sc))
-		low = inactive_anon_is_low_global(zone);
-	else
-		low = mem_cgroup_inactive_anon_is_low(sc->current_memcg);
-	return low;
+	if (mem_cgroup_disabled())
+		return inactive_anon_is_low_global(zone);
+	return mem_cgroup_inactive_anon_is_low(sc->current_memcg);
 }
 #else
 static inline int inactive_anon_is_low(struct zone *zone,
@@ -1678,13 +1656,9 @@ static int inactive_file_is_low_global(struct zone *zone)
  */
 static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
 {
-	int low;
-
-	if (scanning_global_lru(sc))
-		low = inactive_file_is_low_global(zone);
-	else
-		low = mem_cgroup_inactive_file_is_low(sc->current_memcg);
-	return low;
+	if (mem_cgroup_disabled())
+		return inactive_file_is_low_global(zone);
+	return mem_cgroup_inactive_file_is_low(sc->current_memcg);
 }
 
 static int inactive_list_is_low(struct zone *zone, struct scan_control *sc,
@@ -3161,16 +3135,18 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
  */
 static void check_move_unevictable_page(struct page *page, struct zone *zone)
 {
-	VM_BUG_ON(PageActive(page));
+	struct lruvec *lruvec;
 
+	VM_BUG_ON(PageActive(page));
 retry:
 	ClearPageUnevictable(page);
 	if (page_evictable(page, NULL)) {
 		enum lru_list l = page_lru_base_type(page);
 
 		__dec_zone_state(zone, NR_UNEVICTABLE);
-		list_move(&page->lru, &zone->lru[l].list);
-		mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
+		lruvec = mem_cgroup_lru_move_lists(zone, page,
+						   LRU_UNEVICTABLE, l);
+		list_move(&page->lru, &lruvec->lists[l]);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
 	} else {
@@ -3178,8 +3154,9 @@ retry:
 		 * rotate unevictable list
 		 */
 		SetPageUnevictable(page);
-		list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
-		mem_cgroup_rotate_lru_list(page, LRU_UNEVICTABLE);
+		lruvec = mem_cgroup_lru_move_lists(zone, page, LRU_UNEVICTABLE,
+						   LRU_UNEVICTABLE);
+		list_move(&page->lru, &lruvec->lists[LRU_UNEVICTABLE]);
 		if (page_evictable(page, NULL))
 			goto retry;
 	}
@@ -3253,29 +3230,37 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 #define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
 static void scan_zone_unevictable_pages(struct zone *zone)
 {
-	struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
-	unsigned long scan;
 	unsigned long nr_to_scan = zone_page_state(zone, NR_UNEVICTABLE);
 
 	while (nr_to_scan > 0) {
 		unsigned long batch_size = min(nr_to_scan,
 						SCAN_UNEVICTABLE_BATCH_SIZE);
+		struct mem_cgroup *mem = NULL;
 
-		spin_lock_irq(&zone->lru_lock);
-		for (scan = 0;  scan < batch_size; scan++) {
-			struct page *page = lru_to_page(l_unevictable);
-
-			if (!trylock_page(page))
-				continue;
+		do {
+			struct list_head *list;
+			struct lruvec *lruvec;
+			unsigned long scan;
 
-			prefetchw_prev_lru_page(page, l_unevictable, flags);
+			mem_cgroup_hierarchy_walk(NULL, &mem);
+			spin_lock_irq(&zone->lru_lock);
+			lruvec = mem_cgroup_zone_lruvec(zone, mem);
+			list = &lruvec->lists[LRU_UNEVICTABLE];
+			for (scan = 0;  scan < batch_size; scan++) {
+				struct page *page = lru_to_page(list);
 
-			if (likely(PageLRU(page) && PageUnevictable(page)))
+				if (!trylock_page(page))
+					continue;
+				prefetchw_prev_lru_page(page, list, flags);
+				if (unlikely(!PageLRU(page)))
+					continue;
+				if (unlikely(!PageUnevictable(page)))
+					continue;
 				check_move_unevictable_page(page, zone);
-
-			unlock_page(page);
-		}
-		spin_unlock_irq(&zone->lru_lock);
+				unlock_page(page);
+			}
+			spin_unlock_irq(&zone->lru_lock);
+		} while (mem);
 
 		nr_to_scan -= batch_size;
 	}
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
