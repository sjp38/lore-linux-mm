Date: Fri, 21 Jan 2000 05:07:06 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] 2.2.14 VM fix #3
Message-ID: <Pine.LNX.4.10.10001210425250.27593-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Alan, Andrea,

here is my 3rd patch for the VM troubles. It has merged
parts of Andrea's patch with my patch and does some extra
improvements.

Most notably:
- int low_on_memory removed, now using freepages.* for
  hysteresis
- when we get below freepages.min, only __GFP_HIGH
  allocations are allowed to succeed (this was always
  the case and is exactly how it is documented, it
  will reduce the chance of the system running out of
  memory and code that calls with GFP_KERNEL can handle it)
- kswapd does the 1-second sleep and background freeing
  between freepages.low and freepages.high
- below freepages.low, kswapd is immediately woken up,
  __GFP_WAIT processes do a schedule() in case they
  might be lower priority than kswapd, otherwise kswapd
  will have to free memory when they get out of the way
- once we reach freepages.min, processes will actively
  try to free memory themselves and get refused their
  memory if they don't free any

In short, this patch brings the code back to the most
obvious possible code path and reverts back to old
trusted behaviour. I know this behaviour works because
we've been running that way for years...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.


--- linux-2.2.15-pre3/mm/vmscan.c.orig	Wed Jan 19 21:18:54 2000
+++ linux-2.2.15-pre3/mm/vmscan.c	Fri Jan 21 04:24:48 2000
@@ -485,41 +485,26 @@
 		 * the processes needing more memory will wake us
 		 * up on a more timely basis.
 		 */
-		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
 		while (nr_free_pages < freepages.high)
 		{
-			if (do_try_to_free_pages(GFP_KSWAPD))
-			{
-				if (tsk->need_resched)
-					schedule();
-				continue;
-			}
-			tsk->state = TASK_INTERRUPTIBLE;
-			schedule_timeout(10*HZ);
+			if (!do_try_to_free_pages(GFP_KSWAPD))
+				break;
+			if (tsk->need_resched)
+				schedule();
 		}
+		run_task_queue(&tq_disk);
+		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
 	}
 }
 
 /*
- * Called by non-kswapd processes when they want more
- * memory.
- *
- * In a perfect world, this should just wake up kswapd
- * and return. We don't actually want to swap stuff out
- * from user processes, because the locking issues are
- * nasty to the extreme (file write locks, and MM locking)
- *
- * One option might be to let kswapd do all the page-out
- * and VM page table scanning that needs locking, and this
- * process thread could do just the mmap shrink stage that
- * can be done by just dropping cached pages without having
- * any deadlock issues.
+ * Called by non-kswapd processes when kswapd really cannot
+ * keep up with the demand for free memory.
  */
 int try_to_free_pages(unsigned int gfp_mask)
 {
 	int retval = 1;
 
-	wake_up_interruptible(&kswapd_wait);
 	if (gfp_mask & __GFP_WAIT)
 		retval = do_try_to_free_pages(gfp_mask);
 	return retval;
--- linux-2.2.15-pre3/mm/page_alloc.c.orig	Wed Jan 19 21:32:05 2000
+++ linux-2.2.15-pre3/mm/page_alloc.c	Fri Jan 21 05:02:13 2000
@@ -20,6 +20,7 @@
 
 int nr_swap_pages = 0;
 int nr_free_pages = 0;
+extern struct wait_queue * kswapd_wait;
 
 /*
  * Free area management
@@ -184,8 +185,6 @@
 	atomic_set(&map->count, 1); \
 } while (0)
 
-int low_on_memory = 0;
-
 unsigned long __get_free_pages(int gfp_mask, unsigned long order)
 {
 	unsigned long flags;
@@ -212,21 +211,21 @@
 	if (!(current->flags & PF_MEMALLOC)) {
 		int freed;
 
-		if (nr_free_pages > freepages.min) {
-			if (!low_on_memory)
-				goto ok_to_allocate;
-			if (nr_free_pages >= freepages.high) {
-				low_on_memory = 0;
-				goto ok_to_allocate;
-			}
+		if (nr_free_pages <= freepages.low) {
+			wake_up_interruptible(&kswapd_wait);
+			/* a bit of defensive programming */
+			if (gfp_mask & __GFP_WAIT)
+				schedule();
 		}
+		if (nr_free_pages > freepages.min)
+			goto ok_to_allocate;
 
-		low_on_memory = 1;
+		/* Danger, danger! Do something or fail */
 		current->flags |= PF_MEMALLOC;
 		freed = try_to_free_pages(gfp_mask);
 		current->flags &= ~PF_MEMALLOC;
 
-		if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
+		if (!freed && !(gfp_mask & __GFP_HIGH))
 			goto nopage;
 	}
 ok_to_allocate:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
