Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 414346B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 13:21:38 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id x10so2870007pdj.34
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 10:21:37 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id wp10si2658695pbc.47.2014.03.06.10.21.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Mar 2014 10:21:37 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv2] mm/compaction: Break out of loop on !PageBuddy in isolate_freepages_block
Date: Thu,  6 Mar 2014 10:21:32 -0800
Message-Id: <1394130092-25440-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>

We received several reports of bad page state when freeing CMA pages
previously allocated with alloc_contig_range:

<1>[ 1258.084111] BUG: Bad page state in process Binder_A  pfn:63202
<1>[ 1258.089763] page:d21130b0 count:0 mapcount:1 mapping:  (null) index:0x7dfbf
<1>[ 1258.096109] page flags: 0x40080068(uptodate|lru|active|swapbacked)

Based on the page state, it looks like the page was still in use. The page
flags do not make sense for the use case though. Further debugging showed
that despite alloc_contig_range returning success, at least one page in the
range still remained in the buddy allocator.

There is an issue with isolate_freepages_block. In strict mode (which CMA
uses), if any pages in the range cannot be isolated,
isolate_freepages_block should return failure 0. The current check keeps
track of the total number of isolated pages and compares against the size
of the range:

        if (strict && nr_strict_required > total_isolated)
                total_isolated = 0;

After taking the zone lock, if one of the pages in the range is not
in the buddy allocator, we continue through the loop and do not
increment total_isolated. If in the last iteration of the loop we isolate
more than one page (e.g. last page needed is a higher order page), the
check for total_isolated may pass and we fail to detect that a page was
skipped. The fix is to bail out if the loop immediately if we are in
strict mode. There's no benfit to continuing anyway since we need all
pages to be isolated. Additionally, drop the error checking based on
nr_strict_required and just check the pfn ranges. This matches with
what isolate_freepages_range does.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
v2: Addressed several comments by Vlastimil

 mm/compaction.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 5142920..054c28b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -242,7 +242,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 {
 	int nr_scanned = 0, total_isolated = 0;
 	struct page *cursor, *valid_page = NULL;
-	unsigned long nr_strict_required = end_pfn - blockpfn;
 	unsigned long flags;
 	bool locked = false;
 	bool checked_pageblock = false;
@@ -256,11 +255,12 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		nr_scanned++;
 		if (!pfn_valid_within(blockpfn))
-			continue;
+			goto isolate_fail;
+
 		if (!valid_page)
 			valid_page = page;
 		if (!PageBuddy(page))
-			continue;
+			goto isolate_fail;
 
 		/*
 		 * The zone lock must be held to isolate freepages.
@@ -289,12 +289,10 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		/* Recheck this is a buddy page under lock */
 		if (!PageBuddy(page))
-			continue;
+			goto isolate_fail;
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
-		if (!isolated && strict)
-			break;
 		total_isolated += isolated;
 		for (i = 0; i < isolated; i++) {
 			list_add(&page->lru, freelist);
@@ -305,7 +303,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		if (isolated) {
 			blockpfn += isolated - 1;
 			cursor += isolated - 1;
+			continue;
 		}
+
+isolate_fail:
+		if (strict)
+			break;
+		else
+			continue;
+
 	}
 
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
@@ -315,7 +321,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	 * pages requested were isolated. If there were any failures, 0 is
 	 * returned and CMA will fail.
 	 */
-	if (strict && nr_strict_required > total_isolated)
+	if (strict && blockpfn < end_pfn)
 		total_isolated = 0;
 
 	if (locked)
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
