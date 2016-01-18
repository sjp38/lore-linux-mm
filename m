Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D01826B0005
	for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:36:02 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id cy9so427344237pac.0
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 20:36:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mj8si381237pab.50.2016.01.17.20.36.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 20:36:01 -0800 (PST)
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
	<1452516120-5535-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1452516120-5535-1-git-send-email-mhocko@kernel.org>
Message-Id: <201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
Date: Mon, 18 Jan 2016 13:35:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> When oom_reaper manages to unmap all the eligible vmas there shouldn't
> be much of the freable memory held by the oom victim left anymore so it
> makes sense to clear the TIF_MEMDIE flag for the victim and allow the
> OOM killer to select another task if necessary.
> 
> The lack of TIF_MEMDIE also means that the victim cannot access memory
> reserves anymore but that shouldn't be a problem because it would get
> the access again if it needs to allocate and hits the OOM killer again
> due to the fatal_signal_pending resp. PF_EXITING check. We can safely
> hide the task from the OOM killer because it is clearly not a good
> candidate anymore as everyhing reclaimable has been torn down already.
> 
> This patch will allow to cap the time an OOM victim can keep TIF_MEMDIE
> and thus hold off further global OOM killer actions granted the oom
> reaper is able to take mmap_sem for the associated mm struct. This is
> not guaranteed now but further steps should make sure that mmap_sem
> for write should be blocked killable which will help to reduce such a
> lock contention. This is not done by this patch.
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> this has passed my basic testing but it definitely needs a deeper
> review.  I have tested it by flooding the system by OOM and delaying
> exit_mm for TIF_MEMDIE tasks to win the race for the oom reaper. I made
> sure to delay after the mm was set to NULL to make sure that oom reaper
> sees NULL mm from time to time to exercise this case as well. This
> happened in roughly half instance.
> 
>  include/linux/oom.h |  2 +-
>  kernel/exit.c       |  2 +-
>  mm/oom_kill.c       | 72 ++++++++++++++++++++++++++++++++++-------------------
>  3 files changed, 49 insertions(+), 27 deletions(-)

A patch attached bottom is my suggestion for making sure that we won't be
trapped by OOM livelock when the OOM reaper did not reclaim enough memory for
terminating OOM victim. It also includes several bugfixes which I think current
patch is missing.

I like the OOM reaper approach. But I don't like current patch because current
patch ignores unlikely cases described below. I proposed two simple patches for
handling such corner cases.

  (P1) "[PATCH v2] mm,oom: exclude TIF_MEMDIE processes from candidates."
       http://lkml.kernel.org/r/201601081909.CDJ52685.HLFOFJFOQMVOtS@I-love.SAKURA.ne.jp

  (P2) "[PATCH] mm,oom: Re-enable OOM killer using timers."
       http://lkml.kernel.org/r/201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp
       (oomkiller_holdoff_timer and sysctl_oomkiller_holdoff_ms in this patch
       are not directly related with avoiding OOM livelock.)

If all changes that cover unlikely cases are implemented, P1 and P2 will
become unneeded.

