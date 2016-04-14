Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73DCF6B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 06:57:51 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o126so158495018iod.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 03:57:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i37si13861457otd.58.2016.04.14.03.57.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 03:57:50 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Clarify reason to kill other threads sharing the vitctim's memory.
Date: Thu, 14 Apr 2016 19:56:31 +0900
Message-Id: <1460631391-8628-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Current comment for "Kill all user processes sharing victim->mm in other
thread groups" is not clear that doing so is a best effort avoidance.

I tried to update that logic along with TIF_MEMDIE for several times
but not yet accepted. Therefore, this patch changes only comment so that
we can apply now.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e78818d..43d0002 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -814,13 +814,28 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_unlock(victim);
 
 	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * Kill all user processes sharing victim->mm in other thread groups,
+	 * if any. This reduces possibility of hitting mm->mmap_sem livelock
+	 * when an OOM victim thread cannot exit because it requires the
+	 * mm->mmap_sem for read at exit_mm() while another thread is trying
+	 * to allocate memory with that mm->mmap_sem held for write.
+	 *
+	 * Any thread except the victim thread itself which is killed by
+	 * this heuristic does not get access to memory reserves as of now,
+	 * but it will get access to memory reserves by calling out_of_memory()
+	 * or mem_cgroup_out_of_memory() since it has a pending fatal signal.
+	 *
+	 * Note that this heuristic is not perfect because it is possible that
+	 * a thread which shares victim->mm and is doing memory allocation with
+	 * victim->mm->mmap_sem held for write is marked as OOM_SCORE_ADJ_MIN.
+	 * Also, it is possible that a thread which shares victim->mm and is
+	 * doing memory allocation with victim->mm->mmap_sem held for write
+	 * (possibly the victim thread itself which got TIF_MEMDIE) is blocked
+	 * at unkillable locks from direct reclaim paths because nothing
+	 * prevents TIF_MEMDIE threads which already started direct reclaim
+	 * paths from being blocked at unkillable locks. In such cases, the
+	 * OOM reaper will be unable to reap victim->mm and we will need to
+	 * select a different OOM victim.
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
