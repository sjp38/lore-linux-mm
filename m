Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52CA46B0388
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:53 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so10995432wjy.6
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 89si2940789wre.175.2017.02.10.09.23.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:51 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 08/10] mm, compaction: finish whole pageblock to reduce fragmentation
Date: Fri, 10 Feb 2017 18:23:41 +0100
Message-Id: <20170210172343.30283-9-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

The main goal of direct compaction is to form a high-order page for allocation,
but it should also help against long-term fragmentation when possible. Most
lower-than-pageblock-order compactions are for non-movable allocations, which
means that if we compact in a movable pageblock and terminate as soon as we
create the high-order page, it's unlikely that the fallback heuristics will
claim the whole block. Instead there might be a single unmovable page in a
pageblock full of movable pages, and the next unmovable allocation might pick
another pageblock and increase long-term fragmentation.

To help against such scenarios, this patch changes the termination criteria for
compaction so that the current pageblock is finished even though the high-order
page already exists. Note that it might be possible that the high-order page
formed elsewhere in the zone due to parallel activity, but this patch doesn't
try to detect that.

This is only done with sync compaction, because async compaction is limited to
pageblock of the same migratetype, where it cannot result in a migratetype
fallback. (Async compaction also eagerly skips order-aligned blocks where
isolation fails, which is against the goal of migrating away as much of the
pageblock as possible.)

As a result of this patch, long-term memory fragmentation should be reduced.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 35 +++++++++++++++++++++++++++++++++--
 mm/internal.h   |  1 +
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 84ef44c3b1c9..cef77a5fffea 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1329,6 +1329,17 @@ static enum compact_result __compact_finished(struct zone *zone,
 	if (is_via_compact_memory(cc->order))
 		return COMPACT_CONTINUE;
 
+	if (cc->finishing_block) {
+		/*
+		 * We have finished the pageblock, but better check again that
+		 * we really succeeded.
+		 */
+		if (IS_ALIGNED(cc->migrate_pfn, pageblock_nr_pages))
+			cc->finishing_block = false;
+		else
+			return COMPACT_CONTINUE;
+	}
+
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		struct free_area *area = &zone->free_area[order];
@@ -1349,8 +1360,28 @@ static enum compact_result __compact_finished(struct zone *zone,
 		 * other migratetype buddy lists.
 		 */
 		if (find_suitable_fallback(area, order, migratetype,
-						true, &can_steal) != -1)
-			return COMPACT_SUCCESS;
+						true, &can_steal) != -1) {
+
+			/* movable pages are OK in any pageblock */
+			if (migratetype == MIGRATE_MOVABLE)
+				return COMPACT_SUCCESS;
+
+			/*
+			 * We are stealing for a non-movable allocation. Make
+			 * sure we finish compacting the current pageblock
+			 * first so it is as free as possible and we won't
+			 * have to steal another one soon. This only applies
+			 * to sync compaction, as async compaction operates
+			 * on pageblocks of the same migratetype.
+			 */
+			if (cc->mode == MIGRATE_ASYNC ||
+				IS_ALIGNED(cc->migrate_pfn, pageblock_nr_pages)) {
+				return COMPACT_SUCCESS;
+			} else {
+				cc->finishing_block = true;
+				return COMPACT_CONTINUE;
+			}
+		}
 	}
 
 	return COMPACT_NO_SUITABLE_PAGE;
diff --git a/mm/internal.h b/mm/internal.h
index 888f33cc7641..cdb33c957906 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -188,6 +188,7 @@ struct compact_control {
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	bool contended;			/* Signal lock or sched contention */
+	bool finishing_block;		/* Finishing current pageblock */
 };
 
 unsigned long
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
