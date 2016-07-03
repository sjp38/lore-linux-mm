Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89D456B025F
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:38:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so320280967pfa.2
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:38:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id sk10si1331418pab.243.2016.07.02.19.38.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:38:33 -0700 (PDT)
Subject: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Message-Id: <201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:38:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From d86a4340be775bd00217e596ed7f2d65f45b58cb Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 2 Jul 2016 22:56:21 +0900
Subject: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.

Currently, we walk process list in order to find existing TIF_MEMDIE
threads. But if we remember list of mm_struct used by TIF_MEMDIE threads,
we can avoid walking process list. Future patch in this series allows
OOM reaper to use list of mm_struct introduced by this patch.

This patch reverts commit e2fe14564d3316d1 ("oom_reaper: close race with
exiting task") because oom_has_pending_mm() will prevent that race.

Due to oom_has_pending_mm() remaining true until that mm is removed,
this patch temporarily breaks what commit 36324a990cf578b5 ("oom: clear
TIF_MEMDIE after oom_reaper managed to unmap the address space") and
commit 449d777d7ad6d7f9 ("mm, oom_reaper: clear TIF_MEMDIE for all tasks
queued for oom_reaper") tried to address. Future patch in this series
will fix it.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/mm_types.h |   8 ++++
 include/linux/oom.h      |   5 ++-
 kernel/fork.c            |   1 +
 mm/memcontrol.c          |   7 +++-
 mm/oom_kill.c            | 101 +++++++++++++++++++++++++++++++++--------------
 5 files changed, 91 insertions(+), 31 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e093e1d..718c0bd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <linux/workqueue.h>
+#include <linux/nodemask.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -392,6 +393,12 @@ struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
 };
 
+struct oom_mm {
+	struct list_head list; /* Linked to oom_mm_list list. */
+	struct mem_cgroup *memcg; /* No deref. Maybe NULL. */
+	const nodemask_t *nodemask; /* No deref. Maybe NULL. */
+};
+
 struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
@@ -515,6 +522,7 @@ struct mm_struct {
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
 #endif
+	struct oom_mm oom_mm;
 #ifdef CONFIG_MMU
 	struct work_struct async_put_work;
 #endif
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457..1e538c5 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -70,7 +70,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return p->signal->oom_flag_origin;
 }
 
-extern void mark_oom_victim(struct task_struct *tsk);
+extern void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc);
 
 #ifdef CONFIG_MMU
 extern void wake_oom_reaper(struct task_struct *tsk);
@@ -91,6 +91,9 @@ extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 extern void check_panic_on_oom(struct oom_control *oc,
 			       enum oom_constraint constraint);
 
+extern void exit_oom_mm(struct mm_struct *mm);
+extern bool oom_has_pending_mm(struct mem_cgroup *memcg,
+			       const nodemask_t *nodemask);
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 					       struct task_struct *task);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 7926993..b870dbc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -722,6 +722,7 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	exit_oom_mm(mm);
 	mmdrop(mm);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40dfca3..835c95c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1235,12 +1235,17 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
+		mark_oom_victim(current, &oc);
 		wake_oom_reaper(current);
 		goto unlock;
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
index 76c765e..39c5034 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -275,6 +275,48 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
+static LIST_HEAD(oom_mm_list);
+static DEFINE_SPINLOCK(oom_mm_lock);
+
+void exit_oom_mm(struct mm_struct *mm)
+{
+	bool remove;
+
+	/*
+	 * Since exit_oom_mm() can be concurrently called by exiting thread
+	 * and the OOM reaper thread, disconnect this mm from oom_mm_list
+	 * only if still connected.
+	 */
+	spin_lock(&oom_mm_lock);
+	remove = mm->oom_mm.list.next;
+	if (remove) {
+		list_del(&mm->oom_mm.list);
+		mm->oom_mm.list.next = NULL;
+	}
+	spin_unlock(&oom_mm_lock);
+	/* Drop a reference taken by mark_oom_victim() */
+	if (remove)
+		mmdrop(mm);
+}
+
+bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+{
+	struct oom_mm *mm;
+	bool ret = false;
+
+	spin_lock(&oom_mm_lock);
+	list_for_each_entry(mm, &oom_mm_list, list) {
+		if (memcg && mm->memcg != memcg)
+			continue;
+		if (nodemask && mm->nodemask != nodemask)
+			continue;
+		ret = true;
+		break;
+	}
+	spin_unlock(&oom_mm_lock);
+	return ret;
+}
+
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 					struct task_struct *task)
 {
@@ -457,28 +499,9 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
-	bool ret = true;
-
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
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		goto unlock_oom;
-	}
+	if (!down_read_trylock(&mm->mmap_sem))
+		return false;
 
 	/*
 	 * increase mm_users only after we know we will reap something so
@@ -487,7 +510,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto unlock_oom;
+		return true;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -535,9 +558,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
@@ -647,18 +668,37 @@ subsys_initcall(oom_init)
 /**
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
+ * @oc: oom_control
  *
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
  */
-void mark_oom_victim(struct task_struct *tsk)
+void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
 {
+	struct mm_struct *mm = tsk->mm;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 	atomic_inc(&tsk->signal->oom_victims);
 	/*
+	 * Since mark_oom_victim() is called from multiple threads,
+	 * connect this mm to oom_mm_list only if not yet connected.
+	 *
+	 * Since mark_oom_victim() is called with a stable mm (i.e.
+	 * mm->mm_userst > 0), exit_oom_mm() from __mmput() can't be called
+	 * before we add this mm to the list.
+	 */
+	spin_lock(&oom_mm_lock);
+	if (!mm->oom_mm.list.next) {
+		atomic_inc(&mm->mm_count);
+		mm->oom_mm.memcg = oc->memcg;
+		mm->oom_mm.nodemask = oc->nodemask;
+		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+	}
+	spin_unlock(&oom_mm_lock);
+	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
 	 * any memory and livelock. freezing_slow_path will tell the freezer
@@ -815,7 +855,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
+		mark_oom_victim(p, oc);
 		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
@@ -876,7 +916,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
+	mark_oom_victim(victim, oc);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -994,7 +1034,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
+		mark_oom_victim(current, oc);
 		wake_oom_reaper(current);
 		return true;
 	}
@@ -1026,6 +1066,9 @@ bool out_of_memory(struct oom_control *oc)
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
