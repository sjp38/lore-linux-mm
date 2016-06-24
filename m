Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF596B025F
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:55:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a66so13320003wme.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:55:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 133si3209558wml.58.2016.06.24.02.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:55:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 03/17] mm, page_alloc: don't retry initial attempt in slowpath
Date: Fri, 24 Jun 2016 11:54:23 +0200
Message-Id: <20160624095437.16385-4-vbabka@suse.cz>
In-Reply-To: <20160624095437.16385-1-vbabka@suse.cz>
References: <20160624095437.16385-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
first tries get_page_from_freelist() with the new alloc_flags, as it may
succeed e.g. due to using min watermark instead of low watermark. It makes
sense to to do this attempt before adjusting zonelist based on
alloc_flags/gfp_mask, as it's still relatively a fast path if we just wake up
kswapd and successfully allocate.

This patch therefore moves the initial attempt above the retry label and
reorganizes a bit the part below the retry label. We still have to attempt
get_page_from_freelist() on each retry, as some allocations cannot do that
as part of direct reclaim or compaction, and yet are not allowed to fail
(even though they do a WARN_ON_ONCE() and thus should not exist). We can reuse
the call meant for ALLOC_NO_WATERMARKS attempt and just set alloc_flags to
ALLOC_NO_WATERMARKS if the context allows it. As a side-effect, the attempts
from direct reclaim/compaction will also no longer obey watermarks once this
is set, but there's little harm in that.

Kswapd wakeups are also done on each retry to be safe from potential races
resulting in kswapd going to sleep while a process (that may not be able to
reclaim by itself) is still looping.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 82545274adbe..06cfa4bb807d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3582,35 +3582,42 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
+		wake_all_kswapds(order, ac);
+
+	/*
+	 * The adjusted alloc_flags might result in immediate success, so try
+	 * that first
+	 */
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	if (page)
+		goto got_pg;
+
+
 retry:
+	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
+	if (gfp_pfmemalloc_allowed(gfp_mask))
+		alloc_flags = ALLOC_NO_WATERMARKS;
+
 	/*
 	 * Reset the zonelist iterators if memory policies can be ignored.
 	 * These allocations are high priority and system rather than user
 	 * orientated.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) || gfp_pfmemalloc_allowed(gfp_mask)) {
+	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
 					ac->high_zoneidx, ac->nodemask);
 	}
 
-	/* This is the last chance, in general, before the goto nopage. */
+	/* Attempt with potentially adjusted zonelist and alloc_flags */
 	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
-	/* Allocate without watermarks if the context allows */
-	if (gfp_pfmemalloc_allowed(gfp_mask)) {
-
-		page = get_page_from_freelist(gfp_mask, order,
-						ALLOC_NO_WATERMARKS, ac);
-		if (page)
-			goto got_pg;
-	}
-
 	/* Caller is not willing to reclaim, we can't balance anything */
 	if (!can_direct_reclaim) {
 		/*
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
