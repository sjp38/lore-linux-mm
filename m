Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF516B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 12:40:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g8so196688661itb.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 09:40:08 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0123.outbound.protection.outlook.com. [104.47.2.123])
        by mx.google.com with ESMTPS id l17si11300173otd.119.2016.06.27.09.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 09:40:06 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2] mm: oom: deduplicate victim selection code for memcg and global oom
Date: Mon, 27 Jun 2016 19:39:54 +0300
Message-ID: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When selecting an oom victim, we use the same heuristic for both memory
cgroup and global oom. The only difference is the scope of tasks to
select the victim from. So we could just export an iterator over all
memcg tasks and keep all oom related logic in oom_kill.c, but instead we
duplicate pieces of it in memcontrol.c reusing some initially private
functions of oom_kill.c in order to not duplicate all of it. That looks
ugly and error prone, because any modification of select_bad_process
should also be propagated to mem_cgroup_out_of_memory.

Let's rework this as follows: keep all oom heuristic related code
private to oom_kill.c and make oom_kill.c use exported memcg functions
when it's really necessary (like in case of iterating over memcg tasks).

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
Changes in v2:
 - rebase on top of v4.7-rc4-mmotm-2016-06-24-15-53
 - ignore sysctl_oom_kill_allocating_task in case of memcg oom

 include/linux/memcontrol.h |  15 ++++
 include/linux/oom.h        |  43 +---------
 mm/memcontrol.c            | 114 ++++++++++----------------
 mm/oom_kill.c              | 200 ++++++++++++++++++++++++---------------------
 4 files changed, 167 insertions(+), 205 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 104efa6874db..63b880ab8739 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -374,6 +374,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
+int mem_cgroup_scan_tasks(struct mem_cgroup *,
+			  int (*)(struct task_struct *, void *), void *);
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
@@ -454,6 +456,8 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 
 void mem_cgroup_handle_over_high(void);
 
+unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg);
+
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
@@ -647,6 +651,12 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
 {
 }
 
+static inline int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+		int (*fn)(struct task_struct *, void *), void *arg)
+{
+	return 0;
+}
+
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
 	return 0;
@@ -677,6 +687,11 @@ mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 	return 0;
 }
 
+static inline unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457ee3a8..17946e5121b6 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -34,23 +34,11 @@ struct oom_control {
 	 * for display purposes.
 	 */
 	const int order;
-};
 
-/*
- * Types of limitations to the nodes from which allocations may occur
- */
-enum oom_constraint {
-	CONSTRAINT_NONE,
-	CONSTRAINT_CPUSET,
-	CONSTRAINT_MEMORY_POLICY,
-	CONSTRAINT_MEMCG,
-};
-
-enum oom_scan_t {
-	OOM_SCAN_OK,		/* scan thread and find its badness */
-	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
-	OOM_SCAN_ABORT,		/* abort the iteration and return */
-	OOM_SCAN_SELECT,	/* always select this thread first */
+	/* Used by oom implementation, do not set */
+	unsigned long totalpages;
+	struct task_struct *chosen;
+	unsigned long chosen_points;
 };
 
 extern struct mutex oom_lock;
@@ -70,30 +58,10 @@ static inline bool oom_task_origin(const struct task_struct *p)
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
-
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
 
-extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
-			     unsigned int points, unsigned long totalpages,
-			     const char *message);
-
-extern void check_panic_on_oom(struct oom_control *oc,
-			       enum oom_constraint constraint);
-
-extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-					       struct task_struct *task);
-
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(struct task_struct *tsk);
@@ -101,14 +69,11 @@ extern void exit_oom_victim(struct task_struct *tsk);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
-extern bool oom_killer_disabled;
 extern bool oom_killer_disable(void);
 extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
