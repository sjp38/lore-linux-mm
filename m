Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5F46B0262
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:17:56 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id dh6so174624890obb.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:17:56 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0141.outbound.protection.outlook.com. [157.56.112.141])
        by mx.google.com with ESMTPS id h9si4194351otb.54.2016.05.27.07.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 07:17:54 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg and global oom
Date: Fri, 27 May 2016 17:17:42 +0300
Message-ID: <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
In-Reply-To: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
 include/linux/memcontrol.h |  15 ++++
 include/linux/oom.h        |  51 -------------
 mm/memcontrol.c            | 112 ++++++++++-----------------
 mm/oom_kill.c              | 183 +++++++++++++++++++++++++++++----------------
 4 files changed, 176 insertions(+), 185 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a805474df4ab..021c49ebae21 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -324,6 +324,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
+int mem_cgroup_scan_tasks(struct mem_cgroup *,
+			  int (*)(struct task_struct *, void *), void *);
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
@@ -417,6 +419,8 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 
 void mem_cgroup_handle_over_high(void);
 
+unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg);
+
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
@@ -610,6 +614,12 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
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
@@ -640,6 +650,11 @@ mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
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
index cbc24a5fe28d..5a72853c8fc0 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -36,23 +36,6 @@ struct oom_control {
 	const int order;
 };
 
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
-};
-
 extern struct mutex oom_lock;
 
 static inline void set_current_oom_origin(void)
@@ -70,8 +53,6 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
-
 #ifdef CONFIG_MMU
 extern void try_oom_reaper(struct task_struct *tsk);
 #else
@@ -84,16 +65,6 @@ extern unsigned long oom_badness(struct task_struct *p,
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
-		struct task_struct *task, unsigned long totalpages);
-
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(struct task_struct *tsk);
@@ -107,28 +78,6 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
-static inline bool task_will_free_mem(struct task_struct *task)
-{
-	struct signal_struct *sig = task->signal;
-
-	/*
-	 * A coredumping process may sleep for an extended period in exit_mm(),
-	 * so the oom killer cannot assume that the process will promptly exit
-	 * and release memory.
-	 */
-	if (sig->flags & SIGNAL_GROUP_COREDUMP)
-		return false;
-
-	if (!(task->flags & PF_EXITING))
-		return false;
-
-	/* Make sure that the whole thread group is going down */
-	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
-		return false;
-
-	return true;
-}
-
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index eeb3b14de01a..6ad31795d231 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -944,6 +944,43 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
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
  * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
  * @zone: zone of the wanted lruvec
  * @memcg: memcg of the wanted lruvec
@@ -1236,7 +1273,7 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
 /*
  * Return the memory (and swap, if configured) limit for a memcg.
  */
-static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
+unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	unsigned long limit;
 
@@ -1263,79 +1300,12 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		try_oom_reaper(current);
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
-			switch (oom_scan_process_thread(&oc, task, totalpages)) {
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
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b3424199069b..a0a490b2c264 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -48,6 +48,16 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
+/*
+ * Types of limitations to the nodes from which allocations may occur
+ */
+enum oom_constraint {
+	CONSTRAINT_NONE,
+	CONSTRAINT_CPUSET,
+	CONSTRAINT_MEMORY_POLICY,
+	CONSTRAINT_MEMCG,
+};
+
 DEFINE_MUTEX(oom_lock);
 
 #ifdef CONFIG_NUMA
@@ -98,6 +108,28 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 }
 #endif /* CONFIG_NUMA */
 
+static bool task_will_free_mem(struct task_struct *task)
+{
+	struct signal_struct *sig = task->signal;
+
+	/*
+	 * A coredumping process may sleep for an extended period in exit_mm(),
+	 * so the oom killer cannot assume that the process will promptly exit
+	 * and release memory.
+	 */
+	if (sig->flags & SIGNAL_GROUP_COREDUMP)
+		return false;
+
+	if (!(task->flags & PF_EXITING))
+		return false;
+
+	/* Make sure that the whole thread group is going down */
+	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
+		return false;
+
+	return true;
+}
+
 /*
  * The process p may have detached its own ->mm while exiting or through
  * use_mm(), but one or more of its subthreads may still have a valid
@@ -214,7 +246,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 /*
  * Determine the type of allocation constraint.
  */
