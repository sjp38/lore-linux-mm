Received: from atlas.iskon.hr (atlas.iskon.hr [213.191.131.6])
        by mail.iskon.hr (8.12.0.Beta7/8.12.0.Beta7/Debian 8.12.0.Beta7-1) with ESMTP id f53Ce0vS020831
        for <linux-mm@kvack.org>; Sun, 3 Jun 2001 14:40:03 +0200
Received: from atlas.iskon.hr (localhost [127.0.0.1])
        by localhost (8.12.0.Beta7/8.12.0.Beta7/Debian 8.12.0.Beta7-1) with ESMTP id f53CUYm4001634
        for <linux-mm@kvack.org>; Sun, 3 Jun 2001 14:30:35 +0200
Subject: [PATCH] Remove nr_async_pages limit
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 03 Jun 2001 14:30:34 +0200
Message-ID: <874rtxoidx.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch removes the limit on the number of async pages in the
flight.

That artificial limit hurts both swap out and swap in path as it
introduces synchronization points (and/or weakens swapin readahead),
which I think are not necessary.

I also took an opportunity to clean up code a little bit. The patch
practically only removes code. Linus will like it (if and when it's
submitted). :)

Still, it needs some more testing on various workloads, so I'm posting
it on the lists only. So far, it's been completely stable.


Index: 5.9/mm/page_io.c
--- 5.9/mm/page_io.c Sat, 28 Apr 2001 13:16:05 +0200 zcalusic (linux24/j/10_page_io.c 1.1.3.1 644)
+++ 5.8/mm/page_io.c Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/j/10_page_io.c 1.1.3.1.1.1 644)
@@ -20,7 +20,6 @@
 
 /*
  * Reads or writes a swap page.
- * wait=1: start I/O and wait for completion. wait=0: start asynchronous I/O.
  *
  * Important prevention of race condition: the caller *must* atomically 
  * create a unique swap cache entry for this swap page before calling
@@ -41,12 +40,6 @@
 	kdev_t dev = 0;
 	int block_size;
 	struct inode *swapf = 0;
-	int wait = 0;
-
-	/* Don't allow too many pending pages in flight.. */
-	if ((rw == WRITE) && atomic_read(&nr_async_pages) >
-			pager_daemon.swap_cluster * (1 << page_cluster))
-		wait = 1;
 
 	if (rw == READ) {
 		ClearPageUptodate(page);
@@ -75,26 +68,11 @@
 	} else {
 		return 0;
 	}
- 	if (!wait) {
- 		SetPageDecrAfter(page);
- 		atomic_inc(&nr_async_pages);
- 	}
-
  	/* block_size == PAGE_SIZE/zones_used */
  	brw_page(rw, page, dev, zones, block_size);
 
- 	/* Note! For consistency we do all of the logic,
- 	 * decrementing the page count, and unlocking the page in the
- 	 * swap lock map - in the IO completion handler.
- 	 */
- 	if (!wait)
- 		return 1;
-
- 	wait_on_page(page);
-	/* This shouldn't happen, but check to be sure. */
-	if (page_count(page) == 0)
-		printk(KERN_ERR "rw_swap_page: page unused while waiting!\n");
-
+	/* Note! For consistency, we decrement the page count and
+	   unlock the page in the IO completion handler. */
 	return 1;
 }
 
@@ -121,11 +99,6 @@
 		UnlockPage(page);
 }
 
-/*
- * The swap lock map insists that pages be in the page cache!
- * Therefore we can't use it.  Later when we can remove the need for the
- * lock map and we can reduce the number of functions exported.
- */
 void rw_swap_page_nolock(int rw, swp_entry_t entry, char *buf)
 {
 	struct page *page = virt_to_page(buf);
Index: 5.9/mm/page_alloc.c
--- 5.9/mm/page_alloc.c Sat, 26 May 2001 20:44:49 +0200 zcalusic (linux24/j/14_page_alloc 1.1.7.1.1.1.1.1.1.1 644)
+++ 5.8/mm/page_alloc.c Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/j/14_page_alloc 1.1.7.1.1.1.1.1.1.1.2.1 644)
@@ -79,8 +79,6 @@
 		BUG();
 	if (PageLocked(page))
 		BUG();
-	if (PageDecrAfter(page))
-		BUG();
 	if (PageActive(page))
 		BUG();
 	if (PageInactiveDirty(page))
Index: 5.9/mm/swap.c
--- 5.9/mm/swap.c Wed, 31 Jan 2001 23:52:50 +0100 zcalusic (linux24/j/17_swap.c 1.1.4.1 644)
+++ 5.8/mm/swap.c Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/j/17_swap.c 1.1.4.2 644)
@@ -52,10 +52,6 @@
  */
 int memory_pressure;
 
-/* We track the number of pages currently being asynchronously swapped
-   out, so that we don't try to swap TOO many pages out at once */
-atomic_t nr_async_pages = ATOMIC_INIT(0);
-
 buffer_mem_t buffer_mem = {
 	2,	/* minimum percent buffer */
 	10,	/* borrow percent buffer */
Index: 5.9/mm/memory.c
--- 5.9/mm/memory.c Sat, 28 Apr 2001 13:16:05 +0200 zcalusic (linux24/j/18_memory.c 1.1.7.1.1.1.1.1.2.1 644)
+++ 5.8/mm/memory.c Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/j/18_memory.c 1.1.7.1.1.1.1.1.2.1.1.1 644)
@@ -1089,16 +1089,9 @@
 	 */
 	num = valid_swaphandles(entry, &offset);
 	for (i = 0; i < num; offset++, i++) {
-		/* Don't block on I/O for read-ahead */
-		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster
-				* (1 << page_cluster)) {
-			while (i++ < num)
-				swap_free(SWP_ENTRY(SWP_TYPE(entry), offset++));
-			break;
-		}
-		/* Ok, do the async read-ahead now */
-		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset));
-		if (new_page != NULL)
+		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry),
+							   offset));
+		if (new_page)
 			page_cache_release(new_page);
 		swap_free(SWP_ENTRY(SWP_TYPE(entry), offset));
 	}
