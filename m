Message-Id: <20070525051948.009700520@sgi.com>
References: <20070525051716.030494061@sgi.com>
Date: Thu, 24 May 2007 22:17:22 -0700
From: clameter@sgi.com
Subject: [patch 6/6] compound pages: Allow freeing of compound pages via pagevec
Content-Disposition: inline; filename=compound_free_via_pagevec
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Allow the freeing of compound pages via pagevec.

In release_pages() we currently special case for compound pages in order to
be sure to always decrement the page count of the head page and not the
tail page. However that redirection to the head page is only necessary for
tail pages. So use PageTail instead of PageCompound. No change therefore
for the handling of tail pages.

The head page of a compound pages now represents single page large page.
We do the usual processing including checking if its on the LRU
and removing it (not useful right now but later when compound pages are
on the LRU this will work). Then we add the compound page to the pagevec.
Only head pages will end up on the pagevec not tail pages.

In __pagevec_free() we then check if we are freeing a head page and if
so call the destructor for the compound page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/page_alloc.c |   13 +++++++++++--
 mm/swap.c       |    8 +++++++-
 2 files changed, 18 insertions(+), 3 deletions(-)

Index: slub/mm/page_alloc.c
===================================================================
--- slub.orig/mm/page_alloc.c	2007-05-24 21:34:23.000000000 -0700
+++ slub/mm/page_alloc.c	2007-05-24 21:43:24.000000000 -0700
@@ -1760,8 +1760,17 @@ void __pagevec_free(struct pagevec *pvec
 {
 	int i = pagevec_count(pvec);
 
-	while (--i >= 0)
-		free_hot_cold_page(pvec->pages[i], pvec->cold);
+	while (--i >= 0) {
+		struct page *page = pvec->pages[i];
+
+		if (PageHead(page)) {
+			compound_page_dtor *dtor;
+
+			dtor = get_compound_page_dtor(page);
+			(*dtor)(page);
+		} else
+			free_hot_cold_page(page, pvec->cold);
+	}
 }
 
 fastcall void __free_pages(struct page *page, unsigned int order)
Index: slub/mm/swap.c
===================================================================
--- slub.orig/mm/swap.c	2007-05-24 21:34:23.000000000 -0700
+++ slub/mm/swap.c	2007-05-24 21:43:24.000000000 -0700
@@ -307,7 +307,13 @@ void release_pages(struct page **pages, 
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
-		if (unlikely(PageCompound(page))) {
+		/*
+		 * If we have a tail page on the LRU then we need to
+		 * decrement the page count of the head page. There
+		 * is no further need to do anything since tail pages
+		 * cannot be on the LRU.
+		 */
+		if (unlikely(PageTail(page))) {
 			if (zone) {
 				spin_unlock_irq(&zone->lru_lock);
 				zone = NULL;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
