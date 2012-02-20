Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 94BC66B0105
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:33:45 -0500 (EST)
Received: by dadv6 with SMTP id v6so7619126dad.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:33:44 -0800 (PST)
Date: Mon, 20 Feb 2012 15:33:20 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/10] mm/memcg: introduce page_relock_lruvec
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201532170.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Delete the mem_cgroup_page_lruvec() which we just added, replacing
it and nearby spin_lock_irq or spin_lock_irqsave of zone->lru_lock:
in most places by page_lock_lruvec() or page_relock_lruvec() (the
former being a simple case of the latter) or just by lock_lruvec().
unlock_lruvec() does the spin_unlock_irqrestore for them all.

page_relock_lruvec() is born from that "pagezone" pattern in swap.c
and vmscan.c, where we loop over an array of pages, switching lock
whenever the zone changes: bearing in mind that if we were to refine
that lock to per-memcg per-zone, then we would have to switch whenever
the memcg changes too.

page_relock_lruvec(page, &lruvec) locates the right lruvec for page,
unlocks the old lruvec if different (and not NULL), locks the new,
and updates lruvec on return: so that we shall have just one routine
to locate and lock the lruvec, whereas originally it got re-evaluated
at different stages.  But I don't yet know how to satisfy sparse(1).

There are some loops where we never change zone, and a non-memcg kernel
would not change memcg: use no-op mem_cgroup_page_relock_lruvec() there.

In compaction's isolate_migratepages(), although we do know the zone,
we don't know the lruvec in advance: allow for taking the lock later,
and reorganize its cond_resched() lock-dropping accordingly.

page_relock_lruvec() (and its wrappers) is actually an _irqsave operation:
there are a few cases in swap.c where it may be needed at interrupt time
(to free or to rotate a page on I/O completion).  Ideally(?) we would use
straightforward _irq disabling elsewhere, but the variants get confusing,
and page_relock_lruvec() will itself grow more complicated in subsequent
patches: so keep it simple for now with just the one irqsaver everywhere.

Passing an irqflags argument/pointer down several levels looks messy
too, and I'm reluctant to add any more to the page reclaim stack: so
save the irqflags alongside the lru_lock and restore them from there.

It's a little sad now to be including mm.h in swap.h to get page_zone();
but I think that swap.h (despite its name) is the right place for these
lru functions, and without those inlines the optimizer cannot do so
well in the !MEM_RES_CTLR case.

(Is this an appropriate place to confess? that even at the end of the
series, we're left with a small bug in putback_inactive_pages(), one
that I've not yet decided is worth fixing: reclaim_stat there is from
the lruvec on entry, but we might update stats after dropping its lock.
And do zone->pages_scanned and zone->all_unreclaimable need locking?
page_alloc.c thinks zone->lock, vmscan.c thought zone->lru_lock,
and that weakens if we now split lru_lock by memcg.)

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    7 --
 include/linux/mmzone.h     |    1 
 include/linux/swap.h       |   65 +++++++++++++++++++++++
 mm/compaction.c            |   45 ++++++++++------
 mm/huge_memory.c           |   10 +--
 mm/memcontrol.c            |   56 ++++++++++++--------
 mm/swap.c                  |   67 +++++++-----------------
 mm/vmscan.c                |   95 ++++++++++++++++-------------------
 8 files changed, 194 insertions(+), 152 deletions(-)

--- mmotm.orig/include/linux/memcontrol.h	2012-02-18 11:57:35.583524425 -0800
+++ mmotm/include/linux/memcontrol.h	2012-02-18 11:57:42.675524592 -0800
@@ -63,7 +63,6 @@ extern int mem_cgroup_cache_charge(struc
 					gfp_t gfp_mask);
 
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
-extern struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 extern struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec);
 extern void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
 
@@ -241,12 +240,6 @@ static inline struct lruvec *mem_cgroup_
 {
 	return &zone->lruvec;
 }
