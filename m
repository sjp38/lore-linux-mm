Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF19C6B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 20:21:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b2so566324pgt.6
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:21:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor329374pge.300.2018.03.13.17.21.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 17:21:12 -0700 (PDT)
Date: Tue, 13 Mar 2018 17:21:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, memcg: evaluate root and leaf memcgs fairly on oom
In-Reply-To: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There are several downsides to the current implementation that compares
the root mem cgroup with leaf mem cgroups for the cgroup-aware oom killer.

For example, /proc/pid/oom_score_adj is accounted for processes attached
to the root mem cgroup but not leaves.  This leads to wild inconsistencies
that unfairly bias for or against the root mem cgroup.

Assume a 728KB bash shell is attached to the root mem cgroup without any
other processes having a non-default /proc/pid/oom_score_adj.  At the time
of system oom, the root mem cgroup evaluated to 43,474 pages after boot.
If the bash shell adjusts its /proc/self/oom_score_adj to 1000, however,
the root mem cgroup evaluates to 24,765,482 pages lol.  It would take a
cgroup 95GB of memory to outweigh the root mem cgroup's evaluation.

The reverse is even more confusing: if the bash shell adjusts its
/proc/self/oom_score_adj to -999, the root mem cgroup evaluates to 42,268
pages, a basically meaningless transformation.

/proc/pid/oom_score_adj is discounted, however, for processes attached to
leaf mem cgroups.  If a sole process using 250MB of memory is attached to
a mem cgroup, it evaluates to 250MB >> PAGE_SHIFT.  If its
/proc/pid/oom_score_adj is changed to -999, or even 1000, the evaluation
remains the same for the mem cgroup.

The heuristic that is used for the root mem cgroup also differs from leaf
mem cgroups.

For the root mem cgroup, the evaluation is the sum of all process's
/proc/pid/oom_score.  Besides factoring in oom_score_adj, it is based on
the sum of rss + swap + page tables for all processes attached to it.
For leaf mem cgroups, it is based on the amount of anonymous or
unevictable memory + unreclaimable slab + kernel stack + sock + swap.

There's also an exemption for root mem cgroup processes that do not
intersect the allocating process's mems_allowed.  Because the current
heuristic is based on oom_badness(), the evaluation of the root mem
cgroup disregards all processes attached to it that have disjoint
mems_allowed making oom selection specifically dependant on the
allocating process for system oom conditions!

This patch introduces completely fair comparison between the root mem
cgroup and leaf mem cgroups.  It compares them with the same heuristic
and does not prefer one over the other.  It disregards oom_score_adj
as the cgroup-aware oom killer should, if enabled by memory.oom_policy.
The goal is to target the most memory consuming cgroup on the system,
not consider per-process adjustment.

The fact that the evaluation of all mem cgroups depends on the mempolicy
of the allocating process, which is completely undocumented for the
cgroup-aware oom killer, will be addressed in a subsequent patch.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Based on top of oom policy patch series at
 https://marc.info/?t=152090280800001

 Documentation/cgroup-v2.txt |   7 +-
 mm/memcontrol.c             | 147 ++++++++++++++++++------------------
 2 files changed, 74 insertions(+), 80 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1328,12 +1328,7 @@ OOM killer to kill all processes attached to the cgroup, except processes
 with /proc/pid/oom_score_adj set to -1000 (oom disabled).
 
 The root cgroup is treated as a leaf memory cgroup as well, so it is
-compared with other leaf memory cgroups. Due to internal implementation
-restrictions the size of the root cgroup is the cumulative sum of
-oom_badness of all its tasks (in other words oom_score_adj of each task
-is obeyed). Relying on oom_score_adj (apart from OOM_SCORE_ADJ_MIN) can
-lead to over- or underestimation of the root cgroup consumption and it is
-therefore discouraged. This might change in the future, however.
+compared with other leaf memory cgroups.
 
 Please, note that memory charges are not migrating if tasks
 are moved between different memory cgroups. Moving tasks with
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -94,6 +94,8 @@ int do_swap_account __read_mostly;
 #define do_swap_account		0
 #endif
 
