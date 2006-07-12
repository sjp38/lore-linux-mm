From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:37:57 +0200
Message-Id: <20060712143757.16998.46090.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 5/39] mm: pgrep: add a use-once insertion hint
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Allow for a use-once hint.

API:

give a hint to the page replace algorithm:

	void pgrep_hint_use_once(struct page *);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h    |    1 +
 include/linux/mm_use_once_policy.h |    4 ++++
 mm/filemap.c                       |   12 ++++++++++++
 3 files changed, 17 insertions(+)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/filemap.c	2006-07-12 16:08:18.000000000 +0200
@@ -412,6 +412,18 @@ int add_to_page_cache(struct page *page,
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
 			page_cache_get(page);
+			/*
+			 * shmem_getpage()
+			 *   lookup_swap_cache()
+			 *   TestSetPageLocked()
+			 *   move_from_swap_cache()
+			 *     add_to_page_cache()
+			 *
+			 * That path calls us with a LRU page instead of a new
+			 * page. Don't set the hint for LRU pages.
+			 */
+			if (!PageLocked(page))
+				pgrep_hint_use_once(page);
 			SetPageLocked(page);
 			page->mapping = mapping;
 			page->index = offset;
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:54.000000000 +0200
@@ -9,6 +9,7 @@
 #include <linux/mm_inline.h>
 
 /* void pgrep_hint_active(struct page *); */
+/* void pgrep_hint_use_once(struct page *); */
 extern void fastcall pgrep_add(struct page *);
 /* void __pgrep_add(struct zone *, struct page *); */
 /* void pgrep_add_drain(void); */
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:54.000000000 +0200
@@ -8,6 +8,10 @@ static inline void pgrep_hint_active(str
 	SetPageActive(page);
 }
 
+static inline void pgrep_hint_use_once(struct page *page)
+{
+}
+
 static inline void
 __pgrep_add(struct zone *zone, struct page *page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
