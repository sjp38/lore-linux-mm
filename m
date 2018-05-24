Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB0F6B026B
	for <linux-mm@kvack.org>; Thu, 24 May 2018 17:22:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d64-v6so64134pfd.13
        for <linux-mm@kvack.org>; Thu, 24 May 2018 14:22:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor5854007pgn.47.2018.05.24.14.22.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 14:22:56 -0700 (PDT)
Date: Thu, 24 May 2018 14:22:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
it cannot reap an mm.  This can happen for a variety of reasons,
including:

 - the inability to grab mm->mmap_sem in a sufficient amount of time,

 - when the mm has blockable mmu notifiers that could cause the oom reaper
   to stall indefinitely,

but we can also add a third when the oom reaper can "reap" an mm but doing
so is unlikely to free any amount of memory:

 - when the mm's memory is fully mlocked.

When all memory is mlocked, the oom reaper will not be able to free any
substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
unmap and free its memory in exit_mmap() and subsequent oom victims are
chosen unnecessarily.  This is trivial to reproduce if all eligible
processes on the system have mlocked their memory: the oom killer calls
panic() even though forward progress can be made.

This is the same issue where the exit path sets MMF_OOM_SKIP before
unmapping memory and additional processes can be chosen unnecessarily
because the oom killer is racing with exit_mmap().

We can't simply defer setting MMF_OOM_SKIP, however, because if there is
a true oom livelock in progress, it never gets set and no additional
killing is possible.

To fix this, this patch introduces a per-mm reaping timeout, initially set
at 10s.  It requires that the oom reaper's list becomes a properly linked
list so that other mm's may be reaped while waiting for an mm's timeout to
expire.

The exit path will now set MMF_OOM_SKIP only after all memory has been
freed, so additional oom killing is justified, and rely on MMF_UNSTABLE to
determine when it can race with the oom reaper.

The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
lapsed because it can no longer guarantee forward progress.

The reaping timeout is intentionally set for a substantial amount of time
since oom livelock is a very rare occurrence and it's better to optimize
for preventing additional (unnecessary) oom killing than a scenario that
is much more unlikely.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mm_types.h |  4 ++
 include/linux/sched.h    |  2 +-
 mm/mmap.c                | 12 +++---
 mm/oom_kill.c            | 85 ++++++++++++++++++++++++++--------------
 4 files changed, 66 insertions(+), 37 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -462,6 +462,10 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_MMU
+	/* When to give up on oom reaping this mm */
+	unsigned long reap_timeout;
+#endif
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1151,7 +1151,7 @@ struct task_struct {
 #endif
 	int				pagefault_disabled;
 #ifdef CONFIG_MMU
-	struct task_struct		*oom_reaper_list;
+	struct list_head		oom_reap_list;
 #endif
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3059,11 +3059,10 @@ void exit_mmap(struct mm_struct *mm)
 	if (unlikely(mm_is_oom_victim(mm))) {
 		/*
 		 * Manually reap the mm to free as much memory as possible.
-		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
-		 * this mm from further consideration.  Taking mm->mmap_sem for
-		 * write after setting MMF_OOM_SKIP will guarantee that the oom
-		 * reaper will not run on this mm again after mmap_sem is
-		 * dropped.
+		 * Then, set MMF_UNSTABLE to avoid racing with the oom reaper.
+		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
+		 * guarantee that the oom reaper will not run on this mm again
+		 * after mmap_sem is dropped.
 		 *
 		 * Nothing can be holding mm->mmap_sem here and the above call
 		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
@@ -3077,7 +3076,7 @@ void exit_mmap(struct mm_struct *mm)
 		__oom_reap_task_mm(mm);
 		mutex_unlock(&oom_lock);
 
-		set_bit(MMF_OOM_SKIP, &mm->flags);
+		set_bit(MMF_UNSTABLE, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
@@ -3105,6 +3104,7 @@ void exit_mmap(struct mm_struct *mm)
 	unmap_vmas(&tlb, vma, 0, -1);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -476,7 +476,7 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
+static LIST_HEAD(oom_reaper_list);
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 void __oom_reap_task_mm(struct mm_struct *mm)
@@ -558,12 +558,12 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
+	 * MMF_UNSTABLE is set by exit_mmap when the OOM reaper can't
+	 * work on the mm anymore. The check for MMF_UNSTABLE must run
 	 * under mmap_sem for reading because it serializes against the
 	 * down_write();up_write() cycle in exit_mmap().
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+	if (test_bit(MMF_UNSTABLE, &mm->flags)) {
 		up_read(&mm->mmap_sem);
 		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
@@ -589,31 +589,49 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 #define MAX_OOM_REAP_RETRIES 10
 static void oom_reap_task(struct task_struct *tsk)
 {
-	int attempts = 0;
 	struct mm_struct *mm = tsk->signal->oom_mm;
+	bool ret = true;
 
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
+		ret = oom_reap_task_mm(tsk, mm);
+
+	if (time_after(jiffies, mm->reap_timeout)) {
+		if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
+			pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+				task_pid_nr(tsk), tsk->comm);
+			debug_show_all_locks();
 
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
+			/*
+			 * Reaping has failed for the timeout period, so give up
+			 * and allow additional processes to be oom killed.
+			 */
+			set_bit(MMF_OOM_SKIP, &mm->flags);
+		}
+		goto drop;
+	}
 
-done:
-	tsk->oom_reaper_list = NULL;
+	if (!ret)
+		schedule_timeout_idle(HZ/10);
 
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	/* Enqueue to be reaped again */
+	spin_lock(&oom_reaper_lock);
+	list_add(&tsk->oom_reap_list, &oom_reaper_list);
+	spin_unlock(&oom_reaper_lock);
+	return;
 
-	/* Drop a reference taken by wake_oom_reaper */
+drop:
+	/* Drop the reference taken by wake_oom_reaper() */
 	put_task_struct(tsk);
 }
 
@@ -622,11 +640,13 @@ static int oom_reaper(void *unused)
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
+			tsk = list_entry(&oom_reaper_list, struct task_struct,
+					 oom_reap_list);
+			list_del(&tsk->oom_reap_list);
 		}
 		spin_unlock(&oom_reaper_lock);
 
@@ -637,17 +657,22 @@ static int oom_reaper(void *unused)
 	return 0;
 }
 
+/* How long to wait to oom reap an mm before selecting another process */
+#define OOM_REAP_TIMEOUT_MSECS	(10 * 1000)
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	/*
+	 * Set the reap timeout; if it's already set, the mm is enqueued and
+	 * this tsk can be ignored.
+	 */
+	if (cmpxchg(&tsk->signal->oom_mm->reap_timeout, 0UL,
+			jiffies + msecs_to_jiffies(OOM_REAP_TIMEOUT_MSECS)))
 		return;
 
 	get_task_struct(tsk);
 
 	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
+	list_add(&tsk->oom_reap_list, &oom_reaper_list);
 	spin_unlock(&oom_reaper_lock);
 	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
