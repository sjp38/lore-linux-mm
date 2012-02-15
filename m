Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 13F4A6B00EB
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:40 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:39 -0800 (PST)
Subject: [PATCH RFC 08/15] mm: introduce book locking primitives
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:36 +0400
Message-ID: <20120215225736.22050.41988.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

This is initial preparation for lru_lock splitting.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm_inline.h |  135 +++++++++++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c          |   10 ++-
 mm/memcontrol.c           |    8 +--
 mm/swap.c                 |   56 ++++++-------------
 mm/vmscan.c               |   81 +++++++++++----------------
 5 files changed, 196 insertions(+), 94 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 286da9b..9cb3a7e 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -36,6 +36,141 @@ static inline struct pglist_data *book_node(struct book *book)
 
 #endif /* CONFIG_MEMORY_BOOKKEEPING */
 
+static inline void lock_book(struct book *book, unsigned long *flags)
+{
+	spin_lock_irqsave(&book_zone(book)->lru_lock, *flags);
+}
+
+static inline void lock_book_irq(struct book *book)
+{
+	spin_lock_irq(&book_zone(book)->lru_lock);
+}
+
+static inline void unlock_book(struct book *book, unsigned long *flags)
+{
+	spin_unlock_irqrestore(&book_zone(book)->lru_lock, *flags);
+}
+
+static inline void unlock_book_irq(struct book *book)
+{
+	spin_unlock_irq(&book_zone(book)->lru_lock);
+}
+
+#ifdef CONFIG_MEMORY_BOOKKEEPING
+
+static inline struct book *lock_page_book(struct page *page,
+					  unsigned long *flags)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irqsave(&zone->lru_lock, *flags);
+	return page_book(page);
+}
+
+static inline struct book *lock_page_book_irq(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	return page_book(page);
+}
+
+static inline struct book *relock_page_book(struct book *locked_book,
+					    struct page *page,
+					    unsigned long *flags)
+{
+	struct zone *zone = page_zone(page);
+
+	if (!locked_book || zone != book_zone(locked_book)) {
+		if (locked_book)
+			unlock_book(locked_book, flags);
+		locked_book = lock_page_book(page, flags);
+	}
+
+	return locked_book;
+}
+
+static inline struct book *relock_page_book_irq(struct book *locked_book,
+						struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	if (!locked_book || zone != book_zone(locked_book)) {
+		if (locked_book)
+			unlock_book_irq(locked_book);
+		locked_book = lock_page_book_irq(page);
+	}
+
+	return locked_book;
+}
+
+/*
+ * like relock_page_book_irq, but book always locked, interrupts disabled and
+ * page always in the same zone
+ */
+static inline struct book *__relock_page_book(struct book *locked_book,
+					      struct page *page)
+{
+	return page_book(page);
+}
+
+#else /* CONFIG_MEMORY_BOOKKEEPING */
+
+static inline struct book *lock_page_book(struct page *page,
+					  unsigned long *flags)
+{
+	struct book *book = page_book(page);
+
+	lock_book(book, flags);
+	return book;
+}
+
+static inline struct book *lock_page_book_irq(struct page *page)
+{
+	struct book *book = page_book(page);
+
+	lock_book_irq(book);
+	return book;
+}
+
+static inline struct book *relock_page_book(struct book *locked_book,
+					    struct page *page,
+					    unsigned long *flags)
+{
+	struct book *book = page_book(page);
+
+	if (unlikely(locked_book != book)) {
+		if (locked_book)
+			unlock_book(locked_book, flags);
+		lock_book(book, flags);
+		locked_book = book;
+	}
+	return locked_book;
+}
+
+static inline struct book *relock_page_book_irq(struct book *locked_book,
+						struct page *page)
+{
+	struct book *book = page_book(page);
+
+	if (unlikely(locked_book != book)) {
+		if (locked_book)
+			unlock_book_irq(locked_book);
+		lock_book_irq(book);
+		locked_book = book;
+	}
+	return locked_book;
+}
+
+static inline struct book *__relock_page_book(struct book *locked_book,
+					      struct page *page)
+{
+	/* one book per-zone, there nothing to do */
+	return locked_book;
+}
+
+#endif /* CONFIG_MEMORY_BOOKKEEPING */
+
 #define for_each_book(book, zone) \
 	list_for_each_entry_rcu(book, &zone->book_list, list)
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 91d3efb..8e7e289 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1228,11 +1228,11 @@ static int __split_huge_page_splitting(struct page *page,
 static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
-	struct zone *zone = page_zone(page);
+	struct book *book;
 	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
+	book = lock_page_book_irq(page);
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
@@ -1308,17 +1308,17 @@ static void __split_huge_page_refcount(struct page *page)
 		BUG_ON(!PageSwapBacked(page_tail));
 
 
-		lru_add_page_tail(zone, page, page_tail);
+		lru_add_page_tail(book_zone(book), page, page_tail);
 	}
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+	__mod_zone_page_state(book_zone(book), NR_ANON_PAGES, HPAGE_PMD_NR);
 
 	ClearPageCompound(page);
 	compound_unlock(page);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_book_irq(book);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5136017..84e04ae 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3523,19 +3523,19 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 		struct page *page;
 
 		ret = 0;
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		lock_book(&mz->book, &flags);
 		if (list_empty(list)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			unlock_book(&mz->book, &flags);
 			break;
 		}
 		page = list_entry(list->prev, struct page, lru);
 		if (busy == page) {
 			list_move(&page->lru, list);
 			busy = NULL;
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			unlock_book(&mz->book, &flags);
 			continue;
 		}
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		unlock_book(&mz->book, &flags);
 
 		pc = lookup_page_cgroup(page);
 
