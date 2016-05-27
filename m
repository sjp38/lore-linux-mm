Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39D146B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 06:31:34 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w143so161508662oiw.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 03:31:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s10si11729376igy.53.2016.05.27.03.31.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 03:31:29 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task more than twice
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464276476-25136-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464276476-25136-1-git-send-email-mhocko@kernel.org>
Message-Id: <201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
Date: Fri, 27 May 2016 19:31:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@parallels.com, mhocko@suse.com

Michal Hocko wrote:
> Hi,
> I believe that after [1] and this patch we can reasonably expect that
> the risk of the oom lockups is so low that we do not need to employ
> timeout based solutions. I am sending this as an RFC because there still
> might be better ways to accomplish the similar effect. I just like this
> one because it is nicely grafted into the oom reaper which will now be
> invoked for basically all oom victims.
> 
> [1] http://lkml.kernel.org/r/1464266415-15558-1-git-send-email-mhocko@kernel.org

I still cannot agree with "we do not need to employ timeout based solutions".

While it is true that OOM-reap is per "struct mm_struct" action, we don't
need to change user visible oom_score_adj interface by [1] in order to
enforce OOM-kill being per "struct mm_struct" action.

It is possible that a victim thread releases a lot of memory by closing
pipe's file descriptors at exit_files() (before exit_task_work() which is
between exit_mm() and exit_notify()). The problem is that there is no
trigger for giving up (e.g. timeout) when that optimistic expectation
failed. As long as we wake up the OOM reaper, we can use the OOM reaper
as a trigger for giving up, and we can perfectly avoid OOM lockups
as long as the OOM killer is invoked.

We were too much focused on making sure that TIF_MEMDIE thread does not get stuck
at down_read() in exit_mm(). We forgot about "tsk->mm = NULL -> exit_aio() etc.
by mmput() -> exit_oom_victim()" sequence where exit_aio() can be blocked on I/O
which involves memory allocation and oom_scan_process_thread() returns
OOM_SCAN_ABORT due to task->signal->oom_victims > 0 and __oom_reap_task() cannot
reap due to find_lock_task_mm() returning NULL and/or mm->mm_users is already 0.

