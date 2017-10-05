Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7F6C6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 10:31:07 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 90so2099686lfs.12
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 07:31:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o84si13432239wmb.55.2017.10.05.07.31.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 07:31:06 -0700 (PDT)
Date: Thu, 5 Oct 2017 16:31:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v11 4/6] mm, oom: introduce memory.oom_group
Message-ID: <20171005143104.wo5xstpe7mhkdlbr@dhcp22.suse.cz>
References: <20171005130454.5590-1-guro@fb.com>
 <20171005130454.5590-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005130454.5590-5-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Btw. here is how I would do the recursive oom badness. The diff is not
the nicest one because there is some code moving but the resulting code
is smaller and imho easier to grasp. Only compile tested though
---
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 085056e562b1..9cdba4682198 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -122,6 +122,11 @@ void cgroup_free(struct task_struct *p);
 int cgroup_init_early(void);
 int cgroup_init(void);
 
+static bool cgroup_has_tasks(struct cgroup *cgrp)
+{
+	return cgrp->nr_populated_csets;
+}
+
 /*
  * Iteration helpers and macros.
  */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 8dacf73ad57e..a2dd7e3ffe23 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -319,11 +319,6 @@ static void cgroup_idr_remove(struct idr *idr, int id)
 	spin_unlock_bh(&cgroup_idr_lock);
 }
 
-static bool cgroup_has_tasks(struct cgroup *cgrp)
-{
-	return cgrp->nr_populated_csets;
-}
-
 bool cgroup_is_threaded(struct cgroup *cgrp)
 {
 	return cgrp->dom_cgrp != cgrp;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b3848bce4c86..012b2216266f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2671,59 +2671,63 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 }
 
 static long memcg_oom_badness(struct mem_cgroup *memcg,
-			      const nodemask_t *nodemask,
-			      unsigned long totalpages)
+			      const nodemask_t *nodemask)
 {
+	struct mem_cgroup *iter;
+	struct css_task_iter it;
+	struct task_struct *task;
 	long points = 0;
+	int eligible = 0;
 	int nid;
 	pg_data_t *pgdat;
 
-	/*
-	 * We don't have necessary stats for the root memcg,
-	 * so we define it's oom_score as the maximum oom_score
-	 * of the belonging tasks.
-	 *
-	 * As tasks in the root memcg unlikely are parts of a
-	 * single workload, and we don't have to implement
-	 * group killing, this approximation is reasonable.
-	 *
-	 * But if we will have necessary stats for the root memcg,
-	 * we might switch to the approach which is used for all
-	 * other memcgs.
-	 */
-	if (memcg == root_mem_cgroup) {
-		struct css_task_iter it;
-		struct task_struct *task;
-		long score, max_score = 0;
-
+	for_each_mem_cgroup_tree(iter, memcg) {
+		/*
+		 * Memcg is OOM eligible if there are OOM killable tasks inside.
+		 *
+		 * We treat tasks with oom_score_adj set to OOM_SCORE_ADJ_MIN
+		 * as unkillable.
+		 *
+		 * If there are inflight OOM victim tasks inside the memcg,
+		 * we return -1.
+		 */
 		css_task_iter_start(&memcg->css, 0, &it);
 		while ((task = css_task_iter_next(&it))) {
-			score = oom_badness(task, memcg, nodemask,
-					    totalpages);
-			if (score > max_score)
-				max_score = score;
+			if (!eligible &&
+			    task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
+				eligible = 1;
+
+			if (tsk_is_oom_victim(task) &&
+			    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
+				eligible = -1;
+				break;
+			}
 		}
 		css_task_iter_end(&it);
 
-		return max_score;
-	}
+		if (eligible <= 0) {
+			mem_cgroup_iter_break(memcg, iter);
+			points = -1;
+			break;
+		}
 
-	for_each_node_state(nid, N_MEMORY) {
-		if (nodemask && !node_isset(nid, *nodemask))
-			continue;
+		for_each_node_state(nid, N_MEMORY) {
+			if (nodemask && !node_isset(nid, *nodemask))
+				continue;
 
-		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
-				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
+			points += mem_cgroup_node_nr_lru_pages(memcg, nid,
+					LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
 
-		pgdat = NODE_DATA(nid);
-		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
-					    NR_SLAB_UNRECLAIMABLE);
-	}
+			pgdat = NODE_DATA(nid);
+			points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
+						    NR_SLAB_UNRECLAIMABLE);
+		}
 
-	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
-		(PAGE_SIZE / 1024);
-	points += memcg_page_state(memcg, MEMCG_SOCK);
-	points += memcg_page_state(memcg, MEMCG_SWAP);
+		points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
+			(PAGE_SIZE / 1024);
+		points += memcg_page_state(memcg, MEMCG_SOCK);
+		points += memcg_page_state(memcg, MEMCG_SWAP);
+	}
 
 	return points;
 }
