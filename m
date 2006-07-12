From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:43:17 +0200
Message-Id: <20060712144316.16998.36177.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 32/39] mm: cart: third per policy PG_flag
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add a third PG_flag to the page reclaim framework.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/page-flags.h |    1 +
 mm/hugetlb.c               |    3 ++-
 mm/page_alloc.c            |    3 +++
 3 files changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/page-flags.h	2006-07-12 16:09:19.000000000 +0200
@@ -90,6 +90,7 @@
 
 #define PG_uncached		20	/* Page has been mapped as uncached */
 #define PG_reclaim2		21	/* reserved by the mm reclaim code */
+#define PG_reclaim3		22	/* reserved by the mm reclaim code */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/page_alloc.c	2006-07-12 16:09:19.000000000 +0200
@@ -151,6 +151,7 @@ static void bad_page(struct page *page)
 			1 << PG_locked	|
 			1 << PG_reclaim1 |
 			1 << PG_reclaim2 |
+			1 << PG_reclaim3 |
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -382,6 +383,7 @@ static inline int free_pages_check(struc
 			1 << PG_locked	|
 			1 << PG_reclaim1 |
 			1 << PG_reclaim2 |
+			1 << PG_reclaim3 |
 			1 << PG_reclaim	|
 			1 << PG_slab	|
 			1 << PG_swapcache |
@@ -531,6 +533,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_locked	|
 			1 << PG_reclaim1 |
 			1 << PG_reclaim2 |
+			1 << PG_reclaim3 |
 			1 << PG_dirty	|
 			1 << PG_reclaim	|
 			1 << PG_slab    |
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/hugetlb.c	2006-07-12 16:09:19.000000000 +0200
@@ -292,7 +292,8 @@ static void update_and_free_page(struct 
 	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_reclaim1 | 1 << PG_reclaim2 |
-				1 << PG_reserved | 1 << PG_private | 1<< PG_writeback);
+				1 << PG_reclaim3 | 1 << PG_reserved | 1 << PG_private |
+				1<< PG_writeback);
 	}
 	page[1].lru.next = NULL;
 	set_page_refcounted(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
