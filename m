Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A00966B01F6
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 05:42:28 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct reclaim allocation fails
Date: Mon, 16 Aug 2010 10:42:13 +0100
Message-Id: <1281951733-29466-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
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
---
 mm/page_alloc.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 67a2ed0..a8651a4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1844,6 +1844,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
 	struct task_struct *p = current;
+	bool drained = false;
 
 	cond_resched();
 
@@ -1865,11 +1866,25 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	if (order != 0)
 		drain_all_pages();
 
-	if (likely(*did_some_progress))
-		page = get_page_from_freelist(gfp_mask, nodemask, order,
+	if (unlikely(!(*did_some_progress)))
+		return NULL;
+
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
