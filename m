Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 266CC6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 06:15:20 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so198522330pac.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 03:15:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w64si3498947pfb.137.2016.07.01.03.15.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 03:15:18 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear TIF_MEMDIE
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160627175555.GA24370@redhat.com>
	<20160628101956.GA510@dhcp22.suse.cz>
	<20160629001353.GA9377@redhat.com>
	<20160629083314.GA27153@dhcp22.suse.cz>
	<20160629141953.GC27153@dhcp22.suse.cz>
In-Reply-To: <20160629141953.GC27153@dhcp22.suse.cz>
Message-Id: <201607011915.GDB87502.MFQOFOJHtLFOVS@I-love.SAKURA.ne.jp>
Date: Fri, 1 Jul 2016 19:15:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, oleg@redhat.com
Cc: linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

Michal Hocko wrote:
> OK, so this is what I have on top of [1]. I still haven't tested it but
> at least added a changelog to have some reasoning for the change. If
> this looks OK and passes my testing - which would be tricky anyway
> because hitting those rare corner cases is quite hard - then the next
> step would be to fix the race between suspend and oom_killer_disable
> currently worked around by 74070542099c in a more robust way. We can
> also start thinking to use TIF_MEMDIE only for the access to memory
> reserves to oom victims which actually need to allocate and decouple the
> current double meaning.
> 
> I completely understand a resistance to adding new stuff to the
> signal_struct but this seems like worth it. I would like to have a
> stable and existing mm for that purpose but that sounds like a more long
> term plan than something we can do right away.
> 
> Thoughts?

If adding new stuff to the mm_struct is acceptable (like patch shown below),
we can remove

  (1) oom_victims from the signal_struct
  (2) oom_reaper_list from the task_struct
  (3) exit_oom_victim() on remote tasks
  (4) commit 74070542099c66d8 ("oom, suspend: fix oom_reaper vs.
      oom_killer_disable race") due to (3)
  (5) OOM_SCAN_ABORT case from oom_scan_process_thread() because
      oom_has_pending_mm() is called before starting victim selection loop
  (6) commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
      because oom_has_pending_mm() remains true until exit_oom_mm() is called
      from __mmput() or oom_reaper()

and make the OOM reaper operate on mm_struct.

Also, after patch shown below is applied, we can remove almost pointless
oom_unkillable_task() test in oom_scan_process_thread() which is needed
only for doing oom_task_origin() test which can be done after
oom_unkillable_task() test in oom_badness() (i.e. we can remove
oom_scan_process_thread() entirely).

 include/linux/mm_types.h |  10 ++
 include/linux/oom.h      |  16 +--
 include/linux/sched.h    |   4 -
 kernel/exit.c            |   2 +-
 kernel/fork.c            |   1 +
 mm/memcontrol.c          |  18 ++--
 mm/oom_kill.c            | 262 +++++++++++++++++++++--------------------------
 7 files changed, 142 insertions(+), 171 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e093e1d..84b74ad 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <linux/workqueue.h>
+#include <linux/nodemask.h> /* nodemask_t */
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -392,6 +393,14 @@ struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
 };
 
+struct oom_mm {
+	struct list_head list; /* Linked to oom_mm_list list. */
+	struct mem_cgroup *memcg; /* No deref. Maybe NULL. */
+	const nodemask_t *nodemask; /* No deref. Maybe NULL. */
+	char comm[16]; /* Copy of task_struct->comm[TASK_COMM_LEN]. */
+	pid_t pid; /* Copy of task_struct->pid. */
+};
+
 struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
@@ -518,6 +527,7 @@ struct mm_struct {
 #ifdef CONFIG_MMU
 	struct work_struct async_put_work;
 #endif
+	struct oom_mm oom_mm;
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457..1a212c1 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -49,7 +49,6 @@ enum oom_constraint {
 enum oom_scan_t {
 	OOM_SCAN_OK,		/* scan thread and find its badness */
 	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
-	OOM_SCAN_ABORT,		/* abort the iteration and return */
 	OOM_SCAN_SELECT,	/* always select this thread first */
 };
 
@@ -70,15 +69,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
-
-#ifdef CONFIG_MMU
-extern void wake_oom_reaper(struct task_struct *tsk);
-#else
-static inline void wake_oom_reaper(struct task_struct *tsk)
-{
-}
-#endif
+extern void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
@@ -91,12 +82,15 @@ extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 extern void check_panic_on_oom(struct oom_control *oc,
 			       enum oom_constraint constraint);
 
+extern void exit_oom_mm(struct mm_struct *mm);
+extern bool oom_has_pending_mm(struct mem_cgroup *memcg,
+			       const nodemask_t *nodemask);
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 					       struct task_struct *task);
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(struct task_struct *tsk);
+extern void exit_oom_victim(void);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 553af29..4379279 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -671,7 +671,6 @@ struct signal_struct {
 	atomic_t		sigcnt;
 	atomic_t		live;
 	int			nr_threads;
-	atomic_t oom_victims; /* # of TIF_MEDIE threads in this thread group */
 	struct list_head	thread_head;
 
 	wait_queue_head_t	wait_chldexit;	/* for wait4() */
@@ -1917,9 +1916,6 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct task_struct *oom_reaper_list;
-#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/kernel/exit.c b/kernel/exit.c
index 84ae830..1b1dada 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -511,7 +511,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
+		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/kernel/fork.c b/kernel/fork.c
index 7926993..b870dbc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -722,6 +722,7 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40dfca3..bf4c8f8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1235,12 +1235,18 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		mark_oom_victim(current, &oc);
 		goto unlock;
 	}
 
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG);
+
+	if (oom_has_pending_mm(memcg, NULL)) {
+		/* Set a dummy value to return "true". */
+		chosen = (void *) 1;
+		goto unlock;
+	}
+
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
@@ -1258,14 +1264,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				/* fall through */
 			case OOM_SCAN_CONTINUE:
 				continue;
