Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CDD6B6B0089
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:51:34 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 16/27] Save text by reducing call sites of __rmqueue()
Date: Mon, 16 Mar 2009 17:53:30 +0000
Message-Id: <1237226020-14057-17-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

__rmqueue is inlined in the fast path but it has two call sites, the low
order and high order paths. However, a slight modification to the
high-order path reduces the call sites of __rmqueue. This reduces text
at the slight increase of complexity of the high-order allocation path.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0ba9e4f..795cfc5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1123,11 +1123,14 @@ again:
 		list_del(&page->lru);
 		pcp->count--;
 	} else {
-		spin_lock_irqsave(&zone->lock, flags);
-		page = __rmqueue(zone, order, migratetype);
-		spin_unlock(&zone->lock);
-		if (!page)
+		LIST_HEAD(list);
+		local_irq_save(flags);
+
+		/* Calling __rmqueue would bloat text, hence this */
+		if (!rmqueue_bulk(zone, order, 1, &list, migratetype))
 			goto failed;
+		page = list_entry(list.next, struct page, lru);
+		list_del(&page->lru);
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
