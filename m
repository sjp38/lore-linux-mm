Received: from localhost (riel@localhost)
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id UAA24296
	for <linux-mm@kvack.org>; Thu, 25 May 2000 20:03:42 -0300
Date: Thu, 25 May 2000 20:03:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [patch] page aging and deferred swapping for 2.4.0-test1
Message-ID: <Pine.LNX.4.21.0005251936390.7453-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the attached patch attempts to implement the following two
things (which we'll probably want in the active/inactive
design later on):
- page aging (for active pages)
- deferred swap IO, with only unmapping in try_to_swap_out()

The patch still crashes, but maybe one of you has an idea
on what's wrong and/or even how to fix it ;)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/




--- linux-2.4.0-test1/mm/filemap.c.orig	Thu May 25 12:27:47 2000
+++ linux-2.4.0-test1/mm/filemap.c	Thu May 25 19:54:06 2000
@@ -264,7 +264,15 @@
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
-		if (PageTestandClearReferenced(page))
+		if (PageTestandClearReferenced(page)) {
+			page->age += 3;
+			if (page->age > 10)
+				page->age = 0;
+			goto dispose_continue;
+		}
+		page->age--;
+
+		if (page->age)
 			goto dispose_continue;
 
 		count--;
@@ -317,23 +325,30 @@
 			goto cache_unlock_continue;
 
 		/*
+		 * Page is from a zone we don't care about.
+		 * Don't drop page cache entries in vain.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high)
+			goto cache_unlock_continue;
+
+		/*
 		 * Is it a page swap page? If so, we want to
 		 * drop it if it is no longer used, even if it
 		 * were to be marked referenced..
 		 */
 		if (PageSwapCache(page)) {
-			spin_unlock(&pagecache_lock);
+			/* Write dirty swap cache page to swap. */
+			if (PageDeferswap(page)) {
+				if (gfp_mask & __GFP_IO) {
+					goto async_swap;
+				}
+				else
+					goto cache_unlock_continue;
+			}
 			__delete_from_swap_cache(page);
 			goto made_inode_progress;
 		}	
 
-		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto cache_unlock_continue;
-
 		/* is it a page-cache page? */
 		if (page->mapping) {
 			if (!PageDirty(page) && !pgcache_under_min()) {
@@ -351,6 +366,14 @@
 unlock_continue:
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
+		page_cache_release(page);
+		goto dispose_continue;
+async_swap:
+		page->flags &= ~((1 << PG_defer_swap) | (1 << PG_dirty));
+		spin_unlock(&pagecache_lock);
+		/* Do NOT unlock the page ... that is done after IO. */
+		rw_swap_page(WRITE, page, 0);
+		spin_lock(&pagemap_lru_lock);
 		page_cache_release(page);
 dispose_continue:
 		list_add(page_lru, &lru_cache);
--- linux-2.4.0-test1/mm/page_alloc.c.orig	Thu May 25 12:27:47 2000
+++ linux-2.4.0-test1/mm/page_alloc.c	Thu May 25 18:37:44 2000
@@ -94,6 +94,8 @@
 	if (PageDecrAfter(page))
 		BUG();
 
+	page->age = 2;
+
 	zone = page->zone;
 
 	mask = (~0UL) << order;
--- linux-2.4.0-test1/mm/vmscan.c.orig	Thu May 25 12:27:47 2000
+++ linux-2.4.0-test1/mm/vmscan.c	Thu May 25 19:32:17 2000
@@ -62,6 +62,10 @@
 		goto out_failed;
 	}
 
+	/* Can only do this if we age all active pages. */
+	// if (page->age > 1)
+	//	goto out_failed;
+
 	if (TryLockPage(page))
 		goto out_failed;
 
@@ -181,7 +185,11 @@
 	vmlist_access_unlock(vma->vm_mm);
 
 	/* OK, do a physical asynchronous write to swap.  */
-	rw_swap_page(WRITE, page, 0);
+	// rw_swap_page(WRITE, page, 0);
+	/* Let shrink_mmap handle this swapout. */
+	SetPageDirty(page);
+	SetPageDeferswap(page);
+	UnlockPage(page);
 
 out_free_success:
 	page_cache_release(page);
--- linux-2.4.0-test1/include/linux/mm.h.orig	Thu May 25 12:28:10 2000
+++ linux-2.4.0-test1/include/linux/mm.h	Thu May 25 19:24:04 2000
@@ -153,6 +153,7 @@
 	struct buffer_head * buffers;
 	unsigned long virtual; /* nonzero if kmapped */
 	struct zone_struct *zone;
+	unsigned int age;
 } mem_map_t;
 
 #define get_page(p)		atomic_inc(&(p)->count)
@@ -168,8 +169,8 @@
 #define PG_uptodate		 3
 #define PG_dirty		 4
 #define PG_decr_after		 5
-#define PG_unused_01		 6
-#define PG__unused_02		 7
+#define PG_defer_swap		 6
+#define PG_active		 7
 #define PG_slab			 8
 #define PG_swap_cache		 9
 #define PG_skip			10
@@ -185,6 +186,7 @@
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 #define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
 #define SetPageDirty(page)	set_bit(PG_dirty, &(page)->flags)
+#define ClearPageDirty(page)	clear_bit(PG_dirty, &(page)->flags)
 #define PageLocked(page)	test_bit(PG_locked, &(page)->flags)
 #define LockPage(page)		set_bit(PG_locked, &(page)->flags)
 #define TryLockPage(page)	test_and_set_bit(PG_locked, &(page)->flags)
@@ -192,6 +194,12 @@
 					clear_bit(PG_locked, &(page)->flags); \
 					wake_up(&page->wait); \
 				} while (0)
+#define PageDeferswap(page)	test_bit(PG_defer_swap, &(page)->flags)
+#define SetPageDeferswap(page)	set_bit(PG_defer_swap, &(page)->flags)
+#define ClearPageDeferswap(page) clear_bit(PG_defer_swap, &(page)->flags)
+#define PageActive(page)	test_bit(PG_active, &(page)->flags)
+#define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
+#define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define PageError(page)		test_bit(PG_error, &(page)->flags)
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
