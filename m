Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05C956B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 21:22:52 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so79363209ith.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 18:22:52 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id a74si43405977pfa.164.2016.06.21.18.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 18:22:51 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id b13so11425523pat.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 18:22:51 -0700 (PDT)
Date: Tue, 21 Jun 2016 18:22:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: abort free scanner if split fails
In-Reply-To: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

If the memory compaction free scanner cannot successfully split a free
page (only possible due to per-zone low watermark), terminate the free 
scanner rather than continuing to scan memory needlessly.  If the 
watermark is insufficient for a free page of order <= cc->order, then 
terminate the scanner since all future splits will also likely fail.

This prevents the compaction freeing scanner from scanning all memory on 
very large zones (very noticeable for zones > 128GB, for instance) when 
all splits will likely fail while holding zone->lock.

Cc: stable@vger.kernel.org
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Based on Linus's tree

 Suggest including in 4.7 if anybody else agrees?

 mm/compaction.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -441,25 +441,23 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
+		if (!isolated)
+			break;
+
 		total_isolated += isolated;
+		cc->nr_freepages += isolated;
 		for (i = 0; i < isolated; i++) {
 			list_add(&page->lru, freelist);
 			page++;
 		}
-
-		/* If a page was split, advance to the end of it */
-		if (isolated) {
-			cc->nr_freepages += isolated;
-			if (!strict &&
-				cc->nr_migratepages <= cc->nr_freepages) {
-				blockpfn += isolated;
-				break;
-			}
-
-			blockpfn += isolated - 1;
-			cursor += isolated - 1;
-			continue;
+		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
+			blockpfn += isolated;
+			break;
 		}
+		/* Advance to the end of split page */
+		blockpfn += isolated - 1;
+		cursor += isolated - 1;
+		continue;
 
 isolate_fail:
 		if (strict)
@@ -469,6 +467,9 @@ isolate_fail:
 
 	}
 
+	if (locked)
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+
 	/*
 	 * There is a tiny chance that we have read bogus compound_order(),
 	 * so be careful to not go outside of the pageblock.
@@ -490,9 +491,6 @@ isolate_fail:
 	if (strict && blockpfn < end_pfn)
 		total_isolated = 0;
 
-	if (locked)
-		spin_unlock_irqrestore(&cc->zone->lock, flags);
-
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
 		update_pageblock_skip(cc, valid_page, total_isolated, false);
@@ -1011,6 +1009,7 @@ static void isolate_freepages(struct compact_control *cc)
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
+		unsigned long isolated;
 
 		/*
 		 * This can iterate a massively long zone without finding any
@@ -1035,8 +1034,12 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
-		isolate_freepages_block(cc, &isolate_start_pfn,
-					block_end_pfn, freelist, false);
+		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+						block_end_pfn, freelist, false);
+		/* If isolation failed early, do not continue needlessly */
+		if (!isolated && isolate_start_pfn < block_end_pfn &&
+		    cc->nr_migratepages > cc->nr_freepages)
+			break;
 
 		/*
 		 * If we isolated enough freepages, or aborted due to async

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
