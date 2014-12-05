Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id AD4DD6B0070
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 14:59:19 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so2512409wiv.1
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 11:59:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dj10si3836333wib.59.2014.12.05.11.59.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 11:59:17 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 3/4] mm: reduce try_to_compact_pages parameters
Date: Fri,  5 Dec 2014 20:59:04 +0100
Message-Id: <1417809545-4540-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
References: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Use the struct alloc_context introduced in the previous patch also when calling
try_to_compact_pages(), to reduce the number of parameters. Since it's in
different compilation modeule, definition of the struct is moved to mm.h.
With this change we get small savings of code size and stack usage.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h | 14 ++++++--------
 include/linux/mm.h         | 11 +++++++++++
 mm/compaction.c            | 16 ++++++++--------
 mm/page_alloc.c            | 22 ++++------------------
 4 files changed, 29 insertions(+), 34 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 3238ffa..482b359 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -30,10 +30,9 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
-extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
-			int order, gfp_t gfp_mask, nodemask_t *mask,
-			enum migrate_mode mode, int *contended,
-			int alloc_flags, int classzone_idx);
+extern unsigned long try_to_compact_pages(gfp_t gfp_mask,
+			int alloc_flags, const struct alloc_context *ac,
+			enum migrate_mode mode, int *contended);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order,
@@ -101,10 +100,9 @@ static inline bool compaction_restarting(struct zone *zone, int order)
 }
 
 #else
-static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
-			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, int *contended,
-			int alloc_flags, int classzone_idx)
+static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
+			int alloc_flags, const struct alloc_context *ac,
+			enum migrate_mode mode, int *contended)
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 38cf1d6..5ecfb00 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -295,6 +295,17 @@ static inline int get_freepage_migratetype(struct page *page)
 	return page->index;
 }
 
+struct alloc_context {
+	struct zonelist *zonelist;
+	nodemask_t *nodemask;
+	struct zone *preferred_zone;
+
+	unsigned int order;
+	int classzone_idx;
+	int migratetype;
+	enum zone_type high_zoneidx;
+};
+
 /*
  * FIXME: take this include out, include page-flags.h in
  * files which need it (119 of them)
diff --git a/mm/compaction.c b/mm/compaction.c
index 546e571..adb699d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1345,11 +1345,11 @@ int sysctl_extfrag_threshold = 500;
  *
  * This is the main entry point for direct page compaction.
  */
-unsigned long try_to_compact_pages(struct zonelist *zonelist,
-			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, int *contended,
-			int alloc_flags, int classzone_idx)
+unsigned long try_to_compact_pages(gfp_t gfp_mask, int alloc_flags,
+			const struct alloc_context *ac,
+			enum migrate_mode mode, int *contended)
 {
+	const unsigned long order = ac->order;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
@@ -1365,8 +1365,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		return COMPACT_SKIPPED;
 
 	/* Compact each zone in the list */
-	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
-								nodemask) {
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, high_zoneidx,
+								ac->nodemask) {
 		int status;
 		int zone_contended;
 
@@ -1374,7 +1374,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			continue;
 
 		status = compact_zone_order(zone, order, gfp_mask, mode,
-				&zone_contended, alloc_flags, classzone_idx);
+				&zone_contended, alloc_flags, ac->classzone_idx);
 		rc = max(status, rc);
 		/*
 		 * It takes at least one zone that wasn't lock contended
@@ -1384,7 +1384,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
-					classzone_idx, alloc_flags)) {
+					ac->classzone_idx, alloc_flags)) {
 			/*
 			 * We think the allocation will succeed in this zone,
 			 * but it is not certain, hence the false. The caller
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1ee3ee1..3dc45d5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -232,17 +232,6 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
-struct alloc_context {
-	struct zonelist *zonelist;
-	nodemask_t *nodemask;
-	struct zone *preferred_zone;
-
-	unsigned int order;
-	int classzone_idx;
-	int migratetype;
-	enum zone_type high_zoneidx;
-};
-
 int page_group_by_mobility_disabled __read_mostly;
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
@@ -2389,18 +2378,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, int alloc_flags,
 	const struct alloc_context *ac, enum migrate_mode mode,
 	int *contended_compaction, bool *deferred_compaction)
 {
-	const unsigned int order = ac->order;
 	unsigned long compact_result;
 	struct page *page;
 
-	if (!order)
+	if (!ac->order)
 		return NULL;
 
 	current->flags |= PF_MEMALLOC;
-	compact_result = try_to_compact_pages(ac->zonelist, order, gfp_mask,
-						ac->nodemask, mode,
-						contended_compaction,
-						alloc_flags, ac->classzone_idx);
+	compact_result = try_to_compact_pages(gfp_mask, alloc_flags, ac, mode,
+						contended_compaction);
 	current->flags &= ~PF_MEMALLOC;
 
 	switch (compact_result) {
@@ -2426,7 +2412,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, int alloc_flags,
 		struct zone *zone = page_zone(page);
 
 		zone->compact_blockskip_flush = false;
-		compaction_defer_reset(zone, order, true);
+		compaction_defer_reset(zone, ac->order, true);
 		count_vm_event(COMPACTSUCCESS);
 		return page;
 	}
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
