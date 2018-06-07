Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09F1A6B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:01:00 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id j24-v6so5951807otk.11
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:01:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 102-v6si4392275oti.443.2018.06.07.04.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 04:00:58 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/4] mm,page_alloc: Move the short sleep to should_reclaim_retry()
Date: Thu,  7 Jun 2018 20:00:21 +0900
Message-Id: <1528369223-7571-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
is a special case which needs a stronger rescheduling policy. Doing that
unconditionally seems more straightforward than depending on a zone being
a good candidate for a further reclaim.

Thus, move the short sleep when we are waiting for the owner of oom_lock
(which coincidentally also serves as a guaranteed sleep for PF_WQ_WORKER
threads) to should_reclaim_retry(). Note that it is not evaluated that
whether there is negative side effect with this change. We need to test
both real and artificial workloads for evaluation. You can compare with
and without this patch if you noticed something unexpected.

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
index e90f152..210a476 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3914,6 +3914,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
 	struct zone *zone;
 	struct zoneref *z;
+	bool ret = false;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3977,25 +3978,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
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
@@ -4237,12 +4239,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
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
