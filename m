Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 649A76B0103
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:32:35 -0500 (EST)
Received: by dadv6 with SMTP id v6so7618139dad.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:32:34 -0800 (PST)
Date: Mon, 20 Feb 2012 15:32:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/10] mm/memcg: apply add/del_page to lruvec
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201530530.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Go further: pass lruvec instead of zone to add_page_to_lru_list() and
del_page_from_lru_list(); and pagevec_lru_move_fn() pass lruvec down
to its target functions.

This cleanup eliminates a swathe of cruft in memcontrol.c,
including mem_cgroup_lru_add_list(), mem_cgroup_lru_del_list() and
mem_cgroup_lru_move_lists(), which never actually touched the lists.

In their place, mem_cgroup_page_lruvec() to decide the lruvec,
previously a side-effect of add, and mem_cgroup_update_lru_size()
to maintain the lru_size stats.

Whilst these are simplifications in their own right, the goal is to
bring the evaluation of lruvec next to the spin_locking of the lrus,
in preparation for the next patch.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |   40 ++-----------
 include/linux/mm_inline.h  |   20 +++---
 include/linux/swap.h       |    4 -
 mm/compaction.c            |    5 +
 mm/huge_memory.c           |    5 +
 mm/memcontrol.c            |  102 +++++++----------------------------
 mm/swap.c                  |   85 ++++++++++++++---------------
 mm/vmscan.c                |   60 ++++++++++++--------
 8 files changed, 128 insertions(+), 193 deletions(-)

--- mmotm.orig/include/linux/memcontrol.h	2012-02-18 11:57:28.371524252 -0800
+++ mmotm/include/linux/memcontrol.h	2012-02-18 11:57:35.583524425 -0800
@@ -63,13 +63,9 @@ extern int mem_cgroup_cache_charge(struc
 					gfp_t gfp_mask);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+extern struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 extern struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec);
-struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
-				       enum lru_list);
-void mem_cgroup_lru_del_list(struct page *, enum lru_list);
-void mem_cgroup_lru_del(struct page *);
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
-					 enum lru_list, enum lru_list);
+extern void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -119,8 +115,6 @@ int mem_cgroup_inactive_file_is_low(stru
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct lruvec *lruvec,
 					   unsigned int lrumask);
-struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
@@ -248,32 +242,20 @@ static inline struct lruvec *mem_cgroup_
 	return &zone->lruvec;
 }
 
-static inline struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec)
-{
-	return NULL;
-}
-
-static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
-						     struct page *page,
-						     enum lru_list lru)
+static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
+						    struct zone *zone)
 {
 	return &zone->lruvec;
 }
 
-static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
-{
-}
-
-static inline void mem_cgroup_lru_del(struct page *page)
+static inline struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec)
 {
+	return NULL;
 }
 
-static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
-						       struct page *page,
-						       enum lru_list from,
-						       enum lru_list to)
+static inline void mem_cgroup_update_lru_size(struct lruvec *lruvec,
+					      enum lru_list lru, int increment)
 {
-	return &zone->lruvec;
 }
 
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
@@ -352,12 +334,6 @@ mem_cgroup_zone_nr_lru_pages(struct lruv
 	return 0;
 }
 
-static inline struct zone_reclaim_stat*
-mem_cgroup_get_reclaim_stat_from_page(struct page *page)
-{
-	return NULL;
-}
-
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
--- mmotm.orig/include/linux/mm_inline.h	2012-02-18 11:56:23.639522714 -0800
+++ mmotm/include/linux/mm_inline.h	2012-02-18 11:57:35.583524425 -0800
@@ -21,22 +21,22 @@ static inline int page_is_file_cache(str
 	return !PageSwapBacked(page);
 }
 
-static inline void
-add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
+static inline void add_page_to_lru_list(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
 {
-	struct lruvec *lruvec;
-
-	lruvec = mem_cgroup_lru_add_list(zone, page, lru);
+	int nr_pages = hpage_nr_pages(page);
+	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
 	list_add(&page->lru, &lruvec->lists[lru]);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, hpage_nr_pages(page));
+	__mod_zone_page_state(lruvec->zone, NR_LRU_BASE + lru, nr_pages);
 }
 
