Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 11E7A6B0256
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:39 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so63037843pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:38 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id rr7si10168189pab.62.2015.12.02.23.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:38 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so63037664pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:38 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 1/7] mm/compaction: skip useless pfn when updating cached pfn
Date: Thu,  3 Dec 2015 16:11:15 +0900
Message-Id: <1449126681-19647-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Cached pfn is used to determine the start position of scanner
at next compaction run. Current cached pfn points the skipped pageblock
so we uselessly checks whether pageblock is valid for compaction and
skip-bit is set or not. If we set scanner's cached pfn to next pfn of
skipped pageblock, we don't need to do this check.

This patch moved update_pageblock_skip() to
isolate_(freepages|migratepages). Updating pageblock skip information
isn't relevant to CMA so they are more appropriate place
to update this information.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 37 ++++++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 17 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 01b1e5e..564047c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -256,10 +256,9 @@ void reset_isolation_suitable(pg_data_t *pgdat)
  */
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			unsigned long pfn, bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
-	unsigned long pfn;
 
 	if (cc->ignore_skip_hint)
 		return;
@@ -272,8 +271,6 @@ static void update_pageblock_skip(struct compact_control *cc,
 
 	set_pageblock_skip(page);
 
-	pfn = page_to_pfn(page);
-
 	/* Update where async and sync compaction should restart */
 	if (migrate_scanner) {
 		if (pfn > zone->compact_cached_migrate_pfn[0])
@@ -295,7 +292,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
 
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			unsigned long pfn, bool migrate_scanner)
 {
 }
 #endif /* CONFIG_COMPACTION */
@@ -527,10 +524,6 @@ isolate_fail:
 	if (locked)
 		spin_unlock_irqrestore(&cc->zone->lock, flags);
 
-	/* Update the pageblock-skip if the whole pageblock was scanned */
-	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, false);
-
 	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
 	if (total_isolated)
 		count_compact_events(COMPACTISOLATED, total_isolated);
@@ -832,13 +825,6 @@ isolate_success:
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-	/*
-	 * Update the pageblock-skip information and cached scanner pfn,
-	 * if the whole pageblock was scanned without isolating any page.
-	 */
-	if (low_pfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, nr_isolated, true);
-
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
 
@@ -947,6 +933,7 @@ static void isolate_freepages(struct compact_control *cc)
 	unsigned long block_end_pfn;	/* end of current pageblock */
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
 	struct list_head *freelist = &cc->freepages;
+	unsigned long nr_isolated;
 
 	/*
 	 * Initialise the free scanner. The starting point is where we last
@@ -998,10 +985,18 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
-		isolate_freepages_block(cc, &isolate_start_pfn,
+		nr_isolated = isolate_freepages_block(cc, &isolate_start_pfn,
 					block_end_pfn, freelist, false);
 
 		/*
+		 * Update the pageblock-skip if the whole pageblock
+		 * was scanned
+		 */
+		if (isolate_start_pfn == block_end_pfn)
+			update_pageblock_skip(cc, page, nr_isolated,
+				block_start_pfn - pageblock_nr_pages, false);
+
+		/*
 		 * If we isolated enough freepages, or aborted due to async
 		 * compaction being contended, terminate the loop.
 		 * Remember where the free scanner should restart next time,
@@ -1172,6 +1167,14 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			cc->last_migrated_pfn = isolate_start_pfn;
 
 		/*
+		 * Update the pageblock-skip if the whole pageblock
+		 * was scanned without isolating any page.
+		 */
+		if (low_pfn == end_pfn)
+			update_pageblock_skip(cc, page, cc->nr_migratepages,
+						end_pfn, true);
+
+		/*
 		 * Either we isolated something and proceed with migration. Or
 		 * we failed and compact_zone should decide if we should
 		 * continue or not.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
