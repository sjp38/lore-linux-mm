Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C429F6B00F6
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:58:05 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903449bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:58:05 -0800 (PST)
Subject: [PATCH RFC 15/15] mm: split zone->lru_lock
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:58:02 +0400
Message-ID: <20120215225802.22050.78935.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Looks like all ready for splitting zone->lru_lock into small per-book pieces.

Protect lock loop with rcu, memory controller alread release its mem_cgroup_per_node via rcu,
books embedded into zones never released.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm_inline.h |   67 ++++++++++++++++++++++++++++++++++-----------
 include/linux/mmzone.h    |    2 +
 mm/compaction.c           |    3 +-
 mm/memcontrol.c           |    1 +
 mm/page_alloc.c           |    2 +
 mm/swap.c                 |    2 +
 6 files changed, 56 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 9cb3a7e..5d6df15 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -38,22 +38,22 @@ static inline struct pglist_data *book_node(struct book *book)
 
 static inline void lock_book(struct book *book, unsigned long *flags)
 {
-	spin_lock_irqsave(&book_zone(book)->lru_lock, *flags);
+	spin_lock_irqsave(&book->lru_lock, *flags);
 }
 
 static inline void lock_book_irq(struct book *book)
 {
-	spin_lock_irq(&book_zone(book)->lru_lock);
+	spin_lock_irq(&book->lru_lock);
 }
 
 static inline void unlock_book(struct book *book, unsigned long *flags)
 {
-	spin_unlock_irqrestore(&book_zone(book)->lru_lock, *flags);
+	spin_unlock_irqrestore(&book->lru_lock, *flags);
 }
 
 static inline void unlock_book_irq(struct book *book)
 {
-	spin_unlock_irq(&book_zone(book)->lru_lock);
+	spin_unlock_irq(&book->lru_lock);
 }
 
 #ifdef CONFIG_MEMORY_BOOKKEEPING
@@ -61,27 +61,47 @@ static inline void unlock_book_irq(struct book *book)
 static inline struct book *lock_page_book(struct page *page,
 					  unsigned long *flags)
 {
-	struct zone *zone = page_zone(page);
+	struct book *locked_book, *book;
 
-	spin_lock_irqsave(&zone->lru_lock, *flags);
-	return page_book(page);
+	rcu_read_lock();
+	local_irq_save(*flags);
+	book = page_book(page);
+	do {
+		spin_lock(&book->lru_lock);
+		locked_book = book;
+		book = page_book(page);
+		if (likely(book == locked_book)) {
+			rcu_read_unlock();
+			return book;
+		}
+		spin_unlock(&locked_book->lru_lock);
+	} while (1);
 }
 
 static inline struct book *lock_page_book_irq(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct book *locked_book, *book;
 
-	spin_lock_irq(&zone->lru_lock);
-	return page_book(page);
+	rcu_read_lock();
+	local_irq_disable();
+	book = page_book(page);
+	do {
+		spin_lock(&book->lru_lock);
+		locked_book = book;
+		book = page_book(page);
+		if (likely(book == locked_book)) {
+			rcu_read_unlock();
+			return book;
+		}
+		spin_unlock(&locked_book->lru_lock);
+	} while (1);
 }
 
 static inline struct book *relock_page_book(struct book *locked_book,
 					    struct page *page,
 					    unsigned long *flags)
 {
-	struct zone *zone = page_zone(page);
-
-	if (!locked_book || zone != book_zone(locked_book)) {
+	if (unlikely(locked_book != page_book(page))) {
 		if (locked_book)
 			unlock_book(locked_book, flags);
 		locked_book = lock_page_book(page, flags);
@@ -93,9 +113,7 @@ static inline struct book *relock_page_book(struct book *locked_book,
 static inline struct book *relock_page_book_irq(struct book *locked_book,
 						struct page *page)
 {
-	struct zone *zone = page_zone(page);
-
-	if (!locked_book || zone != book_zone(locked_book)) {
+	if (unlikely(locked_book != page_book(page))) {
 		if (locked_book)
 			unlock_book_irq(locked_book);
 		locked_book = lock_page_book_irq(page);
@@ -111,7 +129,22 @@ static inline struct book *relock_page_book_irq(struct book *locked_book,
 static inline struct book *__relock_page_book(struct book *locked_book,
 					      struct page *page)
 {
-	return page_book(page);
+	struct book *book;
+
+	if (likely(locked_book == page_book(page)))
+		return locked_book;
+
+	rcu_read_lock();
+	do {
+		book = page_book(page);
+		if (book == locked_book) {
+			rcu_read_unlock();
+			return book;
+		}
+		spin_unlock(&locked_book->lru_lock);
+		spin_lock(&book->lru_lock);
+		locked_book = book;
+	} while (1);
 }
 
 #else /* CONFIG_MEMORY_BOOKKEEPING */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5bcd5b1..629c6bd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -301,6 +301,7 @@ struct book {
 	struct pglist_data	*node;
 	struct zone		*zone;
 #endif
+	spinlock_t		lru_lock;
 	struct list_head	pages_lru[NR_LRU_LISTS];
 	unsigned long		pages_count[NR_LRU_LISTS];
 
@@ -382,7 +383,6 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct book		book;
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
diff --git a/mm/compaction.c b/mm/compaction.c
index f521edf..cb9266a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -310,7 +310,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 				unlock_book_irq(book);
 			book = NULL;
 		}
-		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
+		if (need_resched() ||
+		    (book && spin_is_contended(&book->lru_lock))) {
 			if (book)
 				unlock_book_irq(book);
 			book = NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90e21d2..eabc2ef 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4640,6 +4640,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 			INIT_LIST_HEAD(&mz->book.pages_lru[l]);
 			mz->book.pages_count[l] = 0;
 		}
+		spin_lock_init(&mz->book.lru_lock);
 		mz->book.node = NODE_DATA(node);
 		mz->book.zone = &NODE_DATA(node)->node_zones[zone];
 		spin_lock(&mz->book.zone->lock);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2df69e..144cef8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4305,7 +4305,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
+		spin_lock_init(&zone->book.lru_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff --git a/mm/swap.c b/mm/swap.c
index 652e691..58ea4f3 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -629,7 +629,7 @@ void lru_add_page_tail(struct book *book,
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&book_zone(book)->lru_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&book->lru_lock));
 
 	SetPageLRU(page_tail);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
