Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60BED6B025F
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p190so905170wmd.0
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si1511149edj.440.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 1/8] mm, compaction: don't mark pageblocks unsuitable when not fully scanned
Date: Wed, 13 Dec 2017 09:59:08 +0100
Message-Id: <20171213085915.9278-2-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Compaction migration scanner marks a pageblock as unsuitable (via pageblock
skip bit) if it fails to isolate any pages in them. When scanning for async
direct compaction, it skips all pages of a order-aligned block once a page
fails isolation, because a single page is enough to prevent forming a free page
of given order. But the skipped pages might still be migratable and form a free
page of a lower order. Therefore we should not mark pageblock unsuitable, if
skipping has happened. The worst example would be a THP allocation attempt
marking pageblock unsuitable due to a single page, so the following lower-order
and more critical allocation will skip the pageblock.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b8c23882c8ae..ce73badad464 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -698,7 +698,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 	unsigned long start_pfn = low_pfn;
-	bool skip_on_failure = false;
+	bool skip_on_failure = false, skipped_pages = false;
 	unsigned long next_skip_pfn = 0;
 
 	/*
@@ -920,13 +920,14 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			nr_isolated = 0;
 		}
 
-		if (low_pfn < next_skip_pfn) {
+		if (low_pfn < next_skip_pfn - 1) {
 			low_pfn = next_skip_pfn - 1;
 			/*
 			 * The check near the loop beginning would have updated
 			 * next_skip_pfn too, but this is a bit simpler.
 			 */
 			next_skip_pfn += 1UL << cc->order;
+			skipped_pages = true;
 		}
 	}
 
@@ -944,7 +945,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	 * Update the pageblock-skip information and cached scanner pfn,
 	 * if the whole pageblock was scanned without isolating any page.
 	 */
-	if (low_pfn == end_pfn)
+	if (low_pfn == end_pfn && !skipped_pages)
 		update_pageblock_skip(cc, valid_page, nr_isolated, true);
 
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
