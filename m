Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 21EAC6B000C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:01:27 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q129-v6so5564554oic.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:01:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w198-v6si8520035oie.389.2018.06.07.04.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 04:01:25 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 4/4] mm,oom: Check pending victims earlier in out_of_memory().
Date: Thu,  7 Jun 2018 20:00:23 +0900
Message-Id: <1528369223-7571-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

The "mm, oom: cgroup-aware OOM killer" patchset is trying to introduce
INFLIGHT_VICTIM in order to replace open-coded ((void *)-1UL). But
(regarding CONFIG_MMU=y case) we have a list of inflight OOM victim
threads which are connected to oom_reaper_list. Thus we can check
whether there are inflight OOM victims before starting process/memcg
list traversal. Since it is likely that only few threads are linked to
oom_reaper_list, checking all victims' OOM domain will not matter.

Thus, check whether there are inflight OOM victims before starting
process/memcg list traversal and eliminate the "abort" path.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |  9 ++---
 mm/memcontrol.c            | 18 +++------
 mm/oom_kill.c              | 99 +++++++++++++++++++++++++---------------------
 3 files changed, 64 insertions(+), 62 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d99b71b..b9ee4f8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -355,8 +355,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
-int mem_cgroup_scan_tasks(struct mem_cgroup *,
-			  int (*)(struct task_struct *, void *), void *);
+void mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+			   void (*fn)(struct task_struct *, void *), void *arg);
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
@@ -806,10 +806,9 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1695f38..ba52fce 100644
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
index 5a6f1b1..0452a70 100644
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
 
@@ -476,7 +456,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 /*
@@ -606,14 +585,16 @@ static void oom_reap_task(struct task_struct *tsk)
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
+	oom_reaper_th->oom_reaper_list = tsk->oom_reaper_list;
+	spin_unlock(&oom_reaper_lock);
+
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
 }
@@ -621,14 +602,12 @@ static void oom_reap_task(struct task_struct *tsk)
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct task_struct *tsk = NULL;
+		struct task_struct *tsk;
 
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
+		wait_event_freezable(oom_reaper_wait,
+				     oom_reaper_th->oom_reaper_list != NULL);
 		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
+		tsk = oom_reaper_th->oom_reaper_list;
 		spin_unlock(&oom_reaper_lock);
 
 		if (tsk)
@@ -640,15 +619,18 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
-		return;
-
-	get_task_struct(tsk);
+	struct task_struct *p = oom_reaper_th;
 
 	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
+	while (p != tsk && p->oom_reaper_list)
+		p = p->oom_reaper_list;
+	if (p == tsk) {
+		spin_unlock(&oom_reaper_lock);
+		return;
+	}
+	p->oom_reaper_list = tsk;
+	tsk->oom_reaper_list = NULL;
+	get_task_struct(tsk);
 	spin_unlock(&oom_reaper_lock);
 	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
@@ -1010,6 +992,34 @@ int unregister_oom_notifier(struct notifier_block *nb)
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
+	for (p = oom_reaper_th; p; p = p->oom_reaper_list)
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
@@ -1063,6 +1073,9 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint);
 
+	if (oom_has_pending_victims(oc))
+		return true;
+
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
@@ -1073,8 +1086,6 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	select_bad_process(oc);
-	if (oc->chosen == (void *)-1UL)
-		return true;
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen) {
 		if (is_sysrq_oom(oc) || is_memcg_oom(oc))
-- 
1.8.3.1
