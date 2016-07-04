Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A264C6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 08:50:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so389846297pfa.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 05:50:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i8si4240295paa.114.2016.07.04.05.50.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jul 2016 05:50:18 -0700 (PDT)
Subject: Re: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
	<201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
	<20160704103931.GA3882@redhat.com>
In-Reply-To: <20160704103931.GA3882@redhat.com>
Message-Id: <201607042150.CIB00512.FSOtMHLOOVFFQJ@I-love.SAKURA.ne.jp>
Date: Mon, 4 Jul 2016 21:50:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

Oleg Nesterov wrote:
> Tetsuo,
> 
> I'll try to actually read this series later, although I will leave the
> actual review to maintainers anyway...

Thank you.

> 
> Just a couple of questions for now,
> 
> On 07/03, Tetsuo Handa wrote:
> >
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -722,6 +722,7 @@ static inline void __mmput(struct mm_struct *mm)
> >  	}
> >  	if (mm->binfmt)
> >  		module_put(mm->binfmt->module);
> > +	exit_oom_mm(mm);
> 
> Is it strictly necessary? At first glance not. Sooner or later oom_reaper() should
> find this mm_struct and do exit_oom_mm(). And given that mm->mm_users is already 0
> the "extra" __oom_reap_vmas() doesn't really hurt.
> 
> It would be nice to remove exit_oom_mm() from __mmput(); it takes the global spinlock
> for the very unlikely case, and if we can avoid it here then perhaps we can remove
> ->oom_mm from mm_struct.

I changed not to take global spinlock from __mmput() unless that mm was used by
TIF_MEMDIE threads. But I don't think I can remove oom_mm from mm_struct because
oom_mm is used for controlling "until when should the OOM killer refrain selecting
next OOM victim". My series is also intended for Michal's

  We can also start thinking to use TIF_MEMDIE only for the access to memory
  reserves to oom victims which actually need to allocate and decouple the
  current double meaning.

response.

> 
> Oleg.
> 
> 

I realized that

	if (nodemask && mm->nodemask != nodemask)
		continue;

in oom_has_pending_mm() is wrong. nodemask_t is not a pointer which can be
compared using address but which needs to be compared using bitmap operation.
Thus, I think I need to remember task_struct which got TIF_MEMDIE. I updated
my series to remember task_struct rather than cgroup and nodemask_t, and to do

	if (oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
		continue;

instead. But I'm not sure whether this will work as expected, especially when
all threads in one thread group (which mm->oom_mm.victim belongs to) reached
TASK_DEAD state. I guess that oom_unkillable_task() will return true, and
that mm will be selected by another thread group (which mm->oom_mm.victim
does not belongs to), and mark_oom_victim() will update mm->oom_mm.victim.
I'd like to wait for Michal to come back...

Below updated patch is based on top of linux-next-20160704 +
http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .
Andrew, can you add "mmotm: mm-oom-fortify-task_will_free_mem-fix" to linux-next?

 include/linux/mm_types.h |    7 +
 include/linux/oom.h      |   16 --
 include/linux/sched.h    |    4
 kernel/exit.c            |    2
 kernel/fork.c            |    1
 kernel/power/process.c   |   12 -
 mm/memcontrol.c          |   16 --
 mm/oom_kill.c            |  298 ++++++++++++++++++++++-------------------------
 8 files changed, 163 insertions(+), 193 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e093e1d..7c1370a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -392,6 +392,12 @@ struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
 };
 
+struct oom_mm {
+	struct list_head list; /* Linked to oom_mm_list list. */
+	/* Thread which was passed to mark_oom_victim() for the last time. */
+	struct task_struct *victim;
+};
+
 struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
