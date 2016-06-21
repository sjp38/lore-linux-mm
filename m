Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 195DB828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 17:47:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so65903095pfa.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:47:59 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id y15si42314305pfb.59.2016.06.21.14.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 14:47:58 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id hl6so9902179pac.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:47:58 -0700 (PDT)
Date: Tue, 21 Jun 2016 14:47:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/2] mm, compaction: abort free scanner if split fails
In-Reply-To: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1606211447360.43430@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
 Note: I think we may want to backport this to -stable since this problem
 has existed since at least 3.11.  This patch won't cleanly apply to any
 stable tree, though.  If people think it should be backported, let me know
 and I'll handle the failures as they arise and rebase.

 mm/compaction.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -496,7 +496,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		order = page_order(page);
 		isolated = __isolate_free_page(page, order);
 		if (!isolated)
-			goto isolate_fail;
+			break;
 		set_page_private(page, order);
 		total_isolated += isolated;
 		list_add_tail(&page->lru, freelist);
@@ -518,6 +518,9 @@ isolate_fail:
 
 	}
 
+	if (locked)
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+
 	/*
 	 * There is a tiny chance that we have read bogus compound_order(),
 	 * so be careful to not go outside of the pageblock.
@@ -539,9 +542,6 @@ isolate_fail:
 	if (strict && blockpfn < end_pfn)
 		total_isolated = 0;
 
-	if (locked)
-		spin_unlock_irqrestore(&cc->zone->lock, flags);
-
 	/* Update the pageblock-skip if the whole pageblock was scanned */
 	if (blockpfn == end_pfn)
 		update_pageblock_skip(cc, valid_page, total_isolated, false);
@@ -1068,6 +1068,7 @@ static void isolate_freepages(struct compact_control *cc)
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
+		unsigned long isolated;
 
 		/*
 		 * This can iterate a massively long zone without finding any
@@ -1092,8 +1093,12 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
-		isolate_freepages_block(cc, &isolate_start_pfn,
-					block_end_pfn, freelist, false);
+		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
+						block_end_pfn, freelist, false);
+		/* If isolation failed, do not continue needlessly */
+		if (!isolated && isolate_start_pfn < block_end_pfn &&
+		    cc->nr_freepages <= cc->nr_migratepages)
+			break;
 
 		/*
 		 * If we isolated enough freepages, or aborted due to async

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
