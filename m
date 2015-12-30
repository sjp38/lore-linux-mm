Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 746286B025C
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 21:01:52 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id uo6so109690071pac.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 18:01:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r78si30347552pfi.202.2015.12.29.18.01.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Dec 2015 18:01:51 -0800 (PST)
Subject: [PATCH] mm,oom: Always sleep before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201512301101.GJD12974.LOVFFtFMOHOJSQ@I-love.SAKURA.ne.jp>
Date: Wed, 30 Dec 2015 11:01:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From c0b5820c594343e06239f15afb35d23b4b8ac0d0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 30 Dec 2015 10:55:59 +0900
Subject: [PATCH] mm,oom: Always sleep before retrying.

When we entered into "Reclaim has failed us, start killing things"
state, sleep function is called only when mutex_trylock(&oom_lock)
in __alloc_pages_may_oom() failed or immediately after returning from
oom_kill_process() in out_of_memory(). This may be insufficient for
giving other tasks a chance to run because mutex_trylock(&oom_lock)
will not fail under non-preemptive UP kernel.

If it is a !__GFP_FS && !__GFP_NOFAIL allocation request,
__alloc_pages_may_oom() will return without sleeping, and
__alloc_pages_slowpath() will retry without sleeping.
As a result, other tasks will never acquire a chance to run.

If it is a __GFP_FS || __GFP_NOFAIL allocation request, out_of_memory()
will be called. But if the OOM victim failed to terminate before
schedule_timeout_killable(1) returns, the victim will never acquire
a chance to run again because the task which called out_of_memory()
will not sleep again.

We should not rely on mutex_trylock(&oom_lock) for a sleep. This patch
makes sure everybody sleeps before __alloc_pages_slowpath() retries.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2565154..6f7f786 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2734,7 +2734,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 */
 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
@@ -3282,6 +3281,12 @@ retry:
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		/*
+		 * Make sure that other tasks (e.g. OOM victims, workqueue
+		 * items) are given a chance to run.
+		 */
+		if (!test_thread_flag(TIF_MEMDIE))
+			schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