-			case OOM_SCAN_ABORT:
-				css_task_iter_end(&it);
-				mem_cgroup_iter_break(memcg, iter);
-				if (chosen)
-					put_task_struct(chosen);
-				/* Set a dummy value to return "true". */
-				chosen = (void *) 1;
-				goto unlock;
 			case OOM_SCAN_OK:
 				break;
 			};
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7d0a275..c9e4b53 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -275,6 +275,50 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+static LIST_HEAD(oom_mm_list);
+static DEFINE_SPINLOCK(oom_mm_list_lock);
+
+/*
+ * This function might be called concurrently from both exiting thread
+ * and the OOM reaper thread.
+ */
+void exit_oom_mm(struct mm_struct *mm)
+{
+	bool remove;
+
+	if (!mm->oom_mm.list.next)
+		return;
+	/* Disconnect from oom_mm_list only if still connected. */
+	spin_lock(&oom_mm_list_lock);
+	remove = mm->oom_mm.list.next;
+	if (remove) {
+		list_del(&mm->oom_mm.list);
+		mm->oom_mm.list.next = NULL;
+	}
+	spin_unlock(&oom_mm_list_lock);
+	/* Drop a reference taken by mark_oom_victim() */
+	if (remove)
+		mmdrop(mm);
+}
+
+bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+{
+	struct oom_mm *mm;
+	bool ret = false;
+
+	spin_lock(&oom_mm_list_lock);
+	list_for_each_entry(mm, &oom_mm_list, list) {
+		if (memcg && mm->memcg != memcg)
+			continue;
+		if (nodemask && mm->nodemask != nodemask)
+			continue;
+		ret = true;
+		break;
+	}
+	spin_unlock(&oom_mm_list_lock);
+	return ret;
+}
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 					struct task_struct *task)
 {
@@ -282,25 +326,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		return OOM_SCAN_CONTINUE;
 
 	/*
-	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves unless
-	 * the task has MMF_OOM_REAPED because chances that it would release
-	 * any memory is quite low.
-	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		struct task_struct *p = find_lock_task_mm(task);
-		enum oom_scan_t ret = OOM_SCAN_ABORT;
-
-		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
-			task_unlock(p);
-		}
-
-		return ret;
-	}
-
-	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
@@ -332,9 +357,6 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 			/* fall through */
 		case OOM_SCAN_CONTINUE:
 			continue;
-		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
 		case OOM_SCAN_OK:
 			break;
 		};
@@ -447,54 +469,17 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
  * victim (if that is possible) to help the OOM killer to move on.
  */
-static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task(struct task_struct *tsk)
+static bool __oom_reap_vma(struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = NULL;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task		exit_mm
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
-	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
-	 */
-	p = find_lock_task_mm(tsk);
-	if (!p)
-		goto unlock_oom;
-	mm = p->mm;
-	atomic_inc(&mm->mm_count);
-	task_unlock(p);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		goto mm_drop;
-	}
+	if (!down_read_trylock(&mm->mmap_sem))
+		return false;
 
 	/*
 	 * increase mm_users only after we know we will reap something so
@@ -503,7 +488,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto mm_drop;
+		return true;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -534,7 +519,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-			task_pid_nr(tsk), tsk->comm,
+			mm->oom_mm.pid, mm->oom_mm.comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
@@ -551,27 +536,32 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-mm_drop:
-	mmdrop(mm);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
+static void oom_reap_vma(struct mm_struct *mm)
 {
 	int attempts = 0;
+	bool ret;
+
+	/*
+	 * Check MMF_OOM_REAPED after holding oom_lock because
+	 * oom_kill_process() might find this mm pinned.
+	 */
+	mutex_lock(&oom_lock);
+	ret = test_bit(MMF_OOM_REAPED, &mm->flags);
+	mutex_unlock(&oom_lock);
+	if (ret)
+		return;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_vma(mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
-		struct task_struct *p;
-
 		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-				task_pid_nr(tsk), tsk->comm);
