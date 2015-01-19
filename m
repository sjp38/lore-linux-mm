Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD116B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 05:05:45 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id b13so2383234wgh.9
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 02:05:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si20192186wiy.81.2015.01.19.02.05.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 02:05:41 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/5] mm, compaction: simplify handling restart position in free pages scanner
Date: Mon, 19 Jan 2015 11:05:17 +0100
Message-Id: <1421661920-4114-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Handling the position where compaction free scanner should restart (stored in
cc->free_pfn) got more complex with commit e14c720efdd7 ("mm, compaction:
remember position within pageblock in free pages scanner"). Currently the
position is updated in each loop iteration isolate_freepages(), although it's
enough to update it only when exiting the loop when we have found enough free
pages, or detected contention in async compaction. Then an extra check outside
the loop updates the position in case we have met the migration scanner.

This can be simplified if we move the test for having isolated enough from
for loop header next to the test for contention, and determining the restart
position only in these cases. We can reuse the isolate_start_pfn variable for
this instead of setting cc->free_pfn directly. Outside the loop, we can simply
set cc->free_pfn to value of isolate_start_pfn without extra check.

We also add VM_BUG_ON to future-proof the code, in case somebody adds a new
condition that terminates isolate_freepages_block() prematurely, which
wouldn't be also considered in isolate_freepages().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 5fdbdb8..45799a4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -849,7 +849,7 @@ static void isolate_freepages(struct compact_control *cc)
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
 	 */
-	for (; block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
+	for (; block_start_pfn >= low_pfn;
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
@@ -883,6 +883,8 @@ static void isolate_freepages(struct compact_control *cc)
 		nr_freepages += isolated;
 
 		/*
+		 * If we isolated enough freepages, or aborted due to async
+		 * compaction being contended, terminate the loop.
 		 * Remember where the free scanner should restart next time,
 		 * which is where isolate_freepages_block() left off.
 		 * But if it scanned the whole pageblock, isolate_start_pfn
@@ -891,28 +893,30 @@ static void isolate_freepages(struct compact_control *cc)
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
+		if ((nr_freepages > cc->nr_migratepages) || cc->contended) {
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
-
+	cc->free_pfn = isolate_start_pfn;
 	cc->nr_freepages = nr_freepages;
 }
 
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