@@ -2741,43 +2745,56 @@ static long oom_evaluate_memcg(struct mem_cgroup *memcg,
 			       const nodemask_t *nodemask,
 			       unsigned long totalpages)
 {
-	struct css_task_iter it;
-	struct task_struct *task;
-	int eligible = 0;
-
 	/*
-	 * Memcg is OOM eligible if there are OOM killable tasks inside.
+	 * We don't have necessary stats for the root memcg,
+	 * so we define it's oom_score as the maximum oom_score
+	 * of the belonging tasks.
 	 *
-	 * We treat tasks with oom_score_adj set to OOM_SCORE_ADJ_MIN
-	 * as unkillable.
+	 * As tasks in the root memcg unlikely are parts of a
+	 * single workload, and we don't have to implement
+	 * group killing, this approximation is reasonable.
 	 *
-	 * If there are inflight OOM victim tasks inside the memcg,
-	 * we return -1.
+	 * But if we will have necessary stats for the root memcg,
+	 * we might switch to the approach which is used for all
+	 * other memcgs.
 	 */
-	css_task_iter_start(&memcg->css, 0, &it);
-	while ((task = css_task_iter_next(&it))) {
-		if (!eligible &&
-		    task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
-			eligible = 1;
-
-		if (tsk_is_oom_victim(task) &&
-		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
-			eligible = -1;
-			break;
+	if (memcg == root_mem_cgroup) {
+		struct css_task_iter it;
+		struct task_struct *task;
+		long score, max_score = 0;
+
+		css_task_iter_start(&memcg->css, 0, &it);
+		while ((task = css_task_iter_next(&it))) {
+			if (tsk_is_oom_victim(task) &&
+			    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
+				max_score = -1;
+				break;
+			}
+			score = oom_badness(task, memcg, nodemask,
+					    totalpages);
+			if (score > max_score)
+				max_score = score;
 		}
-	}
-	css_task_iter_end(&it);
+		css_task_iter_end(&it);
 
-	if (eligible <= 0)
-		return eligible;
+		return max_score;
+	}
 
-	return memcg_oom_badness(memcg, nodemask, totalpages);
+	return memcg_oom_badness(memcg, nodemask);
 }
 
+static bool memcg_is_oom_eligible(struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_oom_group(memcg))
+		return true;
+	if (cgroup_has_tasks(memcg->css.cgroup))
+		return true;
+
+	return false;
+}
 static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 {
-	struct mem_cgroup *iter, *group = NULL;
-	long group_score = 0;
+	struct mem_cgroup *iter;
 
 	oc->chosen_memcg = NULL;
 	oc->chosen_points = 0;
@@ -2803,35 +2820,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 	for_each_mem_cgroup_tree(iter, root) {
 		long score;
 
-		/*
-		 * We don't consider non-leaf non-oom_group memory cgroups
-		 * as OOM victims.
-		 */
-		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
-		    !mem_cgroup_oom_group(iter))
-			continue;
-
-		/*
-		 * If group is not set or we've ran out of the group's sub-tree,
-		 * we should set group and reset group_score.
-		 */
-		if (!group || group == root_mem_cgroup ||
-		    !mem_cgroup_is_descendant(iter, group)) {
-			group = iter;
-			group_score = 0;
-		}
-
-		if (memcg_has_children(iter) && iter != root_mem_cgroup)
+		if (!memcg_is_oom_eligible(iter))
 			continue;
 
 		score = oom_evaluate_memcg(iter, oc->nodemask, oc->totalpages);
 
-		/*
-		 * Ignore empty and non-eligible memory cgroups.
-		 */
-		if (score == 0)
-			continue;
-
 		/*
 		 * If there are inflight OOM victims, we don't need
 		 * to look further for new victims.
@@ -2842,11 +2835,9 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 			break;
 		}
 
-		group_score += score;
-
-		if (group_score > oc->chosen_points) {
-			oc->chosen_points = group_score;
-			oc->chosen_memcg = group;
+		if (score > oc->chosen_points) {
+			oc->chosen_points = score;
+			oc->chosen_memcg = iter;
 		}
 	}
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
