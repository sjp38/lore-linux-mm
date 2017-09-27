Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 538D16B0266
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:11:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x78so23148716pff.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 06:11:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y123si1102905pgy.24.2017.09.27.06.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 06:10:59 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v9 3/5] mm, oom: cgroup-aware OOM killer
Date: Wed, 27 Sep 2017 14:09:34 +0100
Message-ID: <20170927130936.8601-4-guro@fb.com>
In-Reply-To: <20170927130936.8601-1-guro@fb.com>
References: <20170927130936.8601-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Traditionally, the OOM killer is operating on a process level.
Under oom conditions, it finds a process with the highest oom score
and kills it.

This behavior doesn't suit well the system with many running
containers:

1) There is no fairness between containers. A small container with
few large processes will be chosen over a large one with huge
number of small processes.

2) Containers often do not expect that some random process inside
will be killed. In many cases much safer behavior is to kill
all tasks in the container. Traditionally, this was implemented
in userspace, but doing it in the kernel has some advantages,
especially in a case of a system-wide OOM.

To address these issues, the cgroup-aware OOM killer is introduced.

Under OOM conditions, it looks for the biggest memory consumer:
a leaf memory cgroup or a memory cgroup with the memory.oom_group
option set. Then it kills either a task with the biggest memory
footprint, either all belonging tasks, if memory.oom_group is set.
If a cgroup has memory.oom_group set, all descendant cgroups
implicitly inherit the memory.oom_group setting.

Tasks with oom_score_adj set to -1000 are considered as unkillable.

The root cgroup is treated as a leaf memory cgroup, so it's score
is compared with other leaf and oom_group memory cgroups.
The oom_group option is not supported for the root cgroup.
Due to memcg statistics implementation a special algorithm
is used for estimating root cgroup oom_score: we define it
as maximum oom_score of the belonging tasks.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/memcontrol.h |  38 ++++++++
 include/linux/oom.h        |  12 ++-
 mm/memcontrol.c            | 225 +++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c              |  79 +++++++++++++---
 4 files changed, 339 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 69966c461d1c..0289dc3d7434 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -35,6 +35,7 @@ struct mem_cgroup;
 struct page;
 struct mm_struct;
 struct kmem_cache;
+struct oom_control;
 
 /* Cgroup-specific page state, on top of universal node page state */
 enum memcg_stat_item {
@@ -199,6 +200,12 @@ struct mem_cgroup {
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
+	/* kill all tasks in the subtree in case of OOM */
+	bool oom_group;
+
+	/* cached OOM score */
+	long oom_score;
+
 	/* handle for "memory.events" */
 	struct cgroup_file events_file;
 
@@ -342,6 +349,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+	css_put(&memcg->css);
+}
+
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -480,6 +492,18 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 
 bool mem_cgroup_oom_synchronize(bool wait);
 
+bool mem_cgroup_select_oom_victim(struct oom_control *oc);
+
+static inline bool mem_cgroup_oom_group(struct mem_cgroup *memcg)
+{
+	do {
+		if (memcg->oom_group)
+			return true;
+	} while ((memcg = parent_mem_cgroup(memcg)));
+
+	return false;
+}
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
@@ -744,6 +768,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+}
+
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
@@ -936,6 +964,16 @@ static inline
 void count_memcg_event_mm(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline bool mem_cgroup_select_oom_victim(struct oom_control *oc)
+{
+	return false;
+}
+
+static inline bool mem_cgroup_oom_group(struct mem_cgroup *memcg)
+{
+	return false;
+}
 #endif /* CONFIG_MEMCG */
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 76aac4ce39bc..ca78e2d5956e 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -9,6 +9,13 @@
 #include <linux/sched/coredump.h> /* MMF_* */
 #include <linux/mm.h> /* VM_FAULT* */
 
+
+/*
+ * Special value returned by victim selection functions to indicate
+ * that are inflight OOM victims.
+ */
+#define INFLIGHT_VICTIM ((void *)-1UL)
+
 struct zonelist;
 struct notifier_block;
 struct mem_cgroup;
@@ -39,7 +46,8 @@ struct oom_control {
 
 	/* Used by oom implementation, do not set */
 	unsigned long totalpages;
-	struct task_struct *chosen;
+	struct task_struct *chosen_task;
+	struct mem_cgroup *chosen_memcg;
 	unsigned long chosen_points;
 };
 
@@ -101,6 +109,8 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
+extern int oom_evaluate_task(struct task_struct *task, void *arg);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fa1a5120ce3f..353bb590713e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2670,6 +2670,198 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 	return ret;
 }
 
