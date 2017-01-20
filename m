Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7646B0253
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:38:57 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gt1so14077513wjc.0
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:38:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o125si2970751wmg.18.2017.01.20.02.38.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 02:38:56 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 3/4] mm, page_alloc: move cpuset seqcount checking to slowpath
Date: Fri, 20 Jan 2017 11:38:42 +0100
Message-Id: <20170120103843.24587-4-vbabka@suse.cz>
In-Reply-To: <20170120103843.24587-1-vbabka@suse.cz>
References: <20170120103843.24587-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

This is a preparation for the following patch to make review simpler. While
the primary motivation is a bug fix, this also simplifies the fast path,
although the moved code is only enabled when cpusets are in use.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 47 ++++++++++++++++++++++++++---------------------
 1 file changed, 26 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3ca0c15deca4..fd3b9839a355 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3523,12 +3523,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
-	enum compact_priority compact_priority = DEF_COMPACT_PRIORITY;
+	enum compact_priority compact_priority;
 	enum compact_result compact_result;
-	int compaction_retries = 0;
-	int no_progress_loops = 0;
+	int compaction_retries;
+	int no_progress_loops;
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
+	unsigned int cpuset_mems_cookie;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3549,6 +3550,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
 		gfp_mask &= ~__GFP_ATOMIC;
 
+retry_cpuset:
+	compaction_retries = 0;
+	no_progress_loops = 0;
+	compact_priority = DEF_COMPACT_PRIORITY;
+	cpuset_mems_cookie = read_mems_allowed_begin();
+
 	/*
 	 * The fast path uses conservative alloc_flags to succeed only until
 	 * kswapd needs to be woken up, and to avoid the cost of setting up
@@ -3720,6 +3727,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 nopage:
+	/*
+	 * When updating a task's mems_allowed, it is possible to race with
+	 * parallel threads in such a way that an allocation can fail while
+	 * the mask is being updated. If a page allocation is about to fail,
+	 * check if the cpuset changed during allocation and if so, retry.
+	 */
+	if (read_mems_allowed_retry(cpuset_mems_cookie))
+		goto retry_cpuset;
+
 	warn_alloc(gfp_mask,
 			"page allocation failure: order:%u", order);
 got_pg:
@@ -3734,7 +3750,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
 	struct page *page;
-	unsigned int cpuset_mems_cookie;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW;
 	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
@@ -3771,9 +3786,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 
-retry_cpuset:
-	cpuset_mems_cookie = read_mems_allowed_begin();
-
 	/* Dirty zone balancing only done in the fast path */
 	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
@@ -3786,6 +3798,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 					ac.high_zoneidx, ac.nodemask);
 	if (!ac.preferred_zoneref->zone) {
 		page = NULL;
+		/*
+		 * This might be due to race with cpuset_current_mems_allowed
+		 * update, so make sure we retry with original nodemask in the
+		 * slow path.
+		 */
 		goto no_zone;
 	}
 
@@ -3794,6 +3811,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (likely(page))
 		goto out;
 
+no_zone:
 	/*
 	 * Runtime PM, block IO and its error handling path can deadlock
 	 * because I/O on the device might not complete.
@@ -3811,24 +3829,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		ac.nodemask = nodemask;
 		ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
 						ac.high_zoneidx, ac.nodemask);
-		if (!ac.preferred_zoneref->zone)
-			goto no_zone;
+		/* If we have NULL preferred zone, slowpath wll handle that */
 	}
 
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 
-no_zone:
-	/*
-	 * When updating a task's mems_allowed, it is possible to race with
-	 * parallel threads in such a way that an allocation can fail while
-	 * the mask is being updated. If a page allocation is about to fail,
-	 * check if the cpuset changed during allocation and if so, retry.
-	 */
-	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie))) {
-		alloc_mask = gfp_mask;
-		goto retry_cpuset;
-	}
-
 out:
 	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
 	    unlikely(memcg_kmem_charge(page, gfp_mask, order) != 0)) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
