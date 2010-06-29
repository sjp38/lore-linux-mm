Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 157B86007C1
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:43:41 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 10/14] vmscan: Setup pagevec as late as possible in shrink_page_list()
Date: Tue, 29 Jun 2010 12:34:44 +0100
Message-Id: <1277811288-5195-11-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

shrink_page_list() sets up a pagevec to release pages as according as they
are free. It uses significant amounts of stack on the pagevec. This
patch adds pages to be freed via pagevec to a linked list which is then
freed en-masse at the end. This avoids using stack in the main path that
potentially calls writepage().

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8b4ed48..1107830 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -620,6 +620,24 @@ static enum page_references page_check_references(struct page *page,
 	return PAGEREF_RECLAIM;
 }
 
+static noinline_for_stack void free_page_list(struct list_head *free_pages)
+{
+	struct pagevec freed_pvec;
+	struct page *page, *tmp;
+
+	pagevec_init(&freed_pvec, 1);
+
+	list_for_each_entry_safe(page, tmp, free_pages, lru) {
+		list_del(&page->lru);
+		if (!pagevec_add(&freed_pvec, page)) {
+			__pagevec_free(&freed_pvec);
+			pagevec_reinit(&freed_pvec);
+		}
+	}
+
+	pagevec_free(&freed_pvec);
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -628,13 +646,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					enum pageout_io sync_writeback)
 {
 	LIST_HEAD(ret_pages);
-	struct pagevec freed_pvec;
+	LIST_HEAD(free_pages);
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
 
-	pagevec_init(&freed_pvec, 1);
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -809,10 +826,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		__clear_page_locked(page);
 free_it:
 		nr_reclaimed++;
-		if (!pagevec_add(&freed_pvec, page)) {
-			__pagevec_free(&freed_pvec);
-			pagevec_reinit(&freed_pvec);
-		}
+
+		/*
+		 * Is there need to periodically free_page_list? It would
+		 * appear not as the counts should be low
+		 */
+		list_add(&page->lru, &free_pages);
 		continue;
 
 cull_mlocked:
@@ -835,9 +854,10 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
+
+	free_page_list(&free_pages);
+
 	list_splice(&ret_pages, page_list);
-	if (pagevec_count(&freed_pvec))
-		__pagevec_free(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
