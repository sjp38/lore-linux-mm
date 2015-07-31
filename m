Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9FD6B0258
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:28:28 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so36769523wib.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:28:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pl7si6026029wic.103.2015.07.31.08.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 08:28:25 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/5] mm, compaction: simplify handling restart position in free pages scanner
Date: Fri, 31 Jul 2015 17:28:04 +0200
Message-Id: <1438356487-7082-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
References: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>

Handling the position where compaction free scanner should restart (stored in
cc->free_pfn) got more complex with commit e14c720efdd7 ("mm, compaction:
remember position within pageblock in free pages scanner"). Currently the
position is updated in each loop iteration of isolate_freepages(), although it
should be enough to update it only when breaking from the loop. There's also
an extra check outside the loop updates the position in case we have met the
migration scanner.

This can be simplified if we move the test for having isolated enough from the
for-loop header next to the test for contention, and determining the restart
position only in these cases. We can reuse the isolate_start_pfn variable for
this instead of setting cc->free_pfn directly. Outside the loop, we can simply
set cc->free_pfn to current value of isolate_start_pfn without any extra check.

Also add a VM_BUG_ON to catch possible mistake in the future, in case we later
add a new condition that terminates isolate_freepages_block() prematurely
without also considering the condition in isolate_freepages().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index d46aaeb..7e0a814 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -947,8 +947,7 @@ static void isolate_freepages(struct compact_control *cc)
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
 	 */
-	for (; block_start_pfn >= low_pfn &&
-			cc->nr_migratepages > cc->nr_freepages;
+	for (; block_start_pfn >= low_pfn;
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
@@ -980,6 +979,8 @@ static void isolate_freepages(struct compact_control *cc)
 					block_end_pfn, freelist, false);
 
 		/*
+		 * If we isolated enough freepages, or aborted due to async
+		 * compaction being contended, terminate the loop.
 		 * Remember where the free scanner should restart next time,
 		 * which is where isolate_freepages_block() left off.
 		 * But if it scanned the whole pageblock, isolate_start_pfn
@@ -988,27 +989,31 @@ static void isolate_freepages(struct compact_control *cc)
 		 * In that case we will however want to restart at the start
 		 * of the previous pageblock.
 		 */
-		cc->free_pfn = (isolate_start_pfn < block_end_pfn) ?
-				isolate_start_pfn :
-				block_start_pfn - pageblock_nr_pages;
-
-		/*
-		 * isolate_freepages_block() might have aborted due to async
-		 * compaction being contended
-		 */
-		if (cc->contended)
+		if ((cc->nr_freepages >= cc->nr_migratepages)
+							|| cc->contended) {
+			if (isolate_start_pfn >= block_end_pfn)
+				isolate_start_pfn =
+					block_start_pfn - pageblock_nr_pages;
 			break;
+		} else {
+			/*
+			 * isolate_freepages_block() should not terminate
+			 * prematurely unless contended, or isolated enough
+			 */
+			VM_BUG_ON(isolate_start_pfn < block_end_pfn);
+		}
 	}
 
 	/* split_free_page does not map the pages */
 	map_pages(freelist);
 
 	/*
-	 * If we crossed the migrate scanner, we want to keep it that way
-	 * so that compact_finished() may detect this
+	 * Record where the free scanner will restart next time. Either we
+	 * broke from the loop and set isolate_start_pfn based on the last
+	 * call to isolate_freepages_block(), or we met the migration scanner
+	 * and the loop terminated due to isolate_start_pfn < low_pfn
 	 */
-	if (block_start_pfn < low_pfn)
-		cc->free_pfn = cc->migrate_pfn;
+	cc->free_pfn = isolate_start_pfn;
 }
 
 /*
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
