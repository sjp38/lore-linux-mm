Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id D3A4A6B006E
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:33:29 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id p9so2101573lbv.7
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:33:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c10si11455071wjy.4.2015.01.08.02.33.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 02:33:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V5 1/4] mm: set page->pfmemalloc in prep_new_page()
Date: Thu,  8 Jan 2015 11:33:08 +0100
Message-Id: <1420713191-17509-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1420713191-17509-1-git-send-email-vbabka@suse.cz>
References: <1420713191-17509-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>

The function prep_new_page() sets almost everything in the struct page of the
page being allocated, except page->pfmemalloc. This is not obvious and has at
least once led to a bug where page->pfmemalloc was forgotten to be set
correctly, see commit 8fb74b9fb2b1 ("mm: compaction: partially revert capture
of suitable high-order page").

This patch moves the pfmemalloc setting to prep_new_page(), which means it
needs to gain alloc_flags parameter. The call to prep_new_page is moved from
buffered_rmqueue() to get_page_from_freelist(), which also leads to simpler
code. An obsolete comment for buffered_rmqueue() is replaced.

In addition to better maintainability there is a small reduction of code and
stack usage for get_page_from_freelist(), which inlines the other functions
involved.

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-145 (-145)
function                                     old     new   delta
get_page_from_freelist                      2670    2525    -145

Stack usage is reduced from 184 to 168 bytes.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5ed7f93..4060ad2b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -937,7 +937,8 @@ static inline int check_new_page(struct page *page)
 	return 0;
 }
 
-static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
+static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
+								int alloc_flags)
 {
 	int i;
 
@@ -961,6 +962,14 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
 
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
 
@@ -1609,9 +1618,7 @@ int split_free_page(struct page *page)
 }
 
 /*
- * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
- * we cheat by calling it from here, in the order > 0 path.  Saves a branch
- * or two.
+ * Allocate a page from the given zone. Use pcplists for order-0 allocations.
  */
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
@@ -1622,7 +1629,6 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 	struct page *page;
 	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 
-again:
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 		struct list_head *list;
@@ -1678,8 +1684,6 @@ again:
 	local_irq_restore(flags);
 
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
-	if (prep_new_page(page, order, gfp_flags))
-		goto again;
 	return page;
 
 failed:
@@ -2144,25 +2148,16 @@ zonelist_scan:
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
