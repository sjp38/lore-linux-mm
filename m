Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 012D36B0071
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 14:59:21 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so2495740wiw.16
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 11:59:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a7si3902844wie.15.2014.12.05.11.59.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 11:59:17 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/4] mm: set page->pfmemalloc in prep_new_page()
Date: Fri,  5 Dec 2014 20:59:02 +0100
Message-Id: <1417809545-4540-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
References: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

The function prep_new_page() sets almost everything in the struct page of the
page being allocated, except page->pfmemalloc. This is not obvious and has at
least once led to a bug where page->pfmemalloc was forgotten to be set
correctly, see commit 8fb74b9fb2b1 ("mm: compaction: partially revert capture
of suitable high-order page").

This patch moves the pfmemalloc setting to prep_new_page(), which means it
needs to gain alloc_flags parameter. The call to prep_new_page is moved from
buffered_rmqueue() to get_page_from_freelist(), which also leads to simpler
code. An obsolete comment for buffered_rmqueue() is replaced.

A small addition to better maintainability is reduction of code and stack
usage for get_page_from_freelist() (which inlines the other above mentioned
functions).

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 622929f..bfc00c3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -970,7 +970,8 @@ static inline int check_new_page(struct page *page)
 	return 0;
 }
 
-static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
+static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
+								int alloc_flags)
 {
 	int i;
 
@@ -994,6 +995,14 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
 
 	set_page_owner(page, order, gfp_flags);
 
+	/*
+	 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was necessary to
+	 * allocate the page. The expectation is that the caller is taking
+	 * steps that will free more memory. The caller should avoid the page
+	 * being used for !PFMEMALLOC purposes.
+	 */
+	page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+
 	return 0;
 }
 
@@ -1642,9 +1651,7 @@ int split_free_page(struct page *page)
 }
 
 /*
- * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
- * we cheat by calling it from here, in the order > 0 path.  Saves a branch
- * or two.
+ * Allocate a page from the given zone. Use pcplists for order-0 allocations.
  */
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
@@ -1655,7 +1662,6 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 	struct page *page;
 	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 
-again:
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 		struct list_head *list;
@@ -1711,8 +1717,6 @@ again:
 	local_irq_restore(flags);
 
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
-	if (prep_new_page(page, order, gfp_flags))
-		goto again;
 	return page;
 
 failed:
@@ -2177,25 +2181,16 @@ zonelist_scan:
 try_this_zone:
 		page = buffered_rmqueue(preferred_zone, zone, order,
 						gfp_mask, migratetype);
-		if (page)
-			break;
+		if (page) {
+			if (prep_new_page(page, order, gfp_mask, alloc_flags))
+				goto try_this_zone;
+			return page;
+		}
 this_zone_full:
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active)
 			zlc_mark_zone_full(zonelist, z);
 	}
 
-	if (page) {
-		/*
-		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
-		 * necessary to allocate the page. The expectation is
-		 * that the caller is taking steps that will free more
-		 * memory. The caller should avoid the page being used
-		 * for !PFMEMALLOC purposes.
-		 */
-		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
-		return page;
-	}
-
 	/*
 	 * The first pass makes sure allocations are spread fairly within the
 	 * local node.  However, the local node might have free pages left
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
