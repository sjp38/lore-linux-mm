Date: Wed, 10 Jan 2001 04:39:28 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Yet another bogus piece of do_try_to_free_pages() 
In-Reply-To: <Pine.LNX.4.10.10101091604180.2906-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101100425150.7931-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jan 2001, Linus Torvalds wrote:

> I suspect that the proper fix is something more along the lines of what we
> did to bdflush: get rid of the notion of waiting synchronously from
> bdflush, and instead do the work yourself. 

Agreed. 

Without blocking on sync IO, kswapd can keep aging pages and moving
them to the inactive lists. 

The following patch changes some stuff we've discussed before (the
kmem_cache_reap and maxtry thingies) and it also removes the kswapd
sleeping scheme.

I haven't tested it yet, though I'll do it tomorrow.

diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/include/linux/swap.h linux/include/linux/swap.h
--- linux.orig/include/linux/swap.h	Wed Jan 10 02:17:59 2001
+++ linux/include/linux/swap.h	Wed Jan 10 05:52:02 2001
@@ -107,7 +107,7 @@
 extern int page_launder(int, int);
 extern int free_shortage(void);
 extern int inactive_shortage(void);
-extern void wakeup_kswapd(int);
+extern void wakeup_kswapd(void);
 extern int try_to_free_pages(unsigned int gfp_mask);
 
 /* linux/mm/page_io.c */
diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/filemap.c linux/mm/filemap.c
--- linux.orig/mm/filemap.c	Wed Jan 10 02:17:59 2001
+++ linux/mm/filemap.c	Wed Jan 10 05:54:56 2001
@@ -306,7 +306,7 @@
 	 */
 	age_page_up(page);
 	if (inactive_shortage() > inactive_target / 2 && free_shortage())
-			wakeup_kswapd(0);
+			wakeup_kswapd();
 not_found:
 	return page;
 }
diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/page_alloc.c linux/mm/page_alloc.c
--- linux.orig/mm/page_alloc.c	Wed Jan 10 02:17:59 2001
+++ linux/mm/page_alloc.c	Wed Jan 10 06:04:05 2001
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/pagemap.h>
 #include <linux/bootmem.h>
+#include <linux/slab.h>
 
 int nr_swap_pages;
 int nr_active_pages;
@@ -303,7 +304,7 @@
 	 * an inactive page shortage, wake up kswapd.
 	 */
 	if (inactive_shortage() > inactive_target / 2 && free_shortage())
-		wakeup_kswapd(0);
+		wakeup_kswapd();
 	/*
 	 * If we are about to get low on free pages and cleaning
 	 * the inactive_dirty pages would fix the situation,
@@ -379,7 +380,7 @@
 	 * - if we don't have __GFP_IO set, kswapd may be
 	 *   able to free some memory we can't free ourselves
 	 */
