Subject: PATCH: swap_out mega (100+ times) speedboost
References: <Pine.LNX.4.21.0006032219070.17414-100000@duckman.distro.conectiva> <m2wvk54kmy.fsf@boreas.southchinaseas>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 04 Jun 2000 16:43:12 +0100
In-Reply-To: "John Fremlin"'s message of "04 Jun 2000 14:54:13 +0100"
Message-ID: <m2zop1fo4v.fsf_-_@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following patch improves responsiveness (by an immodestly
ridiculous ammount) when there are hundreds of small processes running
on a machine. Without it, it takes a few minutes for even a SysReq SAK
to get through, with it, a few seconds (AMD K6-2 64Mb)!!!  I am
somewhat excited as this is my first kernel patch (I *can't resist*
posting it to the kernel list).

It is my thesis that
        1) there is no point in finding the largest process (modified
by size_cnt) in vmscan.c:swap_out as this is unfair and a bad
heuristic; and
        2) spending ages searching through the task list to find the
very biggest is a waste of time and severely impacts performance; and
        3) the size_cnt heuristic should be done someother way.

My patch proves that searching through the task list for the largest
size_cnt severely impacts performance when there are many (100s of)
threads.

As I explained (on linux-mm):
> Perhaps, but you're traversing a linked list. That means that the
> task_struct entries will probably be widely dispersed, so that each
> one has to be fetched from main RAM, then you look at the mm_struct
> (another miss?). According to "Modern Compiler Implementation in ML"
> (Andrew W. Appel, Cambridge University Press, 1998) a secondary cache
> miss is typically 100-200 cycles.  So if we say around 300-400 cycles
> per iteration of the loop (assuming that the needed data in the two
> structs are fetched completely for each miss penalty), everything
> taken together. I'd say that's quite slow, but I guess assembly
> programming skews your outlook considerably ;-)

The patch is against 2.4.0test1-ac7 with Rik's mmpatch version 3. It
stops trying to get the biggest size_cnt on the task list
(vmscan.c:swap_out), instead just picking the first possible one to
swap out. That is, size_cnt is being (ab)used as a boolean. IMHO, I
think it should be rethoughtout, so take this patch as a technology
demonstration ;-)

Normal system performance does not seem to be affected, but
responsiveness under heavy load is increased considerably. Reports of
performance slowdowns in any situations of course welcome!

Hope I didn't break anything :=)

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
