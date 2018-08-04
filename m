Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 004196B0008
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 09:30:08 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 90-v6so4883524pla.18
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 06:30:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x4-v6si7158650pga.320.2018.08.04.06.30.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Aug 2018 06:30:06 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/4] mm, oom: Remove unused "abort" path.
Date: Sat,  4 Aug 2018 22:29:45 +0900
Message-Id: <1533389386-3501-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>

Since oom_evaluate_task() no longer aborts, we can remove no longer
used "abort" path in the callers.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h |  9 ++++-----
 mm/memcontrol.c            | 18 +++++-------------
 mm/oom_kill.c              | 34 ++++++++++++++++------------------
 3 files changed, 25 insertions(+), 36 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 652f602..396b01d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -417,8 +417,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
-int mem_cgroup_scan_tasks(struct mem_cgroup *,
-			  int (*)(struct task_struct *, void *), void *);
+void mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
+			   void (*fn)(struct task_struct *, void *), void *arg);
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
@@ -917,10 +917,9 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
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
index 4e3c131..f743778 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1058,17 +1058,14 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
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
 
@@ -1077,15 +1074,10 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
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
index a743a8e..783f04d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -312,13 +312,13 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
-static int oom_evaluate_task(struct task_struct *task, void *arg)
+static void oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
 	unsigned long points;
 
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
-		goto next;
+		return;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -331,24 +331,22 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 
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
 }
 
 /*
  * Simple selection loop. We choose the process with the highest number of
- * 'points'. In case scan was aborted, oc->chosen is set to -1.
+ * 'points'.
  */
 static void select_bad_process(struct oom_control *oc)
 {
@@ -359,8 +357,7 @@ static void select_bad_process(struct oom_control *oc)
 
 		rcu_read_lock();
 		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
-				break;
+			oom_evaluate_task(p, oc);
 		rcu_read_unlock();
 	}
 
@@ -876,13 +873,12 @@ static void __oom_kill_process(struct task_struct *victim)
  * Kill provided task unless it's secured by setting
  * oom_score_adj to OOM_SCORE_ADJ_MIN.
  */
-static int oom_kill_memcg_member(struct task_struct *task, void *unused)
+static void oom_kill_memcg_member(struct task_struct *task, void *unused)
 {
 	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(task);
 		__oom_kill_process(task);
 	}
-	return 0;
 }
 
 static void oom_kill_process(struct oom_control *oc, const char *message)
@@ -1098,14 +1094,16 @@ bool out_of_memory(struct oom_control *oc)
 
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
-		dump_header(oc, NULL);
-		panic("Out of memory and no killable processes...\n");
+	if (!oc->chosen) {
+		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+			dump_header(oc, NULL);
+			panic("Out of memory and no killable processes...\n");
+		}
+		return false;
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
