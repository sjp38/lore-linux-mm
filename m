Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 484D36B025E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 10:13:34 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id f198so75611413wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:34 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e19si25142218wmc.60.2016.04.06.07.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 07:13:30 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a140so13655327wma.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:13:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks queued for oom_reaper
Date: Wed,  6 Apr 2016 16:13:16 +0200
Message-Id: <1459951996-12875-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Right now the oom reaper will clear TIF_MEMDIE only for tasks which
were successfully reaped. This is the safest option because we know
that such an oom victim would only block forward progress of the oom
killer without a good reason because it is highly unlikely it would
release much more memory. Basically most of its memory has been already
torn down.

We can relax this assumption to catch more corner cases though.

The first obvious one is when the oom victim clears its mm and gets
stuck later on. oom_reaper would back of on find_lock_task_mm returning
NULL. We can safely try to clear TIF_MEMDIE in this case because such a
task would be ignored by the oom killer anyway. The flag would be
cleared by that time already most of the time anyway.

The less obvious one is when the oom reaper fails due to mmap_sem
contention. Even if we clear TIF_MEMDIE for this task then it is not
very likely that we would select another task too easily because
we haven't reaped the last victim and so it would be still the #1
candidate. There is a rare race condition possible when the current
victim terminates before the next select_bad_process but considering
that oom_reap_task had retried several times before giving up then
this sounds like a borderline thing.

After this patch we should have a guarantee that the OOM killer will
not be block for unbounded amount of time for most cases.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 74c38f5fffef..7098104b7475 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -510,14 +510,10 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	up_read(&mm->mmap_sem);
 
 	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore. OOM killer can continue
-	 * by selecting other victim if unmapping hasn't led to any
-	 * improvements. This also means that selecting this task doesn't
-	 * make any sense.
+	 * This task can be safely ignored because we cannot do much more
+	 * to release its memory.
 	 */
 	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
-	exit_oom_victim(tsk);
 out:
 	mmput(mm);
 	return ret;
@@ -538,6 +534,14 @@ static void oom_reap_task(struct task_struct *tsk)
 		debug_show_all_locks();
 	}
 
+	/*
+	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
+	 * reasonably reclaimable memory anymore or it is not a good candidate
+	 * for the oom victim right now because it cannot release its memory
+	 * itself nor by the oom reaper.
+	 */
+	exit_oom_victim(tsk);
+
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
