Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6145D6B038F
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:16:24 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y90so501379wrb.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:16:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c7si491107wmf.75.2017.03.07.05.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 05:16:23 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 6/8] mm, compaction: add migratetype to compact_control
Date: Tue,  7 Mar 2017 14:15:43 +0100
Message-Id: <20170307131545.28577-7-vbabka@suse.cz>
In-Reply-To: <20170307131545.28577-1-vbabka@suse.cz>
References: <20170307131545.28577-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Preparation patch. We are going to need migratetype at lower layers than
compact_zone() and compact_finished().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/compaction.c | 15 +++++++--------
 mm/internal.h   |  1 +
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a7c2f0da7228..c48da73e30a5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1279,10 +1279,11 @@ static inline bool is_via_compact_memory(int order)
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
@@ -1338,12 +1339,11 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
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
@@ -1476,9 +1476,9 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	enum compact_result ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
-	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
+	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
 	/* Compaction is likely to fail */
@@ -1528,8 +1528,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	migrate_prep_local();
 
-	while ((ret = compact_finished(zone, cc, migratetype)) ==
-						COMPACT_CONTINUE) {
+	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		int err;
 
 		switch (isolate_migratepages(zone, cc)) {
diff --git a/mm/internal.h b/mm/internal.h
index 05c48a95a20a..3985656ac261 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -193,6 +193,7 @@ struct compact_control {
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
+	int migratetype;		/* migratetype of direct compactor */
 	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
 	const int classzone_idx;	/* zone index of a direct compactor */
 	enum migrate_mode mode;		/* Async or sync migration mode */
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
