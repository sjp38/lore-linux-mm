Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13DB86B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 07:41:39 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id a72so561032ioe.13
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:41:39 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 76si6557511ioe.277.2017.11.28.04.41.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 04:41:37 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Set ->signal->oom_mm to all thread groups sharing the victim's mm.
Date: Tue, 28 Nov 2017 21:41:28 +0900
Message-Id: <1511872888-4579-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Due to commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") and patch "mm,oom: Use ALLOC_OOM for OOM victim's last
second allocation.", thread groups sharing the OOM victim's mm without
setting ->signal->oom_mm before task_will_free_mem(current) is called
might fail to try ALLOC_OOM allocation attempt.

Therefore, make sure that all thread groups sharing the OOM victim's mm can
try ALLOC_OOM allocation attempt by calling mark_oom_victim() on all thread
groups sharing the OOM victim's mm, by calling oom_kill_process() even if
task_will_free_mem(current) is true.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
---
 mm/oom_kill.c | 49 ++++++++++++++++++++++++++-----------------------
 1 file changed, 26 insertions(+), 23 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3b0d0fe..399ae36 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -826,6 +826,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
+	bool verbose = false;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -833,13 +834,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
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
+		goto mark_victims;
 	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
@@ -876,7 +872,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	read_unlock(&tasklist_lock);
 
+	verbose = true;
 	p = find_lock_task_mm(victim);
+ mark_victims:
 	if (!p) {
 		put_task_struct(victim);
 		return;
@@ -891,8 +889,10 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	mmgrab(mm);
 
 	/* Raise event before sending signal: task reaper must see this */
-	count_vm_event(OOM_KILL);
-	count_memcg_event_mm(mm, OOM_KILL);
+	if (verbose) {
+		count_vm_event(OOM_KILL);
+		count_memcg_event_mm(mm, OOM_KILL);
+	}
 
 	/*
 	 * We should send SIGKILL before granting access to memory reserves
@@ -901,21 +901,18 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+	if (verbose)
+		pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		       task_pid_nr(victim), victim->comm, K(mm->total_vm),
+		       K(get_mm_counter(mm, MM_ANONPAGES)),
+		       K(get_mm_counter(mm, MM_FILEPAGES)),
+		       K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
 
 	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * Kill all user processes, if any, sharing victim->mm in other thread
+	 * groups and grant access to memory reserves. This helps the OOM
+	 * reaper to reclaim memory.
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
@@ -938,6 +935,11 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		mark_oom_victim(t);
+		task_unlock(t);
 	}
 	rcu_read_unlock();
 
@@ -1018,8 +1020,9 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		get_task_struct(current);
+		oc->chosen = current;
+		oom_kill_process(oc, "");
 		return true;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
