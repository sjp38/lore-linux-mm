Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5F86B0082
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 07:17:20 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 13/19] Inline __rmqueue_smallest()
Date: Tue, 24 Feb 2009 12:17:09 +0000
Message-Id: <1235477835-14500-14-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
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
index ead73fd..51eedfa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -665,7 +665,8 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
  * Go through the free lists for the given migratetype and remove
  * the smallest available page from the freelists
  */
-static struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
+static inline
+struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 						int migratetype)
 {
 	unsigned int current_order;
@@ -835,24 +836,36 @@ static struct page *__rmqueue_fallback(struct zone *zone, int order,
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
