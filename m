Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5FF836B00E9
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:37 -0500 (EST)
Received: by bkty12 with SMTP id y12so1903449bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:35 -0800 (PST)
Subject: [PATCH RFC 07/15] mm: move page-to-book translation upper
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:32 +0400
Message-ID: <20120215225732.22050.17460.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

move page_book() out of add_page_to_lru_list() and del_page_from_lru_list()
switch its first argument from zone to book.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm_inline.h |   10 ++++------
 mm/compaction.c           |    4 +++-
 mm/memcontrol.c           |    7 +++++--
 mm/swap.c                 |   30 ++++++++++++++++++++----------
 mm/vmscan.c               |   16 +++++++++++-----
 5 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 9c484c0..286da9b 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -58,25 +58,23 @@ static inline int page_is_file_cache(struct page *page)
 }
 
 static inline void
-add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
+add_page_to_lru_list(struct book *book, struct page *page, enum lru_list lru)
 {
-	struct book *book = page_book(page);
 	int numpages = hpage_nr_pages(page);
 
 	list_add(&page->lru, &book->pages_lru[lru]);
 	book->pages_count[lru] += numpages;
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, numpages);
+	__mod_zone_page_state(book_zone(book), NR_LRU_BASE + lru, numpages);
 }
 
 static inline void
