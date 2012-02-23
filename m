Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 042326B00F6
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:52:51 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:52:51 -0800 (PST)
Subject: [PATCH v3 14/21] mm: introduce lruvec locking primitives
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:52:47 +0400
Message-ID: <20120223135247.12988.49745.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

This is initial preparation for lru_lock splitting.

This locking primites designed to hide splitted nature of lru_lock
and to avoid overhead for non-splitted lru_lock in non-memcg case.

* Lock via lruvec reference

lock_lruvec(lruvec, flags)
lock_lruvec_irq(lruvec)

* Lock via page reference

lock_page_lruvec(page, flags)
lock_page_lruvec_irq(page)
relock_page_lruvec(lruvec, page, flags)
relock_page_lruvec_irq(lruvec, page)
__relock_page_lruvec(lruvec, page) ( lruvec != NULL, page in same zone )

They always returns pointer to some locked lruvec, page anyway can be
not in lru, PageLRU() sign is stable while we hold returned lruvec lock.
Caller must guarantee page to lruvec reference validity.

* Lock via page, without stable page reference

__lock_page_lruvec_irq(&lruvec, page)

It returns true of lruvec succesfully locked and PageLRU is set.
Initial lruvec can be NULL. Consequent calls must be in the same zone.

* Unlock

unlock_lruvec(lruvec, flags)
unlock_lruvec_irq(lruvec)

* Wait

wait_lruvec_unlock(lruvec)
Wait for lruvec unlock, caller must have stable reference to lruvec.

