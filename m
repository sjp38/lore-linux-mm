Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A4EEE6B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 03:21:45 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so119363265pdb.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:21:45 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id i6si28695089pdr.64.2015.04.27.00.21.43
        for <linux-mm@kvack.org>;
        Mon, 27 Apr 2015 00:21:44 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/3] mm/page_alloc: stop fallback allocation if we already get some freepage
Date: Mon, 27 Apr 2015 16:23:40 +0900
Message-Id: <1430119421-13536-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Sometimes we try to get more freepages from buddy list than how much
we really need, in order to refill pcp list. This may speed up following
allocation request, but, there is a possibility to increase fragmentation
if we steal freepages from other migratetype buddy list excessively. This
patch changes this behaviour to stop fallback allocation in order to
reduce fragmentation if we already get some freepages.

CPU: 8
RAM: 512 MB with zram swap
WORKLOAD: kernel build with -j12
OPTION: page owner is enabled to measure fragmentation
After finishing the build, check fragmentation by 'cat /proc/pagetypeinfo'

* Before
Number of blocks type (movable)
DMA32: 208.4

Number of mixed blocks (movable)
DMA32: 139

Mixed blocks means that there is one or more allocated page for
unmovable/reclaimable allocation in movable pageblock. Results shows that
more than half of movable pageblock is tainted by other migratetype
allocation.

* After
Number of blocks type (movable)
DMA32: 207

Number of mixed blocks (movable)
DMA32: 111.2

This result shows that non-mixed block increase by 38% in this case.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 044f16c..fbe2211 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1292,7 +1292,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
  * Call me with the zone->lock already held.
  */
 static struct page *__rmqueue(struct zone *zone, unsigned int order,
-						int migratetype)
+					int migratetype, int index)
 {
 	struct page *page;
 	bool steal_fallback;
@@ -1301,6 +1301,10 @@ retry:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
 	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
+		/* We already get some freepages so don't do agressive steal */
+		if (index != 0)
+			goto out;
+
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
@@ -1338,7 +1342,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page = __rmqueue(zone, order, migratetype, i);
 		if (unlikely(page == NULL))
 			break;
 
@@ -1749,7 +1753,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 			WARN_ON_ONCE(order > 1);
 		}
 		spin_lock_irqsave(&zone->lock, flags);
-		page = __rmqueue(zone, order, migratetype);
+		page = __rmqueue(zone, order, migratetype, 0);
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
