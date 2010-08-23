Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8A3A6B02C2
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 04:00:43 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct reclaim allocation fails
Date: Mon, 23 Aug 2010 09:00:42 +0100
Message-Id: <1282550442-15193-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When under significant memory pressure, a process enters direct reclaim
and immediately afterwards tries to allocate a page. If it fails and no
further progress is made, it's possible the system will go OOM. However,
on systems with large amounts of memory, it's possible that a significant
number of pages are on per-cpu lists and inaccessible to the calling
process. This leads to a process entering direct reclaim more often than
it should increasing the pressure on the system and compounding the problem.

This patch notes that if direct reclaim is making progress but
allocations are still failing that the system is already under heavy
pressure. In this case, it drains the per-cpu lists and tries the
allocation a second time before continuing.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_alloc.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bbaa959..750e1dc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1847,6 +1847,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
 	struct task_struct *p = current;
+	bool drained = false;
 
 	cond_resched();
 
@@ -1865,14 +1866,25 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	cond_resched();
 
-	if (order != 0)
-		drain_all_pages();
+	if (unlikely(!(*did_some_progress)))
+		return NULL;
 
-	if (likely(*did_some_progress))
-		page = get_page_from_freelist(gfp_mask, nodemask, order,
+retry:
+	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags, preferred_zone,
 					migratetype);
+
+	/*
+	 * If an allocation failed after direct reclaim, it could be because
+	 * pages are pinned on the per-cpu lists. Drain them and try again
+	 */
+	if (!page && !drained) {
+		drain_all_pages();
+		drained = true;
+		goto retry;
+	}
+
 	return page;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
