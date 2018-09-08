Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D62FC8E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 00:54:45 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e63-v6so26995053ite.2
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 21:54:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y1-v6si7030535jae.78.2018.09.07.21.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 21:54:42 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm, oom: Fix unnecessary killing of additional processes.
Date: Sat,  8 Sep 2018 13:54:12 +0900
Message-Id: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>

David Rientjes is complaining about current behavior that the OOM killer
selects next OOM victim as soon as MMF_OOM_SKIP is set even if
__oom_reap_task_mm() returned without any progress. Michal Hocko insisted
that we should make efforts for

  (i) making sure that __oom_reap_task_mm() can make more progress

and

  (ii) using hand over to exit_mmap() instead of setting MMF_OOM_SKIP
       if the OOM reaper detected that exit_mmap() has already past
       the last point of blocking

instead of using timeout based back off. However, Tetsuo Handa is
observing that the OOM killer is selecting next OOM victim despite

  (A) more than 50% of available RAM was reclaimed by __oom_reap_task_mm()

and

  (B) last allocation in __alloc_pages_may_oom() was attempted after
      MMF_OOM_SKIP was set

. This is an obviously unnecessary killing case where (i) and (ii) shown
above are irrelevant.

  Out of memory: Kill process 3359 (a.out) score 834 or sacrifice child
  Killed process 3359 (a.out) total-vm:4267252kB, anon-rss:2894908kB, file-rss:0kB, shmem-rss:0kB
  in:imjournal invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
  in:imjournal cpuset=/ mems_allowed=0
  CPU: 2 PID: 1001 Comm: in:imjournal Tainted: G                T 4.19.0-rc2+ #692
  Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
  Call Trace:
   dump_stack+0x85/0xcb
   dump_header+0x69/0x2fe
   ? _raw_spin_unlock_irqrestore+0x41/0x70
   oom_kill_process+0x307/0x390
   out_of_memory+0x2f3/0x5d0
   __alloc_pages_slowpath+0xc01/0x1030
   __alloc_pages_nodemask+0x333/0x390
   filemap_fault+0x465/0x910
   ? xfs_ilock+0xbf/0x2b0 [xfs]
   ? __xfs_filemap_fault+0x7d/0x2c0 [xfs]
   ? down_read_nested+0x66/0xa0
   __xfs_filemap_fault+0x8e/0x2c0 [xfs]
   __do_fault+0x11/0x133
   __handle_mm_fault+0xa57/0xf40
   handle_mm_fault+0x1b7/0x3c0
   __do_page_fault+0x2a6/0x580
   do_page_fault+0x32/0x270
   ? page_fault+0x8/0x30
   page_fault+0x1e/0x30
  RIP: 0033:0x7f5f078f6e28
  Code: Bad RIP value.
  RSP: 002b:00007f5f05007c50 EFLAGS: 00010246
  RAX: 0000000000000300 RBX: 0000000000000009 RCX: 00007f5f05007d80
  RDX: 00000000000003dd RSI: 00007f5f07b1ca1a RDI: 00005596745e9bb0
  RBP: 00007f5f05007d70 R08: 0000000000000006 R09: 0000000000000078
  R10: 00005596745e9810 R11: 00007f5f082bb4a0 R12: 00007f5f05007d90
  R13: 00007f5f00035fc0 R14: 00007f5f0003c850 R15: 00007f5f0000d760
  Mem-Info:
  active_anon:243554 inactive_anon:3457 isolated_anon:0
   active_file:53 inactive_file:4386 isolated_file:3
   unevictable:0 dirty:0 writeback:0 unstable:0
   slab_reclaimable:8152 slab_unreclaimable:24512
   mapped:3730 shmem:3704 pagetables:3123 bounce:0
   free:562331 free_pcp:502 free_cma:0
  Node 0 active_anon:974216kB inactive_anon:13828kB active_file:212kB inactive_file:17544kB unevictable:0kB isolated(anon):0kB isolated(file):12kB mapped:14920kB dirty:0kB writeback:0kB shmem:14816kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 305152kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
  Node 0 DMA free:13816kB min:308kB low:384kB high:460kB active_anon:1976kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
  lowmem_reserve[]: 0 2717 3378 3378
  Node 0 DMA32 free:2077084kB min:54108kB low:67632kB high:81156kB active_anon:696988kB inactive_anon:12kB active_file:252kB inactive_file:756kB unevictable:0kB writepending:0kB present:3129152kB managed:2782296kB mlocked:0kB kernel_stack:352kB pagetables:388kB bounce:0kB free_pcp:1328kB local_pcp:248kB free_cma:0kB
  lowmem_reserve[]: 0 0 661 661
  Node 0 Normal free:158424kB min:13164kB low:16452kB high:19740kB active_anon:275676kB inactive_anon:13816kB active_file:0kB inactive_file:16084kB unevictable:0kB writepending:0kB present:1048576kB managed:676908kB mlocked:0kB kernel_stack:6720kB pagetables:12100kB bounce:0kB free_pcp:680kB local_pcp:148kB free_cma:0kB
  lowmem_reserve[]: 0 0 0 0
  Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (U) 3*32kB (U) 4*64kB (UM) 1*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 0*2048kB 3*4096kB (M) = 13816kB
  Node 0 DMA32: 122*4kB (UM) 83*8kB (UM) 56*16kB (UM) 70*32kB (UME) 47*64kB (UE) 46*128kB (UME) 41*256kB (UME) 27*512kB (UME) 20*1024kB (ME) 213*2048kB (M) 387*4096kB (M) = 2079360kB
  Node 0 Normal: 653*4kB (UM) 1495*8kB (UM) 1604*16kB (UME) 1069*32kB (UME) 278*64kB (UME) 147*128kB (UME) 85*256kB (ME) 6*512kB (M) 0*1024kB 7*2048kB (M) 2*4096kB (M) = 158412kB
  Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
  8221 total pagecache pages
  0 pages in swap cache
  Swap cache stats: add 0, delete 0, find 0/0
  Free swap  = 0kB
  Total swap = 0kB
  1048422 pages RAM
  0 pages HighMem/MovableOnly
  179652 pages reserved
  0 pages cma reserved
  0 pages hwpoisoned
  Out of memory: Kill process 1089 (java) score 52 or sacrifice child
  Killed process 1089 (java) total-vm:5555688kB, anon-rss:181976kB, file-rss:0kB, shmem-rss:0kB
  oom_reaper: reaped process 3359 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

