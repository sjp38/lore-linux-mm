Message-ID: <3932E28E.E83AD5D3@norran.net>
Date: Mon, 29 May 2000 23:35:10 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] shrink_mmap with fewer list modifications
Content-Type: multipart/mixed;
 boundary="------------733C9E5B65DDA46DD3AF5B80"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Juan J. Quintela" <quintela@fi.udc.es>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------733C9E5B65DDA46DD3AF5B80
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This patch improves Riels patch by using fewer list modifications.
It could be applied to most shrink_mmaps but Riels version will
gain the most.

Function:
- Do not delete + insert all pages while scanning.
- Scan until a suitable page is found, then move the head.

/RogerL

This time with diff -Naur ... and Riels patch removed...
--
Home page:
  http://www.norran.net/nra02596/
--------------733C9E5B65DDA46DD3AF5B80
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test1-deferred_swap-speedup.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test1-deferred_swap-speedup.2"

--- /usr/src/linux/mm/filemap.c.riel	Sat May 27 01:22:47 2000
+++ /usr/src/linux/mm/filemap.c	Mon May 29 16:58:56 2000
@@ -258,23 +258,27 @@
 	count = nr_lru_pages / (priority + 1);
 	nr_dirty = priority;
 
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
+	/* we need pagemap_lru_lock for lru_cache head movement... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	page_lru = &lru_cache;
+	while (count > 0) {
+                page_lru = page_lru->prev;
+                if (page_lru == &lru_cache)
+		  break; /* one whole run */
+
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
 
 		if (PageTestandClearReferenced(page)) {
 			page->age += 3;
 			if (page->age > 10)
-				page->age = 0;
-			goto dispose_continue;
+				page->age = 10;
+			continue;
 		}
 		if (page->age)
 			page->age--;
 
 		if (page->age)
-			goto dispose_continue;
+			continue;
 
 		count--;
 		/*
@@ -282,10 +286,20 @@
 		 * immediate tell are untouchable..
 		 */
 		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
+			continue;
 
 		if (TryLockPage(page))
-			goto dispose_continue;
+			continue;
+
+		/* move header before unlock...
+		 * NOTE: the page to scan might move on while having
+		 * pagemap_lru unlocked. Avoid rescanning same pages
+		 * by moving head and set page_lru to NULL to avoid
+		 * misuses!
+		 */
+                list_del(&lru_cache);
+		list_add_tail(&lru_cache, page_lru);
+		page_lru = NULL;
 
 		/* Release the pagemap_lru lock even if the page is not yet
 		   queued in any lru queue since we have just locked down
@@ -322,6 +336,9 @@
 		 * We can't free pages unless there's just one user
 		 * (count == 2 because we added one ourselves above).
 		 */
+		if (page_count(page) < 2)
+		  BUG();
+
 		if (page_count(page) != 2)
 			goto cache_unlock_continue;
 
@@ -345,7 +362,7 @@
 			}
 			/* PageDeferswap -> we swap out the page now. */
 			if (gfp_mask & __GFP_IO)
-				goto async_swap;
+				goto async_swap_continue;
 			goto cache_unlock_continue;
 		}
 
@@ -368,27 +385,29 @@
 		UnlockPage(page);
 		page_cache_release(page);
 		goto dispose_continue;
-async_swap:
+async_swap_continue:
 		spin_unlock(&pagecache_lock);
 		/* Do NOT unlock the page ... that is done after IO. */
 		ClearPageDirty(page);
 		rw_swap_page(WRITE, page, 0);
+		/* no lock held here? SMP? is page_cache_get enough? */
 		spin_lock(&pagemap_lru_lock);
 		page_cache_release(page);
 dispose_continue:
-		list_add(page_lru, &lru_cache);
+		page_lru =  &lru_cache;
 	}
 	goto out;
 
 made_inode_progress:
 	page_cache_release(page);
 made_buffer_progress:
-	UnlockPage(page);
-	page_cache_release(page);
-	ret = 1;
 	spin_lock(&pagemap_lru_lock);
+        list_del(&page->lru); /* page_lru is NULL... */
 	/* nr_lru_pages needs the spinlock */
 	nr_lru_pages--;
+	UnlockPage(page);
+	page_cache_release(page);
+	ret = 1;
 
 out:
 	spin_unlock(&pagemap_lru_lock);

--------------733C9E5B65DDA46DD3AF5B80--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