diff --git a/mm/swap.c b/mm/swap.c
index 4e00463..677b529 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -48,15 +48,13 @@ static void __page_cache_release(struct page *page)
 {
 	if (PageLRU(page)) {
 		unsigned long flags;
-		struct zone *zone = page_zone(page);
 		struct book *book;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		book = lock_page_book(page, &flags);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		book = page_book(page);
 		del_page_from_lru_list(book, page, page_off_lru(page));
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		unlock_book(book, &flags);
 	}
 }
 
@@ -208,24 +206,17 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 				void *arg)
 {
 	int i;
-	struct zone *zone = NULL;
+	struct book *book = NULL;
 	unsigned long flags = 0;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-			zone = pagezone;
-			spin_lock_irqsave(&zone->lru_lock, flags);
-		}
 
+		book = relock_page_book(book, page, &flags);
 		(*move_fn)(page, arg);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (book)
+		unlock_book(book, &flags);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
@@ -338,11 +329,11 @@ static inline void activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct book *book;
 
-	spin_lock_irq(&zone->lru_lock);
+	book = lock_page_book_irq(page);
 	__activate_page(page, NULL);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_book_irq(book);
 }
 #endif
 
@@ -407,15 +398,13 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
  */
 void add_page_to_unevictable_list(struct page *page)
 {
-	struct zone *zone = page_zone(page);
 	struct book *book;
 
-	spin_lock_irq(&zone->lru_lock);
+	book = lock_page_book_irq(page);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
-	book = page_book(page);
 	add_page_to_lru_list(book, page, LRU_UNEVICTABLE);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_book_irq(book);
 }
 
 /*
@@ -583,16 +572,16 @@ void release_pages(struct page **pages, int nr, int cold)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
-	struct zone *zone = NULL;
+	struct book *book = NULL;
 	unsigned long uninitialized_var(flags);
 
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
 		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				zone = NULL;
+			if (book) {
+				unlock_book(book, &flags);
+				book = NULL;
 			}
 			put_compound_page(page);
 			continue;
@@ -602,16 +591,7 @@ void release_pages(struct page **pages, int nr, int cold)
 			continue;
 
 		if (PageLRU(page)) {
-			struct zone *pagezone = page_zone(page);
-			struct book *book = page_book(page);
-
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irqrestore(&zone->lru_lock,
-									flags);
-				zone = pagezone;
-				spin_lock_irqsave(&zone->lru_lock, flags);
-			}
+			book = relock_page_book(book, page, &flags);
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
 			del_page_from_lru_list(book, page, page_off_lru(page));
@@ -619,8 +599,8 @@ void release_pages(struct page **pages, int nr, int cold)
 
 		list_add(&page->lru, &pages_to_free);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (book)
+		unlock_book(book, &flags);
 
 	free_hot_cold_page_list(&pages_to_free, cold);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0e0bbe2..0b973ff 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1290,19 +1290,17 @@ int isolate_lru_page(struct page *page)
 	VM_BUG_ON(!page_count(page));
 
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
 		struct book *book;
 
-		spin_lock_irq(&zone->lru_lock);
+		book = lock_page_book_irq(page);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
-			book = page_book(page);
 			del_page_from_lru_list(book, page, lru);
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_book_irq(book);
 	}
 	return ret;
 }
@@ -1342,7 +1340,6 @@ putback_inactive_pages(struct book *book,
 		       struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &book->reclaim_stat;
-	struct zone *zone = book_zone(book);
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1350,22 +1347,21 @@ putback_inactive_pages(struct book *book,
 	 */
 	while (!list_empty(page_list)) {
 		struct page *page = lru_to_page(page_list);
-		struct book *book;
 		int lru;
 
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page, NULL))) {
-			spin_unlock_irq(&zone->lru_lock);
+			unlock_book_irq(book);
 			putback_lru_page(page);
-			spin_lock_irq(&zone->lru_lock);
+			lock_book_irq(book);
 			continue;
 		}
 		SetPageLRU(page);
 		lru = page_lru(page);
 
 		/* can differ only on lumpy reclaim */
