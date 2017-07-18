Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 77D076B02C3
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 10:07:27 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c135so1503257oih.3
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 07:07:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m96si1831234oik.294.2017.07.18.07.07.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Jul 2017 07:07:25 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] oom_reaper: close race without using oom_lock
Date: Tue, 18 Jul 2017 23:06:50 +0900
Message-Id: <1500386810-4881-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mhocko@kernel.org, hannes@cmpxchg.org, rientjes@google.com
Cc: linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
guarded whole OOM reaping operations using oom_lock. But there was no
need to guard whole operations. We needed to guard only setting of
MMF_OOM_REAPED flag because get_page_from_freelist() in
__alloc_pages_may_oom() is called with oom_lock held.

If we change to guard only setting of MMF_OOM_SKIP flag, the OOM reaper
can start reaping operations as soon as wake_oom_reaper() is called.
But since setting of MMF_OOM_SKIP flag at __mmput() is not guarded with
oom_lock, guarding only the OOM reaper side is not sufficient.

If we change the OOM killer side to ignore MMF_OOM_SKIP flag once,
there is no need to guard setting of MMF_OOM_SKIP flag, and we can
guarantee a chance to call get_page_from_freelist() in
__alloc_pages_may_oom() without depending on oom_lock serialization.

This patch makes MMF_OOM_SKIP act as if MMF_OOM_REAPED, and adds a new
flag which acts as if MMF_OOM_SKIP, in order to close both race window
(the OOM reaper side and __mmput() side) without using oom_lock.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/mm_types.h |  1 +
 mm/oom_kill.c            | 42 +++++++++++++++---------------------------
 2 files changed, 16 insertions(+), 27 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ff15181..3184b7a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -495,6 +495,7 @@ struct mm_struct {
 	 */
 	bool tlb_flush_pending;
 #endif
+	bool oom_killer_synchronized;
 	struct uprobes_state uprobes_state;
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f0..1710133 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -300,11 +300,17 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves unless
 	 * the task has MMF_OOM_SKIP because chances that it would release
-	 * any memory is quite low.
+	 * any memory is quite low. But ignore MMF_OOM_SKIP once, for there is
+	 * still possibility that get_page_from_freelist() with oom_lock held
+	 * succeeds because MMF_OOM_SKIP is set without oom_lock held.
 	 */
 	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
+		struct mm_struct *mm = task->signal->oom_mm;
+
+		if (mm->oom_killer_synchronized)
 			goto next;
+		if (test_bit(MMF_OOM_SKIP, &mm->flags))
+			mm->oom_killer_synchronized = true;
 		goto abort;
 	}
 
@@ -470,28 +476,10 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
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
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return false;
 	}
 
 	/*
@@ -502,7 +490,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return true;
 	}
 
 	trace_start_task_reaping(tsk->pid);
@@ -549,9 +537,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	mmput_async(mm);
 	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
@@ -661,8 +647,10 @@ static void mark_oom_victim(struct task_struct *tsk)
 		return;
 
 	/* oom_mm is bound to the signal struct life time. */
-	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
-		mmgrab(tsk->signal->oom_mm);
+	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
+		mmgrab(mm);
+		mm->oom_killer_synchronized = false;
+	}
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
