Date: Wed, 19 Apr 2000 19:09:48 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [patch] shrink_mmap() 2.3.99-pre6-3  (take 3)
Message-ID: <Pine.LNX.4.21.0004191903520.12458-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here's a 3rd version of my patch to shrink_mmap(). This
version fixes most of the performance problems with
shrink_mmap() .. to make performance better big changes
will be needed. It also doesn't eliminate a possible race
condition (afaik Ben is working on that one) in shrink_mmap().

The patch does the following:
- remove possible race condition from truncate_inode_pages()
- don't age mapped pages, save the referenced bit for later
- put pages in the right place on the LRU queue
   (thanks for the .prev hint, Andrea ;))

It has been tested under a fairly wide variety of (over)loaded
situations and performance has been good.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.3.99-pre6-3/mm/filemap.c.orig	Mon Apr 17 12:21:46 2000
+++ linux-2.3.99-pre6-3/mm/filemap.c	Wed Apr 19 14:17:27 2000
@@ -149,11 +149,16 @@
 
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
 
@@ -191,11 +196,13 @@
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
@@ -208,6 +215,9 @@
 		 */
 		UnlockPage(page);
 		page_cache_release(page);
+		get_page(page);
+		wait_on_page(page);
+		put_page(page);
 		goto repeat;
 	}
 	spin_unlock(&pagecache_lock);
@@ -233,7 +243,17 @@
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
-		dispose = &zone->lru_cache;
+		/* What?! A page is in the LRU queue of another zone?! */
+		if (!memclass(page->zone, zone))
+			BUG();
+
+		dispose = &young;
+		/* the page is in use, we can't free it now */
+		if (!page->buffers && page_count(page) > 1)
+			goto dispose_continue;
+
+		count--;
+
 		if (test_and_clear_bit(PG_referenced, &page->flags))
 			/* Roll the page at the top of the lru list,
 			 * we could also be more aggressive putting
@@ -243,17 +263,6 @@
 			goto dispose_continue;
 
 		dispose = &old;
-		/* don't account passes over not DMA pages */
-		if (zone && (!memclass(page->zone, zone)))
-			goto dispose_continue;
-
-		count--;
-
-		dispose = &young;
-
-		/* avoid unscalable SMP locking */
-		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
 
 		if (TryLockPage(page))
 			goto dispose_continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
