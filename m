Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98C9A6B0267
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:31:21 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j8so34520078itb.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:31:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m5si8246700ite.125.2016.07.12.06.31.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:31:15 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
Date: Tue, 12 Jul 2016 22:29:18 +0900
Message-Id: <1468330163-4405-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Currently, we walk process list in order to find existing TIF_MEMDIE
threads. But if we remember list of mm_struct used by TIF_MEMDIE threads,
we can avoid walking process list. Later patch in the series will change
OOM reaper to use list of mm_struct introduced by this patch.

Also, we can start using TIF_MEMDIE only for the access to memory reserves
to oom victims which actually need to allocate and decouple the current
double meaning. Later patch in the series will eliminate OOM_SCAN_ABORT
case and "struct signal_struct"->oom_victims because oom_has_pending_mm()
introduced by this patch can take that role.

It is theoretically possible that the number of elements on this list
grows as many as the number of configured memcg groups and
mempolicy/cpuset patterns. But in most cases, the OOM reaper will
immediately remove almost all elements in first OOM reap attempt.
Moreover, many of OOM events can be solved before the OOM reaper tries
to OOM reap that memory. Therefore, the average speed of removing
elements will be faster than the average speed of adding elements.
If delay caused by retrying specific element for one second before
trying other elements matters, we can do parallel OOM reaping.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/mm_types.h |  7 +++++
 include/linux/oom.h      |  3 +++
 kernel/fork.c            |  2 ++
 mm/memcontrol.c          |  5 ++++
 mm/oom_kill.c            | 69 +++++++++++++++++++++++++++++++++++++++++-------
 5 files changed, 77 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 79472b2..96a8709 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -392,6 +392,12 @@ struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
 };
 
+struct oom_mm {
+	struct list_head list; /* Linked to oom_mm_list list. */
+	/* Thread which was passed to mark_oom_victim() for the last time. */
+	struct task_struct *victim;
+};
+
 struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
@@ -515,6 +521,7 @@ struct mm_struct {
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
 #endif
+	struct oom_mm oom_mm;
 #ifdef CONFIG_MMU
 	struct work_struct async_put_work;
 #endif
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457..bdcb331 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -91,6 +91,9 @@ extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 extern void check_panic_on_oom(struct oom_control *oc,
 			       enum oom_constraint constraint);
 
+extern void exit_oom_mm(struct mm_struct *mm);
+extern bool oom_has_pending_mm(struct mem_cgroup *memcg,
+			       const nodemask_t *nodemask);
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 					       struct task_struct *task);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 7926993..d83163a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -722,6 +722,8 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (mm->oom_mm.victim)
+		exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40dfca3..8f7a5b7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1241,6 +1241,11 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	}
 
 	check_panic_on_oom(&oc, CONSTRAINT_MEMCG);
+	if (oom_has_pending_mm(memcg, NULL)) {
+		/* Set a dummy value to return "true". */
+		chosen = (void *) 1;
+		goto unlock;
+	}
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9f0022e..07e8c1a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -132,6 +132,20 @@ static inline bool is_sysrq_oom(struct oom_control *oc)
 	return oc->order == -1;
 }
 
+static bool task_in_oom_domain(struct task_struct *p, struct mem_cgroup *memcg,
+			       const nodemask_t *nodemask)
+{
+	/* When mem_cgroup_out_of_memory() and p is not member of the group */
+	if (memcg && !task_in_mem_cgroup(p, memcg))
+		return false;
+
+	/* p may not have freeable memory in nodemask */
+	if (!has_intersects_mems_allowed(p, nodemask))
+		return false;
+
+	return true;
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -141,15 +155,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (p->flags & PF_KTHREAD)
 		return true;
 
-	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
-
-	/* p may not have freeable memory in nodemask */
-	if (!has_intersects_mems_allowed(p, nodemask))
-		return true;
-
-	return false;
+	return !task_in_oom_domain(p, memcg, nodemask);
 }
 
 /**
@@ -275,6 +281,34 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+static LIST_HEAD(oom_mm_list);
+static DEFINE_SPINLOCK(oom_mm_lock);
+
+void exit_oom_mm(struct mm_struct *mm)
+{
+	spin_lock(&oom_mm_lock);
+	list_del(&mm->oom_mm.list);
+	spin_unlock(&oom_mm_lock);
+	put_task_struct(mm->oom_mm.victim);
+	mmdrop(mm);
+}
+
+bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+{
+	struct mm_struct *mm;
+	bool ret = false;
+
+	spin_lock(&oom_mm_lock);
+	list_for_each_entry(mm, &oom_mm_list, oom_mm.list) {
+		if (task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask)) {
+			ret = true;
+			break;
+		}
+	}
+	spin_unlock(&oom_mm_lock);
+	return ret;
+}
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 					struct task_struct *task)
 {
@@ -653,6 +687,8 @@ subsys_initcall(oom_init)
  */
 void mark_oom_victim(struct task_struct *tsk)
 {
+	struct mm_struct *mm = tsk->mm;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
@@ -666,6 +702,18 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+	/*
+	 * Since mark_oom_victim() is called from multiple threads,
+	 * connect this mm to oom_mm_list only if not yet connected.
+	 */
+	if (!mm->oom_mm.victim) {
+		atomic_inc(&mm->mm_count);
+		get_task_struct(tsk);
+		mm->oom_mm.victim = tsk;
+		spin_lock(&oom_mm_lock);
+		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+		spin_unlock(&oom_mm_lock);
+	}
 }
 
 /**
@@ -1026,6 +1074,9 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	if (!is_sysrq_oom(oc) && oom_has_pending_mm(oc->memcg, oc->nodemask))
+		return true;
+
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p && !is_sysrq_oom(oc)) {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
