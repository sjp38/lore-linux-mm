Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE4C6B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 05:18:56 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so7522851eek.1
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 02:18:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si24641015eew.108.2014.04.15.02.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 02:18:54 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/2] mm/compaction: make isolate_freepages start at pageblock boundary
Date: Tue, 15 Apr 2014 11:18:26 +0200
Message-Id: <1397553507-15330-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <5342BA34.8050006@suse.cz>
References: <5342BA34.8050006@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

The compaction freepage scanner implementation in isolate_freepages() starts
by taking the current cc->free_pfn value as the first pfn. In a for loop, it
scans from this first pfn to the end of the pageblock, and then subtracts
pageblock_nr_pages from the first pfn to obtain the first pfn for the next
for loop iteration.

This means that when cc->free_pfn starts at offset X rather than being aligned
on pageblock boundary, the scanner will start at offset X in all scanned
pageblock, ignoring potentially many free pages. Currently this can happen when
a) zone's end pfn is not pageblock aligned, or
b) through zone->compact_cached_free_pfn with CONFIG_HOLES_IN_ZONE enabled and
   a hole spanning the beginning of a pageblock

This patch fixes the problem by aligning the initial pfn in isolate_freepages()
to pageblock boundary. This also allows to replace the end-of-pageblock
alignment within the for loop with a simple pageblock_nr_pages increment.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Heesub Shin <heesub.shin@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 37f9762..627dc2e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -671,16 +671,20 @@ static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn, z_end_pfn, end_pfn;
+	unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
 	/*
 	 * Initialise the free scanner. The starting point is where we last
-	 * scanned from (or the end of the zone if starting). The low point
-	 * is the end of the pageblock the migration scanner is using.
+	 * successfully isolated from, zone-cached value, or the end of the
+	 * zone when isolating for the first time. We need this aligned to
+	 * the pageblock boundary, because we do pfn -= pageblock_nr_pages
+	 * in the for loop.
+	 * The low boundary is the end of the pageblock the migration scanner
+	 * is using.
 	 */
-	pfn = cc->free_pfn;
+	pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
 	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
 
 	/*
@@ -700,6 +704,7 @@ static void isolate_freepages(struct zone *zone,
 	for (; pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
+		unsigned long end_pfn;
 
 		/*
 		 * This can iterate a massively long zone without finding any
@@ -734,13 +739,10 @@ static void isolate_freepages(struct zone *zone,
 		isolated = 0;
 
 		/*
-		 * As pfn may not start aligned, pfn+pageblock_nr_page
-		 * may cross a MAX_ORDER_NR_PAGES boundary and miss
-		 * a pfn_valid check. Ensure isolate_freepages_block()
-		 * only scans within a pageblock
+		 * Take care when isolating in last pageblock of a zone which
+		 * ends in the middle of a pageblock.
 		 */
-		end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
-		end_pfn = min(end_pfn, z_end_pfn);
+		end_pfn = min(pfn + pageblock_nr_pages, z_end_pfn);
 		isolated = isolate_freepages_block(cc, pfn, end_pfn,
 						   freelist, false);
 		nr_freepages += isolated;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
