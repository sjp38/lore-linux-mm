Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D790B6B0253
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 05:26:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a66so13405060wme.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:53 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t5si3188581wmt.124.2016.07.01.02.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 02:26:52 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 187so3863681wmz.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/6] oom: keep mm of the killed task available
Date: Fri,  1 Jul 2016 11:26:25 +0200
Message-Id: <1467365190-24640-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_reap_task has to call exit_oom_victim in order to make sure that the
oom vicim will never block the oom killer for ever. This is, however,
opening new problems (e.g oom_killer_disable exclusion - see
74070542099c ("oom, suspend: fix oom_reaper vs. oom_killer_disable
race")). exit_oom_victim should be only called from the victim's
context ideally.

One way to achieve this would be to rely on per mm_struct flags. We
already have MMF_OOM_REAPED to hide a task from the oom killer since
"mm, oom: hide mm which is shared with kthread or global init". The
problem is that the exit path:
do_exit
  exit_mm
    tsk->mm = NULL;
    mmput
      __mmput
    exit_oom_victim

doesn't guarantee that exit_oom_victim will get called in a bounded
amount of time. At least exit_aio depends on IO which might get blocked
due to lack of memory and who knows what else is lurking there.

This patch takes a different approach. We remember tsk->mm into the
signal_struct and bind it to the signal struct life time for all oom
victims. __oom_reap_task as well as oom_scan_process_thread do not have
to rely on find_lock_task_mm anymore and they will have a reliable
reference to the mm struct. As a result all the oom specific
communication inside the OOM killer can be done via tsk->signal->oom_mm.
exit_oom_victim from __oom_reap_task can be dropped.
MMF_OOM_NOT_REAPABLE is trivial to implement as well because we just
need to OOM_SCAN_SELECT it when we see the flag.

Increasing the signal_struct for something as unlikely as the oom
killer is far from ideal but this approach will make the code much more
reasonable and long term we even might want to move task->mm into the
signal_struct anyway. In the next step we might want to make the oom
killer exclusion and access to memory reserves completely independent
which would be also nice.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  2 ++
 kernel/fork.c         |  2 ++
 mm/oom_kill.c         | 67 +++++++++++++++++++++------------------------------
 3 files changed, 31 insertions(+), 40 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d81a1eb974a..befdcc1cde3c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -793,6 +793,8 @@ struct signal_struct {
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
+	struct mm_struct *oom_mm;	/* recorded mm when the thread group got
+					 * killed by the oom killer */
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
diff --git a/kernel/fork.c b/kernel/fork.c
index 452fc864f2f6..2bd3cc73d103 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -245,6 +245,8 @@ static inline void free_signal_struct(struct signal_struct *sig)
 {
 	taskstats_tgid_free(sig);
 	sched_autogroup_exit(sig);
+	if (sig->oom_mm)
+		mmdrop(sig->oom_mm);
 	kmem_cache_free(signal_cachep, sig);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7d0a275df822..4ea4a649822d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -286,16 +286,17 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * Don't allow any other task to have access to the reserves unless
 	 * the task has MMF_OOM_REAPED because chances that it would release
 	 * any memory is quite low.
+	 * MMF_OOM_NOT_REAPABLE means that the oom_reaper backed off last time
+	 * so let it try again.
 	 */
 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
-		struct task_struct *p = find_lock_task_mm(task);
+		struct mm_struct *mm = task->signal->oom_mm;
 		enum oom_scan_t ret = OOM_SCAN_ABORT;
 
-		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
-			task_unlock(p);
-		}
+		if (test_bit(MMF_OOM_REAPED, &mm->flags))
+			ret = OOM_SCAN_CONTINUE;
+		else if (test_bit(MMF_OOM_NOT_REAPABLE, &mm->flags))
+			ret = OOM_SCAN_SELECT;
 
 		return ret;
 	}
@@ -457,7 +458,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = NULL;
-	struct task_struct *p;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
 	bool ret = true;
@@ -478,22 +478,10 @@ static bool __oom_reap_task(struct task_struct *tsk)
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
+	mm = tsk->signal->oom_mm;
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
-		goto mm_drop;
+		goto unlock_oom;
 	}
 
 	/*
@@ -503,7 +491,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto mm_drop;
+		goto unlock_oom;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -551,8 +539,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-mm_drop:
-	mmdrop(mm);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
@@ -568,7 +554,7 @@ static void oom_reap_task(struct task_struct *tsk)
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
-		struct task_struct *p;
+		struct mm_struct *mm;
 
 		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 				task_pid_nr(tsk), tsk->comm);
@@ -579,27 +565,17 @@ static void oom_reap_task(struct task_struct *tsk)
 		 * so hide the mm from the oom killer so that it can move on
 		 * to another task with a different mm struct.
 		 */
-		p = find_lock_task_mm(tsk);
-		if (p) {
-			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
-				pr_info("oom_reaper: giving up pid:%d (%s)\n",
-						task_pid_nr(tsk), tsk->comm);
-				set_bit(MMF_OOM_REAPED, &p->mm->flags);
-			}
-			task_unlock(p);
+		mm = tsk->signal->oom_mm;
+		if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
+			pr_info("oom_reaper: giving up pid:%d (%s)\n",
+					task_pid_nr(tsk), tsk->comm);
+			set_bit(MMF_OOM_REAPED, &mm->flags);
 		}
 
 		debug_show_all_locks();
 	}
 
-	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
-	 */
 	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -664,14 +640,25 @@ subsys_initcall(oom_init)
  *
  * Has to be called with oom_lock held and never after
  * oom has been disabled already.
+ *
+ * tsk->mm has to be non NULL and caller has to guarantee it is stable (either
+ * under task_lock or operate on the current).
  */
 void mark_oom_victim(struct task_struct *tsk)
 {
+	struct mm_struct *mm = tsk->mm;
+
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+
 	atomic_inc(&tsk->signal->oom_victims);
+
+	/* oom_mm is bound to the signal struct life time. */
+	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
+		atomic_inc(&tsk->signal->oom_mm->mm_count);
+
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
