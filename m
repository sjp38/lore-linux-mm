Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id PAA00941
	for <linux-mm@kvack.org>; Tue, 20 Jun 2000 15:39:02 +0100
Subject: [PATCH][CFT] vmscan::swap_out optimisations
From: "John Fremlin" <vii@penguinpowered.com>
Date: 20 Jun 2000 15:39:01 +0100
Message-ID: <m2g0q8xvqy.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-=-=

This patch is against stock ac22-riel. It is experimental, just for
testing. It needs more work.

It should alleviate most of the horrible couple of second freezeups.

What it does:
        Changes meaning of priority argument to swap_out.

        Stops looking for best process to take pages off, just take
pages off first one

        Microoptimisations (moving loops about, loop unrolling).

The rationale for the first change is that having vague definitions
like "higher priority means try harder" is extremely difficult to tune
correctly, i.e. you're likely to either try as hard as you can, or as
little as you can. This was happening on my box, with counter either
1-5 or > 30k.

Now the priority argument is straightforwardly the number of processes
we try to steal pages off. However, none of the calling procedures has
been changed so the system is now even worse tuned than before ;-)
This doesn't seem to matter to my box very much.

The rationale for the second change I have already explained. Both
design analysis and empirical evidence show that looking through a
scattered link list (with resultant cache penalties) for the best
process to take pages off is a waste of time.

I think I may have broken something in moving the loops around. The
patch is not finished (it still prints out the priority arg, so you
can believe me that its messed up).


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment;
  filename=linux-2.4.0test1-ac22-riel-mm1

--- linux/mm/vmscan.c	Mon Jun 19 23:57:44 2000
+++ linux-hacked/mm/vmscan.c	Tue Jun 20 12:23:45 2000
@@ -356,8 +356,9 @@
 	struct task_struct * p;
 	int counter;
 	int __ret = 0;
+	struct mm_struct *best = NULL;
+	int pid = 0;
 
-	lock_kernel();
 	/* 
 	 * We make one or two passes through the task list, indexed by 
 	 * assign = {0, 1}:
@@ -372,49 +373,39 @@
 	 * Think of swap_cnt as a "shadow rss" - it tells us which process
 	 * we want to page out (always try largest first).
 	 */
-	counter = (nr_threads << 2) >> (priority >> 2);
+	counter = priority;
 	if (counter < 1)
 		counter = 1;
 
-	for (; counter >= 0; counter--) {
-		unsigned long max_cnt = 0;
-		struct mm_struct *best = NULL;
-		int pid = 0;
-		int assign = 0;
-	select:
-		read_lock(&tasklist_lock);
-		p = init_task.next_task;
-		for (; p != &init_task; p = p->next_task) {
-			struct mm_struct *mm = p->mm;
-			if (!p->swappable || !mm)
-				continue;
-	 		if (mm->rss <= 0)
-				continue;
-			/* Refresh swap_cnt? */
-			if (assign == 1)
-				mm->swap_cnt = mm->rss;
-			if (mm->swap_cnt > max_cnt) {
-				max_cnt = mm->swap_cnt;
-				best = mm;
-				pid = p->pid;
-			}
-		}
+	printk(KERN_DEBUG "vmscan: count %d\n", counter );
+
+	lock_kernel();
+	
+
+	read_lock(&tasklist_lock);
+	p = init_task.next_task;
+	for (; p != &init_task; p = p->next_task) {
+		struct mm_struct *mm = p->mm;
+		if (!p->swappable || !mm)
+			continue;
+		if (mm->rss <= 0)
+			continue;
+
+		best = mm;
+		pid = p->pid;
 		read_unlock(&tasklist_lock);
-		if (!best) {
-			if (!assign) {
-				assign = 1;
-				goto select;
-			}
-			goto out;
-		} else {
+		{
 			int ret;
 
 			atomic_inc(&best->mm_count);
 			ret = swap_out_mm(best, gfp_mask);
 			mmdrop(best);
 
-			if (!ret)
+			if (!ret) {
+				if(!--counter)goto out;
 				continue;
+			}
+			
 
 			if (ret < 0)
 				kill_proc(pid, SIGBUS, 1);
@@ -422,6 +413,21 @@
 			goto out;
 		}
 	}
+	read_unlock(&tasklist_lock);
+	read_lock(&tasklist_lock);
+	p = init_task.next_task;
+	for (; p != &init_task; p = p->next_task) {
+		struct mm_struct *mm = p->mm;
+		if (!p->swappable || !mm)
+			continue;
+		if (mm->rss <= 0)
+			continue;
+		mm->swap_cnt = mm->rss;
+	}
+	read_unlock(&tasklist_lock);
+
+	goto out;
+
 out:
 	unlock_kernel();
 	return __ret;

--=-=-=


-- 

	http://altern.org/vii

--=-=-=--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
