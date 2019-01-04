Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7DC28E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:50:54 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so35039164edc.6
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:50:54 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id s34si4249719edb.417.2019.01.04.04.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:50:53 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id CD9D81C1D6B
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:50:52 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 03/25] mm, compaction: Remove last_migrated_pfn from compact_control
Date: Fri,  4 Jan 2019 12:49:49 +0000
Message-Id: <20190104125011.16071-4-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The last_migrated_pfn field is a bit dubious as to whether it really helps
but either way, the information from it can be inferred without increasing
the size of compact_control so remove the field.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 25 +++++++++----------------
 mm/internal.h   |  1 -
 2 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ef29490b0f46..fb4d9f52ed56 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -886,15 +886,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		cc->nr_migratepages++;
 		nr_isolated++;
 
-		/*
-		 * Record where we could have freed pages by migration and not
-		 * yet flushed them to buddy allocator.
-		 * - this is the lowest page that was isolated and likely be
-		 * then freed by migration.
-		 */
-		if (!cc->last_migrated_pfn)
-			cc->last_migrated_pfn = low_pfn;
-
 		/* Avoid isolating too much */
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
 			++low_pfn;
@@ -918,7 +909,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			}
 			putback_movable_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
-			cc->last_migrated_pfn = 0;
 			nr_isolated = 0;
 		}
 
@@ -1539,6 +1529,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	enum compact_result ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
+	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
@@ -1584,7 +1575,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 			cc->whole_zone = true;
 	}
 
-	cc->last_migrated_pfn = 0;
+	last_migrated_pfn = 0;
 
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync);
@@ -1593,12 +1584,14 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		int err;
+		unsigned long start_pfn = cc->migrate_pfn;
 
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_CONTENDED;
 			putback_movable_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
+			last_migrated_pfn = 0;
 			goto out;
 		case ISOLATE_NONE:
 			/*
@@ -1608,6 +1601,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 			 */
 			goto check_drain;
 		case ISOLATE_SUCCESS:
+			last_migrated_pfn = start_pfn;
 			;
 		}
 
@@ -1639,8 +1633,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 				cc->migrate_pfn = block_end_pfn(
 						cc->migrate_pfn - 1, cc->order);
 				/* Draining pcplists is useless in this case */
-				cc->last_migrated_pfn = 0;
-
+				last_migrated_pfn = 0;
 			}
 		}
 
@@ -1652,18 +1645,18 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 		 * compact_finished() can detect immediately if allocation
 		 * would succeed.
 		 */
-		if (cc->order > 0 && cc->last_migrated_pfn) {
+		if (cc->order > 0 && last_migrated_pfn) {
 			int cpu;
 			unsigned long current_block_start =
 				block_start_pfn(cc->migrate_pfn, cc->order);
 
-			if (cc->last_migrated_pfn < current_block_start) {
+			if (last_migrated_pfn < current_block_start) {
 				cpu = get_cpu();
 				lru_add_drain_cpu(cpu);
 				drain_local_pages(zone);
 				put_cpu();
 				/* No more flushing until we migrate again */
-				cc->last_migrated_pfn = 0;
+				last_migrated_pfn = 0;
 			}
 		}
 
diff --git a/mm/internal.h b/mm/internal.h
index 9437ba5791db..c6f794ad21a9 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -187,7 +187,6 @@ struct compact_control {
 	unsigned int nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
 	struct zone *zone;
 	unsigned long total_migrate_scanned;
 	unsigned long total_free_scanned;
-- 
2.16.4
