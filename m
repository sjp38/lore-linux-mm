Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D447D6B0098
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:39 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 31/35] Optimistically check the first page on the PCP free list is suitable
Date: Mon, 16 Mar 2009 09:46:26 +0000
Message-Id: <1237196790-7268-32-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

The PCP lists are searched for a page of the suitable order. However,
the majority of pages are still expected to be order-0 pages and the
setup for the search is a bit expensive. This patch optimistically
checks if the first page is suitable for use in the hot-page allocation
path.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb5bd5e..8568284 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1212,6 +1212,12 @@ again:
 				if (pcp_page_suit(page, order))
 					break;
 		} else {
+			/* Optimistic before we start a list search */
+			page = list_entry(list->next, struct page, lru);
+			if (pcp_page_suit(page, order))
+				goto found;
+
+			/* Do the search */
 			list_for_each_entry(page, list, lru)
 				if (pcp_page_suit(page, order))
 					break;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