+static long memcg_oom_badness(struct mem_cgroup *memcg,
+			      const nodemask_t *nodemask,
+			      unsigned long totalpages)
+{
+	long points = 0;
+	int nid;
+	pg_data_t *pgdat;
+
+	/*
+	 * We don't have necessary stats for the root memcg,
+	 * so we define it's oom_score as the maximum oom_score
+	 * of the belonging tasks.
+	 */
+	if (memcg == root_mem_cgroup) {
+		struct css_task_iter it;
+		struct task_struct *task;
+		long score, max_score = 0;
+
+		css_task_iter_start(&memcg->css, 0, &it);
+		while ((task = css_task_iter_next(&it))) {
+			score = oom_badness(task, memcg, nodemask,
+					    totalpages);
+			if (score > max_score)
+				max_score = score;
+		}
+		css_task_iter_end(&it);
+
+		return max_score;
+	}
+
+	for_each_node_state(nid, N_MEMORY) {
+		if (nodemask && !node_isset(nid, *nodemask))
+			continue;
+
+		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
+				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
+
+		pgdat = NODE_DATA(nid);
+		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
+					    NR_SLAB_UNRECLAIMABLE);
+	}
+
+	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
+		(PAGE_SIZE / 1024);
+	points += memcg_page_state(memcg, MEMCG_SOCK);
+	points += memcg_page_state(memcg, MEMCG_SWAP);
+
+	return points;
+}
+
+/*
+ * Checks if the given memcg is a valid OOM victim and returns a number,
+ * which means the folowing:
+ *   -1: there are inflight OOM victim tasks, belonging to the memcg
+ *    0: memcg is not eligible, e.g. all belonging tasks are protected
+ *       by oom_score_adj set to OOM_SCORE_ADJ_MIN
+ *   >0: memcg is eligible, and the returned value is an estimation
+ *       of the memory footprint
+ */
+static long oom_evaluate_memcg(struct mem_cgroup *memcg,
+			       const nodemask_t *nodemask,
+			       unsigned long totalpages)
+{
+	struct css_task_iter it;
+	struct task_struct *task;
+	int eligible = 0;
+
+	/*
+	 * Memcg is OOM eligible if there are OOM killable tasks inside.
+	 *
+	 * We treat tasks with oom_score_adj set to OOM_SCORE_ADJ_MIN
+	 * as unkillable.
+	 *
+	 * If there are inflight OOM victim tasks inside the memcg,
+	 * we return -1.
+	 */
+	css_task_iter_start(&memcg->css, 0, &it);
+	while ((task = css_task_iter_next(&it))) {
+		if (!eligible &&
+		    task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
+			eligible = 1;
+
+		if (tsk_is_oom_victim(task) &&
+		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
+			eligible = -1;
+			break;
+		}
+	}
+	css_task_iter_end(&it);
+
+	if (eligible <= 0)
+		return eligible;
+
+	return memcg_oom_badness(memcg, nodemask, totalpages);
+}
+
+static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
+{
+	struct mem_cgroup *iter, *parent;
+
+	/*
+	 * If OOM is memcg-wide, and the memcg or it's ancestor has
+	 * the oom_group flag, simple select the memcg as a victim.
+	 */
+	if (oc->memcg && mem_cgroup_oom_group(oc->memcg)) {
+		oc->chosen_memcg = oc->memcg;
+		css_get(&oc->chosen_memcg->css);
+		oc->chosen_points = oc->memcg->oom_score;
+		return;
+	}
+
+	oc->chosen_memcg = NULL;
+
+	/*
+	 * The oom_score is calculated for leaf memcgs and propagated upwards
+	 * by the tree.
+	 *
+	 * for_each_mem_cgroup_tree() walks the tree in pre-order,
+	 * so we simple reset oom_score for non-lead cgroups before
+	 * starting accumulating an actual value from underlying sub-tree.
+	 *
+	 * Root memcg is treated as a leaf memcg.
+	 */
+	rcu_read_lock();
+	for_each_mem_cgroup_tree(iter, root) {
+		if (memcg_has_children(iter) && iter != root_mem_cgroup) {
+			iter->oom_score = 0;
+			continue;
+		}
+
+		iter->oom_score = oom_evaluate_memcg(iter, oc->nodemask,
+						     oc->totalpages);
+
+		/*
+		 * Ignore empty and non-eligible memory cgroups.
+		 */
+		if (iter->oom_score == 0)
+			continue;
+
+		/*
+		 * If there are inflight OOM victims, we don't need to look
+		 * further for new victims.
+		 */
+		if (iter->oom_score == -1) {
+			oc->chosen_memcg = INFLIGHT_VICTIM;
+			mem_cgroup_iter_break(root, iter);
+			break;
+		}
+
+		if (iter->oom_score > oc->chosen_points) {
+			oc->chosen_memcg = iter;
+			oc->chosen_points = iter->oom_score;
+		}
+
+		for (parent = parent_mem_cgroup(iter); parent && parent != root;
+		     parent = parent_mem_cgroup(parent)) {
+			parent->oom_score += iter->oom_score;
+
+			if (mem_cgroup_oom_group(parent) &&
+			    parent->oom_score > oc->chosen_points) {
+				oc->chosen_memcg = parent;
+				oc->chosen_points = parent->oom_score;
+			}
+		}
+	}
+
+	if (oc->chosen_memcg && oc->chosen_memcg != INFLIGHT_VICTIM)
+		css_get(&oc->chosen_memcg->css);
+
+	rcu_read_unlock();
+}
+
+bool mem_cgroup_select_oom_victim(struct oom_control *oc)
+{
+	struct mem_cgroup *root;
+
+	if (mem_cgroup_disabled())
+		return false;
+
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		return false;
+
+	if (oc->memcg)
+		root = oc->memcg;
+	else
+		root = root_mem_cgroup;
+
+	select_victim_memcg(root, oc);
+
+	return oc->chosen_memcg;
+}
+
 /*
  * Reclaims as many pages from the given memcg as possible.
  *
@@ -5267,6 +5459,33 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static int memory_oom_group_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	bool oom_group = memcg->oom_group;
+
+	seq_printf(m, "%d\n", oom_group);
+
+	return 0;
+}
+
+static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
+					       char *buf, size_t nbytes,
+					       loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	int oom_group;
+	int err;
+
+	err = kstrtoint(strstrip(buf), 0, &oom_group);
+	if (err)
+		return err;
+
+	memcg->oom_group = oom_group;
+
+	return nbytes;
+}
+
 static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -5387,6 +5606,12 @@ static struct cftype memory_files[] = {
 		.write = memory_max_write,
 	},
 	{
+		.name = "oom_group",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_oom_group_show,
+		.write = memory_oom_group_write,
+	},
+	{
 		.name = "events",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.file_offset = offsetof(struct mem_cgroup, events_file),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9d65a173e0f6..c69e5e397407 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -289,7 +289,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
-static int oom_evaluate_task(struct task_struct *task, void *arg)
+int oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
 	unsigned long points;
@@ -323,26 +323,26 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto next;
 
 	/* Prefer thread group leaders for display purposes */
-	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
+	if (points == oc->chosen_points && thread_group_leader(oc->chosen_task))
 		goto next;
 select:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
+	if (oc->chosen_task)
+		put_task_struct(oc->chosen_task);
 	get_task_struct(task);
-	oc->chosen = task;
+	oc->chosen_task = task;
 	oc->chosen_points = points;
 next:
 	return 0;
 abort:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
-	oc->chosen = (void *)-1UL;
+	if (oc->chosen_task)
+		put_task_struct(oc->chosen_task);
+	oc->chosen_task = INFLIGHT_VICTIM;
 	return 1;
 }
 
 /*
  * Simple selection loop. We choose the process with the highest number of
- * 'points'. In case scan was aborted, oc->chosen is set to -1.
+ * 'points'. In case scan was aborted, oc->chosen_task is set to -1.
  */
 static void select_bad_process(struct oom_control *oc)
 {
@@ -826,6 +826,12 @@ static void __oom_kill_process(struct task_struct *victim)
 	struct mm_struct *mm;
 	bool can_oom_reap = true;
 
+	if (is_global_init(victim) || (victim->flags & PF_KTHREAD) ||
+	    victim->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+		put_task_struct(victim);
+		return;
+	}
+
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
@@ -901,7 +907,7 @@ static void __oom_kill_process(struct task_struct *victim)
 
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
-	struct task_struct *p = oc->chosen;
+	struct task_struct *p = oc->chosen_task;
 	unsigned int points = oc->chosen_points;
 	struct task_struct *victim = p;
 	struct task_struct *child;
@@ -962,6 +968,48 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	__oom_kill_process(victim);
 }
 
