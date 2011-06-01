Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8FA6B0028
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 02:25:52 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 8/8] mm: make per-memcg lru lists exclusive
Date: Wed,  1 Jun 2011 08:25:19 +0200
Message-Id: <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

All lru list walkers have been converted to operate on per-memcg
lists, the global per-zone lists are no longer required.

This patch makes the per-memcg lists exclusive and removes the global
lists from memcg-enabled kernels.

The per-memcg lists now string up page descriptors directly, which
unifies/simplifies the list isolation code of page reclaim as well as
it saves a full double-linked list head for each page in the system.

At the core of this change is the introduction of the lruvec
structure, an array of all lru list heads.  It exists for each zone
globally, and for each zone per memcg.  All lru list operations are
now done in generic code against lruvecs, with the memcg lru list
primitives only doing accounting and returning the proper lruvec for
the currently scanned memcg on isolation, or for the respective page
on putback.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h  |   53 ++++-----
 include/linux/mm_inline.h   |   14 ++-
 include/linux/mmzone.h      |   10 +-
 include/linux/page_cgroup.h |   36 ------
 mm/memcontrol.c             |  271 ++++++++++++++++++-------------------------
 mm/page_alloc.c             |    2 +-
 mm/page_cgroup.c            |   38 +------
 mm/swap.c                   |   20 ++--
 mm/vmscan.c                 |   88 ++++++--------
 9 files changed, 207 insertions(+), 325 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 56c1def..d3837f0 100644
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
@@ -60,15 +54,14 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
-struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
-				    enum lru_list);
-extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
-extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
-extern void mem_cgroup_del_lru(struct page *page);
-extern void mem_cgroup_move_lists(struct page *page,
-				  enum lru_list from, enum lru_list to);
+
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
+				       enum lru_list);
+void mem_cgroup_lru_del_list(struct page *, enum lru_list);
+void mem_cgroup_lru_del(struct page *);
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
+					 enum lru_list, enum lru_list);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -214,33 +207,33 @@ static inline int mem_cgroup_shmem_charge_fallback(struct page *page,
 	return 0;
 }
 
-static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
-{
-}
-
-static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
+static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
+						    struct mem_cgroup *mem)
 {
-	return ;
+	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
+static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
+						     struct page *page,
+						     enum lru_list lru)
 {
-	return ;
+	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
+static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 {
-	return ;
 }
 
-static inline void mem_cgroup_del_lru(struct page *page)
+static inline void mem_cgroup_lru_del(struct page *page)
 {
-	return ;
 }
 
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
index 8f7d247..43d5d9f 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -25,23 +25,27 @@ static inline void
 __add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
 		       struct list_head *head)
 {
+	/* NOTE: Caller must ensure @head is on the right lruvec! */
+	mem_cgroup_lru_add_list(zone, page, l);
 	list_add(&page->lru, head);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
-	mem_cgroup_add_lru_list(page, l);
 }
 
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
-	__add_page_to_lru_list(zone, page, l, &zone->lru[l].list);
+	struct lruvec *lruvec = mem_cgroup_lru_add_list(zone, page, l);
+
+	list_add(&page->lru, &lruvec->lists[l]);
+	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
 }
 
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
+	mem_cgroup_lru_del_list(page, l);
 	list_del(&page->lru);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages(page));
-	mem_cgroup_del_lru_list(page, l);
 }
 
 /**
@@ -64,7 +68,6 @@ del_page_from_lru(struct zone *zone, struct page *page)
 {
 	enum lru_list l;
 
-	list_del(&page->lru);
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
 		l = LRU_UNEVICTABLE;
@@ -75,8 +78,9 @@ del_page_from_lru(struct zone *zone, struct page *page)
 			l += LRU_ACTIVE;
 		}
 	}
+	mem_cgroup_lru_del_list(page, l);
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
index 961ecc7..a42ddf9 100644
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
@@ -121,40 +119,6 @@ static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
 	bit_spin_unlock(PCG_MOVE_LOCK, &pc->flags);
 	local_irq_restore(*flags);
 }
-
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
index d9d1a7e..4a365b7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -133,10 +133,7 @@ struct mem_cgroup_stat_cpu {
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
@@ -642,6 +639,26 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 	return (mem == root_mem_cgroup);
 }
 
+/**
+ * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
+ * @zone: zone of the wanted lruvec
+ * @mem: memcg of the wanted lruvec
+ *
+ * Returns the lru list vector holding pages for the given @zone and
+ * @mem.  This can be the global zone lruvec, if the memory controller
+ * is disabled.
+ */
+struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone, struct mem_cgroup *mem)
+{
+	struct mem_cgroup_per_zone *mz;
+
+	if (mem_cgroup_disabled())
+		return &zone->lruvec;
+
+	mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
+	return &mz->lruvec;
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -656,21 +673,74 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
  * When moving account, the page is not on LRU. It's isolated.
  */
 
-struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup *mem,
-				    enum lru_list lru)
+/**
+ * mem_cgroup_lru_add_list - account for adding an lru page and return lruvec
+ * @zone: zone of the page
+ * @page: the page itself
+ * @lru: target lru list
+ *
+ * This function must be called when a page is to be added to an lru
+ * list.
+ *
+ * Returns the lruvec to hold @page, the callsite is responsible for
+ * physically linking the page to &lruvec->lists[@lru].
+ */
+struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
+				       enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
 
