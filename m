Date: Wed, 19 Jan 2000 22:15:13 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [PATCH] 2.2.1{3,4,5} VM fix
Message-ID: <Pine.LNX.4.10.10001192201020.15862-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Alan,

here's the patch for the 2.2.15* out of memory problem.
This patch does a number of things:
- make kswapd sleep just HZ, just like in 2.3
- don't start freeing memory from a user process when
  we're at or just below the limit:
	- we need the kernel lock so freeing memory
	  together with kswapd isn't possible anyway
	- if kswapd can keep up, there's no latency
	  penalty for (kernel) memory allocations
	- when we truly are low on memory or kswapd
	  can't keep up, then any __GFP_WAIT allocations
	  _will_ wait while trying to free memory
	  (so there's less chance of running out for
	  GFP_ATOMIC ones)
- wake up kswapd somewhat earlier (instead of too late)

This should be enough to make sure that 2.2.1* doesn't
run out of memory on a slight network flooding any more.
Note that I have only compiled the code with this patch
and not tried it, this wouldn't have worked anyway because
I can't create the problem situation (fast network, etc)
at home...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.



--- linux-2.2.15-pre3/mm/vmscan.c.orig	Wed Jan 19 21:18:54 2000
+++ linux-2.2.15-pre3/mm/vmscan.c	Wed Jan 19 22:06:34 2000
@@ -490,12 +490,13 @@
 		{
 			if (do_try_to_free_pages(GFP_KSWAPD))
 			{
+				run_task_queue(&tq_disk);
 				if (tsk->need_resched)
 					schedule();
 				continue;
 			}
 			tsk->state = TASK_INTERRUPTIBLE;
-			schedule_timeout(10*HZ);
+			schedule_timeout(HZ);
 		}
 	}
 }
@@ -509,18 +510,16 @@
  * from user processes, because the locking issues are
  * nasty to the extreme (file write locks, and MM locking)
  *
- * One option might be to let kswapd do all the page-out
- * and VM page table scanning that needs locking, and this
- * process thread could do just the mmap shrink stage that
- * can be done by just dropping cached pages without having
- * any deadlock issues.
+ * If we're on or just slighly below freepages.low, kswapd
+ * should manage on its own, we just give it a nudge. This
+ * should also reduce contention for the kernel lock above.
  */
 int try_to_free_pages(unsigned int gfp_mask)
 {
 	int retval = 1;
 
 	wake_up_interruptible(&kswapd_wait);
-	if (gfp_mask & __GFP_WAIT)
+	if ((gfp_mask & __GFP_WAIT) && (nr_free_pages < (freepages.low - 4)))
 		retval = do_try_to_free_pages(gfp_mask);
 	return retval;
 }
--- linux-2.2.15-pre3/mm/page_alloc.c.orig	Wed Jan 19 21:32:05 2000
+++ linux-2.2.15-pre3/mm/page_alloc.c	Wed Jan 19 21:42:00 2000
@@ -212,7 +212,7 @@
 	if (!(current->flags & PF_MEMALLOC)) {
 		int freed;
 
-		if (nr_free_pages > freepages.min) {
+		if (nr_free_pages > freepages.low) {
 			if (!low_on_memory)
 				goto ok_to_allocate;
 			if (nr_free_pages >= freepages.high) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
