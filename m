Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1C66B0005
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:42:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so320944602pfb.3
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:42:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h63si1416390pfe.82.2016.07.02.19.42.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:42:12 -0700 (PDT)
Subject: [PATCH 8/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Message-Id: <201607031141.FII82373.FMHQLFOOtVSJOF@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:41:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From ce97a7f6b94a6003bc2b41e5f69da2fedc934a9d Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 2 Jul 2016 23:10:06 +0900
Subject: [PATCH 8/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.

Since OOM reaping is per mm_struct operation, it is natural to use
list of mm_struct used by OOM victims.

This patch eliminates find_lock_task_mm() usage from the OOM reaper.

This patch fixes what commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE
after oom_reaper managed to unmap the address space") and
commit 449d777d7ad6d7f9 ("mm, oom_reaper: clear TIF_MEMDIE for all tasks
queued for oom_reaper") tried to address, by always calling exit_oom_mm()
after OOM reap attempt was made.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   |  8 -----
 include/linux/sched.h |  3 --
 mm/memcontrol.c       |  1 -
 mm/oom_kill.c         | 84 +++++++++++++++++----------------------------------
 4 files changed, 27 insertions(+), 69 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 4844325..1a212c1 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -71,14 +71,6 @@ static inline bool oom_task_origin(const struct task_struct *p)
 
 extern void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc);
 
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
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f472f27..4379279 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1916,9 +1916,6 @@ struct task_struct {
 	unsigned long	task_state_change;
 #endif
 	int pagefault_disabled;
-#ifdef CONFIG_MMU
-	struct task_struct *oom_reaper_list;
-#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c17160d..9acc840 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1236,7 +1236,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current, &oc);
-		wake_oom_reaper(current);
 		goto unlock;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 317ce2c..bdc192f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -468,8 +468,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  * victim (if that is possible) to help the OOM killer to move on.
  */
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
 
 static bool __oom_reap_vmas(struct mm_struct *mm)
 {
@@ -540,30 +538,27 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
+static void oom_reap_vmas(struct mm_struct *mm)
 {
 	int attempts = 0;
-	struct mm_struct *mm = NULL;
-	struct task_struct *p = find_lock_task_mm(tsk);
+	bool ret;
 
 	/*
-	 * Make sure we find the associated mm_struct even when the particular
-	 * thread has already terminated and cleared its mm.
-	 * We might have race with exit path so consider our work done if there
-	 * is no mm.
+	 * Check MMF_OOM_REAPED after holding oom_lock because
+	 * oom_kill_process() might find this mm pinned.
 	 */
-	if (!p)
-		goto done;
-	mm = p->mm;
-	atomic_inc(&mm->mm_count);
-	task_unlock(p);
+	mutex_lock(&oom_lock);
+	ret = test_bit(MMF_OOM_REAPED, &mm->flags);
+	mutex_unlock(&oom_lock);
+	if (ret)
+		return;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_vmas(mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
-		goto done;
+		return;
 
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		mm->oom_mm.pid, mm->oom_mm.comm);
@@ -580,51 +575,30 @@ static void oom_reap_task(struct task_struct *tsk)
 		set_bit(MMF_OOM_REAPED, &mm->flags);
 	}
 	debug_show_all_locks();
-
-done:
-	tsk->oom_reaper_list = NULL;
-	/* Drop a reference taken by wake_oom_reaper */
-	put_task_struct(tsk);
-	/* Drop a reference taken above. */
-	if (mm)
-		mmdrop(mm);
 }
 
 static int oom_reaper(void *unused)
 {
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
+		struct mm_struct *mm = NULL;
+
+		wait_event_freezable(oom_reaper_wait,
+				     !list_empty(&oom_mm_list));
+		spin_lock(&oom_mm_lock);
+		if (!list_empty(&oom_mm_list))
+			mm = list_first_entry(&oom_mm_list, struct mm_struct,
+					      oom_mm.list);
+		spin_unlock(&oom_mm_lock);
+		if (!mm)
+			continue;
+		oom_reap_vmas(mm);
+		/* Drop a reference taken by mark_oom_victim(). */
+		exit_oom_mm(mm);
 	}
 
 	return 0;
 }
 
-void wake_oom_reaper(struct task_struct *tsk)
-{
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
 	kthread_run(oom_reaper, NULL, "oom_reaper");
@@ -667,6 +641,9 @@ void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
 		mm->oom_mm.pid = task_pid_nr(tsk);
 #endif
 		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+#ifdef CONFIG_MMU
+		wake_up(&oom_reaper_wait);
+#endif
 	}
 	spin_unlock(&oom_mm_lock);
 	/*
@@ -816,7 +793,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -825,7 +801,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p, oc);
-		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -915,7 +890,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * memory might be still used. Hide the mm from the oom
 			 * killer to guarantee OOM forward progress.
 			 */
-			can_oom_reap = false;
 			set_bit(MMF_OOM_REAPED, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
@@ -926,9 +900,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -1004,7 +975,6 @@ bool out_of_memory(struct oom_control *oc)
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current, oc);
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
