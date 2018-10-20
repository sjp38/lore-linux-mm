Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBF46B0003
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 06:57:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id j47so26659334ota.16
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 03:57:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 46si13154216oty.291.2018.10.20.03.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Oct 2018 03:57:41 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Use timeout based back off.
Date: Sat, 20 Oct 2018 19:57:01 +0900
Message-Id: <1540033021-3258-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

This patch changes the OOM killer to wait for either

  (A) __mmput() of the OOM victim's mm completes

or

  (B) the OOM reaper gives up waiting for (A) because memory pages
      used by the OOM victim's mm did not decrease for one second

in order to mitigate at least three problems

  (1) an OOM victim needlessly selects next OOM victim if the OOM-killed
      processes are using clone(CLONE_VM) without CLONE_THREAD because
      task_will_free_mem(current) in out_of_memory() returns false when
      MMF_OOM_SKIP was set before remaining OOM-killed processes reach
      out_of_memory().

  (2) an memcg OOM event needlessly selects next OOM victim because we
      are assuming that the OOM reaper can reclaim majority of the OOM
      victim's mm, but sometimes we need to wait for completion of
      free_pgtables() in exit_mmap() in order to reclaim enough memory.

  (3) an memcg OOM event from a multithreaded process by an unprivileged
      user can needlessly trigger flooding of "Out of memory and no
      killable processes..." and dump_header() messages because
      task_will_free_mem(current) in out_of_memory() returns false when
      MMF_OOM_SKIP was set before remaining OOM-killed threads reach
      out_of_memory().

all caused by setting MMF_OOM_SKIP too early.

Michal has proposed an attempt to handover setting of MMF_OOM_SKIP to
the OOM victim's exit path [1] in order to handle (2), but there was no
feedback (except me) and nobody knows whether it is really safe and is
worth constrain future changes. Not only that attempt can mitigate only
portion of exit_mmap() (rather than until the OOM victim thread becomes
invisible from the OOM killer), that attempt does not help at all for (1)
and (3) because __mmput() cannot be called.

I have proposed many patches which mitigate (1) and (3) without using
timeout based approach, but Michal is rejecting them and wants to address
the root cause that MMF_OOM_SKIP is set too early. And nobody (including
Michal) has time to make the OOM reaper reclaim more memory (including
mlock()ed and shared memory, and mmap_sem contention) before setting
MMF_OOM_SKIP. We are deadlocked there.

Michal has been refusing timeout based approach, but I don't think this
is something we have to be frayed around the edge about possibility of
overlooking races/bugs just because Michal does not want to use timeout.
I believe that timeout based back off is the only approach we can use
for now.

[1] https://marc.info/?i=20180910125513.311-1-mhocko@kernel.org

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |   2 +-
 kernel/fork.c       |  13 ++++++
 mm/mmap.c           |  44 +++++++-----------
 mm/oom_kill.c       | 126 ++++++++++++++++++++++++----------------------------
 4 files changed, 87 insertions(+), 98 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 69864a5..cb7300d 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -95,7 +95,7 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 	return 0;
 }
 
-bool __oom_reap_task_mm(struct mm_struct *mm);
+void oom_reap_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
diff --git a/kernel/fork.c b/kernel/fork.c
index f0b5847..1270873 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -992,7 +992,18 @@ struct mm_struct *mm_alloc(void)
 
 static inline void __mmput(struct mm_struct *mm)
 {
+	const bool oom = mm_is_oom_victim(mm);
+
 	VM_BUG_ON(atomic_read(&mm->mm_users));
+	if (IS_ENABLED(CONFIG_MMU) && oom) {
+		/* Try what the OOM reaper kernel thread can afford. */
+		down_read(&mm->mmap_sem);
+		oom_reap_mm(mm);
+		up_read(&mm->mmap_sem);
+		/* Shut out the OOM reaper kernel thread. */
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+	}
 
 	uprobe_clear_state(mm);
 	exit_aio(mm);
@@ -1008,6 +1019,8 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	if (oom)
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 	mmdrop(mm);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index f7cd9cb..5f1908b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3042,41 +3042,29 @@ void exit_mmap(struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
+	const bool oom = mm_is_oom_victim(mm);
 
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
-
-	if (unlikely(mm_is_oom_victim(mm))) {
-		/*
-		 * Manually reap the mm to free as much memory as possible.
-		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
-		 * this mm from further consideration.  Taking mm->mmap_sem for
-		 * write after setting MMF_OOM_SKIP will guarantee that the oom
-		 * reaper will not run on this mm again after mmap_sem is
-		 * dropped.
-		 *
-		 * Nothing can be holding mm->mmap_sem here and the above call
-		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
-		 * __oom_reap_task_mm() will not block.
-		 *
-		 * This needs to be done before calling munlock_vma_pages_all(),
-		 * which clears VM_LOCKED, otherwise the oom reaper cannot
-		 * reliably test it.
-		 */
-		(void)__oom_reap_task_mm(mm);
-
-		set_bit(MMF_OOM_SKIP, &mm->flags);
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
-	}
+	/*
+	 * The OOM reaper kernel thread was already shut out at __mmput().
+	 * Retry what the OOM reaper kernel thread can afford, for all MMU
+	 * notifiers are now gone. Since nothing can be holding mm->mmap_sem,
+	 * there is no need to hold mmap_sem here.
+	 */
+	if (oom)
+		oom_reap_mm(mm);
 
 	if (mm->locked_vm) {
-		vma = mm->mmap;
-		while (vma) {
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
 			if (vma->vm_flags & VM_LOCKED)
 				munlock_vma_pages_all(vma);
-			vma = vma->vm_next;
-		}
+		/*
+		 * Retry what the OOM reaper kernel thread can afford, for
+		 * all mlocked vmas are now unlocked.
+		 */
+		if (oom)
+			oom_reap_mm(mm);
 	}
 
 	arch_exit_mmap(mm);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..b2e381b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -189,6 +189,16 @@ static bool is_dump_unreclaim_slabs(void)
 	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
 }
 
+/*
+ * Rough memory consumption of the given mm which should be theoretically freed
+ * when the mm is removed.
+ */
+static unsigned long oom_badness_pages(struct mm_struct *mm)
+{
+	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
+		mm_pgtables_bytes(mm) / PAGE_SIZE;
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -230,8 +240,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_badness_pages(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -488,10 +497,9 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-bool __oom_reap_task_mm(struct mm_struct *mm)
+void oom_reap_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
-	bool ret = true;
 
 	/*
 	 * Tell all users of get_user/copy_from_user etc... that the content
@@ -501,7 +509,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	 */
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
-	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
 
@@ -523,7 +531,6 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			tlb_gather_mmu(&tlb, mm, start, end);
 			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
 				tlb_finish_mmu(&tlb, start, end);
-				ret = false;
 				continue;
 			}
 			unmap_page_range(&tlb, vma, start, end, NULL);
@@ -531,54 +538,29 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			tlb_finish_mmu(&tlb, start, end);
 		}
 	}
