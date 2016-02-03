Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E46B3828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:14:13 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l66so163066693wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:13 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id s132si3283277wmf.100.2016.02.03.05.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:14:09 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r129so7372160wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
Date: Wed,  3 Feb 2016 14:13:58 +0100
Message-Id: <1454505240-23446-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

When oom_reaper manages to unmap all the eligible vmas there shouldn't
be much of the freable memory held by the oom victim left anymore so it
makes sense to clear the TIF_MEMDIE flag for the victim and allow the
OOM killer to select another task.

The lack of TIF_MEMDIE also means that the victim cannot access memory
reserves anymore but that shouldn't be a problem because it would get
the access again if it needs to allocate and hits the OOM killer again
due to the fatal_signal_pending resp. PF_EXITING check. We can safely
hide the task from the OOM killer because it is clearly not a good
candidate anymore as everyhing reclaimable has been torn down already.

This patch will allow to cap the time an OOM victim can keep TIF_MEMDIE
and thus hold off further global OOM killer actions granted the oom
reaper is able to take mmap_sem for the associated mm struct. This is
not guaranteed now but further steps should make sure that mmap_sem
for write should be blocked killable which will help to reduce such a
lock contention. This is not done by this patch.

Note that exit_oom_victim might be called on a remote task from
__oom_reap_task now so we have to check and clear the flag atomically
otherwise we might race and underflow oom_victims or wake up
waiters too early.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h |  2 +-
 kernel/exit.c       |  2 +-
 mm/oom_kill.c       | 73 +++++++++++++++++++++++++++++++++++------------------
 3 files changed, 50 insertions(+), 27 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 03e6257321f0..45993b840ed6 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -91,7 +91,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(void);
+extern void exit_oom_victim(struct task_struct *tsk);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/kernel/exit.c b/kernel/exit.c
index 07110c6020a0..4b1c6e2658bd 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -436,7 +436,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim();
+		exit_oom_victim(tsk);
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 840e03986497..8e345126d73e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -417,20 +417,36 @@ bool oom_killer_disabled __read_mostly;
  * victim (if that is possible) to help the OOM killer to move on.
  */
 static struct task_struct *oom_reaper_th;
-static struct mm_struct *mm_to_reap;
+static struct task_struct *task_to_reap;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 
-static bool __oom_reap_vmas(struct mm_struct *mm)
+static bool __oom_reap_task(struct task_struct *tsk)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
 
-	/* We might have raced with exit path */
-	if (!atomic_inc_not_zero(&mm->mm_users))
+	/*
+	 * Make sure we find the associated mm_struct even when the particular
+	 * thread has already terminated and cleared its mm.
+	 * We might have race with exit path so consider our work done if there
+	 * is no mm.
+	 */
+	p = find_lock_task_mm(tsk);
+	if (!p)
+		return true;
+
+	mm = p->mm;
+	if (!atomic_inc_not_zero(&mm->mm_users)) {
+		task_unlock(p);
 		return true;
+	}
+
+	task_unlock(p);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
@@ -461,60 +477,66 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	up_read(&mm->mmap_sem);
+
+	/*
+	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
+	 * reasonably reclaimable memory anymore. OOM killer can continue
+	 * by selecting other victim if unmapping hasn't led to any
+	 * improvements. This also means that selecting this task doesn't
+	 * make any sense.
+	 */
+	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+	exit_oom_victim(tsk);
 out:
 	mmput(mm);
 	return ret;
 }
 
-static void oom_reap_vmas(struct mm_struct *mm)
+static void oom_reap_task(struct task_struct *tsk)
 {
 	int attempts = 0;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < 10 && !__oom_reap_vmas(mm))
+	while (attempts++ < 10 && !__oom_reap_task(tsk))
 		schedule_timeout_idle(HZ/10);
 
 	/* Drop a reference taken by wake_oom_reaper */
-	mmdrop(mm);
+	put_task_struct(tsk);
 }
 
 static int oom_reaper(void *unused)
 {
 	while (true) {
-		struct mm_struct *mm;
+		struct task_struct *tsk;
 
 		wait_event_freezable(oom_reaper_wait,
-				     (mm = READ_ONCE(mm_to_reap)));
-		oom_reap_vmas(mm);
-		WRITE_ONCE(mm_to_reap, NULL);
+				     (tsk = READ_ONCE(task_to_reap)));
+		oom_reap_task(tsk);
+		WRITE_ONCE(task_to_reap, NULL);
 	}
 
 	return 0;
 }
 
-static void wake_oom_reaper(struct mm_struct *mm)
+static void wake_oom_reaper(struct task_struct *tsk)
 {
-	struct mm_struct *old_mm;
+	struct task_struct *old_tsk;
 
 	if (!oom_reaper_th)
 		return;
 
-	/*
-	 * Pin the given mm. Use mm_count instead of mm_users because
-	 * we do not want to delay the address space tear down.
-	 */
-	atomic_inc(&mm->mm_count);
+	get_task_struct(tsk);
 
 	/*
 	 * Make sure that only a single mm is ever queued for the reaper
 	 * because multiple are not necessary and the operation might be
 	 * disruptive so better reduce it to the bare minimum.
 	 */
-	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
-	if (!old_mm)
+	old_tsk = cmpxchg(&task_to_reap, NULL, tsk);
+	if (!old_tsk)
 		wake_up(&oom_reaper_wait);
 	else
-		mmdrop(mm);
+		put_task_struct(tsk);
 }
 
 static int __init oom_init(void)
@@ -529,7 +551,7 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void wake_oom_reaper(struct mm_struct *mm)
+static void wake_oom_reaper(struct task_struct *mm)
 {
 }
 #endif
@@ -560,9 +582,10 @@ void mark_oom_victim(struct task_struct *tsk)
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
-void exit_oom_victim(void)
+void exit_oom_victim(struct task_struct *tsk)
 {
-	clear_thread_flag(TIF_MEMDIE);
+	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
+		return;
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -745,7 +768,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	rcu_read_unlock();
 
 	if (can_oom_reap)
-		wake_oom_reaper(mm);
+		wake_oom_reaper(victim);
 
 	mmdrop(mm);
 	put_task_struct(victim);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