-bool task_will_free_mem(struct task_struct *task);
-
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40dfca3ef4bb..950e217ec6f7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -935,6 +935,43 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
 /**
+ * mem_cgroup_scan_tasks - iterate over tasks of a memory cgroup hierarchy
+ * @memcg: hierarchy root
+ * @fn: function to call for each task
+ * @arg: argument passed to @fn
+ *
+ * This function iterates over tasks attached to @memcg or to any of its
+ * descendants and calls @fn for each task. If @fn returns a non-zero
+ * value, the function breaks the iteration loop and returns the value.
+ * Otherwise, it will iterate over all tasks and return 0.
+ *
+ * This function must not be called for the root memory cgroup.
+ */
+int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+			  int (*fn)(struct task_struct *, void *), void *arg)
+{
+	struct mem_cgroup *iter;
+	int ret = 0;
+
+	BUG_ON(memcg == root_mem_cgroup);
+
+	for_each_mem_cgroup_tree(iter, memcg) {
+		struct css_task_iter it;
+		struct task_struct *task;
+
+		css_task_iter_start(&iter->css, &it);
+		while (!ret && (task = css_task_iter_next(&it)))
+			ret = fn(task, arg);
+		css_task_iter_end(&it);
+		if (ret) {
+			mem_cgroup_iter_break(memcg, iter);
+			break;
+		}
+	}
+	return ret;
+}
+
+/**
  * mem_cgroup_page_lruvec - return lruvec for isolating/putting an LRU page
  * @page: the page
  * @zone: zone of the page
@@ -1194,7 +1231,7 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
 /*
  * Return the memory (and swap, if configured) limit for a memcg.
  */
-static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
+unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	unsigned long limit;
 
@@ -1221,79 +1258,12 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-	struct mem_cgroup *iter;
-	unsigned long chosen_points = 0;
-	unsigned long totalpages;
-	unsigned int points = 0;
-	struct task_struct *chosen = NULL;
+	bool ret;
 
 	mutex_lock(&oom_lock);
-
-	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 */
-	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
-		goto unlock;
-	}
-
-	check_panic_on_oom(&oc, CONSTRAINT_MEMCG);
-	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
-	for_each_mem_cgroup_tree(iter, memcg) {
-		struct css_task_iter it;
-		struct task_struct *task;
-
-		css_task_iter_start(&iter->css, &it);
-		while ((task = css_task_iter_next(&it))) {
-			switch (oom_scan_process_thread(&oc, task)) {
-			case OOM_SCAN_SELECT:
-				if (chosen)
-					put_task_struct(chosen);
-				chosen = task;
-				chosen_points = ULONG_MAX;
-				get_task_struct(chosen);
-				/* fall through */
-			case OOM_SCAN_CONTINUE:
-				continue;
-			case OOM_SCAN_ABORT:
-				css_task_iter_end(&it);
-				mem_cgroup_iter_break(memcg, iter);
-				if (chosen)
-					put_task_struct(chosen);
-				/* Set a dummy value to return "true". */
-				chosen = (void *) 1;
-				goto unlock;
-			case OOM_SCAN_OK:
-				break;
-			};
-			points = oom_badness(task, memcg, NULL, totalpages);
-			if (!points || points < chosen_points)
-				continue;
-			/* Prefer thread group leaders for display purposes */
-			if (points == chosen_points &&
-			    thread_group_leader(chosen))
-				continue;
-
-			if (chosen)
-				put_task_struct(chosen);
-			chosen = task;
-			chosen_points = points;
-			get_task_struct(chosen);
-		}
-		css_task_iter_end(&it);
-	}
-
-	if (chosen) {
-		points = chosen_points * 1000 / totalpages;
-		oom_kill_process(&oc, chosen, points, totalpages,
-				 "Memory cgroup out of memory");
-	}
-unlock:
+	ret = out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
-	return chosen;
+	return ret;
 }
 
 #if MAX_NUMNODES > 1
@@ -1616,7 +1586,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
 	if (!memcg)
 		return false;
 
-	if (!handle || oom_killer_disabled)
+	if (!handle)
 		goto cleanup;
 
 	owait.memcg = memcg;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f744daa6..b6a7db3d2391 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -132,6 +132,11 @@ static inline bool is_sysrq_oom(struct oom_control *oc)
 	return oc->order == -1;
 }
 
+static inline bool is_memcg_oom(struct oom_control *oc)
+{
+	return oc->memcg != NULL;
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -213,12 +218,17 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	return points > 0 ? points : 1;
 }
 
+enum oom_constraint {
+	CONSTRAINT_NONE,
+	CONSTRAINT_CPUSET,
+	CONSTRAINT_MEMORY_POLICY,
+	CONSTRAINT_MEMCG,
+};
+
 /*
  * Determine the type of allocation constraint.
  */
