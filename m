Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3159828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 17:47:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so65901442pfa.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:47:56 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id x2si42412611pfb.89.2016.06.21.14.47.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 14:47:56 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id t190so10385637pfb.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:47:56 -0700 (PDT)
Date: Tue, 21 Jun 2016 14:47:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/2] mm/compaction: split freepages without holding the
 zone lock fix
Message-ID: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If __isolate_free_page() fails, avoid adding to freelist so we don't call
map_pages() with it.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Fix for mm-compaction-split-freepages-without-holding-the-zone-lock.patch in
 -mm.

 mm/compaction.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -494,24 +494,21 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		/* Found a free page, will break it into order-0 pages */
 		order = page_order(page);
-		isolated = __isolate_free_page(page, page_order(page));
+		isolated = __isolate_free_page(page, order);
+		if (!isolated)
+			goto isolate_fail;
 		set_page_private(page, order);
 		total_isolated += isolated;
 		list_add_tail(&page->lru, freelist);
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
+		cc->nr_freepages += isolated;
+		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
+			blockpfn += isolated;
+			break;
 		}
+		/* Advance to end of split page */
+		blockpfn += isolated - 1;
+		cursor += isolated - 1;
+		continue;
 
 isolate_fail:
 		if (strict)
@@ -622,7 +619,7 @@ isolate_freepages_range(struct compact_control *cc,
 		 */
 	}
 
-	/* split_free_page does not map the pages */
+	/* __isolate_free_page() does not map the pages */
 	map_pages(&freelist);
 
 	if (pfn < end_pfn) {
@@ -1124,7 +1121,7 @@ static void isolate_freepages(struct compact_control *cc)
 		}
 	}
 
-	/* split_free_page does not map the pages */
+	/* __isolate_free_page() does not map the pages */
 	map_pages(freelist);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
