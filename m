Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id CD9616B0036
	for <linux-mm@kvack.org>; Wed,  7 May 2014 08:09:35 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so662293eek.31
        for <linux-mm@kvack.org>; Wed, 07 May 2014 05:09:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v41si16177236eew.134.2014.05.07.05.09.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 05:09:34 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in isolate_freepages
Date: Wed,  7 May 2014 14:09:10 +0200
Message-Id: <1399464550-26447-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1399464550-26447-1-git-send-email-vbabka@suse.cz>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
 <1399464550-26447-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

The compaction free scanner in isolate_freepages() currently remembers PFN of
the highest pageblock where it successfully isolates, to be used as the
starting pageblock for the next invocation. The rationale behind this is that
page migration might return free pages to the allocator when migration fails
and we don't want to skip them if the compaction continues.

Since migration now returns free pages back to compaction code where they can
be reused, this is no longer a concern. This patch changes isolate_freepages()
so that the PFN for restarting is updated with each pageblock where isolation
is attempted. Using stress-highalloc from mmtests, this resulted in 10%
reduction of the pages scanned by the free scanner.

Note that the somewhat similar functionality that records highest successful
pageblock in zone->compact_cached_free_pfn, remains unchanged. This cache is
used when the whole compaction is restarted, not for multiple invocations of
the free scanner during single compaction.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 v2: no changes, just keep patches together

 mm/compaction.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 383d562..83ca6f9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -706,12 +706,6 @@ static void isolate_freepages(struct zone *zone,
 	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
 
 	/*
-	 * If no pages are isolated, the block_start_pfn < low_pfn check
-	 * will kick in.
-	 */
-	next_free_pfn = 0;
-
-	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
@@ -751,19 +745,19 @@ static void isolate_freepages(struct zone *zone,
 			continue;
 
 		/* Found a block suitable for isolating free pages from */
+		next_free_pfn = block_start_pfn;
 		isolated = isolate_freepages_block(cc, block_start_pfn,
 					block_end_pfn, freelist, false);
 		nr_freepages += isolated;
 
 		/*
-		 * Record the highest PFN we isolated pages from. When next
-		 * looking for free pages, the search will restart here as
-		 * page migration may have returned some pages to the allocator
+		 * Set a flag that we successfully isolated in this pageblock.
+		 * In the next loop iteration, zone->compact_cached_free_pfn
+		 * will not be updated and thus it will effectively contain the
+		 * highest pageblock we isolated pages from.
 		 */
-		if (isolated && next_free_pfn == 0) {
+		if (isolated)
 			cc->finished_update_free = true;
-			next_free_pfn = block_start_pfn;
-		}
 	}
 
 	/* split_free_page does not map the pages */
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