-	wakeup_kswapd(0);
+	wakeup_kswapd();
 	if (gfp_mask & __GFP_WAIT) {
 		__set_current_state(TASK_RUNNING);
 		current->policy |= SCHED_YIELD;
@@ -404,7 +405,7 @@
 	 * - we're doing a higher-order allocation
 	 * 	--> move pages to the free list until we succeed
 	 * - we're /really/ tight on memory
-	 * 	--> wait on the kswapd waitqueue until memory is freed
+	 * 	--> try to free pages ourselves with page_launder
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
 		/*
@@ -443,36 +444,23 @@
 		/*
 		 * When we arrive here, we are really tight on memory.
 		 *
-		 * We wake up kswapd and sleep until kswapd wakes us
-		 * up again. After that we loop back to the start.
-		 *
-		 * We have to do this because something else might eat
-		 * the memory kswapd frees for us and we need to be
-		 * reliable. Note that we don't loop back for higher
-		 * order allocations since it is possible that kswapd
-		 * simply cannot free a large enough contiguous area
-		 * of memory *ever*.
-		 */
-		if ((gfp_mask & (__GFP_WAIT|__GFP_IO)) == (__GFP_WAIT|__GFP_IO)) {
-			wakeup_kswapd(1);
-			memory_pressure++;
-			if (!order)
-				goto try_again;
-		/*
-		 * If __GFP_IO isn't set, we can't wait on kswapd because
-		 * kswapd just might need some IO locks /we/ are holding ...
-		 *
-		 * SUBTLE: The scheduling point above makes sure that
-		 * kswapd does get the chance to free memory we can't
-		 * free ourselves...
+		 * We try to free pages ourselves by:
+		 * 	- shrinking the i/d caches.
+		 * 	- reclaiming unused memory from the slab caches.
+		 * 	- swapping/syncing pages to disk (done by page_launder)
+		 * 	- moving clean pages from the inactive dirty list to
+		 * 	  the inactive clean list. (done by page_launder)
 		 */
-		} else if (gfp_mask & __GFP_WAIT) {
-			try_to_free_pages(gfp_mask);
-			memory_pressure++;
+		if (gfp_mask & __GFP_WAIT) {
+			shrink_icache_memory(6, gfp_mask);
+			shrink_dcache_memory(6, gfp_mask);
+			kmem_cache_reap(gfp_mask);
+
+			page_launder(gfp_mask, 1);
+
 			if (!order)
 				goto try_again;
 		}
-
 	}
 
 	/*
diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/slab.c linux/mm/slab.c
--- linux.orig/mm/slab.c	Wed Jan 10 02:17:59 2001
+++ linux/mm/slab.c	Wed Jan 10 06:01:27 2001
@@ -1702,7 +1702,7 @@
  * kmem_cache_reap - Reclaim memory from caches.
  * @gfp_mask: the type of memory required.
  *
- * Called from try_to_free_page().
+ * Called from do_try_to_free_pages() and __alloc_pages()
  */
 void kmem_cache_reap (int gfp_mask)
 {
diff --exclude-from=/home/marcelo/exclude -Nur linux.orig/mm/vmscan.c linux/mm/vmscan.c
--- linux.orig/mm/vmscan.c	Wed Jan 10 02:17:59 2001
+++ linux/mm/vmscan.c	Wed Jan 10 05:57:45 2001
@@ -156,20 +156,6 @@
 	return 0;
 }
 
-/*
- * A new implementation of swap_out().  We do not swap complete processes,
- * but only a small number of blocks, before we continue with the next
- * process.  The number of blocks actually swapped is determined on the
- * number of page faults, that this process actually had in the last time,
- * so we won't swap heavily used processes all the time ...
- *
- * Note: the priority argument is a hint on much CPU to waste with the
- *       swap block search, not a hint, of how much blocks to swap with
- *       each process.
- *
- * (C) 1993 Kai Petzke, wpp@marie.physik.tu-berlin.de
- */
-
 static inline int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end)
 {
 	pte_t * pte;
@@ -818,17 +804,14 @@
  */
 static int refill_inactive(unsigned int gfp_mask, int user)
 {
-	int priority, count, start_count;
+	int priority, count, start_count, maxtry;
 
 	count = inactive_shortage() + free_shortage();
 	if (user)
 		count = (1 << page_cluster);
 	start_count = count;
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
-	priority = 6;
+	maxtry = priority = 6;
 	do {
 		if (current->need_resched) {
 			__set_current_state(TASK_RUNNING);
@@ -842,7 +825,10 @@
 
 		/* If refill_inactive_scan failed, try to page stuff out.. */
 		swap_out(priority, gfp_mask);
-	} while (!inactive_shortage());
+
+		if(--maxtry <= 0)
+			return 0;
+	} while (inactive_shortage());
 
 done:
 	return (count < start_count);
@@ -872,20 +858,14 @@
 		ret += refill_inactive(gfp_mask, user);
 
 	/* 	
-	 * Delete pages from the inode and dentry cache 
-	 * if memory is low. 
+	 * Delete pages from the inode and dentry caches and 
+	 * reclaim unused slab cache if memory is low.
 	 */
 	if (free_shortage()) {
 		shrink_dcache_memory(6, gfp_mask);
 		shrink_icache_memory(6, gfp_mask);
-	} else { 
-
-		/*
-		 * Reclaim unused slab cache memory.
-		 */
 		kmem_cache_reap(gfp_mask);
-		ret = 1;
-	}
+	} 
 
 	return ret;
 }
@@ -938,13 +918,8 @@
 		static int recalc = 0;
 
 		/* If needed, try to free some memory. */
-		if (inactive_shortage() || free_shortage()) {
-			int wait = 0;
-			/* Do we need to do some synchronous flushing? */
-			if (waitqueue_active(&kswapd_done))
-				wait = 1;
-			do_try_to_free_pages(GFP_KSWAPD, wait);
-		}
+		if (inactive_shortage() || free_shortage()) 
+			do_try_to_free_pages(GFP_KSWAPD, 0);
 
 		/*
 		 * Do some (very minimal) background scanning. This
@@ -960,11 +935,6 @@
 			recalculate_vm_stats();
 		}
 
-		/*
-		 * Wake up everybody waiting for free memory
-		 * and unplug the disk queue.
-		 */
-		wake_up_all(&kswapd_done);
 		run_task_queue(&tq_disk);
 
 		/* 
@@ -995,33 +965,10 @@
 	}
 }
 
-void wakeup_kswapd(int block)
+void wakeup_kswapd(void)
 {
-	DECLARE_WAITQUEUE(wait, current);
-
-	if (current == kswapd_task)
-		return;
-
-	if (!block) {
-		if (waitqueue_active(&kswapd_wait))
-			wake_up(&kswapd_wait);
-		return;
-	}
-
-	/*
-	 * Kswapd could wake us up before we get a chance
-	 * to sleep, so we have to be very careful here to
-	 * prevent SMP races...
-	 */
-	__set_current_state(TASK_UNINTERRUPTIBLE);
-	add_wait_queue(&kswapd_done, &wait);
-
-	if (waitqueue_active(&kswapd_wait))
-		wake_up(&kswapd_wait);
-	schedule();
-
-	remove_wait_queue(&kswapd_done, &wait);
-	__set_current_state(TASK_RUNNING);
+	if (current != kswapd_task)
+		wake_up_process(kswapd_task);
 }
 
 /*
@@ -1046,7 +993,7 @@
 /*
  * Kreclaimd will move pages from the inactive_clean list to the
  * free list, in order to keep atomic allocations possible under
- * all circumstances. Even when kswapd is blocked on IO.
+ * all circumstances.
  */
 int kreclaimd(void *unused)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