Index: 5.9/kernel/ksyms.c
--- 5.9/kernel/ksyms.c Sat, 26 May 2001 20:44:49 +0200 zcalusic (linux24/j/46_ksyms.c 1.1.4.1.1.1.1.1.2.1.1.1 644)
+++ 5.8/kernel/ksyms.c Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/j/46_ksyms.c 1.1.4.1.1.1.1.1.2.1.1.1.1.1 644)
@@ -488,7 +488,6 @@
 EXPORT_SYMBOL(file_fsync);
 EXPORT_SYMBOL(fsync_inode_buffers);
 EXPORT_SYMBOL(clear_inode);
-EXPORT_SYMBOL(nr_async_pages);
 EXPORT_SYMBOL(___strtok);
 EXPORT_SYMBOL(init_special_inode);
 EXPORT_SYMBOL(read_ahead);
Index: 5.9/include/linux/swap.h
--- 5.9/include/linux/swap.h Sat, 26 May 2001 20:44:49 +0200 zcalusic (linux24/d/b/26_swap.h 1.1.7.1.2.1.1.1 644)
+++ 5.8/include/linux/swap.h Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/d/b/26_swap.h 1.1.7.1.2.1.1.1.1.1 644)
@@ -69,7 +69,6 @@
 extern unsigned int nr_free_buffer_pages(void);
 extern int nr_active_pages;
 extern int nr_inactive_dirty_pages;
-extern atomic_t nr_async_pages;
 extern struct address_space swapper_space;
 extern atomic_t page_cache_size;
 extern atomic_t buffermem_pages;
Index: 5.9/include/linux/mm.h
--- 5.9/include/linux/mm.h Sat, 26 May 2001 20:44:49 +0200 zcalusic (linux24/g/b/6_mm.h 1.1.5.2.1.1.2.1.1.1 644)
+++ 5.8/include/linux/mm.h Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/g/b/6_mm.h 1.1.5.2.1.1.2.1.1.1.1.1 644)
@@ -159,7 +159,7 @@
 #define PG_referenced		 2
 #define PG_uptodate		 3
 #define PG_dirty		 4
-#define PG_decr_after		 5
+				 /* bit 5 unused */
 #define PG_active		 6
 #define PG_inactive_dirty	 7
 #define PG_slab			 8
@@ -210,9 +210,6 @@
 #define SetPageReferenced(page)	set_bit(PG_referenced, &(page)->flags)
 #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define PageTestandClearReferenced(page)	test_and_clear_bit(PG_referenced, &(page)->flags)
-#define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
-#define SetPageDecrAfter(page)	set_bit(PG_decr_after, &(page)->flags)
-#define PageTestandClearDecrAfter(page)	test_and_clear_bit(PG_decr_after, &(page)->flags)
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define PageSwapCache(page)	test_bit(PG_swap_cache, &(page)->flags)
 #define PageReserved(page)	test_bit(PG_reserved, &(page)->flags)
Index: 5.9/fs/buffer.c
--- 5.9/fs/buffer.c Sat, 26 May 2001 20:44:49 +0200 zcalusic (linux24/p/b/15_buffer.c 1.1.7.1.1.1.1.1.2.1.1.1 644)
+++ 5.8/fs/buffer.c Sat, 02 Jun 2001 19:54:40 +0200 zcalusic (linux24/p/b/15_buffer.c 1.1.7.1.1.1.1.1.2.1.1.1.2.1 644)
@@ -822,14 +822,7 @@
 	if (!PageError(page))
 		SetPageUptodate(page);
 
-	/*
-	 * Run the hooks that have to be done when a page I/O has completed.
-	 */
-	if (PageTestandClearDecrAfter(page))
-		atomic_dec(&nr_async_pages);
-
 	UnlockPage(page);
-
 	return;
 
 still_busy:
@@ -838,7 +831,7 @@
 }
 
 void set_buffer_async_io(struct buffer_head *bh) {
-    bh->b_end_io = end_buffer_io_async ;
+	bh->b_end_io = end_buffer_io_async;
 }
 
 /*
@@ -1530,7 +1523,7 @@
 	/* Stage 2: lock the buffers, mark them clean */
 	do {
 		lock_buffer(bh);
-		bh->b_end_io = end_buffer_io_async;
+		set_buffer_async_io(bh);
 		atomic_inc(&bh->b_count);
 		set_bit(BH_Uptodate, &bh->b_state);
 		clear_bit(BH_Dirty, &bh->b_state);
@@ -1731,7 +1724,7 @@
 	for (i = 0; i < nr; i++) {
 		struct buffer_head * bh = arr[i];
 		lock_buffer(bh);
-		bh->b_end_io = end_buffer_io_async;
+		set_buffer_async_io(bh);
 		atomic_inc(&bh->b_count);
 	}
 
@@ -2177,7 +2170,7 @@
 		lock_buffer(bh);
 		bh->b_blocknr = *(b++);
 		set_bit(BH_Mapped, &bh->b_state);
-		bh->b_end_io = end_buffer_io_async;
+		set_buffer_async_io(bh);
 		atomic_inc(&bh->b_count);
 		bh = bh->b_this_page;
 	} while (bh != head);

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
