Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BD0976B005D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:51:34 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 13/27] Inline __rmqueue_smallest()
Date: Mon, 16 Mar 2009 17:53:27 +0000
Message-Id: <1237226020-14057-14-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Inline __rmqueue_smallest by altering flow very slightly so that there
is only one call site. This allows the function to be inlined without
additional text bloat.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1e8b4b6..a3ca80d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -664,7 +664,8 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
  * Go through the free lists for the given migratetype and remove
  * the smallest available page from the freelists
  */
-static struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
+static inline
+struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 						int migratetype)
 {
 	unsigned int current_order;
@@ -834,24 +835,36 @@ static struct page *__rmqueue_fallback(struct zone *zone, int order,
 		}
 	}
 
-	/* Use MIGRATE_RESERVE rather than fail an allocation */
-	return __rmqueue_smallest(zone, order, MIGRATE_RESERVE);
+	return NULL;
 }
 
 /*
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.
  */
-static struct page *__rmqueue(struct zone *zone, unsigned int order,
+static inline
+struct page *__rmqueue(struct zone *zone, unsigned int order,
 						int migratetype)
 {
 	struct page *page;
 
+retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
-	if (unlikely(!page))
+	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
 		page = __rmqueue_fallback(zone, order, migratetype);
 
+		/*
+		 * Use MIGRATE_RESERVE rather than fail an allocation. goto
+		 * is used because __rmqueue_smallest is an inline function
+		 * and we want just one call site
+		 */
+		if (!page) {
+			migratetype = MIGRATE_RESERVE;
+			goto retry_reserve;
+		}
+	}
+
 	return page;
 }
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