(1) Make the OOM reaper available on CONFIG_MMU=n kernels.

    I don't know about MMU, but I assume we can handle these errors.

    slub.c:(.text+0x4184): undefined reference to `tlb_gather_mmu'
    slub.c:(.text+0x41bc): undefined reference to `unmap_page_range'
    slub.c:(.text+0x41d8): undefined reference to `tlb_finish_mmu'

(2) Do not boot the system if failed to create the OOM reaper thread.

    We are already heavily depending on the OOM reaper.

    pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
                    PTR_ERR(oom_reaper_th));

(3) Eliminate locations that call mark_oom_victim() without
    making the OOM victim task under monitor of the OOM reaper.

    The OOM reaper needs to take actions when the OOM victim task got stuck
    because we (except me) do not want to use my sysctl-controlled timeout-
    based OOM victim selection.

    out_of_memory():
        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                return true;
        }

    oom_kill_process():
        task_lock(p);
        if (p->mm && task_will_free_mem(p)) {
                mark_oom_victim(p);
                task_unlock(p);
                put_task_struct(p);
                return;
        }
        task_unlock(p);

    mem_cgroup_out_of_memory():
        if (fatal_signal_pending(current) || task_will_free_mem(current)) {
                mark_oom_victim(current);
                goto unlock;
        }

    lowmem_scan():
        if (selected->mm)
                mark_oom_victim(selected);

(4) Don't select an OOM victim until mm_to_reap (or task_to_reap) becomes NULL.

    This is needed for making sure that any OOM victim is made under
    monitor of the OOM reaper in order to let the OOM reaper take action
    before leaving oom_reap_vmas() (or oom_reap_task()).

    Since the OOM reaper can do mm_to_reap (or task_to_reap) = NULL shortly
    (e.g. within a second if it retries for 10 times with 0.1 second interval),
    waiting should not become a problem.

(5) Decrease oom_score_adj value after the OOM reaper reclaimed memory.

    If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) succeeded, set oom_score_adj
    value of all tasks sharing the same mm to -1000 (by walking the process list)
    and clear TIF_MEMDIE.

    Changing only the OOM victim's oom_score_adj is not sufficient
    when there are other thread groups sharing the OOM victim's memory
    (i.e. clone(!CLONE_THREAD && CLONE_VM) case).

(6) Decrease oom_score_adj value even if the OOM reaper failed to reclaim memory.

    If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) failed for 10 times, decrease
    oom_score_adj value of all tasks sharing the same mm and clear TIF_MEMDIE.
    This is needed for preventing the OOM killer from selecting the same thread
    group forever.

    An example is, set oom_score_adj to -999 if oom_score_adj is greater than
    -999, set -1000 if oom_score_adj is already -999. This will allow the OOM
    killer try to choose different OOM victims before retrying __oom_reap_vmas(mm)
    (or __oom_reap_task(tsk)) of this OOM victim, then trigger kernel panic if
    all OOM victims got -1000.

    Changing mmap_sem lock killable increases possibility of __oom_reap_vmas(mm)
    (or __oom_reap_task(tsk)) to succeed. But due to the changes in (3) and (4),
    there is no guarantee that TIF_MEMDIE is set to the thread which is looping at
    __alloc_pages_slowpath() with the mmap_sem held for writing. If the OOM killer
    were able to know which thread is looping at __alloc_pages_slowpath() with the
    mmap_sem held for writing (via per task_struct variable), the OOM killer would
    set TIF_MEMDIE on that thread before randomly choosing one thread using
    find_lock_task_mm().

(7) Decrease oom_score_adj value even if the OOM reaper is not allowed to reclaim
    memory.

    This is same with (6) except for cases where the OOM victim's memory is
    used by some OOM-unkillable threads (i.e. can_oom_reap = false case).

    Calling wake_oom_reaper() with can_oom_reap added is the simplest way for
    waiting for short period (e.g. a second) and change oom_score_adj value
    and clear TIF_MEMDIE.

Since kmallocwd-like approach (i.e. walk the process list) will eliminate
the need for doing (3) and (4), I tried it (a patch is shown below). The
changes are larger than I initially thought, for clearing TIF_MEMDIE needs
a switch for avoid re-setting TIF_MEMDIE forever and such switch is
complicated.

  (a) PFA_OOM_NO_RECURSION is a switch for avoid re-setting TIF_MEMDIE forever
      when an OOM victim is chosen without taking ->oom_score_adj into account.

  (b) When an OOM victim is chosen with taking ->oom_score_adj into account,
      it is set to -999 when the OOM reaper was unable to reclaim victim's
      memory. It is set to -1000 when the OOM reaper was unable to reclaim
      victim's memory when it was already -999.

  (c) If ->oom_score_adj was set to -1000 when TIF_MEMDIE was cleared,
      we can consider such task OOM-killable because such task is either
      SIGKILL pending or already exiting. Thus, we should not try to test
      whether a task's memory is reapable at oom_kill_process().

Do we prefer this direction over P1+P2 which do not clear TIF_MEMDIE?
----------------------------------------
Date: Mon, 18 Jan 2016 13:22:51 +0900
Subject: [PATCH 4/2] oom: change OOM reaper to walk the process list

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h |   4 +
 mm/memcontrol.c       |   8 +-
 mm/oom_kill.c         | 250 ++++++++++++++++++++++++++++++++++----------------
 3 files changed, 183 insertions(+), 79 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1ef541c..1a15c584 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2167,6 +2167,7 @@ static inline void memalloc_noio_restore(unsigned int flags)
 #define PFA_NO_NEW_PRIVS 0	/* May not gain new privileges. */
 #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */
 #define PFA_SPREAD_SLAB  2      /* Spread some slab caches over cpuset */
+#define PFA_OOM_NO_RECURSION 3  /* OOM-killing with OOM score ignored */
 
 
 #define TASK_PFA_TEST(name, func)					\
@@ -2190,6 +2191,9 @@ TASK_PFA_TEST(SPREAD_SLAB, spread_slab)
 TASK_PFA_SET(SPREAD_SLAB, spread_slab)
 TASK_PFA_CLEAR(SPREAD_SLAB, spread_slab)
 
+TASK_PFA_TEST(OOM_NO_RECURSION, oom_no_recursion)
+TASK_PFA_SET(OOM_NO_RECURSION, oom_no_recursion)
+
 /*
  * task->jobctl flags
  */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d75028d..134ddf7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1290,8 +1290,14 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
+	 *
+	 * But prepare for situations where failing to OOM-kill current task
+	 * caused unable to choose next OOM victim.
+	 * In that case, do regular OOM victim selection.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    !task_oom_no_recursion(current)) {
+		task_set_oom_no_recursion(current);
 		mark_oom_victim(current);
 		goto unlock;
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6ebc0351..d3a7cd8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -288,9 +288,16 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
+	 *
+	 * But prepare for situations where failing to OOM-kill this task
+	 * after the OOM reaper reaped this task's memory caused unable to
+	 * abort swapoff() or KSM's unmerge operation.
+	 * In that case, do regular OOM victim selection.
 	 */
-	if (oom_task_origin(task))
+	if (oom_task_origin(task) && !task_oom_no_recursion(task)) {
+		task_set_oom_no_recursion(task);
 		return OOM_SCAN_SELECT;
+	}
 
 	return OOM_SCAN_OK;
 }
@@ -416,37 +423,18 @@ bool oom_killer_disabled __read_mostly;
  * victim (if that is possible) to help the OOM killer to move on.
  */
 static struct task_struct *oom_reaper_th;
-static struct task_struct *task_to_reap;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 
-static bool __oom_reap_task(struct task_struct *tsk)
+static bool __oom_reap_vma(struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct mm_struct *mm;
+	struct task_struct *g;
 	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
 
-	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
-	 */
-	p = find_lock_task_mm(tsk);
-	if (!p)
-		return true;
-
-	mm = p->mm;
-	if (!atomic_inc_not_zero(&mm->mm_users)) {
-		task_unlock(p);
-		return true;
-	}
-
-	task_unlock(p);
-
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		goto out;
@@ -478,64 +466,169 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	up_read(&mm->mmap_sem);
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore. OOM killer can continue
-	 * by selecting other victim if unmapping hasn't led to any
-	 * improvements. This also means that selecting this task doesn't
-	 * make any sense.
+	 * If we successfully reaped a mm, mark all tasks using it as
+	 * OOM-unkillable and clear TIF_MEMDIE. This will help future
+	 * select_bad_process() try to select other OOM-killable tasks.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
-	exit_oom_victim(tsk);
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (mm != p->mm)
+			continue;
+		p->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+		exit_oom_victim(p);
+	}
+	rcu_read_unlock();
 out:
-	mmput(mm);
 	return ret;
 }
 
-static void oom_reap_task(struct task_struct *tsk)
+#define MAX_PIDS_TO_CHECK_LEN 16
+static struct pid *pids_to_check[MAX_PIDS_TO_CHECK_LEN];
+static int pids_to_check_len;
+
+static int gather_pids_to_check(void)
 {
-	int attempts = 0;
+	struct task_struct *g;
+	struct task_struct *p;
 
-	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < 10 && !__oom_reap_task(tsk))
-		schedule_timeout_idle(HZ/10);
+	if (!atomic_read(&oom_victims))
+		return 0;
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (!test_tsk_thread_flag(p, TIF_MEMDIE))
+			continue;
+		/*
+		 * Remember "struct pid" of TIF_MEMDIE tasks rather than
+		 * "struct task_struct". This will avoid needlessly deferring
+		 * final __put_task_struct() call when such tasks become
+		 * ready to terminate.
+		 */
+		pids_to_check[pids_to_check_len++] =
+			get_task_pid(p, PIDTYPE_PID);
+		if (pids_to_check_len == MAX_PIDS_TO_CHECK_LEN)
+			goto done;
+	}
+done:
+	rcu_read_unlock();
+	return pids_to_check_len;
+}
 
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
+static int reap_pids_to_check(void)
+{
+	int i;
+	int j;
+	struct pid *pid;
+	struct task_struct *g;
+	struct task_struct *p;
+	struct mm_struct *mm;
+	bool success;
+
+	for (i = 0; i < pids_to_check_len; i++) {
+		pid = pids_to_check[i];
+		rcu_read_lock();
+		p = pid_task(pid, PIDTYPE_PID);
+		mm = p ? READ_ONCE(p->mm) : NULL;
+		if (!mm) {
+			rcu_read_unlock();
+			goto done;
+		}
+		/*
+		 * Since it is possible that p voluntarily called do_exit() or
+		 * somebody other than the OOM killer sent SIGKILL on p, a mm
+		 * used by p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN is
+		 * reapable if p has pending SIGKILL or already reached
+		 * do_exit().
+		 *
+		 * On the other hand, it is possible that mark_oom_victim(p) is
+		 * called without sending SIGKILL to all OOM-killable tasks
+		 * using a mm used by p. In that case, the OOM reaper cannot
+		 * reap that mm unless p is the only task using that mm.
+		 *
+		 * Therefore, determine whether a mm is reapable by testing
+		 * whether all tasks using that mm are dying or already exiting
+		 * rather than depending on p->signal->oom_score_adj value
+		 * which is updated by the OOM reaper.
+		 */
+		for_each_process_thread(g, p) {
+			if (mm != READ_ONCE(p->mm) ||
+			    fatal_signal_pending(p) || (p->flags & PF_EXITING))
+				continue;
+			mm = NULL;
+			goto skip;
+		}
+		if (!atomic_inc_not_zero(&mm->mm_users))
+			mm = NULL;
+skip:
+		rcu_read_unlock();
+		if (!mm)
+			continue;
+		success = __oom_reap_vma(mm);
+		mmput(mm);
+		if (success) {
+done:
+			put_pid(pid);
+			pids_to_check_len--;
+			for (j = i; j < pids_to_check_len; j++)
+				pids_to_check[j] = pids_to_check[j + 1];
+			i--;
+		}
+	}
+	return pids_to_check_len;
+}
+
+static void release_pids_to_check(void)
+{
+	int i;
+	struct pid *pid;
+	struct task_struct *p;
+	short score;
+
+	for (i = 0; i < pids_to_check_len; i++) {
+		pid = pids_to_check[i];
+		/*
+		 * If we failed to reap a mm, mark that task using it as almost
+		 * OOM-unkillable and clear TIF_MEMDIE. This will help future
+		 * select_bad_process() try to select other OOM-killable tasks
+		 * before selecting that task again.
+		 *
+		 * But if that task got TIF_MEMDIE when that task is already
+		 * marked as almost OOM-unkillable, mark that task completely
+		 * OOM-unkillable. Otherwise, we cannot make progress when all
+		 * OOM-killable tasks became almost OOM-unkillable.
+		 */
+		rcu_read_lock();
+		p = pid_task(pid, PIDTYPE_PID);
+		if (p) {
+			score = p->signal->oom_score_adj;
+			p->signal->oom_score_adj =
+				score > OOM_SCORE_ADJ_MIN + 1 ?
+				OOM_SCORE_ADJ_MIN + 1 : OOM_SCORE_ADJ_MIN;
+			exit_oom_victim(p);
+		}
+		rcu_read_unlock();
+		put_pid(pid);
+	}
+	pids_to_check_len = 0;
 }
 
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk;
+		int i;
 
-		wait_event_freezable(oom_reaper_wait,
-				     (tsk = READ_ONCE(task_to_reap)));
-		oom_reap_task(tsk);
-		WRITE_ONCE(task_to_reap, NULL);
+		wait_event_freezable(oom_reaper_wait, gather_pids_to_check());
+		for (i = 0; reap_pids_to_check() && i < 10; i++)
+			schedule_timeout_idle(HZ / 10);
+		release_pids_to_check();
 	}
 
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
+static void wake_oom_reaper(void)
 {
-	struct task_struct *old_tsk;
-
-	if (!oom_reaper_th)
-		return;
-
-	get_task_struct(tsk);
-
-	/*
-	 * Make sure that only a single mm is ever queued for the reaper
-	 * because multiple are not necessary and the operation might be
-	 * disruptive so better reduce it to the bare minimum.
-	 */
-	old_tsk = cmpxchg(&task_to_reap, NULL, tsk);
-	if (!old_tsk)
+	if (oom_reaper_th)
 		wake_up(&oom_reaper_wait);
-	else
-		put_task_struct(tsk);
 }
 
 static int __init oom_init(void)
@@ -558,7 +651,7 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void wake_oom_reaper(struct task_struct *mm)
+static void wake_oom_reaper(void)
 {
 }
 #endif
@@ -584,6 +677,7 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+	wake_oom_reaper();
 }
 
 /**
@@ -591,9 +685,8 @@ void mark_oom_victim(struct task_struct *tsk)
  */
 void exit_oom_victim(struct task_struct *tsk)
 {
-	clear_tsk_thread_flag(tsk, TIF_MEMDIE);
-
-	if (!atomic_dec_return(&oom_victims))
+	if (test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE) &&
+	    !atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 }
 
@@ -672,7 +765,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -740,7 +832,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -766,23 +857,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		if (is_global_init(p))
 			continue;
 		if (unlikely(p->flags & PF_KTHREAD) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
-		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
+	mark_oom_victim(victim);
 	put_task_struct(victim);
 }
 #undef K
@@ -858,9 +940,14 @@ bool out_of_memory(struct oom_control *oc)
 	 *
 	 * But don't select if current has already released its mm and cleared
 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
+	 *
+	 * Also, prepare for situations where failing to OOM-kill current task
+	 * caused unable to choose next OOM victim.
+	 * In that case, do regular OOM victim selection.
 	 */
-	if (current->mm &&
+	if (current->mm && !task_oom_no_recursion(current) &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
+		task_set_oom_no_recursion(current);
 		mark_oom_victim(current);
 		return true;
 	}
@@ -876,7 +963,14 @@ bool out_of_memory(struct oom_control *oc)
 
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN &&
+	    !task_oom_no_recursion(current)) {
+		/*
+		 * But prepare for situations where failing to OOM-kill current
+		 * task caused unable to choose next OOM victim.
+		 * In that case, do regular OOM victim selection.
+		 */
+		task_set_oom_no_recursion(current);
 		get_task_struct(current);
 		oom_kill_process(oc, current, 0, totalpages, NULL,
 				 "Out of memory (oom_kill_allocating_task)");
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
