Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AAD46B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 11:18:59 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id n64so182009ota.3
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 08:18:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h34si10501314otb.236.2017.11.28.08.18.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 08:18:57 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm,oom: Set ->signal->oom_mm to all thread groups sharing the victim's mm.
Date: Wed, 29 Nov 2017 01:17:15 +0900
Message-Id: <1511885835-4899-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <201711282307.EBG97690.MQVOFLFFOJHtOS@I-love.SAKURA.ne.jp>
References: <201711282307.EBG97690.MQVOFLFFOJHtOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

Due to commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") and patch "mm,oom: Use ALLOC_OOM for OOM victim's last
second allocation.", thread groups sharing the OOM victim's mm without
setting ->signal->oom_mm before task_will_free_mem(current) is called
might fail to try ALLOC_OOM allocation attempt.

Therefore, make sure that all thread groups sharing the OOM victim's mm can
try ALLOC_OOM allocation attempt by calling mark_oom_victim() on all thread
groups sharing the OOM victim's mm, by splitting oom_kill_process() into
"select final victim and print message" part and "kill final victim" part.

Roman is proposing similar change for implementing cgroup-aware OOM killer
at http://lkml.kernel.org/r/20171019185218.12663-2-guro@fb.com , and this
patch can be reused for that purpose.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Roman Gushchin <guro@fb.com>
Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c | 129 ++++++++++++++++++++++++++++++----------------------------
 1 file changed, 67 insertions(+), 62 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3b0d0fe..f859144 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -814,6 +814,64 @@ static bool task_will_free_mem(struct task_struct *task)
 	return ret;
 }
 
+static void __oom_kill_process(struct task_struct *victim)
+{
+	bool can_oom_reap = true;
+	struct task_struct *p;
+	struct task_struct *t;
+	struct mm_struct *mm;
+
+	victim = find_lock_task_mm(victim);
+	if (!victim)
+		return;
+	get_task_struct(victim);
+	/* Get a reference to safely compare mm after task_unlock(victim) */
+	mm = victim->mm;
+	mmgrab(mm);
+	task_unlock(victim);
+
+	/*
+	 * Kill all user processes sharing victim's mm and then grant them
+	 * access to memory reserves.
+	 */
+	rcu_read_lock();
+	for_each_process(p) {
+		if (!process_shares_mm(p, mm))
+			continue;
+		if (is_global_init(p)) {
+			can_oom_reap = false;
+			set_bit(MMF_OOM_SKIP, &mm->flags);
+			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
+				task_pid_nr(victim), victim->comm,
+				task_pid_nr(p), p->comm);
+			continue;
+		}
+		/*
+		 * No use_mm() user needs to read from the userspace so we are
+		 * ok to reap it.
+		 */
+		if (unlikely(p->flags & PF_KTHREAD))
+			continue;
+		/*
+		 * We should send SIGKILL before granting access to memory
+		 * reserves in order to prevent the OOM victim from depleting
+		 * the memory reserves from the user space under its control.
+		 */
+		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		mark_oom_victim(t);
+		task_unlock(t);
+	}
+	rcu_read_unlock();
+
+	if (can_oom_reap)
+		wake_oom_reaper(victim);
+	mmdrop(mm);
+	put_task_struct(victim);
+}
+
 static void oom_kill_process(struct oom_control *oc, const char *message)
 {
 	struct task_struct *p = oc->chosen;
@@ -825,7 +883,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -833,13 +890,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 * so it can die quickly
 	 */
 	task_lock(p);
-	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
+	if (task_will_free_mem(p))
+		goto kill_victims;
 	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
@@ -885,66 +937,20 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		put_task_struct(victim);
 		victim = p;
 	}
-
-	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
-	mmgrab(mm);
 
 	/* Raise event before sending signal: task reaper must see this */
 	count_vm_event(OOM_KILL);
 	count_memcg_event_mm(mm, OOM_KILL);
 
-	/*
-	 * We should send SIGKILL before granting access to memory reserves
-	 * in order to prevent the OOM victim from depleting the memory
-	 * reserves from the user space under its control.
-	 */
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
-	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+	       task_pid_nr(victim), victim->comm, K(mm->total_vm),
+	       K(get_mm_counter(mm, MM_ANONPAGES)),
+	       K(get_mm_counter(mm, MM_FILEPAGES)),
+	       K(get_mm_counter(mm, MM_SHMEMPAGES)));
+kill_victims:
 	task_unlock(victim);
-
-	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
-	 */
-	rcu_read_lock();
-	for_each_process(p) {
-		if (!process_shares_mm(p, mm))
-			continue;
-		if (same_thread_group(p, victim))
-			continue;
-		if (is_global_init(p)) {
-			can_oom_reap = false;
-			set_bit(MMF_OOM_SKIP, &mm->flags);
-			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
-					task_pid_nr(victim), victim->comm,
-					task_pid_nr(p), p->comm);
-			continue;
-		}
-		/*
-		 * No use_mm() user needs to read from the userspace so we are
-		 * ok to reap it.
-		 */
-		if (unlikely(p->flags & PF_KTHREAD))
-			continue;
-		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
-	}
-	rcu_read_unlock();
-
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
-
-	mmdrop(mm);
+	__oom_kill_process(victim);
 	put_task_struct(victim);
 }
 #undef K
@@ -1018,8 +1024,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		__oom_kill_process(current);
 		return true;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
