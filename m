Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 339D1900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 03:43:38 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p7U7hW0E031864
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:43:33 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by hpaq2.eem.corp.google.com with ESMTP id p7U7gLhG007626
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:43:30 -0700
Received: by pzk32 with SMTP id 32so11124175pzk.5
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:43:30 -0700 (PDT)
Date: Tue, 30 Aug 2011 00:43:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] oom: remove oom_disable_count
In-Reply-To: <alpine.DEB.2.00.1108291611070.32495@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1108300040490.21066@chino.kir.corp.google.com>
References: <20110727163159.GA23785@redhat.com> <20110727163610.GJ23793@redhat.com> <20110727175624.GA3950@redhat.com> <20110728154324.GA22864@redhat.com> <alpine.DEB.2.00.1107281341060.16093@chino.kir.corp.google.com> <20110729141431.GA3501@redhat.com>
 <20110730143426.GA6061@redhat.com> <20110730152238.GA17424@redhat.com> <4E369372.80105@jp.fujitsu.com> <20110829183743.GA15216@redhat.com> <alpine.DEB.2.00.1108291611070.32495@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This removes mm->oom_disable_count entirely since it's unnecessary and
currently buggy.  The counter was intended to be per-process but it's
currently decremented in the exit path for each thread that exits, causing
it to underflow.

The count was originally intended to prevent oom killing threads that
share memory with threads that cannot be killed since it doesn't lead to
future memory freeing.  The counter could be fixed to represent all
threads sharing the same mm, but it's better to remove the count since:

 - it is possible that the OOM_DISABLE thread sharing memory with the
   victim is waiting on that thread to exit and will actually cause
   future memory freeing, and

 - there is no guarantee that a thread is disabled from oom killing just
   because another thread sharing its mm is oom disabled.

Reported-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/exec.c                |    4 ----
 fs/proc/base.c           |   13 -------------
 include/linux/mm_types.h |    3 ---
 kernel/exit.c            |    2 --
 kernel/fork.c            |   10 +---------
 mm/oom_kill.c            |   23 +++++------------------
 6 files changed, 6 insertions(+), 49 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -841,10 +841,6 @@ static int exec_mmap(struct mm_struct *mm)
 	tsk->mm = mm;
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
-	if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-		atomic_dec(&old_mm->oom_disable_count);
-		atomic_inc(&tsk->mm->oom_disable_count);
-	}
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1107,13 +1107,6 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 		goto err_sighand;
 	}
 
-	if (oom_adjust != task->signal->oom_adj) {
-		if (oom_adjust == OOM_DISABLE)
-			atomic_inc(&task->mm->oom_disable_count);
-		if (task->signal->oom_adj == OOM_DISABLE)
-			atomic_dec(&task->mm->oom_disable_count);
-	}
-
 	/*
 	 * Warn that /proc/pid/oom_adj is deprecated, see
 	 * Documentation/feature-removal-schedule.txt.
@@ -1215,12 +1208,6 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 		goto err_sighand;
 	}
 
-	if (oom_score_adj != task->signal->oom_score_adj) {
-		if (oom_score_adj == OOM_SCORE_ADJ_MIN)
-			atomic_inc(&task->mm->oom_disable_count);
-		if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-			atomic_dec(&task->mm->oom_disable_count);
-	}
 	task->signal->oom_score_adj = oom_score_adj;
 	if (has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = oom_score_adj;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -313,9 +313,6 @@ struct mm_struct {
 	unsigned int token_priority;
 	unsigned int last_interval;
 
-	/* How many tasks sharing this mm are OOM_DISABLE */
-	atomic_t oom_disable_count;
-
 	unsigned long flags; /* Must use atomic bitops to access the bits */
 
 	struct core_state *core_state; /* coredumping support */
diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -681,8 +681,6 @@ static void exit_mm(struct task_struct * tsk)
 	enter_lazy_tlb(mm, current);
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
-	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-		atomic_dec(&mm->oom_disable_count);
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -501,7 +501,6 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm->cached_hole_size = ~0UL;
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
-	atomic_set(&mm->oom_disable_count, 0);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
@@ -816,8 +815,6 @@ good_mm:
 	/* Initializing for Swap token stuff */
 	mm->token_priority = 0;
 	mm->last_interval = 0;
-	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-		atomic_inc(&mm->oom_disable_count);
 
 	tsk->mm = mm;
 	tsk->active_mm = mm;
@@ -1391,13 +1388,8 @@ bad_fork_cleanup_io:
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
-	if (p->mm) {
-		task_lock(p);
-		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-			atomic_dec(&p->mm->oom_disable_count);
-		task_unlock(p);
+	if (p->mm)
 		mmput(p->mm);
-	}
 bad_fork_cleanup_signal:
 	if (!(clone_flags & CLONE_THREAD))
 		free_signal_struct(p->signal);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -53,13 +53,7 @@ int test_set_oom_score_adj(int new_val)
 
 	spin_lock_irq(&sighand->siglock);
 	old_val = current->signal->oom_score_adj;
-	if (new_val != old_val) {
-		if (new_val == OOM_SCORE_ADJ_MIN)
-			atomic_inc(&current->mm->oom_disable_count);
-		else if (old_val == OOM_SCORE_ADJ_MIN)
-			atomic_dec(&current->mm->oom_disable_count);
-		current->signal->oom_score_adj = new_val;
-	}
+	current->signal->oom_score_adj = new_val;
 	spin_unlock_irq(&sighand->siglock);
 
 	return old_val;
@@ -172,16 +166,6 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 		return 0;
 
 	/*
-	 * Shortcut check for a thread sharing p->mm that is OOM_SCORE_ADJ_MIN
-	 * so the entire heuristic doesn't need to be executed for something
-	 * that cannot be killed.
-	 */
-	if (atomic_read(&p->mm->oom_disable_count)) {
-		task_unlock(p);
-		return 0;
-	}
-
-	/*
 	 * The memory controller may have a limit of 0 bytes, so avoid a divide
 	 * by zero, if necessary.
 	 */
@@ -447,6 +431,9 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 	for_each_process(q)
 		if (q->mm == mm && !same_thread_group(q, p) &&
 		    !(q->flags & PF_KTHREAD)) {
+			if (q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+				continue;
+
 			task_lock(q);	/* Protect ->comm from prctl() */
 			pr_err("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(q), q->comm);
@@ -723,7 +710,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	read_lock(&tasklist_lock);
 	if (sysctl_oom_kill_allocating_task &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
-	    current->mm && !atomic_read(&current->mm->oom_disable_count)) {
+	    current->mm) {
 		/*
 		 * oom_kill_process() needs tasklist_lock held.  If it returns
 		 * non-zero, current could not be killed so we must fallback to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