-del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list lru)
+del_page_from_lru_list(struct book *book, struct page *page, enum lru_list lru)
 {
-	struct book *book = page_book(page);
 	int numpages = hpage_nr_pages(page);
 
 	list_del(&page->lru);
 	book->pages_count[lru] -= numpages;
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -numpages);
+	__mod_zone_page_state(book_zone(book), NR_LRU_BASE + lru, -numpages);
 }
 
 /**
diff --git a/mm/compaction.c b/mm/compaction.c
index 177f0d3..680a725 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -269,6 +269,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
+	struct book *book;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -388,7 +389,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
-		del_page_from_lru_list(zone, page, page_lru(page));
+		book = page_book(page);
+		del_page_from_lru_list(book, page, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ff82d6e..5136017 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2536,6 +2536,7 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	struct zone *zone = page_zone(page);
+	struct book *book;
 	unsigned long flags;
 	bool removed = false;
 
@@ -2546,13 +2547,15 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 	 */
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (PageLRU(page)) {
-		del_page_from_lru_list(zone, page, page_lru(page));
+		book = page_book(page);
+		del_page_from_lru_list(book, page, page_lru(page));
 		ClearPageLRU(page);
 		removed = true;
 	}
 	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
 	if (removed) {
-		add_page_to_lru_list(zone, page, page_lru(page));
+		book = page_book(page);
+		add_page_to_lru_list(book, page, page_lru(page));
 		SetPageLRU(page);
 	}
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
diff --git a/mm/swap.c b/mm/swap.c
index 2268ee7..4e00463 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -49,11 +49,13 @@ static void __page_cache_release(struct page *page)
 	if (PageLRU(page)) {
 		unsigned long flags;
 		struct zone *zone = page_zone(page);
+		struct book *book;
 
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		del_page_from_lru_list(zone, page, page_off_lru(page));
+		book = page_book(page);
+		del_page_from_lru_list(book, page, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 }
@@ -293,11 +295,13 @@ static void __activate_page(struct page *page, void *arg)
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
-		del_page_from_lru_list(zone, page, lru);
+		struct book *book = page_book(page);
+
+		del_page_from_lru_list(book, page, lru);
 
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
-		add_page_to_lru_list(zone, page, lru);
+		add_page_to_lru_list(book, page, lru);
 		__count_vm_event(PGACTIVATE);
 
 		update_page_reclaim_stat(zone, page, file, 1);
@@ -404,11 +408,13 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
 void add_page_to_unevictable_list(struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	struct book *book;
 
 	spin_lock_irq(&zone->lru_lock);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
-	add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
+	book = page_book(page);
+	add_page_to_lru_list(book, page, LRU_UNEVICTABLE);
 	spin_unlock_irq(&zone->lru_lock);
 }
 
@@ -438,6 +444,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 	int lru, file;
 	bool active;
 	struct zone *zone = page_zone(page);
+	struct book *book;
 
 	if (!PageLRU(page))
 		return;
@@ -453,10 +460,11 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 
 	file = page_is_file_cache(page);
 	lru = page_lru_base_type(page);
-	del_page_from_lru_list(zone, page, lru + active);
+	book = page_book(page);
+	del_page_from_lru_list(book, page, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
-	add_page_to_lru_list(zone, page, lru);
+	add_page_to_lru_list(book, page, lru);
 
 	if (PageWriteback(page) || PageDirty(page)) {
 		/*
@@ -466,7 +474,6 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 */
 		SetPageReclaim(page);
 	} else {
-		struct book *book = page_book(page);
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
@@ -596,6 +603,7 @@ void release_pages(struct page **pages, int nr, int cold)
 
 		if (PageLRU(page)) {
 			struct zone *pagezone = page_zone(page);
+			struct book *book = page_book(page);
 
 			if (pagezone != zone) {
 				if (zone)
@@ -606,7 +614,7 @@ void release_pages(struct page **pages, int nr, int cold)
 			}
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
-			del_page_from_lru_list(zone, page, page_off_lru(page));
+			del_page_from_lru_list(book, page, page_off_lru(page));
 		}
 
 		list_add(&page->lru, &pages_to_free);
@@ -644,6 +652,7 @@ void lru_add_page_tail(struct zone* zone,
 	int active;
 	enum lru_list lru;
 	const int file = 0;
+	struct book *book = page_book(page);
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
@@ -678,7 +687,7 @@ void lru_add_page_tail(struct zone* zone,
 		 * Use the standard add function to put page_tail on the list,
 		 * but then correct its position so they all end up in order.
 		 */
-		add_page_to_lru_list(zone, page_tail, lru);
+		add_page_to_lru_list(book, page_tail, lru);
 		list_head = page_tail->lru.prev;
 		list_move_tail(&page_tail->lru, list_head);
 	}
@@ -689,6 +698,7 @@ static void __pagevec_lru_add_fn(struct page *page, void *arg)
 {
 	enum lru_list lru = (enum lru_list)arg;
 	struct zone *zone = page_zone(page);
+	struct book *book = page_book(page);
 	int file = is_file_lru(lru);
 	int active = is_active_lru(lru);
 
@@ -700,7 +710,7 @@ static void __pagevec_lru_add_fn(struct page *page, void *arg)
 	if (active)
 		SetPageActive(page);
 	update_page_reclaim_stat(zone, page, file, active);
-	add_page_to_lru_list(zone, page, lru);
+	add_page_to_lru_list(book, page, lru);
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c59d4f7..0e0bbe2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1291,6 +1291,7 @@ int isolate_lru_page(struct page *page)
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
+		struct book *book;
 
 		spin_lock_irq(&zone->lru_lock);
 		if (PageLRU(page)) {
@@ -1298,8 +1299,8 @@ int isolate_lru_page(struct page *page)
 			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
-
-			del_page_from_lru_list(zone, page, lru);
+			book = page_book(page);
+			del_page_from_lru_list(book, page, lru);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
@@ -1349,6 +1350,7 @@ putback_inactive_pages(struct book *book,
 	 */
 	while (!list_empty(page_list)) {
 		struct page *page = lru_to_page(page_list);
+		struct book *book;
 		int lru;
 
 		VM_BUG_ON(PageLRU(page));
@@ -1361,7 +1363,10 @@ putback_inactive_pages(struct book *book,
 		}
 		SetPageLRU(page);
 		lru = page_lru(page);
-		add_page_to_lru_list(zone, page, lru);
+
+		/* can differ only on lumpy reclaim */
+		book = page_book(page);
+		add_page_to_lru_list(book, page, lru);
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
@@ -1370,7 +1375,7 @@ putback_inactive_pages(struct book *book,
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
-			del_page_from_lru_list(zone, page, lru);
+			del_page_from_lru_list(book, page, lru);
 
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
@@ -1644,6 +1649,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
+		/* can differ only on lumpy reclaim */
 		book = page_book(page);
 		list_move(&page->lru, &book->pages_lru[lru]);
 		numpages = hpage_nr_pages(page);
@@ -1653,7 +1659,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
-			del_page_from_lru_list(zone, page, lru);
+			del_page_from_lru_list(book, page, lru);
 
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
