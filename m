From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906192314.QAA33843@google.engr.sgi.com>
Subject: [RFC] [RFT] [PATCH] kanoj-mm9-2.2.10 simplify swapcache/shm code interaction
Date: Sat, 19 Jun 1999 16:14:26 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com, sct@redhat.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

There is no reason for shared memory pages to have to be marked
PG_swap_cache to fool the underlying swap io routines. Not doing
this will also make sure shrink_mmap does not steal such pages,
and an extra page reference bumping is not neccesary to ensure 
this. Also, this makes things more consistent, in the sense
that pages marked PG_swap_cache are always in the swap cache,
and vice versa.

Kanoj
kanoj@engr.sgi.com

--- /usr/tmp/p_rdiff_a005Qw/page_io.c	Sat Jun 19 16:03:22 1999
+++ mm/page_io.c	Sat Jun 19 15:01:45 1999
@@ -35,7 +35,7 @@
  * that shared pages stay shared while being swapped.
  */
 
-static void rw_swap_page_base(int rw, unsigned long entry, struct page *page, int wait)
+static void rw_swap_page_base(int rw, unsigned long entry, struct page *page, int wait, int shmfs)
 {
 	unsigned long type, offset;
 	struct swap_info_struct * p;
@@ -84,7 +84,7 @@
 		return;
 	}
 
-	if (PageSwapCache(page)) {
+	if (!shmfs) {
 		/* Make sure we are the only process doing I/O with this swap page. */
 		while (test_and_set_bit(offset,p->swap_lockmap)) {
 			run_task_queue(&tq_disk);
@@ -162,7 +162,7 @@
 		/* Do some cleaning up so if this ever happens we can hopefully
 		 * trigger controlled shutdown.
 		 */
-		if (PageSwapCache(page)) {
+		if (!shmfs) {
 			if (!test_and_clear_bit(offset,p->swap_lockmap))
 				printk("swap_after_unlock_page: lock already cleared\n");
 			wake_up(&lock_queue);
@@ -174,7 +174,7 @@
  		set_bit(PG_decr_after, &page->flags);
  		atomic_inc(&nr_async_pages);
  	}
- 	if (PageSwapCache(page)) {
+ 	if (!shmfs) {
  		/* only lock/unlock swap cache pages! */
  		set_bit(PG_swap_unlock_after, &page->flags);
  	}
@@ -256,7 +256,7 @@
 		printk ("swap entry mismatch");
 		return;
 	}
-	rw_swap_page_base(rw, entry, page, wait);
+	rw_swap_page_base(rw, entry, page, wait, 0);
 }
 
 /*
@@ -270,7 +270,7 @@
 	page = mem_map + MAP_NR((unsigned long) buffer);
 	wait_on_page(page);
 	set_bit(PG_locked, &page->flags);
-	if (test_and_set_bit(PG_swap_cache, &page->flags)) {
+	if (test_bit(PG_swap_cache, &page->flags)) {
 		printk ("VM: read_swap_page: page already in swap cache!\n");
 		return;
 	}
@@ -278,13 +278,9 @@
 		printk ("VM: read_swap_page: page already in page cache!\n");
 		return;
 	}
-	page->inode = &swapper_inode;
 	page->offset = entry;
-	atomic_inc(&page->count);	/* Protect from shrink_mmap() */
-	rw_swap_page(rw, entry, buffer, 1);
+	rw_swap_page_base(rw, entry, page, 1, 0);
 	atomic_dec(&page->count);
-	page->inode = 0;
-	clear_bit(PG_swap_cache, &page->flags);
 }
 
 /*
@@ -305,5 +301,5 @@
 		printk ("VM: rw_swap_page_nolock: page in swap cache!\n");
 		return;
 	}
-	rw_swap_page_base(rw, entry, page, wait);
+	rw_swap_page_base(rw, entry, page, wait, 1);
 }
--- /usr/tmp/p_rdiff_a005UY/swap.h	Sat Jun 19 16:05:33 1999
+++ include/linux/swap.h	Sat Jun 19 15:05:43 1999
@@ -144,13 +144,6 @@
 extern unsigned long swap_cache_find_success;
 #endif
 
-extern inline unsigned long in_swap_cache(struct page *page)
-{
-	if (PageSwapCache(page))
-		return page->offset;
-	return 0;
-}
-
 /*
  * Work out if there are any other processes sharing this page, ignoring
  * any page reference coming from the swap cache, or from outstanding
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
