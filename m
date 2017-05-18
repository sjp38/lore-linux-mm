From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Date: Thu, 18 May 2017 17:28:04 +0100
Message-ID: <1495124884-28974-1-git-send-email-guro@fb.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Traditionally, the OOM killer is operating on a process level.
Under oom conditions, it finds a process with the highest oom score
and kills it.

This behavior doesn't suit well the system with many running
containers. There are two main issues:

1) There is no fairness between containers. A small container with
a few large processes will be chosen over a large one with huge
number of small processes.

2) Containers often do not expect that some random process inside
will be killed. So, in general, a much safer behavior is
to kill the whole cgroup. Traditionally, this was implemented
in userspace, but doing it in the kernel has some advantages,
especially in a case of a system-wide OOM.

To address these issues, cgroup-aware OOM killer is introduced.
Under OOM conditions, it looks for a memcg with highest oom score,
and kills all processes inside.

Memcg oom score is calculated as a size of active and inactive
anon LRU lists, unevictable LRU list and swap size.

For a cgroup-wide OOM, only cgroups belonging to the subtree of
the OOMing cgroup are considered.

If there is no elegible memcg found, OOM killer falls back to
a traditional per-process behavior.

This change affects only cgroup v2.

Signed-off-by: Roman Gushchin <guro@fb.com>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 Documentation/cgroup-v2.txt | 24 ++++++++++++++--
 include/linux/memcontrol.h  |  3 ++
 include/linux/oom.h         |  1 +
 mm/memcontrol.c             | 69 +++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c               | 49 ++++++++++++++++++++++++++++----
 5 files changed, 139 insertions(+), 7 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index dc5e2dc..6583041 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -44,6 +44,7 @@ CONTENTS
     5-2-1. Memory Interface Files
     5-2-2. Usage Guidelines
     5-2-3. Memory Ownership
+    5-2-4. Cgroup-aware OOM Killer
   5-3. IO
     5-3-1. IO Interface Files
     5-3-2. Writeback
@@ -831,8 +832,7 @@ PAGE_SIZE multiple when read back.
 	  oom
 
 		The number of times the OOM killer has been invoked in
-		the cgroup.  This may not exactly match the number of
-		processes killed but should generally be close.
+		the cgroup.
 
   memory.stat
 
@@ -988,6 +988,26 @@ POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
 belonging to the affected files to ensure correct memory ownership.
 
 
+5-2-4. Cgroup-aware OOM Killer
+
+Cgroup v2 memory controller implements a cgroup-aware OOM killer.
+It means that it treats memory cgroups as memory consumers
+rather then individual processes. Under the OOM conditions it tries
+to find an elegible leaf memory cgroup, and kill all processes
+in this cgroup. If it's not possible (e.g. all processes belong
+to the root cgroup), it falls back to the traditional per-process
+behaviour.
+
+The memory controller tries to make the best choise of a victim cgroup.
+In general, it tries to select the largest cgroup, matching given
+node/zone requirements, but the concrete algorithm is not defined,
+and may be changed later.
+
+This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
+the memory controller considers only cgroups belonging to a sub-tree
+of the OOM-ing cgroup, including itself.
+
+
 5-3. IO
 
 The "io" controller regulates the distribution of IO resources.  This
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 899949b..fb0ff64 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -34,6 +34,7 @@ struct mem_cgroup;
 struct page;
 struct mm_struct;
 struct kmem_cache;
+struct oom_control;
 
 /* Cgroup-specific page state, on top of universal node page state */
 enum memcg_stat_item {
@@ -465,6 +466,8 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 
 bool mem_cgroup_oom_synchronize(bool wait);
 
+bool mem_cgroup_select_oom_victim(struct oom_control *oc);
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8a266e2..51e71f2 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -39,6 +39,7 @@ struct oom_control {
 	unsigned long totalpages;
 	struct task_struct *chosen;
 	unsigned long chosen_points;
+	struct mem_cgroup *chosen_memcg;
 };
 
 extern struct mutex oom_lock;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c131f7e..8d07481 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2625,6 +2625,75 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 	return ret;
 }
 
