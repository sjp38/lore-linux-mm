Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCF06B007E
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:16:29 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 11/20] Inline get_page_from_freelist() in the fast-path
Date: Sun, 22 Feb 2009 23:17:20 +0000
Message-Id: <1235344649-18265-12-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

In the best-case scenario, use an inlined version of
get_page_from_freelist(). This increases the size of the text but avoids
time spent pushing arguments onto the stack.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0d8c07..36d30f3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1393,8 +1393,8 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
  */
-static struct page *
-get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
+static inline struct page *
+__get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
 		struct zone *preferred_zone, int migratetype)
 {
@@ -1470,6 +1470,17 @@ try_next_zone:
 	return page;
 }
 
+/* Non-inline version of __get_page_from_freelist() */
+static struct page * noinline
+get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
+		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
+		struct zone *preferred_zone, int migratetype)
+{
+	return __get_page_from_freelist(gfp_mask, nodemask, order,
+			zonelist, high_zoneidx, alloc_flags,
+			preferred_zone, migratetype);
+}
+
 int
 should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 				unsigned long pages_reclaimed)
@@ -1780,8 +1791,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (!preferred_zone)
 		return NULL;
 
-	/* First allocation attempt */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
+	/* First allocation attempt. Fastpath uses inlined version */
+	page = __get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
 			preferred_zone, migratetype);
 	if (unlikely(!page))
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
