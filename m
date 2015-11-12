Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5008D6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:53:47 -0500 (EST)
Received: by wmvv187 with SMTP id v187so39871123wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:53:46 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id 202si20277432wms.8.2015.11.12.07.53.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 07:53:46 -0800 (PST)
Received: by wmec201 with SMTP id c201so39871569wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:53:45 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH] mm: get rid of __alloc_pages_high_priority
Date: Thu, 12 Nov 2015 16:53:38 +0100
Message-Id: <1447343618-19696-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_high_priority doesn't do anything special other than it
calls get_page_from_freelist and loops around GFP_NOFAIL allocation
until it succeeds. It would be better if the first part was done in
__alloc_pages_slowpath where we modify the zonelist because this would
be easier to read and understand. And do the retry at the very same
place because retrying without even attempting to do any reclaim is
fragile because we are basically relying on somebody else to make the
reclaim (be it the direct reclaim or OOM killer) for us. The caller
might be holding resources (e.g. locks) which block other other
reclaimers from making any progress for example.

Remove the helper and open code it into its only user. We have to be
careful about __GFP_NOFAIL allocations from the PF_MEMALLOC context
even though this is a very bad idea to begin with because no progress
can be gurateed at all.  We shouldn't break the __GFP_NOFAIL semantic
here though. It could be argued that this is essentially GFP_NOWAIT
context which we do not support but PF_MEMALLOC is much harder to check
for existing users because they might happen deep down the code path
performed much later after setting the flag so we cannot really rule out
there is no kernel path triggering this combination.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I think that this is more a cleanup than any functional change. We
are rarely screwed so much that __alloc_pages_high_priority would
fail. Yet I think that __alloc_pages_high_priority is obscuring the
overal intention more than it is helpful. Another motivation is to
reduce wait_iff_congested call to a single one in the allocator. I plan
to do other changes in that area and get rid of it altogether.

 mm/page_alloc.c | 48 +++++++++++++++++-------------------------------
 1 file changed, 17 insertions(+), 31 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8034909faad2..df7746280427 100644
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
@@ -3068,28 +3046,36 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * allocations are system rather than user orientated
 		 */
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
-
-		page = __alloc_pages_high_priority(gfp_mask, order, ac);
-
-		if (page) {
+		page = get_page_from_freelist(gfp_mask, order,
+						ALLOC_NO_WATERMARKS, ac);
+		if (page)
 			goto got_pg;
-		}
 	}
 
 	/* Caller is not willing to reclaim, we can't balance anything */
 	if (!can_direct_reclaim) {
 		/*
-		 * All existing users of the deprecated __GFP_NOFAIL are
-		 * blockable, so warn of any new users that actually allow this
-		 * type of allocation to fail.
+		 * All existing users of the __GFP_NOFAIL are blockable, so warn
+		 * of any new users that actually allow this type of allocation
+		 * to fail.
 		 */
 		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
 		goto nopage;
 	}
 
 	/* Avoid recursion of direct reclaim */
-	if (current->flags & PF_MEMALLOC)
+	if (current->flags & PF_MEMALLOC) {
+		/*
+		 * __GFP_NOFAIL request from this context is rather bizarre
+		 * because we cannot reclaim anything and only can loop waiting
+		 * for somebody to do a work for us.
+		 */
+		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+			cond_resched();
+			goto retry;
+		}
 		goto nopage;
+	}
 
 	/* Avoid allocations with no watermarks from looping endlessly */
 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
