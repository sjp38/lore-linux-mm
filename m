Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 140406B0035
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 20:30:01 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id to1so6620681ieb.16
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 17:30:00 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id l10si31087106igu.17.2014.06.03.17.30.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 17:30:00 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id hn18so5662488igb.12
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 17:30:00 -0700 (PDT)
Date: Tue, 3 Jun 2014 17:29:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/3] mm, compaction: pass gfp mask to compact_control
In-Reply-To: <alpine.DEB.2.02.1406031728390.5312@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1406031729260.5312@chino.kir.corp.google.com>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <537DB0E5.40602@suse.cz> <alpine.DEB.2.02.1405220127320.13630@chino.kir.corp.google.com>
 <537DE799.3040400@suse.cz> <alpine.DEB.2.02.1406031728390.5312@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

struct compact_control currently converts the gfp mask to a migratetype, but we 
need the entire gfp mask in a follow-up patch.

Pass the entire gfp mask as part of struct compact_control.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 12 +++++++-----
 mm/internal.h   |  2 +-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -883,8 +883,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return ISOLATE_SUCCESS;
 }
 
-static int compact_finished(struct zone *zone,
-			    struct compact_control *cc)
+static int compact_finished(struct zone *zone, struct compact_control *cc,
+			    const int migratetype)
 {
 	unsigned int order;
 	unsigned long watermark;
@@ -930,7 +930,7 @@ static int compact_finished(struct zone *zone,
 		struct free_area *area = &zone->free_area[order];
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[cc->migratetype]))
+		if (!list_empty(&area->free_list[migratetype]))
 			return COMPACT_PARTIAL;
 
 		/* Job done if allocation would set block type */
@@ -996,6 +996,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	int ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
+	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
 	ret = compaction_suitable(zone, cc->order);
@@ -1038,7 +1039,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	migrate_prep_local();
 
-	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
+	while ((ret = compact_finished(zone, cc, migratetype)) ==
+						COMPACT_CONTINUE) {
 		int err;
 
 		switch (isolate_migratepages(zone, cc)) {
@@ -1096,7 +1098,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
 		.order = order,
-		.migratetype = gfpflags_to_migratetype(gfp_mask),
+		.gfp_mask = gfp_mask,
 		.zone = zone,
 		.mode = mode,
 	};
diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -142,7 +142,7 @@ struct compact_control {
 	bool finished_update_migrate;
 
 	int order;			/* order a direct compactor needs */
-	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
+	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	struct zone *zone;
 	bool contended;			/* True if a lock was contended, or
 					 * need_resched() true during async

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
