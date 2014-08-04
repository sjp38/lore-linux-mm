Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA3C6B0038
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 04:56:07 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so4600590wib.14
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 01:56:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ew14si32336858wjc.44.2014.08.04.01.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 01:56:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 10/13] mm, compaction: remember position within pageblock in free pages scanner
Date: Mon,  4 Aug 2014 10:55:21 +0200
Message-Id: <1407142524-2025-11-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

Unlike the migration scanner, the free scanner remembers the beginning of the
last scanned pageblock in cc->free_pfn. It might be therefore rescanning pages
uselessly when called several times during single compaction. This might have
been useful when pages were returned to the buddy allocator after a failed
migration, but this is no longer the case.

This patch changes the meaning of cc->free_pfn so that if it points to a
middle of a pageblock, that pageblock is scanned only from cc->free_pfn to the
end. isolate_freepages_block() will record the pfn of the last page it looked
at, which is then used to update cc->free_pfn.

In the mmtests stress-highalloc benchmark, this has resulted in lowering the
ratio between pages scanned by both scanners, from 2.5 free pages per migrate
page, to 2.25 free pages per migrate page, without affecting success rates.

With __GFP_NO_KSWAPD allocations, this appears to result in a worse ratio (2.1
instead of 1.8), but page migration successes increased by 10%, so this could
mean that more useful work can be done until need_resched() aborts this kind
of compaction.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/compaction.c | 39 ++++++++++++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 98e687b..817f3aa 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -330,7 +330,7 @@ static bool suitable_migration_target(struct page *page)
  * (even though it may still end up isolating some pages).
  */
 static unsigned long isolate_freepages_block(struct compact_control *cc,
-				unsigned long blockpfn,
+				unsigned long *start_pfn,
 				unsigned long end_pfn,
 				struct list_head *freelist,
 				bool strict)
@@ -339,6 +339,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	struct page *cursor, *valid_page = NULL;
 	unsigned long flags;
 	bool locked = false;
+	unsigned long blockpfn = *start_pfn;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -412,6 +413,9 @@ isolate_fail:
 			break;
 	}
 
+	/* Record how far we have got within the block */
+	*start_pfn = blockpfn;
+
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
 
 	/*
@@ -460,14 +464,16 @@ isolate_freepages_range(struct compact_control *cc,
 
 	for (; pfn < end_pfn; pfn += isolated,
 				block_end_pfn += pageblock_nr_pages) {
+		/* Protect pfn from changing by isolate_freepages_block */
+		unsigned long isolate_start_pfn = pfn;
 
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
 		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
 			break;
 
-		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
-						   &freelist, true);
+		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+						block_end_pfn, &freelist, true);
 
 		/*
 		 * In strict mode, isolate_freepages_block() returns 0 if
@@ -770,6 +776,7 @@ static void isolate_freepages(struct compact_control *cc)
 	struct zone *zone = cc->zone;
 	struct page *page;
 	unsigned long block_start_pfn;	/* start of current pageblock */
+	unsigned long isolate_start_pfn; /* exact pfn we start at */
 	unsigned long block_end_pfn;	/* end of current pageblock */
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
 	int nr_freepages = cc->nr_freepages;
@@ -778,14 +785,15 @@ static void isolate_freepages(struct compact_control *cc)
 	/*
 	 * Initialise the free scanner. The starting point is where we last
 	 * successfully isolated from, zone-cached value, or the end of the
-	 * zone when isolating for the first time. We need this aligned to
-	 * the pageblock boundary, because we do
+	 * zone when isolating for the first time. For looping we also need
+	 * this pfn aligned down to the pageblock boundary, because we do
 	 * block_start_pfn -= pageblock_nr_pages in the for loop.
 	 * For ending point, take care when isolating in last pageblock of a
 	 * a zone which ends in the middle of a pageblock.
 	 * The low boundary is the end of the pageblock the migration scanner
 	 * is using.
 	 */
+	isolate_start_pfn = cc->free_pfn;
 	block_start_pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
@@ -798,7 +806,8 @@ static void isolate_freepages(struct compact_control *cc)
 	 */
 	for (; block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
 				block_end_pfn = block_start_pfn,
-				block_start_pfn -= pageblock_nr_pages) {
+				block_start_pfn -= pageblock_nr_pages,
+				isolate_start_pfn = block_start_pfn) {
 		unsigned long isolated;
 
 		/*
@@ -823,13 +832,25 @@ static void isolate_freepages(struct compact_control *cc)
 		if (!isolation_suitable(cc, page))
 			continue;
 
-		/* Found a block suitable for isolating free pages from */
-		cc->free_pfn = block_start_pfn;
-		isolated = isolate_freepages_block(cc, block_start_pfn,
+		/* Found a block suitable for isolating free pages from. */
+		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
 					block_end_pfn, freelist, false);
 		nr_freepages += isolated;
 
 		/*
+		 * Remember where the free scanner should restart next time,
+		 * which is where isolate_freepages_block() left off.
+		 * But if it scanned the whole pageblock, isolate_start_pfn
+		 * now points at block_end_pfn, which is the start of the next
+		 * pageblock.
+		 * In that case we will however want to restart at the start
+		 * of the previous pageblock.
+		 */
+		cc->free_pfn = (isolate_start_pfn < block_end_pfn) ?
+				isolate_start_pfn :
+				block_start_pfn - pageblock_nr_pages;
+
+		/*
 		 * Set a flag that we successfully isolated in this pageblock.
 		 * In the next loop iteration, zone->compact_cached_free_pfn
 		 * will not be updated and thus it will effectively contain the
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
