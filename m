Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 04 of 13] avoid selecting already killed tasks
Message-Id: <e08fdb8dad51268d7a78.1199778635@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:35 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470015 -3600
# Node ID e08fdb8dad51268d7a786625fc54c65f277f736b
# Parent  4091a7ef36c80c3d2fa0d60a7b8bd885da68154d
avoid selecting already killed tasks

If the killed task doesn't go away because it's waiting on some other
task who needs to allocate memory, to release the i_sem or some other
lock, we must fallback to killing some other task in order to kill the
original selected and already oomkilled task, but the logic that kills
the childs first, would deadlock, if the already oom-killed task was
actually the first child of the newly oom-killed task.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1178,6 +1178,7 @@ struct task_struct {
 	int make_it_fail;
 #endif
 	struct prop_local_single dirties;
+	unsigned long memdie_jiffies;
 };
 
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -30,6 +30,8 @@ int sysctl_oom_kill_allocating_task;
 int sysctl_oom_kill_allocating_task;
 static DEFINE_SPINLOCK(zone_scan_mutex);
 /* #define DEBUG */
+
+#define MEMDIE_DELAY (60*HZ)
 
 /**
  * badness - calculate a numeric value for how bad this task has been
@@ -287,7 +289,8 @@ static void __oom_kill_task(struct task_
 	 * exit() and clear out its resources quickly...
 	 */
 	p->time_slice = HZ;
-	set_tsk_thread_flag(p, TIF_MEMDIE);
+	if (!test_and_set_tsk_thread_flag(p, TIF_MEMDIE))
+		p->memdie_jiffies = jiffies;
 
 	force_sig(SIGKILL, p);
 }
@@ -362,6 +365,13 @@ static int oom_kill_process(struct task_
 	/* Try to kill a child first */
 	list_for_each_entry(c, &p->children, sibling) {
 		if (c->mm == p->mm)
+			continue;
+		/*
+		 * We cannot select tasks with TIF_MEMDIE already set
+		 * or we'll hard deadlock.
+		 */
+		if (unlikely(test_tsk_thread_flag(c, TIF_MEMDIE) &&
+			     time_before(c->memdie_jiffies + MEMDIE_DELAY, jiffies)))
 			continue;
 		if (!oom_kill_task(c))
 			return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