-#ifdef CONFIG_NUMA
-static enum oom_constraint constrained_alloc(struct oom_control *oc,
-					     unsigned long *totalpages)
+static enum oom_constraint constrained_alloc(struct oom_control *oc)
 {
 	struct zone *zone;
 	struct zoneref *z;
@@ -226,8 +236,16 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 	bool cpuset_limited = false;
 	int nid;
 
+	if (is_memcg_oom(oc)) {
+		oc->totalpages = mem_cgroup_get_limit(oc->memcg) ?: 1;
+		return CONSTRAINT_MEMCG;
+	}
+
 	/* Default to all available memory */
-	*totalpages = totalram_pages + total_swap_pages;
+	oc->totalpages = totalram_pages + total_swap_pages;
+
+	if (!IS_ENABLED(CONFIG_NUMA))
+		return CONSTRAINT_NONE;
 
 	if (!oc->zonelist)
 		return CONSTRAINT_NONE;
@@ -246,9 +264,9 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 	 */
 	if (oc->nodemask &&
 	    !nodes_subset(node_states[N_MEMORY], *oc->nodemask)) {
-		*totalpages = total_swap_pages;
+		oc->totalpages = total_swap_pages;
 		for_each_node_mask(nid, *oc->nodemask)
-			*totalpages += node_spanned_pages(nid);
+			oc->totalpages += node_spanned_pages(nid);
 		return CONSTRAINT_MEMORY_POLICY;
 	}
 
@@ -259,27 +277,21 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 			cpuset_limited = true;
 
 	if (cpuset_limited) {
-		*totalpages = total_swap_pages;
+		oc->totalpages = total_swap_pages;
 		for_each_node_mask(nid, cpuset_current_mems_allowed)
-			*totalpages += node_spanned_pages(nid);
+			oc->totalpages += node_spanned_pages(nid);
 		return CONSTRAINT_CPUSET;
 	}
 	return CONSTRAINT_NONE;
 }
-#else
-static enum oom_constraint constrained_alloc(struct oom_control *oc,
-					     unsigned long *totalpages)
-{
-	*totalpages = totalram_pages + total_swap_pages;
-	return CONSTRAINT_NONE;
-}
-#endif
 
-enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-					struct task_struct *task)
+static int oom_evaluate_task(struct task_struct *task, void *arg)
 {
+	struct oom_control *oc = arg;
+	unsigned long points;
+
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
-		return OOM_SCAN_CONTINUE;
+		goto next;
 
 	/*
 	 * This task already has access to memory reserves and is being killed.
@@ -289,68 +301,67 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 */
 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
 		struct task_struct *p = find_lock_task_mm(task);
-		enum oom_scan_t ret = OOM_SCAN_ABORT;
+		bool reaped = false;
 
 		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
+			reaped = test_bit(MMF_OOM_REAPED, &p->mm->flags);
 			task_unlock(p);
 		}
-
-		return ret;
+		if (reaped)
+			goto next;
+		goto abort;
 	}
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
-	if (oom_task_origin(task))
-		return OOM_SCAN_SELECT;
+	if (oom_task_origin(task)) {
+		points = ULONG_MAX;
+		goto select;
+	}
 
-	return OOM_SCAN_OK;
+	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
+	if (!points || points < oc->chosen_points)
+		goto next;
+
+	/* Prefer thread group leaders for display purposes */
+	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
+		goto next;
+select:
+	if (oc->chosen)
+		put_task_struct(oc->chosen);
+	get_task_struct(task);
+	oc->chosen = task;
+	oc->chosen_points = points;
+next:
+	return 0;
+abort:
+	if (oc->chosen)
+		put_task_struct(oc->chosen);
+	oc->chosen = (void *)-1UL;
+	return 1;
 }
 
 /*
- * Simple selection loop. We chose the process with the highest
- * number of 'points'.  Returns -1 on scan abort.
+ * Simple selection loop. We choose the process with the highest number of
+ * 'points'. In case scan was aborted, oc->chosen is set to -1.
  */
