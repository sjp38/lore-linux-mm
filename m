Message-ID: <391D92DE.1AA3F6EA@norran.net>
Date: Sat, 13 May 2000 19:37:34 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] more efficient shrink_mmap
Content-Type: multipart/mixed;
 boundary="------------6A077CB9C606AAC83D501413"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@chiara.elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------6A077CB9C606AAC83D501413
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This patch is against pre7-9 (almost)
I will prepare a patch against pre8 but it might take
until Monday.

Tested on PPro 180 UP system with 96MB RAM.
(Bennos latency tests)

This shrink_mmap checks all pages at the priority level
and frees the one it can. And then it is not retried
with the same level.

It does not move pages around unnecessarily thus keeping
the list LRU (unscanned but referenced pages are not
moved up... bad)

I think the locking is SMP safe [Ingo].
  pagemap_lru_lock or page_locked

It uses the >> priority trick since that will result
in scanning double amount of pages next time.
(pages already scanned + the same no of prev. unscanned)

vmscan.c is modified to call only once per priority level.

(it has the goto sleep patch too)

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------6A077CB9C606AAC83D501413
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.3.99-pre7-9-shrink_mmap.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.3.99-pre7-9-shrink_mmap.2"

--- linux-2.3-pre9--/mm/filemap.c	Fri May 12 02:42:19 2000
+++ linux-2.3/mm/filemap.c	Sat May 13 18:01:25 2000
@@ -236,34 +236,36 @@
 int shrink_mmap(int priority, int gfp_mask)
 {
 	int ret = 0, count;
-	LIST_HEAD(old);
 	struct list_head * page_lru, * dispose;
 	struct page * page = NULL;
 	
-	count = nr_lru_pages / (priority + 1);
+	count = nr_lru_pages >> priority;
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	page_lru = &lru_cache;
+	while (count > 0 && (page_lru = page_lru->prev) != &lru_cache) {
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
 
 		dispose = &lru_cache;
 		if (PageTestandClearReferenced(page))
 			goto dispose_continue;
 
 		count--;
-		dispose = &old;
+
+		dispose = NULL;
 
 		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			continue;
 
+		/* Lock this lru page, reentrant
+		 * will be disposed correctly when unlocked */
 		if (TryLockPage(page))
-			goto dispose_continue;
+			continue;
 
 		/* Release the pagemap_lru lock even if the page is not yet
 		   queued in any lru queue since we have just locked down
@@ -281,7 +283,7 @@
 		 */
 		if (page->buffers) {
 			if (!try_to_free_buffers(page))
-				goto unlock_continue;
+				goto page_unlock_continue;
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
@@ -336,27 +338,43 @@
 
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
-unlock_continue:
+page_unlock_continue:
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		put_page(page);
+		continue;
+
 dispose_continue:
-		list_add(page_lru, dispose);
-	}
-	goto out;
+		/* have the pagemap_lru_lock, lru cannot change */
+		{
+		  struct list_head * page_lru_to_move = page_lru; 
+		  page_lru = page_lru->next; /* continues with page_lru.prev */
+		  list_del(page_lru_to_move);
+		  list_add(page_lru_to_move, dispose);
+		}
+		continue;
 
 made_inode_progress:
-	page_cache_release(page);
+		page_cache_release(page);
 made_buffer_progress:
-	UnlockPage(page);
-	put_page(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
+		/* like to have the lru lock before UnlockPage */
+		spin_lock(&pagemap_lru_lock);
 
-out:
-	list_splice(&old, lru_cache.prev);
+		UnlockPage(page);
+		put_page(page);
+		ret++;
+
+		/* lru manipulation needs the spin lock */
+		{
+		  struct list_head * page_lru_to_free = page_lru; 
+		  page_lru = page_lru->next; /* continues with page_lru.prev */
+		  list_del(page_lru_to_free);
+		}
+
+		/* nr_lru_pages needs the spinlock */
+		nr_lru_pages--;
+
+	}
 
 	spin_unlock(&pagemap_lru_lock);
 
--- linux-2.3-pre9--/mm/vmscan.c	Fri May 12 02:42:19 2000
+++ linux-2.3/mm/vmscan.c	Sat May 13 19:01:51 2000
@@ -443,10 +443,9 @@
 
 	priority = 6;
 	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
+	        count -= shrink_mmap(priority, gfp_mask);
+		if (count <= 0)
+		  goto done;
 
 		/* Try to get rid of some shared memory pages.. */
 		if (gfp_mask & __GFP_IO) {
@@ -481,10 +480,9 @@
 	} while (--priority >= 0);
 
 	/* Always end on a shrink_mmap.. */
-	while (shrink_mmap(0, gfp_mask)) {
-		if (!--count)
-			goto done;
-	}
+	count -= shrink_mmap(0, gfp_mask);
+	if (count <= 0)
+	  goto done;
 
 	return 0;
 
@@ -544,13 +542,14 @@
 				something_to_do = 1;
 				do_try_to_free_pages(GFP_KSWAPD);
 				if (tsk->need_resched)
-					schedule();
+					goto sleep;
 			}
 			run_task_queue(&tq_disk);
 			pgdat = pgdat->node_next;
 		} while (pgdat);
 
 		if (!something_to_do) {
+sleep:
 			tsk->state = TASK_INTERRUPTIBLE;
 			interruptible_sleep_on(&kswapd_wait);
 		}

--------------6A077CB9C606AAC83D501413--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
