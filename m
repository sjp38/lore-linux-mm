Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id F3F892158B
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:07:27 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 09 of 16] fallback killing more tasks if tif-memdie doesn't go
	away
Message-Id: <4a70e6a4142230fa161d.1181332987@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:07 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332961 -7200
# Node ID 4a70e6a4142230fa161dd37202cd62fede122880
# Parent  60059913ab07906fceda14ffa72f2c77ef282fca
fallback killing more tasks if tif-memdie doesn't go away

Waiting indefinitely for a TIF_MEMDIE task to go away will deadlock. Two
tasks reading from the same inode at the same time and both going out of
memory inside a read(largebuffer) syscall, will even deadlock through
contention over the PG_locked bitflag. The task holding the semaphore
detects oom but the oom killer decides to kill the task blocked in
wait_on_page_locked(). The task holding the semaphore will hang inside
alloc_pages that will never return because it will wait the TIF_MEMDIE
task to go away, but the TIF_MEMDIE task can't go away until the task
holding the semaphore is killed in the first place.

It's quite unpractical to teach the oom killer the locking dependencies
across running tasks, so the feasible fix is to develop a logic that
after waiting a long time for a TIF_MEMDIE tasks goes away, fallbacks
on killing one more task. This also eliminates the possibility of
suprious oom killage (i.e. two tasks killed despite only one had to be
killed). It's not a math guarantee because we can't demonstrate that if
a TIF_MEMDIE SIGKILLED task didn't mange to complete do_exit within
10sec, it never will. But the current probability of suprious oom
killing is sure much higher than the probability of suprious oom killing
with this patch applied.

The whole locking is around the tasklist_lock. On one side do_exit reads
TIF_MEMDIE and clears VM_is_OOM under the lock, on the other side the
oom killer accesses VM_is_OOM and TIF_MEMDIE under the lock. This is a
read_lock in the oom killer but it's actually a write lock thanks to the
OOM_lock semaphore running one oom killer at once (the locking rule is,
either use write_lock_irq or read_lock+OOM_lock).

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -845,6 +845,15 @@ static void exit_notify(struct task_stru
 	     unlikely(tsk->parent->signal->flags & SIGNAL_GROUP_EXIT)))
 		state = EXIT_DEAD;
 	tsk->exit_state = state;
+
+	/*
+	 * Read TIF_MEMDIE and set VM_is_OOM to 0 atomically inside
+	 * the tasklist_lock_lock.
+	 */
+	if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE))) {
+		extern unsigned long VM_is_OOM;
+		clear_bit(0, &VM_is_OOM);
+	}
 
 	write_unlock_irq(&tasklist_lock);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -28,6 +28,9 @@ int sysctl_panic_on_oom;
 int sysctl_panic_on_oom;
 /* #define DEBUG */
 
+unsigned long VM_is_OOM;
+static unsigned long last_tif_memdie_jiffies;
+
 /**
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
@@ -225,21 +228,14 @@ static struct task_struct *select_bad_pr
 		if (is_init(p))
 			continue;
 
-		/*
-		 * This task already has access to memory reserves and is
-		 * being killed. Don't allow any other task access to the
-		 * memory reserve.
-		 *
-		 * Note: this may have a chance of deadlock if it gets
-		 * blocked waiting for another task which itself is waiting
-		 * for memory. Is there a better alternative?
-		 *
-		 * Better not to skip PF_EXITING tasks, since they
-		 * don't have access to the PF_MEMALLOC pool until
-		 * we select them here first.
-		 */
-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
-			return ERR_PTR(-1UL);
+		if (unlikely(test_tsk_thread_flag(p, TIF_MEMDIE))) {
+			/*
+			 * Either we already waited long enough,
+			 * or exit_mm already run, so we must
+			 * try to kill another task.
+			 */
+			continue;
+		}
 
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;
@@ -276,13 +272,16 @@ static void __oom_kill_task(struct task_
 	if (verbose)
 		printk(KERN_ERR "Killed process %d (%s)\n", p->pid, p->comm);
 
+	if (!test_and_set_tsk_thread_flag(p, TIF_MEMDIE)) {
+		last_tif_memdie_jiffies = jiffies;
+		set_bit(0, &VM_is_OOM);
+	}
 	/*
 	 * We give our sacrificial lamb high priority and access to
 	 * all the memory it needs. That way it should be able to
 	 * exit() and clear out its resources quickly...
 	 */
 	p->time_slice = HZ;
-	set_tsk_thread_flag(p, TIF_MEMDIE);
 
 	force_sig(SIGKILL, p);
 }
@@ -419,6 +418,18 @@ void out_of_memory(struct zonelist *zone
 	constraint = constrained_alloc(zonelist, gfp_mask);
 	cpuset_lock();
 	read_lock(&tasklist_lock);
+
+	/*
+	 * This holds the down(OOM_lock)+read_lock(tasklist_lock), so it's
+	 * equivalent to write_lock_irq(tasklist_lock) as far as VM_is_OOM
+	 * is concerned.
+	 */
+	if (unlikely(test_bit(0, &VM_is_OOM))) {
+		if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
+			goto out;
+		printk("detected probable OOM deadlock, so killing another task\n");
+		last_tif_memdie_jiffies = jiffies;
+	}
 
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
@@ -440,10 +451,6 @@ retry:
 		 * issues we may have.
 		 */
 		p = select_bad_process(&points);
-
-		if (PTR_ERR(p) == -1UL)
-			goto out;
-
 		/* Found nothing?!?! Either we hang forever, or we panic. */
 		if (!p) {
 			read_unlock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
