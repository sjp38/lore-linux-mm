Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9514F6B0003
	for <linux-mm@kvack.org>; Sat, 23 Jun 2018 23:18:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l2-v6so5256400pff.3
        for <linux-mm@kvack.org>; Sat, 23 Jun 2018 20:18:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 97-v6si11420454pld.345.2018.06.23.20.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Jun 2018 20:18:28 -0700 (PDT)
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <3b31694e-a556-f092-132b-9e4ba3d0afef@i-love.sakura.ne.jp>
Date: Sun, 24 Jun 2018 11:36:24 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/06/15 5:42, David Rientjes wrote:
>  Note: I understand there is an objection based on timeout based delays.
>  This is currently the only possible way to avoid oom killing important
>  processes completely unnecessarily.  If the oom reaper can someday free
>  all memory, including mlocked memory and those mm's with blockable mmu
>  notifiers, and is guaranteed to always be able to grab mm->mmap_sem,
>  this can be removed.  I do not believe any such guarantee is possible
>  and consider the massive killing of additional processes unnecessarily
>  to be a regression introduced by the oom reaper and its very quick
>  setting of MMF_OOM_SKIP to allow additional processes to be oom killed.
> 

Here is my version for your proposal including my anti-lockup series.
My version is using OOM badness score as a feedback for deciding when to give up.

---
 drivers/tty/sysrq.c            |   2 -
 include/linux/memcontrol.h     |   9 +-
 include/linux/oom.h            |   7 +-
 include/linux/sched.h          |   7 +-
 include/linux/sched/coredump.h |   1 -
 kernel/fork.c                  |   2 +
 mm/memcontrol.c                |  24 +--
 mm/mmap.c                      |  17 +-
 mm/oom_kill.c                  | 383 +++++++++++++++++------------------------
 mm/page_alloc.c                |  73 +++-----
 10 files changed, 202 insertions(+), 323 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 6364890..c8b66b9 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -376,10 +376,8 @@ static void moom_callback(struct work_struct *ignored)
 		.order = -1,
 	};
 
-	mutex_lock(&oom_lock);
 	if (!out_of_memory(&oc))
 		pr_info("OOM request ignored. No task eligible\n");
-	mutex_unlock(&oom_lock);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb11..a82360a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -382,8 +382,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
-int mem_cgroup_scan_tasks(struct mem_cgroup *,
-			  int (*)(struct task_struct *, void *), void *);
+void mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+			   void (*fn)(struct task_struct *, void *), void *arg);
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
@@ -850,10 +850,9 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
 {
 }
 
-static inline int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
-		int (*fn)(struct task_struct *, void *), void *arg)
+static inline void mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+		void (*fn)(struct task_struct *, void *), void *arg)
 {
-	return 0;
 }
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 6adac11..09cfa8e 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -44,8 +44,6 @@ struct oom_control {
 	unsigned long chosen_points;
 };
 
-extern struct mutex oom_lock;
-
 static inline void set_current_oom_origin(void)
 {
 	current->signal->oom_flag_origin = true;
@@ -68,7 +66,7 @@ static inline bool tsk_is_oom_victim(struct task_struct * tsk)
 
 /*
  * Use this helper if tsk->mm != mm and the victim mm needs a special
- * handling. This is guaranteed to stay true after once set.
+ * handling.
  */
 static inline bool mm_is_oom_victim(struct mm_struct *mm)
 {
@@ -95,7 +93,8 @@ static inline int check_stable_address_space(struct mm_struct *mm)
 	return 0;
 }
 
-void __oom_reap_task_mm(struct mm_struct *mm);
+extern void oom_reap_mm(struct mm_struct *mm);
+extern bool try_oom_notifier(void);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 87bf02d..e23fc7f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1162,9 +1162,10 @@ struct task_struct {
 	unsigned long			task_state_change;
 #endif
 	int				pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
-#endif
+	struct list_head		oom_victim_list;
+	unsigned long			last_oom_compared;
+	unsigned long			last_oom_score;
+	unsigned char			oom_reap_stall_count;
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index ec912d0..d30615e 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -66,7 +66,6 @@ static inline int get_dumpable(struct mm_struct *mm)
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
-#define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
 #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
 #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
 #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
diff --git a/kernel/fork.c b/kernel/fork.c
index 9440d61..5ad2b19 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -977,6 +977,8 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (unlikely(mm_is_oom_victim(mm)))
+		clear_bit(MMF_OOM_VICTIM, &mm->flags);
 	mmdrop(mm);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6f0d5e..35c33bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -884,17 +884,14 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
  * @arg: argument passed to @fn
  *
  * This function iterates over tasks attached to @memcg or to any of its
- * descendants and calls @fn for each task. If @fn returns a non-zero
- * value, the function breaks the iteration loop and returns the value.
- * Otherwise, it will iterate over all tasks and return 0.
+ * descendants and calls @fn for each task.
  *
  * This function must not be called for the root memory cgroup.
  */
-int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
-			  int (*fn)(struct task_struct *, void *), void *arg)
+void mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+			   void (*fn)(struct task_struct *, void *), void *arg)
 {
 	struct mem_cgroup *iter;
-	int ret = 0;
 
 	BUG_ON(memcg == root_mem_cgroup);
 
@@ -903,15 +900,10 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 		struct task_struct *task;
 
 		css_task_iter_start(&iter->css, 0, &it);
-		while (!ret && (task = css_task_iter_next(&it)))
-			ret = fn(task, arg);
+		while ((task = css_task_iter_next(&it)))
+			fn(task, arg);
 		css_task_iter_end(&it);
-		if (ret) {
-			mem_cgroup_iter_break(memcg, iter);
-			break;
-		}
 	}