-
-static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
-						    struct zone *zone)
-{
-	return &zone->lruvec;
-}
 
 static inline struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec)
 {
--- mmotm.orig/include/linux/mmzone.h	2012-02-18 11:57:28.371524252 -0800
+++ mmotm/include/linux/mmzone.h	2012-02-18 11:57:42.675524592 -0800
@@ -374,6 +374,7 @@ struct zone {
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	spinlock_t		lru_lock;
+	unsigned long		irqflags;
 	struct lruvec		lruvec;
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
--- mmotm.orig/include/linux/swap.h	2012-02-18 11:57:35.583524425 -0800
+++ mmotm/include/linux/swap.h	2012-02-18 11:57:42.675524592 -0800
@@ -8,7 +8,7 @@
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
 #include <linux/node.h>
-
+#include <linux/mm.h>			/* for page_zone(page) */
 #include <linux/atomic.h>
 #include <asm/page.h>
 
@@ -250,6 +250,69 @@ static inline void lru_cache_add_file(st
 	__lru_cache_add(page, LRU_INACTIVE_FILE);
 }
 
+static inline spinlock_t *lru_lockptr(struct lruvec *lruvec)
+{
+	return &lruvec->zone->lru_lock;
+}
+
+static inline void lock_lruvec(struct lruvec *lruvec)
+{
+	struct zone *zone = lruvec->zone;
+	unsigned long irqflags;
+
+	spin_lock_irqsave(&zone->lru_lock, irqflags);
+	zone->irqflags = irqflags;
+}
+
+static inline void unlock_lruvec(struct lruvec *lruvec)
+{
+	struct zone *zone = lruvec->zone;
+	unsigned long irqflags;
+
+	irqflags = zone->irqflags;
+	spin_unlock_irqrestore(&zone->lru_lock, irqflags);
+}
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/* linux/mm/memcontrol.c */
+extern void page_relock_lruvec(struct page *page, struct lruvec **lruvp);
+
+static inline void
+mem_cgroup_page_relock_lruvec(struct page *page, struct lruvec **lruvp)
+{
+	page_relock_lruvec(page, lruvp);
+}
+#else
+static inline void page_relock_lruvec(struct page *page, struct lruvec **lruvp)
+{
+	struct lruvec *lruvec;
+
+	lruvec = &page_zone(page)->lruvec;
+	if (*lruvp && *lruvp != lruvec) {
+		unlock_lruvec(*lruvp);
+		*lruvp = NULL;
+	}
+	if (!*lruvp) {
+		*lruvp = lruvec;
+		lock_lruvec(lruvec);
+	}
+}
+
+static inline void
+mem_cgroup_page_relock_lruvec(struct page *page, struct lruvec **lruvp)
+{
+	/* No-op used in a few places where zone is known not to change */
+}
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
+
+static inline struct lruvec *page_lock_lruvec(struct page *page)
+{
+	struct lruvec *lruvec = NULL;
+
+	page_relock_lruvec(page, &lruvec);
+	return lruvec;
+}
+
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
--- mmotm.orig/mm/compaction.c	2012-02-18 11:57:35.583524425 -0800
+++ mmotm/mm/compaction.c	2012-02-18 11:57:42.675524592 -0800
@@ -262,7 +262,7 @@ static isolate_migrate_t isolate_migrate
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
-	struct lruvec *lruvec;
+	struct lruvec *lruvec = NULL;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -293,26 +293,23 @@ static isolate_migrate_t isolate_migrate
 	}
 
 	/* Time to isolate some pages for migration */
-	cond_resched();
-	spin_lock_irq(&zone->lru_lock);
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
-		bool locked = true;
 
-		/* give a chance to irqs before checking need_resched() */
-		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
-			spin_unlock_irq(&zone->lru_lock);
-			locked = false;
-		}
-		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
-			if (locked)
-				spin_unlock_irq(&zone->lru_lock);
+		/* give a chance to irqs before cond_resched() */
+		if (lruvec) {
+			if (!((low_pfn+1) % SWAP_CLUSTER_MAX) ||
+			    spin_is_contended(lru_lockptr(lruvec)) ||
+			    need_resched()) {
+				unlock_lruvec(lruvec);
+				lruvec = NULL;
+			}
+		}
+		if (!lruvec) {
 			cond_resched();
-			spin_lock_irq(&zone->lru_lock);
 			if (fatal_signal_pending(current))
 				break;
-		} else if (!locked)
-			spin_lock_irq(&zone->lru_lock);
+		}
 
 		/*
 		 * migrate_pfn does not necessarily start aligned to a
@@ -359,6 +356,15 @@ static isolate_migrate_t isolate_migrate
 			continue;
 		}
 
+		if (!lruvec) {
+			/*
+			 * We do need to take the lock before advancing to
+			 * check PageLRU etc., but there's no guarantee that
+			 * the page we're peeking at has a stable memcg here.
+			 */
+			lruvec = &zone->lruvec;
+			lock_lruvec(lruvec);
+		}
 		if (!PageLRU(page))
 			continue;
 
