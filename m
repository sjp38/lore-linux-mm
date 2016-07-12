Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6076B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:30:13 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e139so26352140oib.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:30:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s185si990158oia.133.2016.07.12.06.30.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:30:11 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
Date: Tue, 12 Jul 2016 22:29:15 +0900
Message-Id: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

This series is an update of
http://lkml.kernel.org/r/201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp .

This series is based on top of linux-next-20160712 +
http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .

 include/linux/mm_types.h |    7
 include/linux/oom.h      |   14 -
 include/linux/sched.h    |    2
 kernel/exit.c            |    2
 kernel/fork.c            |    2
 mm/memcontrol.c          |   14 -
 mm/oom_kill.c            |  362 ++++++++++++++++++++++-------------------------
 7 files changed, 190 insertions(+), 213 deletions(-)

[PATCH 1/8] mm,oom_reaper: Reduce find_lock_task_mm() usage.
[PATCH 2/8] mm,oom_reaper: Do not attempt to reap a task twice.
[PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
[PATCH 4/8] mm,oom: Close oom_has_pending_mm race.
[PATCH 5/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.
[PATCH 6/8] mm,oom: Remove OOM_SCAN_ABORT case and signal_struct->oom_victims.
[PATCH 7/8] mm,oom: Stop clearing TIF_MEMDIE on remote thread.
[PATCH 8/8] oom_reaper: Revert "oom_reaper: close race with exiting task".

At a first glance, the diff lines have increased compared to v2. But v3 is rather
patch description update. Actual change (shown below) is almost same with v2.

 kernel/fork.c |    2
 mm/oom_kill.c |  117 ++++++++++++++++++++++++++++++++++++++--------------------
 2 files changed, 78 insertions(+), 41 deletions(-)

diff -ur v2/kernel/fork.c v3/kernel/fork.c
--- v2/kernel/fork.c
+++ v3/kernel/fork.c
@@ -722,10 +722,8 @@
 	}
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
-#ifndef CONFIG_MMU
 	if (mm->oom_mm.victim)
 		exit_oom_mm(mm);
-#endif
 	mmdrop(mm);
 }
 
diff -ur v2/mm/oom_kill.c v3/mm/oom_kill.c
--- v2/mm/oom_kill.c
+++ v3/mm/oom_kill.c
@@ -132,6 +132,20 @@
 	return oc->order == -1;
 }
 
+static bool task_in_oom_domain(struct task_struct *p, struct mem_cgroup *memcg,
+			       const nodemask_t *nodemask)
+{
+	/* When mem_cgroup_out_of_memory() and p is not member of the group */
+	if (memcg && !task_in_mem_cgroup(p, memcg))
+		return false;
+
+	/* p may not have freeable memory in nodemask */
+	if (!has_intersects_mems_allowed(p, nodemask))
+		return false;
+
+	return true;
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -141,15 +155,7 @@
 	if (p->flags & PF_KTHREAD)
 		return true;
 
-	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
-
-	/* p may not have freeable memory in nodemask */
-	if (!has_intersects_mems_allowed(p, nodemask))
-		return true;
-
-	return false;
+	return !task_in_oom_domain(p, memcg, nodemask);
 }
 
 /**
@@ -276,25 +282,39 @@
 #endif
 
 static LIST_HEAD(oom_mm_list);
+static DEFINE_SPINLOCK(oom_mm_lock);
 
 void exit_oom_mm(struct mm_struct *mm)
 {
-	mutex_lock(&oom_lock);
-	list_del(&mm->oom_mm.list);
-	put_task_struct(mm->oom_mm.victim);
+	struct task_struct *victim;
+
+	/* __mmput() and oom_reaper() could race. */
+	spin_lock(&oom_mm_lock);
+	victim = mm->oom_mm.victim;
 	mm->oom_mm.victim = NULL;
