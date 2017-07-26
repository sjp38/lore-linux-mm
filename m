Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9926D6B02FA
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:28:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q50so31821626wrb.14
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:28:12 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y15si17454548wry.67.2017.07.26.06.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 06:28:11 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v4 2/4] mm, oom: cgroup-aware OOM killer
Date: Wed, 26 Jul 2017 14:27:16 +0100
Message-ID: <20170726132718.14806-3-guro@fb.com>
In-Reply-To: <20170726132718.14806-1-guro@fb.com>
References: <20170726132718.14806-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

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

3) Per-process oom_score_adj affects global OOM, so it's a breache
in the isolation.

To address these issues, cgroup-aware OOM killer is introduced.

Under OOM conditions, it tries to find the biggest memory consumer,
and free memory by killing corresponding task(s). The difference
the "traditional" OOM killer is that it can treat memory cgroups
as memory consumers as well as single processes.

By default, it will look for the biggest leaf cgroup, and kill
the largest task inside.

But a user can change this behavior by enabling the per-cgroup
oom_kill_all_tasks option. If set, it causes the OOM killer treat
the whole cgroup as an indivisible memory consumer. In case if it's
selected as on OOM victim, all belonging tasks will be killed.

Tasks in the root cgroup are treated as independent memory consumers,
and are compared with other memory consumers (e.g. leaf cgroups).
The root cgroup doesn't support the oom_kill_all_tasks feature.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/memcontrol.h |  23 +++++
 include/linux/oom.h        |   3 +
 mm/memcontrol.c            | 208 +++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c              | 172 ++++++++++++++++++++++++-------------
 4 files changed, 349 insertions(+), 57 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3914e3dd6168..b21bbb0edc72 100644
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
+	bool oom_kill_all_tasks;
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
 
@@ -480,6 +492,8 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 
 bool mem_cgroup_oom_synchronize(bool wait);
 
