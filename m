Date: Fri, 6 Apr 2007 12:44:27 +0100
Subject: [PATCH] Do not cross section boundary when moving pages between mobility lists
Message-ID: <20070406114426.GA21653@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: y-goto@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

move-free-pages-between-lists-on-steal-fix-2.patch fixed an issue with a
BUG_ON() that checked for a page just outside a MAX_ORDER_NR_PAGES boundary. In
fact, the proper place to check it was earlier. A situation can occur on
SPARSEMEM where a section boundary is crossed which will cause problems on some
machines. This patch addresses the problem.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc5-mm4-clean/mm/page_alloc.c linux-movefree_sparsememfix/mm/page_alloc.c
--- linux-2.6.21-rc5-mm4-clean/mm/page_alloc.c	2007-04-04 17:33:15.000000000 +0100
+++ linux-movefree_sparsememfix/mm/page_alloc.c	2007-04-06 10:06:08.000000000 +0100
@@ -743,10 +743,10 @@ int move_freepages(struct zone *zone,
 	 * Remove at a later date when no bug reports exist related to
 	 * CONFIG_PAGE_GROUP_BY_MOBILITY
 	 */
-	BUG_ON(page_zone(start_page) != page_zone(end_page - 1));
+	BUG_ON(page_zone(start_page) != page_zone(end_page));
 #endif
 
-	for (page = start_page; page < end_page;) {
+	for (page = start_page; page <= end_page;) {
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
 			continue;
@@ -776,8 +776,8 @@ int move_freepages_block(struct zone *zo
 	start_pfn = page_to_pfn(page);
 	start_pfn = start_pfn & ~(MAX_ORDER_NR_PAGES-1);
 	start_page = pfn_to_page(start_pfn);
-	end_page = start_page + MAX_ORDER_NR_PAGES;
-	end_pfn = start_pfn + MAX_ORDER_NR_PAGES;
+	end_page = start_page + MAX_ORDER_NR_PAGES - 1;
+	end_pfn = start_pfn + MAX_ORDER_NR_PAGES - 1;
 
 	/* Do not cross zone boundaries */
 	if (start_pfn < zone->zone_start_pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
