Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9A86B026C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:26:22 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o24-v6so1679068iob.20
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:26:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p10-v6si829372iob.40.2018.07.03.07.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:26:20 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/8] mm,oom: Fix unnecessary killing of additional processes.
Date: Tue,  3 Jul 2018 23:25:04 +0900
Message-Id: <1530627910-3415-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

David Rientjes is complaining that memcg OOM events needlessly select
more OOM victims when the OOM reaper was unable to reclaim memory. This
is because exit_mmap() is setting MMF_OOM_SKIP before calling
free_pgtables(). While David is trying to introduce timeout based hold
off approach, Michal Hocko is rejecting plain timeout based approaches.

Therefore, this patch gets rid of the OOM reaper kernel thread and
introduces OOM-badness-score based hold off approach. The reason for
getting rid of the OOM reaper kernel thread is explained below.

    We are about to start getting a lot of OOM victim processes by
    introducing "mm, oom: cgroup-aware OOM killer" patchset.

    When there are multiple OOM victims, we should try reclaiming memory
    in parallel rather than sequentially wait until conditions to be able
    to reclaim memory are met. Also, we should preferentially reclaim from
    OOM domains where currently allocating threads belong to. Also, we
    want to get rid of schedule_timeout_*(1) heuristic which is used for
    trying to give CPU resource to the owner of oom_lock. Therefire,
    direct OOM reaping by allocating threads can do the job better than
    the OOM reaper kernel thread.

This patch changes the OOM killer to wait until either __mmput()
completes or OOM badness score did not decrease for 3 seconds.
This patch changes the meaning of MMF_OOM_SKIP changes from "start
selecting next OOM victim" to "stop calling oom_reap_mm() from direct
OOM reaping". In order to allow direct OOM reaping, counter variables
which remember "the current OOM badness score", "when OOM badness score
was compared for the last time", "how many times OOM badness score did
not decrease" are added to "struct task_struct".

Note that four tracepoints which are used for recording the OOM reaper is
removed because the OOM reaper kernel thread is removed and concurrently
executed direct OOM reaping can generate too many trace logs.

As a side note, the potential regression for CONFIG_MMU=n kernels is
fixed by doing the same things except oom_reap_mm(), for there is now
no difference between CONFIG_MMU=y kernels and CONFIG_MMU=n kernels
except that CONFIG_MMU=n kernels cannot implement oom_reap_mm(). But
CONFIG_MMU=n kernels can save memory for one kernel thread.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/oom.h        |   3 +-
 include/linux/sched.h      |   5 +-
 include/trace/events/oom.h |  64 ----------
 kernel/fork.c              |   2 +
 mm/mmap.c                  |  17 +--
 mm/oom_kill.c              | 299 ++++++++++++++++-----------------------------
 6 files changed, 116 insertions(+), 274 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 6adac11..eab409f 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -95,7 +95,7 @@ static inline int check_stable_address_space(struct mm_struct *mm)
 	return 0;
 }
 
-void __oom_reap_task_mm(struct mm_struct *mm);
+extern void oom_reap_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
@@ -104,6 +104,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(void);
+extern void exit_oom_mm(struct mm_struct *mm);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d56ae68..dc47976 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1162,9 +1162,10 @@ struct task_struct {
 	unsigned long			task_state_change;
 #endif
 	int				pagefault_disabled;
-#ifdef CONFIG_MMU
 	struct list_head		oom_victim_list;
-#endif
+	unsigned long			last_oom_compared;
+	unsigned long			last_oom_score;
+	unsigned char			oom_reap_stall_count;
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
index 26a11e4..5228fc2 100644
--- a/include/trace/events/oom.h
+++ b/include/trace/events/oom.h
@@ -87,70 +87,6 @@
 	TP_printk("pid=%d", __entry->pid)
 );
 
