Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 919946B026D
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 07:39:33 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w1so2463994pgq.21
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 04:39:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x4si1799159pgv.629.2017.12.06.04.39.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 04:39:26 -0800 (PST)
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1712051857450.98120@chino.kir.corp.google.com>
	<201712060328.vB63SrDK069830@www262.sakura.ne.jp>
	<alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
Message-Id: <201712062037.DAF90168.SVFQOJFMOOtHLF@I-love.SAKURA.ne.jp>
Date: Wed, 6 Dec 2017 20:37:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes wrote:
> On Wed, 6 Dec 2017, Tetsuo Handa wrote:
> > Also, I don't know what exit_mmap() is doing but I think that there is a
> > possibility that the OOM reaper tries to reclaim mlocked pages as soon as
> > exit_mmap() cleared VM_LOCKED flag by calling munlock_vma_pages_all().
> > 
> > 	if (mm->locked_vm) {
> > 		vma = mm->mmap;
> > 		while (vma) {
> > 			if (vma->vm_flags & VM_LOCKED)
> > 				munlock_vma_pages_all(vma);
> > 			vma = vma->vm_next;
> > 		}
> > 	}
> > 
> 
> Yes, that looks possible as well, although the problem I have reported can 
> happen with or without mlock.  Did you find this by code inspection or 
> have you experienced runtime problems with it?

By code inspection.

> 
> I think this argues to do MMF_REAPING-style behavior at the beginning of 
> exit_mmap() and avoid reaping all together once we have reached that 
> point.  There are no more users of the mm and we are in the process of 
> tearing it down, I'm not sure that the oom reaper should be in the 
> business with trying to interfere with that.  Or are there actual bug 
> reports where an oom victim gets wedged while in exit_mmap() prior to 
> releasing its memory?

If our assumption is that the OOM reaper can reclaim majority of OOM
victim's memory via victim's ->signal->oom_mm, what will be wrong with
simply reverting 212925802454672e ("mm: oom: let oom_reap_task and
exit_mmap run concurrently") and replace mmgrab()/mmdrop_async() with
mmget()/mmput_async() so that the OOM reaper no longer need to worry
about tricky __mmput() behavior (like shown below) ?

----------
 kernel/fork.c |   17 ++++++++++++-----
 mm/mmap.c     |   17 -----------------
 mm/oom_kill.c |   21 +++++++--------------
 3 files changed, 19 insertions(+), 36 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 432eadf..018a857 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -394,12 +394,18 @@ static inline void free_signal_struct(struct signal_struct *sig)
 {
 	taskstats_tgid_free(sig);
 	sched_autogroup_exit(sig);
-	/*
-	 * __mmdrop is not safe to call from softirq context on x86 due to
-	 * pgd_dtor so postpone it to the async context
-	 */
-	if (sig->oom_mm)
+	if (sig->oom_mm) {
+#ifdef CONFIG_MMU
+		mmput_async(sig->oom_mm);
+#else
+		/*
+		 * There might be archtectures where calling __mmdrop() from
+		 * softirq context is not safe. Thus, postpone it to the async
+		 * context.
+		 */
 		mmdrop_async(sig->oom_mm);
+#endif
+	}
 	kmem_cache_free(signal_cachep, sig);
 }
 
@@ -931,6 +937,7 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 	mmdrop(mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index a4d5468..fafaf06 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3019,23 +3019,6 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-	if (unlikely(tsk_is_oom_victim(current))) {
-		/*
-		 * Wait for oom_reap_task() to stop working on this
-		 * mm. Because MMF_OOM_SKIP is already set before
-		 * calling down_read(), oom_reap_task() will not run
-		 * on this "mm" post up_write().
-		 *
-		 * tsk_is_oom_victim() cannot be set from under us
-		 * either because current->mm is already set to NULL
-		 * under task_lock before calling mmput and oom_mm is
-		 * set not NULL by the OOM killer only if current->mm
-		 * is found not NULL while holding the task_lock.
-		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
-	}
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c957be3..eb2a005 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -528,18 +528,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		goto unlock_oom;
 	}
 
-	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
-	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
-		up_read(&mm->mmap_sem);
-		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
-	}
-
 	trace_start_task_reaping(tsk->pid);
 
 	/*
@@ -683,8 +671,13 @@ static void mark_oom_victim(struct task_struct *tsk)
 		return;
 
 	/* oom_mm is bound to the signal struct life time. */
-	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
-		mmgrab(tsk->signal->oom_mm);
+	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
+#ifdef CONFIG_MMU
+		mmget(mm);
+#else
+		mmgrab(mm);
+#endif
+	}
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
----------

If holding the address space when there are so many victim's mm waiting for
the OOM reaper to reclaim is considered dangerous, I think we can try direct
OOM reaping (like untested patch shown below) in order to reclaim first-blocked
first-reaped basis (and also serve as a mitigation for race caused by removing
oom_lock from the OOM reaper).

----------
 include/linux/mm_types.h |   3 ++
 include/linux/sched.h    |   3 --
 mm/oom_kill.c            | 132 ++++++++++++++---------------------------------
 3 files changed, 43 insertions(+), 95 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4..068119b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -501,6 +501,9 @@ struct mm_struct {
 	atomic_long_t hugetlb_usage;
 #endif
 	struct work_struct async_put_work;
+#ifdef CONFIG_MMU
+	unsigned long oom_reap_started;
+#endif
 
 #if IS_ENABLED(CONFIG_HMM)
 	/* HMM needs to track a few things per mm */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a2709d2..d63b599 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1081,9 +1081,6 @@ struct task_struct {
 	unsigned long			task_state_change;
 #endif
 	int				pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
-#endif
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3b0d0fe..a9f8bae 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -309,9 +309,14 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
+#ifdef CONFIG_MMU
+static void oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm);
+#endif
+
 static int oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
+	struct mm_struct *mm;
 	unsigned long points;
 
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
@@ -324,7 +329,8 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
+		mm = task->signal->oom_mm;
+		if (test_bit(MMF_OOM_SKIP, &mm->flags))
 			goto next;
 		goto abort;
 	}
@@ -357,6 +363,15 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	if (oc->chosen)
 		put_task_struct(oc->chosen);
 	oc->chosen = (void *)-1UL;
+#ifdef CONFIG_MMU
+	get_task_struct(task);
+	if (!is_memcg_oom(oc))
+		rcu_read_unlock();
+	oom_reap_task_mm(task, mm);
+	put_task_struct(task);
+	if (!is_memcg_oom(oc))
+		rcu_read_lock();
+#endif
 	return 1;
 }
 
@@ -474,23 +489,14 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
-
 #ifdef CONFIG_MMU
-/*
- * OOM Reaper kernel thread which tries to reap the memory used by the OOM
- * victim (if that is possible) to help the OOM killer to move on.
- */
-static struct task_struct *oom_reaper_th;
-static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
-
 static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	bool ret = true;
 
+	trace_wake_reaper(tsk->pid);
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		trace_skip_task_reaping(tsk->pid);
@@ -507,8 +513,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * mmu_notifier_invalidate_range_{start,end} around unmap_page_range
 	 */
 	if (mm_has_notifiers(mm)) {
+		ret = false;
 		up_read(&mm->mmap_sem);
-		schedule_timeout_idle(HZ);
 		goto unlock_oom;
 	}
 
@@ -567,82 +573,22 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	return ret;
 }
 
