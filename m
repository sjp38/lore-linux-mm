Date: Fri, 16 Jun 2000 07:45:33 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: kswapd eating too much CPU on ac16/ac18
In-Reply-To: <E1320bL-0008Af-00@the-village.bc.nu>
Message-ID: <Pine.Linu.4.10.10006160724100.793-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, Cesar Eduardo Barros <cesarb@nitnet.com.br>, linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Alan Cox wrote:

> > ac4 was faster than ever, it looked like it wasn't swapping at all
> > 
> > ac16 and ac18 are both awful, dpkg takes an infinite time, all of it dominated
> 
> Im interested to know if ac9/ac10 is the slow->fast change point

ac5 is definately the breaking point.  ac5 doesn't survive make -j30..
starts swinging it's VM machette at everything in sight.  Reversing the
VM changes to ac4 restores throughput to test1 levels (11 minute build
vs 21-26 minutes for everything forward).

Exact tested reversals below.  FWIW, page aging doesn't seem to be the
problem.  I disabled that in ac17 and saw zero difference.  (What may or
not be a hint is that the /* Let shrink_mmap handle this swapout. */ bit
in vmscan.c does make a consistent difference.  Reverting that bit alone
takes a minimum of 4 minutes off build time)

	-Mike

diff -urN linux-2.4.0-ac4/include/linux/mm.h linux-2.4.0-ac5/include/linux/mm.h
--- linux-2.4.0-ac4/include/linux/mm.h	Fri Jun 16 06:09:48 2000
+++ linux-2.4.0-ac5/include/linux/mm.h	Fri Jun 16 06:17:29 2000
@@ -153,6 +153,7 @@
 	struct buffer_head * buffers;
 	unsigned long virtual; /* nonzero if kmapped */
 	struct zone_struct *zone;
+	unsigned int age;
 } mem_map_t;
 
 #define get_page(p)		atomic_inc(&(p)->count)
@@ -169,7 +170,7 @@
 #define PG_dirty		 4
 #define PG_decr_after		 5
 #define PG_unused_01		 6
-#define PG__unused_02		 7
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
@@ -192,6 +194,9 @@
 					clear_bit(PG_locked, &(page)->flags); \
 					wake_up(&page->wait); \
 				} while (0)
+#define PageActive(page)	test_bit(PG_active, &(page)->flags)
+#define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
+#define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define PageError(page)		test_bit(PG_error, &(page)->flags)
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
diff -urN linux-2.4.0-ac4/include/linux/swap.h linux-2.4.0-ac5/include/linux/swap.h
--- linux-2.4.0-ac4/include/linux/swap.h	Wed Jun 14 11:52:13 2000
+++ linux-2.4.0-ac5/include/linux/swap.h	Fri Jun 16 06:17:30 2000
@@ -168,12 +168,15 @@
 	spin_lock(&pagemap_lru_lock);		\
 	list_add(&(page)->lru, &lru_cache);	\
 	nr_lru_pages++;				\
+	page->age = 2;				\
+	SetPageActive(page);			\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
 
 #define	__lru_cache_del(page)			\
 do {						\
 	list_del(&(page)->lru);			\
+	ClearPageActive(page);			\
 	nr_lru_pages--;				\
 } while (0)
 
diff -urN linux-2.4.0-ac4/mm/filemap.c linux-2.4.0-ac5/mm/filemap.c
--- linux-2.4.0-ac4/mm/filemap.c	Wed May 24 06:23:09 2000
+++ linux-2.4.0-ac5/mm/filemap.c	Fri Jun 16 06:15:32 2000
@@ -264,7 +264,16 @@
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
-		if (PageTestandClearReferenced(page))
+		if (PageTestandClearReferenced(page)) {
+			page->age += 3;
+			if (page->age > 10)
+				page->age = 10;
+			goto dispose_continue;
+		}
+		if (page->age)
+			page->age--;
+
+		if (page->age)
 			goto dispose_continue;
 
 		count--;
