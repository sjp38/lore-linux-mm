Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 91F446B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 05:59:53 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id hb3so61939449igb.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 02:59:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z68si3897863ioi.107.2016.03.08.02.59.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 02:59:52 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm,oom: Do not sleep with oom_lock held.
Date: Tue,  8 Mar 2016 19:59:15 +0900
Message-Id: <1457434755-12531-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.cz>

out_of_memory() can stall effectively forever if a SCHED_IDLE thread
called out_of_memory() when there are !SCHED_IDLE threads running on
the same CPU, for schedule_timeout_killable(1) cannot return shortly
due to scheduling priority on CONFIG_PREEMPT_NONE=y kernels.

Operations with oom_lock held should complete as soon as possible
because we might be preserving OOM condition for most of that period
if we are in OOM condition. SysRq-f can't work if oom_lock is held.

It would be possible to boost scheduling priority of current thread
while holding oom_lock, but priority of current thread might be
manipulated by other threads after boosting. Unless we offload
operations with oom_lock held to a dedicated kernel thread with high
priority, addressing this problem using priority manipulation is racy.

This patch brings schedule_timeout_killable(1) out of oom_lock.

This patch does not address OOM notifiers which are blockable.
Long term we should focus on making the OOM context not preemptible.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c   | 14 +++++++-------
 mm/page_alloc.c |  7 +++++++
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5d5eca9..c84e784 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -901,15 +901,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
+	if (p && p != (void *)-1UL)
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return true;
 }
 
@@ -944,4 +938,10 @@ void pagefault_out_of_memory(void)
 	}
 
 	mutex_unlock(&oom_lock);
+
+	/*
+	 * Give the killed process a good chance to exit before trying
+	 * to allocate memory again.
+	 */
+	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1993894..378a346 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2888,6 +2888,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	}
 out:
 	mutex_unlock(&oom_lock);
+	if (*did_some_progress && !page) {
+		/*
+		 * Give the killed process a good chance to exit before trying
+		 * to allocate memory again.
+		 */
+		schedule_timeout_killable(1);
+	}
 	return page;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