-	mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
-	pc = list_entry(mz->lists[lru].prev, struct page_cgroup, lru);
-	return lookup_cgroup_page(pc);
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
+		 * If the page is no longer charged, add it to the
+		 * root memcg's lru.  Either it will be freed soon, or
+		 * it will get charged again and the charger will
+		 * relink it to the right list.
+		 */
+		mem = root_mem_cgroup;
+	}
+	mz = page_cgroup_zoneinfo(mem, page);
+	/*
+	 * We do not account for uncharged pages: they are linked to
+	 * root_mem_cgroup but when the page is unlinked upon free,
+	 * accounting would be done against pc->mem_cgroup.
+	 */
+	if (PageCgroupUsed(pc)) {
+		/*
+		 * Huge page splitting is serialized through the lru
+		 * lock, so compound_order() is stable here.
+		 */
+		MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
+		SetPageCgroupAcctLRU(pc);
+	}
+	return &mz->lruvec;
 }
 
-void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
+/**
+ * mem_cgroup_lru_del_list - account for removing an lru page
+ * @page: page to unlink
+ * @lru: lru list the page is sitting on
+ *
+ * This function must be called when a page is to be removed from an
+ * lru list.
+ *
+ * The callsite is responsible for physically unlinking &@page->lru.
+ */
+void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 {
-	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
 
 	if (mem_cgroup_disabled())
 		return;
@@ -686,75 +756,35 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
-	VM_BUG_ON(list_empty(&pc->lru));
-	list_del_init(&pc->lru);
 }
 
-void mem_cgroup_del_lru(struct page *page)
+void mem_cgroup_lru_del(struct page *page)
 {
-	mem_cgroup_del_lru_list(page, page_lru(page));
+	mem_cgroup_lru_del_list(page, page_lru(page));
 }
 
-/*
- * Writeback is about to end against a page which has been marked for immediate
- * reclaim.  If it still appears to be reclaimable, move it to the tail of the
- * inactive list.
+/**
+ * mem_cgroup_lru_move_lists - account for moving a page between lru lists
+ * @zone: zone of the page
+ * @page: page to move
+ * @from: current lru list
+ * @to: new lru list
+ *
+ * This function must be called when a page is moved between lru
+ * lists, or rotated on the same lru list.
+ *
+ * Returns the lruvec to hold @page in the future, the callsite is
+ * responsible for physically relinking the page to
+ * &lruvec->lists[@to].
  */
-void mem_cgroup_rotate_reclaimable_page(struct page *page)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct page_cgroup *pc;
-	enum lru_list lru = page_lru(page);
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(page);
-	/* unused page is not rotated. */
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	list_move_tail(&pc->lru, &mz->lists[lru]);
-}
-
-void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
+struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
+					 struct page *page,
+					 enum lru_list from,
+					 enum lru_list to)
 {
-	struct mem_cgroup_per_zone *mz;
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(page);
-	/* unused page is not rotated. */
-	if (!PageCgroupUsed(pc))
-		return;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
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
-	list_add(&pc->lru, &mz->lists[lru]);
+	/* TODO: this could be optimized, especially if from == to */
+	mem_cgroup_lru_del_list(page, from);
+	return mem_cgroup_lru_add_list(zone, page, to);
 }
 
 /*
@@ -786,7 +816,7 @@ static void mem_cgroup_lru_del_before_commit(struct page *page)
 	 * is guarded by lock_page() because the page is SwapCache.
 	 */
 	if (!PageCgroupUsed(pc))
-		mem_cgroup_del_lru_list(page, page_lru(page));
+		del_page_from_lru(zone, page);
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
@@ -800,22 +830,11 @@ static void mem_cgroup_lru_add_after_commit(struct page *page)
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
@@ -935,67 +954,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
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
 
@@ -3110,22 +3068,23 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
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
@@ -3134,16 +3093,16 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
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
@@ -3151,7 +3110,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 
 		if (ret == -EBUSY || ret == -EINVAL) {
 			/* found lock contention or "pc" is obsolete. */
-			busy = pc;
+			busy = page;
 			cond_resched();
 		} else
 			busy = NULL;
