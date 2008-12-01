Date: Mon, 1 Dec 2008 00:41:39 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2/8] badpage: keep any bad page out of circulation
In-Reply-To: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010040330.11401@blonde.site>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Until now the bad_page() checkers have special-cased PageReserved, keeping
those pages out of circulation thereafter.  Now extend the special case to
all: we want to keep ANY page with bad state out of circulation - the
"free" page may well be in use by something.

Leave the bad state of those pages untouched, for examination by debuggers;
except for PageBuddy - leaving that set would risk bringing the page back.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/page_alloc.c |   52 +++++++++++++++++++++-------------------------
 1 file changed, 24 insertions(+), 28 deletions(-)

--- badpage1/mm/page_alloc.c	2008-11-28 20:40:33.000000000 +0000
+++ badpage2/mm/page_alloc.c	2008-11-28 20:40:36.000000000 +0000
@@ -231,9 +231,9 @@ static void bad_page(struct page *page)
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
 		KERN_EMERG "Backtrace:\n");
 	dump_stack();
-	set_page_count(page, 0);
-	reset_page_mapcount(page);
-	page->mapping = NULL;
+
+	/* Leave bad fields for debug, except PageBuddy could make trouble */
+	__ClearPageBuddy(page);
 	add_taint(TAINT_BAD_PAGE);
 }
 
@@ -290,25 +290,31 @@ void prep_compound_gigantic_page(struct 
 }
 #endif
 
-static void destroy_compound_page(struct page *page, unsigned long order)
+static int destroy_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
+	int bad = 0;
 
-	if (unlikely(compound_order(page) != order))
+	if (unlikely(compound_order(page) != order) ||
+	    unlikely(!PageHead(page))) {
 		bad_page(page);
+		bad++;
+	}
 
-	if (unlikely(!PageHead(page)))
-			bad_page(page);
 	__ClearPageHead(page);
+
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 
-		if (unlikely(!PageTail(p) |
-				(p->first_page != page)))
+		if (unlikely(!PageTail(p) | (p->first_page != page))) {
 			bad_page(page);
+			bad++;
+		}
 		__ClearPageTail(p);
 	}
+
+	return bad;
 }
 
 static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
@@ -428,7 +434,8 @@ static inline void __free_one_page(struc
 	int migratetype = get_pageblock_migratetype(page);
 
 	if (unlikely(PageCompound(page)))
-		destroy_compound_page(page, order);
+		if (unlikely(destroy_compound_page(page, order)))
+			return;
 
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
 
@@ -465,15 +472,10 @@ static inline int free_pages_check(struc
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
 		(page_count(page) != 0)  |
-		(page->flags & PAGE_FLAGS_CHECK_AT_FREE)))
+		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
 		bad_page(page);
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not free the page.  But we shall soon need
-	 * to do more, for when the ZERO_PAGE count wraps negative.
-	 */
-	if (PageReserved(page))
 		return 1;
+	}
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -521,11 +523,11 @@ static void __free_pages_ok(struct page 
 {
 	unsigned long flags;
 	int i;
-	int reserved = 0;
+	int bad = 0;
 
 	for (i = 0 ; i < (1 << order) ; ++i)
-		reserved += free_pages_check(page + i);
-	if (reserved)
+		bad += free_pages_check(page + i);
+	if (bad)
 		return;
 
 	if (!PageHighMem(page)) {
@@ -610,17 +612,11 @@ static int prep_new_page(struct page *pa
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
 		(page_count(page) != 0)  |
-		(page->flags & PAGE_FLAGS_CHECK_AT_PREP)))
+		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
 		bad_page(page);
-
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not allocate the page: as a safety net.
-	 */
-	if (PageReserved(page))
 		return 1;
+	}
 
-	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
