Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 37A766B00A4
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:42 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 34/35] Allow compound pages to be stored on the PCP lists
Date: Mon, 16 Mar 2009 09:46:29 +0000
Message-Id: <1237196790-7268-35-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

The SLUB allocator frees and allocates compound pages. The setup costs
for compound pages are noticeable in profiles and incur cache misses as
every struct page has to be checked and written. This patch allows
compound pages to be stored on the PCP list to save on teardown and
setup time.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/page-flags.h |    4 ++-
 mm/page_alloc.c            |   50 +++++++++++++++++++++++++++++---------------
 2 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 219a523..4177ec1 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -388,7 +388,9 @@ static inline void __ClearPageTail(struct page *page)
  * Pages being prepped should not have any flags set.  It they are set,
  * there has been a kernel bug or struct page corruption.
  */
-#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_CHECK_AT_PREP_BUDDY	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_CHECK_AT_PREP	(((1 << NR_PAGEFLAGS) - 1) & \
+					~(1 << PG_head | 1 << PG_tail))
 
 #endif /* !__GENERATING_BOUNDS_H */
 #endif	/* PAGE_FLAGS_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f1741a3..1ac4c3d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -281,11 +281,7 @@ out:
  * put_page() function.  Its ->lru.prev holds the order of allocation.
  * This usage means that zero-order pages may not be compound.
  */
-
-static void free_compound_page(struct page *page)
-{
-	__free_pages_ok(page, compound_order(page));
-}
+static void free_compound_page(struct page *page);
 
 void prep_compound_page(struct page *page, unsigned long order)
 {
@@ -557,7 +553,9 @@ static inline void __free_one_page(struct page *page,
 	zone->free_area[page_order(page)].nr_free++;
 }
 
-static inline int free_pages_check(struct page *page)
+/* Sanity check a free pages flags */
+static inline int check_freepage_flags(struct page *page,
+						unsigned long prepflags)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
@@ -566,8 +564,8 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
-	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
-		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	if (page->flags & prepflags)
+		page->flags &= ~prepflags;
 	return 0;
 }
 
@@ -678,7 +676,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	int clearMlocked = PageMlocked(page);
 
 	for (i = 0 ; i < (1 << order) ; ++i)
-		bad += free_pages_check(page + i);
+		bad += check_freepage_flags(page + i,
+					PAGE_FLAGS_CHECK_AT_PREP_BUDDY);
 	if (bad)
 		return;
 
@@ -782,8 +781,20 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 	if (gfp_flags & __GFP_ZERO)
 		prep_zero_page(page, order, gfp_flags);
 
-	if (order && (gfp_flags & __GFP_COMP))
-		prep_compound_page(page, order);
+	/*
+	 * If a compound page is requested, we have to check the page being
+	 * prepped. If it's already compound, we leave it alone. If a
+	 * compound page is not requested but the page being prepped is
+	 * compound, then it must be destroyed
+	 */
+	if (order) {
+		if ((gfp_flags & __GFP_COMP) && !PageCompound(page))
+			prep_compound_page(page, order);
+
+		if (!(gfp_flags & __GFP_COMP) && PageCompound(page))
+			if (unlikely(destroy_compound_page(page, order)))
+				return 1;
+	}
 
 	return 0;
 }
@@ -1148,14 +1159,9 @@ static void free_hot_cold_page(struct page *page, int order, int cold)
 	int migratetype;
 	int clearMlocked = PageMlocked(page);
 
-	/* SLUB can return lowish-order compound pages that need handling */
-	if (order > 0 && unlikely(PageCompound(page)))
-		if (unlikely(destroy_compound_page(page, order)))
-			return;
-
 	if (PageAnon(page))
 		page->mapping = NULL;
-	if (free_pages_check(page))
+	if (check_freepage_flags(page, PAGE_FLAGS_CHECK_AT_PREP))
 		return;
 
 	if (!PageHighMem(page)) {
@@ -1199,6 +1205,16 @@ out:
 	put_cpu();
 }
 
+static void free_compound_page(struct page *page)
+{
+	unsigned int order = compound_order(page);
+
+	if (order <= PAGE_ALLOC_COSTLY_ORDER)
+		free_hot_cold_page(page, order, 0);
+	else
+		__free_pages_ok(page, order);
+}
+
 void free_hot_page(struct page *page)
 {
 	free_hot_cold_page(page, 0, 0);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
