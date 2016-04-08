Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 003056B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 07:19:44 -0400 (EDT)
Received: by mail-oi0-f42.google.com with SMTP id s79so132841738oie.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 04:19:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o79si4457543ota.54.2016.04.08.04.19.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Apr 2016 04:19:42 -0700 (PDT)
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip regular OOM killer path
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
	<1459951996-12875-3-git-send-email-mhocko@kernel.org>
	<201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
In-Reply-To: <201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
Message-Id: <201604082019.EDH52671.OJHQFMStOFLVOF@I-love.SAKURA.ne.jp>
Date: Fri, 8 Apr 2016 20:19:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com, oleg@redhat.com

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > @@ -694,6 +746,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	task_lock(p);
> >  	if (p->mm && task_will_free_mem(p)) {
> >  		mark_oom_victim(p);
> > +		try_oom_reaper(p);
> >  		task_unlock(p);
> >  		put_task_struct(p);
> >  		return;
> > @@ -873,6 +926,7 @@ bool out_of_memory(struct oom_control *oc)
> >  	if (current->mm &&
> >  	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> >  		mark_oom_victim(current);
> > +		try_oom_reaper(current);
> >  		return true;
> >  	}
> >  

oom_reaper() will need to do "tsk->oom_reaper_list = NULL;" due to

	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
		return;

test in wake_oom_reaper() if "[PATCH 3/3] mm, oom_reaper: clear
TIF_MEMDIE for all tasks queued for oom_reaper" will select the same
thread again. Though I think we should not allow the OOM killer to
select the same thread again.

> 
> Why don't you call try_oom_reaper() from the shortcuts in
> mem_cgroup_out_of_memory() as well?

I looked at next-20160408 but I again came to think that we should remove
these shortcuts (something like a patch shown bottom).

These shortcuts might be called without sending SIGKILL to threads sharing
the victim's memory. It is possible that try_oom_reaper() fails to call
wake_oom_reaper() due to a thread without fatal_signal_pending(). If such
thread is holding mmap_sem for write without fatal_signal_pending(),
the victim will get stuck at exit_mm() but wake_oom_reaper() is not called.
Therefore, use of these shortcuts can put us back to square one.

My perspective on the OOM reaper is to behave as a guaranteed unlocking
mechanism than a preemptive memory reaping mechanism. Therefore, it is
critically important that the OOM reaper kernel thread is always woken up
and unlock TIF_MEMDIE some time later, even if it is known that the memory
used by the caller of try_oom_reaper() is not reapable. Therefore, I moved
mm_is_reapable() test to the OOM reaper kernel thread in the patch shown
bottom.

Also, setting TIF_MEMDIE to all threads at oom_kill_process() not only
eliminates the need of "[PATCH 1/3] mm, oom: move GFP_NOFS check to
out_of_memory" but also suppresses needless OOM killer messages by holding
off the OOM killer until "all threads which should release the victim's mm
releases the victim's mm" or "the OOM reaper marks all threads which failed
to release the victim's mm as being stuck".

Setting TIF_MEMDIE to all threads at oom_kill_process() also increases
possibility of reclaiming memory when racing with oom_killer_disable() by
waiting until "all threads which should release the victim's mm releases
the victim's mm" or "oom_killer_disable() gives up waiting for oom_victims
to become 0". It sounds strange to me that we are currently thawing only
victim's thread when we need to thaw all threads sharing the victim's mm
in order to reclaim memory used by the victim. (And more crazy thing is
that we loop forever without providing a guarantee of forward progress at

	/* Exhausted what can be done so it's blamo time */
	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
		*did_some_progress = 1;

		if (gfp_mask & __GFP_NOFAIL) {
			page = get_page_from_freelist(gfp_mask, order,
					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
			/*
			 * fallback to ignore cpuset restriction if our nodes
			 * are depleted
			 */
			if (!page)
				page = get_page_from_freelist(gfp_mask, order,
					ALLOC_NO_WATERMARKS, ac);
		}
	}

but that thing is outside of this discussion.)

----------
 include/linux/oom.h   |    4 -
 include/linux/sched.h |    2
 kernel/exit.c         |    2
 mm/memcontrol.c       |   13 ---
 mm/oom_kill.c         |  200 +++++++++++++++++++-------------------------------
 5 files changed, 83 insertions(+), 138 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index abaab8e..9c99956 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -67,8 +67,6 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
-
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
@@ -86,7 +84,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(struct task_struct *tsk);
+extern void exit_oom_victim(void);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index dd286b1..a93b24d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -786,6 +786,8 @@ struct signal_struct {
 	 * oom
 	 */
 	bool oom_flag_origin;
+	/* Already OOM-killed but cannot terminate. Don't count on me. */
+	bool oom_skip_me;
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
diff --git a/kernel/exit.c b/kernel/exit.c
index 9e6e135..c742c37 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -435,7 +435,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
+		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e90d48..57611b8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1278,17 +1278,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int points = 0;
 	struct task_struct *chosen = NULL;
 
-	mutex_lock(&oom_lock);
-
-	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		goto unlock;
-	}
+	if (mutex_lock_killable(&oom_lock))
+		return NULL;
 
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7098104..7bda655 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -279,6 +279,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * Don't allow any other task to have access to the reserves.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
+		if (task->signal->oom_skip_me)
+			return OOM_SCAN_CONTINUE;
 		if (!is_sysrq_oom(oc))
 			return OOM_SCAN_ABORT;
 	}
