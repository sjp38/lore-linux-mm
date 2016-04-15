Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F35E76B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:08:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l6so13198871wml.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:08:07 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id 195si39068001wmh.23.2016.04.15.02.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:08:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 7D2471C1B3B
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:08:06 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 13/28] mm, page_alloc: Remove redundant check for empty zonelist
Date: Fri, 15 Apr 2016 10:07:40 +0100
Message-Id: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

A check is made for an empty zonelist early in the page allocator fast path
but it's unnecessary. When get_page_from_freelist() is called, it'll return
NULL immediately. Removing the first check is slower for machines with
memoryless nodes but that is a corner case that can live with the overhead.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df03ccc7f07c..21aaef6ddd7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3374,14 +3374,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (should_fail_alloc_page(gfp_mask, order))
 		return NULL;
 
-	/*
-	 * Check the zones suitable for the gfp_mask contain at least one
-	 * valid zone. It's possible to have an empty zonelist as a result
-	 * of __GFP_THISNODE and a memoryless node
-	 */
-	if (unlikely(!zonelist->_zonerefs->zone))
-		return NULL;
-
 	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 
@@ -3394,8 +3386,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/* The preferred zone is used for statistics later */
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
 				ac.nodemask, &ac.preferred_zone);
-	if (!ac.preferred_zone)
-		goto out;
 	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 	/* First allocation attempt */
@@ -3418,7 +3408,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
 
-out:
 	/*
 	 * When updating a task's mems_allowed, it is possible to race with
 	 * parallel threads in such a way that an allocation can fail while
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
