Message-ID: <39359068.1A0B1CB4@norran.net>
Date: Thu, 01 Jun 2000 00:21:28 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] shrink_mmap scan speedup
Content-Type: multipart/mixed;
 boundary="------------DB6FE65A6FB5344CC1D46887"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------DB6FE65A6FB5344CC1D46887
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This is a patch against 2.4.0test1-ac7

It will speed up list operations in shrink_mmap,
by not deleting and reinserting every page...

It is not enough to get good interactive feel,
but it is a step on the way.

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------DB6FE65A6FB5344CC1D46887
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test1-ac7-shrink_mmap.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test1-ac7-shrink_mmap.1"

--- filemap.c.orig	Wed May 31 21:03:33 2000
+++ filemap.c	Wed May 31 22:51:58 2000
@@ -317,20 +317,24 @@
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	page_lru = &lru_cache;
+	while (count > 0) {
+                page_lru = page_lru->prev;
+                if (page_lru == &lru_cache)
+		  continue; /* one whole run, all could have had age > 0 */
+
 		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
 
 		if (PageTestandClearReferenced(page)) {
 			page->age += PG_AGE_ADV;
 			if (page->age > PG_AGE_MAX)
 				page->age = PG_AGE_MAX;
-			goto dispose_continue;
+			continue;
 		}
 		page->age -= min(PG_AGE_DECL, page->age);
 
 		if (page->age)
-			goto dispose_continue;
+			continue;
 
 		count--;
 		/*
@@ -338,17 +342,39 @@
 		 * Don't drop page cache entries in vain.
 		 */
 		if (page->zone->free_pages > page->zone->pages_high)
-			goto dispose_continue;
+			continue;
 
 		/*
 		 * Avoid unscalable SMP locking for pages we can
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
+		 * pagemap_lru unlocked. Avoid rescanning pages
+		 * by moving head and removing current.
+		 */
+
+		/*
+		 * list_del(&lru_cache);
+		 * list_add_tail(&lru_cache, page_lru);
+		 * list_del(page_lru);
+		 */
+		if (lru_cache.prev == page_lru) {
+		  /* Handle case with only one page on lru...
+		   * also optimize if first page checked is suitable.
+		   */
+		  list_del(page_lru);
+		}
+		else {
+		  list_del(&lru_cache);
+		  __list_add(&lru_cache, page_lru->prev, page_lru->next);
+		}
 
 		/* Release the pagemap_lru lock even if the page is not yet
 		   queued in any lru queue since we have just locked down
@@ -432,7 +458,11 @@
 		spin_lock(&pagemap_lru_lock);
 		page_cache_release(page);
 dispose_continue:
+		/* page_lru was deleted from list. Reinsert it at _new_
+		 * lru_cache location
+		 */
 		list_add(page_lru, &lru_cache);
+		page_lru =  &lru_cache;
 	}
 	goto out;
 

--------------DB6FE65A6FB5344CC1D46887--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
