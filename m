Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BADF6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 17:35:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l2-v6so2120925pff.3
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:35:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m68-v6sor1868526pfi.65.2018.06.21.14.35.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 14:35:22 -0700 (PDT)
Date: Thu, 21 Jun 2018 14:35:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
it cannot reap an mm.  This can happen for a variety of reasons,
including:

 - the inability to grab mm->mmap_sem in a sufficient amount of time,

 - when the mm has blockable mmu notifiers that could cause the oom reaper
   to stall indefinitely,

but we can also add a third when the oom reaper can "reap" an mm but doing
so is unlikely to free any amount of memory:

 - when the mm's memory is mostly mlocked.

When all memory is mlocked, the oom reaper will not be able to free any
substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
unmap and free its memory in exit_mmap() and subsequent oom victims are
chosen unnecessarily.  This is trivial to reproduce if all eligible
processes on the system have mlocked their memory: the oom killer calls
panic() even though forward progress can be made.

This is the same issue where the exit path sets MMF_OOM_SKIP before
unmapping memory and additional processes can be chosen unnecessarily
because the oom killer is racing with exit_mmap() and is separate from
the oom reaper setting MMF_OOM_SKIP prematurely.

We can't simply defer setting MMF_OOM_SKIP, however, because if there is
a true oom livelock in progress, it never gets set and no additional
killing is possible.

To fix this, this patch introduces a per-mm reaping period, which is
configurable through the new oom_free_timeout_ms file in debugfs and
defaults to one second to match the current heuristics.  This support
requires that the oom reaper's list becomes a proper linked list so that
other mm's may be reaped while waiting for an mm's timeout to expire.

This replaces the current timeouts in the oom reaper: (1) when trying to
grab mm->mmap_sem 10 times in a row with HZ/10 sleeps in between and (2)
a HZ sleep if there are blockable mmu notifiers.  It extends it with
timeout to allow an oom victim to reach exit_mmap() before choosing
additional processes unnecessarily.

The exit path will now set MMF_OOM_SKIP only after all memory has been
freed, so additional oom killing is justified, and rely on MMF_UNSTABLE to
determine when it can race with the oom reaper.

The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
lapsed because it can no longer guarantee forward progress.  Since the
default oom_free_timeout_ms is one second, the same as current heuristics,
there should be no functional change with this patch for users who do not
tune it to be longer other than MMF_OOM_SKIP is set by exit_mmap() after
free_pgtables(), which is the preferred behavior.

The reaping timeout can intentionally be set for a substantial amount of
time, such as 10s, since oom livelock is a very rare occurrence and it's
better to optimize for preventing additional (unnecessary) oom killing
than a scenario that is much more unlikely.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v3:
  - oom_free_timeout_ms is now static per kbuild test robot

 v2:
  - configurable timeout period through debugfs
  - change mm->reap_timeout to mm->oom_free_expire and add more
    descriptive comment per akpm
  - add comment to describe task->oom_reap_list locking based on
    oom_reaper_lock per akpm
  - rework the exit_mmap() comment and split into two parts to be more
    descriptive about the locking and the issue with the oom reaper
    racing with munlock_vma_pages_all() per akpm
---
 include/linux/mm_types.h |   7 ++
 include/linux/sched.h    |   3 +-
 kernel/fork.c            |   3 +
 mm/mmap.c                |  26 +++++---
 mm/oom_kill.c            | 140 +++++++++++++++++++++++++--------------
 5 files changed, 119 insertions(+), 60 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -449,6 +449,13 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_MMU