-		book = page_book(page);
+		book = __relock_page_book(book, page);
 		add_page_to_lru_list(book, page, lru);
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
@@ -1378,9 +1374,9 @@ putback_inactive_pages(struct book *book,
 			del_page_from_lru_list(book, page, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				unlock_book_irq(book);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				lock_book_irq(book);
 			} else
 				list_add(&page->lru, &pages_to_free);
 		}
@@ -1516,7 +1512,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 	if (!sc->may_writepage)
 		reclaim_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_book_irq(book);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, book, &page_list,
 				     &nr_scanned, sc->order,
@@ -1532,7 +1528,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 	}
 
 	if (nr_taken == 0) {
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_book_irq(book);
 		return 0;
 	}
 
@@ -1541,7 +1537,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_book_irq(book);
 
 	nr_reclaimed = shrink_page_list(&page_list, book, sc, priority,
 						&nr_dirty, &nr_writeback);
@@ -1553,7 +1549,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 					priority, &nr_dirty, &nr_writeback);
 	}
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_book_irq(book);
 
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
@@ -1564,7 +1560,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_book_irq(book);
 
 	free_hot_cold_page_list(&page_list, 1);
 
@@ -1620,7 +1616,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct book *book,
  * But we had to alter page->flags anyway.
  */
 
-static void move_active_pages_to_lru(struct zone *zone,
+static void move_active_pages_to_lru(struct book *book,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
@@ -1629,7 +1625,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 	struct page *page;
 
 	if (buffer_heads_over_limit) {
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_book_irq(book);
 		list_for_each_entry(page, list, lru) {
 			if (page_has_private(page) && trylock_page(page)) {
 				if (page_has_private(page))
@@ -1637,11 +1633,10 @@ static void move_active_pages_to_lru(struct zone *zone,
 				unlock_page(page);
 			}
 		}
-		spin_lock_irq(&zone->lru_lock);
+		lock_book_irq(book);
 	}
 
 	while (!list_empty(list)) {
-		struct book *book;
 		int numpages;
 
 		page = lru_to_page(list);
@@ -1650,7 +1645,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 		SetPageLRU(page);
 
 		/* can differ only on lumpy reclaim */
-		book = page_book(page);
+		book = __relock_page_book(book, page);
 		list_move(&page->lru, &book->pages_lru[lru]);
 		numpages = hpage_nr_pages(page);
 		book->pages_count[lru] += numpages;
@@ -1662,14 +1657,14 @@ static void move_active_pages_to_lru(struct zone *zone,
 			del_page_from_lru_list(book, page, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&zone->lru_lock);
+				unlock_book_irq(book);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&zone->lru_lock);
+				lock_book_irq(book);
 			} else
 				list_add(&page->lru, pages_to_free);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+	__mod_zone_page_state(book_zone(book), NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1698,7 +1693,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_writepage)
 		reclaim_mode |= ISOLATE_CLEAN;
 
-	spin_lock_irq(&zone->lru_lock);
+	lock_book_irq(book);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, book, &l_hold,
 				     &nr_scanned, sc->order,
@@ -1714,7 +1709,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+
+	unlock_book_irq(book);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1750,7 +1746,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	lock_book_irq(book);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1759,12 +1755,12 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(zone, &l_active, &l_hold,
+	move_active_pages_to_lru(book, &l_active, &l_hold,
 						LRU_ACTIVE + file * LRU_FILE);
-	move_active_pages_to_lru(zone, &l_inactive, &l_hold,
+	move_active_pages_to_lru(book, &l_inactive, &l_hold,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_book_irq(book);
 
 	free_hot_cold_page_list(&l_hold, 1);
 }
@@ -1944,7 +1940,7 @@ static void get_scan_count(struct book *book, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	lock_book_irq(book);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1965,7 +1961,7 @@ static void get_scan_count(struct book *book, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	unlock_book_irq(book);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3466,24 +3462,16 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
  */
 void check_move_unevictable_pages(struct page **pages, int nr_pages)
 {
-	struct book *book;
-	struct zone *zone = NULL;
+	struct book *book = NULL;
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
+		book = relock_page_book_irq(book, page);
 
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
@@ -3493,20 +3481,19 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 
 			VM_BUG_ON(PageActive(page));
 			ClearPageUnevictable(page);
-			__dec_zone_state(zone, NR_UNEVICTABLE);
-			book = page_book(page);
+			__dec_zone_state(book_zone(book), NR_UNEVICTABLE);
 			book->pages_count[LRU_UNEVICTABLE]--;
 			book->pages_count[lru]++;
 			list_move(&page->lru, &book->pages_lru[lru]);
-			__inc_zone_state(zone, NR_INACTIVE_ANON + lru);
+			__inc_zone_state(book_zone(book), NR_INACTIVE_ANON + lru);
 			pgrescued++;
 		}
 	}
 
-	if (zone) {
+	if (book) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(&zone->lru_lock);
+		unlock_book_irq(book);
 	}
 }
 #endif /* CONFIG_SHMEM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
