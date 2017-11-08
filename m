Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB4DB4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 06:02:45 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 82so1811260oid.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 03:02:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 5si1760009ota.360.2017.11.08.03.02.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 03:02:44 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 5/5] nommu,oom: Set MMF_OOM_SKIP without waiting for termination.
Date: Wed,  8 Nov 2017 20:01:48 +0900
Message-Id: <1510138908-6265-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>

Commit 212925802454672e ("mm: oom: let oom_reap_task and exit_mmap run
concurrently") moved the location of setting MMF_OOM_SKIP from __mmput()
in kernel/fork.c (which is used by both MMU and !MMU) to exit_mm() in
mm/mmap.c (which is used by MMU only). As a result, that commit required
OOM victims in !MMU kernels to disappear from the task list in order to
reenable the OOM killer, for !MMU kernels can no longer set MMF_OOM_SKIP
(unless the OOM victim's mm is shared with global init process).

While it would be possible to restore MMF_OOM_SKIP in __mmput() for !MMU
kernels, let's forget about possibility of OOM livelock for !MMU kernels
caused by failing to set MMF_OOM_SKIP, by setting MMF_OOM_SKIP at
oom_kill_process(), for the invocation of the OOM killer is a rare event
for !MMU systems from the beginning. By doing so, we can get rid of
special treatment for !MMU case in commit cd04ae1e2dc8e365 ("mm, oom:
do not rely on TIF_MEMDIE for memory reserves access"). And "mm,oom:
Use ALLOC_OOM for OOM victim's last second allocation." will allow the
OOM victim to try ALLOC_OOM (instead of ALLOC_NO_WATERMARKS) allocation
before killing more OOM victims.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 mm/internal.h   |  9 ---------
 mm/oom_kill.c   |  7 +++++--
 mm/page_alloc.c | 12 +-----------
 3 files changed, 6 insertions(+), 22 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index e6bd351..f0eb8d90 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -481,16 +481,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 /* Mask to get the watermark bits */
 #define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
 
-/*
- * Only MMU archs have async oom victim reclaim - aka oom_reaper so we
- * cannot assume a reduced access to memory reserves is sufficient for
- * !MMU
- */
-#ifdef CONFIG_MMU
 #define ALLOC_OOM		0x08
-#else
-#define ALLOC_OOM		ALLOC_NO_WATERMARKS
-#endif
 
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6949465..d57dcd5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -647,6 +647,8 @@ static int __init oom_init(void)
 #else
 static inline void wake_oom_reaper(struct task_struct *tsk)
 {
+	/* tsk->mm != NULL because tsk == current or task_lock is held. */
+	set_bit(MMF_OOM_SKIP, &tsk->mm->flags);
 }
 #endif /* CONFIG_MMU */
 
@@ -829,7 +831,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
+	bool can_oom_reap = IS_ENABLED(CONFIG_MMU);
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -929,7 +931,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 			continue;
 		if (is_global_init(p)) {
 			can_oom_reap = false;
-			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
@@ -947,6 +948,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 
 	if (can_oom_reap)
 		wake_oom_reaper(victim);
+	else
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	mmdrop(mm);
 	put_task_struct(victim);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fbbc95a..ff435f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3711,17 +3711,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 static bool oom_reserves_allowed(struct task_struct *tsk)
 {
-	if (!tsk_is_oom_victim(tsk))
-		return false;
-
-	/*
-	 * !MMU doesn't have oom reaper so give access to memory reserves
-	 * only to the thread with TIF_MEMDIE set
-	 */
-	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
-		return false;
-
-	return true;
+	return tsk_is_oom_victim(tsk);
 }
 
 /*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
