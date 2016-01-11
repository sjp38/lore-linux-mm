Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 544D7828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:42:10 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l65so209461902wmf.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:42:10 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ia6si198533053wjb.29.2016.01.11.04.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 04:42:07 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id f206so26106344wmf.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:42:07 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
Date: Mon, 11 Jan 2016 13:42:00 +0100
Message-Id: <1452516120-5535-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1452094975-551-1-git-send-email-mhocko@kernel.org>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

When oom_reaper manages to unmap all the eligible vmas there shouldn't
be much of the freable memory held by the oom victim left anymore so it
makes sense to clear the TIF_MEMDIE flag for the victim and allow the
OOM killer to select another task if necessary.

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

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this has passed my basic testing but it definitely needs a deeper
review.  I have tested it by flooding the system by OOM and delaying
exit_mm for TIF_MEMDIE tasks to win the race for the oom reaper. I made
sure to delay after the mm was set to NULL to make sure that oom reaper
sees NULL mm from time to time to exercise this case as well. This
happened in roughly half instance.

 include/linux/oom.h |  2 +-
 kernel/exit.c       |  2 +-
 mm/oom_kill.c       | 72 ++++++++++++++++++++++++++++++++++-------------------
 3 files changed, 49 insertions(+), 27 deletions(-)

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
index ea95ee1b5ef7..4c114ba8a825 100644
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
index 45e51ad2f7cf..abefeeb42504 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -419,21 +419,37 @@ bool oom_killer_disabled __read_mostly;
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
 		return true;
 
+	mm = p->mm;
+	if (!atomic_inc_not_zero(&mm->mm_users)) {
+		task_unlock(p);
+		return true;
+	}
+
+	task_unlock(p);
+
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		goto out;
@@ -463,60 +479,66 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
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
@@ -539,7 +561,7 @@ static int __init oom_init(void)
 }
 subsys_initcall(oom_init)
 #else
-static void wake_oom_reaper(struct mm_struct *mm)
+static void wake_oom_reaper(struct task_struct *mm)
 {
 }
 #endif
@@ -570,9 +592,9 @@ void mark_oom_victim(struct task_struct *tsk)
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
-void exit_oom_victim(void)
+void exit_oom_victim(struct task_struct *tsk)
 {
-	clear_thread_flag(TIF_MEMDIE);
+	clear_tsk_thread_flag(tsk, TIF_MEMDIE);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -759,7 +781,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	rcu_read_unlock();
 
 	if (can_oom_reap)
-		wake_oom_reaper(mm);
+		wake_oom_reaper(victim);
 
 	mmdrop(mm);
 	put_task_struct(victim);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
