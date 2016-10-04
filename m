Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB8C6B0261
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 05:00:26 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id bv10so384536255pad.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:26 -0700 (PDT)
Received: from mail-pa0-f67.google.com (mail-pa0-f67.google.com. [209.85.220.67])
        by mx.google.com with ESMTPS id n23si41674477pfi.168.2016.10.04.02.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 02:00:25 -0700 (PDT)
Received: by mail-pa0-f67.google.com with SMTP id t6so6111352pae.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 02:00:25 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
Date: Tue,  4 Oct 2016 11:00:08 +0200
Message-Id: <20161004090009.7974-4-mhocko@kernel.org>
In-Reply-To: <20161004090009.7974-1-mhocko@kernel.org>
References: <20161004090009.7974-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>

From: Michal Hocko <mhocko@suse.com>

mark_oom_victim and exit_oom_victim are used for oom_killer_disable
which should block as long as there are any oom victims alive. Up to now
we have relied on TIF_MEMDIE task flag to count how many oom victim
we have. This is not optimal because only one thread receives this flag
at the time while the whole process (thread group) is killed and should
die. As a result we do not thaw the whole thread group and so a multi
threaded process can leave some threads behind in the fridge. We really
want to thaw all the threads.

This is not all that easy because there is no reliable way to count
threads in the process as the oom killer might race with copy_process.
So marking all threads with TIF_MEMDIE and increment oom_victims
accordingly is not safe. Also TIF_MEMDIE flag should just die so
we should better come up with a different approach.

All we need to guarantee is that exit_oom_victim is called at the time
when no further access to (possibly suspended) devices or generate other
IO (which would clobber suspended image and only once per process)
is possible. It seems we can rely on exit_notify for that because we
already have to detect the last thread to do a cleanup. Let's propagate
that information up to do_exit and only call exit_oom_victim for such
a thread. With this in place we can safely increment oom_victims only
once per thread group and thaw all the threads from the process.
freezing_slow_path can also rely on tsk_is_oom_victim as well now.

exit_io_context is currently called after exit_notify but it seems it is
safe to call it right before exit_notify because that is passed
exit_files.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  2 +-
 kernel/exit.c         | 38 ++++++++++++++++++++++++++++----------
 kernel/freezer.c      |  3 ++-
 mm/oom_kill.c         | 29 +++++++++++++++++------------
 4 files changed, 48 insertions(+), 24 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 770d01e7a68e..605e40b47992 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2660,7 +2660,7 @@ static inline void kernel_signal_stop(void)
 	schedule();
 }
 
-extern void release_task(struct task_struct * p);
+extern bool release_task(struct task_struct * p);
 extern int send_sig_info(int, struct siginfo *, struct task_struct *);
 extern int force_sigsegv(int, struct task_struct *);
 extern int force_sig_info(int, struct siginfo *, struct task_struct *);
diff --git a/kernel/exit.c b/kernel/exit.c
index 914088e8c2ac..c762416dbed1 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -165,10 +165,11 @@ static void delayed_put_task_struct(struct rcu_head *rhp)
 }
 
 
-void release_task(struct task_struct *p)
+bool release_task(struct task_struct *p)
 {
 	struct task_struct *leader;
 	int zap_leader;
+	bool last = false;
 repeat:
 	/* don't need to get the RCU readlock here - the process is dead and
 	 * can't be modifying its own credentials. But shut RCU-lockdep up */
@@ -197,8 +198,10 @@ void release_task(struct task_struct *p)
 		 * then we are the one who should release the leader.
 		 */
 		zap_leader = do_notify_parent(leader, leader->exit_signal);
-		if (zap_leader)
+		if (zap_leader) {
 			leader->exit_state = EXIT_DEAD;
+			last = true;
+		}
 	}
 
 	write_unlock_irq(&tasklist_lock);
@@ -208,6 +211,8 @@ void release_task(struct task_struct *p)
 	p = leader;
 	if (unlikely(zap_leader))
 		goto repeat;
+
+	return last;
 }
 
 /*
@@ -434,8 +439,6 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
@@ -584,12 +587,15 @@ static void forget_original_parent(struct task_struct *father,
 /*
  * Send signals to all our closest relatives so that they know
  * to properly mourn us..
+ *
+ * Returns true if this is the last thread from the thread group
  */