@@ -379,7 +385,7 @@ static isolate_migrate_t isolate_migrate
 		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		page_relock_lruvec(page, &lruvec);
 
 		VM_BUG_ON(PageTransCompound(page));
 
@@ -396,9 +402,14 @@ static isolate_migrate_t isolate_migrate
 		}
 	}
 
+	if (!lruvec)
+		local_irq_disable();
 	acct_isolated(zone, cc);
+	if (lruvec)
+		unlock_lruvec(lruvec);
+	else
+		local_irq_enable();
 
-	spin_unlock_irq(&zone->lru_lock);
 	cc->migrate_pfn = low_pfn;
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
--- mmotm.orig/mm/huge_memory.c	2012-02-18 11:57:35.583524425 -0800
+++ mmotm/mm/huge_memory.c	2012-02-18 11:57:42.679524592 -0800
@@ -1222,13 +1222,11 @@ static int __split_huge_page_splitting(s
 static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
-	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
-	lruvec = mem_cgroup_page_lruvec(page, zone);
+	lruvec = page_lock_lruvec(page);
 
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
@@ -1310,12 +1308,12 @@ static void __split_huge_page_refcount(s
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
-	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+	__mod_zone_page_state(lruvec->zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
+	__mod_zone_page_state(lruvec->zone, NR_ANON_PAGES, HPAGE_PMD_NR);
 
 	ClearPageCompound(page);
 	compound_unlock(page);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec(lruvec);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
--- mmotm.orig/mm/memcontrol.c	2012-02-18 11:57:35.587524424 -0800
+++ mmotm/mm/memcontrol.c	2012-02-18 11:57:42.679524592 -0800
@@ -1037,23 +1037,36 @@ struct mem_cgroup *mem_cgroup_from_lruve
  */
 
 /**
- * mem_cgroup_page_lruvec - return lruvec for adding an lru page
+ * page_relock_lruvec - lock and update lruvec for this page, unlocking previous
  * @page: the page
- * @zone: zone of the page
+ * @lruvp: pointer to where to output lruvec; unlock input lruvec if non-NULL
  */
-struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
+void page_relock_lruvec(struct page *page, struct lruvec **lruvp)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc;
+	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled())
-		return &zone->lruvec;
+		lruvec = &page_zone(page)->lruvec;
+	else {
+		pc = lookup_page_cgroup(page);
+		memcg = pc->mem_cgroup;
+		mz = page_cgroup_zoneinfo(memcg, page);
+		lruvec = &mz->lruvec;
+	}
 
-	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
-	mz = page_cgroup_zoneinfo(memcg, page);
-	return &mz->lruvec;
+	/*
+	 * For the moment, simply lock by zone just as before.
+	 */
+	if (*lruvp && (*lruvp)->zone != lruvec->zone) {
+		unlock_lruvec(*lruvp);
+		*lruvp = NULL;
+	}
+	if (!*lruvp)
+		lock_lruvec(lruvec);
+	*lruvp = lruvec;
 }
 
 /**
@@ -2631,30 +2644,27 @@ __mem_cgroup_commit_charge_lrucare(struc
 					enum charge_type ctype)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-	struct zone *zone = page_zone(page);
-	unsigned long flags;
-	bool removed = false;
 	struct lruvec *lruvec;
+	bool removed = false;
 
 	/*
 	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
 	 * is already on LRU. It means the page may on some other page_cgroup's
 	 * LRU. Take care of it.
 	 */
-	spin_lock_irqsave(&zone->lru_lock, flags);
+	lruvec = page_lock_lruvec(page);
 	if (PageLRU(page)) {
-		lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		ClearPageLRU(page);
 		removed = true;
 	}
 	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
 	if (removed) {
-		lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
+		page_relock_lruvec(page, &lruvec);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 		SetPageLRU(page);
 	}
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	unlock_lruvec(lruvec);
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -3572,15 +3582,15 @@ static int mem_cgroup_force_empty_list(s
 				int node, int zid, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
-	unsigned long flags, loop;
+	unsigned long loop;
 	struct list_head *list;
 	struct page *busy;
-	struct zone *zone;
+	struct lruvec *lruvec;
 	int ret = 0;
 
-	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	list = &mz->lruvec.lists[lru];
+	lruvec = &mz->lruvec;
+	list = &lruvec->lists[lru];
 
 	loop = mz->lru_size[lru];
 	/* give some margin against EBUSY etc...*/
@@ -3591,19 +3601,19 @@ static int mem_cgroup_force_empty_list(s
 		struct page *page;
 
 		ret = 0;
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		lock_lruvec(lruvec);
 		if (list_empty(list)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			unlock_lruvec(lruvec);
 			break;
 		}
 		page = list_entry(list->prev, struct page, lru);
 		if (busy == page) {
 			list_move(&page->lru, list);
 			busy = NULL;
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			unlock_lruvec(lruvec);
 			continue;
 		}
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		unlock_lruvec(lruvec);
 
 		pc = lookup_page_cgroup(page);
 
--- mmotm.orig/mm/swap.c	2012-02-18 11:57:35.587524424 -0800
+++ mmotm/mm/swap.c	2012-02-18 11:57:42.679524592 -0800
@@ -47,16 +47,13 @@ static DEFINE_PER_CPU(struct pagevec, lr
 static void __page_cache_release(struct page *page)
 {
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
-		unsigned long flags;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = page_lock_lruvec(page);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		unlock_lruvec(lruvec);
 	}
 }
 
@@ -208,26 +205,16 @@ static void pagevec_lru_move_fn(struct p
 	void *arg)
 {
 	int i;
-	struct zone *zone = NULL;
-	struct lruvec *lruvec;
-	unsigned long flags = 0;
+	struct lruvec *lruvec = NULL;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
 
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-			zone = pagezone;
-			spin_lock_irqsave(&zone->lru_lock, flags);
-		}
-
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		page_relock_lruvec(page, &lruvec);
 		(*move_fn)(page, lruvec, arg);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (lruvec)
+		unlock_lruvec(lruvec);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
@@ -334,11 +321,11 @@ static inline void activate_page_drain(i
 
 void activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
 
-	spin_lock_irq(&zone->lru_lock);
-	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
-	spin_unlock_irq(&zone->lru_lock);
+	lruvec = page_lock_lruvec(page);
+	__activate_page(page, lruvec, NULL);
+	unlock_lruvec(lruvec);
 }
 #endif
 
@@ -403,15 +390,13 @@ void lru_cache_add_lru(struct page *page
  */
 void add_page_to_unevictable_list(struct page *page)
 {
-	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 
-	spin_lock_irq(&zone->lru_lock);
-	lruvec = mem_cgroup_page_lruvec(page, zone);
+	lruvec = page_lock_lruvec(page);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec(lruvec);
 }
 
 /*
@@ -577,17 +562,15 @@ void release_pages(struct page **pages,
 {
 	int i;
 	LIST_HEAD(pages_to_free);
-	struct zone *zone = NULL;
-	struct lruvec *lruvec;
-	unsigned long uninitialized_var(flags);
+	struct lruvec *lruvec = NULL;
 
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
 		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				zone = NULL;
+			if (lruvec) {
+				unlock_lruvec(lruvec);
+				lruvec = NULL;
 			}
 			put_compound_page(page);
 			continue;
@@ -597,17 +580,7 @@ void release_pages(struct page **pages,
 			continue;
 
 		if (PageLRU(page)) {
-			struct zone *pagezone = page_zone(page);
-
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irqrestore(&zone->lru_lock,
-									flags);
-				zone = pagezone;
-				spin_lock_irqsave(&zone->lru_lock, flags);
-			}
-
-			lruvec = mem_cgroup_page_lruvec(page, zone);
+			page_relock_lruvec(page, &lruvec);
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
@@ -615,8 +588,8 @@ void release_pages(struct page **pages,
 
 		list_add(&page->lru, &pages_to_free);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (lruvec)
+		unlock_lruvec(lruvec);
 
 	free_hot_cold_page_list(&pages_to_free, cold);
 }
@@ -652,7 +625,7 @@ void lru_add_page_tail(struct page *page
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&lruvec->zone->lru_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(lru_lockptr(lruvec)));
 
 	SetPageLRU(page_tail);
 
--- mmotm.orig/mm/vmscan.c	2012-02-18 11:57:35.587524424 -0800
+++ mmotm/mm/vmscan.c	2012-02-18 11:57:42.679524592 -0800
@@ -1212,8 +1212,8 @@ static unsigned long isolate_lru_pages(u
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				lruvec = mem_cgroup_page_lruvec(cursor_page,
-								lruvec->zone);
+				mem_cgroup_page_relock_lruvec(cursor_page,
+								&lruvec);
 				isolated_pages = hpage_nr_pages(cursor_page);
 				mem_cgroup_update_lru_size(lruvec,
 					page_lru(cursor_page), -isolated_pages);
@@ -1294,11 +1294,9 @@ int isolate_lru_page(struct page *page)
 	VM_BUG_ON(!page_count(page));
 
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(&zone->lru_lock);
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		lruvec = page_lock_lruvec(page);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			get_page(page);
@@ -1306,7 +1304,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_lruvec(lruvec);
 	}
 	return ret;
 }
@@ -1337,10 +1335,9 @@ static int too_many_isolated(struct zone
 }
 
 static noinline_for_stack void
-putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
+putback_inactive_pages(struct lruvec **lruvec, struct list_head *page_list)
 {
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	struct zone *zone = lruvec->zone;
+	struct zone_reclaim_stat *reclaim_stat = &(*lruvec)->reclaim_stat;
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1353,17 +1350,18 @@ putback_inactive_pages(struct lruvec *lr
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page, NULL))) {
-			spin_unlock_irq(&zone->lru_lock);
+			unlock_lruvec(*lruvec);
 			putback_lru_page(page);
-			spin_lock_irq(&zone->lru_lock);
+			lock_lruvec(*lruvec);
 			continue;
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		/* lock lru, occasionally changing lruvec */
+		mem_cgroup_page_relock_lruvec(page, lruvec);
 
 		SetPageLRU(page);
 		lru = page_lru(page);
-		add_page_to_lru_list(page, lruvec, lru);
+		add_page_to_lru_list(page, *lruvec, lru);
 
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
@@ -1373,12 +1371,12 @@ putback_inactive_pages(struct lruvec *lr
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
-			del_page_from_lru_list(page, lruvec, lru);
+			del_page_from_lru_list(page, *lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				unlock_lruvec(*lruvec);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				lock_lruvec(*lruvec);
 			} else
 				list_add(&page->lru, &pages_to_free);
 		}
@@ -1513,7 +1511,7 @@ shrink_inactive_list(unsigned long nr_to
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec(lruvec);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, 0, file);
@@ -1524,7 +1522,7 @@ shrink_inactive_list(unsigned long nr_to
 		else
 			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec(lruvec);
 
 	if (nr_taken == 0)
 		return 0;
@@ -1541,7 +1539,7 @@ shrink_inactive_list(unsigned long nr_to
 					priority, &nr_dirty, &nr_writeback);
 	}
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec(lruvec);
 
 	reclaim_stat->recent_scanned[0] += nr_anon;
 	reclaim_stat->recent_scanned[1] += nr_file;
@@ -1550,12 +1548,12 @@ shrink_inactive_list(unsigned long nr_to
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_inactive_pages(lruvec, &page_list);
+	putback_inactive_pages(&lruvec, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec(lruvec);
 
 	free_hot_cold_page_list(&page_list, 1);
 
@@ -1611,42 +1609,44 @@ shrink_inactive_list(unsigned long nr_to
  * But we had to alter page->flags anyway.
  */
 
-static void move_active_pages_to_lru(struct lruvec *lruvec,
+static void move_active_pages_to_lru(struct lruvec **lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
 {
-	struct zone *zone = lruvec->zone;
 	unsigned long pgmoved = 0;
 	struct page *page;
 	int nr_pages;
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+
+		/* lock lru, occasionally changing lruvec */
+		mem_cgroup_page_relock_lruvec(page, lruvec);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
 		nr_pages = hpage_nr_pages(page);
-		list_move(&page->lru, &lruvec->lists[lru]);
-		mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+		list_move(&page->lru, &(*lruvec)->lists[lru]);
+		mem_cgroup_update_lru_size(*lruvec, lru, nr_pages);
 		pgmoved += nr_pages;
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
-			del_page_from_lru_list(page, lruvec, lru);
+			del_page_from_lru_list(page, *lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				unlock_lruvec(*lruvec);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				lock_lruvec(*lruvec);
 			} else
 				list_add(&page->lru, pages_to_free);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+
+	__mod_zone_page_state((*lruvec)->zone, NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1676,7 +1676,7 @@ static void shrink_active_list(unsigned
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec(lruvec);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, 1, file);
@@ -1691,7 +1691,8 @@ static void shrink_active_list(unsigned
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+
+	unlock_lruvec(lruvec);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1735,7 +1736,7 @@ static void shrink_active_list(unsigned
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec(lruvec);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1744,12 +1745,13 @@ static void shrink_active_list(unsigned
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(lruvec, &l_active, &l_hold,
+	move_active_pages_to_lru(&lruvec, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold,
+	move_active_pages_to_lru(&lruvec, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+
+	unlock_lruvec(lruvec);
 
 	free_hot_cold_page_list(&l_hold, 1);
 }
@@ -1940,7 +1942,7 @@ static void get_scan_count(struct lruvec
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec(lruvec);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1961,7 +1963,7 @@ static void get_scan_count(struct lruvec
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec(lruvec);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3525,25 +3527,16 @@ int page_evictable(struct page *page, st
  */
 void check_move_unevictable_pages(struct page **pages, int nr_pages)
 {
-	struct lruvec *lruvec;
-	struct zone *zone = NULL;
+	struct lruvec *lruvec = NULL;
 	int pgscanned = 0;
 	int pgrescued = 0;
 	int i;
 
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page = pages[i];
-		struct zone *pagezone;
 
 		pgscanned++;
-		pagezone = page_zone(page);
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+		page_relock_lruvec(page, &lruvec);
 
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
@@ -3559,10 +3552,10 @@ void check_move_unevictable_pages(struct
 		}
 	}
 
-	if (zone) {
+	if (lruvec) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_lruvec(lruvec);
 	}
 }
 #endif /* CONFIG_SHMEM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
