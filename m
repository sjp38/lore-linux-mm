Received: from d1o43.telia.com (d1o43.telia.com [194.22.195.241])
	by maile.telia.com (8.9.3/8.9.3) with ESMTP id BAA07033
	for <linux-mm@kvack.org>; Wed, 7 Jun 2000 01:19:18 +0200 (CEST)
Received: from norran.net (roger@t4o43p58.telia.com [194.22.195.238])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id BAA28996
	for <linux-mm@kvack.org>; Wed, 7 Jun 2000 01:19:17 +0200 (CEST)
Message-ID: <393D867F.87DE4DBC@norran.net>
Date: Wed, 07 Jun 2000 01:17:19 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: instrumentation patch for shrink_mmap to find cause of failures - it did
 :-)
Content-Type: multipart/mixed;
 boundary="------------C72CB030F4F4B97B295B66E8"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------C72CB030F4F4B97B295B66E8
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

When applying this patch and running it a typical output looks like
this:


Jun  7 00:41:10 dox kernel: shrink_mmap:     2     0     0     0  
212     0    0     0     0 

First 2 is PID
then comes the counters for different reasons to continue.

The fourth counter is 'count_noncarezone'

I interprete this as:


a) shrink_mmap hits - we need both Normal and DMA pages.
b) Normal pages are easily fulfilled.
c) DMA pages are rare among all Normal pages.
d) When a Normal page is found it is counted as tested but
  then discarded.
e) while loops ends (before finding any DMA pages)
f) shrink_mmap has failed
g) swapping starts...

What to do about it:
a) Move the zone check early - buffers may get old...
b) Undo counting before continuing due to wrong zone

I and others will examine our options.

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------C72CB030F4F4B97B295B66E8
Content-Type: text/plain; charset=us-ascii;
 name="filemap.inst"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="filemap.inst"

--- filemap.c~	Sat Jun  3 19:09:16 2000
+++ filemap.c	Wed Jun  7 00:34:49 2000
@@ -311,6 +311,14 @@
 	int ret = 0, count, nr_dirty;
 	struct list_head * page_lru;
 	struct page * page = NULL;
+	int count_nonbuffers_w_page_gt_1 = 0;
+	int count_nonlockable = 0;
+	int count_failed_try_to_free_buffers = 0;
+	int count_noncarezone = 0;
+	int count_latepagecounterror = 0;
+	int count_async = 0;
+	int count_nonio = 0;
+	int count_mappingbut = 0;
 	
 	count = nr_lru_pages / (priority + 1);
 	nr_dirty = priority;
@@ -337,11 +345,15 @@
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
-		if (!page->buffers && page_count(page) > 1)
+		if (!page->buffers && page_count(page) > 1) {
+		  count_nonbuffers_w_page_gt_1++;
 			goto dispose_continue;
+		}
 
-		if (TryLockPage(page))
+		if (TryLockPage(page)) {
+		  count_nonlockable++;
 			goto dispose_continue;
+		}
 
 		/* Release the pagemap_lru lock even if the page is not yet
 		   queued in any lru queue since we have just locked down
@@ -359,8 +371,10 @@
 		 */
 		if (page->buffers) {
 			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
-			if (!try_to_free_buffers(page, wait))
+			if (!try_to_free_buffers(page, wait)) {
+			  count_failed_try_to_free_buffers++;
 				goto unlock_continue;
+			}
 			/* page was locked, inode can't go away under us */
 			if (!page->mapping) {
 				atomic_dec(&buffermem_pages);
@@ -372,8 +386,10 @@
 		 * Page is from a zone we don't care about.
 		 * Don't drop page cache entries in vain.
 		 */
-		if (page->zone->free_pages > page->zone->pages_high)
+		if (page->zone->free_pages > page->zone->pages_high) {
+		  count_noncarezone++;
 			goto unlock_continue;
+		}
 
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its
@@ -385,8 +401,10 @@
 		 * We can't free pages unless there's just one user
 		 * (count == 2 because we added one ourselves above).
 		 */
-		if (page_count(page) != 2)
+		if (page_count(page) != 2) {
+		  count_latepagecounterror++;
 			goto cache_unlock_continue;
+		}
 
 		/*
 		 * Is it a page swap page? If so, we want to
@@ -407,8 +425,10 @@
 				rw_swap_page(WRITE, page, 0);
 				spin_lock(&pagemap_lru_lock);
 				page_cache_release(page);
+				count_async++;
 				goto dispose_continue;
 			}
+			count_nonio++;
 			goto cache_unlock_continue;
 		}
 
@@ -419,6 +439,7 @@
 				spin_unlock(&pagecache_lock);
 				goto made_inode_progress;
 			}
+			count_mappingbut++;
 			goto cache_unlock_continue;
 		}
 
@@ -447,6 +468,17 @@
 
 out:
 	spin_unlock(&pagemap_lru_lock);
+
+	printk("shrink_mmap: %5d %5d %5d %5d %5d %5d %5d %5d %5d\n",
+	       current->pid,
+	       count_nonbuffers_w_page_gt_1,
+	       count_nonlockable,
+	       count_failed_try_to_free_buffers,
+	       count_noncarezone,
+	       count_latepagecounterror,
+	       count_async,
+	       count_nonio,
+	       count_mappingbut);
 
 	return ret;
 }

--------------C72CB030F4F4B97B295B66E8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