@@ -4171,7 +4130,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
-			INIT_LIST_HEAD(&mz->lists[l]);
+			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 	}
 	return 0;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f8bce2..9da238d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4289,7 +4289,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone_pcp_init(zone);
 		for_each_lru(l) {
-			INIT_LIST_HEAD(&zone->lru[l].list);
+			INIT_LIST_HEAD(&zone->lruvec.lists[l]);
 			zone->reclaim_stat.nr_saved_scan[l] = 0;
 		}
 		zone->reclaim_stat.recent_rotated[0] = 0;
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 2daadc3..916c6f9 100644
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
@@ -167,11 +139,9 @@ static int __init_refok init_section_page_cgroup(unsigned long pfn)
 	struct page_cgroup *base, *pc;
 	struct mem_section *section;
 	unsigned long table_size;
-	unsigned long nr;
 	int nid, index;
 
-	nr = pfn_to_section_nr(pfn);
-	section = __nr_to_section(nr);
+	section = __pfn_to_section(pfn);
 
 	if (section->page_cgroup)
 		return 0;
@@ -194,7 +164,7 @@ static int __init_refok init_section_page_cgroup(unsigned long pfn)
 
 	for (index = 0; index < PAGES_PER_SECTION; index++) {
 		pc = base + index;
-		init_page_cgroup(pc, nr);
+		init_page_cgroup(pc);
 	}
 
 	section->page_cgroup = base - pfn;
diff --git a/mm/swap.c b/mm/swap.c
index 5602f1a..0a5a93b 100644
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
@@ -420,12 +422,13 @@ static void lru_deactivate_fn(struct page *page, void *arg)
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
 
@@ -597,7 +600,6 @@ void lru_add_page_tail(struct zone* zone,
 	int active;
 	enum lru_list lru;
 	const int file = 0;
-	struct list_head *head;
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
@@ -617,10 +619,10 @@ void lru_add_page_tail(struct zone* zone,
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
index 23fd2b1..87e1fcb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1080,15 +1080,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
+			mem_cgroup_lru_del(page);
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
@@ -1138,8 +1137,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);
-				mem_cgroup_del_lru(cursor_page);
 				nr_taken += hpage_nr_pages(page);
 				nr_lumpy_taken++;
 				if (PageDirty(cursor_page))
@@ -1168,19 +1167,22 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
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
@@ -1428,20 +1430,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
-			&page_list, &nr_scanned, sc->order,
-			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
+	nr_taken = isolate_pages(nr_to_scan,
+				 &page_list, &nr_scanned, sc->order,
+				 sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
-			zone, sc->mem_cgroup,
-			0, file);
-	}
+				 zone, 0, file, sc->mem_cgroup);
 
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
@@ -1514,13 +1507,15 @@ static void move_active_pages_to_lru(struct zone *zone,
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
@@ -1551,17 +1546,10 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 
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
-						sc->mem_cgroup, 1, file);
-	}
+	nr_taken = isolate_pages(nr_pages, &l_hold,
+				 &pgscanned, sc->order,
+				 ISOLATE_ACTIVE, zone,
+				 1, file, sc->mem_cgroup);
 
 	if (global_reclaim(sc))
 		zone->pages_scanned += pgscanned;
@@ -3154,16 +3142,18 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
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
 
+		lruvec = mem_cgroup_lru_move_lists(zone, page,
+						   LRU_UNEVICTABLE, l);
 		__dec_zone_state(zone, NR_UNEVICTABLE);
-		list_move(&page->lru, &zone->lru[l].list);
-		mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
+		list_move(&page->lru, &lruvec->lists[l]);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
 	} else {
@@ -3171,8 +3161,9 @@ retry:
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
@@ -3233,14 +3224,6 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 
 }
 
-static struct page *lru_tailpage(struct zone *zone, struct mem_cgroup *mem,
-				 enum lru_list lru)
-{
-	if (mem)
-		return mem_cgroup_lru_to_page(zone, mem, lru);
-	return lru_to_page(&zone->lru[lru].list);
-}
-
 /**
  * scan_zone_unevictable_pages - check unevictable list for evictable pages
  * @zone - zone of which to scan the unevictable list
@@ -3259,8 +3242,13 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 	first = mem = mem_cgroup_hierarchy_walk(NULL, mem);
 	do {
 		unsigned long nr_to_scan;
+		struct list_head *list;
+		struct lruvec *lruvec;
 
 		nr_to_scan = zone_nr_lru_pages(zone, mem, LRU_UNEVICTABLE);
+		lruvec = mem_cgroup_zone_lruvec(zone, mem);
+		list = &lruvec->lists[LRU_UNEVICTABLE];
+
 		while (nr_to_scan > 0) {
 			unsigned long batch_size;
 			unsigned long scan;
@@ -3272,7 +3260,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 			for (scan = 0; scan < batch_size; scan++) {
 				struct page *page;
 
-				page = lru_tailpage(zone, mem, LRU_UNEVICTABLE);
+				page = lru_to_page(list);
 				if (!trylock_page(page))
 					continue;
 				if (likely(PageLRU(page) &&
-- 
1.7.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
