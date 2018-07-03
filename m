Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4BED56B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:26:14 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v142-v6so1992608itb.1
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:26:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a124-v6si1162383ite.38.2018.07.03.07.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:26:13 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 8/8] mm,page_alloc: Move the short sleep to should_reclaim_retry().
Date: Tue,  3 Jul 2018 23:25:09 +0900
Message-Id: <1530627910-3415-9-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

From: Michal Hocko <mhocko@suse.com>

Since the page allocator can now spend CPU resource for oom_reap_mm()
for their interested OOM domains, the short sleep for waiting for the
owner of oom_lock no longer makes sense.

should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
is a special case which needs a stronger rescheduling policy. Doing that
unconditionally seems more straightforward than depending on a zone being
a good candidate for a further reclaim.

Thus, move the short sleep for waiting for the owner of oom_lock (which
coincidentally also serves as a guaranteed sleep for PF_WQ_WORKER threads)
to should_reclaim_retry().

Signed-off-by: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/page_alloc.c | 40 ++++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4c648f7..010b536 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3904,6 +3904,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
 	struct zone *zone;
 	struct zoneref *z;
+	bool ret = false;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3967,25 +3968,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 				}
 			}
 
-			/*
-			 * Memory allocation/reclaim might be called from a WQ
-			 * context and the current implementation of the WQ
-			 * concurrency control doesn't recognize that
-			 * a particular WQ is congested if the worker thread is
-			 * looping without ever sleeping. Therefore we have to
-			 * do a short sleep here rather than calling
-			 * cond_resched().
-			 */
-			if (current->flags & PF_WQ_WORKER)
-				schedule_timeout_uninterruptible(1);
-			else
-				cond_resched();
-
-			return true;
+			ret = true;
+			goto out;
 		}
 	}
 
-	return false;
+out:
+	/*
+	 * Memory allocation/reclaim might be called from a WQ
+	 * context and the current implementation of the WQ
+	 * concurrency control doesn't recognize that
+	 * a particular WQ is congested if the worker thread is
+	 * looping without ever sleeping. Therefore we have to
+	 * do a short sleep here rather than calling
+	 * cond_resched().
+	 */
+	if (current->flags & PF_WQ_WORKER)
+		schedule_timeout_uninterruptible(1);
+	else
+		cond_resched();
+	return ret;
 }
 
 static inline bool
@@ -4226,12 +4228,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
-		/*
-		 * This schedule_timeout_*() serves as a guaranteed sleep for
-		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
-		 */
-		if (!tsk_is_oom_victim(current))
-			schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 
-- 
1.8.3.1
