Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4983A6B0006
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:33:14 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id a32so7290672otj.5
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 05:33:14 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u205si2237590oig.485.2018.02.20.05.33.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Feb 2018 05:33:13 -0800 (PST)
Subject: [PATCH] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180123083806.GF1526@dhcp22.suse.cz>
	<201801232107.HJB48975.OHJFFOOLFQMVSt@I-love.SAKURA.ne.jp>
	<20180123124245.GK1526@dhcp22.suse.cz>
	<201801242228.FAD52671.SFFLQMOVOFHOtJ@I-love.SAKURA.ne.jp>
	<201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
In-Reply-To: <201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
Message-Id: <201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp>
Date: Tue, 20 Feb 2018 22:32:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

>From c3b6616238fcd65d5a0fdabcb4577c7e6f40d35e Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 20 Feb 2018 11:07:23 +0900
Subject: [PATCH] mm,page_alloc: wait for oom_lock than back off

This patch fixes a bug which is essentially same with a bug fixed by
commit 400e22499dd92613 ("mm: don't warn about allocations which stall for
too long").

Currently __alloc_pages_may_oom() is using mutex_trylock(&oom_lock) based
on an assumption that the owner of oom_lock is making progress for us. But
it is possible to trigger OOM lockup when many threads concurrently called
__alloc_pages_slowpath() because all CPU resources are wasted for pointless
direct reclaim efforts. That is, schedule_timeout_uninterruptible(1) in
__alloc_pages_may_oom() does not always give enough CPU resource to the
owner of the oom_lock.

It is possible that the owner of oom_lock is preempted by other threads.
Preemption makes the OOM situation much worse. But the page allocator is
not responsible about wasting CPU resource for something other than memory
allocation request. Wasting CPU resource for memory allocation request
without allowing the owner of oom_lock to make forward progress is a page
allocator's bug.

Therefore, this patch changes to wait for oom_lock in order to guarantee
that no thread waiting for the owner of oom_lock to make forward progress
will not consume CPU resources for pointless direct reclaim efforts.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2b42f6..0cd48ae6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3350,11 +3350,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 
 	*did_some_progress = 0;
 
-	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
-	 */
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
