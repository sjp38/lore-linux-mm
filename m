Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id EDE6C6B0038
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:42:55 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so41238790pdj.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:42:55 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id tp10si42246173pab.201.2015.06.24.17.42.53
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:54 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 01/10] mm/compaction: update skip-bit if whole pageblock is really scanned
Date: Thu, 25 Jun 2015 09:45:12 +0900
Message-Id: <1435193121-25880-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Scanning pageblock is stopped at the middle of pageblock if enough
pages are isolated. In the next run, it begins again at this position
and if it find that there is no isolation candidate from the middle of
pageblock to end of pageblock, it updates skip-bit. In this case,
scanner doesn't start at begin of pageblock so it is not appropriate
to set skipbit. This patch fixes this situation that updating skip-bit
only happens when whole pageblock is really scanned.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6ef2fdf..4397bf7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,7 +261,8 @@ void reset_isolation_suitable(pg_data_t *pgdat)
  */
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			unsigned long start_pfn, unsigned long end_pfn,
+			unsigned long curr_pfn, bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
 	unsigned long pfn;
@@ -275,6 +276,13 @@ static void update_pageblock_skip(struct compact_control *cc,
 	if (nr_isolated)
 		return;
 
+	/* Update the pageblock-skip if the whole pageblock was scanned */
+	if (curr_pfn != end_pfn)
+		return;
+
+	if (start_pfn != round_down(end_pfn - 1, pageblock_nr_pages))
+		return;
+
 	set_pageblock_skip(page);
 
 	pfn = page_to_pfn(page);
@@ -300,7 +308,8 @@ static inline bool isolation_suitable(struct compact_control *cc,
 
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			unsigned long start_pfn, unsigned long end_pfn,
+			unsigned long curr_pfn, bool migrate_scanner)
 {
 }
 #endif /* CONFIG_COMPACTION */
@@ -493,9 +502,6 @@ isolate_fail:
 	trace_mm_compaction_isolate_freepages(*start_pfn, blockpfn,
 					nr_scanned, total_isolated);
 
-	/* Record how far we have got within the block */
-	*start_pfn = blockpfn;
-
 	/*
 	 * If strict isolation is requested by CMA then check that all the
 	 * pages requested were isolated. If there were any failures, 0 is
@@ -507,9 +513,11 @@ isolate_fail:
 	if (locked)
 		spin_unlock_irqrestore(&cc->zone->lock, flags);
 
-	/* Update the pageblock-skip if the whole pageblock was scanned */
-	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, false);
+	update_pageblock_skip(cc, valid_page, total_isolated,
+			*start_pfn, end_pfn, blockpfn, false);
+
+	/* Record how far we have got within the block */
+	*start_pfn = blockpfn;
 
 	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
 	if (total_isolated)
@@ -806,12 +814,8 @@ isolate_success:
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-	/*
-	 * Update the pageblock-skip information and cached scanner pfn,
-	 * if the whole pageblock was scanned without isolating any page.
-	 */
-	if (low_pfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, nr_isolated, true);
+	update_pageblock_skip(cc, valid_page, nr_isolated,
+			start_pfn, end_pfn, low_pfn, true);
 
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