This is because we need to wait for a while until reclaimed memory becomes
re-allocatable by get_page_from_freelist(). Michal Hocko finally admitted
that there is no reliable way to handle this race.

Before the OOM reaper was introduced, the OOM killer waited until
TIF_MEMDIE is cleared. It implied completion of __mmput() as long as
a thread which got TIF_MEMDIE invokes __mmput(). But currently, the OOM
killer waits for only completion of __oom_reap_task_mm(), which is very
much shorter wait compared to waiting for completion of __mmput().

We can again try to wait for completion of __mmput(). But like described
in commit 97b1255cb27c551d ("mm,oom_reaper: check for MMF_OOM_SKIP before
complaining"), we have memory allocation dependency after returning from
__oom_reap_task_mm(). Thus, effectively timeout based back off is the only
choice we can use for now.

To mitigate this race, this patch adds a timeout based back off, with
whether the OOM score of an OOM victim's memory is decreasing over time
as a feedback, after MMF_OOM_SKIP is set by the OOM reaper or exit_mmap().

This patch also fixes three possible bugs

  (1) oom_task_origin() tasks can be selected forever because it did not
      check for MMF_OOM_SKIP.

  (2) sysctl_oom_kill_allocating_task path can be selected forever
      because it did not check for MMF_OOM_SKIP.

  (3) CONFIG_MMU=n kernels might livelock because nobody except
      is_global_init() case in __oom_kill_process() sets MMF_OOM_SKIP.

which prevent proof of "the forward progress guarantee"
and adds one optimization

  (4) oom_evaluate_task() was calling oom_unkillable_task() twice because
      oom_evaluate_task() needs to check for !MMF_OOM_SKIP and
      oom_task_origin() tasks before calling oom_badness().

in addition to mitigating the race.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h |   9 +-
 include/linux/oom.h        |   1 +
 include/linux/sched.h      |   7 +-
 kernel/fork.c              |   2 +
 mm/memcontrol.c            |  18 +---
 mm/oom_kill.c              | 242 ++++++++++++++++++++++++---------------------
 6 files changed, 148 insertions(+), 131 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 652f602..396b01d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -417,8 +417,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
-int mem_cgroup_scan_tasks(struct mem_cgroup *,
-			  int (*)(struct task_struct *, void *), void *);
+void mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+			   void (*fn)(struct task_struct *, void *), void *arg);
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
@@ -917,10 +917,9 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
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
index 69864a5..4a14787 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -104,6 +104,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(void);
+extern void exit_oom_mm(struct mm_struct *mm);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 977cb57..4e0e357 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1174,9 +1174,10 @@ struct task_struct {
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
diff --git a/kernel/fork.c b/kernel/fork.c
index f0b5847..205386b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1008,6 +1008,8 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (unlikely(mm_is_oom_victim(mm)))
+		exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59..53c8d2c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1058,17 +1058,14 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
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
 
@@ -1077,15 +1074,10 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
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
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..713545e 100644
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
@@ -206,22 +212,30 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	long points;
 	long adj;
 
+	/*
+	 * Ignore if this task was already marked as an OOM victim, for
+	 * oom_has_pending_victims() already waited for this task.
+	 */
+	if (tsk_is_oom_victim(p))
+		return 0;
+
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
 
+	/* Select if this task is marked to be killed first. */
+	if (unlikely(oom_task_origin(p)))
+		return ULONG_MAX;
+
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 0;
 
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
+	if (adj == OOM_SCORE_ADJ_MIN || (in_vfork(p) && totalpages)) {
 		task_unlock(p);
 		return 0;
 	}
@@ -230,8 +244,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_victim_mm_score(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -312,60 +325,27 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
-static int oom_evaluate_task(struct task_struct *task, void *arg)
+static void oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
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
-
-	/*
-	 * If task is allocating a lot of memory and has been marked to be
-	 * killed first if it triggers an oom, then select it.
-	 */
-	if (oom_task_origin(task)) {
-		points = ULONG_MAX;
-		goto select;
-	}
-
 	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
 	if (!points || points < oc->chosen_points)
-		goto next;
-
+		return;
 	/* Prefer thread group leaders for display purposes */
 	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
-		goto next;
-select:
+		return;
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
@@ -376,8 +356,7 @@ static void select_bad_process(struct oom_control *oc)
 
 		rcu_read_lock();
 		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
-				break;
+			oom_evaluate_task(p, oc);
 		rcu_read_unlock();
 	}
 
@@ -478,6 +457,8 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
+static LIST_HEAD(oom_victim_list);
+
 #ifdef CONFIG_MMU
 /*
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
@@ -485,8 +466,7 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
+static struct task_struct *oom_reap_target;
 
 bool __oom_reap_task_mm(struct mm_struct *mm)
 {
@@ -591,73 +571,32 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
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
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
 	set_bit(MMF_OOM_SKIP, &mm->flags);
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
 }
 
 static int oom_reaper(void *unused)
 {
 	while (true) {
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
+		wait_event_freezable(oom_reaper_wait, oom_reap_target != NULL);
+		oom_reap_task(oom_reap_target);
+		/* Drop a reference taken by oom_has_pending_victims(). */
+		put_task_struct(oom_reap_target);
+		oom_reap_target = NULL;
 	}
 
 	return 0;
 }
 
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
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
 	return 0;
 }
 subsys_initcall(oom_init)
