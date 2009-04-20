Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB2425F0013
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:20:12 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 23/25] Get the pageblock migratetype without disabling interrupts
Date: Mon, 20 Apr 2009 23:20:09 +0100
Message-Id: <1240266011-11140-24-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Local interrupts are disabled when freeing pages to the PCP list. Part
of that free checks what the migratetype of the pageblock the page is in
but it checks this with interrupts disabled. This patch checks the
pagetype with interrupts enabled. The impact is that it is possible a
page is freed to the wrong list when a pageblock changes type but as
that block is now already considered mixed from an anti-fragmentation
perspective, it's not of vital importance.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6bcaf08..acb0fac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1035,6 +1035,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 	kernel_map_pages(page, 1, 0);
 
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
+	set_page_private(page, get_pageblock_migratetype(page));
 	local_irq_save(flags);
 	if (unlikely(clearMlocked))
 		free_page_mlock(page);
@@ -1044,7 +1045,6 @@ static void free_hot_cold_page(struct page *page, int cold)
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
