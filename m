Received: from d1o43.telia.com (d1o43.telia.com [194.22.195.241])
	by mailc.telia.com (8.9.3/8.9.3) with ESMTP id CAA04933
	for <linux-mm@kvack.org>; Tue, 16 May 2000 02:45:55 +0200 (CEST)
Received: from norran.net (roger@t1o43p49.telia.com [194.22.195.49])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id CAA20839
	for <linux-mm@kvack.org>; Tue, 16 May 2000 02:45:51 +0200 (CEST)
Message-ID: <3920B665.D1757F94@norran.net>
Date: Tue, 16 May 2000 04:45:57 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] improved LRU shrink_mmap, kswapd, ...
Content-Type: multipart/mixed;
 boundary="------------4EDB981BF9A4ADA7770045A2"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------4EDB981BF9A4ADA7770045A2
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi all,

As I promised - here is my improved LRU shrink_mmap
against pre8.

Tested:

- Can compile a kernel with 'make -j 2'.

Features:

- kswapd, works a little all the time. Thus avoiding situation
  where all pages are referenced at the same time (ageing).

- kswapd, always ages lru_list before running shrink_mmap.

- shrink_mmap, tries to free more than one page each turn.

- do_try_to_free_pages, uses that to avoid recalls => shrink_mmap
  is called once per priority level.

- shrink_mmap, does its work with as a fast page finder.

Bugs:

- Does not handle mmap002 correctly.

Needs:

- Additions of other current patches that improves that
  situation - I tried to keep this clean.

- Tuning...

- More testing - there is a day tomorrow too...

--
Home page:
  http://www.norran.net/nra02596/
--------------4EDB981BF9A4ADA7770045A2
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.3.99-pre8-shrink_mmap.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.3.99-pre8-shrink_mmap.1"

diff -Naur linux-2.3.99-pre8/include/linux/mm.h linux/include/linux/mm.h
--- linux-2.3.99-pre8/include/linux/mm.h	Fri May 12 21:16:14 2000
+++ linux/include/linux/mm.h	Tue May 16 03:07:40 2000
@@ -456,6 +456,7 @@
 extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int);
+extern int age_mmap(void);
 extern void truncate_inode_pages(struct address_space *, loff_t);
 
 /* generic vm_area_ops exported for stackable file systems */
diff -Naur linux-2.3.99-pre8/mm/filemap.c linux/mm/filemap.c
--- linux-2.3.99-pre8/mm/filemap.c	Fri May 12 04:10:53 2000
+++ linux/mm/filemap.c	Tue May 16 03:13:47 2000
@@ -244,20 +244,21 @@
 	spin_unlock(&pagecache_lock);
 }
 
+static unsigned long shrink_mmap_referenced_moved;
+
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
@@ -265,28 +266,19 @@
 
 		count--;
 
-		/*
-		 * I'm ambivalent on this one.. Should we try to
-		 * maintain LRU on the LRU list, and put pages that
-		 * are old at the end of the queue, even if that
-		 * means that we'll re-scan then again soon and
-		 * often waste CPU time? Or should be just let any
-		 * pages we do not want to touch now for one reason
-		 * or another percolate to be "young"?
-		 *
-		dispose = &old;
-		 *
-		 */
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
@@ -304,7 +296,7 @@
 		 */
 		if (page->buffers) {
 			if (!try_to_free_buffers(page))
-				goto unlock_continue;
+				goto page_unlock_continue;
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
@@ -357,32 +349,88 @@
 
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
-unlock_continue:
+page_unlock_continue:
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
-		page_cache_release(page);
+		put_page(page);
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
+		  shrink_mmap_referenced_moved++;
+		}
+		continue;
 
 made_inode_progress:
-	page_cache_release(page);
+		page_cache_release(page);
 made_buffer_progress:
-	UnlockPage(page);
-	page_cache_release(page);
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
 
 	return ret;
 }
+
+int age_mmap(void)
+{
+	LIST_HEAD(referenced);
+	struct list_head * page_lru;
+	struct page * page = NULL;
+
+	int moved_pre, moved_here=0;
+
+
+	spin_lock(&pagemap_lru_lock);
+
+	moved_pre = shrink_mmap_referenced_moved;
+	shrink_mmap_referenced_moved = 0;
+
+	page_lru = &lru_cache;
+	while ((page_lru = page_lru->prev) != &lru_cache) {
+		page = list_entry(page_lru, struct page, lru);
+
+		if (PageTestandClearReferenced(page)) {
+		  struct list_head * page_lru_to_move = page_lru; 
+		  page_lru = page_lru->next; /* continues with page_lru.prev */
+		  list_del(page_lru_to_move);
+		  list_add(page_lru_to_move, &referenced);
+		  moved_here++;
+		}
+	}
+
+	list_splice(&referenced, &lru_cache);
+
+	spin_unlock(&pagemap_lru_lock);
+
+	printk("age_mmap: referenced moved before %lu background %lu\n",
+	       moved_pre, moved_here);
+
+	return (moved_pre + moved_here);
+}
+ 
+
 
 static inline struct page * __find_page_nolock(struct address_space *mapping, unsigned long offset, struct page *page)
 {
diff -Naur linux-2.3.99-pre8/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.3.99-pre8/mm/vmscan.c	Fri May 12 22:49:14 2000
+++ linux/mm/vmscan.c	Tue May 16 03:16:57 2000
@@ -441,10 +441,9 @@
 
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
@@ -480,10 +479,9 @@
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
 
@@ -541,15 +539,40 @@
 				if (!zone->size || !zone->zone_wake_kswapd)
 					continue;
 				something_to_do = 1;
-				do_try_to_free_pages(GFP_KSWAPD);
+				break;
 			}
-			run_task_queue(&tq_disk);
 			pgdat = pgdat->node_next;
-		} while (pgdat);
+		} while (!something_to_do && pgdat);
+
+		if (something_to_do) {
+		  do_try_to_free_pages(GFP_KSWAPD);
+		  run_task_queue(&tq_disk);
+		}
+
+		/* Always sleep - give requestors a chance to use
+		 * freed pages. Even low prio ones - they might be
+		 * the only ones.
+		 */
+
+		/* Do not depend on kswapd.. it should be able to sleep
+		 * sleep time is possible to trim:
+		 * - function of pages aged?
+		 * - function of something_to_do?
+		 * - free_pages?
+		 * right now 1s periods, wakeup possible */
+		{
+			static long aging_time = 0L;
+			if (aging_time == 0L) {
+			  aging_time = 1L*HZ;
+			}
 
-		if (tsk->need_resched || !something_to_do) {
 			tsk->state = TASK_INTERRUPTIBLE;
-			interruptible_sleep_on(&kswapd_wait);
+			aging_time = interruptible_sleep_on_timeout(&kswapd_wait, 1*HZ);
+
+			/* age after wakeup, slept at least one jiffie or have
+			 * been waken up - a lot might have happened.
+			 */
+			(void)age_mmap();
 		}
 	}
 }

--------------4EDB981BF9A4ADA7770045A2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
