From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:41:14 +0200
Message-Id: <20060712144114.16998.58510.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 22/39] mm: pgrep: per policy PG_flags
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Abstract the replacement policy specific pageflags.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_use_once_policy.h |    8 ++++++++
 include/linux/page-flags.h         |    7 +------
 mm/hugetlb.c                       |    2 +-
 mm/page_alloc.c                    |    6 +++---
 4 files changed, 13 insertions(+), 10 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:36.000000000 +0200
@@ -5,6 +5,14 @@
 
 #include <linux/fs.h>
 #include <linux/rmap.h>
+#include <linux/page-flags.h>
+
+#define PG_active	PG_reclaim1
+
+#define PageActive(page)	test_bit(PG_active, &(page)->flags)
+#define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
+#define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
+#define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
 
 static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2006-07-12 16:07:30.000000000 +0200
+++ linux-2.6/include/linux/page-flags.h	2006-07-12 16:11:30.000000000 +0200
@@ -70,7 +70,7 @@
 
 #define PG_dirty	 	 4
 #define PG_lru			 5
-#define PG_active		 6
+#define PG_reclaim1		 6	/* reserved by the mm reclaim code */
 #define PG_slab			 7	/* slab debug (Suparna wants this) */
 
 #define PG_checked		 8	/* kill me in 2.5.<early>. */
@@ -259,11 +259,6 @@ extern void __mod_page_state_offset(unsi
 #define ClearPageLRU(page)	clear_bit(PG_lru, &(page)->flags)
 #define __ClearPageLRU(page)	__clear_bit(PG_lru, &(page)->flags)
 
-#define PageActive(page)	test_bit(PG_active, &(page)->flags)
-#define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
-#define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
-#define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
-
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define __SetPageSlab(page)	__set_bit(PG_slab, &(page)->flags)
 #define __ClearPageSlab(page)	__clear_bit(PG_slab, &(page)->flags)
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/page_alloc.c	2006-07-12 16:11:30.000000000 +0200
@@ -149,7 +149,7 @@ static void bad_page(struct page *page)
 	page->flags &= ~(1 << PG_lru	|
 			1 << PG_private |
 			1 << PG_locked	|
-			1 << PG_active	|
+			1 << PG_reclaim1 |
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -379,7 +379,7 @@ static inline int free_pages_check(struc
 			1 << PG_lru	|
 			1 << PG_private |
 			1 << PG_locked	|
-			1 << PG_active	|
+			1 << PG_reclaim1 |
 			1 << PG_reclaim	|
 			1 << PG_slab	|
 			1 << PG_swapcache |
@@ -527,7 +527,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_lru	|
 			1 << PG_private	|
 			1 << PG_locked	|
-			1 << PG_active	|
+			1 << PG_reclaim1 |
 			1 << PG_dirty	|
 			1 << PG_reclaim	|
 			1 << PG_slab    |
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/hugetlb.c	2006-07-12 16:11:30.000000000 +0200
@@ -291,7 +291,7 @@ static void update_and_free_page(struct 
 	nr_huge_pages_node[page_zone(page)->zone_pgdat->node_id]--;
 	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
-				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
+				1 << PG_dirty | 1 << PG_reclaim1 | 1 << PG_reserved |
 				1 << PG_private | 1<< PG_writeback);
 	}
 	page[1].lru.next = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