-TRACE_EVENT(wake_reaper,
-	TP_PROTO(int pid),
-
-	TP_ARGS(pid),
-
-	TP_STRUCT__entry(
-		__field(int, pid)
-	),
-
-	TP_fast_assign(
-		__entry->pid = pid;
-	),
-
-	TP_printk("pid=%d", __entry->pid)
-);
-
-TRACE_EVENT(start_task_reaping,
-	TP_PROTO(int pid),
-
-	TP_ARGS(pid),
-
-	TP_STRUCT__entry(
-		__field(int, pid)
-	),
-
-	TP_fast_assign(
-		__entry->pid = pid;
-	),
-
-	TP_printk("pid=%d", __entry->pid)
-);
-
-TRACE_EVENT(finish_task_reaping,
-	TP_PROTO(int pid),
-
-	TP_ARGS(pid),
-
-	TP_STRUCT__entry(
-		__field(int, pid)
-	),
-
-	TP_fast_assign(
-		__entry->pid = pid;
-	),
-
-	TP_printk("pid=%d", __entry->pid)
-);
-
-TRACE_EVENT(skip_task_reaping,
-	TP_PROTO(int pid),
-
-	TP_ARGS(pid),
-
-	TP_STRUCT__entry(
-		__field(int, pid)
-	),
-
-	TP_fast_assign(
-		__entry->pid = pid;
-	),
-
-	TP_printk("pid=%d", __entry->pid)
-);
-
 #ifdef CONFIG_COMPACTION
 TRACE_EVENT(compact_retry,
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 9440d61..63a0bc6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -977,6 +977,8 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (unlikely(mm_is_oom_victim(mm)))
+		exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index d1eb87e..a12e6bf 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3059,24 +3059,19 @@ void exit_mmap(struct mm_struct *mm)
 	if (unlikely(mm_is_oom_victim(mm))) {
 		/*
 		 * Manually reap the mm to free as much memory as possible.
-		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
-		 * this mm from further consideration.  Taking mm->mmap_sem for
-		 * write after setting MMF_OOM_SKIP will guarantee that the oom
-		 * reaper will not run on this mm again after mmap_sem is
-		 * dropped.
+		 * Then, tell oom_has_pending_victims() to stop calling
+		 * oom_reap_mm(), by taking mm->mmap_sem for write after
+		 * setting MMF_OOM_SKIP.
 		 *
 		 * Nothing can be holding mm->mmap_sem here and the above call
 		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
-		 * __oom_reap_task_mm() will not block.
+		 * oom_reap_mm() will not block.
 		 *
 		 * This needs to be done before calling munlock_vma_pages_all(),
-		 * which clears VM_LOCKED, otherwise the oom reaper cannot
+		 * which clears VM_LOCKED, otherwise oom_reap_mm() cannot
 		 * reliably test it.
 		 */
-		mutex_lock(&oom_lock);
-		__oom_reap_task_mm(mm);
-		mutex_unlock(&oom_lock);
-
+		oom_reap_mm(mm);
 		set_bit(MMF_OOM_SKIP, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f58281e..1a9fae4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -49,6 +49,12 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
 
+static inline unsigned long oom_victim_mm_score(struct mm_struct *mm)
+{
+	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
+		mm_pgtables_bytes(mm) / PAGE_SIZE;
+}
+
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
@@ -198,6 +204,9 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	long points;
 	long adj;
 
+	if (tsk_is_oom_victim(p))
+		return 0;
+
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
 
@@ -207,13 +216,10 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 
 	/*
 	 * Do not even consider tasks which are explicitly marked oom
-	 * unkillable or have been already oom reaped or the are in
-	 * the middle of vfork
+	 * unkillable or are in the middle of vfork
 	 */
 	adj = (long)p->signal->oom_score_adj;
-	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_SKIP, &p->mm->flags) ||
-			in_vfork(p)) {
+	if (adj == OOM_SCORE_ADJ_MIN || in_vfork(p)) {
 		task_unlock(p);
 		return 0;
 	}
@@ -222,8 +228,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_victim_mm_score(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -431,6 +436,29 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
+static bool victim_mm_stalling(struct task_struct *p, struct mm_struct *mm)
+{
+	unsigned long score;
+
+	if (time_before(jiffies, p->last_oom_compared + HZ / 10))
+		return false;
+	score = oom_victim_mm_score(mm);
+	if (score < p->last_oom_score)
+		p->oom_reap_stall_count = 0;
+	else
+		p->oom_reap_stall_count++;
+	p->last_oom_score = oom_victim_mm_score(mm);
+	p->last_oom_compared = jiffies;
+	if (p->oom_reap_stall_count < 30)
+		return false;
+	pr_info("Gave up waiting for process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		task_pid_nr(p), p->comm, K(mm->total_vm),
+		K(get_mm_counter(mm, MM_ANONPAGES)),
+		K(get_mm_counter(mm, MM_FILEPAGES)),
+		K(get_mm_counter(mm, MM_SHMEMPAGES)));
+	return true;
+}
+
 /*
  * task->mm can be NULL if the task is the exited group leader.  So to
  * determine whether the task is using a particular mm, we examine all the
@@ -449,32 +477,10 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
-#ifdef CONFIG_MMU
-/*
- * OOM Reaper kernel thread which tries to reap the memory used by the OOM
- * victim (if that is possible) to help the OOM killer to move on.
- */
-static struct task_struct *oom_reaper_th;
-static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static LIST_HEAD(oom_victim_list);
-static DEFINE_SPINLOCK(oom_reaper_lock);
 
-/*
- * We have to make sure not to cause premature new oom victim selection.
- *
- * __alloc_pages_may_oom()     oom_reap_task_mm()/exit_mmap()
- *   mutex_trylock(&oom_lock)
- *   get_page_from_freelist(ALLOC_WMARK_HIGH) # fails
- *                               unmap_page_range() # frees some memory
- *                               set_bit(MMF_OOM_SKIP)
- *   out_of_memory()
- *     oom_has_pending_victims()
- *       test_bit(MMF_OOM_SKIP) # selects new oom victim
- *   mutex_unlock(&oom_lock)
- *
- * Therefore, the callers hold oom_lock when calling this function.
- */
-void __oom_reap_task_mm(struct mm_struct *mm)
+#ifdef CONFIG_MMU
+void oom_reap_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 
@@ -513,137 +519,7 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 		}
 	}
 }
