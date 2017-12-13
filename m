Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCE16B026F
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:07 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 11so931746wrb.18
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e25si1362673edj.108.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 3/8] mm, compaction: pass valid_page to isolate_migratepages_block
Date: Wed, 13 Dec 2017 09:59:10 +0100
Message-Id: <20171213085915.9278-4-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

The valid_page pointer is needed to operate on pageblock bits. The next
patches will need it sooner in isolate_migratepages_block() than currently
estabilished. Since isolate_migratepages() has the pointer already, pass it
down. CMA's isolate_migratepages_range() doesn't, but we will use it only
for compaction so that's ok.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 95b8b5ae59c5..00dc46343093 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -674,6 +674,8 @@ static bool too_many_isolated(struct zone *zone)
  *				  a single pageblock
  * @cc:		Compaction control structure.
  * @low_pfn:	The first PFN to isolate
+ * @valid_page: Page belonging to same pageblock as low_pfn (for pageblock
+ *              flag operations). May be NULL.
  * @end_pfn:	The one-past-the-last PFN to isolate, within same pageblock
  * @isolate_mode: Isolation mode to be used.
  *
@@ -689,14 +691,15 @@ static bool too_many_isolated(struct zone *zone)
  */
 static unsigned long
 isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
-			unsigned long end_pfn, isolate_mode_t isolate_mode)
+		struct page *valid_page, unsigned long end_pfn,
+		isolate_mode_t isolate_mode)
 {
 	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct lruvec *lruvec;
 	unsigned long flags = 0;
 	bool locked = false;
-	struct page *page = NULL, *valid_page = NULL;
+	struct page *page = NULL;
 	unsigned long start_pfn = low_pfn;
 	bool skip_on_failure = false, skipped_pages = false;
 	unsigned long next_skip_pfn = 0;
@@ -992,7 +995,7 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 					block_end_pfn, cc->zone))
 			continue;
 
-		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
+		pfn = isolate_migratepages_block(cc, pfn, NULL, block_end_pfn,
 							ISOLATE_UNEVICTABLE);
 
 		if (!pfn)
@@ -1282,7 +1285,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* Perform the isolation */
-		low_pfn = isolate_migratepages_block(cc, low_pfn,
+		low_pfn = isolate_migratepages_block(cc, low_pfn, page,
 						block_end_pfn, isolate_mode);
 
 		if (!low_pfn || cc->contended)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
