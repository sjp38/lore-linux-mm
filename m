Received: from Cantor.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA15646
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 15:56:58 -0500
Message-ID: <19981123215359.45625@boole.suse.de>
Date: Mon, 23 Nov 1998 21:53:59 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Running 2.1.129 at extrem load [patch] (Was: Linux-2.1.129..)
References: <19981119223434.00625@boole.suse.de> <Pine.LNX.3.95.981119143242.13021A-100000@penguin.transmeta.com> <199811231713.RAA17361@dax.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199811231713.RAA17361@dax.scot.redhat.com>; from Stephen C. Tweedie on Mon, Nov 23, 1998 at 05:13:34PM +0000
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: linux-mm <linux-mm@kvack.org>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

[...]

> > Maybe we even want to keep a 3:1 ratio or something like that for
> > mapped:swap_cached pages and a semi- FIFO reclamation of swap cached
> > pages so we can simulate a bit of (very cheap) page aging.
> 
> I will just restate my profound conviction that any VM balancing which
> works by imposing precalculated limits on resources is fundamentally
> wrong.
> 
> Cheers,
>   Stephen

I've done some simply test and worked out some changes (patch enclosed).
Starting with a plain 2.1.129 I've run a simple stress
situation:

       * 64MB ram + 128 MB swap
       * Under X11 (fvwm2)
       * xload
       * xosview
       * xterm running top
       * xterm running tail -f /var/log/warn /var/log/messages
       * xterm compiling 2.0.36 sources with:
             while true; do make clean; make -j || break ; done
       * xterm compiling 2.1.129 sources with:
             while true; do make clean; make MAKE='make -j5' || break ; done


.. clearly all together.  Load goes upto 30 and higher and random SIGBUS
to random processes occurs (in best case the X server was signaled which
makes the system usable again).

I've add some changes:

       * changed the position of deleting pages from
         swap cache in mm/filemap.c::shrink_one_page()
       * add a simple repeat case in
         mm/page_alloc.c::__get_free_pages() if we wait
         on low priority pages (aka GFP_USER).
       * don't let mm/vmscan.c::try_to_free_pages()
         scan to much.
       * add a simple age scheme for recently swapped in
         pages. (The condition, e.g. a bigger rss window
         is changeable).

The random SIGBUS disappears and the system seems more usable
which means only loads over 35 and higher makes the system
only temporarily unusable.


            Werner

--------------------------------------------------------------------
diff -urN linux-2.1.129/include/linux/mm.h linux/include/linux/mm.h
--- linux-2.1.129/include/linux/mm.h	Thu Nov 19 20:49:37 1998
+++ linux/include/linux/mm.h	Mon Nov 23 14:53:14 1998
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
+++ linux/ipc/shm.c	Mon Nov 23 15:14:00 1998
@@ -15,6 +15,7 @@
 #include <linux/stat.h>
 #include <linux/malloc.h>
 #include <linux/swap.h>
+#include <linux/swapctl.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/init.h>
@@ -656,6 +657,7 @@
 
 	pte = __pte(shp->shm_pages[idx]);
 	if (!pte_present(pte)) {
+		int old_rss = shm_rss;
 		unsigned long page = get_free_page(GFP_KERNEL);
 		if (!page) {
 			oom(current);
@@ -677,6 +679,16 @@
 			shm_swp--;
 		}
 		shm_rss++;
+
+		/* Increase life time of the page */
+		mem_map[MAP_NR(page)].lifetime = 0;
+		if (old_rss == 0) 
+			current->dec_flt++;
+		if (current->dec_flt > 3) {
+			mem_map[MAP_NR(page)].lifetime = 3 * PAGE_ADVANCE;
+			current->dec_flt = 0;
+		}
+
 		pte = pte_mkdirty(mk_pte(page, PAGE_SHARED));
 		shp->shm_pages[idx] = pte_val(pte);
 	} else