-
-static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
-{
-	bool ret = true;
-
-	mutex_lock(&oom_lock);
-
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
-	}
-
-	/*
-	 * If the mm has invalidate_{start,end}() notifiers that could block,
-	 * sleep to give the oom victim some more time.
-	 * TODO: we really want to get rid of this ugly hack and make sure that
-	 * notifiers cannot block for unbounded amount of time
-	 */
-	if (mm_has_blockable_invalidate_notifiers(mm)) {
-		up_read(&mm->mmap_sem);
-		schedule_timeout_idle(HZ);
-		goto unlock_oom;
-	}
-
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
-	trace_start_task_reaping(tsk->pid);
-
-	__oom_reap_task_mm(mm);
-
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-			task_pid_nr(tsk), tsk->comm,
-			K(get_mm_counter(mm, MM_ANONPAGES)),
-			K(get_mm_counter(mm, MM_FILEPAGES)),
-			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-	up_read(&mm->mmap_sem);
-
-	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
-}
-
-#define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
-{
-	int attempts = 0;
-	struct mm_struct *mm = tsk->signal->oom_mm;
-
-	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
-		schedule_timeout_idle(HZ/10);
-
-	if (attempts <= MAX_OOM_REAP_RETRIES ||
-	    test_bit(MMF_OOM_SKIP, &mm->flags))
-		goto done;
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
-done:
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-
-	spin_lock(&oom_reaper_lock);
-	list_del(&tsk->oom_victim_list);
-	spin_unlock(&oom_reaper_lock);
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
-}
-
-static int oom_reaper(void *unused)
-{
-	while (true) {
-		struct task_struct *tsk = NULL;
-
-		wait_event_freezable(oom_reaper_wait,
-				     !list_empty(&oom_victim_list));
-		spin_lock(&oom_reaper_lock);
-		if (!list_empty(&oom_victim_list))
-			tsk = list_first_entry(&oom_victim_list,
-					       struct task_struct,
-					       oom_victim_list);
-		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
-	}
-
-	return 0;
-}
-
-static void wake_oom_reaper(struct task_struct *tsk)
-{
-	if (tsk->oom_victim_list.next)
-		return;
-	get_task_struct(tsk);
-	spin_lock(&oom_reaper_lock);
-	list_add_tail(&tsk->oom_victim_list, &oom_victim_list);
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
-}
-#endif /* CONFIG_MMU */
+#endif
 
 /**
  * mark_oom_victim - mark the given task as OOM victim
@@ -668,6 +544,13 @@ static void mark_oom_victim(struct task_struct *tsk)
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
 		set_bit(MMF_OOM_VICTIM, &mm->flags);
+		/* Save current values for victim_mm_stalling() test. */
+		tsk->oom_reap_stall_count = 0;
+		tsk->last_oom_score = oom_victim_mm_score(mm);
+		tsk->last_oom_compared = jiffies;
+		get_task_struct(tsk);
+		lockdep_assert_held(&oom_lock);
+		list_add_tail(&tsk->oom_victim_list, &oom_victim_list);
 	}
 
 	/*
@@ -786,10 +669,11 @@ static bool task_will_free_mem(struct task_struct *task)
 		return false;
 
 	/*
-	 * This task has already been drained by the oom reaper so there are
-	 * only small chances it will free some more
+	 * If memory reserves granted to this task was not sufficient, allow
+	 * killing more processes after oom_has_pending_victims() completed
+	 * reaping this mm.
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+	if (tsk_is_oom_victim(task))
 		return false;
 
 	if (atomic_read(&mm->mm_users) <= 1)
@@ -826,7 +710,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -836,7 +719,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -925,8 +807,11 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		if (same_thread_group(p, victim))
 			continue;
 		if (is_global_init(p)) {
-			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
+			/*
+			 * Since oom_lock is held, unlike exit_mmap(), there is
+			 * no need to take mm->mmap_sem for write here.
+			 */
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
@@ -942,9 +827,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -989,32 +871,59 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+void exit_oom_mm(struct mm_struct *mm)
+{
+	struct task_struct *p, *tmp;
+
+	mutex_lock(&oom_lock);
+	list_for_each_entry_safe(p, tmp, &oom_victim_list, oom_victim_list) {
+		if (mm != p->signal->oom_mm)
+			continue;
+		list_del(&p->oom_victim_list);
+		/* Drop a reference taken by mark_oom_victim(). */
+		put_task_struct(p);
+	}
+	mutex_unlock(&oom_lock);
+}
+
 static bool oom_has_pending_victims(struct oom_control *oc)
 {
-#ifdef CONFIG_MMU
-	struct task_struct *p;
+	struct task_struct *p, *tmp;
+	bool ret = false;
+	bool gaveup = false;
 
-	if (is_sysrq_oom(oc))
-		return false;
-	/*
-	 * Since oom_reap_task_mm()/exit_mmap() will set MMF_OOM_SKIP, let's
-	 * wait for pending victims until MMF_OOM_SKIP is set.
-	 */
-	spin_lock(&oom_reaper_lock);
-	list_for_each_entry(p, &oom_victim_list, oom_victim_list)
-		if (!oom_unkillable_task(p, oc->memcg, oc->nodemask) &&
-		    !test_bit(MMF_OOM_SKIP, &p->signal->oom_mm->flags))
-			break;
-	spin_unlock(&oom_reaper_lock);
-	return p != NULL;
-#else
-	/*
-	 * Since nobody except oom_kill_process() sets MMF_OOM_SKIP, waiting
-	 * for pending victims until MMF_OOM_SKIP is set is useless. Therefore,
-	 * simply let the OOM killer select pending victims again.
-	 */
-	return false;
+	lockdep_assert_held(&oom_lock);
+	list_for_each_entry_safe(p, tmp, &oom_victim_list, oom_victim_list) {
+		struct mm_struct *mm = p->signal->oom_mm;
+
+		/* Skip OOM victims which current thread cannot select. */
+		if (oom_unkillable_task(p, oc->memcg, oc->nodemask))
+			continue;
+		ret = true;
+#ifdef CONFIG_MMU
+		/*
+		 * We need to hold mmap_sem for read, in order to safely test
+		 * MMF_UNSTABLE flag and blockable invalidate notifiers.
+		 */
+		if (down_read_trylock(&mm->mmap_sem)) {
+			if (!test_bit(MMF_OOM_SKIP, &mm->flags) &&
+			    !mm_has_blockable_invalidate_notifiers(mm))
+				oom_reap_mm(mm);
+			up_read(&mm->mmap_sem);
+		}
 #endif
+		/* Forget if this mm didn't complete __mmput() for too long. */
+		if (!victim_mm_stalling(p, mm))
+			continue;
+		gaveup = true;
+		list_del(&p->oom_victim_list);
+		/* Drop a reference taken by mark_oom_victim(). */
+		put_task_struct(p);
+	}
+	if (gaveup)
+		debug_show_all_locks();
+
+	return ret && !is_sysrq_oom(oc);
 }
 
 /**
@@ -1048,7 +957,6 @@ bool out_of_memory(struct oom_control *oc)
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		wake_oom_reaper(current);
 		return true;
 	}
 
@@ -1074,8 +982,7 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+	    oom_badness(current, NULL, oc->nodemask, oc->totalpages) > 0) {
 		get_task_struct(current);
 		oc->chosen = current;
 		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
-- 
1.8.3.1
