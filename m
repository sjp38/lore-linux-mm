Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3597B6B00A5
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:49:25 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so1371143wiv.7
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:49:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j15si24099303wjn.21.2014.07.16.06.49.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:49:07 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 13/15] mm, compaction: pass gfp mask to compact_control
Date: Wed, 16 Jul 2014 15:48:21 +0200
Message-Id: <1405518503-27687-14-git-send-email-vbabka@suse.cz>
In-Reply-To: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

From: David Rientjes <rientjes@google.com>

struct compact_control currently converts the gfp mask to a migratetype, but we
need the entire gfp mask in a follow-up patch.

Pass the entire gfp mask as part of struct compact_control.

Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 12 +++++++-----
 mm/internal.h   |  2 +-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 523c7bd..279c0b0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1028,8 +1028,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
-static int compact_finished(struct zone *zone,
-			    struct compact_control *cc)
+static int compact_finished(struct zone *zone, struct compact_control *cc,
+			    const int migratetype)
 {
 	unsigned int order;
 	unsigned long watermark;
@@ -1075,7 +1075,7 @@ static int compact_finished(struct zone *zone,
 		struct free_area *area = &zone->free_area[order];
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[cc->migratetype]))
+		if (!list_empty(&area->free_list[migratetype]))
 			return COMPACT_PARTIAL;
 
 		/* Job done if allocation would set block type */
@@ -1141,6 +1141,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	int ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
+	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
 	ret = compaction_suitable(zone, cc->order);
@@ -1183,7 +1184,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	migrate_prep_local();
 
-	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
+	while ((ret = compact_finished(zone, cc, migratetype)) ==
+						COMPACT_CONTINUE) {
 		int err;
 
 		switch (isolate_migratepages(zone, cc)) {
@@ -1238,7 +1240,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
 		.order = order,
-		.migratetype = gfpflags_to_migratetype(gfp_mask),
+		.gfp_mask = gfp_mask,
 		.zone = zone,
 		.mode = mode,
 	};
diff --git a/mm/internal.h b/mm/internal.h
index 86ae964..8293040 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -142,7 +142,7 @@ struct compact_control {
 	bool finished_update_migrate;
 
 	int order;			/* order a direct compactor needs */
-	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
+	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	struct zone *zone;
 	int contended;			/* Signal need_sched() or lock
 					 * contention detected during
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
