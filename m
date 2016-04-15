Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4867828E6
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:10:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so13146672wmw.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:10:30 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id bb7si49467672wjc.182.2016.04.15.02.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:10:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 38CE71C1999
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:10:29 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 27/28] mm, page_alloc: Defer debugging checks of freed pages until a PCP drain
Date: Fri, 15 Apr 2016 10:07:54 +0100
Message-Id: <1460711275-1130-15-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Every page free checks a number of page fields for validity. This
catches premature frees and corruptions but it is also expensive.
This patch weakens the debugging check by checking PCP pages at the
time they are drained from the PCP list. This will trigger the bug
but the site that freed the corrupt page will be lost. To get the
full context, a kernel rebuild with DEBUG_VM is necessary.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 244 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 146 insertions(+), 98 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e63afe07c032..b5722790c846 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -939,6 +939,148 @@ static inline int free_pages_check(struct page *page)
 	return 1;
 }
 
+static int free_tail_pages_check(struct page *head_page, struct page *page)
+{
+	int ret = 1;
+
+	/*
+	 * We rely page->lru.next never has bit 0 set, unless the page
+	 * is PageTail(). Let's make sure that's true even for poisoned ->lru.
+	 */
+	BUILD_BUG_ON((unsigned long)LIST_POISON1 & 1);
+
+	if (!IS_ENABLED(CONFIG_DEBUG_VM)) {
+		ret = 0;
+		goto out;
+	}
+	switch (page - head_page) {
+	case 1:
+		/* the first tail page: ->mapping is compound_mapcount() */
+		if (unlikely(compound_mapcount(page))) {
+			bad_page(page, "nonzero compound_mapcount", 0);
+			goto out;
+		}
+		break;
+	case 2:
+		/*
+		 * the second tail page: ->mapping is
+		 * page_deferred_list().next -- ignore value.
+		 */
+		break;
+	default:
+		if (page->mapping != TAIL_MAPPING) {
+			bad_page(page, "corrupted mapping in tail page", 0);
+			goto out;
+		}
+		break;
+	}
+	if (unlikely(!PageTail(page))) {
+		bad_page(page, "PageTail not set", 0);
+		goto out;
+	}
+	if (unlikely(compound_head(page) != head_page)) {
+		bad_page(page, "compound_head not consistent", 0);
+		goto out;
+	}
+	ret = 0;
+out:
+	page->mapping = NULL;
+	clear_compound_head(page);
+	return ret;
+}
+
+static bool free_pages_prepare(struct page *page, unsigned int order)
+{
+	int bad = 0;
+
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	trace_mm_page_free(page, order);
+	kmemcheck_free_shadow(page, order);
+	kasan_free_pages(page, order);
+
+	/*
+	 * Check tail pages before head page information is cleared to
+	 * avoid checking PageCompound for order-0 pages.
+	 */
+	if (order) {
+		bool compound = PageCompound(page);
+		int i;
+
+		VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
+
+		for (i = 1; i < (1 << order); i++) {
+			if (compound)
+				bad += free_tail_pages_check(page, page + i);
+			bad += free_pages_check(page + i);
+		}
+	}
+	if (PageAnonHead(page))
+		page->mapping = NULL;
+	bad += free_pages_check(page);
+	if (bad)
+		return false;
+
+	reset_page_owner(page, order);
+
+	if (!PageHighMem(page)) {
+		debug_check_no_locks_freed(page_address(page),
+					   PAGE_SIZE << order);
+		debug_check_no_obj_freed(page_address(page),
+					   PAGE_SIZE << order);
+	}
+	arch_free_page(page, order);
+	kernel_poison_pages(page, 1 << order, 0);
+	kernel_map_pages(page, 1 << order, 0);
+
+	return true;
+}
+
+#ifdef CONFIG_DEBUG_VM
+static inline bool free_pcp_prepare(struct page *page)
+{
+	return free_pages_prepare(page, 0);
+}
+
+static inline bool bulkfree_pcp_prepare(struct page *page)
+{
+	return false;
+}
+#else
+static bool free_pcp_prepare(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	trace_mm_page_free(page, 0);
+	kmemcheck_free_shadow(page, 0);
+	kasan_free_pages(page, 0);
+
+	if (PageAnonHead(page))
+		page->mapping = NULL;
+
+	reset_page_owner(page, 0);
+
+	if (!PageHighMem(page)) {
+		debug_check_no_locks_freed(page_address(page),
+					   PAGE_SIZE);
+		debug_check_no_obj_freed(page_address(page),
+					   PAGE_SIZE);
+	}
+	arch_free_page(page, 0);
+	kernel_poison_pages(page, 0, 0);
+	kernel_map_pages(page, 0, 0);
+
+	page_cpupid_reset_last(page);
+	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	return true;
+}
+
+static bool bulkfree_pcp_prepare(struct page *page)
+{
+	return free_pages_check(page);
+}
+#endif /* CONFIG_DEBUG_VM */
+
 /*
  * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
@@ -999,6 +1141,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			if (unlikely(isolated_pageblocks))
 				mt = get_pageblock_migratetype(page);
 
+			if (bulkfree_pcp_prepare(page))
+				continue;
+
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
 		} while (--count && --batch_free && !list_empty(list));
@@ -1025,56 +1170,6 @@ static void free_one_page(struct zone *zone,
 	spin_unlock(&zone->lock);
 }
 
-static int free_tail_pages_check(struct page *head_page, struct page *page)
-{
-	int ret = 1;
-
-	/*
-	 * We rely page->lru.next never has bit 0 set, unless the page
-	 * is PageTail(). Let's make sure that's true even for poisoned ->lru.
-	 */
-	BUILD_BUG_ON((unsigned long)LIST_POISON1 & 1);
-
-	if (!IS_ENABLED(CONFIG_DEBUG_VM)) {
-		ret = 0;
-		goto out;
-	}
-	switch (page - head_page) {
-	case 1:
-		/* the first tail page: ->mapping is compound_mapcount() */
-		if (unlikely(compound_mapcount(page))) {
-			bad_page(page, "nonzero compound_mapcount", 0);
-			goto out;
-		}
-		break;
-	case 2:
-		/*
-		 * the second tail page: ->mapping is
-		 * page_deferred_list().next -- ignore value.
-		 */
-		break;
-	default:
-		if (page->mapping != TAIL_MAPPING) {
-			bad_page(page, "corrupted mapping in tail page", 0);
-			goto out;
-		}
-		break;
-	}
-	if (unlikely(!PageTail(page))) {
-		bad_page(page, "PageTail not set", 0);
-		goto out;
-	}
-	if (unlikely(compound_head(page) != head_page)) {
-		bad_page(page, "compound_head not consistent", 0);
-		goto out;
-	}
-	ret = 0;
-out:
-	page->mapping = NULL;
-	clear_compound_head(page);
-	return ret;
-}
-
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
@@ -1148,53 +1243,6 @@ void __meminit reserve_bootmem_region(unsigned long start, unsigned long end)
 	}
 }
 
