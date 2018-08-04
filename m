Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1377F6B0005
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 09:30:05 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o12-v6so4916761pls.20
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 06:30:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p21-v6si5648555plq.94.2018.08.04.06.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Aug 2018 06:30:03 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional processes.
Date: Sat,  4 Aug 2018 22:29:46 +0900
Message-Id: <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>

David Rientjes is complaining about current behavior that the OOM killer
selects next OOM victim as soon as MMF_OOM_SKIP is set even if
__oom_reap_task_mm() returned without any progress.

To address this problem, this patch adds a timeout with whether the OOM
score of an OOM victim's memory is decreasing over time as a feedback,
after MMF_OOM_SKIP is set by the OOM reaper or exit_mmap().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>
---
 include/linux/sched.h |  3 ++
 mm/oom_kill.c         | 81 ++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 63 insertions(+), 21 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 589fe78..70c7dfd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1174,6 +1174,9 @@ struct task_struct {
 #endif
 	int				pagefault_disabled;
 	struct list_head		oom_victim_list;
+	unsigned long			last_oom_compared;
+	unsigned long			last_oom_score;
+	unsigned char			oom_reap_stall_count;
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 783f04d..7cad886 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -49,6 +49,12 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
 
+static inline unsigned long oom_victim_mm_score(struct mm_struct *mm)
+{
+	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
+		mm_pgtables_bytes(mm) / PAGE_SIZE;
+}
+
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
@@ -230,8 +236,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_victim_mm_score(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -571,15 +576,6 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts <= MAX_OOM_REAP_RETRIES ||
-	    test_bit(MMF_OOM_SKIP, &mm->flags))
-		goto done;
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
-done:
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
@@ -631,6 +627,9 @@ static void mark_oom_victim(struct task_struct *tsk)
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
 		set_bit(MMF_OOM_VICTIM, &mm->flags);
+		tsk->last_oom_compared = jiffies;
+		tsk->last_oom_score = oom_victim_mm_score(mm);
+		tsk->oom_reap_stall_count = 0;
 		get_task_struct(tsk);
 		list_add(&tsk->oom_victim_list, &oom_victim_list);
 	}
@@ -867,7 +866,6 @@ static void __oom_kill_process(struct task_struct *victim)
 	mmdrop(mm);
 	put_task_struct(victim);
 }
-#undef K
 
 /*
  * Kill provided task unless it's secured by setting
@@ -999,33 +997,74 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+static bool victim_mm_stalling(struct task_struct *p, struct mm_struct *mm)
+{
+	unsigned long score;
+
+	if (time_before(jiffies, p->last_oom_compared + HZ / 10))
+		return false;
+	score = oom_victim_mm_score(mm);
+	if (score < p->last_oom_score)
+		p->oom_reap_stall_count = 0;
+	else
+		p->oom_reap_stall_count++;
+	p->last_oom_score = oom_victim_mm_score(mm);
+	p->last_oom_compared = jiffies;
+	if (p->oom_reap_stall_count < 30)
+		return false;
+	pr_info("Gave up waiting for process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		task_pid_nr(p), p->comm, K(mm->total_vm),
+		K(get_mm_counter(mm, MM_ANONPAGES)),
+		K(get_mm_counter(mm, MM_FILEPAGES)),
+		K(get_mm_counter(mm, MM_SHMEMPAGES)));
+	return true;
+}
+
 static bool oom_has_pending_victims(struct oom_control *oc)
 {
-	struct task_struct *p;
+	struct task_struct *p, *tmp;
+	bool ret = false;
+	bool gaveup = false;
 
 	if (is_sysrq_oom(oc))
 		return false;
 	/*
-	 * Since oom_reap_task()/exit_mmap() will set MMF_OOM_SKIP, let's
-	 * wait for pending victims until MMF_OOM_SKIP is set or __mmput()
-	 * completes.
+	 * Wait for pending victims until __mmput() completes or stalled
+	 * too long.
 	 */
-	list_for_each_entry(p, &oom_victim_list, oom_victim_list) {
+	list_for_each_entry_safe(p, tmp, &oom_victim_list, oom_victim_list) {
+		struct mm_struct *mm = p->signal->oom_mm;
+
 		if (oom_unkillable_task(p, oc->memcg, oc->nodemask))
 			continue;
-		if (!test_bit(MMF_OOM_SKIP, &p->signal->oom_mm->flags)) {
+		ret = true;
 #ifdef CONFIG_MMU
+		/*
+		 * Since the OOM reaper exists, we can safely wait until
+		 * MMF_OOM_SKIP is set.
+		 */
+		if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
 			if (!oom_reap_target) {
 				get_task_struct(p);
 				oom_reap_target = p;
 				trace_wake_reaper(p->pid);
 				wake_up(&oom_reaper_wait);
 			}
-#endif
-			return true;
+			continue;
 		}
+#endif
+		/* We can wait as long as OOM score is decreasing over time. */
+		if (!victim_mm_stalling(p, mm))
+			continue;
+		gaveup = true;
+		list_del(&p->oom_victim_list);
+		/* Drop a reference taken by mark_oom_victim(). */
+		put_task_struct(p);
 	}
-	return false;
+	if (gaveup)
+		debug_show_all_locks();
+
+	return ret;
 }
 
 /**
-- 
1.8.3.1
