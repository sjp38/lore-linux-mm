Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 458DD6B04D9
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 07:01:45 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q4so9787111oif.2
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 04:01:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u190si10509814oiu.342.2017.07.16.04.01.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 16 Jul 2017 04:01:44 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm/page_alloc: Wait for oom_lock before retrying.
Date: Sun, 16 Jul 2017 19:59:51 +0900
Message-Id: <1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mhocko@kernel.org, hannes@cmpxchg.org, rientjes@google.com
Cc: linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since the whole memory reclaim path has never been designed to handle the
scheduling priority inversions, those locations which are assuming that
execution of some code path shall eventually complete without using
synchronization mechanisms can get stuck (livelock) due to scheduling
priority inversions, for CPU time is not guaranteed to be yielded to some
thread doing such code path.

mutex_trylock() in __alloc_pages_may_oom() (waiting for oom_lock) and
schedule_timeout_killable(1) in out_of_memory() (already held oom_lock) is
one of such locations, and it was demonstrated using artificial stressing
that the system gets stuck effectively forever because SCHED_IDLE priority
thread is unable to resume execution at schedule_timeout_killable(1) if
a lot of !SCHED_IDLE priority threads are wasting CPU time [1].

To solve this problem properly, complete redesign and rewrite of the whole
memory reclaim path will be needed. But we are not going to think about
reimplementing the the whole stack (at least for foreseeable future).

Thus, this patch workarounds livelock by forcibly yielding enough CPU time
to the thread holding oom_lock by using mutex_lock_killable() mechanism,
so that the OOM killer/reaper can use CPU time yielded by this patch.
Of course, this patch does not help if the cause of lack of CPU time is
somewhere else (e.g. executing CPU intensive computation with very high
scheduling priority), but that is not fault of this patch.
This patch only manages not to lockup if the cause of lack of CPU time is
direct reclaim storm wasting CPU time without making any progress while
waiting for oom_lock.

[1] http://lkml.kernel.org/r/201707142130.JJF10142.FHJFOQSOOtMVLF@I-love.SAKURA.ne.jp

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb..622ecbf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3259,10 +3259,12 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	*did_some_progress = 0;
 
 	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
+	 * Acquire the oom lock. If that fails, somebody else should be making
+	 * progress for us. But if many threads are doing the same thing, the
+	 * owner of the oom lock can fail to make progress due to lack of CPU
+	 * time. Therefore, wait unless we get SIGKILL.
 	 */
-	if (!mutex_trylock(&oom_lock)) {
+	if (mutex_lock_killable(&oom_lock)) {
 		*did_some_progress = 1;
 		schedule_timeout_uninterruptible(1);
 		return NULL;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
