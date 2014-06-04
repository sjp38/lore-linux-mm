Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D93076B0035
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 12:12:28 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id m15so8575095wgh.4
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 09:12:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si5642590wjf.134.2014.06.04.09.12.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 09:12:26 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 3/6] mm, compaction: remember position within pageblock in free pages scanner
Date: Wed,  4 Jun 2014 18:11:47 +0200
Message-Id: <1401898310-14525-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1401898310-14525-1-git-send-email-vbabka@suse.cz>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com>
 <1401898310-14525-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

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
 mm/compaction.c | 33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 27c73d7..ae7db5f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -294,7 +294,7 @@ static bool suitable_migration_target(struct page *page)
  * (even though it may still end up isolating some pages).
  */
 static unsigned long isolate_freepages_block(struct compact_control *cc,
-				unsigned long blockpfn,
+				unsigned long *start_pfn,
 				unsigned long end_pfn,
 				struct list_head *freelist,
 				bool strict)
@@ -304,6 +304,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	unsigned long flags;
 	bool locked = false;
 	bool checked_pageblock = false;
+	unsigned long blockpfn = *start_pfn;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -312,6 +313,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		int isolated, i;
 		struct page *page = cursor;
 
+		/* Record how far we have got within the block */
+		*start_pfn = blockpfn;
+
 		/*
 		 * Periodically drop the lock (if held) regardless of its
 		 * contention, to give chance to IRQs. Abort async compaction
@@ -438,6 +442,9 @@ isolate_freepages_range(struct compact_control *cc,
 	LIST_HEAD(freelist);
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
+		/* Protect pfn from changing by isolate_freepages_block */
+		unsigned long isolate_start_pfn = pfn;
+
 		if (!pfn_valid(pfn) || cc->zone != page_zone(pfn_to_page(pfn)))
 			break;
 
@@ -448,8 +455,8 @@ isolate_freepages_range(struct compact_control *cc,
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
-						   &freelist, true);
+		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+						block_end_pfn, &freelist, true);
 
 		/*
 		 * In strict mode, isolate_freepages_block() returns 0 if
@@ -789,6 +796,7 @@ static void isolate_freepages(struct zone *zone,
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
+		unsigned long isolate_start_pfn;
 
 		/*
 		 * This can iterate a massively long zone without finding any
@@ -822,11 +830,26 @@ static void isolate_freepages(struct zone *zone,
 			continue;
 
 		/* Found a block suitable for isolating free pages from */
-		cc->free_pfn = block_start_pfn;
-		isolated = isolate_freepages_block(cc, block_start_pfn,
+		isolate_start_pfn = block_start_pfn;
+
+		/* 
+		 * If we are restarting the free scanner in this block, do not
+		 * rescan the beginning of the block
+		 */
+		if (cc->free_pfn < block_end_pfn)
+			isolate_start_pfn = cc->free_pfn;
+
+		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
 					block_end_pfn, freelist, false);
 		nr_freepages += isolated;
 
+		/* 
+		 * Remember where the free scanner should restart next time.
+		 * This will point to the last page of pageblock we just
+		 * scanned, if we scanned it fully.
+		 */
+		cc->free_pfn = isolate_start_pfn;
+
 		/*
 		 * Set a flag that we successfully isolated in this pageblock.
 		 * In the next loop iteration, zone->compact_cached_free_pfn
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
