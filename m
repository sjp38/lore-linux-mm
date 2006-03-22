From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20060322223552.12658.16852.sendpatchset@twins.localnet>
In-Reply-To: <20060322223107.12658.14997.sendpatchset@twins.localnet>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
Subject: [PATCH 28/34] mm: clockpro-PG_reclaim2.patch
Date: Wed, 22 Mar 2006 23:36:24 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Bob Picco <bob.picco@hp.com>, Andrew Morton <akpm@osdl.org>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add a second PG_flag to the page reclaim framework.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

---

 include/linux/page-flags.h |    2 ++
 mm/hugetlb.c               |    4 ++--
 mm/page_alloc.c            |    3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2006-03-13 20:38:26.000000000 +0100
+++ linux-2.6/include/linux/page-flags.h	2006-03-13 20:45:31.000000000 +0100
@@ -76,6 +76,8 @@
 #define PG_nosave_free		18	/* Free, should not be written */
 #define PG_uncached		19	/* Page has been mapped as uncached */
 
+#define PG_reclaim2		20	/* reserved by the mm reclaim code */
+
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
  * allowed.
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-03-13 20:38:26.000000000 +0100
+++ linux-2.6/mm/page_alloc.c	2006-03-13 20:45:31.000000000 +0100
@@ -150,6 +150,7 @@ static void bad_page(struct page *page)
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_reclaim1 |
+			1 << PG_reclaim2 |
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -361,6 +362,7 @@ static inline int free_pages_check(struc
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_reclaim1 |
+			1 << PG_reclaim2 |
 			1 << PG_reclaim	|
 			1 << PG_slab	|
 			1 << PG_swapcache |
@@ -518,6 +520,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_private	|
 			1 << PG_locked	|
 			1 << PG_reclaim1 |
+			1 << PG_reclaim2 |
 			1 << PG_dirty	|
 			1 << PG_reclaim	|
 			1 << PG_slab    |
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2006-03-13 20:38:26.000000000 +0100
+++ linux-2.6/mm/hugetlb.c	2006-03-13 20:45:31.000000000 +0100
@@ -152,8 +152,8 @@ static void update_and_free_page(struct 
 	nr_huge_pages_node[page_zone(page)->zone_pgdat->node_id]--;
 	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
-				1 << PG_dirty | 1 << PG_reclaim1 | 1 << PG_reserved |
-				1 << PG_private | 1<< PG_writeback);
+				1 << PG_dirty | 1 << PG_reclaim1 | 1 << PG_reclaim2 |
+				1 << PG_reserved | 1 << PG_private | 1<< PG_writeback);
 		set_page_count(&page[i], 0);
 	}
 	set_page_count(page, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
