Received: from Cantor.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA20383
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 09:25:09 -0500
Message-ID: <19981124133820.46357@boole.suse.de>
Date: Tue, 24 Nov 1998 13:38:20 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: Running 2.1.129 at extrem load [patch] (Was: Linux-2.1.129..)
References: <19981123215359.45625@boole.suse.de> <Pine.LNX.3.96.981123224942.6626B-100000@mirkwood.dummy.home> <19981123233550.34576@boole.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19981123233550.34576@boole.suse.de>; from Dr. Werner Fink on Mon, Nov 23, 1998 at 11:35:50PM +0100
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm <linux-mm@kvack.org>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

> > Sorry Werner, but this is exactly the place where we need to
> > remove any from of page aging. We can do some kind of aging
> > in the swap cache, page cache and buffer cache, but doing
> > aging here is just prohibitively expensive and needs to be
> > removed.
> > 
> > IMHO a better construction be to have a page->fresh flag
> > which would be set on unmapping from swap_out(). Then
> > shrink_mmap() would free pages with page->fresh reset
> > and reset page->fresh if it is set. This way we can
> > free a page at it's second scan so we avoid freeing
> > a page that was just unmapped (and giving each page a
> > bit of a chance to undergo cheap aging).

Comments on the enclosed patch please :-)

 * Without the old ageing scheme within try_to_swap_out any
   bigger increase of the load causes a temporarily unusable system.

 * The `if (buffer_under_min()) break;' within shrink_one_page()
   reduces the average system CPU time in comparison to the user
   CPU time.


            Werner

--------------------------------------------------------------------------
diff -urN linux-2.1.129/include/linux/mm.h linux/include/linux/mm.h
--- linux-2.1.129/include/linux/mm.h	Thu Nov 19 20:49:37 1998
+++ linux/include/linux/mm.h	Tue Nov 24 00:09:29 1998
@@ -117,7 +117,7 @@
 	unsigned long offset;
 	struct page *next_hash;
 	atomic_t count;
-	unsigned int unused;
+	unsigned int lifetime;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	struct wait_queue *wait;
 	struct page **pprev_hash;
diff -urN linux-2.1.129/ipc/shm.c linux/ipc/shm.c
--- linux-2.1.129/ipc/shm.c	Sun Oct 18 00:52:18 1998
+++ linux/ipc/shm.c	Tue Nov 24 12:38:07 1998
@@ -15,6 +15,7 @@
 #include <linux/stat.h>
 #include <linux/malloc.h>
 #include <linux/swap.h>
+#include <linux/swapctl.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/init.h>
@@ -677,6 +678,11 @@
 			shm_swp--;
 		}
 		shm_rss++;
+
+		/* Increase life time of the page */
+		if (mem_map[MAP_NR(page)].lifetime < 3 && pgcache_under_max())
+			mem_map[MAP_NR(page)].lifetime++;
+
 		pte = pte_mkdirty(mk_pte(page, PAGE_SHARED));
 		shp->shm_pages[idx] = pte_val(pte);
 	} else
diff -urN linux-2.1.129/mm/filemap.c linux/mm/filemap.c
--- linux-2.1.129/mm/filemap.c	Thu Nov 19 20:44:18 1998
+++ linux/mm/filemap.c	Tue Nov 24 12:25:10 1998
@@ -136,6 +136,8 @@
 
 	if (PageLocked(page))
 		goto next;
+	if (page->lifetime)
+		page->lifetime--;
 	if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
 		goto next;
 	/* First of all, regenerate the page's referenced bit
@@ -167,15 +169,16 @@
 	case 1:
 		/* is it a swap-cache or page-cache page? */
 		if (page->inode) {
-			/* Throw swap-cache pages away more aggressively */
-			if (PageSwapCache(page)) {
-				delete_from_swap_cache(page);
-				return 1;
-			}
 			if (test_and_clear_bit(PG_referenced, &page->flags))
 				break;
 			if (pgcache_under_min())
 				break;
+			if (PageSwapCache(page)) {
+				if (page->lifetime && pgcache_under_borrow())
+					break;
+				delete_from_swap_cache(page);
+				return 1;
+			}
 			remove_inode_page(page);
 			return 1;
 		}
@@ -183,7 +186,8 @@
 		 * If it has been referenced recently, don't free it */
 		if (test_and_clear_bit(PG_referenced, &page->flags))
 			break;
-
+		if (buffer_under_min())
+			break;
 		/* is it a buffer cache page? */
 		if (bh && try_to_free_buffer(bh, &bh, 6))
 			return 1;
diff -urN linux-2.1.129/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-2.1.129/mm/page_alloc.c	Thu Nov 19 20:44:18 1998
+++ linux/mm/page_alloc.c	Tue Nov 24 12:37:30 1998
@@ -231,11 +231,13 @@
 		map += size; \
 	} \
 	atomic_set(&map->count, 1); \
+	map->lifetime = 0; \
 } while (0)
 
 unsigned long __get_free_pages(int gfp_mask, unsigned long order)
 {
 	unsigned long flags;
+	int loop = 0;
 
 	if (order >= NR_MEM_LISTS)
 		goto nopage;
@@ -262,6 +264,7 @@
 				goto nopage;
 		}
 	}
+repeat:
 	spin_lock_irqsave(&page_alloc_lock, flags);
 	RMQUEUE(order, (gfp_mask & GFP_DMA));
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
@@ -274,6 +277,8 @@
 	if (gfp_mask & __GFP_WAIT) {
 		current->policy |= SCHED_YIELD;
 		schedule();
+		if (!loop++ && nr_free_pages > freepages.low)
+			goto repeat;
 	}
 
 nopage:
@@ -399,6 +404,10 @@
 	vma->vm_mm->rss++;
 	tsk->min_flt++;
 	swap_free(entry);
+
+	/* Increase life time of the page */
+	if (page_map->lifetime < 3 && pgcache_under_max())
+		page_map->lifetime++;
 
 	if (!write_access || is_page_shared(page_map)) {
 		set_pte(page_table, mk_pte(page, vma->vm_page_prot));
diff -urN linux-2.1.129/mm/swap.c linux/mm/swap.c
--- linux-2.1.129/mm/swap.c	Wed Sep  9 17:56:59 1998
+++ linux/mm/swap.c	Tue Nov 24 13:08:19 1998
@@ -76,7 +76,7 @@
 
 buffer_mem_t page_cache = {
 	5,	/* minimum percent page cache */
-	30,	/* borrow percent page cache */
+	25,	/* borrow percent page cache */
 	75	/* maximum */
 };
 
diff -urN linux-2.1.129/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.1.129/mm/vmscan.c	Thu Nov 19 20:44:18 1998
+++ linux/mm/vmscan.c	Tue Nov 24 00:06:20 1998
@@ -561,6 +561,7 @@
 int try_to_free_pages(unsigned int gfp_mask, int count)
 {
 	int retval = 1;
+	int is_dma = (gfp_mask & __GFP_DMA);
 
 	lock_kernel();
 	if (!(current->flags & PF_MEMALLOC)) {
@@ -568,6 +569,8 @@
 		do {
 			retval = do_try_to_free_page(gfp_mask);
 			if (!retval)
+				break;
+			if (!is_dma && nr_free_pages > freepages.high + SWAP_CLUSTER_MAX)
 				break;
 			count--;
 		} while (count > 0);
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
