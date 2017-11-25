Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98B306B0033
	for <linux-mm@kvack.org>; Sat, 25 Nov 2017 05:53:04 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id v8so12964554otd.4
        for <linux-mm@kvack.org>; Sat, 25 Nov 2017 02:53:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m11si10734563otb.296.2017.11.25.02.53.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 25 Nov 2017 02:53:03 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/3] mm,oom: Remove oom_lock serialization from the OOM reaper.
Date: Sat, 25 Nov 2017 19:52:49 +0900
Message-Id: <1511607169-5084-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>

Since "mm,oom: Move last second allocation to inside the OOM killer."
changed to do last second allocation attempt after confirming that there
is no OOM victim's mm without MMF_OOM_SKIP set, we no longer need to
block the OOM reaper using oom_lock. This patch should allow start
reclaiming earlier than now.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 348ec5a..3b0d0fe 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -491,22 +491,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
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
@@ -580,7 +564,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
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
