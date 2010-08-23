Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 38D136B02B9
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 04:00:43 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/3] mm: page allocator: Update free page counters after pages are placed on the free list
Date: Mon, 23 Aug 2010 09:00:40 +0100
Message-Id: <1282550442-15193-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When allocating a page, the system uses NR_FREE_PAGES counters to determine
if watermarks would remain intact after the allocation was made. This
check is made without interrupts disabled or the zone lock held and so is
race-prone by nature. Unfortunately, when pages are being freed in batch,
the counters are updated before the pages are added on the list. During this
window, the counters are misleading as the pages do not exist yet. When
under significant pressure on systems with large numbers of CPUs, it's
possible for processes to make progress even though they should have been
stalled. This is particularly problematic if a number of the processes are
using GFP_ATOMIC as the min watermark can be accidentally breached and in
extreme cases, the system can livelock.

This patch updates the counters after the pages have been added to the
list. This makes the allocator more cautious with respect to preserving
the watermarks and mitigates livelock possibilities.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a9649f4..97d74a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -588,12 +588,12 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 {
 	int migratetype = 0;
 	int batch_free = 0;
+	int freed = count;
 
 	spin_lock(&zone->lock);
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
-	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
 	while (count) {
 		struct page *page;
 		struct list_head *list;
@@ -621,6 +621,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
 		} while (--count && --batch_free && !list_empty(list));
 	}
+	__mod_zone_page_state(zone, NR_FREE_PAGES, freed);
 	spin_unlock(&zone->lock);
 }
 
@@ -631,8 +632,8 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
-	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 	__free_one_page(page, zone, order, migratetype);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 	spin_unlock(&zone->lock);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
