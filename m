From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070524190546.31911.7469.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070524190505.31911.42785.sendpatchset@skynet.skynet.ie>
References: <20070524190505.31911.42785.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/5] Breakout page_order() to internal.h to avoid special knowledge of the buddy allocator
Date: Thu, 24 May 2007 20:05:46 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The statistics patch later needs to know what order a free page is on the
free lists. Rather than having special knowledge of page_private() when
PageBuddy() is set, this patch places out page_order() in internal.h and
adds a VM_BUG_ON to catch using it on non-PageBuddy pages.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 internal.h   |   10 ++++++++++
 page_alloc.c |   10 ----------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-001_fix_movefreepages/mm/internal.h linux-2.6.22-rc2-mm1-002_breakout_pageorder/mm/internal.h
--- linux-2.6.22-rc2-mm1-001_fix_movefreepages/mm/internal.h	2007-05-19 05:06:17.000000000 +0100
+++ linux-2.6.22-rc2-mm1-002_breakout_pageorder/mm/internal.h	2007-05-24 16:41:31.000000000 +0100
@@ -37,4 +37,14 @@ static inline void __put_page(struct pag
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+/*
+ * function for dealing with page's order in buddy system.
+ * zone->lock is already acquired when we use these.
+ * So, we don't need atomic page->flags operations here.
+ */
+static inline unsigned long page_order(struct page *page)
+{
+	VM_BUG_ON(!PageBuddy(page));
+	return page_private(page);
+}
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-001_fix_movefreepages/mm/page_alloc.c linux-2.6.22-rc2-mm1-002_breakout_pageorder/mm/page_alloc.c
--- linux-2.6.22-rc2-mm1-001_fix_movefreepages/mm/page_alloc.c	2007-05-24 16:37:27.000000000 +0100
+++ linux-2.6.22-rc2-mm1-002_breakout_pageorder/mm/page_alloc.c	2007-05-24 16:41:31.000000000 +0100
@@ -336,16 +336,6 @@ static inline void prep_zero_page(struct
 		clear_highpage(page + i);
 }
 
-/*
- * function for dealing with page's order in buddy system.
- * zone->lock is already acquired when we use these.
- * So, we don't need atomic page->flags operations here.
- */
-static inline unsigned long page_order(struct page *page)
-{
-	return page_private(page);
-}
-
 static inline void set_page_order(struct page *page, int order)
 {
 	set_page_private(page, order);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
