Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B045D6B0072
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:34:01 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id hi2so8260881wib.15
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:34:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8si14556529wic.70.2014.10.07.08.33.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/5] mm, compaction: simplify deferred compaction
Date: Tue,  7 Oct 2014 17:33:36 +0200
Message-Id: <1412696019-21761-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Since commit ("mm, compaction: defer each zone individually instead of
preferred zone"), compaction is deferred for each zone where sync direct
compaction fails, and reset where it succeeds. However, it was observed
that for DMA zone compaction often appeared to succeed while subsequent
allocation attempt would not, due to different outcome of watermark check.
In order to properly defer compaction in this zone, the candidate zone has
to be passed back to __alloc_pages_direct_compact() and compaction deferred
in the zone after the allocation attempt fails.

The large source of mismatch between watermark check in compaction and
allocation was the lack of alloc_flags and classzone_idx values in compaction,
which has been fixed in the previous patch. So with this problem fixed, we
can simplify the code by removing the candidate_zone parameter and deferring
in __alloc_pages_direct_compact().

After this patch, the compaction activity during stress-highalloc benchmark is
still somewhat increased, but it's negligible compared to the increase that
occurred without the better watermark checking. This suggests that it is still
possible to apparently succeed in compaction but fail to allocate, possibly
due to parallel allocation activity.

Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/compaction.h |  6 ++----
 mm/compaction.c            |  5 +----
 mm/page_alloc.c            | 12 +-----------
 3 files changed, 4 insertions(+), 19 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index d896765..58c293d 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -33,8 +33,7 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			enum migrate_mode mode, int *contended,
-			int alloc_flags, int classzone_idx,
-			struct zone **candidate_zone);
+			int alloc_flags, int classzone_idx);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order,
@@ -105,8 +104,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
 			enum migrate_mode mode, int *contended,
-			int alloc_flags, int classzone_idx,
-			struct zone **candidate_zone)
+			int alloc_flags, int classzone_idx);
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index dba8891..4b3e0bd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1276,15 +1276,13 @@ int sysctl_extfrag_threshold = 500;
  * @mode: The migration mode for async, sync light, or sync migration
  * @contended: Return value that determines if compaction was aborted due to
  *	       need_resched() or lock contention
- * @candidate_zone: Return the zone where we think allocation should succeed
  *
  * This is the main entry point for direct page compaction.
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
 			enum migrate_mode mode, int *contended,
-			int alloc_flags, int classzone_idx,
-			struct zone **candidate_zone)
+			int alloc_flags, int classzone_idx)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -1321,7 +1319,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
 					classzone_idx, alloc_flags)) {
-			*candidate_zone = zone;
 			/*
 			 * We think the allocation will succeed in this zone,
 			 * but it is not certain, hence the false. The caller
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8d143a0..5a4506f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2328,7 +2328,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	int classzone_idx, int migratetype, enum migrate_mode mode,
 	int *contended_compaction, bool *deferred_compaction)
 {
-	struct zone *last_compact_zone = NULL;
 	unsigned long compact_result;
 	struct page *page;
 
@@ -2339,8 +2338,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	compact_result = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, mode,
 						contended_compaction,
-						alloc_flags, classzone_idx,
-						&last_compact_zone);
+						alloc_flags, classzone_idx);
 	current->flags &= ~PF_MEMALLOC;
 
 	switch (compact_result) {
@@ -2378,14 +2376,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/*
-	 * last_compact_zone is where try_to_compact_pages thought allocation
-	 * should succeed, so it did not defer compaction. But here we know
-	 * that it didn't succeed, so we do the defer.
-	 */
-	if (last_compact_zone && mode != MIGRATE_ASYNC)
-		defer_compaction(last_compact_zone, order);
-
-	/*
 	 * It's bad if compaction run occurs and fails. The most likely reason
 	 * is that pages exist, but not enough to satisfy watermarks.
 	 */
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