-static inline void
-del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
+static inline void del_page_from_lru_list(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
 {
-	mem_cgroup_lru_del_list(page, lru);
+	int nr_pages = hpage_nr_pages(page);
+	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
 	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -hpage_nr_pages(page));
+	__mod_zone_page_state(lruvec->zone, NR_LRU_BASE + lru, -nr_pages);
 }
 
 /**
--- mmotm.orig/include/linux/swap.h	2012-02-18 11:56:23.639522714 -0800
+++ mmotm/include/linux/swap.h	2012-02-18 11:57:35.583524425 -0800
@@ -224,8 +224,8 @@ extern unsigned int nr_free_pagecache_pa
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
-extern void lru_add_page_tail(struct zone* zone,
-			      struct page *page, struct page *page_tail);
+extern void lru_add_page_tail(struct page *page, struct page *page_tail,
+			      struct lruvec *lruvec);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
--- mmotm.orig/mm/compaction.c	2012-02-18 11:56:23.639522714 -0800
+++ mmotm/mm/compaction.c	2012-02-18 11:57:35.583524425 -0800
@@ -262,6 +262,7 @@ static isolate_migrate_t isolate_migrate
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
+	struct lruvec *lruvec;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -378,10 +379,12 @@ static isolate_migrate_t isolate_migrate
 		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
 
+		lruvec = mem_cgroup_page_lruvec(page, zone);
+
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
-		del_page_from_lru_list(zone, page, page_lru(page));
+		del_page_from_lru_list(page, lruvec, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
--- mmotm.orig/mm/huge_memory.c	2012-02-18 11:56:23.639522714 -0800
+++ mmotm/mm/huge_memory.c	2012-02-18 11:57:35.583524425 -0800
@@ -1223,10 +1223,13 @@ static void __split_huge_page_refcount(s
 {
 	int i;
 	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
 	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
+	lruvec = mem_cgroup_page_lruvec(page, zone);
+
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
@@ -1302,7 +1305,7 @@ static void __split_huge_page_refcount(s
 		BUG_ON(!PageSwapBacked(page_tail));
 
 
-		lru_add_page_tail(zone, page, page_tail);
+		lru_add_page_tail(page, page_tail, lruvec);
 	}
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
--- mmotm.orig/mm/memcontrol.c	2012-02-18 11:57:28.371524252 -0800
+++ mmotm/mm/memcontrol.c	2012-02-18 11:57:35.587524424 -0800
@@ -993,7 +993,7 @@ EXPORT_SYMBOL(mem_cgroup_count_vm_event)
 /**
  * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
  * @zone: zone of the wanted lruvec
- * @mem: memcg of the wanted lruvec
+ * @memcg: memcg of the wanted lruvec
  *
  * Returns the lru list vector holding pages for the given @zone and
  * @mem.  This can be the global zone lruvec, if the memory controller
@@ -1037,19 +1037,11 @@ struct mem_cgroup *mem_cgroup_from_lruve
  */
 
 /**
- * mem_cgroup_lru_add_list - account for adding an lru page and return lruvec
- * @zone: zone of the page
+ * mem_cgroup_page_lruvec - return lruvec for adding an lru page
  * @page: the page
- * @lru: current lru
- *
- * This function accounts for @page being added to @lru, and returns
- * the lruvec for the given @zone and the memcg @page is charged to.
- *
- * The callsite is then responsible for physically linking the page to
- * the returned lruvec->lists[@lru].
+ * @zone: zone of the page
  */
-struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
-				       enum lru_list lru)
+struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup *memcg;
@@ -1061,66 +1053,31 @@ struct lruvec *mem_cgroup_lru_add_list(s
 	pc = lookup_page_cgroup(page);
 	memcg = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(memcg, page);
-	/* compound_order() is stabilized through lru_lock */
-	mz->lru_size[lru] += 1 << compound_order(page);
 	return &mz->lruvec;
 }
 
 /**
- * mem_cgroup_lru_del_list - account for removing an lru page
- * @page: the page
- * @lru: target lru
- *
- * This function accounts for @page being removed from @lru.
+ * mem_cgroup_update_lru_size - account for adding or removing an lru page
+ * @lruvec: mem_cgroup per zone lru vector
+ * @lru: index of lru list the page is sitting on
+ * @nr_pages: positive when adding or negative when removing
  *
- * The callsite is then responsible for physically unlinking
- * @page->lru.
+ * This function must be called when a page is added to or removed from an
+ * lru list.
  */
