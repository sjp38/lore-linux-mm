Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E67E36B02FA
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:36:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s74so14835690pfe.10
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:36:30 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p76si20756342pfd.192.2017.06.01.11.36.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:36:30 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH v2 6/7] mm, oom: cgroup-aware OOM killer
Date: Thu, 1 Jun 2017 19:35:14 +0100
Message-ID: <1496342115-3974-7-git-send-email-guro@fb.com>
In-Reply-To: <1496342115-3974-1-git-send-email-guro@fb.com>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Traditionally, the OOM killer is operating on a process level.
Under oom conditions, it finds a process with the highest oom score
and kills it.

This behavior doesn't suit well the system with many running
containers. There are two main issues:

1) There is no fairness between containers. A small container with
few large processes will be chosen over a large one with huge
number of small processes.

2) Containers often do not expect that some random process inside
will be killed. In many cases much more safer behavior is to kill
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
 include/linux/memcontrol.h |  13 ++++
 include/linux/oom.h        |   1 +
 mm/memcontrol.c            | 178 +++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c              |   6 ++
 4 files changed, 198 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 818a42e..67709a4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -34,6 +34,7 @@ struct mem_cgroup;
 struct page;
 struct mm_struct;
 struct kmem_cache;
+struct oom_control;
 
 /* Cgroup-specific page state, on top of universal node page state */
 enum memcg_stat_item {
@@ -471,6 +472,9 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 
 bool mem_cgroup_oom_synchronize(bool wait);
 
+bool mem_cgroup_select_oom_victim(struct oom_control *oc);
+bool mem_cgroup_kill_oom_victim(struct oom_control *oc);
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
@@ -931,6 +935,15 @@ static inline void memcg_kmem_update_page_stat(struct page *page,
 				enum memcg_stat_item idx, int val)
 {
 }
+
+static inline bool mem_cgroup_select_oom_victim(struct oom_control *oc)
+{
+	return false;
+}
+static inline bool mem_cgroup_kill_oom_victim(struct oom_control *oc)
+{
+	return false;
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/oom.h b/include/linux/oom.h
index edf7a77..a6086a2 100644
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
index f979ac7..855d335 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2625,6 +2625,184 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 	return ret;
 }
 
+static long mem_cgroup_oom_badness(struct mem_cgroup *memcg,
+				   const nodemask_t *nodemask)
+{
+	long points = 0;
+	int nid;
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, memcg) {
+		for_each_node_state(nid, N_MEMORY) {
+			if (nodemask && !node_isset(nid, *nodemask))
+				continue;
+
+			points += mem_cgroup_node_nr_lru_pages(iter, nid,
+					LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
+		}
+
+		points += mem_cgroup_get_nr_swap_pages(iter);
+		points += memcg_page_state(iter, MEMCG_KERNEL_STACK_KB) /
+			(PAGE_SIZE / 1024);
+		points += memcg_page_state(iter, MEMCG_SLAB_UNRECLAIMABLE);
+		points += memcg_page_state(iter, MEMCG_SOCK);
+	}
+
+	return points;
+}
+
+bool mem_cgroup_select_oom_victim(struct oom_control *oc)
+{
+	struct cgroup_subsys_state *css = NULL;
+	struct mem_cgroup *iter = NULL;
+	struct mem_cgroup *chosen_memcg = NULL;
+	struct mem_cgroup *parent = root_mem_cgroup;
+	unsigned long totalpages = oc->totalpages;
+	long chosen_memcg_points = 0;
+	long points = 0;
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
+	pr_info("Choosing a victim memcg because of the %s",
+		oc->memcg ?
+		"memory limit reached of cgroup " :
+		"system-wide OOM\n");
+	if (oc->memcg) {
+		pr_cont_cgroup_path(oc->memcg->css.cgroup);
+		pr_cont("\n");
+
+		chosen_memcg = oc->memcg;
+		parent = oc->memcg;
+	}
+
+	rcu_read_lock();
+
+	for (;;) {
+		css = css_next_child(css, &parent->css);
+		if (css) {
+			iter = mem_cgroup_from_css(css);
+
+			points = mem_cgroup_oom_badness(iter, oc->nodemask);
+			points += iter->oom_score_adj * (totalpages / 1000);
+
+			pr_info("Cgroup ");
+			pr_cont_cgroup_path(iter->css.cgroup);
+			pr_cont(": %ld\n", points);
+
+			if (points > chosen_memcg_points) {
+				chosen_memcg = iter;
+				chosen_memcg_points = points;
+				oc->chosen_points = points;
+			}
+
+			continue;
+		}
+
+		if (chosen_memcg && !chosen_memcg->oom_kill_all_tasks) {
+			/* Go deeper in the cgroup hierarchy */
+			totalpages = chosen_memcg_points;
+			chosen_memcg_points = 0;
+
+			parent = chosen_memcg;
+			chosen_memcg = NULL;
+
+			continue;
+		}
+
+		if (!chosen_memcg && parent != root_mem_cgroup)
+			chosen_memcg = parent;
+
+		break;
+	}
+
+	if (!oc->memcg) {
+		/*
+		 * We should also consider tasks in the root cgroup
+		 * with badness larger than oc->chosen_points
+		 */
+
+		struct css_task_iter it;
+		struct task_struct *task;
+		int ret = 0;
+
+		css_task_iter_start(&root_mem_cgroup->css, &it);
+		while (!ret && (task = css_task_iter_next(&it)))
+			ret = oom_evaluate_task(task, oc);
+		css_task_iter_end(&it);
+	}
+
+	if (!oc->chosen && chosen_memcg) {
+		pr_info("Chosen cgroup ");
+		pr_cont_cgroup_path(chosen_memcg->css.cgroup);
+		pr_cont(": %ld\n", oc->chosen_points);
+
+		if (chosen_memcg->oom_kill_all_tasks) {
+			css_get(&chosen_memcg->css);
+			oc->chosen_memcg = chosen_memcg;
+		} else {
+			/*
+			 * If we don't need to kill all tasks in the cgroup,
+			 * let's select the biggest task.
+			 */
+			oc->chosen_points = 0;
+			select_bad_process(oc, chosen_memcg);
+		}
+	} else if (oc->chosen)
+		pr_info("Chosen task %s (%d) in root cgroup: %ld\n",
+			oc->chosen->comm, oc->chosen->pid, oc->chosen_points);
+
+	rcu_read_unlock();
+
+	oc->chosen_points = 0;
+	return !!oc->chosen || !!oc->chosen_memcg;
+}
+
+static int __oom_kill_task(struct task_struct *tsk, void *arg)
+{
+	if (!is_global_init(tsk) && !(tsk->flags & PF_KTHREAD)) {
+		get_task_struct(tsk);
+		__oom_kill_process(tsk);
+	}
+	return 0;
+}
+
+bool mem_cgroup_kill_oom_victim(struct oom_control *oc)
+{
+	if (oc->chosen_memcg) {
+		/*
+		 * Kill all tasks in the cgroup hierarchy
+		 */
+		mem_cgroup_scan_tasks(oc->chosen_memcg,
+				      __oom_kill_task, NULL);
+
+		/*
+		 * Release oc->chosen_memcg
+		 */
+		css_put(&oc->chosen_memcg->css);
+		oc->chosen_memcg = NULL;
+	}
+
+	if (oc->chosen && oc->chosen != (void *)-1UL) {
+		__oom_kill_process(oc->chosen);
+		return true;
+	}
+
+	/*
+	 * Reset points before falling back to an old
+	 * per-process OOM victim selection logic
+	 */
+	oc->chosen_points = 0;
+
+	return !!oc->chosen;
+}
+
 /*
  * Reclaims as many pages from the given memcg as possible.
  *
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8cf77fb..1346565 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1039,6 +1039,12 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	if (mem_cgroup_select_oom_victim(oc) &&
+	    mem_cgroup_kill_oom_victim(oc)) {
+		schedule_timeout_killable(1);
+		return true;
+	}
+
 	select_bad_process(oc, oc->memcg);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
