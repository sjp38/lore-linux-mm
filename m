Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 020FB83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:30 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so28650620lfg.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:29 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id m68si13528200wma.37.2016.08.25.03.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:28 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so6652288wmg.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 1/9] mm,oom_reaper: Reduce find_lock_task_mm() usage.
Date: Thu, 25 Aug 2016 12:03:06 +0200
Message-Id: <1472119394-11342-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

__oom_reap_task() can be simplified a bit if it receives a valid mm from
oom_reap_task() which also uses that mm when __oom_reap_task() failed.
We can drop one find_lock_task_mm() call and also make the
__oom_reap_task() code flow easier to follow. Moreover, this will make
later patch in the series easier to review. Pinning mm's mm_count for
longer time is not really harmful because this will not pin much memory.

This patch doesn't introduce any functional change.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 81 ++++++++++++++++++++++++++++-------------------------------
 1 file changed, 38 insertions(+), 43 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 463cdd22d4e0..87fad956c96b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -463,12 +463,10 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task(struct task_struct *tsk)
+static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = NULL;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
@@ -476,7 +474,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	/*
 	 * We have to make sure to not race with the victim exit path
 	 * and cause premature new oom victim selection:
-	 * __oom_reap_task		exit_mm
+	 * __oom_reap_task_mm		exit_mm
 	 *   mmget_not_zero
 	 *				  mmput
 	 *				    atomic_dec_and_test
@@ -489,22 +487,9 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	mutex_lock(&oom_lock);
 
-	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
-	 */
-	p = find_lock_task_mm(tsk);
-	if (!p)
-		goto unlock_oom;
-	mm = p->mm;
-	atomic_inc(&mm->mm_count);
-	task_unlock(p);
-
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
-		goto mm_drop;
+		goto unlock_oom;
 	}
 
 	/*
@@ -514,7 +499,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto mm_drop;
+		goto unlock_oom;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -562,8 +547,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-mm_drop:
-	mmdrop(mm);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
@@ -573,36 +556,45 @@ static bool __oom_reap_task(struct task_struct *tsk)
 static void oom_reap_task(struct task_struct *tsk)
 {
 	int attempts = 0;
+	struct mm_struct *mm = NULL;
+	struct task_struct *p = find_lock_task_mm(tsk);
+
+	/*
+	 * Make sure we find the associated mm_struct even when the particular
+	 * thread has already terminated and cleared its mm.
+	 * We might have race with exit path so consider our work done if there
+	 * is no mm.
+	 */
+	if (!p)
+		goto done;
+	mm = p->mm;
+	atomic_inc(&mm->mm_count);
+	task_unlock(p);
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts > MAX_OOM_REAP_RETRIES) {
-		struct task_struct *p;
+	if (attempts <= MAX_OOM_REAP_RETRIES)
+		goto done;
 
-		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-				task_pid_nr(tsk), tsk->comm);
+	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+		task_pid_nr(tsk), tsk->comm);
 
-		/*
-		 * If we've already tried to reap this task in the past and
-		 * failed it probably doesn't make much sense to try yet again
-		 * so hide the mm from the oom killer so that it can move on
-		 * to another task with a different mm struct.
-		 */
-		p = find_lock_task_mm(tsk);
-		if (p) {
-			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
-				pr_info("oom_reaper: giving up pid:%d (%s)\n",
-						task_pid_nr(tsk), tsk->comm);
-				set_bit(MMF_OOM_REAPED, &p->mm->flags);
-			}
-			task_unlock(p);
-		}
-
-		debug_show_all_locks();
+	/*
+	 * If we've already tried to reap this task in the past and
+	 * failed it probably doesn't make much sense to try yet again
+	 * so hide the mm from the oom killer so that it can move on
+	 * to another task with a different mm struct.
+	 */
+	if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
+		pr_info("oom_reaper: giving up pid:%d (%s)\n",
+			task_pid_nr(tsk), tsk->comm);
+		set_bit(MMF_OOM_REAPED, &mm->flags);
 	}
+	debug_show_all_locks();
 
+done:
 	/*
 	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
 	 * reasonably reclaimable memory anymore or it is not a good candidate
@@ -614,6 +606,9 @@ static void oom_reap_task(struct task_struct *tsk)
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
+	/* Drop a reference taken above. */
+	if (mm)
+		mmdrop(mm);
 }
 
 static int oom_reaper(void *unused)
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
