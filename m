Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id C2C566B006C
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:32:57 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/16] mm: Only set page->pfmemalloc when ALLOC_NO_WATERMARKS was used
Date: Fri, 29 Jun 2012 14:32:36 +0100
Message-Id: <1340976767-5737-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1340976767-5737-1-git-send-email-mgorman@suse.de>
References: <1340976767-5737-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

__alloc_pages_slowpath() is called when the number of free pages is below
the low watermark. If the caller is entitled to use ALLOC_NO_WATERMARKS
then the page will be marked page->pfmemalloc.  This protects more pages
than are strictly necessary as we only need to protect pages allocated
below the min watermark (the pfmemalloc reserves).

This patch only sets page->pfmemalloc when ALLOC_NO_WATERMARKS was
required to allocate the page.

[rientjes@google.com: David noticed the problem during review]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5c6d9c6..9883cf7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2085,8 +2085,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
-				alloc_flags, preferred_zone,
-				migratetype);
+				alloc_flags & ~ALLOC_NO_WATERMARKS,
+				preferred_zone, migratetype);
 		if (page) {
 			preferred_zone->compact_considered = 0;
 			preferred_zone->compact_defer_shift = 0;
@@ -2178,8 +2178,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
-					alloc_flags, preferred_zone,
-					migratetype);
+					alloc_flags & ~ALLOC_NO_WATERMARKS,
+					preferred_zone, migratetype);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2350,8 +2350,17 @@ rebalance:
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-		if (page)
+		if (page) {
+			/*
+			 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
+			 * necessary to allocate the page. The expectation is
+			 * that the caller is taking steps that will free more
+			 * memory. The caller should avoid the page being used
+			 * for !PFMEMALLOC purposes.
+			 */
+			page->pfmemalloc = true;
 			goto got_pg;
+		}
 	}
 
 	/* Atomic allocations - we can't balance anything */
@@ -2468,14 +2477,6 @@ nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 	return page;
 got_pg:
-	/*
-	 * page->pfmemalloc is set when the caller had PFMEMALLOC set, is
-	 * been OOM killed or specified __GFP_MEMALLOC. The expectation is
-	 * that the caller is taking steps that will free more memory. The
-	 * caller should avoid the page being used for !PFMEMALLOC purposes.
-	 */
-	page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
-
 	if (kmemcheck_enabled)
 		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
