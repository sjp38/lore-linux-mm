Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEF716B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 04:12:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f193so83563151wmg.0
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 01:12:26 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ig4si2907281wjb.128.2016.10.04.01.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 01:12:24 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b201so13208419wmb.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 01:12:24 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS requests
Date: Tue,  4 Oct 2016 10:12:15 +0200
Message-Id: <20161004081215.5563-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
direct compact when a high-order allocation fails"). The main reason
is that the migration of page cache pages might recurse back to fs/io
layer and we could potentially deadlock. This is overly conservative
because all the anonymous memory is migrateable in the GFP_NOFS context
just fine.  This might be a large portion of the memory in many/most
workkloads.

Remove the GFP_NOFS restriction and make sure that we skip all fs pages
(those with a mapping) while isolating pages to be migrated. We cannot
consider clean fs pages because they might need a metadata update so
only isolate pages without any mapping for nofs requests.

The effect of this patch will be probably very limited in many/most
workloads because higher order GFP_NOFS requests are quite rare,
although different configurations might lead to very different results
as GFP_NOFS usage is rather unleashed (e.g. I had hard time to trigger
any with my setup). But still there shouldn't be any strong reason to
completely back off and do nothing in that context. In the worst case
we just skip parts of the block with fs pages. This might be still
sufficient to make a progress for small orders.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I am sending this as an RFC because I am not completely sure this a) is
really worth it and b) it is 100% correct. I couldn't find any problems
when staring into the code but as mentioned in the changelog I wasn't
really able to trigger high order GFP_NOFS requests in my setup.

Thoughts?

 mm/compaction.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index badb92bf14b4..07254a73ee32 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -834,6 +834,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		    page_count(page) > page_mapcount(page))
 			goto isolate_fail;
 
+		/*
+		 * Only allow to migrate anonymous pages in GFP_NOFS context
+		 * because those do not depend on fs locks.
+		 */
+		if (!(cc->gfp_mask & __GFP_FS) && page_mapping(page))
+			goto isolate_fail;
+
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
 			locked = compact_trylock_irqsave(zone_lru_lock(zone),
@@ -1696,14 +1703,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum compact_priority prio)
 {
-	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
 	struct zone *zone;
 	enum compact_result rc = COMPACT_SKIPPED;
 
-	/* Check if the GFP flags allow compaction */
-	if (!may_enter_fs || !may_perform_io)
+	/*
+	 * Check if the GFP flags allow compaction - GFP_NOIO is really
+	 * tricky context because the migration might require IO and
+	 */
+	if (!may_perform_io)
 		return COMPACT_SKIPPED;
 
 	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, prio);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
