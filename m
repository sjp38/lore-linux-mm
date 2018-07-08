Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42E376B0006
	for <linux-mm@kvack.org>; Sun,  8 Jul 2018 07:10:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f9-v6so8717240pfn.22
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 04:10:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h3-v6si12381956pld.114.2018.07.08.04.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jul 2018 04:10:35 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: PF_WQ_WORKER should always sleep at should_reclaim_retry().
Date: Sun,  8 Jul 2018 19:35:58 +0900
Message-Id: <1531046158-4010-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
is a special case which needs a stronger rescheduling policy. However,
since schedule_timeout_uninterruptible(1) for PF_WQ_WORKER depends on
__zone_watermark_ok() == true, PF_WQ_WORKER is currently counting on
mutex_trylock(&oom_lock) == 0 in __alloc_pages_may_oom() which is a bad
expectation.

Doing schedule_timeout_uninterruptible(1) at should_reclaim_retry()
unconditionally seems more straightforward than depending on a zone being
a good candidate for a further reclaim.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100..f56cc09 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3922,6 +3922,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
 	struct zone *zone;
 	struct zoneref *z;
+	bool ret = false;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3985,25 +3986,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
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
-- 
1.8.3.1