-	return ret;
 }
 
 /**
@@ -1206,12 +1198,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-	bool ret;
 
-	mutex_lock(&oom_lock);
-	ret = out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
-	return ret;
+	return out_of_memory(&oc);
 }
 
 #if MAX_NUMNODES > 1
diff --git a/mm/mmap.c b/mm/mmap.c
index d1eb87e..2b422dd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3059,25 +3059,18 @@ void exit_mmap(struct mm_struct *mm)
 	if (unlikely(mm_is_oom_victim(mm))) {
 		/*
 		 * Manually reap the mm to free as much memory as possible.
-		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
-		 * this mm from further consideration.  Taking mm->mmap_sem for
-		 * write after setting MMF_OOM_SKIP will guarantee that the oom
-		 * reaper will not run on this mm again after mmap_sem is
-		 * dropped.
+		 * Then, tell oom_has_pending_victims() no longer try to call
+		 * oom_reap_mm() by taking mm->mmap_sem for write.
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
-		set_bit(MMF_OOM_SKIP, &mm->flags);
+		oom_reap_mm(mm);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 84081e7..36bc02f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -38,7 +38,6 @@
 #include <linux/freezer.h>
 #include <linux/ftrace.h>
 #include <linux/ratelimit.h>
-#include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
 
@@ -49,11 +48,17 @@
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
 
-DEFINE_MUTEX(oom_lock);
+static DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
 /**
@@ -201,19 +206,19 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
 
+	if (tsk_is_oom_victim(p))
+		return 0;
+
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 0;
 
 	/*
 	 * Do not even consider tasks which are explicitly marked oom
-	 * unkillable or have been already oom reaped or the are in
-	 * the middle of vfork
+	 * unkillable or they are in the middle of vfork
 	 */
 	adj = (long)p->signal->oom_score_adj;
-	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_SKIP, &p->mm->flags) ||
-			in_vfork(p)) {
+	if (adj == OOM_SCORE_ADJ_MIN || in_vfork(p)) {
 		task_unlock(p);
 		return 0;
 	}
@@ -222,8 +227,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_victim_mm_score(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -304,25 +308,13 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
-static int oom_evaluate_task(struct task_struct *task, void *arg)
+static void oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
 	unsigned long points;
 
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
-		goto next;
-
-	/*
-	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves unless
-	 * the task has MMF_OOM_SKIP because chances that it would release
-	 * any memory is quite low.
-	 */
-	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
-			goto next;
-		goto abort;
-	}
+		return;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -335,29 +327,22 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 
 	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
 	if (!points || points < oc->chosen_points)
-		goto next;
+		return;
 
 	/* Prefer thread group leaders for display purposes */
 	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
-		goto next;
+		return;
 select:
 	if (oc->chosen)
 		put_task_struct(oc->chosen);
 	get_task_struct(task);
 	oc->chosen = task;
 	oc->chosen_points = points;
-next:
-	return 0;
-abort:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
-	oc->chosen = (void *)-1UL;
-	return 1;
 }
 
 /*
  * Simple selection loop. We choose the process with the highest number of
- * 'points'. In case scan was aborted, oc->chosen is set to -1.
+ * 'points'.
  */
 static void select_bad_process(struct oom_control *oc)
 {
@@ -368,8 +353,7 @@ static void select_bad_process(struct oom_control *oc)
 
 		rcu_read_lock();
 		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
-				break;
+			oom_evaluate_task(p, oc);
 		rcu_read_unlock();
 	}
 