+	/*
+	 * When to give up on memory freeing from this mm after its
+	 * threads have been oom killed, in jiffies.
+	 */
+	unsigned long oom_free_expire;
+#endif
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1163,7 +1163,8 @@ struct task_struct {
 #endif
 	int				pagefault_disabled;
 #ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
+	/* OOM victim queue for oom reaper, protected by oom_reaper_lock */
+	struct list_head		oom_reap_list;
 #endif
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -842,6 +842,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 #ifdef CONFIG_FAULT_INJECTION
 	tsk->fail_nth = 0;
 #endif
+#ifdef CONFIG_MMU
+	INIT_LIST_HEAD(&tsk->oom_reap_list);
+#endif
 
 	return tsk;
 
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3059,25 +3059,28 @@ void exit_mmap(struct mm_struct *mm)
 	if (unlikely(mm_is_oom_victim(mm))) {
 		/*
 		 * Manually reap the mm to free as much memory as possible.
-		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
-		 * this mm from further consideration.  Taking mm->mmap_sem for
-		 * write after setting MMF_OOM_SKIP will guarantee that the oom
-		 * reaper will not run on this mm again after mmap_sem is
-		 * dropped.
-		 *
 		 * Nothing can be holding mm->mmap_sem here and the above call
 		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
 		 * __oom_reap_task_mm() will not block.
-		 *
-		 * This needs to be done before calling munlock_vma_pages_all(),
-		 * which clears VM_LOCKED, otherwise the oom reaper cannot
-		 * reliably test it.
 		 */
 		mutex_lock(&oom_lock);
 		__oom_reap_task_mm(mm);
 		mutex_unlock(&oom_lock);
 
-		set_bit(MMF_OOM_SKIP, &mm->flags);
+		/*
+		 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
+		 * This needs to be done before calling munlock_vma_pages_all(),
+		 * which clears VM_LOCKED, otherwise the oom reaper cannot
+		 * reliably test for it.  If the oom reaper races with
+		 * munlock_vma_pages_all(), this can result in a kernel oops if
+		 * a pmd is zapped, for example, after follow_page_mask() has
+		 * checked pmd_none().
+		 *
+		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
+		 * guarantee that the oom reaper will not run on this mm again
+		 * after mmap_sem is dropped.
+		 */
+		set_bit(MMF_UNSTABLE, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
@@ -3105,6 +3108,7 @@ void exit_mmap(struct mm_struct *mm)
 	unmap_vmas(&tlb, vma, 0, -1);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,7 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/debugfs.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -476,7 +477,7 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
+static LIST_HEAD(oom_reaper_list);
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 void __oom_reap_task_mm(struct mm_struct *mm)
@@ -519,10 +520,8 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 	}
 }
 
-static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+static void oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
-	bool ret = true;
-
 	/*
 	 * We have to make sure to not race with the victim exit path
 	 * and cause premature new oom victim selection:
@@ -540,9 +539,8 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	mutex_lock(&oom_lock);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		goto out_oom;
 	}
 
 	/*
@@ -551,69 +549,81 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * TODO: we really want to get rid of this ugly hack and make sure that
 	 * notifiers cannot block for unbounded amount of time
 	 */
-	if (mm_has_blockable_invalidate_notifiers(mm)) {
-		up_read(&mm->mmap_sem);
-		schedule_timeout_idle(HZ);
-		goto unlock_oom;
-	}
+	if (mm_has_blockable_invalidate_notifiers(mm))
+		goto out_mm;
 
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
+	 * MMF_UNSTABLE is set by exit_mmap when the OOM reaper can't
+	 * work on the mm anymore. The check for MMF_UNSTABLE must run
 	 * under mmap_sem for reading because it serializes against the
 	 * down_write();up_write() cycle in exit_mmap().
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
-		up_read(&mm->mmap_sem);
+	if (test_bit(MMF_UNSTABLE, &mm->flags)) {
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		goto out_mm;
 	}
 
 	trace_start_task_reaping(tsk->pid);
-
 	__oom_reap_task_mm(mm);
+	trace_finish_task_reaping(tsk->pid);
 
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+out_mm:
 	up_read(&mm->mmap_sem);
-
-	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
+out_oom:
 	mutex_unlock(&oom_lock);
-	return ret;
 }
 
