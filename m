Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB7D6B0253
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:37:49 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id o10so232630384obp.3
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:37:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d13si662928iog.202.2016.07.02.19.37.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:37:48 -0700 (PDT)
Subject: [PATCH 2/8] mm,oom_reaper: Reduce find_lock_task_mm() usage.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Message-Id: <201607031137.HBF15174.HQJLOVMStFOFOF@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:37:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From 3be379c6b42a0901cd81fb2c743e321b6fbdec5b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 2 Jul 2016 22:55:17 +0900
Subject: [PATCH 2/8] mm,oom_reaper: Reduce find_lock_task_mm() usage.

Since holding mm_struct with elevated mm_count for a second is harmless,
we can determine mm_struct and hold it upon entry of oom_reap_task().
This patch has no functional change. Future patch in this series will
eliminate find_lock_task_mm() usage from the OOM reaper.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 79 ++++++++++++++++++++++++++++-------------------------------
 1 file changed, 37 insertions(+), 42 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 16340f2..76c765e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -451,12 +451,10 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task(struct task_struct *tsk)
+static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct mm_struct *mm = NULL;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
@@ -477,22 +475,9 @@ static bool __oom_reap_task(struct task_struct *tsk)
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
@@ -502,7 +487,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto mm_drop;
+		goto unlock_oom;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -550,8 +535,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-mm_drop:
-	mmdrop(mm);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
@@ -561,36 +544,45 @@ unlock_oom:
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
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
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
@@ -602,6 +594,9 @@ static void oom_reap_task(struct task_struct *tsk)
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
+	/* Drop a reference taken above. */
+	if (mm)
+		mmdrop(mm);
 }
 
 static int oom_reaper(void *unused)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