+bool mem_cgroup_select_oom_victim(struct oom_control *oc);
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
@@ -739,6 +753,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+}
+
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
@@ -926,6 +944,11 @@ static inline
 void count_memcg_event_mm(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline bool mem_cgroup_select_oom_victim(struct oom_control *oc)
+{
+	return false;
+}
 #endif /* CONFIG_MEMCG */
 
 static inline void __inc_memcg_state(struct mem_cgroup *memcg,
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8a266e2be5a6..b7ec3bd441be 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -39,6 +39,7 @@ struct oom_control {
 	unsigned long totalpages;
 	struct task_struct *chosen;
 	unsigned long chosen_points;
+	struct mem_cgroup *chosen_memcg;
 };
 
 extern struct mutex oom_lock;
@@ -79,6 +80,8 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
+extern int oom_evaluate_task(struct task_struct *task, void *arg);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9085e55eb69f..ba72d1cf73d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2625,6 +2625,181 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 	return ret;
 }
 
+static long memcg_oom_badness(struct mem_cgroup *memcg,
+			      const nodemask_t *nodemask)
+{
+	long points = 0;
+	int nid;
+
+	for_each_node_state(nid, N_MEMORY) {
+		if (nodemask && !node_isset(nid, *nodemask))
+			continue;
+
+		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
+				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
+	}
+
+	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
+		(PAGE_SIZE / 1024);
+	points += memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE);
+	points += memcg_page_state(memcg, MEMCG_SOCK);
+	points += memcg_page_state(memcg, MEMCG_SWAP);
+
+	return points;
+}
+
+static long oom_evaluate_memcg(struct mem_cgroup *memcg,
+			       const nodemask_t *nodemask)
+{
+	struct css_task_iter it;
+	struct task_struct *task;
+	int elegible = 0;
+
+	css_task_iter_start(&memcg->css, 0, &it);
+	while ((task = css_task_iter_next(&it))) {
+		/*
+		 * If there are no tasks, or all tasks have oom_score_adj set
+		 * to OOM_SCORE_ADJ_MIN and oom_kill_all_tasks is not set,
+		 * don't select this memory cgroup.
+		 */
+		if (!elegible &&
+		    (memcg->oom_kill_all_tasks ||
+		     task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN))
+			elegible = 1;
+
+		/*
+		 * If there are previously selected OOM victims,
+		 * abort memcg selection.
+		 */
+		if (tsk_is_oom_victim(task) &&
+		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
+			elegible = -1;
+			break;
+		}
+	}
+	css_task_iter_end(&it);
+
+	return elegible > 0 ? memcg_oom_badness(memcg, nodemask) : elegible;
+}
+
+static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
+{
+	struct mem_cgroup *iter, *parent;
+
+	for_each_mem_cgroup_tree(iter, root) {
+		if (memcg_has_children(iter)) {
+			iter->oom_score = 0;
+			continue;
+		}
+
+		iter->oom_score = oom_evaluate_memcg(iter, oc->nodemask);
+		if (iter->oom_score == -1) {
+			oc->chosen_memcg = (void *)-1UL;
+			mem_cgroup_iter_break(root, iter);
+			return;
+		}
+
+		if (!iter->oom_score)
+			continue;
+
+		for (parent = parent_mem_cgroup(iter); parent && parent != root;
+		     parent = parent_mem_cgroup(parent))
+			parent->oom_score += iter->oom_score;
+	}
+
+	for (;;) {
+		struct cgroup_subsys_state *css;
+		struct mem_cgroup *memcg = NULL;
+		long score = LONG_MIN;
+
+		css_for_each_child(css, &root->css) {
+			struct mem_cgroup *iter = mem_cgroup_from_css(css);
+
+			if (iter->oom_score > score) {
+				memcg = iter;
+				score = iter->oom_score;
+			}
+		}
+
+		if (!memcg) {
+			if (oc->memcg && root == oc->memcg) {
+				oc->chosen_memcg = oc->memcg;
+				css_get(&oc->chosen_memcg->css);
+				oc->chosen_points = oc->memcg->oom_score;
+			}
+			break;
+		}
+
+		if (memcg->oom_kill_all_tasks || !memcg_has_children(memcg)) {
+			oc->chosen_memcg = memcg;
+			css_get(&oc->chosen_memcg->css);
+			oc->chosen_points = score;
+			break;
+		}
+
+		root = memcg;
+	}
+}
+
+static void select_victim_root_cgroup_task(struct oom_control *oc)
+{
+	struct css_task_iter it;
+	struct task_struct *task;
+	int ret = 0;
+
+	css_task_iter_start(&root_mem_cgroup->css, 0, &it);
+	while (!ret && (task = css_task_iter_next(&it)))
+		ret = oom_evaluate_task(task, oc);
+	css_task_iter_end(&it);
+}
+
+bool mem_cgroup_select_oom_victim(struct oom_control *oc)
+{
+	struct mem_cgroup *root = root_mem_cgroup;
+
+	oc->chosen = NULL;
+	oc->chosen_memcg = NULL;
+
+	if (mem_cgroup_disabled())
+		return false;
+
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		return false;
+
+	if (oc->memcg)
+		root = oc->memcg;
+
+	rcu_read_lock();
+
+	select_victim_memcg(root, oc);
+	if (oc->chosen_memcg == (void *)-1UL) {
+		/* Existing OOM victims are found. */
+		rcu_read_unlock();
+		return true;
+	}
+
+	/*
+	 * For system-wide OOMs we should consider tasks in the root cgroup
+	 * with oom_score larger than oc->chosen_points.
+	 */
+	if (!oc->memcg) {
+		select_victim_root_cgroup_task(oc);
+
+		if (oc->chosen && oc->chosen_memcg) {
+			/*
+			 * If we've decided to kill a task in the root memcg,
+			 * release chosen_memcg.
+			 */
+			css_put(&oc->chosen_memcg->css);
+			oc->chosen_memcg = NULL;
+		}
+	}
+
+	rcu_read_unlock();
+
+	return !!oc->chosen || !!oc->chosen_memcg;
+}
+
 /*
  * Reclaims as many pages from the given memcg as possible.
  *
@@ -5171,6 +5346,33 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static int memory_oom_kill_all_tasks_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	bool oom_kill_all_tasks = memcg->oom_kill_all_tasks;
+
+	seq_printf(m, "%d\n", oom_kill_all_tasks);
+
+	return 0;
+}
+
+static ssize_t memory_oom_kill_all_tasks_write(struct kernfs_open_file *of,
+					       char *buf, size_t nbytes,
+					       loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	int oom_kill_all_tasks;
+	int err;
+
+	err = kstrtoint(strstrip(buf), 0, &oom_kill_all_tasks);
+	if (err)
+		return err;
+
+	memcg->oom_kill_all_tasks = !!oom_kill_all_tasks;
+
+	return nbytes;
+}
+
 static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -5291,6 +5493,12 @@ static struct cftype memory_files[] = {
 		.write = memory_max_write,
 	},
 	{
+		.name = "oom_kill_all_tasks",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_oom_kill_all_tasks_show,
+		.write = memory_oom_kill_all_tasks_write,
+	},
+	{
 		.name = "events",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.file_offset = offsetof(struct mem_cgroup, events_file),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 72de01be4d33..a9d75becd1e4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -288,7 +288,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
-static int oom_evaluate_task(struct task_struct *task, void *arg)
+int oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
 	unsigned long points;
@@ -829,66 +829,14 @@ static bool task_will_free_mem(struct task_struct *task)
 	return ret;
 }
 
-static void oom_kill_process(struct oom_control *oc, const char *message)
+static void __oom_kill_process(struct task_struct *victim)
 {
-	struct task_struct *p = oc->chosen;
-	unsigned int points = oc->chosen_points;
-	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
+	struct task_struct *p;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
-	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
-					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	task_lock(p);
-	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
+	if (is_global_init(victim) || (victim->flags & PF_KTHREAD))
 		return;
-	}
-	task_unlock(p);
-
-	if (__ratelimit(&oom_rs))
-		dump_header(oc, p);
-
-	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
-
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (process_shares_mm(child, p->mm))
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child,
-				oc->memcg, oc->nodemask, oc->totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	read_unlock(&tasklist_lock);
 
 	p = find_lock_task_mm(victim);
 	if (!p) {
@@ -959,10 +907,117 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		wake_oom_reaper(victim);
 
 	mmdrop(mm);
-	put_task_struct(victim);
 }
 #undef K
 
+static void oom_kill_process(struct oom_control *oc, const char *message)
+{
+	struct task_struct *p = oc->chosen;
+	unsigned int points = oc->chosen_points;
+	struct task_struct *victim = p;
+	struct task_struct *child;
+	struct task_struct *t;
+	unsigned int victim_points = 0;
+	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
+					      DEFAULT_RATELIMIT_BURST);
+
+	/*
+	 * If the task is already exiting, don't alarm the sysadmin or kill
+	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 */
+	task_lock(p);
+	if (task_will_free_mem(p)) {
+		mark_oom_victim(p);
+		wake_oom_reaper(p);
+		task_unlock(p);
+		put_task_struct(p);
+		return;
+	}
+	task_unlock(p);
+
+	if (__ratelimit(&oom_rs))
+		dump_header(oc, p);
+
+	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
+		message, task_pid_nr(p), p->comm, points);
+
+	/*
+	 * If any of p's children has a different mm and is eligible for kill,
+	 * the one with the highest oom_badness() score is sacrificed for its
+	 * parent.  This attempts to lose the minimal amount of work done while
+	 * still freeing memory.
+	 */
+	read_lock(&tasklist_lock);
+	for_each_thread(p, t) {
+		list_for_each_entry(child, &t->children, sibling) {
+			unsigned int child_points;
+
+			if (process_shares_mm(child, p->mm))
+				continue;
+			/*
+			 * oom_badness() returns 0 if the thread is unkillable
+			 */
+			child_points = oom_badness(child,
+				oc->memcg, oc->nodemask, oc->totalpages);
+			if (child_points > victim_points) {
+				put_task_struct(victim);
+				victim = child;
+				victim_points = child_points;
+				get_task_struct(victim);
+			}
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	__oom_kill_process(victim);
+	put_task_struct(victim);
+}
+
+static int oom_kill_memcg_member(struct task_struct *task, void *unused)
+{
+	if (!tsk_is_oom_victim(task))
+		__oom_kill_process(task);
+	return 0;
+}
+
+static bool oom_kill_memcg_victim(struct oom_control *oc)
+{
+	if (oc->chosen) {
+		if (oc->chosen != (void *)-1UL) {
+			__oom_kill_process(oc->chosen);
+			put_task_struct(oc->chosen);
+			schedule_timeout_killable(1);
+		}
+		return true;
+
+	} else if (oc->chosen_memcg) {
+		if (oc->chosen_memcg == (void *)-1UL)
+			return true;
+
+		/* Always begin with the biggest task */
+		oc->chosen_points = 0;
+		oc->chosen = NULL;
+		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
+		if (oc->chosen && oc->chosen != (void *)-1UL) {
+			__oom_kill_process(oc->chosen);
+			put_task_struct(oc->chosen);
+
+			if (oc->chosen_memcg->oom_kill_all_tasks)
+				mem_cgroup_scan_tasks(oc->chosen_memcg,
+						      oom_kill_memcg_member,
+						      NULL);
+		}
+
+		mem_cgroup_put(oc->chosen_memcg);
+		oc->chosen_memcg = NULL;
+		return true;
+
+	} else {
+		oc->chosen_points = 0;
+		return false;
+	}
+}
+
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
@@ -1064,6 +1119,9 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	if (mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc))
+		return true;
+
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
