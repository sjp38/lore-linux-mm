Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 751846B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 18:35:01 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id he1so55753304pac.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:35:01 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id 203si1672406pfa.186.2016.06.15.15.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 15:35:00 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id b13so11445509pat.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:35:00 -0700 (PDT)
Date: Wed, 15 Jun 2016 15:34:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: ignore watermarks when isolating free
 pages
Message-ID: <alpine.DEB.2.10.1606151530590.37360@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The goal of memory compaction is to defragment memory by moving migratable 
pages to free pages at the end of the zone.  No additional memory is being 
allocated.

Ignore per-zone low watermarks in __isolate_free_page() because memory is 
either fully migrated or isolated free pages are returned when migration 
fails.

This fixes an issue where the compaction freeing scanner can isolate 
memory but the zone drops below its low watermark for that page order, so 
the scanner must continue to scan all memory pointlessly.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2484,23 +2484,14 @@ EXPORT_SYMBOL_GPL(split_page);
 
 int __isolate_free_page(struct page *page, unsigned int order)
 {
-	unsigned long watermark;
 	struct zone *zone;
-	int mt;
+	const int mt = get_pageblock_migratetype(page);
 
 	BUG_ON(!PageBuddy(page));
-
 	zone = page_zone(page);
-	mt = get_pageblock_migratetype(page);
-
-	if (!is_migrate_isolate(mt)) {
-		/* Obey watermarks as if the page was being allocated */
-		watermark = low_wmark_pages(zone) + (1 << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
-			return 0;
 
+	if (!is_migrate_isolate(mt))
 		__mod_zone_freepage_state(zone, -(1UL << order), mt);
-	}
 
 	/* Remove page from free list */
 	list_del(&page->lru);
@@ -2520,7 +2511,6 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		}
 	}
 
-
 	return 1UL << order;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