@@ -451,6 +435,29 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 
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
@@ -469,17 +476,10 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
-#ifdef CONFIG_MMU
-/*
- * OOM Reaper kernel thread which tries to reap the memory used by the OOM
- * victim (if that is possible) to help the OOM killer to move on.
- */
-static struct task_struct *oom_reaper_th;
-static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
+static LIST_HEAD(oom_victim_list);
 
-void __oom_reap_task_mm(struct mm_struct *mm)
+#ifdef CONFIG_MMU
+void oom_reap_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 
@@ -518,152 +518,20 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 		}
 	}
 }
-
-static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
-{
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
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
-{
-	while (true) {
-		struct task_struct *tsk = NULL;
-
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
-		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
-	}
-
-	return 0;
-}
+#endif
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	if (tsk->oom_victim_list.next)
 		return;
 
 	get_task_struct(tsk);
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
+	tsk->oom_reap_stall_count = 0;
+	tsk->last_oom_compared = jiffies;
+	tsk->last_oom_score = oom_victim_mm_score(tsk->signal->oom_mm);
+	lockdep_assert_held(&oom_lock);
+	list_add_tail(&tsk->oom_victim_list, &oom_victim_list);
 }
-#endif /* CONFIG_MMU */
 
 /**
  * mark_oom_victim - mark the given task as OOM victim
@@ -806,10 +674,11 @@ static bool task_will_free_mem(struct task_struct *task)
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
@@ -946,7 +815,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 			continue;
 		if (is_global_init(p)) {
 			can_oom_reap = false;
-			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
@@ -1009,6 +877,72 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+bool try_oom_notifier(void)
+{
+	static DEFINE_MUTEX(lock);
+	unsigned long freed = 0;
+
+	/*
+	 * In order to protect OOM notifiers which are not thread safe and to
+	 * avoid excessively releasing memory from OOM notifiers which release
+	 * memory every time, this lock serializes/excludes concurrent calls to
+	 * OOM notifiers.
+	 */
+	if (!mutex_trylock(&lock))
+		return true;
+	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+	mutex_unlock(&lock);
+	return freed > 0;
+}
+
+/*
+ * Currently a reference to "struct task_struct" taken by wake_oom_reaper()
+ * will remain on the oom_victim_list until somebody finds that this mm has
+ * already completed __mmput() or had not completed for too long.
+ */
+static bool oom_has_pending_victims(struct oom_control *oc)
+{
+	struct task_struct *p, *tmp;
+	bool ret = false;
+	bool gaveup = false;
+
+	lockdep_assert_held(&oom_lock);
+	list_for_each_entry_safe(p, tmp, &oom_victim_list, oom_victim_list) {
+		struct mm_struct *mm = p->signal->oom_mm;
+
+		/* Forget about mm which already completed __mmput(). */
+		if (!test_bit(MMF_OOM_VICTIM, &mm->flags))
+			goto remove;
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
+			if (!test_bit(MMF_UNSTABLE, &mm->flags) &&
+			    !mm_has_blockable_invalidate_notifiers(mm))
+				oom_reap_mm(mm);
+			up_read(&mm->mmap_sem);
+		}
+#endif
+		/* Forget if this mm didn't complete __mmput() for too long. */
+		if (!victim_mm_stalling(p, mm))
+			continue;
+		gaveup = true;
+remove:
+		list_del(&p->oom_victim_list);
+		put_task_struct(p);
+	}
+	if (gaveup)
+		debug_show_all_locks();
+
+	return ret && !is_sysrq_oom(oc);
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -1020,18 +954,8 @@ int unregister_oom_notifier(struct notifier_block *nb)
  */
 bool out_of_memory(struct oom_control *oc)
 {
-	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
-
-	if (oom_killer_disabled)
-		return false;
-
-	if (!is_memcg_oom(oc)) {
-		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-		if (freed > 0)
-			/* Got some memory back in the last second. */
-			return true;
-	}
+	const char *prompt;
 
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
@@ -1045,15 +969,6 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	/*
-	 * The OOM killer does not compensate for IO-less reclaim.
-	 * pagefault_out_of_memory lost its gfp context so we have to
-	 * make sure exclude 0 mask - all other users should have at least
-	 * ___GFP_DIRECT_RECLAIM to get here.
-	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
-		return true;
-
-	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA and memcg) that may require different handling.
 	 */
@@ -1067,32 +982,46 @@ bool out_of_memory(struct oom_control *oc)
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
 		oc->chosen = current;
-		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
-		return true;
+		prompt = "Out of memory (oom_kill_allocating_task)";
+	} else {
+		select_bad_process(oc);
+		prompt = !is_memcg_oom(oc) ? "Out of memory" :
+			"Memory cgroup out of memory";
 	}