-static struct task_struct *select_bad_process(struct oom_control *oc,
-		unsigned int *ppoints, unsigned long totalpages)
+static void select_bad_process(struct oom_control *oc)
 {
-	struct task_struct *p;
-	struct task_struct *chosen = NULL;
-	unsigned long chosen_points = 0;
-
-	rcu_read_lock();
-	for_each_process(p) {
-		unsigned int points;
-
-		switch (oom_scan_process_thread(oc, p)) {
-		case OOM_SCAN_SELECT:
-			chosen = p;
-			chosen_points = ULONG_MAX;
-			/* fall through */
-		case OOM_SCAN_CONTINUE:
-			continue;
-		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
-		case OOM_SCAN_OK:
-			break;
-		};
-		points = oom_badness(p, NULL, oc->nodemask, totalpages);
-		if (!points || points < chosen_points)
-			continue;
+	if (is_memcg_oom(oc))
+		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
+	else {
+		struct task_struct *p;
 
-		chosen = p;
-		chosen_points = points;
+		rcu_read_lock();
+		for_each_process(p)
+			if (oom_evaluate_task(p, oc))
+				break;
+		rcu_read_unlock();
 	}
-	if (chosen)
-		get_task_struct(chosen);
-	rcu_read_unlock();
 
-	*ppoints = chosen_points * 1000 / totalpages;
-	return chosen;
+	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
 }
 
 /**
@@ -419,7 +430,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 static atomic_t oom_victims = ATOMIC_INIT(0);
 static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
-bool oom_killer_disabled __read_mostly;
+static bool oom_killer_disabled __read_mostly;
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
@@ -627,7 +638,7 @@ static int oom_reaper(void *unused)
 	return 0;
 }
 
-void wake_oom_reaper(struct task_struct *tsk)
+static void wake_oom_reaper(struct task_struct *tsk)
 {
 	if (!oom_reaper_th)
 		return;
@@ -656,7 +667,11 @@ static int __init oom_init(void)
 	return 0;
 }
 subsys_initcall(oom_init)
-#endif
+#else
+static inline void wake_oom_reaper(struct task_struct *tsk)
+{
+}
+#endif /* CONFIG_MMU */
 
 /**
  * mark_oom_victim - mark the given task as OOM victim
@@ -665,7 +680,7 @@ subsys_initcall(oom_init)
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+static void mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
@@ -758,7 +773,7 @@ static inline bool __task_will_free_mem(struct task_struct *task)
  * release its address space. This means that all threads and processes
  * sharing the same mm have to be killed or exiting.
  */
-bool task_will_free_mem(struct task_struct *task)
+static bool task_will_free_mem(struct task_struct *task)
 {
 	struct mm_struct *mm;
 	struct task_struct *p;
@@ -817,14 +832,10 @@ bool task_will_free_mem(struct task_struct *task)
 	return ret;
 }
 
-/*
- * Must be called while holding a reference to p, which will be released upon
- * returning.
- */
-void oom_kill_process(struct oom_control *oc, struct task_struct *p,
-		      unsigned int points, unsigned long totalpages,
-		      const char *message)
+static void oom_kill_process(struct oom_control *oc, const char *message)
 {
+	struct task_struct *p = oc->chosen;
+	unsigned int points = oc->chosen_points;
 	struct task_struct *victim = p;
 	struct task_struct *child;
 	struct task_struct *t;
@@ -868,7 +879,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
 			child_points = oom_badness(child,
-					oc->memcg, oc->nodemask, totalpages);
+				oc->memcg, oc->nodemask, oc->totalpages);
 			if (child_points > victim_points) {
 				put_task_struct(victim);
 				victim = child;
@@ -950,7 +961,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint)
+static void check_panic_on_oom(struct oom_control *oc,
+			       enum oom_constraint constraint)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -996,19 +1008,18 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  */
 bool out_of_memory(struct oom_control *oc)
 {
-	struct task_struct *p;
-	unsigned long totalpages;
 	unsigned long freed = 0;
-	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
 		return false;
 
-	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-	if (freed > 0)
-		/* Got some memory back in the last second. */
-		return true;
+	if (!is_memcg_oom(oc)) {
+		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+		if (freed > 0)
+			/* Got some memory back in the last second. */
+			return true;
+	}
 
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
@@ -1035,37 +1046,38 @@ bool out_of_memory(struct oom_control *oc)
 
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
-	 * NUMA) that may require different handling.
+	 * NUMA and memcg) that may require different handling.
 	 */
-	constraint = constrained_alloc(oc, &totalpages);
+	constraint = constrained_alloc(oc);
 	if (constraint != CONSTRAINT_MEMORY_POLICY)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint);
 
-	if (sysctl_oom_kill_allocating_task && current->mm &&
-	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
+	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
+	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages,
-				 "Out of memory (oom_kill_allocating_task)");
+		oc->chosen = current;
+		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
 		return true;
 	}
 
-	p = select_bad_process(oc, &points, totalpages);
+	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!p && !is_sysrq_oom(oc)) {
+	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
-		oom_kill_process(oc, p, points, totalpages, "Out of memory");
+	if (oc->chosen && oc->chosen != (void *)-1UL) {
+		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
+				 "Memory cgroup out of memory");
 		/*
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.
 		 */
 		schedule_timeout_killable(1);
 	}
-	return true;
+	return !!oc->chosen;
 }
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
