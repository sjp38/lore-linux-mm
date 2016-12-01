Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC3928025A
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 10:25:28 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o3so39599358wjo.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:25:28 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id l10si626367wjr.92.2016.12.01.07.25.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 07:25:27 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id g23so34806648wme.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:25:27 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath
Date: Thu,  1 Dec 2016 16:25:16 +0100
Message-Id: <20161201152517.27698-2-mhocko@kernel.org>
In-Reply-To: <20161201152517.27698-1-mhocko@kernel.org>
References: <20161201152517.27698-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo Handa has pointed out that 0a0337e0d1d1 ("mm, oom: rework oom
detection") has subtly changed semantic for costly high order requests
with __GFP_NOFAIL and withtout __GFP_REPEAT and those can fail right now.
My code inspection didn't reveal any such users in the tree but it is
true that this might lead to unexpected allocation failures and
subsequent OOPs.

__alloc_pages_slowpath wrt. GFP_NOFAIL is hard to follow currently.
There are few special cases but we are lacking a catch all place to be
sure we will not miss any case where the non failing allocation might
fail. This patch reorganizes the code a bit and puts all those special
cases under nopage label which is the generic go-to-fail path. Non
failing allocations are retried or those that cannot retry like
non-sleeping allocation go to the failure point directly. This should
make the code flow much easier to follow and make it less error prone
for future changes.

While we are there we have to move the stall check up to catch
potentially looping non-failing allocations.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 68 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 41 insertions(+), 27 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fbfead6aa7d..76c0b6bb0baf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3627,32 +3627,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Caller is not willing to reclaim, we can't balance anything */
-	if (!can_direct_reclaim) {
-		/*
-		 * All existing users of the __GFP_NOFAIL are blockable, so warn
-		 * of any new users that actually allow this type of allocation
-		 * to fail.
-		 */
-		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
+	if (!can_direct_reclaim)
 		goto nopage;
+
+	/* Make sure we know about allocations which stall for too long */
+	if (time_after(jiffies, alloc_start + stall_timeout)) {
+		warn_alloc(gfp_mask,
+			"page alloction stalls for %ums, order:%u",
+			jiffies_to_msecs(jiffies-alloc_start), order);
+		stall_timeout += 10 * HZ;
 	}
 
 	/* Avoid recursion of direct reclaim */
-	if (current->flags & PF_MEMALLOC) {
-		/*
-		 * __GFP_NOFAIL request from this context is rather bizarre
-		 * because we cannot reclaim anything and only can loop waiting
-		 * for somebody to do a work for us.
-		 */
-		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
-			cond_resched();
-			goto retry;
-		}
+	if (current->flags & PF_MEMALLOC)
 		goto nopage;
-	}
 
 	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+	if (test_thread_flag(TIF_MEMDIE))
 		goto nopage;
 
 
@@ -3679,14 +3670,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
-	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask,
-			"page alloction stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
-		stall_timeout += 10 * HZ;
-	}
-
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
 				 did_some_progress > 0, &no_progress_loops))
 		goto retry;
@@ -3715,6 +3698,37 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 nopage:
+	/*
+	 * Make sure that __GFP_NOFAIL request doesn't leak out and make sure
+	 * we always retry
+	 */
+	if (gfp_mask & __GFP_NOFAIL) {
+		/*
+		 * All existing users of the __GFP_NOFAIL are blockable, so warn
+		 * of any new users that actually require GFP_NOWAIT
+		 */
+		if (WARN_ON_ONCE(!can_direct_reclaim))
+			goto fail;
+
+		/*
+		 * PF_MEMALLOC request from this context is rather bizarre
+		 * because we cannot reclaim anything and only can loop waiting
+		 * for somebody to do a work for us
+		 */
+		WARN_ON_ONCE(current->flags & PF_MEMALLOC);
+
+		/*
+		 * non failing costly orders are a hard requirement which we
+		 * are not prepared for much so let's warn about these users
+		 * so that we can identify them and convert them to something
+		 * else.
+		 */
+		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
+
+		cond_resched();
+		goto retry;
+	}
+fail:
 	warn_alloc(gfp_mask,
 			"page allocation failure: order:%u", order);
 got_pg:
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
