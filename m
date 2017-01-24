Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B11E26B027B
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 10:05:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so28571238wmd.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 07:05:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c17si17265591wrb.34.2017.01.24.07.05.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 07:05:17 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/2] mm, page_alloc: remove redundant checks from alloc fastpath
Date: Tue, 24 Jan 2017 16:05:10 +0100
Message-Id: <20170124150511.5710-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

The allocation fast path contains two similar checks for zoneref->zone being
NULL, where zoneref points either to the first zone in the zonelist, or to the
preferred zone. These can be NULL either due to empty zonelist, or no zone
being compatible with given nodemask or task's cpuset.

These checks are unnecessary, because the zonelist walks in
first_zones_zonelist() and get_page_from_freelist() handle a NULL starting
zoneref->zone or preferred_zoneref->zone safely. It's safe to fallback to
__alloc_pages_slowpath() where we also have the check early enough.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
This and the following patch is on top of Mel's bulk cpu work.

 mm/page_alloc.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9288175e57e3..05068adf9007 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3912,14 +3912,6 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 	if (should_fail_alloc_page(gfp_mask, order))
 		return false;
 
-	/*
-	 * Check the zones suitable for the gfp_mask contain at least one
-	 * valid zone. It's possible to have an empty zonelist as a result
-	 * of __GFP_THISNODE and a memoryless node
-	 */
-	if (unlikely(!ac->zonelist->_zonerefs->zone))
-		return false;
-
 	if (IS_ENABLED(CONFIG_CMA) && ac->migratetype == MIGRATE_MOVABLE)
 		*alloc_flags |= ALLOC_CMA;
 
@@ -3959,22 +3951,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	finalise_ac(gfp_mask, order, &ac);
-	if (!ac.preferred_zoneref->zone) {
-		page = NULL;
-		/*
-		 * This might be due to race with cpuset_current_mems_allowed
-		 * update, so make sure we retry with original nodemask in the
-		 * slow path.
-		 */
-		goto no_zone;
-	}
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
 	if (likely(page))
 		goto out;
 
-no_zone:
 	/*
 	 * Runtime PM, block IO and its error handling path can deadlock
 	 * because I/O on the device might not complete.
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