-#ifdef CONFIG_NUMA
 static enum oom_constraint constrained_alloc(struct oom_control *oc,
 					     unsigned long *totalpages)
 {
@@ -224,9 +255,17 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 	bool cpuset_limited = false;
 	int nid;
 
+	if (oc->memcg) {
+		*totalpages = mem_cgroup_get_limit(oc->memcg) ?: 1;
+		return CONSTRAINT_MEMCG;
+	}
+
 	/* Default to all available memory */
 	*totalpages = totalram_pages + total_swap_pages;
 
+	if (!IS_ENABLED(CONFIG_NUMA))
+		return CONSTRAINT_NONE;
+
 	if (!oc->zonelist)
 		return CONSTRAINT_NONE;
 	/*
@@ -264,36 +303,77 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 	}
 	return CONSTRAINT_NONE;
 }
-#else
-static enum oom_constraint constrained_alloc(struct oom_control *oc,
-					     unsigned long *totalpages)
+
+static void oom_scan_tasks(struct oom_control *oc,
+			   int (*fn)(struct task_struct *, void *), void *arg)
 {
-	*totalpages = totalram_pages + total_swap_pages;
-	return CONSTRAINT_NONE;
+	struct task_struct *p;
+
+	if (oc->memcg) {
+		mem_cgroup_scan_tasks(oc->memcg, fn, arg);
+		return;
+	}
+
+	rcu_read_lock();
+	for_each_process(p) {
+		if (fn(p, arg))
+			break;
+	}
+	rcu_read_unlock();
 }
-#endif
 
-enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-			struct task_struct *task, unsigned long totalpages)
+struct oom_evaluate_task_arg {
+	struct oom_control *oc;
+	unsigned long totalpages;
+	struct task_struct *chosen;
+	unsigned long chosen_points;
+};
+
+static int oom_evaluate_task(struct task_struct *task, void *_arg)
 {
+	struct oom_evaluate_task_arg *arg = _arg;
+	struct oom_control *oc = arg->oc;
+	unsigned long totalpages = arg->totalpages;
+	unsigned long points;
+
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
-		return OOM_SCAN_CONTINUE;
+		return 0;
 
 	/*
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
-		return OOM_SCAN_ABORT;
+	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
+		if (arg->chosen)
+			put_task_struct(arg->chosen);
+		arg->chosen = (struct task_struct *)(-1UL);
+		return 1;
+	}
 
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
+
+	points = oom_badness(task, NULL, oc->nodemask, totalpages);
+	if (!points || points < arg->chosen_points)
+		return 0;
 
-	return OOM_SCAN_OK;
+	/* Prefer thread group leaders for display purposes */
+	if (points == arg->chosen_points &&
+	    thread_group_leader(arg->chosen))
+		return 0;
+select:
+	if (arg->chosen)
+		put_task_struct(arg->chosen);
+	get_task_struct(task);
+	arg->chosen = task;
+	arg->chosen_points = points;
+	return 0;
 }
 
 /*
@@ -303,40 +383,15 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 static struct task_struct *select_bad_process(struct oom_control *oc,
 		unsigned int *ppoints, unsigned long totalpages)
 {
-	struct task_struct *p;
-	struct task_struct *chosen = NULL;
-	unsigned long chosen_points = 0;
-
-	rcu_read_lock();
-	for_each_process(p) {
-		unsigned int points;
-
-		switch (oom_scan_process_thread(oc, p, totalpages)) {
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
+	struct oom_evaluate_task_arg arg = {
+		.oc = oc,
+		.totalpages = totalpages,
+	};
 
-		chosen = p;
-		chosen_points = points;
-	}
-	if (chosen)
-		get_task_struct(chosen);
-	rcu_read_unlock();
+	oom_scan_tasks(oc, oom_evaluate_task, &arg);
 
-	*ppoints = chosen_points * 1000 / totalpages;
-	return chosen;
+	*ppoints = arg.chosen_points * 1000 / totalpages;
+	return arg.chosen;
 }
 
 /**
@@ -674,7 +729,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+static void mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
@@ -745,9 +800,8 @@ void oom_killer_enable(void)
  * Must be called while holding a reference to p, which will be released upon
  * returning.
  */
-void oom_kill_process(struct oom_control *oc, struct task_struct *p,
-		      unsigned int points, unsigned long totalpages,
-		      const char *message)
+static void oom_kill_process(struct oom_control *oc, struct task_struct *p,
+			     unsigned int points, unsigned long totalpages)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
@@ -776,7 +830,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		dump_header(oc, p);
 
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
+	       oc->memcg ? "Memory cgroup out of memory" : "Out of memory",
+	       task_pid_nr(p), p->comm, points);
 
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
@@ -873,7 +928,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint)
+static void check_panic_on_oom(struct oom_control *oc,
+			       enum oom_constraint constraint)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -928,10 +984,12 @@ bool out_of_memory(struct oom_control *oc)
 	if (oom_killer_disabled)
 		return false;
 
-	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-	if (freed > 0)
-		/* Got some memory back in the last second. */
-		return true;
+	if (!oc->memcg) {
+		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+		if (freed > 0)
+			/* Got some memory back in the last second. */
+			return true;
+	}
 
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
@@ -959,7 +1017,7 @@ bool out_of_memory(struct oom_control *oc)
 
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
-	 * NUMA) that may require different handling.
+	 * NUMA and memcg) that may require different handling.
 	 */
 	constraint = constrained_alloc(oc, &totalpages);
 	if (constraint != CONSTRAINT_MEMORY_POLICY)
@@ -970,26 +1028,25 @@ bool out_of_memory(struct oom_control *oc)
 	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages,
-				 "Out of memory (oom_kill_allocating_task)");
+		oom_kill_process(oc, current, 0, totalpages);
 		return true;
 	}
 
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!p && !is_sysrq_oom(oc)) {
+	if (!p && !is_sysrq_oom(oc) && !oc->memcg) {
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (p && p != (void *)-1UL) {
-		oom_kill_process(oc, p, points, totalpages, "Out of memory");
+		oom_kill_process(oc, p, points, totalpages);
 		/*
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.
 		 */
 		schedule_timeout_killable(1);
 	}
-	return true;
+	return !!p;
 }
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
