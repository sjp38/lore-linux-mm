Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCFB6B0260
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:05:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w72so4195122wmf.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 14:05:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l130si722231wmf.77.2016.09.29.14.05.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 14:05:57 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/4] mm, compaction: add migratetype to compact_control
Date: Thu, 29 Sep 2016 23:05:46 +0200
Message-Id: <20160929210548.26196-3-vbabka@suse.cz>
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Preparation patch. We are going to need migratetype at lower layers than
compact_zone() and compact_finished().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 15 +++++++--------
 mm/internal.h   |  1 +
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 673a81618534..823538353b80 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1290,11 +1290,12 @@ static inline bool is_via_compact_memory(int order)
 	return order == -1;
 }
 
-static enum compact_result __compact_finished(struct zone *zone, struct compact_control *cc,
-			    const int migratetype)
+static enum compact_result __compact_finished(struct zone *zone,
+						struct compact_control *cc)
 {
 	unsigned int order;
 	unsigned long watermark;
+	const int migratetype = cc->migratetype;
 
 	if (cc->contended || fatal_signal_pending(current))
 		return COMPACT_CONTENDED;
@@ -1357,12 +1358,11 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
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
@@ -1497,9 +1497,9 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	enum compact_result ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
-	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
+	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
 	/* Compaction is likely to fail */
@@ -1549,8 +1549,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	migrate_prep_local();
 
-	while ((ret = compact_finished(zone, cc, migratetype)) ==
-						COMPACT_CONTINUE) {
+	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		int err;
 
 		switch (isolate_migratepages(zone, cc)) {
diff --git a/mm/internal.h b/mm/internal.h
index 537ac9951f5f..1fee63010dcc 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -182,6 +182,7 @@ struct compact_control {
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
 	int order;			/* order a direct compactor needs */
+	int migratetype;		/* migratetype of direct compactor */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
 	const int classzone_idx;	/* zone index of a direct compactor */
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