-
-	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+	if (!oc->chosen) {
+		if (is_sysrq_oom(oc) || is_memcg_oom(oc))
+			return false;
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL) {
-		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-				 "Memory cgroup out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
-	return !!oc->chosen;
+	mutex_lock(&oom_lock);
+	/*
+	 * If there are OOM victims which current thread can select,
+	 * wait for them to reach __mmput().
+	 *
+	 * If oom_killer_disable() is in progress, we can't select new OOM
+	 * victims.
+	 *
+	 * The OOM killer does not compensate for IO-less reclaim.
+	 * pagefault_out_of_memory lost its gfp context so we have to
+	 * make sure exclude 0 mask - all other users should have at least
+	 * ___GFP_DIRECT_RECLAIM to get here.
+	 *
+	 * Otherwise, invoke the OOM-killer.
+	 */
+	if (oom_has_pending_victims(oc) || oom_killer_disabled ||
+	    (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS)))
+		put_task_struct(oc->chosen);
+	else
+		oom_kill_process(oc, prompt);
+	mutex_unlock(&oom_lock);
+	return !oom_killer_disabled;
 }
 
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
- * killing is already in progress so do nothing.
+ * memory-hogging task.
  */
 void pagefault_out_of_memory(void)
 {
@@ -1107,8 +1036,6 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
-		return;
 	out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
+	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100..cd7f9db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3460,29 +3460,16 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	};
 	struct page *page;
 
-	*did_some_progress = 0;
-
-	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
-	 */
-	if (!mutex_trylock(&oom_lock)) {
-		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
-		return NULL;
-	}
+	*did_some_progress = try_oom_notifier();
 
 	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
+	 * we're still under heavy pressure.
 	 */
-	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
+	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL), order,
 				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
-	if (page)
+	if (page || *did_some_progress)
 		goto out;
 
 	/* Coredumps can quickly deplete all memory reserves */
@@ -3531,7 +3518,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 					ALLOC_NO_WATERMARKS, ac);
 	}
 out:
-	mutex_unlock(&oom_lock);
 	return page;
 }
 
@@ -3863,21 +3849,6 @@ static void wake_all_kswapds(unsigned int order, gfp_t gfp_mask,
 	return alloc_flags;
 }
 
-static bool oom_reserves_allowed(struct task_struct *tsk)
-{
-	if (!tsk_is_oom_victim(tsk))
-		return false;
-
-	/*
-	 * !MMU doesn't have oom reaper so give access to memory reserves
-	 * only to the thread with TIF_MEMDIE set
-	 */
-	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
-		return false;
-
-	return true;
-}
-
 /*
  * Distinguish requests which really need access to full memory
  * reserves from oom victims which can live with a portion of it
@@ -3893,7 +3864,7 @@ static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
 	if (!in_interrupt()) {
 		if (current->flags & PF_MEMALLOC)
 			return ALLOC_NO_WATERMARKS;
-		else if (oom_reserves_allowed(current))
+		else if (tsk_is_oom_victim(current))
 			return ALLOC_OOM;
 	}
 
@@ -3922,6 +3893,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
 	struct zone *zone;
 	struct zoneref *z;
+	bool ret = false;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3985,25 +3957,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 				}
 			}
 
-			/*
-			 * Memory allocation/reclaim might be called from a WQ
-			 * context and the current implementation of the WQ
-			 * concurrency control doesn't recognize that
-			 * a particular WQ is congested if the worker thread is
-			 * looping without ever sleeping. Therefore we have to
-			 * do a short sleep here rather than calling
-			 * cond_resched().
-			 */
-			if (current->flags & PF_WQ_WORKER)
-				schedule_timeout_uninterruptible(1);
-			else
-				cond_resched();
-
-			return true;
+			ret = true;
+			goto out;
 		}
 	}
 
-	return false;
+out:
+	/*
+	 * Memory allocation/reclaim might be called from a WQ
+	 * context and the current implementation of the WQ
+	 * concurrency control doesn't recognize that
+	 * a particular WQ is congested if the worker thread is
+	 * looping without ever sleeping. Therefore we have to
+	 * do a short sleep here rather than calling
+	 * cond_resched().
+	 */
+	if (current->flags & PF_WQ_WORKER)
+		schedule_timeout_uninterruptible(1);
+	else
+		cond_resched();
+	return ret;
 }
 
 static inline bool
-- 
1.8.3.1