-static void exit_notify(struct task_struct *tsk, int group_dead)
+static bool exit_notify(struct task_struct *tsk, int group_dead)
 {
 	bool autoreap;
 	struct task_struct *p, *n;
 	LIST_HEAD(dead);
+	bool last = false;
 
 	write_lock_irq(&tasklist_lock);
 	forget_original_parent(tsk, &dead);
@@ -606,6 +612,7 @@ static void exit_notify(struct task_struct *tsk, int group_dead)
 	} else if (thread_group_leader(tsk)) {
 		autoreap = thread_group_empty(tsk) &&
 			do_notify_parent(tsk, tsk->exit_signal);
+		last = thread_group_empty(tsk);
 	} else {
 		autoreap = true;
 	}
@@ -621,8 +628,11 @@ static void exit_notify(struct task_struct *tsk, int group_dead)
 
 	list_for_each_entry_safe(p, n, &dead, ptrace_entry) {
 		list_del_init(&p->ptrace_entry);
-		release_task(p);
+		if (release_task(p) && p == tsk)
+			last = true;
 	}
+
+	return last;
 }
 
 #ifdef CONFIG_DEBUG_STACK_USAGE
@@ -766,7 +776,18 @@ void do_exit(long code)
 	TASKS_RCU(preempt_disable());
 	TASKS_RCU(tasks_rcu_i = __srcu_read_lock(&tasks_rcu_exit_srcu));
 	TASKS_RCU(preempt_enable());
-	exit_notify(tsk, group_dead);
+
+	if (tsk->io_context)
+		exit_io_context(tsk);
+
+	/*
+	 * Notify oom_killer_disable that the last oom thread is exiting.
+	 * We might have more threads running at this point but none of them
+	 * will access any devices behind this point.
+	 */
+	if (exit_notify(tsk, group_dead) && tsk_is_oom_victim(current))
+		exit_oom_victim();
+
 	proc_exit_connector(tsk);
 	mpol_put_task_policy(tsk);
 #ifdef CONFIG_FUTEX
@@ -784,9 +805,6 @@ void do_exit(long code)
 	 */
 	tsk->flags |= PF_EXITPIDONE;
 
-	if (tsk->io_context)
-		exit_io_context(tsk);
-
 	if (tsk->splice_pipe)
 		free_pipe_info(tsk->splice_pipe);
 
diff --git a/kernel/freezer.c b/kernel/freezer.c
index 6f56a9e219fa..c6a64474a408 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -10,6 +10,7 @@
 #include <linux/syscalls.h>
 #include <linux/freezer.h>
 #include <linux/kthread.h>
+#include <linux/oom.h>
 
 /* total number of freezing conditions in effect */
 atomic_t system_freezing_cnt = ATOMIC_INIT(0);
@@ -42,7 +43,7 @@ bool freezing_slow_path(struct task_struct *p)
 	if (p->flags & (PF_NOFREEZE | PF_SUSPEND_TASK))
 		return false;
 
-	if (test_tsk_thread_flag(p, TIF_MEMDIE))
+	if (tsk_is_oom_victim(p))
 		return false;
 
 	if (pm_nosig_freezing || cgroup_freezing(p))
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f47202725ea9..e48c4c4f73f9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -649,33 +649,38 @@ static inline void wake_oom_reaper(struct task_struct *tsk)
 static void mark_oom_victim(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
+	struct task_struct *t;
 
 	WARN_ON(oom_killer_disabled);
-	/* OOM killer might race with memcg OOM */
-	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
 
 	/* oom_mm is bound to the signal struct life time. */
-	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
+	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		atomic_inc(&tsk->signal->oom_mm->mm_count);
 
+		/* Only count thread groups */
+		atomic_inc(&oom_victims);
+	}
+
 	/*
-	 * Make sure that the task is woken up from uninterruptible sleep
-	 * if it is frozen because OOM killer wouldn't be able to free
-	 * any memory and livelock. freezing_slow_path will tell the freezer
-	 * that TIF_MEMDIE tasks should be ignored.
+	 * Make sure that the the whole thread groupd is woken up from
+	 * uninterruptible sleep if it is frozen because the oom victim
+	 * will free its memory completely only after exit.
+	 * freezing_slow_path will tell the freezer that oom victims
+	 * should be ignored.
 	 */
-	__thaw_task(tsk);
-	atomic_inc(&oom_victims);
+	rcu_read_lock();
+	for_each_thread(tsk, t)
+		__thaw_task(t);
+	rcu_read_unlock();
 }
 
 /**
  * exit_oom_victim - note the exit of an OOM victim
+ *
+ * Has to be called only once per thread group.
  */
 void exit_oom_victim(void)
 {
-	clear_thread_flag(TIF_MEMDIE);
-
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
