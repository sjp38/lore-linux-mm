Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6D8B6B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 18:27:24 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 13so3910037itl.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 15:27:24 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id k9si35733318pfj.91.2016.06.20.15.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 15:27:23 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id c2so58223724pfa.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 15:27:23 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:27:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: abort free scanner if split fails
In-Reply-To: <4f5ba93e-8bf0-151e-57eb-cad1a4823b9e@suse.cz>
Message-ID: <alpine.DEB.2.10.1606201443350.33055@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606151530590.37360@chino.kir.corp.google.com> <4f5ba93e-8bf0-151e-57eb-cad1a4823b9e@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If the memory compaction free scanner cannot successfully split a free
page (only possible due to per-zone low watermark), terminate the free 
scanner rather than continuing to scan memory needlessly.

If the per-zone watermark is insufficient for a free page of 
order <= cc->order, then terminate the scanner since future splits will 
also likely fail.

This prevents the compaction freeing scanner from scanning all memory on 
very large zones (very noticeable for zones > 128GB, for instance) when 
all splits will likely fail.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 49 +++++++++++++++++++++++++++++--------------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -494,24 +494,22 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		/* Found a free page, will break it into order-0 pages */
 		order = page_order(page);
-		isolated = __isolate_free_page(page, page_order(page));
+		isolated = __isolate_free_page(page, order);
+		if (!isolated)
+			break;
 		set_page_private(page, order);
 		total_isolated += isolated;
 		list_add_tail(&page->lru, freelist);
 
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
+		/* Advance to the end of split page */
+		cc->nr_freepages += isolated;
+		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
+			blockpfn += isolated;
+			break;
 		}
+		blockpfn += isolated - 1;
+		cursor += isolated - 1;
+		continue;
 
 isolate_fail:
 		if (strict)
@@ -521,6 +519,9 @@ isolate_fail:
 
 	}
 
+	if (locked)
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+
 	/*
 	 * There is a tiny chance that we have read bogus compound_order(),
 	 * so be careful to not go outside of the pageblock.
@@ -542,9 +543,6 @@ isolate_fail:
 	if (strict && blockpfn < end_pfn)
 		total_isolated = 0;
 
-	if (locked)
-		spin_unlock_irqrestore(&cc->zone->lock, flags);
-
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
 		update_pageblock_skip(cc, valid_page, total_isolated, false);
@@ -622,7 +620,7 @@ isolate_freepages_range(struct compact_control *cc,
 		 */
 	}
 
-	/* split_free_page does not map the pages */
+	/* __isolate_free_page() does not map the pages */
 	map_pages(&freelist);
 
 	if (pfn < end_pfn) {
@@ -1071,6 +1069,7 @@ static void isolate_freepages(struct compact_control *cc)
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
+		unsigned long isolated;
 
 		/*
 		 * This can iterate a massively long zone without finding any
@@ -1095,8 +1094,12 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
-		isolate_freepages_block(cc, &isolate_start_pfn,
-					block_end_pfn, freelist, false);
+		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+						block_end_pfn, freelist, false);
+		/* If free page split failed, do not continue needlessly */
+		if (!isolated && isolate_start_pfn < block_end_pfn &&
+		    cc->nr_freepages <= cc->nr_migratepages)
+			break;
 
 		/*
 		 * If we isolated enough freepages, or aborted due to async
@@ -1124,7 +1127,7 @@ static void isolate_freepages(struct compact_control *cc)
 		}
 	}
 
-	/* split_free_page does not map the pages */
+	/* __isolate_free_page() does not map the pages */
 	map_pages(freelist);
 
 	/*
@@ -1703,6 +1706,12 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			continue;
 		}
 
+		/* Don't attempt compaction if splitting free page will fail */
+		if (!zone_watermark_ok(zone, 0,
+				       low_wmark_pages(zone) + (1 << order),
+				       0, 0))
+			continue;
+
 		status = compact_zone_order(zone, order, gfp_mask, mode,
 				&zone_contended, alloc_flags,
 				ac_classzone_idx(ac));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