__wait_lruvec_unlock(lruvec)
Wait for lruvec unlock before locking other lrulock for same page,
nothing if there only one possible lruvec per page.
Used at page-to-lruvec reference switching to stabilize PageLRU sign.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/huge_memory.c |    8 +-
 mm/internal.h    |  176 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c  |   14 ++--
 mm/swap.c        |   58 ++++++------------
 mm/vmscan.c      |   77 ++++++++++--------------
 5 files changed, 237 insertions(+), 96 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 09e7069..74996b8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1228,13 +1228,11 @@ static int __split_huge_page_splitting(struct page *page,
 static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
-	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
-	lruvec = page_lruvec(page);
+	lruvec = lock_page_lruvec_irq(page);
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
@@ -1316,11 +1314,11 @@ static void __split_huge_page_refcount(struct page *page)
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+	__mod_zone_page_state(lruvec_zone(lruvec), NR_ANON_PAGES, HPAGE_PMD_NR);
 
 	ClearPageCompound(page);
 	compound_unlock(page);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec_irq(lruvec);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
diff --git a/mm/internal.h b/mm/internal.h
index ef49dbf..9454752 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -13,6 +13,182 @@
 
 #include <linux/mm.h>
 
+static inline void lock_lruvec(struct lruvec *lruvec, unsigned long *flags)
+{
+	spin_lock_irqsave(&lruvec_zone(lruvec)->lru_lock, *flags);
+}
+
+static inline void lock_lruvec_irq(struct lruvec *lruvec)
+{
+	spin_lock_irq(&lruvec_zone(lruvec)->lru_lock);
+}
+
+static inline void unlock_lruvec(struct lruvec *lruvec, unsigned long *flags)
+{
+	spin_unlock_irqrestore(&lruvec_zone(lruvec)->lru_lock, *flags);
+}
+
+static inline void unlock_lruvec_irq(struct lruvec *lruvec)
+{
+	spin_unlock_irq(&lruvec_zone(lruvec)->lru_lock);
+}
+
+static inline void wait_lruvec_unlock(struct lruvec *lruvec)
+{
+	spin_unlock_wait(&lruvec_zone(lruvec)->lru_lock);
+}
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+
+/* Dynamic page to lruvec mapping */
+
+/* Lock other lruvec for other page in the same zone */
+static inline struct lruvec *__relock_page_lruvec(struct lruvec *locked_lruvec,
+						  struct page *page)
+{
+	/* Currenyly only one lru_lock per-zone */
+	return page_lruvec(page);
+}
+
+static inline struct lruvec *relock_page_lruvec_irq(struct lruvec *lruvec,
+						    struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	if (!lruvec) {
+		spin_lock_irq(&zone->lru_lock);
+	} else if (zone != lruvec_zone(lruvec)) {
+		unlock_lruvec_irq(lruvec);
+		spin_lock_irq(&zone->lru_lock);
+	}
+	return page_lruvec(page);
+}
+
+static inline struct lruvec *relock_page_lruvec(struct lruvec *lruvec,
+						struct page *page,
+						unsigned long *flags)
+{
+	struct zone *zone = page_zone(page);
+
+	if (!lruvec) {
+		spin_lock_irqsave(&zone->lru_lock, *flags);
+	} else if (zone != lruvec_zone(lruvec)) {
+		unlock_lruvec(lruvec, flags);
+		spin_lock_irqsave(&zone->lru_lock, *flags);
+	}
+	return page_lruvec(page);
+}
+
+/*
+ * Caller may not have stable reference to page.
+ * Page for next call must be from the same zone.
+ * Returns true if page successfully catched in LRU.
+ */
+static inline bool __lock_page_lruvec_irq(struct lruvec **lruvec,
+					  struct page *page)
+{
+	struct zone *zone;
+	bool ret = false;
+
+	if (PageLRU(page)) {
+		if (!*lruvec) {
+			zone = page_zone(page);
+			spin_lock_irq(&zone->lru_lock);
+		} else
+			zone = lruvec_zone(*lruvec);
+
+		if (PageLRU(page)) {
+			*lruvec = page_lruvec(page);
+			ret = true;
+		} else
+			*lruvec = &zone->lruvec;
+	}
+
+	return ret;
+}
+
+/* Wait for lruvec unlock before locking other lruvec for the same page */
+static inline void __wait_lruvec_unlock(struct lruvec *lruvec)
+{
+	/* Currently only one lru_lock per-zone */
+}
+
+#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+
+/* Fixed page to lruvec mapping */
+
+/* Lock lruvec for other page in the same zone */
+static inline struct lruvec *__relock_page_lruvec(struct lruvec *locked_lruvec,
+						  struct page *page)
+{
+	/* Currently ony one lruvec per-zone */
+	return locked_lruvec;
+}
+
+static inline struct lruvec *relock_page_lruvec(struct lruvec *locked_lruvec,
+						struct page *page,
+						unsigned long *flags)
+{
+	struct lruvec *lruvec = page_lruvec(page);
+
+	if (!locked_lruvec) {
+		lock_lruvec(lruvec, flags);
+	} else if (locked_lruvec != lruvec) {
+		unlock_lruvec(locked_lruvec, flags);
+		lock_lruvec(lruvec, flags);
+	}
+
+	return lruvec;
+}
+
+static inline struct lruvec *relock_page_lruvec_irq(
+		struct lruvec *locked_lruvec, struct page *page)
+{
+	struct lruvec *lruvec = page_lruvec(page);
+
+	if (!locked_lruvec) {
+		lock_lruvec_irq(lruvec);
+	} else if (locked_lruvec != lruvec) {
+		unlock_lruvec_irq(locked_lruvec);
+		lock_lruvec_irq(lruvec);
+	}
+
+	return lruvec;
+}
+
+static inline bool __lock_page_lruvec_irq(struct lruvec **lruvec,
+					  struct page *page)
+{
+	bool ret = false;
+
+	if (PageLRU(page)) {
+		*lruvec = relock_page_lruvec_irq(*lruvec, page);
+		if (PageLRU(page))
+			ret = true;
+	}
+
+	return ret;
+}
+
+/* Wait for lruvec unlock before locking other lruvec for the same page */
+static inline void __wait_lruvec_unlock(struct lruvec *lruvec)
+{
+	/* Fixed page to lruvec mapping, there only one possible lruvec */
+}
+
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
+
+static inline struct lruvec *lock_page_lruvec(struct page *page,
+					      unsigned long *flags)
+{
+	return relock_page_lruvec(NULL, page, flags);
+}
+
+static inline struct lruvec *lock_page_lruvec_irq(struct page *page)
+{
+	return relock_page_lruvec_irq(NULL, page);
+}
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 83fa99b..aed1360 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3487,12 +3487,14 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 	struct list_head *list;
 	struct page *busy;
 	struct zone *zone;
+	struct lruvec *lruvec;
 	int ret = 0;
 
 	zone = &NODE_DATA(node)->node_zones[zid];
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
-	list = &mz->lruvec.pages_lru[lru];
-	loop = mz->lruvec.pages_count[lru];
+	lruvec = &mz->lruvec;
+	list = &lruvec->pages_lru[lru];
+	loop = lruvec->pages_count[lru];
 	/* give some margin against EBUSY etc...*/
 	loop += 256;
 	busy = NULL;
@@ -3501,19 +3503,19 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 		struct page *page;
 
 		ret = 0;
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		lock_lruvec(lruvec, &flags);
 		if (list_empty(list)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			unlock_lruvec(lruvec, &flags);
 			break;
 		}
 		page = list_entry(list->prev, struct page, lru);
 		if (busy == page) {
 			list_move(&page->lru, list);
 			busy = NULL;
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			unlock_lruvec(lruvec, &flags);
 			continue;
 		}
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		unlock_lruvec(lruvec, &flags);
 
 		pc = lookup_page_cgroup(page);
 
diff --git a/mm/swap.c b/mm/swap.c
index f7b5896..3689e3d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -48,15 +48,13 @@ static void __page_cache_release(struct page *page)
 {
 	if (PageLRU(page)) {
 		unsigned long flags;
-		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		lruvec = lock_page_lruvec(page, &flags);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		lruvec = page_lruvec(page);
 		del_page_from_lru_list(lruvec, page, page_off_lru(page));
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		unlock_lruvec(lruvec, &flags);
 	}
 }
 
@@ -209,26 +207,17 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 				void *arg)
 {
 	int i;
-	struct zone *zone = NULL;
+	struct lruvec *lruvec = NULL;
 	unsigned long flags = 0;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-		struct lruvec *lruvec;
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-			zone = pagezone;
-			spin_lock_irqsave(&zone->lru_lock, flags);
-		}
 
