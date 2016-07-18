Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3003B6B0263
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:23:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so55858620wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:23:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si596258wjg.193.2016.07.18.04.23.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 04:23:10 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/8] mm, page_alloc: set alloc_flags only once in slowpath
Date: Mon, 18 Jul 2016 13:22:56 +0200
Message-Id: <20160718112302.27381-3-vbabka@suse.cz>
In-Reply-To: <20160718112302.27381-1-vbabka@suse.cz>
References: <20160718112302.27381-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
so move the initialization above the retry: label. Also make the comment above
the initialization more descriptive.

The only exception in the alloc_flags being constant is ALLOC_NO_WATERMARKS,
which may change due to TIF_MEMDIE being set on the allocating thread. We can
fix this, and make the code simpler and a bit more effective at the same time,
by moving the part that determines ALLOC_NO_WATERMARKS from
gfp_to_alloc_flags() to gfp_pfmemalloc_allowed(). This means we don't have to
mask out ALLOC_NO_WATERMARKS in numerous places in __alloc_pages_slowpath()
anymore. The only two tests for the flag can instead call
gfp_pfmemalloc_allowed().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 571aca8c637a..eb1968a1041e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3119,8 +3119,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	page = get_page_from_freelist(gfp_mask, order,
-					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -3288,8 +3287,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 retry:
-	page = get_page_from_freelist(gfp_mask, order,
-					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -3351,16 +3349,6 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
-	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (gfp_mask & __GFP_MEMALLOC)
-			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
-			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (!in_interrupt() &&
-				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
-			alloc_flags |= ALLOC_NO_WATERMARKS;
-	}
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
@@ -3370,7 +3358,19 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 
 bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
-	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
+	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
+		return false;
+
+	if (gfp_mask & __GFP_MEMALLOC)
+		return true;
+	if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
+		return true;
+	if (!in_interrupt() &&
+			((current->flags & PF_MEMALLOC) ||
+			 unlikely(test_thread_flag(TIF_MEMDIE))))
+		return true;
+
+	return false;
 }
 
 static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
@@ -3534,36 +3534,36 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
 		gfp_mask &= ~__GFP_ATOMIC;
 
-retry:
-	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
-		wake_all_kswapds(order, ac);
-
 	/*
-	 * OK, we're below the kswapd watermark and have kicked background
-	 * reclaim. Now things get more complex, so set up alloc_flags according
-	 * to how we want to proceed.
+	 * The fast path uses conservative alloc_flags to succeed only until
+	 * kswapd needs to be woken up, and to avoid the cost of setting up
+	 * alloc_flags precisely. So we do that now.
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+retry:
+	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
+		wake_all_kswapds(order, ac);
+
 	/*
 	 * Reset the zonelist iterators if memory policies can be ignored.
 	 * These allocations are high priority and system rather than user
 	 * orientated.
 	 */
-	if ((alloc_flags & ALLOC_NO_WATERMARKS) || !(alloc_flags & ALLOC_CPUSET)) {
+	if (!(alloc_flags & ALLOC_CPUSET) || gfp_pfmemalloc_allowed(gfp_mask)) {
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
 					ac->high_zoneidx, ac->nodemask);
 	}
 
 	/* This is the last chance, in general, before the goto nopage. */
-	page = get_page_from_freelist(gfp_mask, order,
-				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
 	/* Allocate without watermarks if the context allows */
-	if (alloc_flags & ALLOC_NO_WATERMARKS) {
+	if (gfp_pfmemalloc_allowed(gfp_mask)) {
+
 		page = get_page_from_freelist(gfp_mask, order,
 						ALLOC_NO_WATERMARKS, ac);
 		if (page)
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
