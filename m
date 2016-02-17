Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 558B7828DF
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:29:47 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fy10so9213603pac.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:29:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i17si1083650pfi.213.2016.02.17.02.29.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 02:29:46 -0800 (PST)
Subject: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
In-Reply-To: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
Message-Id: <201602171929.IFG12927.OVFJOQHOSMtFFL@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 19:29:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From 142b08258e4c60834602e9b0a734564208bc6397 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 16:29:29 +0900
Subject: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.

The OOM reaper kernel thread can reclaim OOM victim's memory before
the victim releases it. But it is possible that a TIF_MEMDIE thread
gets stuck at down_read(&mm->mmap_sem) in exit_mm() called from
do_exit() due to one of !TIF_MEMDIE threads doing a GFP_KERNEL
allocation between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
(e.g. mmap()). In that case, we need to use SysRq-f (manual invocation
of the OOM killer) because down_read_trylock(&mm->mmap_sem) by the OOM
reaper will not succeed. Also, there are other situations where the OOM
reaper cannot reap the victim's memory (e.g. CONFIG_MMU=n, victim's
memory is shared with OOM-unkillable processes) which will require
manual SysRq-f for making progress.

However, it is possible that the OOM killer chooses the same OOM victim
forever which already has TIF_MEMDIE. This is effectively disabling
SysRq-f. This patch excludes processes which has a TIF_MEMDIE thread
 from OOM victim candidates.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 871470f..27949ef 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -119,6 +119,30 @@ found:
 }
 
 /*
+ * Treat the whole process p as unkillable when one of threads has
+ * TIF_MEMDIE pending. Otherwise, we may end up setting TIF_MEMDIE
+ * on the same victim forever (e.g. making SysRq-f unusable).
+ */
+static struct task_struct *find_lock_non_victim_task_mm(struct task_struct *p)
+{
+	struct task_struct *t;
+
+	rcu_read_lock();
+
+	for_each_thread(p, t) {
+		if (likely(!test_tsk_thread_flag(t, TIF_MEMDIE)))
+			continue;
+		t = NULL;
+		goto found;
+	}
+	t = find_lock_task_mm(p);
+ found:
+	rcu_read_unlock();
+
+	return t;
+}
+
+/*
  * order == -1 means the oom kill is required by sysrq, otherwise only
  * for display purposes.
  */
@@ -165,7 +189,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
 
-	p = find_lock_task_mm(p);
+	p = find_lock_non_victim_task_mm(p);
 	if (!p)
 		return 0;
 
@@ -361,7 +385,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 		if (oom_unkillable_task(p, memcg, nodemask))
 			continue;
 
-		task = find_lock_task_mm(p);
+		task = find_lock_non_victim_task_mm(p);
 		if (!task) {
 			/*
 			 * This is a kthread or all of p's threads have already
@@ -562,7 +586,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	read_unlock(&tasklist_lock);
 
-	p = find_lock_task_mm(victim);
+	p = find_lock_non_victim_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
 		return;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
