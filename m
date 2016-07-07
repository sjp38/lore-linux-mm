Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A73CB6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:04:58 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ib6so33106962pad.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:04:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m87si4555834pfi.190.2016.07.07.09.04.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 09:04:57 -0700 (PDT)
Subject: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
In-Reply-To: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
Message-Id: <201607080104.JDA41505.OtOFMSLOQVJFHF@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 01:04:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From acc85fdd36452e39bace6aa73b3aaa41bbe776a5 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 00:39:36 +0900
Subject: [PATCH 4/6] mm,oom_reaper: Make OOM reaper use list of mm_struct.

Since OOM reaping is per mm_struct operation, it is natural to use
list of mm_struct used by OOM victims. By using list of mm_struct,
we can eliminate find_lock_task_mm() usage from the OOM reaper.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |   8 -----
 mm/memcontrol.c     |   1 -
 mm/oom_kill.c       | 100 +++++++++++++++-------------------------------------
 3 files changed, 29 insertions(+), 80 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index bdcb331..cb3f041 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -72,14 +72,6 @@ static inline bool oom_task_origin(const struct task_struct *p)
 
 extern void mark_oom_victim(struct task_struct *tsk);
 
-#ifdef CONFIG_MMU
-extern void wake_oom_reaper(struct task_struct *tsk);
-#else
-static inline void wake_oom_reaper(struct task_struct *tsk)
-{
-}
-#endif
-
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8f7a5b7..5043324 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1236,7 +1236,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		wake_oom_reaper(current);
 		goto unlock;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 87e7ff3..223e1fe 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -471,8 +471,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
 
 static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 {
@@ -543,30 +541,23 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
+static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 {
 	int attempts = 0;
-	struct mm_struct *mm = NULL;
-	struct task_struct *p = find_lock_task_mm(tsk);
 
 	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
+	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
+	 * pinned.
 	 */
-	if (!p)
-		goto done;
-	mm = p->mm;
-	atomic_inc(&mm->mm_count);
-	task_unlock(p);
+	if (test_bit(MMF_OOM_REAPED, &mm->flags))
+		return;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
-		goto done;
+		return;
 
 	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
 	set_bit(MMF_OOM_REAPED, &mm->flags);
@@ -574,25 +565,6 @@ static void oom_reap_task(struct task_struct *tsk)
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
 	debug_show_all_locks();
-
-done:
-	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
-	 */
-	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
-
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
-	/* Drop references taken by mark_oom_victim() */
-	if (mm)
-		exit_oom_mm(mm);
-	/* Drop a reference taken above. */
-	if (mm)
-		mmdrop(mm);
 }
 
 static int oom_reaper(void *unused)
@@ -600,41 +572,31 @@ static int oom_reaper(void *unused)
 	set_freezable();
 
 	while (true) {
-		struct task_struct *tsk = NULL;
-
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
-		spin_unlock(&oom_reaper_lock);
-
-		if (tsk)
-			oom_reap_task(tsk);
+		struct mm_struct *mm;
+		struct task_struct *victim;
+
+		wait_event_freezable(oom_reaper_wait,
+				     !list_empty(&oom_mm_list));
+		mutex_lock(&oom_lock);
+		mm = list_first_entry(&oom_mm_list, struct mm_struct,
+				      oom_mm.list);
+		victim = mm->oom_mm.victim;
+		/*
+		 * Take a reference on current victim thread in case
+		 * oom_reap_task() raced with mark_oom_victim() by
+		 * other threads sharing this mm.
+		 */
+		get_task_struct(victim);
+		mutex_unlock(&oom_lock);
+		oom_reap_task(victim, mm);
+		put_task_struct(victim);
+		/* Drop references taken by mark_oom_victim() */
+		exit_oom_mm(mm);
 	}
 
 	return 0;
 }
 
-void wake_oom_reaper(struct task_struct *tsk)
-{
-	if (!oom_reaper_th)
-		return;
-
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
-		return;
-
-	get_task_struct(tsk);
-
-	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
-	spin_unlock(&oom_reaper_lock);
-	wake_up(&oom_reaper_wait);
-}
-
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
@@ -682,6 +644,9 @@ void mark_oom_victim(struct task_struct *tsk)
 	if (!old_tsk) {
 		atomic_inc(&mm->mm_count);
 		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+#ifdef CONFIG_MMU
+		wake_up(&oom_reaper_wait);
+#endif
 	} else {
 		put_task_struct(old_tsk);
 	}
@@ -826,7 +791,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -835,7 +799,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -925,7 +888,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * memory might be still used. Hide the mm from the oom
 			 * killer to guarantee OOM forward progress.
 			 */
-			can_oom_reap = false;
 			set_bit(MMF_OOM_REAPED, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
@@ -936,9 +898,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -1014,7 +973,6 @@ bool out_of_memory(struct oom_control *oc)
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		wake_oom_reaper(current);
 		return true;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
