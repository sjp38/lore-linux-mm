Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4836E6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:45:56 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so3020554pdj.3
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 02:45:55 -0700 (PDT)
From: Ming Liu <ming.liu@windriver.com>
Subject: [PATCH] oom: avoid killing init if it assume the oom killed thread's mm
Date: Mon, 23 Sep 2013 17:45:28 +0800
Message-ID: <1379929528-19179-1-git-send-email-ming.liu@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

After selecting a task to kill, the oom killer iterates all processes and
kills all other user threads that share the same mm_struct in different
thread groups.

But in some extreme cases, the selected task happens to be a vfork child
of init process sharing the same mm_struct with it, which causes kernel
panic on init getting killed. This panic is observed in a busybox shell
that busybox itself is init, with a kthread keeps consuming memories.

Signed-off-by: Ming Liu <ming.liu@windriver.com>
---
 mm/oom_kill.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 314e9d2..7db4881 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -479,17 +479,17 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	task_unlock(victim);
 
 	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * Kill all user processes except init sharing victim->mm in other
+	 * thread groups, if any.  They don't get access to memory reserves,
+	 * though, to avoid depletion of all memory.  This prevents mm->mmap_sem
+	 * livelock when an oom killed thread cannot exit because it requires
+	 * the semaphore and its contended by another thread trying to allocate
+	 * memory itself. That thread will now get access to memory reserves
+	 * since it has a pending fatal signal.
 	 */
 	for_each_process(p)
 		if (p->mm == mm && !same_thread_group(p, victim) &&
-		    !(p->flags & PF_KTHREAD)) {
+		    !(p->flags & PF_KTHREAD) && !is_global_init(p)) {
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
