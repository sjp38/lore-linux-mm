From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/1] handle initialising compound pages at orders greater than MAX_ORDER
Date: Thu,  2 Oct 2008 17:19:56 +0100
Message-Id: <1222964396-25031-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

When we initialise a compound page we initialise the page flags and head
page pointer for all base pages spanned by that page.  When we initialise a
gigantic page (a page of order greater than or equal to MAX_ORDER) we have
to initialise more than MAX_ORDER_NR_PAGES pages.  Currently we assume
that all elements of the mem_map in this page are contigious in memory.
However this is only guarenteed out to MAX_ORDER_NR_PAGES pages, and with
SPARSEMEM enabled they will not be contigious.  This leads us to walk off
the end of the first section and scribble on everything which follows, BAD.

When we reach a MAX_ORDER_NR_PAGES boundary we much locate the next section
of the mem_map.  As gigantic pages can only be maximally aligned we know
this will occur at exact multiple of MAX_ORDER_NR_PAGES pages from the
start of the page.

This is a bug fix for the gigantic page support in hugetlbfs, please
consider for merging before 2.6.27.

Credit to Mel Gorman for spotting the issue.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/page_alloc.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e293c58..27b8681 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -268,13 +268,14 @@ void prep_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
+	struct page *p = page + 1;
 
 	set_compound_page_dtor(page, free_compound_page);
 	set_compound_order(page, order);
 	__SetPageHead(page);
-	for (i = 1; i < nr_pages; i++) {
-		struct page *p = page + i;
-
+	for (i = 1; i < nr_pages; i++, p++) {
+		if (unlikely((i & (MAX_ORDER_NR_PAGES - 1)) == 0))
+			p = pfn_to_page(page_to_pfn(page) + i);
 		__SetPageTail(p);
 		p->first_page = page;
 	}
@@ -284,6 +285,7 @@ static void destroy_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
+	struct page *p = page + 1;
 
 	if (unlikely(compound_order(page) != order))
 		bad_page(page);
@@ -291,8 +293,9 @@ static void destroy_compound_page(struct page *page, unsigned long order)
 	if (unlikely(!PageHead(page)))
 			bad_page(page);
 	__ClearPageHead(page);
-	for (i = 1; i < nr_pages; i++) {
-		struct page *p = page + i;
+	for (i = 1; i < nr_pages; i++, p++) {
+		if (unlikely((i & (MAX_ORDER_NR_PAGES - 1)) == 0))
+			p = pfn_to_page(page_to_pfn(page) + i);
 
 		if (unlikely(!PageTail(p) |
 				(p->first_page != page)))
-- 
1.6.0.1.451.gc8d31

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