diff -urN linux-2.1.129/mm/filemap.c linux/mm/filemap.c
--- linux-2.1.129/mm/filemap.c	Thu Nov 19 20:44:18 1998
+++ linux/mm/filemap.c	Mon Nov 23 13:38:47 1998
@@ -167,15 +167,14 @@
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
+				delete_from_swap_cache(page);
+				return 1;
+			}
 			remove_inode_page(page);
 			return 1;
 		}
diff -urN linux-2.1.129/mm/page_alloc.c linux/mm/page_alloc.c
--- linux-2.1.129/mm/page_alloc.c	Thu Nov 19 20:44:18 1998
+++ linux/mm/page_alloc.c	Mon Nov 23 19:31:10 1998
@@ -236,6 +236,7 @@
 unsigned long __get_free_pages(int gfp_mask, unsigned long order)
 {
 	unsigned long flags;
+	int loop = 0;
 
 	if (order >= NR_MEM_LISTS)
 		goto nopage;
@@ -262,6 +263,7 @@
 				goto nopage;
 		}
 	}
+repeat:
 	spin_lock_irqsave(&page_alloc_lock, flags);
 	RMQUEUE(order, (gfp_mask & GFP_DMA));
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
@@ -274,6 +276,8 @@
 	if (gfp_mask & __GFP_WAIT) {
 		current->policy |= SCHED_YIELD;
 		schedule();
+		if (!loop++ && nr_free_pages > freepages.low)
+			goto repeat;
 	}
 
 nopage:
@@ -380,6 +384,7 @@
 {
 	unsigned long page;
 	struct page *page_map;
+	int shared, old_rss = vma->vm_mm->rss;
 	
 	page_map = read_swap_cache(entry);
 
@@ -399,8 +404,18 @@
 	vma->vm_mm->rss++;
 	tsk->min_flt++;
 	swap_free(entry);
+	shared = is_page_shared(page_map);
 
-	if (!write_access || is_page_shared(page_map)) {
+	/* Increase life time of the page */
+	page_map->lifetime = 0;
+	if (old_rss == 0)
+		tsk->dec_flt++;
+	if (tsk->dec_flt > 3) {
+		page_map->lifetime = (shared ? 2 : 5) * PAGE_ADVANCE;
+		tsk->dec_flt = 0;
+	}
+
+	if (!write_access || shared) {
 		set_pte(page_table, mk_pte(page, vma->vm_page_prot));
 		return;
 	}
diff -urN linux-2.1.129/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.1.129/mm/vmscan.c	Thu Nov 19 20:44:18 1998
+++ linux/mm/vmscan.c	Mon Nov 23 19:34:21 1998
@@ -131,12 +131,21 @@
 		return 0;
 	}
 
+	/* life time decay */
+	if (page_map->lifetime > PAGE_DECLINE)
+		page_map->lifetime -= PAGE_DECLINE;
+	else
+		page_map->lifetime = 0;
+	if (page_map->lifetime)
+		return 0;
+
 	if (pte_dirty(pte)) {
 		if (vma->vm_ops && vma->vm_ops->swapout) {
 			pid_t pid = tsk->pid;
 			vma->vm_mm->rss--;
-			if (vma->vm_ops->swapout(vma, address - vma->vm_start + vma->vm_offset, page_table))
+			if (vma->vm_ops->swapout(vma, address - vma->vm_start + vma->vm_offset, page_table)) {
 				kill_proc(pid, SIGBUS, 1);
+			}
 		} else {
 			/*
 			 * This is a dirty, swappable page.  First of all,
@@ -561,6 +570,7 @@
 int try_to_free_pages(unsigned int gfp_mask, int count)
 {
 	int retval = 1;
+	int is_dma = (gfp_mask & __GFP_DMA);
 
 	lock_kernel();
 	if (!(current->flags & PF_MEMALLOC)) {
@@ -568,6 +578,8 @@
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
