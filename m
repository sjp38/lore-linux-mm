Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 988136B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:19:54 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so5191481pad.3
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:19:54 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id v1si24991425pdb.148.2015.08.23.19.19.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:19:53 -0700 (PDT)
Received: by padfo6 with SMTP id fo6so5191286pad.3
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:19:53 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 1/9] mm/compaction: skip useless pfn when updating cached pfn
Date: Mon, 24 Aug 2015 11:19:25 +0900
Message-Id: <1440382773-16070-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Cached pfn is used to determine the start position of scanner
at next compaction run. Current cached pfn points the skipped pageblock
so we uselessly checks whether pageblock is valid for compaction and
skip-bit is set or not. If we set scanner's cached pfn to next pfn of
skipped pageblock, we don't need to do this check.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6ef2fdf..c2d3d6a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,10 +261,9 @@ void reset_isolation_suitable(pg_data_t *pgdat)
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
@@ -277,8 +276,6 @@ static void update_pageblock_skip(struct compact_control *cc,
 
 	set_pageblock_skip(page);
 
-	pfn = page_to_pfn(page);
-
 	/* Update where async and sync compaction should restart */
 	if (migrate_scanner) {
 		if (pfn > zone->compact_cached_migrate_pfn[0])
@@ -300,7 +297,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
 
 static void update_pageblock_skip(struct compact_control *cc,
 			struct page *page, unsigned long nr_isolated,
-			bool migrate_scanner)
+			unsigned long pfn, bool migrate_scanner)
 {
 }
 #endif /* CONFIG_COMPACTION */
@@ -509,7 +506,8 @@ isolate_fail:
 
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, total_isolated, false);
+		update_pageblock_skip(cc, valid_page, total_isolated,
+					end_pfn, false);
 
 	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
 	if (total_isolated)
@@ -811,7 +809,8 @@ isolate_success:
 	 * if the whole pageblock was scanned without isolating any page.
 	 */
 	if (low_pfn == end_pfn)
-		update_pageblock_skip(cc, valid_page, nr_isolated, true);
+		update_pageblock_skip(cc, valid_page, nr_isolated,
+					end_pfn, true);
 
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