+static atomic_long_t total_sock_pages;
+
 /* Whether legacy memory+swap accounting is active */
 static bool do_memsw_account(void)
 {
@@ -2607,9 +2609,9 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 }
 
 static long memcg_oom_badness(struct mem_cgroup *memcg,
-			      const nodemask_t *nodemask,
-			      unsigned long totalpages)
+			      const nodemask_t *nodemask)
 {
+	const bool is_root_memcg = memcg == root_mem_cgroup;
 	long points = 0;
 	int nid;
 	pg_data_t *pgdat;
@@ -2618,92 +2620,65 @@ static long memcg_oom_badness(struct mem_cgroup *memcg,
 		if (nodemask && !node_isset(nid, *nodemask))
 			continue;
 
-		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
-				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
-
 		pgdat = NODE_DATA(nid);
-		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
-					    NR_SLAB_UNRECLAIMABLE);
+		if (is_root_memcg) {
+			points += node_page_state(pgdat, NR_ACTIVE_ANON) +
+				  node_page_state(pgdat, NR_INACTIVE_ANON);
+			points += node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE);
+		} else {
+			points += mem_cgroup_node_nr_lru_pages(memcg, nid,
+							       LRU_ALL_ANON);
+			points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
+						    NR_SLAB_UNRECLAIMABLE);
+		}
 	}
 
