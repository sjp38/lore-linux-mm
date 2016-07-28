Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F02B16B0262
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 15:42:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so24845480wmp.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:49 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ch18si14700049wjb.75.2016.07.28.12.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 12:42:44 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so12643436wma.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:44 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 04/10] mm, oom: get rid of signal_struct::oom_victims
Date: Thu, 28 Jul 2016 21:42:28 +0200
Message-Id: <1469734954-31247-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

After "oom: keep mm of the killed task available" we can safely
detect an oom victim by checking task->signal->oom_mm so we do not need
the signal_struct counter anymore so let's get rid of it.

This alone wouldn't be sufficient for nommu archs because exit_oom_victim
doesn't hide the process from the oom killer anymore. We can, however,
mark the mm with a MMF flag in __mmput. We can reuse MMF_OOM_REAPED and
rename it to a more generic MMF_OOM_SKIP.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h   |  6 ++++++
 include/linux/sched.h |  3 +--
 kernel/fork.c         |  1 +
 mm/oom_kill.c         | 17 +++++++----------
 4 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457ee3a8..bbe0a7789636 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -72,6 +72,12 @@ static inline bool oom_task_origin(const struct task_struct *p)
 
 extern void mark_oom_victim(struct task_struct *tsk);
 
+static inline bool tsk_is_oom_victim(struct task_struct * tsk)
+{
+	return tsk->signal->oom_mm;
+}
+
+
 #ifdef CONFIG_MMU
 extern void wake_oom_reaper(struct task_struct *tsk);
 #else
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8943546d52e7..e3376215f4d0 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -511,7 +511,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
-#define MMF_OOM_REAPED		21	/* mm has been already reaped */
+#define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
@@ -659,7 +659,6 @@ struct signal_struct {
 	atomic_t		sigcnt;
 	atomic_t		live;
 	int			nr_threads;
-	atomic_t oom_victims; /* # of TIF_MEDIE threads in this thread group */
 	struct list_head	thread_head;
 
 	wait_queue_head_t	wait_chldexit;	/* for wait4() */
diff --git a/kernel/fork.c b/kernel/fork.c
index 7e9f83d5fe95..89905b641a0a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -721,6 +721,7 @@ static inline void __mmput(struct mm_struct *mm)
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 	mmdrop(mm);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7f09608405b7..bb4c2ee9c67f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -181,7 +181,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 */
 	adj = (long)p->signal->oom_score_adj;
 	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
+			test_bit(MMF_OOM_SKIP, &p->mm->flags) ||
 			in_vfork(p)) {
 		task_unlock(p);
 		return 0;
@@ -284,14 +284,14 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	/*
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves unless
-	 * the task has MMF_OOM_REAPED because chances that it would release
+	 * the task has MMF_OOM_SKIP because chances that it would release
 	 * any memory is quite low.
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
+	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
 		struct mm_struct *mm = task->signal->oom_mm;
 		enum oom_scan_t ret = OOM_SCAN_ABORT;
 
-		if (test_bit(MMF_OOM_REAPED, &mm->flags))
+		if (test_bit(MMF_OOM_SKIP, &mm->flags))
 			ret = OOM_SCAN_CONTINUE;
 
 		return ret;
@@ -565,7 +565,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
-	set_bit(MMF_OOM_REAPED, &mm->flags);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -643,8 +643,6 @@ void mark_oom_victim(struct task_struct *tsk)
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 
-	atomic_inc(&tsk->signal->oom_victims);
-
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
 		atomic_inc(&tsk->signal->oom_mm->mm_count);
@@ -666,7 +664,6 @@ void exit_oom_victim(struct task_struct *tsk)
 {
 	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
-	atomic_dec(&tsk->signal->oom_victims);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
@@ -758,7 +755,7 @@ bool task_will_free_mem(struct task_struct *task)
 	 * This task has already been drained by the oom reaper so there are
 	 * only small chances it will free some more
 	 */
-	if (test_bit(MMF_OOM_REAPED, &mm->flags))
+	if (test_bit(MMF_OOM_SKIP, &mm->flags))
 		return false;
 
 	if (atomic_read(&mm->mm_users) <= 1)
@@ -898,7 +895,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * killer to guarantee OOM forward progress.
 			 */
 			can_oom_reap = false;
-			set_bit(MMF_OOM_REAPED, &mm->flags);
+			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