-
-	return ret;
 }
 
-/*
- * Reaps the address space of the give task.
- *
- * Returns true on success and false if none or part of the address space
- * has been reclaimed and the caller should retry later.
- */
-static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+/* Reaps the address space of the give task. */
+static void __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
-	bool ret = true;
-
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		trace_skip_task_reaping(tsk->pid);
-		return false;
-	}
-
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
+	 * Reaping operation needs mmap_sem held for read. Also, the check for
+	 * mm_users must run under mmap_sem for reading because it serializes
+	 * against the down_write()/up_write() cycle in __mmput().
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
-		trace_skip_task_reaping(tsk->pid);
-		goto out_unlock;
+	if (!down_read_trylock(&mm->mmap_sem)) {
+		/* Do nothing if already in __mmput(). */
+		if (atomic_read(&mm->mm_users))
+			trace_skip_task_reaping(tsk->pid);
+		return;
+	}
+	/* Do nothing if already in __mmput(). */
+	if (atomic_read(&mm->mm_users)) {
+		trace_start_task_reaping(tsk->pid);
+		oom_reap_mm(mm);
+		trace_finish_task_reaping(tsk->pid);
 	}
-
-	trace_start_task_reaping(tsk->pid);
-
-	/* failed to reap part of the address space. Try again later */
-	ret = __oom_reap_task_mm(mm);
-	if (!ret)
-		goto out_finish;
-
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-			task_pid_nr(tsk), tsk->comm,
-			K(get_mm_counter(mm, MM_ANONPAGES)),
-			K(get_mm_counter(mm, MM_FILEPAGES)),
-			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-out_finish:
-	trace_finish_task_reaping(tsk->pid);
-out_unlock:
 	up_read(&mm->mmap_sem);
-
-	return ret;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
@@ -586,29 +568,32 @@ static void oom_reap_task(struct task_struct *tsk)
 {
 	int attempts = 0;
 	struct mm_struct *mm = tsk->signal->oom_mm;
+	unsigned long last_oom_pages = oom_badness_pages(mm);
+	unsigned long pages;
 
-	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
+	while (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
+		__oom_reap_task_mm(tsk, mm);
 		schedule_timeout_idle(HZ/10);
-
-	if (attempts <= MAX_OOM_REAP_RETRIES ||
-	    test_bit(MMF_OOM_SKIP, &mm->flags))
-		goto done;
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
-done:
+		pages = oom_badness_pages(mm);
+		if (last_oom_pages > pages) {
+			last_oom_pages = pages;
+			attempts = 0;
+			continue;
+		}
+		if (attempts++ <= MAX_OOM_REAP_RETRIES)
+			continue;
+		/* Hide this mm from OOM killer if stalled for too long. */
+		pr_info("oom_reaper: gave up process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+			task_pid_nr(tsk), tsk->comm,
+			K(get_mm_counter(mm, MM_ANONPAGES)),
+			K(get_mm_counter(mm, MM_FILEPAGES)),
+			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+		debug_show_all_locks();
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+		break;
+	}
 	tsk->oom_reaper_list = NULL;
-
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-
-	/* Drop a reference taken by wake_oom_reaper */
+	/* Drop a reference taken by wake_oom_reaper(). */
 	put_task_struct(tsk);
 }
 
@@ -634,9 +619,12 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	struct mm_struct *mm = tsk->signal->oom_mm;
+
+	/* There is no point with processing same mm twice. */
+	if (test_bit(MMF_UNSTABLE, &mm->flags))
 		return;
+	set_bit(MMF_UNSTABLE, &mm->flags);
 
 	get_task_struct(tsk);
 
-- 
1.8.3.1
