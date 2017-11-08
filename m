Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAEB4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 06:02:39 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id s88so537256ota.1
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 03:02:39 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c91si1768330otb.420.2017.11.08.03.02.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 03:02:37 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 4/5] mm,oom: Remove oom_lock serialization from the OOM reaper.
Date: Wed,  8 Nov 2017 20:01:47 +0900
Message-Id: <1510138908-6265-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since "mm,oom: Move last second allocation to inside the OOM killer."
changed to do last second allocation attempt after confirming that there
is no OOM victim's mm without MMF_OOM_SKIP set, we no longer need to
block the OOM reaper using oom_lock. This patch should allow start
reclaiming earlier than now.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index cf6f19b..6949465 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -495,22 +495,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	bool ret = true;
 
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
-	mutex_lock(&oom_lock);
-
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		trace_skip_task_reaping(tsk->pid);
@@ -584,7 +568,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	trace_finish_task_reaping(tsk->pid);
 unlock_oom:
-	mutex_unlock(&oom_lock);
 	return ret;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