-#else
-static inline void wake_oom_reaper(struct task_struct *tsk)
-{
-}
 #endif /* CONFIG_MMU */
 
 /**
@@ -683,6 +622,11 @@ static void mark_oom_victim(struct task_struct *tsk)
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
 		set_bit(MMF_OOM_VICTIM, &mm->flags);
+		tsk->last_oom_compared = jiffies;
+		tsk->last_oom_score = oom_victim_mm_score(mm);
+		tsk->oom_reap_stall_count = 0;
+		get_task_struct(tsk);
+		list_add(&tsk->oom_victim_list, &oom_victim_list);
 	}
 
 	/*
@@ -696,6 +640,21 @@ static void mark_oom_victim(struct task_struct *tsk)
 	trace_mark_victim(tsk->pid);
 }
 
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
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
@@ -834,7 +793,6 @@ static void __oom_kill_process(struct task_struct *victim)
 {
 	struct task_struct *p;
 	struct mm_struct *mm;
-	bool can_oom_reap = true;
 
 	p = find_lock_task_mm(victim);
 	if (!p) {
@@ -884,7 +842,6 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (same_thread_group(p, victim))
 			continue;
 		if (is_global_init(p)) {
-			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
@@ -901,25 +858,20 @@ static void __oom_kill_process(struct task_struct *victim)
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
-#undef K
 
 /*
  * Kill provided task unless it's secured by setting
  * oom_score_adj to OOM_SCORE_ADJ_MIN.
  */