+			mm->oom_mm.pid, mm->oom_mm.comm);
 
 		/*
 		 * If we've already tried to reap this task in the past and
@@ -579,30 +569,14 @@ static void oom_reap_task(struct task_struct *tsk)
 		 * so hide the mm from the oom killer so that it can move on
 		 * to another task with a different mm struct.
 		 */
-		p = find_lock_task_mm(tsk);
-		if (p) {
-			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
-				pr_info("oom_reaper: giving up pid:%d (%s)\n",
-						task_pid_nr(tsk), tsk->comm);
-				set_bit(MMF_OOM_REAPED, &p->mm->flags);
-			}
-			task_unlock(p);
+		if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
+			pr_info("oom_reaper: giving up pid:%d (%s)\n",
+				mm->oom_mm.pid, mm->oom_mm.comm);
+			set_bit(MMF_OOM_REAPED, &mm->flags);
 		}
 
 		debug_show_all_locks();
 	}
-
-	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
-	 */
-	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
 }
 
 static int oom_reaper(void *unused)
@@ -610,49 +584,33 @@ static int oom_reaper(void *unused)
 	set_freezable();
 
 	while (true) {
-		struct task_struct *tsk = NULL;
+		struct mm_struct *mm = NULL;
 
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
-		spin_unlock(&oom_reaper_lock);
+		wait_event_freezable(oom_reaper_wait,
+				     !list_empty(&oom_mm_list));
+		spin_lock(&oom_mm_list_lock);
+		if (!list_empty(&oom_mm_list))
+			mm = list_first_entry(&oom_mm_list, struct mm_struct,
+					      oom_mm.list);
+		spin_unlock(&oom_mm_list_lock);
 
-		if (tsk)
-			oom_reap_task(tsk);
+		if (!mm)
+			continue;
+		oom_reap_vma(mm);
+		exit_oom_mm(mm);
 	}
 
 	return 0;
 }
 
-void wake_oom_reaper(struct task_struct *tsk)
-{
-	if (!oom_reaper_th)
-		return;
-
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
-	wake_up(&oom_reaper_wait);
-}
-
 static int __init oom_init(void)
 {
-	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
-	if (IS_ERR(oom_reaper_th)) {
-		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
-				PTR_ERR(oom_reaper_th));
-		oom_reaper_th = NULL;
-	}
+	/*
+	 * If this kthread_run() call triggers OOM killer, the system will
+	 * panic() because this function is called before userspace processes
+	 * are started. Thus, there is no point with checking failure.
+	 */
+	kthread_run(oom_reaper, NULL, "oom_reaper");
 	return 0;
 }
 subsys_initcall(oom_init)
@@ -665,13 +623,33 @@ subsys_initcall(oom_init)
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
 {
+	struct mm_struct *mm = tsk->mm;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_inc(&tsk->signal->oom_victims);
+	/*
+	 * Connect to oom_mm_list only if not connected.
+	 * Since we have stable mm, exit_oom_mm() from __mmput() can't be
+	 * called before we add this mm.
+	 */
+	spin_lock(&oom_mm_list_lock);
+	if (!mm->oom_mm.list.next) {
+		atomic_inc(&mm->mm_count);
+		mm->oom_mm.memcg = oc->memcg;
+		mm->oom_mm.nodemask = oc->nodemask;
+		strncpy(mm->oom_mm.comm, tsk->comm, sizeof(mm->oom_mm.comm));
+		mm->oom_mm.pid = task_pid_nr(tsk);
+		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+#ifdef CONFIG_MMU
+		wake_up(&oom_reaper_wait);
+#endif
+	}
+	spin_unlock(&oom_mm_list_lock);
+
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -685,11 +663,9 @@ void mark_oom_victim(struct task_struct *tsk)
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
-void exit_oom_victim(struct task_struct *tsk)
+void exit_oom_victim(void)
 {
-	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
-	atomic_dec(&tsk->signal->oom_victims);
+	clear_thread_flag(TIF_MEMDIE);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -821,7 +797,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -829,8 +804,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
+		mark_oom_victim(p, oc);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -890,7 +864,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
+	mark_oom_victim(victim, oc);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -920,7 +894,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * memory might be still used. Hide the mm from the oom
 			 * killer to guarantee OOM forward progress.
 			 */
-			can_oom_reap = false;
 			set_bit(MMF_OOM_REAPED, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
@@ -931,9 +904,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -1008,8 +978,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		mark_oom_victim(current, oc);
 		return true;
 	}
 
@@ -1040,13 +1009,16 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	if (!is_sysrq_oom(oc) && oom_has_pending_mm(oc->memcg, oc->nodemask))
+		return true;
+
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p && !is_sysrq_oom(oc)) {
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
+	if (p) {
 		oom_kill_process(oc, p, points, totalpages, "Out of memory");
 		/*
 		 * Give the killed process a good chance to exit before trying
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
