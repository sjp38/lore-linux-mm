Date: Sat, 22 Apr 2000 23:08:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <Pine.LNX.4.21.0004222301280.20850-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

the following patch makes VM in 2.3.99-pre6+ behave more nice
than in previous versions. It does that by:

- having a global lru queue for shrink_mmap()
- slightly improving the lru scanning
- being less agressive with lru scanning, so we'll have
  more pages in the lru queue and will do better page
  aging  (and also gives us a bigger buffer of clean pages,
  this way big memory hogs have less impact on the rest of
  the system)
- freeing some pages from the "wrong" zone when freeing
  from one particular zone ... this keeps memory balanced
  because __alloc_pages() will allocate most pages from
  the least busy zone

It has done some amazing things in test situations on my
machine, but I have no idea what it'll do to kswapd cpu
usage on >1GB machines. I think that the extra freedom in
allocation will offset the slightly more expensive freeing
code almost all of the time.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.3.99-pre6-3/mm/filemap.c.orig	Mon Apr 17 12:21:46 2000
+++ linux-2.3.99-pre6-3/mm/filemap.c	Sat Apr 22 22:14:10 2000
@@ -44,6 +44,7 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
+struct list_head lru_cache;
 
 spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -149,11 +150,16 @@
 
 		/* page wholly truncated - free it */
 		if (offset >= start) {
+			if (TryLockPage(page)) {
+				spin_unlock(&pagecache_lock);
+				get_page(page);
+				wait_on_page(page);
+				put_page(page);
+				goto repeat;
+			}
 			get_page(page);
 			spin_unlock(&pagecache_lock);
 
-			lock_page(page);
-
 			if (!page->buffers || block_flushpage(page, 0))
 				lru_cache_del(page);
 
@@ -191,11 +197,13 @@
 			continue;
 
 		/* partial truncate, clear end of page */
+		if (TryLockPage(page)) {
+			spin_unlock(&pagecache_lock);
+			goto repeat;
+		}
 		get_page(page);
 		spin_unlock(&pagecache_lock);
 
-		lock_page(page);
-
 		memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
 		if (page->buffers)
 			block_flushpage(page, partial);
@@ -208,6 +216,9 @@
 		 */
 		UnlockPage(page);
 		page_cache_release(page);
+		get_page(page);
+		wait_on_page(page);
+		put_page(page);
 		goto repeat;
 	}
 	spin_unlock(&pagecache_lock);
@@ -215,46 +226,56 @@
 
 int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
 {
-	int ret = 0, count;
+	int ret = 0, loop = 0, count;
 	LIST_HEAD(young);
 	LIST_HEAD(old);
 	LIST_HEAD(forget);
 	struct list_head * page_lru, * dispose;
-	struct page * page;
-
+	struct page * page = NULL;
+	struct zone_struct * p_zone;
+	
 	if (!zone)
 		BUG();
 
-	count = nr_lru_pages / (priority+1);
+	count = nr_lru_pages >> priority;
+	if (!count)
+		return ret;
 
 	spin_lock(&pagemap_lru_lock);
-
-	while (count > 0 && (page_lru = zone->lru_cache.prev) != &zone->lru_cache) {
+again:
+	/* we need pagemap_lru_lock for list_del() ... subtle code below */
+	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
+		p_zone = page->zone;
 
-		dispose = &zone->lru_cache;
-		if (test_and_clear_bit(PG_referenced, &page->flags))
-			/* Roll the page at the top of the lru list,
-			 * we could also be more aggressive putting
-			 * the page in the young-dispose-list, so
-			 * avoiding to free young pages in each pass.
-			 */
-			goto dispose_continue;
-
+		/*
+		 * These two tests are there to make sure we don't free too
+		 * many pages from the "wrong" zone. We free some anyway,
+		 * they are the least recently used pages in the system.
+		 * When we don't free them, leave them in &old.
+		 */
 		dispose = &old;
-		/* don't account passes over not DMA pages */
-		if (zone && (!memclass(page->zone, zone)))
+		if (p_zone->free_pages > p_zone->pages_high)
 			goto dispose_continue;
 
-		count--;
-
+		if (loop > 5 && page->zone != zone)
+			goto dispose_continue;
+		
+		/* The page is in use, or was used very recently, put it in
+		 * &young to make sure that we won't try to free it the next
+		 * time */
 		dispose = &young;
-
-		/* avoid unscalable SMP locking */
 		if (!page->buffers && page_count(page) > 1)
 			goto dispose_continue;
 
+		/* Only count pages that have a chance of being freeable */
+		count--;
+		if (test_and_clear_bit(PG_referenced, &page->flags))
+			goto dispose_continue;
+
+		/* Page not used -> free it; if that fails -> &old */
+		dispose = &old;
 		if (TryLockPage(page))
 			goto dispose_continue;
 
@@ -327,6 +348,7 @@
 		list_add(page_lru, dispose);
 		continue;
 
+		/* we're holding pagemap_lru_lock, so we can just loop again */
 dispose_continue:
 		list_add(page_lru, dispose);
 	}
@@ -342,9 +364,14 @@
 	/* nr_lru_pages needs the spinlock */
 	nr_lru_pages--;
 
+	loop++;
+	/* wrong zone?  not looped too often?    roll again... */
+	if (page->zone != zone && loop < (128 >> priority))
+		goto again;
+
 out:
-	list_splice(&young, &zone->lru_cache);
-	list_splice(&old, zone->lru_cache.prev);
+	list_splice(&young, &lru_cache);
+	list_splice(&old, lru_cache.prev);
 
 	spin_unlock(&pagemap_lru_lock);
 
--- linux-2.3.99-pre6-3/mm/page_alloc.c.orig	Mon Apr 17 12:21:46 2000
+++ linux-2.3.99-pre6-3/mm/page_alloc.c	Sat Apr 22 17:28:31 2000
@@ -25,7 +25,7 @@
 #endif
 
 int nr_swap_pages = 0;
-int nr_lru_pages;
+int nr_lru_pages = 0;
 pg_data_t *pgdat_list = (pg_data_t *)0;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -530,6 +530,7 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
+	memlist_init(&lru_cache);
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -609,7 +610,6 @@
 			unsigned long bitmap_size;
 
 			memlist_init(&zone->free_area[i].free_list);
-			memlist_init(&zone->lru_cache);
 			mask += mask;
 			size = (size + ~mask) & mask;
 			bitmap_size = size >> i;
--- linux-2.3.99-pre6-3/include/linux/mm.h.orig	Mon Apr 17 12:22:22 2000
+++ linux-2.3.99-pre6-3/include/linux/mm.h	Sat Apr 22 16:13:15 2000
@@ -15,6 +15,7 @@
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
+extern struct list_head lru_cache;
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
--- linux-2.3.99-pre6-3/include/linux/mmzone.h.orig	Mon Apr 17 12:22:22 2000
+++ linux-2.3.99-pre6-3/include/linux/mmzone.h	Sat Apr 22 16:13:02 2000
@@ -31,7 +31,6 @@
 	char			low_on_memory;
 	char			zone_wake_kswapd;
 	unsigned long		pages_min, pages_low, pages_high;
-	struct list_head	lru_cache;
 
 	/*
 	 * free areas of different sizes
--- linux-2.3.99-pre6-3/include/linux/swap.h.orig	Mon Apr 17 12:22:23 2000
+++ linux-2.3.99-pre6-3/include/linux/swap.h	Sat Apr 22 16:19:38 2000
@@ -166,7 +166,7 @@
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &page->zone->lru_cache);	\
+	list_add(&(page)->lru, &lru_cache);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