-static bool free_pages_prepare(struct page *page, unsigned int order)
-{
-	int bad = 0;
-
-	VM_BUG_ON_PAGE(PageTail(page), page);
-
-	trace_mm_page_free(page, order);
-	kmemcheck_free_shadow(page, order);
-	kasan_free_pages(page, order);
-
-	/*
-	 * Check tail pages before head page information is cleared to
-	 * avoid checking PageCompound for order-0 pages.
-	 */
-	if (order) {
-		bool compound = PageCompound(page);
-		int i;
-
-		VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
-
-		for (i = 1; i < (1 << order); i++) {
-			if (compound)
-				bad += free_tail_pages_check(page, page + i);
-			bad += free_pages_check(page + i);
-		}
-	}
-	if (PageAnonHead(page))
-		page->mapping = NULL;
-	bad += free_pages_check(page);
-	if (bad)
-		return false;
-
-	reset_page_owner(page, order);
-
-	if (!PageHighMem(page)) {
-		debug_check_no_locks_freed(page_address(page),
-					   PAGE_SIZE << order);
-		debug_check_no_obj_freed(page_address(page),
-					   PAGE_SIZE << order);
-	}
-	arch_free_page(page, order);
-	kernel_poison_pages(page, 1 << order, 0);
-	kernel_map_pages(page, 1 << order, 0);
-
-	return true;
-}
-
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
@@ -2327,7 +2375,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
 
-	if (!free_pages_prepare(page, 0))
+	if (!free_pcp_prepare(page))
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
