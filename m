Subject: Re: [uPatch] Re: Graceful failure?
References: <Pine.LNX.4.21.0006051258370.31069-100000@duckman.distro.conectiva>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 05 Jun 2000 21:21:25 +0100
In-Reply-To: Rik van Riel's message of "Mon, 5 Jun 2000 13:03:08 -0300 (BRST)"
Message-ID: <m2r9abev5m.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Billy Harvey <Billy.Harvey@thrillseeker.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On Mon, 5 Jun 2000, Billy Harvey wrote:
> 
> > A "make -j" slowly over the course of 5 minutes drives the load
> > to about 30.  At first the degradation is controlled, with
> > sendmail refusing service, but at about 160 process visible in
> > top, top quits updating (set a 8 second updates), showing about
> > 2 MB swap used.  At this point it sounds like the system is
> > thrashing.
> 
> That probably means you're a lot more in swap now and top
> has stopped displaying before you really hit the swap...

Allow me to hype my patch again. Could someone please test it?

It improves performance markedly (no horrible pauses in
vmscan.c:swap_out under heavy load).

> 
> > Is this failure process acceptable?  I'd think the system should
> > react differently to the thrashing, killing off the load
> > demanding user process(es), rather than degrading to a point of
> > freeze.

My patch fixes this for me, please test.

[...]

--- linux-2.4.0t1a7m3/mm/vmscan.c	Sat Jun  3 17:10:15 2000
+++ kernel-hacking/mm/vmscan.c	Sun Jun  4 16:35:31 2000
@@ -361,23 +361,24 @@
 	/* 
 	 * We make one or two passes through the task list, indexed by 
 	 * assign = {0, 1}:
-	 *   Pass 1: select the swappable task with maximal RSS that has
-	 *         not yet been swapped out. 
+	 *
+	 *   Pass 1: select the first swappable task that has not yet
+	 *   been swapped out.
+	 *
 	 *   Pass 2: re-assign rss swap_cnt values, then select as above.
 	 *
 	 * With this approach, there's no need to remember the last task
 	 * swapped out.  If the swap-out fails, we clear swap_cnt so the 
 	 * task won't be selected again until all others have been tried.
 	 *
-	 * Think of swap_cnt as a "shadow rss" - it tells us which process
-	 * we want to page out (always try largest first).
-	 */
+	 * Think of swap_cnt as a "shadow rss" - it tells us which
+	 * process we want to page out (always try largest first).  */
+	
 	counter = (nr_threads << 2) >> (priority >> 2);
 	if (counter < 1)
 		counter = 1;
 
 	for (; counter >= 0; counter--) {
-		unsigned long max_cnt = 0;
 		struct mm_struct *best = NULL;
 		int pid = 0;
 		int assign = 0;
@@ -391,13 +392,14 @@
 	 		if (mm->rss <= 0)
 				continue;
 			/* Refresh swap_cnt? */
-			if (assign == 1)
+			best = mm;
+			pid = p->pid;
+
+			if (assign == 1){
 				mm->swap_cnt = mm->rss;
-			if (mm->swap_cnt > max_cnt) {
-				max_cnt = mm->swap_cnt;
-				best = mm;
-				pid = p->pid;
 			}
+			else
+				break;
 		}
 		read_unlock(&tasklist_lock);
 		if (!best) {


-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