@@ -515,6 +521,7 @@ struct mm_struct {
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
 #endif
+	struct oom_mm oom_mm;
 #ifdef CONFIG_MMU
 	struct work_struct async_put_work;
 #endif
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
 
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 0c2ee97..df058be 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -146,18 +146,6 @@ int freeze_processes(void)
 	if (!error && !oom_killer_disable())
 		error = -EBUSY;
 
-	/*
-	 * There is a hard to fix race between oom_reaper kernel thread
-	 * and oom_killer_disable. oom_reaper calls exit_oom_victim
-	 * before the victim reaches exit_mm so try to freeze all the tasks
-	 * again and catch such a left over task.
-	 */
-	if (!error) {
-		pr_info("Double checking all user space processes after OOM killer disable... ");
-		error = try_to_freeze_tasks(true);
-		pr_cont("\n");
-	}
-
 	if (error)
 		thaw_processes();
 	return error;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40dfca3..9acc840 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1235,12 +1235,16 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		mark_oom_victim(current, &oc);
 		goto unlock;
 	}
 
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG);
+	if (oom_has_pending_mm(memcg, NULL)) {
+		/* Set a dummy value to return "true". */
+		chosen = (void *) 1;
+		goto unlock;
+	}
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
@@ -1258,14 +1262,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
index 7d0a275..f60ed04 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -282,25 +282,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
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
@@ -310,6 +291,57 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	return OOM_SCAN_OK;
 }
 
+static LIST_HEAD(oom_mm_list);
+static DEFINE_SPINLOCK(oom_mm_lock);
+
+static inline void __exit_oom_mm(struct mm_struct *mm)
+{
+	struct task_struct *tsk;
+
+	spin_lock(&oom_mm_lock);
+	list_del(&mm->oom_mm.list);
+	tsk = mm->oom_mm.victim;
+	mm->oom_mm.victim = NULL;
+	spin_unlock(&oom_mm_lock);
+	/* Drop references taken by mark_oom_victim() */
+	put_task_struct(tsk);
+	mmdrop(mm);
+}
+
+void exit_oom_mm(struct mm_struct *mm)
+{
+	/* Nothing to do unless mark_oom_victim() was called with this mm. */
+	if (!mm->oom_mm.victim)
+		return;
+#ifdef CONFIG_MMU
+	/*
+	 * OOM reaper will eventually call __exit_oom_mm().
+	 * Allow oom_has_pending_mm() to ignore this mm.
+	 */
+	set_bit(MMF_OOM_REAPED, &mm->flags);
+#else
+	__exit_oom_mm(mm);
+#endif
+}
+
+bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+{
+	struct mm_struct *mm;
+	bool ret = false;
+
+	spin_lock(&oom_mm_lock);
+	list_for_each_entry(mm, &oom_mm_list, oom_mm.list) {
+		if (oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
+			continue;
+		if (test_bit(MMF_OOM_REAPED, &mm->flags))
+			continue;
+		ret = true;
+		break;
+	}
+	spin_unlock(&oom_mm_lock);
+	return ret;
+}
+
 /*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'.  Returns -1 on scan abort.
@@ -332,9 +364,6 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 			/* fall through */
 		case OOM_SCAN_CONTINUE:
 			continue;
-		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
 		case OOM_SCAN_OK:
 			break;
 		};
@@ -447,54 +476,17 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
  * victim (if that is possible) to help the OOM killer to move on.
  */
-static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task(struct task_struct *tsk)
+static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = NULL;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
-	bool ret = true;
 
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
-
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		goto mm_drop;
-	}
+	if (!down_read_trylock(&mm->mmap_sem))
+		return false;
 
 	/*
 	 * increase mm_users only after we know we will reap something so
@@ -503,7 +495,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto mm_drop;
+		return true;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -551,108 +543,85 @@ static bool __oom_reap_task(struct task_struct *tsk)
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
+static void oom_reap_task(struct mm_struct *mm, struct task_struct *tsk)
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
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts > MAX_OOM_REAP_RETRIES) {
-		struct task_struct *p;
-
-		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-				task_pid_nr(tsk), tsk->comm);
-
-		/*
-		 * If we've already tried to reap this task in the past and
-		 * failed it probably doesn't make much sense to try yet again
-		 * so hide the mm from the oom killer so that it can move on
-		 * to another task with a different mm struct.
-		 */
-		p = find_lock_task_mm(tsk);
-		if (p) {
-			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
-				pr_info("oom_reaper: giving up pid:%d (%s)\n",
-						task_pid_nr(tsk), tsk->comm);
-				set_bit(MMF_OOM_REAPED, &p->mm->flags);
-			}
-			task_unlock(p);
-		}
+	if (attempts <= MAX_OOM_REAP_RETRIES)
+		return;
 