-		lruvec = page_lruvec(page);
+		lruvec = relock_page_lruvec(lruvec, page, &flags);
 		(*move_fn)(lruvec, page, arg);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (lruvec)
+		unlock_lruvec(lruvec, &flags);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
@@ -335,11 +324,11 @@ static inline void activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
 
-	spin_lock_irq(&zone->lru_lock);
+	lruvec = lock_page_lruvec_irq(page);
 	__activate_page(page, NULL);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec_irq(lruvec);
 }
 #endif
 
@@ -404,15 +393,13 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
  */
 void add_page_to_unevictable_list(struct page *page)
 {
-	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 
-	spin_lock_irq(&zone->lru_lock);
+	lruvec = lock_page_lruvec_irq(page);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
-	lruvec = page_lruvec(page);
 	add_page_to_lru_list(lruvec, page, LRU_UNEVICTABLE);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec_irq(lruvec);
 }
 
 /*
@@ -577,16 +564,16 @@ void release_pages(struct page **pages, int nr, int cold)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
-	struct zone *zone = NULL;
+	struct lruvec *lruvec = NULL;
 	unsigned long uninitialized_var(flags);
 
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
 		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				zone = NULL;
+			if (lruvec) {
+				unlock_lruvec(lruvec, &flags);
+				lruvec = NULL;
 			}
 			put_compound_page(page);
 			continue;
@@ -596,16 +583,7 @@ void release_pages(struct page **pages, int nr, int cold)
 			continue;
 
 		if (PageLRU(page)) {
-			struct zone *pagezone = page_zone(page);
-			struct lruvec *lruvec = page_lruvec(page);
-
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irqrestore(&zone->lru_lock,
-									flags);
-				zone = pagezone;
-				spin_lock_irqsave(&zone->lru_lock, flags);
-			}
+			lruvec = relock_page_lruvec(lruvec, page, &flags);
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
 			del_page_from_lru_list(lruvec, page, page_off_lru(page));
@@ -613,8 +591,8 @@ void release_pages(struct page **pages, int nr, int cold)
 
 		list_add(&page->lru, &pages_to_free);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (lruvec)
+		unlock_lruvec(lruvec, &flags);
 
 	free_hot_cold_page_list(&pages_to_free, cold);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ebb5d99..a3941d1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1285,19 +1285,17 @@ int isolate_lru_page(struct page *page)
 	VM_BUG_ON(!page_count(page));
 
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(&zone->lru_lock);
+		lruvec = lock_page_lruvec_irq(page);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
-			lruvec = page_lruvec(page);
 			del_page_from_lru_list(lruvec, page, lru);
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_lruvec_irq(lruvec);
 	}
 	return ret;
 }
@@ -1332,7 +1330,6 @@ putback_inactive_pages(struct lruvec *lruvec,
 		       struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	struct zone *zone = lruvec_zone(lruvec);
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1340,15 +1337,14 @@ putback_inactive_pages(struct lruvec *lruvec,
 	 */
 	while (!list_empty(page_list)) {
 		struct page *page = lru_to_page(page_list);
-		struct lruvec *lruvec;
 		int lru;
 
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page, NULL))) {
-			spin_unlock_irq(&zone->lru_lock);
+			unlock_lruvec_irq(lruvec);
 			putback_lru_page(page);
-			spin_lock_irq(&zone->lru_lock);
+			lock_lruvec_irq(lruvec);
 			continue;
 		}
 		SetPageLRU(page);