-void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
+void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
+				int nr_pages)
 {
 	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc;
+	unsigned long *lru_size;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
-	VM_BUG_ON(!memcg);
-	mz = page_cgroup_zoneinfo(memcg, page);
-	/* huge page split is done under lru_lock. so, we have no races. */
-	VM_BUG_ON(mz->lru_size[lru] < (1 << compound_order(page)));
-	mz->lru_size[lru] -= 1 << compound_order(page);
-}
-
-void mem_cgroup_lru_del(struct page *page)
-{
-	mem_cgroup_lru_del_list(page, page_lru(page));
-}
-
-/**
- * mem_cgroup_lru_move_lists - account for moving a page between lrus
- * @zone: zone of the page
- * @page: the page
- * @from: current lru
- * @to: target lru
- *
- * This function accounts for @page being moved between the lrus @from
- * and @to, and returns the lruvec for the given @zone and the memcg
- * @page is charged to.
- *
- * The callsite is then responsible for physically relinking
- * @page->lru to the returned lruvec->lists[@to].
- */
-struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
-					 struct page *page,
-					 enum lru_list from,
-					 enum lru_list to)
-{
-	/* XXX: Optimize this, especially for @from == @to */
-	mem_cgroup_lru_del_list(page, from);
-	return mem_cgroup_lru_add_list(zone, page, to);
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	lru_size = mz->lru_size + lru;
+	*lru_size += nr_pages;
+	VM_BUG_ON((long)(*lru_size) < 0);
 }
 
 /*
@@ -1203,24 +1160,6 @@ int mem_cgroup_inactive_file_is_low(stru
 	return (active > inactive);
 }
 
-struct zone_reclaim_stat *
-mem_cgroup_get_reclaim_stat_from_page(struct page *page)
-{
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
-
-	if (mem_cgroup_disabled())
-		return NULL;
-
-	pc = lookup_page_cgroup(page);
-	if (!PageCgroupUsed(pc))
-		return NULL;
-	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
-	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	return &mz->lruvec.reclaim_stat;
-}
-
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -2695,6 +2634,7 @@ __mem_cgroup_commit_charge_lrucare(struc
 	struct zone *zone = page_zone(page);
 	unsigned long flags;
 	bool removed = false;
+	struct lruvec *lruvec;
 
 	/*
 	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
@@ -2703,13 +2643,15 @@ __mem_cgroup_commit_charge_lrucare(struc
 	 */
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (PageLRU(page)) {
-		del_page_from_lru_list(zone, page, page_lru(page));
+		lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
+		del_page_from_lru_list(page, lruvec, page_lru(page));
 		ClearPageLRU(page);
 		removed = true;
 	}
 	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
 	if (removed) {
-		add_page_to_lru_list(zone, page, page_lru(page));
+		lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
+		add_page_to_lru_list(page, lruvec, page_lru(page));
 		SetPageLRU(page);
 	}
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
--- mmotm.orig/mm/swap.c	2012-02-18 11:57:20.395524062 -0800
+++ mmotm/mm/swap.c	2012-02-18 11:57:35.587524424 -0800
@@ -47,13 +47,15 @@ static DEFINE_PER_CPU(struct pagevec, lr
 static void __page_cache_release(struct page *page)
 {
 	if (PageLRU(page)) {
-		unsigned long flags;
 		struct zone *zone = page_zone(page);
+		struct lruvec *lruvec;
+		unsigned long flags;
 
 		spin_lock_irqsave(&zone->lru_lock, flags);
+		lruvec = mem_cgroup_page_lruvec(page, zone);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		del_page_from_lru_list(zone, page, page_off_lru(page));
+		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 }
@@ -202,11 +204,12 @@ void put_pages_list(struct list_head *pa
 EXPORT_SYMBOL(put_pages_list);
 
 static void pagevec_lru_move_fn(struct pagevec *pvec,
-				void (*move_fn)(struct page *page, void *arg),
-				void *arg)
+	void (*move_fn)(struct page *page, struct lruvec *lruvec, void *arg),
+	void *arg)
 {
 	int i;
 	struct zone *zone = NULL;
+	struct lruvec *lruvec;
 	unsigned long flags = 0;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
@@ -220,7 +223,8 @@ static void pagevec_lru_move_fn(struct p
 			spin_lock_irqsave(&zone->lru_lock, flags);
 		}
 
-		(*move_fn)(page, arg);
+		lruvec = mem_cgroup_page_lruvec(page, zone);
+		(*move_fn)(page, lruvec, arg);
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
@@ -228,16 +232,13 @@ static void pagevec_lru_move_fn(struct p
 	pagevec_reinit(pvec);
 }
 
-static void pagevec_move_tail_fn(struct page *page, void *arg)
+static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
+				 void *arg)
 {
 	int *pgmoved = arg;
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		struct lruvec *lruvec;
-
-		lruvec = mem_cgroup_lru_move_lists(page_zone(page),
-						   page, lru, lru);
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		(*pgmoved)++;
 	}
@@ -276,35 +277,30 @@ void rotate_reclaimable_page(struct page
 	}
 }
 
-static void update_page_reclaim_stat(struct zone *zone, struct page *page,
+static void update_page_reclaim_stat(struct lruvec *lruvec,
 				     int file, int rotated)
 {
-	struct zone_reclaim_stat *reclaim_stat;
-
-	reclaim_stat = mem_cgroup_get_reclaim_stat_from_page(page);
-	if (!reclaim_stat)
-		reclaim_stat = &zone->lruvec.reclaim_stat;
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
 	reclaim_stat->recent_scanned[file]++;
 	if (rotated)
 		reclaim_stat->recent_rotated[file]++;
 }
 
-static void __activate_page(struct page *page, void *arg)
+static void __activate_page(struct page *page, struct lruvec *lruvec,
+			    void *arg)
 {
-	struct zone *zone = page_zone(page);
-
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
-		del_page_from_lru_list(zone, page, lru);
 
+		del_page_from_lru_list(page, lruvec, lru);
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
-		add_page_to_lru_list(zone, page, lru);
-		__count_vm_event(PGACTIVATE);
+		add_page_to_lru_list(page, lruvec, lru);
 
-		update_page_reclaim_stat(zone, page, file, 1);
+		__count_vm_event(PGACTIVATE);
+		update_page_reclaim_stat(lruvec, file, 1);
 	}
 }
 
@@ -341,7 +337,7 @@ void activate_page(struct page *page)
 	struct zone *zone = page_zone(page);
 
 	spin_lock_irq(&zone->lru_lock);
-	__activate_page(page, NULL);
+	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
 	spin_unlock_irq(&zone->lru_lock);
 }
 #endif
