Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 544146B0260
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:08:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so43550511wme.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:08:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si36963846wmd.69.2016.05.31.06.08.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:08:35 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 03/18] mm, page_alloc: don't retry initial attempt in slowpath
Date: Tue, 31 May 2016 15:08:03 +0200
Message-Id: <20160531130818.28724-4-vbabka@suse.cz>
In-Reply-To: <20160531130818.28724-1-vbabka@suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
first tries get_page_from_freelist() with the new alloc_flags, as it may
succeed e.g. due to using min watermark instead of low watermark. This attempt
does not have to be retried on each loop, since direct reclaim, direct
compaction and oom call get_page_from_freelist() themselves. There is a corner
case where direct reclaim does not attempt allocation when there is no reclaim
progress, but that is trivial to adjust.

This patch therefore moves the initial attempt above the retry label. The
ALLOC_NO_WATERMARKS attempt is kept under retry label as it's special and
should be retried after each loop. Kswapd wakeups are also done on each retry
to be safe from potential races resulting in kswapd going to sleep while a
process (that may not be able to reclaim by itself) is still looping.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index da3a62a94b4a..9f83259a18a8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3367,10 +3367,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	bool drained = false;
 
 	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
-	if (unlikely(!(*did_some_progress)))
-		return NULL;
 
 retry:
+	/* We attempt even when no progress, as kswapd might have done some */
 	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 
 	/*
@@ -3378,7 +3377,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	 * pages are pinned on the per-cpu lists or in high alloc reserves.
 	 * Shrink them them and try again
 	 */
-	if (!page && !drained) {
+	if (!page && *did_some_progress && !drained) {
 		unreserve_highatomic_pageblock(ac);
 		drain_all_pages(NULL);
 		drained = true;
@@ -3592,15 +3591,22 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
-retry:
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-	/* This is the last chance, in general, before the goto nopage. */
+	/*
+	 * The adjusted alloc_flags might result in immediate success, so try
+	 * that first
+	 */
 	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
+retry:
+	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
+	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
+		wake_all_kswapds(order, ac);
+
 	/* Allocate without watermarks if the context allows */
 	if (gfp_pfmemalloc_allowed(gfp_mask)) {
 		/*
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