+bool mem_cgroup_select_oom_victim(struct oom_control *oc)
+{
+	struct mem_cgroup *iter;
+	unsigned long chosen_memcg_points;
+
+	oc->chosen_memcg = NULL;
+
+	if (mem_cgroup_disabled())
+		return false;
+
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		return false;
+
+	pr_info("Choosing a victim memcg because of %s",
+		oc->memcg ?
+		"memory limit reached of cgroup " :
+		"out of memory\n");
+	if (oc->memcg) {
+		pr_cont_cgroup_path(oc->memcg->css.cgroup);
+		pr_cont("\n");
+	}
+
+	chosen_memcg_points = 0;
+
+	for_each_mem_cgroup_tree(iter, oc->memcg) {
+		unsigned long points;
+		int nid;
+
+		if (mem_cgroup_is_root(iter))
+			continue;
+
+		if (memcg_has_children(iter))
+			continue;
+
+		points = 0;
+		for_each_node_state(nid, N_MEMORY) {
+			if (oc->nodemask && !node_isset(nid, *oc->nodemask))
+				continue;
+			points += mem_cgroup_node_nr_lru_pages(iter, nid,
+					LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
+		}
+		points += mem_cgroup_get_nr_swap_pages(iter);
+
+		pr_info("Memcg ");
+		pr_cont_cgroup_path(iter->css.cgroup);
+		pr_cont(": %lu\n", points);
+
+		if (points > chosen_memcg_points) {
+			if (oc->chosen_memcg)
+				css_put(&oc->chosen_memcg->css);
+
+			oc->chosen_memcg = iter;
+			css_get(&iter->css);
+
+			chosen_memcg_points = points;
+		}
+	}
+
+	if (oc->chosen_memcg) {
+		pr_info("Kill memcg ");
+		pr_cont_cgroup_path(oc->chosen_memcg->css.cgroup);
+		pr_cont(" (%lu)\n", chosen_memcg_points);
+	} else {
+		pr_info("No elegible memory cgroup found\n");
+	}
+
+	return !!oc->chosen_memcg;
+}
+
 /*
  * Reclaims as many pages from the given memcg as possible.
  *
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143..c000495 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -802,6 +802,8 @@ static bool task_will_free_mem(struct task_struct *task)
 	return ret;
 }
 
+static void __oom_kill_process(struct task_struct *victim);
+
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
 	struct task_struct *p = oc->chosen;
@@ -809,11 +811,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	struct task_struct *victim = p;
 	struct task_struct *child;
 	struct task_struct *t;
-	struct mm_struct *mm;
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -863,6 +863,15 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	read_unlock(&tasklist_lock);
 
+	__oom_kill_process(victim);
+}
+
+static void __oom_kill_process(struct task_struct *victim)
+{
+	struct task_struct *p;
+	struct mm_struct *mm;
+	bool can_oom_reap = true;
+
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
@@ -970,6 +979,20 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+static int oom_kill_task_fn(struct task_struct *p, void *arg)
+{
+	if (is_global_init(p))
+		return 0;
+
+	if (p->flags & PF_KTHREAD)
+		return 0;
+
+	get_task_struct(p);
+	__oom_kill_process(p);
+
+	return 0;
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -1032,13 +1055,29 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
-	select_bad_process(oc);
+	/*
+	 * Try to find an elegible memory cgroup. If nothing found,
+	 * fallback to a per-process OOM.
+	 */
+	if (!mem_cgroup_select_oom_victim(oc))
+		select_bad_process(oc);
+
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+	if (!oc->chosen_memcg && !oc->chosen && !is_sysrq_oom(oc) &&
+	    !is_memcg_oom(oc)) {
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL) {
+
+	if (oc->chosen_memcg) {
+		/* Try to kill the whole memory cgroup. */
+		if (!is_memcg_oom(oc))
+			mem_cgroup_event(oc->chosen_memcg, MEMCG_OOM);
+		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_task_fn, NULL);
+
+		css_put(&oc->chosen_memcg->css);
+		schedule_timeout_killable(1);
+	} else if (oc->chosen && oc->chosen != (void *)-1UL) {
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
 		/*
-- 
2.7.4

