Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 24F756B00B9
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:52:55 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 20/22] Get the pageblock migratetype without disabling interrupts
Date: Wed, 22 Apr 2009 14:53:25 +0100
Message-Id: <1240408407-21848-21-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Local interrupts are disabled when freeing pages to the PCP list. Part of
that free checks what the migratetype of the pageblock the page is in but it
checks this with interrupts disabled and interupts should never be disabled
longer than necessary. This patch checks the pagetype with interrupts
enabled with the impact that it is possible a page is freed to the wrong
list when a pageblock changes type. As that block is now already considered
mixed from an anti-fragmentation perspective, it's not of vital importance.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6494e13..ba41551 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1034,6 +1034,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 	kernel_map_pages(page, 1, 0);
 
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
+	set_page_private(page, get_pageblock_migratetype(page));
 	local_irq_save(flags);
 	if (unlikely(clearMlocked))
 		free_page_mlock(page);
@@ -1043,7 +1044,6 @@ static void free_hot_cold_page(struct page *page, int cold)
 		list_add_tail(&page->lru, &pcp->list);
 	else
 		list_add(&page->lru, &pcp->list);
-	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