-#define MAX_OOM_REAP_RETRIES 10
 static void oom_reap_task(struct task_struct *tsk)
 {
-	int attempts = 0;
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
-	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
-		schedule_timeout_idle(HZ/10);
+	/*
+	 * If this mm has either been fully unmapped, or the oom reaper has
+	 * given up on it, nothing left to do except drop the refcount.
+	 */
+	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+		goto drop;
 
-	if (attempts <= MAX_OOM_REAP_RETRIES ||
-	    test_bit(MMF_OOM_SKIP, &mm->flags))
-		goto done;
+	/*
+	 * If this mm has already been reaped, doing so again will not likely
+	 * free additional memory.
+	 */
+	if (!test_bit(MMF_UNSTABLE, &mm->flags))
+		oom_reap_task_mm(tsk, mm);
 
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
+	if (time_after_eq(jiffies, mm->oom_free_expire)) {
+		if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
+			pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+				task_pid_nr(tsk), tsk->comm);
+			debug_show_all_locks();
 
-done:
-	tsk->oom_reaper_list = NULL;
+			/*
+			 * Reaping has failed for the timeout period, so give up
+			 * and allow additional processes to be oom killed.
+			 */
+			set_bit(MMF_OOM_SKIP, &mm->flags);
+		}
+		goto drop;
+	}
 
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+		goto drop;
+
+	/* Enqueue to be reaped again */
+	spin_lock(&oom_reaper_lock);
+	list_add_tail(&tsk->oom_reap_list, &oom_reaper_list);
+	spin_unlock(&oom_reaper_lock);
 
-	/* Drop a reference taken by wake_oom_reaper */
+	schedule_timeout_idle(HZ/10);
+	return;
+
+drop:
+	/* Drop the reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
 }
 
@@ -622,11 +632,13 @@ static int oom_reaper(void *unused)
 	while (true) {
 		struct task_struct *tsk = NULL;
 
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
+		wait_event_freezable(oom_reaper_wait,
+				     !list_empty(&oom_reaper_list));
 		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
+		if (!list_empty(&oom_reaper_list)) {
+			tsk = list_entry(oom_reaper_list.next,
+					 struct task_struct, oom_reap_list);
+			list_del(&tsk->oom_reap_list);
 		}
 		spin_unlock(&oom_reaper_lock);
 
@@ -637,25 +649,57 @@ static int oom_reaper(void *unused)
 	return 0;
 }
 
+/*
+ * Millisecs to wait for an oom mm to free memory before selecting another
+ * victim.
+ */
+static u64 oom_free_timeout_ms = 1000;
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	/*
+	 * Set the reap timeout; if it's already set, the mm is enqueued and
+	 * this tsk can be ignored.
+	 */
+	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL,
+			jiffies + msecs_to_jiffies(oom_free_timeout_ms)))
 		return;
 
 	get_task_struct(tsk);
 
 	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
+	list_add(&tsk->oom_reap_list, &oom_reaper_list);
 	spin_unlock(&oom_reaper_lock);
 	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
 }
 
+#ifdef CONFIG_DEBUG_FS
+static int oom_free_timeout_ms_read(void *data, u64 *val)
+{
+	*val = oom_free_timeout_ms;
+	return 0;
+}
+
+static int oom_free_timeout_ms_write(void *data, u64 val)
+{
+	if (val > 60 * 1000)
+		return -EINVAL;
+
+	oom_free_timeout_ms = val;
+	return 0;
+}
+DEFINE_SIMPLE_ATTRIBUTE(oom_free_timeout_ms_fops, oom_free_timeout_ms_read,
+			oom_free_timeout_ms_write, "%llu\n");
+#endif /* CONFIG_DEBUG_FS */
+
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
+#ifdef CONFIG_DEBUG_FS
+	if (!IS_ERR(oom_reaper_th))
+		debugfs_create_file("oom_free_timeout_ms", 0200, NULL, NULL,
+				    &oom_free_timeout_ms_fops);
+#endif
 	return 0;
 }
 subsys_initcall(oom_init)