-	mmdrop(mm);
-	mutex_unlock(&oom_lock);
+	if (victim)
+		list_del(&mm->oom_mm.list);
+	spin_unlock(&oom_mm_lock);
+	if (victim) {
+		put_task_struct(victim);
+		mmdrop(mm);
+	}
 }
 
 bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 {
 	struct mm_struct *mm;
+	bool ret = false;
 
-	list_for_each_entry(mm, &oom_mm_list, oom_mm.list)
-		if (!oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
-			return true;
-	return false;
+	spin_lock(&oom_mm_lock);
+	list_for_each_entry(mm, &oom_mm_list, oom_mm.list) {
+		if (task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask)) {
+			ret = true;
+			break;
+		}
+	}
+	spin_unlock(&oom_mm_lock);
+	return ret;
 }
 
 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
@@ -522,12 +542,16 @@
 static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 {
 	int attempts = 0;
+	bool ret;
 
 	/*
-	 * Check MMF_OOM_REAPED in case oom_kill_process() found this mm
-	 * pinned.
+	 * Check MMF_OOM_REAPED after holding oom_lock in case
+	 * oom_kill_process() found this mm pinned.
 	 */
-	if (test_bit(MMF_OOM_REAPED, &mm->flags))
+	mutex_lock(&oom_lock);
+	ret = test_bit(MMF_OOM_REAPED, &mm->flags);
+	mutex_unlock(&oom_lock);
+	if (ret)
 		return;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
@@ -550,22 +574,26 @@
 	set_freezable();
 
 	while (true) {
-		struct mm_struct *mm;
-		struct task_struct *victim;
+		struct mm_struct *mm = NULL;
+		struct task_struct *victim = NULL;
 
 		wait_event_freezable(oom_reaper_wait,
 				     !list_empty(&oom_mm_list));
-		mutex_lock(&oom_lock);
-		mm = list_first_entry(&oom_mm_list, struct mm_struct,
-				      oom_mm.list);
-		victim = mm->oom_mm.victim;
-		/*
-		 * Take a reference on current victim thread in case
-		 * oom_reap_task() raced with mark_oom_victim() by
-		 * other threads sharing this mm.
-		 */
-		get_task_struct(victim);
-		mutex_unlock(&oom_lock);
+		spin_lock(&oom_mm_lock);
+		if (!list_empty(&oom_mm_list)) {
+			mm = list_first_entry(&oom_mm_list, struct mm_struct,
+					      oom_mm.list);
+			victim = mm->oom_mm.victim;
+			/*
+			 * Take a reference on current victim thread in case
+			 * oom_reap_task() raced with mark_oom_victim() by
+			 * other threads sharing this mm.
+			 */
+			get_task_struct(victim);
+		}
+		spin_unlock(&oom_mm_lock);
+		if (!mm)
+			continue;
 		oom_reap_task(victim, mm);
 		put_task_struct(victim);
 		/* Drop references taken by mark_oom_victim() */
@@ -598,7 +626,7 @@
 void mark_oom_victim(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
-	struct task_struct *old_tsk = mm->oom_mm.victim;
+	struct task_struct *old_tsk;
 
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
@@ -615,18 +643,29 @@
 	/*
 	 * Since mark_oom_victim() is called from multiple threads,
 	 * connect this mm to oom_mm_list only if not yet connected.
+	 *
+	 * But task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask) in
+	 * oom_has_pending_mm() might return false after all threads in one
+	 * thread group (which mm->oom_mm.victim belongs to) reached TASK_DEAD
+	 * state. In that case, the same mm will be selected by another thread
+	 * group (which mm->oom_mm.victim does not belongs to). Therefore,
+	 * we need to replace the old task with the new task (at least when
+	 * task_in_oom_domain() returned false).
 	 */
 	get_task_struct(tsk);
+	spin_lock(&oom_mm_lock);
+	old_tsk = mm->oom_mm.victim;
 	mm->oom_mm.victim = tsk;
 	if (!old_tsk) {
 		atomic_inc(&mm->mm_count);
 		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
+	}
+	spin_unlock(&oom_mm_lock);
+	if (old_tsk)
+		put_task_struct(old_tsk);
 #ifdef CONFIG_MMU
-		wake_up(&oom_reaper_wait);
+	wake_up(&oom_reaper_wait);
 #endif
-	} else {
-		put_task_struct(old_tsk);
-	}
 }
 
 /**

This series does not include patches for use_mm() users and wait_event()
in oom_killer_disable(). We can apply
http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org
on top of this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
