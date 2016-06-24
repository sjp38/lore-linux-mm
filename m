Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAB5A828E1
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 06:02:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so13319242wme.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 03:02:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y13si3198616wmh.72.2016.06.24.02.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:55:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 05/17] mm, page_alloc: make THP-specific decisions more generic
Date: Fri, 24 Jun 2016 11:54:25 +0200
Message-Id: <20160624095437.16385-6-vbabka@suse.cz>
In-Reply-To: <20160624095437.16385-1-vbabka@suse.cz>
References: <20160624095437.16385-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Since THP allocations during page faults can be costly, extra decisions are
employed for them to avoid excessive reclaim and compaction, if the initial
compaction doesn't look promising. The detection has never been perfect as
there is no gfp flag specific to THP allocations. At this moment it checks the
whole combination of flags that makes up GFP_TRANSHUGE, and hopes that no other
users of such combination exist, or would mind being treated the same way.
Extra care is also taken to separate allocations from khugepaged, where latency
doesn't matter that much.

It is however possible to distinguish these allocations in a simpler and more
reliable way. The key observation is that after the initial compaction followed
by the first iteration of "standard" reclaim/compaction, both __GFP_NORETRY
allocations and costly allocations without __GFP_REPEAT are declared as
failures:

        /* Do not loop if specifically requested */
        if (gfp_mask & __GFP_NORETRY)
                goto nopage;

        /*
         * Do not retry costly high order allocations unless they are
         * __GFP_REPEAT
         */
        if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
                goto nopage;

This means we can further distinguish allocations that are costly order *and*
additionally include the __GFP_NORETRY flag. As it happens, GFP_TRANSHUGE
allocations do already fall into this category. This will also allow other
costly allocations with similar high-order benefit vs latency considerations to
use this semantic. Furthermore, we can distinguish THP allocations that should
try a bit harder (such as from khugepageed) by removing __GFP_NORETRY, as will
be done in the next patch.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a3a7a9dbdff..246cba86b257 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3159,7 +3159,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-
 /*
  * Maximum number of compaction retries wit a progress before OOM
  * killer is consider as the only way to move forward.
@@ -3443,11 +3442,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return false;
 }
 
-static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
-{
-	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
-}
-
 /*
  * Maximum number of reclaim retries without any progress before OOM killer
  * is consider as the only way to move forward.
@@ -3605,8 +3599,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		if (page)
 			goto got_pg;
 
-		/* Checks for THP-specific high-order allocations */
-		if (is_thp_gfp_mask(gfp_mask)) {
+		/*
+		 * Checks for costly allocations with __GFP_NORETRY, which
+		 * includes THP page fault allocations
+		 */
+		if (gfp_mask & __GFP_NORETRY) {
 			/*
 			 * If compaction is deferred for high-order allocations,
 			 * it is because sync compaction recently failed. If
@@ -3626,11 +3623,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				goto nopage;
 
 			/*
-			 * It can become very expensive to allocate transparent
-			 * hugepages at fault, so use asynchronous memory
-			 * compaction for THP unless it is khugepaged trying to
-			 * collapse. All other requests should tolerate at
-			 * least light sync migration.
+			 * Looks like reclaim/compaction is worth trying, but
+			 * sync compaction could be very expensive, so keep
+			 * using async compaction, unless it's khugepaged
+			 * trying to collapse.
 			 */
 			if (!(current->flags & PF_KTHREAD))
 				migration_mode = MIGRATE_ASYNC;
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