+static int oom_kill_memcg_member(struct task_struct *task, void *unused)
+{
+	if (!tsk_is_oom_victim(task)) {
+		get_task_struct(task);
+		__oom_kill_process(task);
+	}
+	return 0;
+}
+
+static bool oom_kill_memcg_victim(struct oom_control *oc)
+{
+	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
+
+	if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
+		return oc->chosen_memcg;
+
+	/* Always begin with the task with the biggest memory footprint */
+	oc->chosen_points = 0;
+	oc->chosen_task = NULL;
+	mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
+
+	if (oc->chosen_task == NULL || oc->chosen_task == INFLIGHT_VICTIM)
+		goto out;
+
+	if (__ratelimit(&oom_rs))
+		dump_header(oc, oc->chosen_task);
+
+	__oom_kill_process(oc->chosen_task);
+
+	/* If oom_group flag is set, kill all belonging tasks */
+	if (mem_cgroup_oom_group(oc->chosen_memcg))
+		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_memcg_member,
+				      NULL);
+
+	schedule_timeout_killable(1);
+
+out:
+	mem_cgroup_put(oc->chosen_memcg);
+	return oc->chosen_task;
+}
+
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
@@ -1058,18 +1106,21 @@ bool out_of_memory(struct oom_control *oc)
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
-		oc->chosen = current;
+		oc->chosen_task = current;
 		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
 		return true;
 	}
 
+	if (mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc))
+		return true;
+
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+	if (!oc->chosen_task && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL) {
+	if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM) {
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
 		/*
@@ -1078,7 +1129,7 @@ bool out_of_memory(struct oom_control *oc)
 		 */
 		schedule_timeout_killable(1);
 	}
-	return !!oc->chosen;
+	return !!oc->chosen_task;
 }
 
 /*
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
