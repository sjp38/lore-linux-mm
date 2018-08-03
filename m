Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08C1D6B0008
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 09:19:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p11-v6so4566846oih.17
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 06:19:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d14-v6si3415162oig.71.2018.08.03.06.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 06:19:27 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Remove wake_oom_reaper().
Date: Fri,  3 Aug 2018 22:19:10 +0900
Message-Id: <1533302350-3398-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, rientjes@google.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Currently, wake_oom_reaper() is checking whether an OOM victim thread is
already chained to the OOM victim list. But chaining one thread from each
OOM victim process is sufficient.

Since mark_oom_victim() sets signal->oom_mm for one thread from each OOM
victim process, we can chain that OOM victim thread there. Since oom_lock
is held during __oom_kill_process(), by replacing oom_reaper_lock with
oom_lock, it becomes safe to use mark_oom_victim() even if MMF_OOM_SKIP is
later set due to is_global_init() case.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 41 ++++++++++-------------------------------
 1 file changed, 10 insertions(+), 31 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0e10b86..dad0409 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -486,7 +486,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
-static DEFINE_SPINLOCK(oom_reaper_lock);
 
 bool __oom_reap_task_mm(struct mm_struct *mm)
 {
@@ -607,7 +606,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	 */
 	set_bit(MMF_OOM_SKIP, &mm->flags);
 
-	/* Drop a reference taken by wake_oom_reaper */
+	/* Drop a reference taken by mark_oom_victim(). */
 	put_task_struct(tsk);
 }
 
@@ -617,12 +616,12 @@ static int oom_reaper(void *unused)
 		struct task_struct *tsk = NULL;
 
 		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
-		spin_lock(&oom_reaper_lock);
+		mutex_lock(&oom_lock);
 		if (oom_reaper_list != NULL) {
 			tsk = oom_reaper_list;
 			oom_reaper_list = tsk->oom_reaper_list;
 		}
-		spin_unlock(&oom_reaper_lock);
+		mutex_unlock(&oom_lock);
 
 		if (tsk)
 			oom_reap_task(tsk);
@@ -631,32 +630,12 @@ static int oom_reaper(void *unused)
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
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
-	trace_wake_reaper(tsk->pid);
-	wake_up(&oom_reaper_wait);
-}
-
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
 	return 0;
 }
 subsys_initcall(oom_init)
-#else
-static inline void wake_oom_reaper(struct task_struct *tsk)
-{
-}
 #endif /* CONFIG_MMU */
 
 /**
@@ -682,6 +661,13 @@ static void mark_oom_victim(struct task_struct *tsk)
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
 		set_bit(MMF_OOM_VICTIM, &mm->flags);
+#ifdef CONFIG_MMU
+		get_task_struct(tsk);
+		tsk->oom_reaper_list = oom_reaper_list;
+		oom_reaper_list = tsk;
+		trace_wake_reaper(tsk->pid);
+		wake_up(&oom_reaper_wait);
+#endif
 	}
 
 	/*
@@ -833,7 +819,6 @@ static void __oom_kill_process(struct task_struct *victim)
 {
 	struct task_struct *p;
 	struct mm_struct *mm;
-	bool can_oom_reap = true;
 
 	p = find_lock_task_mm(victim);
 	if (!p) {
@@ -883,7 +868,6 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (same_thread_group(p, victim))
 			continue;
 		if (is_global_init(p)) {
-			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
@@ -900,9 +884,6 @@ static void __oom_kill_process(struct task_struct *victim)
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
 	mmdrop(mm);
 	put_task_struct(victim);
 }
@@ -941,7 +922,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -1071,7 +1051,6 @@ bool out_of_memory(struct oom_control *oc)
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		wake_oom_reaper(current);
 		return true;
 	}
 
-- 
1.8.3.1
