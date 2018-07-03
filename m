Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0E566B000C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:26:15 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w12-v6so1303740oie.12
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:26:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 101-v6si415199otm.195.2018.07.03.07.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:26:14 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/8] mm,oom: Check pending victims earlier in out_of_memory().
Date: Tue,  3 Jul 2018 23:25:03 +0900
Message-Id: <1530627910-3415-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

The "mm, oom: cgroup-aware OOM killer" patchset is trying to introduce
INFLIGHT_VICTIM in order to replace open-coded ((void *)-1UL). But
(regarding CONFIG_MMU=y case) we have a list of inflight OOM victim
threads which are connected to oom_reaper_list. Thus we can check
whether there are inflight OOM victims before starting process/memcg
list traversal. Since it is likely that only few threads are linked to
oom_reaper_list, checking all victims' OOM domain will not matter.

Thus, check whether there are inflight OOM victims before starting
process/memcg list traversal and eliminate the "abort" path.

Note that this patch could temporarily regress CONFIG_MMU=n kernels
because this patch selects same victims rather than waits for victims
if CONFIG_MMU=n. This will be fixed by the next patch in this series.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |   9 ++--
 include/linux/sched.h      |   2 +-
 mm/memcontrol.c            |  18 +++-----
 mm/oom_kill.c              | 103 +++++++++++++++++++++++++--------------------
 4 files changed, 67 insertions(+), 65 deletions(-)

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
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 9256118..d56ae68 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1163,7 +1163,7 @@ struct task_struct {
 #endif
 	int				pagefault_disabled;
 #ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
+	struct list_head		oom_victim_list;
 #endif
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6f0d5e..c8a75c8 100644
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
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d3fb4e4..f58281e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -304,25 +304,13 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
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
@@ -335,29 +323,22 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 
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
@@ -368,8 +349,7 @@ static void select_bad_process(struct oom_control *oc)
 
 		rcu_read_lock();
 		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
-				break;
+			oom_evaluate_task(p, oc);
 		rcu_read_unlock();
 	}
 
@@ -476,7 +456,7 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
+static LIST_HEAD(oom_victim_list);
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 /*
@@ -488,7 +468,7 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  *                               unmap_page_range() # frees some memory
  *                               set_bit(MMF_OOM_SKIP)
  *   out_of_memory()
- *     select_bad_process()
+ *     oom_has_pending_victims()
  *       test_bit(MMF_OOM_SKIP) # selects new oom victim
  *   mutex_unlock(&oom_lock)
  *
@@ -606,14 +586,16 @@ static void oom_reap_task(struct task_struct *tsk)
 	debug_show_all_locks();
 
 done:
-	tsk->oom_reaper_list = NULL;
-
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
 	set_bit(MMF_OOM_SKIP, &mm->flags);
 
+	spin_lock(&oom_reaper_lock);
+	list_del(&tsk->oom_victim_list);
+	spin_unlock(&oom_reaper_lock);
+
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
 }
@@ -623,12 +605,13 @@ static int oom_reaper(void *unused)
 	while (true) {
 		struct task_struct *tsk = NULL;
 
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
+		wait_event_freezable(oom_reaper_wait,
+				     !list_empty(&oom_victim_list));
 		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
+		if (!list_empty(&oom_victim_list))
+			tsk = list_first_entry(&oom_victim_list,
+					       struct task_struct,
+					       oom_victim_list);
 		spin_unlock(&oom_reaper_lock);
 
 		if (tsk)
@@ -640,15 +623,11 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	if (tsk->oom_victim_list.next)
 		return;
-
 	get_task_struct(tsk);
-
 	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
+	list_add_tail(&tsk->oom_victim_list, &oom_victim_list);
 	spin_unlock(&oom_reaper_lock);
 	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
@@ -1010,6 +989,34 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+static bool oom_has_pending_victims(struct oom_control *oc)
+{
+#ifdef CONFIG_MMU
+	struct task_struct *p;
+
+	if (is_sysrq_oom(oc))
+		return false;
+	/*
+	 * Since oom_reap_task_mm()/exit_mmap() will set MMF_OOM_SKIP, let's
+	 * wait for pending victims until MMF_OOM_SKIP is set.
+	 */
+	spin_lock(&oom_reaper_lock);
+	list_for_each_entry(p, &oom_victim_list, oom_victim_list)
+		if (!oom_unkillable_task(p, oc->memcg, oc->nodemask) &&
+		    !test_bit(MMF_OOM_SKIP, &p->signal->oom_mm->flags))
+			break;
+	spin_unlock(&oom_reaper_lock);
+	return p != NULL;
+#else
+	/*
+	 * Since nobody except oom_kill_process() sets MMF_OOM_SKIP, waiting
+	 * for pending victims until MMF_OOM_SKIP is set is useless. Therefore,
+	 * simply let the OOM killer select pending victims again.
+	 */
+	return false;
+#endif
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -1063,6 +1070,9 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint);
 
+	if (oom_has_pending_victims(oc))
+		return true;
+
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
@@ -1074,14 +1084,15 @@ bool out_of_memory(struct oom_control *oc)
 
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+	if (!oc->chosen) {
+		if (is_sysrq_oom(oc) || is_memcg_oom(oc))
+			return false;
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
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
