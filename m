Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1651C6B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:03:23 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d132so38225863oig.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:03:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y198si2379868oia.31.2016.07.07.09.03.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 09:03:22 -0700 (PDT)
Subject: [PATCH 3/6] mm,oom: Use list of mm_struct used by OOM victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
In-Reply-To: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
Message-Id: <201607080103.CDH12401.LFOHStQFOOFVJM@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 01:03:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From 5fbd16cffd5dc51f9ba8591fc18d315ff6ff9b96 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 00:33:13 +0900
Subject: [PATCH 3/6] mm,oom: Use list of mm_struct used by OOM victims.

Currently, we walk process list in order to find existing TIF_MEMDIE
threads. But if we remember list of mm_struct used by TIF_MEMDIE threads,
we can avoid walking process list. Next patch in this series allows
OOM reaper to use list of mm_struct introduced by this patch.

This patch reverts commit e2fe14564d3316d1 ("oom_reaper: close race with
exiting task") because oom_has_pending_mm() will prevent that race.

Since CONFIG_MMU=y kernel has OOM reaper callback hook which can remove
mm_struct from the list, let the OOM reaper call exit_oom_mm(mm). This
patch temporarily fails to call exit_oom_mm(mm) when find_lock_task_mm()
in oom_reap_task() failed. It will be fixed by next patch.

But since CONFIG_MMU=n kernel does not have OOM reaper callback hook,
call exit_oom_mm(mm) from __mmput(mm) if that mm is used by OOM victims.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/mm_types.h |  7 +++++
 include/linux/oom.h      |  3 ++
 kernel/fork.c            |  4 +++
 mm/memcontrol.c          |  5 ++++
 mm/oom_kill.c            | 72 +++++++++++++++++++++++++++++++-----------------
 5 files changed, 66 insertions(+), 25 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e093e1d..7c1370a 100644
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
index 7926993..8e469e0 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -722,6 +722,10 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+#ifndef CONFIG_MMU
+	if (mm->oom_mm.victim)
+		exit_oom_mm(mm);
+#endif
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
index 9f0022e..87e7ff3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -275,6 +275,28 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+static LIST_HEAD(oom_mm_list);
+
+void exit_oom_mm(struct mm_struct *mm)
+{
+	mutex_lock(&oom_lock);
+	list_del(&mm->oom_mm.list);
+	put_task_struct(mm->oom_mm.victim);
+	mm->oom_mm.victim = NULL;
+	mmdrop(mm);
+	mutex_unlock(&oom_lock);
+}
+
+bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+{
+	struct mm_struct *mm;
+
+	list_for_each_entry(mm, &oom_mm_list, oom_mm.list)
+		if (!oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
+			return true;
+	return false;
+}
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 					struct task_struct *task)
 {
@@ -458,28 +480,9 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
-	bool ret = true;
 
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
-	mutex_lock(&oom_lock);
-
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		goto unlock_oom;
-	}
+	if (!down_read_trylock(&mm->mmap_sem))
+		return false;
 
 	/*
 	 * increase mm_users only after we know we will reap something so
@@ -488,7 +491,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto unlock_oom;
+		return true;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -536,9 +539,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
@@ -586,6 +587,9 @@ done:
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
+	/* Drop references taken by mark_oom_victim() */
+	if (mm)
+		exit_oom_mm(mm);
 	/* Drop a reference taken above. */
 	if (mm)
 		mmdrop(mm);
@@ -653,6 +657,9 @@ subsys_initcall(oom_init)
  */
 void mark_oom_victim(struct task_struct *tsk)
 {
+	struct mm_struct *mm = tsk->mm;
+	struct task_struct *old_tsk = mm->oom_mm.victim;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
@@ -666,6 +673,18 @@ void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+	/*
+	 * Since mark_oom_victim() is called from multiple threads,
+	 * connect this mm to oom_mm_list only if not yet connected.
+	 */
+	get_task_struct(tsk);
+	mm->oom_mm.victim = tsk;
+	if (!old_tsk) {
+		atomic_inc(&mm->mm_count);
+		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+	} else {
+		put_task_struct(old_tsk);
+	}
 }
 
 /**
@@ -1026,6 +1045,9 @@ bool out_of_memory(struct oom_control *oc)
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