@@ -1367,9 +1363,9 @@ putback_inactive_pages(struct lruvec *lruvec,
 			del_page_from_lru_list(lruvec, page, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				unlock_lruvec_irq(lruvec);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				lock_lruvec_irq(lruvec);
 			} else
 				list_add(&page->lru, &pages_to_free);
 		}
@@ -1505,7 +1501,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec_irq(lruvec);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, 0, file);
@@ -1521,7 +1517,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	}
 
 	if (nr_taken == 0) {
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_lruvec_irq(lruvec);
 		return 0;
 	}
 
@@ -1530,7 +1526,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec_irq(lruvec);
 
 	nr_reclaimed = shrink_page_list(&page_list, lruvec, sc, priority,
 						&nr_dirty, &nr_writeback);
@@ -1542,7 +1538,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 					priority, &nr_dirty, &nr_writeback);
 	}
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec_irq(lruvec);
 
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
@@ -1553,7 +1549,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec_irq(lruvec);
 
 	free_hot_cold_page_list(&page_list, 1);
 
@@ -1609,7 +1605,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  * But we had to alter page->flags anyway.
  */
 
-static void move_active_pages_to_lru(struct zone *zone,
+static void move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
@@ -1618,7 +1614,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 	struct page *page;
 
 	if (buffer_heads_over_limit) {
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_lruvec_irq(lruvec);
 		list_for_each_entry(page, list, lru) {
 			if (page_has_private(page) && trylock_page(page)) {
 				if (page_has_private(page))
@@ -1626,11 +1622,10 @@ static void move_active_pages_to_lru(struct zone *zone,
 				unlock_page(page);
 			}
 		}
-		spin_lock_irq(&zone->lru_lock);
+		lock_lruvec_irq(lruvec);
 	}
 
 	while (!list_empty(list)) {
-		struct lruvec *lruvec;
 		int numpages;
 
 		page = lru_to_page(list);
@@ -1650,14 +1645,14 @@ static void move_active_pages_to_lru(struct zone *zone,
 			del_page_from_lru_list(lruvec, page, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				unlock_lruvec_irq(lruvec);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				lock_lruvec_irq(lruvec);
 			} else
 				list_add(&page->lru, pages_to_free);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1686,7 +1681,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_writepage)
 		isolate_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec_irq(lruvec);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold, &nr_scanned,
 				     sc, isolate_mode, 1, file);
@@ -1702,7 +1697,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+
+	unlock_lruvec_irq(lruvec);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1739,7 +1735,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec_irq(lruvec);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1748,12 +1744,12 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(zone, &l_active, &l_hold,
+	move_active_pages_to_lru(lruvec, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive, &l_hold,
+	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec_irq(lruvec);
 
 	free_hot_cold_page_list(&l_hold, 1);
 }
@@ -1952,7 +1948,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	lock_lruvec_irq(lruvec);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1973,7 +1969,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_lruvec_irq(lruvec);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3518,24 +3514,16 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
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
+		lruvec = relock_page_lruvec_irq(lruvec, page);
 
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
@@ -3545,21 +3533,20 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 
 			VM_BUG_ON(PageActive(page));
 			ClearPageUnevictable(page);
-			__dec_zone_state(zone, NR_UNEVICTABLE);
-			lruvec = page_lruvec(page);
+			__dec_zone_state(lruvec_zone(lruvec), NR_UNEVICTABLE);
 			lruvec->pages_count[LRU_UNEVICTABLE]--;
 			VM_BUG_ON((long)lruvec->pages_count[LRU_UNEVICTABLE] < 0);
 			lruvec->pages_count[lru]++;
 			list_move(&page->lru, &lruvec->pages_lru[lru]);
-			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
+			__inc_zone_state(lruvec_zone(lruvec), NR_INACTIVE_ANON + lru);
 			pgrescued++;
 		}
 	}
 
-	if (zone) {
+	if (lruvec) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_lruvec_irq(lruvec);
 	}
 }
 #endif /* CONFIG_SHMEM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