-#define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
-{
-	int attempts = 0;
-	struct mm_struct *mm = tsk->signal->oom_mm;
-
-	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
-		schedule_timeout_idle(HZ/10);
-
-	if (attempts <= MAX_OOM_REAP_RETRIES)
-		goto done;
-
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
-done:
-	tsk->oom_reaper_list = NULL;
-
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
-}
-
-static int oom_reaper(void *unused)
+static void oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
-	while (true) {
-		struct task_struct *tsk = NULL;
-
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
+	if (__oom_reap_task_mm(tsk, mm))
+		/* Hide this mm from OOM killer because we reaped it. */
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+	else if (!mm->oom_reap_started)
+		mm->oom_reap_started = jiffies;
+	else if (time_after(jiffies, mm->oom_reap_started + HZ)) {
+		if (!mm_has_notifiers(mm)) {
+			pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+				task_pid_nr(tsk), tsk->comm);
+			debug_show_all_locks();
 		}
-		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
+		/* Hide this mm from OOM killer because we can't reap. */
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 	}
-
-	return 0;
-}
-
-static void wake_oom_reaper(struct task_struct *tsk)
-{
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
-		return;
-
-	get_task_struct(tsk);
-
-	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
-	spin_unlock(&oom_reaper_lock);
-	trace_wake_reaper(tsk->pid);
-	wake_up(&oom_reaper_wait);
-}
-
-static int __init oom_init(void)
-{
-	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
-	return 0;
-}
-subsys_initcall(oom_init)
-#else
-static inline void wake_oom_reaper(struct task_struct *tsk)
-{
 }
 #endif /* CONFIG_MMU */
 
@@ -825,7 +771,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -835,7 +780,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -924,7 +868,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		if (same_thread_group(p, victim))
 			continue;
 		if (is_global_init(p)) {
-			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
@@ -941,9 +884,15 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
+#ifdef CONFIG_MMU
+	/*
+	 * sysctl_oom_kill_allocating_task case could get stuck because
+	 * select_bad_process() which calls oom_reap_task_mm() is not called.
+	 */
+	if (sysctl_oom_kill_allocating_task &&
+	    !test_bit(MMF_OOM_SKIP, &mm->flags))
+		oom_reap_task_mm(victim, mm);
+#endif
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -1019,7 +968,6 @@ bool out_of_memory(struct oom_control *oc)
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		wake_oom_reaper(current);
 		return true;
 	}
 
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