-	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
-		(PAGE_SIZE / 1024);
-	points += memcg_page_state(memcg, MEMCG_SOCK);
-	points += memcg_page_state(memcg, MEMCG_SWAP);
-
+	if (is_root_memcg) {
+		points += global_zone_page_state(NR_KERNEL_STACK_KB) /
+				(PAGE_SIZE / 1024);
+		points += atomic_long_read(&total_sock_pages);
+		points += total_swap_pages - atomic_long_read(&nr_swap_pages);
+	} else {
+		points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
+				(PAGE_SIZE / 1024);
+		points += memcg_page_state(memcg, MEMCG_SOCK);
+		points += memcg_page_state(memcg, MEMCG_SWAP);
+	}
 	return points;
 }
 
 /*
- * Checks if the given memcg is a valid OOM victim and returns a number,
- * which means the folowing:
- *   -1: there are inflight OOM victim tasks, belonging to the memcg
- *    0: memcg is not eligible, e.g. all belonging tasks are protected
- *       by oom_score_adj set to OOM_SCORE_ADJ_MIN
+ * Checks if the given non-root memcg has a valid OOM victim and returns a
+ * number, which means the following:
+ *   -1: there is an inflight OOM victim process attached to the memcg
+ *    0: memcg is not eligible because all tasks attached are unkillable
+ *       (kthreads or oom_score_adj set to OOM_SCORE_ADJ_MIN)
  *   >0: memcg is eligible, and the returned value is an estimation
  *       of the memory footprint
  */
 static long oom_evaluate_memcg(struct mem_cgroup *memcg,
-			       const nodemask_t *nodemask,
-			       unsigned long totalpages)
+			       const nodemask_t *nodemask)
 {
 	struct css_task_iter it;
 	struct task_struct *task;
 	int eligible = 0;
 
 	/*
-	 * Root memory cgroup is a special case:
-	 * we don't have necessary stats to evaluate it exactly as
-	 * leaf memory cgroups, so we approximate it's oom_score
-	 * by summing oom_score of all belonging tasks, which are
-	 * owners of their mm structs.
-	 *
-	 * If there are inflight OOM victim tasks inside
-	 * the root memcg, we return -1.
-	 */
-	if (memcg == root_mem_cgroup) {
-		struct css_task_iter it;
-		struct task_struct *task;
-		long score = 0;
-
-		css_task_iter_start(&memcg->css, 0, &it);
-		while ((task = css_task_iter_next(&it))) {
-			if (tsk_is_oom_victim(task) &&
-			    !test_bit(MMF_OOM_SKIP,
-				      &task->signal->oom_mm->flags)) {
-				score = -1;
-				break;
-			}
-
-			task_lock(task);
-			if (!task->mm || task->mm->owner != task) {
-				task_unlock(task);
-				continue;
-			}
-			task_unlock(task);
-
-			score += oom_badness(task, memcg, nodemask,
-					     totalpages);
-		}
-		css_task_iter_end(&it);
-
-		return score;
-	}
-
-	/*
-	 * Memcg is OOM eligible if there are OOM killable tasks inside.
-	 *
-	 * We treat tasks with oom_score_adj set to OOM_SCORE_ADJ_MIN
-	 * as unkillable.
-	 *
-	 * If there are inflight OOM victim tasks inside the memcg,
-	 * we return -1.
+	 * Memcg is eligible for oom kill if at least one process is eligible
+	 * to be killed.  Processes with oom_score_adj of OOM_SCORE_ADJ_MIN
+	 * are unkillable.
 	 */
 	css_task_iter_start(&memcg->css, 0, &it);
 	while ((task = css_task_iter_next(&it))) {
+		task_lock(task);
+		if (!task->mm || task != task->mm->owner) {
+			task_unlock(task);
+			continue;
+		}
 		if (!eligible &&
 		    task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
 			eligible = 1;
+		task_unlock(task);
 
 		if (tsk_is_oom_victim(task) &&
 		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
@@ -2716,13 +2691,14 @@ static long oom_evaluate_memcg(struct mem_cgroup *memcg,
 	if (eligible <= 0)
 		return eligible;
 
-	return memcg_oom_badness(memcg, nodemask, totalpages);
+	return memcg_oom_badness(memcg, nodemask);
 }
 
 static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 {
 	struct mem_cgroup *iter, *group = NULL;
 	long group_score = 0;
+	long leaf_score = 0;
 
 	oc->chosen_memcg = NULL;
 	oc->chosen_points = 0;
@@ -2748,12 +2724,18 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	for_each_mem_cgroup_tree(iter, root) {
 		long score;
 
+		/*
+		 * Root memory cgroup will be considered after iteration,
+		 * if eligible.
+		 */
+		if (iter == root_mem_cgroup)
+			continue;
+
 		/*
 		 * We don't consider non-leaf non-oom_group memory cgroups
 		 * without the oom policy of "tree" as OOM victims.
 		 */
-		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
-		    !mem_cgroup_oom_group(iter) &&
+		if (memcg_has_children(iter) && !mem_cgroup_oom_group(iter) &&
 		    iter->oom_policy != MEMCG_OOM_POLICY_TREE)
 			continue;
 
@@ -2761,16 +2743,15 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 		 * If group is not set or we've ran out of the group's sub-tree,
 		 * we should set group and reset group_score.
 		 */
-		if (!group || group == root_mem_cgroup ||
-		    !mem_cgroup_is_descendant(iter, group)) {
+		if (!group || !mem_cgroup_is_descendant(iter, group)) {
 			group = iter;
 			group_score = 0;
 		}
 
-		if (memcg_has_children(iter) && iter != root_mem_cgroup)
+		if (memcg_has_children(iter))
 			continue;
 
-		score = oom_evaluate_memcg(iter, oc->nodemask, oc->totalpages);
+		score = oom_evaluate_memcg(iter, oc->nodemask);
 
 		/*
 		 * Ignore empty and non-eligible memory cgroups.
@@ -2789,6 +2770,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 		}
 
 		group_score += score;
+		leaf_score += score;
 
 		if (group_score > oc->chosen_points) {
 			oc->chosen_points = group_score;
@@ -2796,8 +2778,25 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 		}
 	}
 
-	if (oc->chosen_memcg && oc->chosen_memcg != INFLIGHT_VICTIM)
-		css_get(&oc->chosen_memcg->css);
+	if (oc->chosen_memcg != INFLIGHT_VICTIM) {
+		if (root == root_mem_cgroup) {
+			group_score = oom_evaluate_memcg(root_mem_cgroup,
+							 oc->nodemask);
+			if (group_score > leaf_score) {
+				/*
+				 * Discount the sum of all leaf scores to find
+				 * root score.
+				 */
+				group_score -= leaf_score;
+				if (group_score > oc->chosen_points) {
+					oc->chosen_points = group_score;
+					oc->chosen_memcg = root_mem_cgroup;
+				}
+			}
+		}
+		if (oc->chosen_memcg)
+			css_get(&oc->chosen_memcg->css);
+	}
 
 	rcu_read_unlock();
 }