@@ -441,6 +443,42 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
+static bool mm_is_reapable(struct mm_struct *mm)
+{
+	struct task_struct *p;
+
+	if (atomic_read(&mm->mm_users) <= 2)
+		return true;
+	/*
+	 * There might be other threads/processes which are either not
+	 * dying or even not killable.
+	 */
+	rcu_read_lock();
+	for_each_process(p) {
+		bool exiting;
+
+		if (!process_shares_mm(p, mm))
+			continue;
+		if (fatal_signal_pending(p))
+			continue;
+
+		/*
+		 * If the task is exiting make sure the whole thread group
+		 * is exiting and cannot access mm anymore.
+		 */
+		spin_lock_irq(&p->sighand->siglock);
+		exiting = signal_group_exit(p->signal);
+		spin_unlock_irq(&p->sighand->siglock);
+		if (exiting)
+			continue;
+
+		/* Give up */
+		rcu_read_unlock();
+		return false;
+	}
+	rcu_read_unlock();
+	return true;
+}
 
 static bool __oom_reap_task(struct task_struct *tsk)
 {
@@ -470,7 +508,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 
 	task_unlock(p);

-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		goto out;
 	}
@@ -509,11 +547,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
 
-	/*
-	 * This task can be safely ignored because we cannot do much more
-	 * to release its memory.
-	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
 out:
 	mmput(mm);
 	return ret;
@@ -535,12 +568,12 @@ static void oom_reap_task(struct task_struct *tsk)
 	}
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
+	 * Tell oom_scan_process_thread() not to wait for this process, for
+	 * the task shouldn't be sitting on a reasonably reclaimable memory
+	 * anymore or it is not a good candidate for the oom victim right now
+	 * because it cannot release its memory itself nor by the oom reaper.
 	 */
-	exit_oom_victim(tsk);
+	tsk->signal->oom_skip_me = true;
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -586,53 +619,6 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	wake_up(&oom_reaper_wait);
 }
 
-/* Check if we can reap the given task. This has to be called with stable
- * tsk->mm
- */
-static void try_oom_reaper(struct task_struct *tsk)
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
-			if (same_thread_group(p, tsk))
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
@@ -645,10 +631,6 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void try_oom_reaper(struct task_struct *tsk)
-{
-}
-
 static void wake_oom_reaper(struct task_struct *tsk)
 {
 }
@@ -661,7 +643,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+static void mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
@@ -680,10 +662,9 @@ void mark_oom_victim(struct task_struct *tsk)
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
-void exit_oom_victim(struct task_struct *tsk)
+void exit_oom_victim(void)
 {
-	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
+	clear_thread_flag(TIF_MEMDIE);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -741,21 +722,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
-
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		try_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
-	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
@@ -804,13 +770,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
-	/*
-	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
-	 * the OOM victim from depleting the memory reserves from the user
-	 * space under its control.
-	 */
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -819,37 +778,47 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_unlock(victim);
 
 	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * Kill all user processes sharing victim->mm in other thread groups,
+	 * if any. This reduces possibility of hitting mm->mmap_sem livelock
+	 * when an oom killed thread cannot exit because it requires the
+	 * semaphore and its contended by another thread trying to allocate
+	 * memory itself.
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
 		if (!process_shares_mm(p, mm))
 			continue;
-		if (same_thread_group(p, victim))
+		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
+		if (is_global_init(p))
 			continue;
-		}
+		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			continue;
+
+		/*
+		 * We should make sure that oom_badness() will treat this
+		 * process as unkillable because wake_oom_reaper() might do
+		 * nothing.
+		 * Note that this will change sysctl_oom_kill_allocating_task
+		 * behavior.
+		 */
+		p->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+		/*
+		 * We should send SIGKILL before setting TIF_MEMDIE in order to
+		 * prevent the OOM victim from depleting the memory reserves
+		 * from the user space under its control.
+		 */
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		for_each_thread(p, t) {
+			task_lock(t);
+			if (t->mm)
+				mark_oom_victim(t);
+			task_unlock(t);
+		}
+		wake_oom_reaper(p);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -920,21 +889,6 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 
 	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
-	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		mark_oom_victim(current);
-		try_oom_reaper(current);
-		return true;
-	}
-
-	/*
 	 * The OOM killer does not compensate for IO-less reclaim.
 	 * pagefault_out_of_memory lost its gfp context so we have to
 	 * make sure exclude 0 mask - all other users should have at least
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