@@ -317,28 +326,34 @@
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
-			__delete_from_swap_cache(page);
-			goto made_inode_progress;
-		}	
-
-		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
+			if (!PageDirty(page)) {
+				spin_unlock(&pagecache_lock);
+				__delete_from_swap_cache(page);
+				goto made_inode_progress;
+			}
+			/* PageDeferswap -> we swap out the page now. */
+			if (gfp_mask & __GFP_IO)
+				goto async_swap;
 			goto cache_unlock_continue;
+		}
 
 		/* is it a page-cache page? */
 		if (page->mapping) {
 			if (!PageDirty(page) && !pgcache_under_min()) {
-				__remove_inode_page(page);
 				spin_unlock(&pagecache_lock);
+				__remove_inode_page(page);
 				goto made_inode_progress;
 			}
 			goto cache_unlock_continue;
@@ -351,6 +366,14 @@
 unlock_continue:
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
+		page_cache_release(page);
+		goto dispose_continue;
+async_swap:
+		spin_unlock(&pagecache_lock);
+		/* Do NOT unlock the page ... that is done after IO. */
+		ClearPageDirty(page);
+		rw_swap_page(WRITE, page, 0);
+		spin_lock(&pagemap_lru_lock);
 		page_cache_release(page);
 dispose_continue:
 		list_add(page_lru, &lru_cache);
diff -urN linux-2.4.0-ac4/mm/page_alloc.c linux-2.4.0-ac5/mm/page_alloc.c
--- linux-2.4.0-ac4/mm/page_alloc.c	Sat May 13 07:12:42 2000
+++ linux-2.4.0-ac5/mm/page_alloc.c	Fri Jun 16 06:15:32 2000
@@ -93,6 +93,8 @@
 		BUG();
 	if (PageDecrAfter(page))
 		BUG();
+	if (PageDirty(page))
+		BUG();
 
 	zone = page->zone;
 
diff -urN linux-2.4.0-ac4/mm/swap_state.c linux-2.4.0-ac5/mm/swap_state.c
--- linux-2.4.0-ac4/mm/swap_state.c	Wed May 24 06:23:09 2000
+++ linux-2.4.0-ac5/mm/swap_state.c	Fri Jun 16 06:15:32 2000
@@ -73,6 +73,7 @@
 		PAGE_BUG(page);
 
 	PageClearSwapCache(page);
+	ClearPageDirty(page);
 	remove_inode_page(page);
 }
 
diff -urN linux-2.4.0-ac4/mm/vmscan.c linux-2.4.0-ac5/mm/vmscan.c
--- linux-2.4.0-ac4/mm/vmscan.c	Wed May 24 06:23:09 2000
+++ linux-2.4.0-ac5/mm/vmscan.c	Fri Jun 16 06:15:32 2000
@@ -62,6 +62,10 @@
 		goto out_failed;
 	}
 
+	/* Can only do this if we age all active pages. */
+	if (PageActive(page) && page->age > 1)
+		goto out_failed;
+
 	if (TryLockPage(page))
 		goto out_failed;
 
@@ -74,6 +78,8 @@
 	 * memory, and we should just continue our scan.
 	 */
 	if (PageSwapCache(page)) {
+		if (pte_dirty(pte))
+			SetPageDirty(page);
 		entry.val = page->index;
 		swap_duplicate(entry);
 		set_pte(page_table, swp_entry_to_pte(entry));
@@ -181,7 +187,10 @@
 	vmlist_access_unlock(vma->vm_mm);
 
 	/* OK, do a physical asynchronous write to swap.  */
-	rw_swap_page(WRITE, page, 0);
+	// rw_swap_page(WRITE, page, 0);
+	/* Let shrink_mmap handle this swapout. */
+	SetPageDirty(page);
+	UnlockPage(page);
 
 out_free_success:
 	page_cache_release(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