Yes, commit 449d777d7ad6d7f9 ("mm, oom_reaper: clear TIF_MEMDIE for all tasks
queued for oom_reaper") which went to Linux 4.7-rc1 will clear TIF_MEMDIE and
decrement task->signal->oom_victims even if __oom_reap_task() cannot reap
so that oom_scan_process_thread() will not return OOM_SCAN_ABORT forever.
But still, such unlocking depends on an assumption that wake_oom_reaper() is
always called.

What we need to have is "always call wake_oom_reaper() in order to let the
OOM reaper clear TIF_MEMDIE and mark as no longer OOM-killable" or "ignore
TIF_MEMDIE after some timeout". As you hate timeout, I propose below patch
instead of [1] and your "[RFC PATCH] mm, oom_reaper: do not attempt to reap
a task more than twice".
----------
>From a6b9f155e99971ef6144583a9ca1f427b0a85df8 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 27 May 2016 15:59:29 +0900
Subject: [PATCH] mm,oom: Make sure OOM killer always make forward progress

This patch is for handling problems listed below.

  (1) Incomplete TIF_MEMDIE shortcuts which may cause OOM livelock
      due to failing to wake up the OOM reaper.

  (2) Infinite retry loop which may cause OOM livelock because
      the OOM killer continues selecting the same victim forever.

  (3) MM shared by unkillable tasks which may cause OOM livelock
      because the OOM killer cannot wake up the OOM reaper.

The core of this patch is mm_is_reapable() which examines whether all
threads using a given mm is dying. While mm_is_reapable() is costly and
slow operation, it is true only until that mm gets MMF_OOM_REAPABLE.
It is likely that once oom_kill_process() selects an OOM victim,
subsequent mm_is_reapable() calls (from __oom_reap_task() by the OOM
reaper and/or out_of_memory()/mem_cgroup_out_of_memory() shortcuts
by any threads sharing that OOM victim's mm) find MMF_OOM_REAPABLE.

There are two exceptions which this patch does not address.
One is that it is theoretically possible that sending SIGKILL to
oom_task_origin() task can get stuck, as explained as
http://lkml.kernel.org/r/1463796090-7948-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
The other is that it is theoretically possible that current thread which
got TIF_MEMDIE using out_of_memory()/mem_cgroup_out_of_memory() shortcuts
gets stuck due to unable to satisfy __GFP_NOFAIL allocation request (and
therefore needs to select next OOM victim). We will be able to avoid such
infinite retry loop using per "struct task_struct" atomic flags.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  32 +----------
 include/linux/sched.h |   1 +
 mm/memcontrol.c       |   7 +--
 mm/oom_kill.c         | 153 ++++++++++++++++++++++++++------------------------
 4 files changed, 84 insertions(+), 109 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8346952..3f4453f 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -67,15 +67,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
-
-#ifdef CONFIG_MMU
-extern void try_oom_reaper(struct task_struct *tsk);
-#else
-static inline void try_oom_reaper(struct task_struct *tsk)
-{
-}
-#endif
+extern bool task_is_reapable(struct task_struct *tsk);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
@@ -105,28 +97,6 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
-static inline bool task_will_free_mem(struct task_struct *task)
-{
-	struct signal_struct *sig = task->signal;
-
-	/*
-	 * A coredumping process may sleep for an extended period in exit_mm(),
-	 * so the oom killer cannot assume that the process will promptly exit
-	 * and release memory.
-	 */
-	if (sig->flags & SIGNAL_GROUP_COREDUMP)
-		return false;
-
-	if (!(task->flags & PF_EXITING))
-		return false;
-
-	/* Make sure that the whole thread group is going down */
-	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
-		return false;
-
-	return true;
-}
-
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b3e84ac..d748f16 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -523,6 +523,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
+#define MMF_OOM_REAPABLE	22      /* mm is ready to be reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 37ba604..aed588e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1271,15 +1271,12 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	mutex_lock(&oom_lock);
 
 	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
+	 * If current's memory is ready to be OOM-reaped, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		try_oom_reaper(current);
+	if (task_is_reapable(current))
 		goto unlock;
-	}
 
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1685890..95fce47 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -428,6 +428,50 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
+bool mm_is_reapable(struct mm_struct *mm)
+{
+	struct task_struct *p;
+
+	if (!mm)
+		return false;
+	if (test_bit(MMF_OOM_REAPABLE, &mm->flags))
+		return true;
+	if (!down_read_trylock(&mm->mmap_sem))
+		return false;
+	up_read(&mm->mmap_sem);
+	/*
+	 * There might be other threads/processes which are either not
+	 * dying or even not killable.
+	 */
+	if (atomic_read(&mm->mm_users) > 1) {
+		rcu_read_lock();
+		for_each_process(p) {
+			bool exiting;
+
+			if (!process_shares_mm(p, mm))
+				continue;
+			if (fatal_signal_pending(p))
+				continue;
+
+			/*
+			 * If the task is exiting make sure the whole thread
+			 * group is exiting and cannot access mm anymore.
+			 */
+			spin_lock_irq(&p->sighand->siglock);
+			exiting = signal_group_exit(p->signal);
+			spin_unlock_irq(&p->sighand->siglock);
+			if (exiting)
+				continue;
+
+			/* Give up */
+			rcu_read_unlock();
+			return false;
+		}
+		rcu_read_unlock();
+	}
+	set_bit(MMF_OOM_REAPABLE, &mm->flags);
+	return true;
+}
 
 #ifdef CONFIG_MMU
 /*
@@ -483,7 +527,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 
 	task_unlock(p);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		goto unlock_oom;
 	}
@@ -553,6 +597,9 @@ static void oom_reap_task(struct task_struct *tsk)
 		debug_show_all_locks();
 	}
 
+	/* Do not allow the OOM killer to select this thread group again. */
+	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+
 	/*
 	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
 	 * reasonably reclaimable memory anymore or it is not a good candidate
@@ -606,51 +653,6 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	wake_up(&oom_reaper_wait);
 }
 
-/* Check if we can reap the given task. This has to be called with stable
- * tsk->mm
- */
-void try_oom_reaper(struct task_struct *tsk)
-{
-	struct mm_struct *mm = tsk->mm;
-	struct task_struct *p;
-
-	if (!mm)
-		return;
-
-	/*
-	 * There might be other threads/processes which are either not
-	 * dying or even not killable.
-	 */
-	if (atomic_read(&mm->mm_users) > 1) {
-		rcu_read_lock();
-		for_each_process(p) {
-			bool exiting;
-
-			if (!process_shares_mm(p, mm))
-				continue;
-			if (fatal_signal_pending(p))
-				continue;
-
-			/*
-			 * If the task is exiting make sure the whole thread group
-			 * is exiting and cannot acces mm anymore.
-			 */
-			spin_lock_irq(&p->sighand->siglock);
-			exiting = signal_group_exit(p->signal);
-			spin_unlock_irq(&p->sighand->siglock);
-			if (exiting)
-				continue;
-
-			/* Give up */
-			rcu_read_unlock();
-			return;
-		}
-		rcu_read_unlock();
-	}
-
-	wake_oom_reaper(tsk);
-}
-
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
@@ -675,7 +677,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+static void mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
@@ -743,6 +745,24 @@ void oom_killer_enable(void)
 }
 
 /*
+ * Try to mark the given task as an OOM victim.
+ *
+ * @tsk: Task to check.
+ *
+ * Needs task_lock(@tsk)/task_unlock(@tsk) unless @tsk == current.
+ */
+bool task_is_reapable(struct task_struct *tsk)
+{
+	if ((fatal_signal_pending(tsk) || (tsk->flags & PF_EXITING)) &&
+	    mm_is_reapable(tsk->mm)) {
+		mark_oom_victim(tsk);
+		wake_oom_reaper(tsk);
+		return true;
+	}
+	return false;
+}
+
+/*
  * Must be called while holding a reference to p, which will be released upon
  * returning.
  */
@@ -757,16 +777,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 * If the task's memory is ready to be OOM-reaped, then don't alarm
+	 * the sysadmin or kill its children or threads, just set TIF_MEMDIE
+	 * so it can die quickly.
 	 */
 	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		try_oom_reaper(p);
+	if (task_is_reapable(p)) {
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -849,22 +867,18 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
+		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
-		}
+		if (is_global_init(p))
+			continue;
+		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			continue;
+
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
+	wake_oom_reaper(victim);
 
 	mmdrop(mm);
 	put_task_struct(victim);
@@ -936,19 +950,12 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 
 	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
+	 * If current's memory is ready to be OOM-reaped, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		mark_oom_victim(current);
-		try_oom_reaper(current);
+	if (task_is_reapable(current))
 		return true;
-	}
 
 	/*
 	 * The OOM killer does not compensate for IO-less reclaim.
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
