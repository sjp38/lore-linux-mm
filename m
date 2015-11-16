Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D1C526B0254
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:22:28 -0500 (EST)
Received: by wmdw130 with SMTP id w130so110733389wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:22:28 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id kt2si45866480wjb.176.2015.11.16.05.22.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 05:22:27 -0800 (PST)
Received: by wmvv187 with SMTP id v187so176020070wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:22:27 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH 1/2] mm: get rid of __alloc_pages_high_priority
Date: Mon, 16 Nov 2015 14:22:18 +0100
Message-Id: <1447680139-16484-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_high_priority doesn't do anything special other than it
calls get_page_from_freelist and loops around GFP_NOFAIL allocation
until it succeeds. It would be better if the first part was done in
__alloc_pages_slowpath where we modify the zonelist because this would
be easier to read and understand. Opencoding the function into its only
caller allows to simplify it a bit as well.

This patch doesn't introduce any functional changes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 36 +++++++++---------------------------
 1 file changed, 9 insertions(+), 27 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8034909faad2..b153fa3d0b9b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2902,28 +2902,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-/*
- * This is called in the allocator slow-path if the allocation request is of
- * sufficient urgency to ignore watermarks and take other desperate measures
- */
-static inline struct page *
-__alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
-				const struct alloc_context *ac)
-{
-	struct page *page;
-
-	do {
-		page = get_page_from_freelist(gfp_mask, order,
-						ALLOC_NO_WATERMARKS, ac);
-
-		if (!page && gfp_mask & __GFP_NOFAIL)
-			wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC,
-									HZ/50);
-	} while (!page && (gfp_mask & __GFP_NOFAIL));
-
-	return page;
-}
-
 static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 {
 	struct zoneref *z;
@@ -3068,12 +3046,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * allocations are system rather than user orientated
 		 */
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		do {
+			page = get_page_from_freelist(gfp_mask, order,
+							ALLOC_NO_WATERMARKS, ac);
+			if (page)
+				goto got_pg;
 
-		page = __alloc_pages_high_priority(gfp_mask, order, ac);
-
-		if (page) {
-			goto got_pg;
-		}
+			if (gfp_mask & __GFP_NOFAIL)
+				wait_iff_congested(ac->preferred_zone,
+						   BLK_RW_ASYNC, HZ/50);
+		} while (gfp_mask & __GFP_NOFAIL);
 	}
 
 	/* Caller is not willing to reclaim, we can't balance anything */
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