-		debug_show_all_locks();
-	}
+	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+		task_pid_nr(tsk), tsk->comm);
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
+	 * If we've already tried to reap this task in the past and
+	 * failed it probably doesn't make much sense to try yet again
+	 * so hide the mm from the oom killer so that it can move on
+	 * to another task with a different mm struct.
 	 */
-	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
+	if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
+		pr_info("oom_reaper: giving up pid:%d (%s)\n",
+			task_pid_nr(tsk), tsk->comm);
+		set_bit(MMF_OOM_REAPED, &mm->flags);
+	}
+	debug_show_all_locks();
 }
 
 static int oom_reaper(void *unused)
 {
-	set_freezable();
-
 	while (true) {
-		struct task_struct *tsk = NULL;
+		struct mm_struct *mm = NULL;
+		struct task_struct *victim = NULL;
 
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
+		wait_event_freezable(oom_reaper_wait,
+				     !list_empty(&oom_mm_list));
+		/*
+		 * Take a reference on current victim thread in case
+		 * oom_reap_task() raced with mark_oom_victim() by
+		 * other threads sharing this mm.
+		 */
+		spin_lock(&oom_mm_lock);
+		if (!list_empty(&oom_mm_list)) {
+			mm = list_first_entry(&oom_mm_list, struct mm_struct,
+					      oom_mm.list);
+			victim = mm->oom_mm.victim;
+			get_task_struct(victim);
 		}
-		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
+		spin_unlock(&oom_mm_lock);
+		if (!mm)
+			continue;
+		oom_reap_task(mm, victim);
+		put_task_struct(victim);
+		__exit_oom_mm(mm);
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
+	struct task_struct *p = kthread_run(oom_reaper, NULL, "oom_reaper");
+
+	BUG_ON(IS_ERR(p));
 	return 0;
 }
 subsys_initcall(oom_init)
@@ -661,17 +630,39 @@ subsys_initcall(oom_init)
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
+ * @oc: oom_control
  *
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
 {
+	struct mm_struct *mm = tsk->mm;
+	struct task_struct *old_tsk;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_inc(&tsk->signal->oom_victims);
+	/*
+	 * Since mark_oom_victim() is called from multiple threads,
+	 * connect this mm to oom_mm_list only if not yet connected.
+	 *
+	 * Since mark_oom_victim() is called with a stable mm (i.e.
+	 * mm->mm_users > 0), __exit_oom_mm() from __mmput() can't be called
+	 * before we add this mm to the list.
+	 */
+	spin_lock(&oom_mm_lock);
+	old_tsk = mm->oom_mm.victim;
+	get_task_struct(tsk);
+	mm->oom_mm.victim = tsk;
+	if (!old_tsk) {
+		atomic_inc(&mm->mm_count);
+		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+	}
+	spin_unlock(&oom_mm_lock);
+	if (old_tsk)
+		put_task_struct(old_tsk);
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -680,16 +671,17 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+#ifdef CONFIG_MMU
+	wake_up(&oom_reaper_wait);
+#endif
 }
 
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
@@ -821,7 +813,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -829,8 +820,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
+		mark_oom_victim(p, oc);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -890,7 +880,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
+	mark_oom_victim(victim, oc);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -920,7 +910,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * memory might be still used. Hide the mm from the oom
 			 * killer to guarantee OOM forward progress.
 			 */
-			can_oom_reap = false;
 			set_bit(MMF_OOM_REAPED, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
@@ -931,9 +920,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -1008,8 +994,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		mark_oom_victim(current, oc);
 		return true;
 	}
 
@@ -1040,13 +1025,16 @@ bool out_of_memory(struct oom_control *oc)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