@@ -408,11 +404,13 @@ void lru_cache_add_lru(struct page *page
 void add_page_to_unevictable_list(struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
 
 	spin_lock_irq(&zone->lru_lock);
+	lruvec = mem_cgroup_page_lruvec(page, zone);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
-	add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
+	add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
 	spin_unlock_irq(&zone->lru_lock);
 }
 
@@ -437,11 +435,11 @@ void add_page_to_unevictable_list(struct
  * be write it out by flusher threads as this is much more effective
  * than the single-page writeout from reclaim.
  */
-static void lru_deactivate_fn(struct page *page, void *arg)
+static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+			      void *arg)
 {
 	int lru, file;
 	bool active;
-	struct zone *zone = page_zone(page);
 
 	if (!PageLRU(page))
 		return;
@@ -454,13 +452,13 @@ static void lru_deactivate_fn(struct pag
 		return;
 
 	active = PageActive(page);
-
 	file = page_is_file_cache(page);
 	lru = page_lru_base_type(page);
-	del_page_from_lru_list(zone, page, lru + active);
+
+	del_page_from_lru_list(page, lruvec, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
-	add_page_to_lru_list(zone, page, lru);
+	add_page_to_lru_list(page, lruvec, lru);
 
 	if (PageWriteback(page) || PageDirty(page)) {
 		/*
@@ -470,19 +468,17 @@ static void lru_deactivate_fn(struct pag
 		 */
 		SetPageReclaim(page);
 	} else {
-		struct lruvec *lruvec;
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		lruvec = mem_cgroup_lru_move_lists(zone, page, lru, lru);
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		__count_vm_event(PGROTATED);
 	}
 
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
-	update_page_reclaim_stat(zone, page, file, 0);
+	update_page_reclaim_stat(lruvec, file, 0);
 }
 
 /*
@@ -582,6 +578,7 @@ void release_pages(struct page **pages,
 	int i;
 	LIST_HEAD(pages_to_free);
 	struct zone *zone = NULL;
+	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
 
 	for (i = 0; i < nr; i++) {
@@ -609,9 +606,11 @@ void release_pages(struct page **pages,
 				zone = pagezone;
 				spin_lock_irqsave(&zone->lru_lock, flags);
 			}
+
+			lruvec = mem_cgroup_page_lruvec(page, zone);
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
-			del_page_from_lru_list(zone, page, page_off_lru(page));
+			del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		}
 
 		list_add(&page->lru, &pages_to_free);
@@ -643,8 +642,8 @@ EXPORT_SYMBOL(__pagevec_release);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* used by __split_huge_page_refcount() */
-void lru_add_page_tail(struct zone* zone,
-		       struct page *page, struct page *page_tail)
+void lru_add_page_tail(struct page *page, struct page *page_tail,
+		       struct lruvec *lruvec)
 {
 	int active;
 	enum lru_list lru;
@@ -653,7 +652,7 @@ void lru_add_page_tail(struct zone* zone
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&zone->lru_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&lruvec->zone->lru_lock));
 
 	SetPageLRU(page_tail);
 
@@ -666,7 +665,7 @@ void lru_add_page_tail(struct zone* zone
 			active = 0;
 			lru = LRU_INACTIVE_ANON;
 		}
-		update_page_reclaim_stat(zone, page_tail, file, active);
+		update_page_reclaim_stat(lruvec, file, active);
 	} else {
 		SetPageUnevictable(page_tail);
 		lru = LRU_UNEVICTABLE;
@@ -683,17 +682,17 @@ void lru_add_page_tail(struct zone* zone
 		 * Use the standard add function to put page_tail on the list,
 		 * but then correct its position so they all end up in order.
 		 */
-		add_page_to_lru_list(zone, page_tail, lru);
+		add_page_to_lru_list(page_tail, lruvec, lru);
 		list_head = page_tail->lru.prev;
 		list_move_tail(&page_tail->lru, list_head);
 	}
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-static void __pagevec_lru_add_fn(struct page *page, void *arg)
+static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
+				 void *arg)
 {
 	enum lru_list lru = (enum lru_list)arg;
-	struct zone *zone = page_zone(page);
 	int file = is_file_lru(lru);
 	int active = is_active_lru(lru);
 
@@ -704,8 +703,8 @@ static void __pagevec_lru_add_fn(struct
 	SetPageLRU(page);
 	if (active)
 		SetPageActive(page);
-	update_page_reclaim_stat(zone, page, file, active);
-	add_page_to_lru_list(zone, page, lru);
+	update_page_reclaim_stat(lruvec, file, active);
+	add_page_to_lru_list(page, lruvec, lru);
 }
 
 /*
--- mmotm.orig/mm/vmscan.c	2012-02-18 11:57:28.375524252 -0800
+++ mmotm/mm/vmscan.c	2012-02-18 11:57:35.587524424 -0800
@@ -1124,6 +1124,7 @@ static unsigned long isolate_lru_pages(u
 		unsigned long *nr_scanned, struct scan_control *sc,
 		isolate_mode_t mode, int active, int file)
 {
+	struct lruvec *home_lruvec = lruvec;
 	struct list_head *src;
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1140,6 +1141,7 @@ static unsigned long isolate_lru_pages(u
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
+		int isolated_pages;
 		unsigned long pfn;
 		unsigned long end_pfn;
 		unsigned long page_pfn;
@@ -1152,9 +1154,10 @@ static unsigned long isolate_lru_pages(u
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
-			mem_cgroup_lru_del(page);
+			isolated_pages = hpage_nr_pages(page);
+			mem_cgroup_update_lru_size(lruvec, lru, -isolated_pages);
 			list_move(&page->lru, dst);
-			nr_taken += hpage_nr_pages(page);
+			nr_taken += isolated_pages;
 			break;
 
 		case -EBUSY:
@@ -1209,11 +1212,13 @@ static unsigned long isolate_lru_pages(u
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				unsigned int isolated_pages;
-
-				mem_cgroup_lru_del(cursor_page);
-				list_move(&cursor_page->lru, dst);
+				lruvec = mem_cgroup_page_lruvec(cursor_page,
+								lruvec->zone);
 				isolated_pages = hpage_nr_pages(cursor_page);
+				mem_cgroup_update_lru_size(lruvec,
+					page_lru(cursor_page), -isolated_pages);
+				list_move(&cursor_page->lru, dst);
+
 				nr_taken += isolated_pages;
 				nr_lumpy_taken += isolated_pages;
 				if (PageDirty(cursor_page))
@@ -1243,6 +1248,8 @@ static unsigned long isolate_lru_pages(u
 		/* If we break out of the loop above, lumpy reclaim failed */
 		if (pfn < end_pfn)
 			nr_lumpy_failed++;
+
+		lruvec = home_lruvec;
 	}
 
 	*nr_scanned = scan;
@@ -1288,15 +1295,16 @@ int isolate_lru_page(struct page *page)
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
+		struct lruvec *lruvec;
 
 		spin_lock_irq(&zone->lru_lock);
+		lruvec = mem_cgroup_page_lruvec(page, zone);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
-			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
-
-			del_page_from_lru_list(zone, page, lru);
+			del_page_from_lru_list(page, lruvec, lru);
+			ret = 0;
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
@@ -1350,9 +1358,13 @@ putback_inactive_pages(struct lruvec *lr
 			spin_lock_irq(&zone->lru_lock);
 			continue;
 		}
+
+		lruvec = mem_cgroup_page_lruvec(page, zone);
+
 		SetPageLRU(page);
 		lru = page_lru(page);
-		add_page_to_lru_list(zone, page, lru);
+		add_page_to_lru_list(page, lruvec, lru);
+
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
@@ -1361,7 +1373,7 @@ putback_inactive_pages(struct lruvec *lr
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
-			del_page_from_lru_list(zone, page, lru);
+			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
@@ -1599,30 +1611,32 @@ shrink_inactive_list(unsigned long nr_to
  * But we had to alter page->flags anyway.
  */
 
-static void move_active_pages_to_lru(struct zone *zone,
+static void move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
 {
+	struct zone *zone = lruvec->zone;
 	unsigned long pgmoved = 0;
 	struct page *page;
+	int nr_pages;
 
 	while (!list_empty(list)) {
-		struct lruvec *lruvec;
-
 		page = lru_to_page(list);
+		lruvec = mem_cgroup_page_lruvec(page, zone);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
+		nr_pages = hpage_nr_pages(page);
 		list_move(&page->lru, &lruvec->lists[lru]);
-		pgmoved += hpage_nr_pages(page);
+		mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+		pgmoved += nr_pages;
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
-			del_page_from_lru_list(zone, page, lru);
+			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
@@ -1730,9 +1744,9 @@ static void shrink_active_list(unsigned
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(zone, &l_active, &l_hold,
+	move_active_pages_to_lru(lruvec, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive, &l_hold,
+	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
@@ -3529,6 +3543,7 @@ void check_move_unevictable_pages(struct
 			zone = pagezone;
 			spin_lock_irq(&zone->lru_lock);
 		}
+		lruvec = mem_cgroup_page_lruvec(page, zone);
 
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
@@ -3538,11 +3553,8 @@ void check_move_unevictable_pages(struct
 
 			VM_BUG_ON(PageActive(page));
 			ClearPageUnevictable(page);
-			__dec_zone_state(zone, NR_UNEVICTABLE);
-			lruvec = mem_cgroup_lru_move_lists(zone, page,
-						LRU_UNEVICTABLE, lru);
-			list_move(&page->lru, &lruvec->lists[lru]);
-			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
+			del_page_from_lru_list(page, lruvec, LRU_UNEVICTABLE);
+			add_page_to_lru_list(page, lruvec, lru);
 			pgrescued++;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