-static int oom_kill_memcg_member(struct task_struct *task, void *unused)
+static void oom_kill_memcg_member(struct task_struct *task, void *unused)
 {
 	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(task);
 		__oom_kill_process(task);
 	}
-	return 0;
 }
 
 static void oom_kill_process(struct oom_control *oc, const char *message)
@@ -942,7 +894,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -1041,6 +992,76 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
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
+static bool oom_has_pending_victims(struct oom_control *oc)
+{
+	struct task_struct *p, *tmp;
+	bool ret = false;
+	bool gaveup = false;
+
+	if (is_sysrq_oom(oc))
+		return false;
+	/*
+	 * Wait for pending victims until __mmput() completes or stalled
+	 * too long.
+	 */
+	list_for_each_entry_safe(p, tmp, &oom_victim_list, oom_victim_list) {
+		struct mm_struct *mm = p->signal->oom_mm;
+
+		if (oom_unkillable_task(p, oc->memcg, oc->nodemask))
+			continue;
+		ret = true;
+#ifdef CONFIG_MMU
+		/*
+		 * Since the OOM reaper exists, we can safely wait until
+		 * MMF_OOM_SKIP is set.
+		 */
+		if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
+			if (!oom_reap_target) {
+				get_task_struct(p);
+				oom_reap_target = p;
+				trace_wake_reaper(p->pid);
+				wake_up(&oom_reaper_wait);
+			}
+			continue;
+		}
+#endif
+		/* We can wait as long as OOM score is decreasing over time. */
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
+	return ret;
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -1072,7 +1093,6 @@ bool out_of_memory(struct oom_control *oc)
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		wake_oom_reaper(current);
 		return true;
 	}
 
@@ -1094,9 +1114,11 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint);
 
+	if (oom_has_pending_victims(oc))
+		return true;
+
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+	    oom_badness(current, NULL, oc->nodemask, 0)) {
 		get_task_struct(current);
 		oc->chosen = current;
 		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
@@ -1115,11 +1137,11 @@ bool out_of_memory(struct oom_control *oc)
 		 */
 		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
 			panic("System is deadlocked on memory\n");
+		return false;
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL)
-		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-				 "Memory cgroup out of memory");
-	return !!oc->chosen;
+	oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
+			 "Memory cgroup out of memory");
+	return true;
 }
 
 /*
-- 
1.8.3.1
