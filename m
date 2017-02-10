Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63B236B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:53 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t18so12825373wmt.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z187si1971089wmd.166.2017.02.10.09.23.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:51 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 06/10] mm, compaction: add migratetype to compact_control
Date: Fri, 10 Feb 2017 18:23:39 +0100
Message-Id: <20170210172343.30283-7-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Preparation patch. We are going to need migratetype at lower layers than
compact_zone() and compact_finished().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 15 +++++++--------
 mm/internal.h   |  1 +
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6c477025c3da..b7094700712b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1290,10 +1290,11 @@ static inline bool is_via_compact_memory(int order)
 	return order == -1;
 }
 
-static enum compact_result __compact_finished(struct zone *zone, struct compact_control *cc,
-			    const int migratetype)
+static enum compact_result __compact_finished(struct zone *zone,
+						struct compact_control *cc)
 {
 	unsigned int order;
+	const int migratetype = cc->migratetype;
 
 	if (cc->contended || fatal_signal_pending(current))
 		return COMPACT_CONTENDED;
@@ -1349,12 +1350,11 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 }
 
 static enum compact_result compact_finished(struct zone *zone,
-			struct compact_control *cc,
-			const int migratetype)
+			struct compact_control *cc)
 {
 	int ret;
 
-	ret = __compact_finished(zone, cc, migratetype);
+	ret = __compact_finished(zone, cc);
 	trace_mm_compaction_finished(zone, cc->order, ret);
 	if (ret == COMPACT_NO_SUITABLE_PAGE)
 		ret = COMPACT_CONTINUE;
@@ -1487,9 +1487,9 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	enum compact_result ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
-	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
+	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
 	/* Compaction is likely to fail */
@@ -1539,8 +1539,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	migrate_prep_local();
 
-	while ((ret = compact_finished(zone, cc, migratetype)) ==
-						COMPACT_CONTINUE) {
+	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		int err;
 
 		switch (isolate_migratepages(zone, cc)) {
diff --git a/mm/internal.h b/mm/internal.h
index da37ddd3db40..888f33cc7641 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -179,6 +179,7 @@ struct compact_control {
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
+	int migratetype;		/* migratetype of direct compactor */
 	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
 	const int classzone_idx;	/* zone index of a direct compactor */
 	enum migrate_mode mode;		/* Async or sync migration mode */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
