Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B77486B0269
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:13:40 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id a140so47136363wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:13:40 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id g5si23091232wmd.47.2016.04.12.03.13.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:13:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 484B598BBB
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:13:39 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 13/24] mm, page_alloc: Remove redundant check for empty zonelist
Date: Tue, 12 Apr 2016 11:12:14 +0100
Message-Id: <1460455945-29644-14-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

A check is made for an empty zonelist early in the page allocator fast
path but it's unnecessary. The check after first_zones_zonelist call
should catch that situation. Removing the first check is slower for
machines with memoryless nodes but that is a corner case that can
live with the overhead.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df03ccc7f07c..e50e754ec9eb 100644
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
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
