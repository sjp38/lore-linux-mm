Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2B1A6B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:50:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l23so5903419pgc.10
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:50:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j25si3492477pgn.86.2017.11.02.05.50.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:50:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, page_alloc: fix potential false positive in __zone_watermark_ok
Date: Thu,  2 Nov 2017 13:50:01 +0100
Message-Id: <20171102125001.23708-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

Since commit 97a16fc82a7c ("mm, page_alloc: only enforce watermarks for order-0
allocations"), __zone_watermark_ok() check for high-order allocations will
shortcut per-migratetype free list checks for ALLOC_HARDER allocations, and
return true as long as there's free page of any migratetype. The intention is
that ALLOC_HARDER can allocate from MIGRATE_HIGHATOMIC free lists, while normal
allocations can't.

However, as a side effect, the watermark check will then also return true when
there are pages only on the MIGRATE_ISOLATE list, or (prior to CMA conversion
to ZONE_MOVABLE) on the MIGRATE_CMA list. Since the allocation cannot actually
obtain isolated pages, and might not be able to obtain CMA pages, this can
result in a false positive.

The condition should be rare and perhaps the outcome is not a fatal one. Still,
it's better if the watermark check is correct. There also shouldn't be a
performance tradeoff here.

Fixes: 97a16fc82a7c ("mm, page_alloc: only enforce watermarks for order-0 allocations")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 79cdac1fee42..f43039945148 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3032,9 +3032,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		if (!area->nr_free)
 			continue;
 
-		if (alloc_harder)
-			return true;
-
 		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
 			if (!list_empty(&area->free_list[mt]))
 				return true;
@@ -3044,6 +3041,9 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		if (!list_empty(&area->free_list[MIGRATE_CMA]))
 			return true;
 #endif
+		if (alloc_harder &&
+			!list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
+			return true;
 	}
 	return false;
 }
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
