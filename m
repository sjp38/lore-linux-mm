Date: Fri, 21 Jan 2000 02:55:19 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: [patch] 2.2.15-pre3 kswapd fix
Message-ID: <Pine.LNX.4.10.10001210252390.27593-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Andrea Arcangeli <andrea@e-mind.com>
List-ID: <linux-mm.kvack.org>

Hi Alan,

here's a much cleaner (and hopefully slightly higher
performance) fix of the kswapd problem. The code is
also more readable now...

About Andrea's freepages.low vs. freepages.min problem,
I propose we chose .low here since it's value is higher
and we're trying to solve a reliability problem here.
We'll find out what to do with the freepages.min once
we need it ... in 2.3 it _will_ be used.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.




--- linux-2.2.15-pre3/mm/vmscan.c.orig	Wed Jan 19 21:18:54 2000
+++ linux-2.2.15-pre3/mm/vmscan.c	Fri Jan 21 02:46:42 2000
@@ -485,18 +485,16 @@
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
+		tsk->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(HZ);
 	}
 }
 
@@ -509,18 +507,16 @@
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
