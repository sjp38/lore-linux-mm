Message-Id: <200405222211.i4MMBrr14156@mail.osdl.org>
Subject: [patch 42/57] rmap 24 no rmap fastcalls
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:11:22 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

I like CONFIG_REGPARM, even when it's forced on: because it's easy to force
off for debugging - easier than editing out scattered fastcalls.  Plus I've
never understood why we make function foo a fastcall, but function bar not. 
Remove fastcall directives from rmap.  And fix comment about mremap_moved
race: it only applies to anon pages.


---

 25-akpm/include/linux/rmap.h |   14 ++++++--------
 25-akpm/mm/rmap.c            |   16 ++++++++--------
 2 files changed, 14 insertions(+), 16 deletions(-)

diff -puN include/linux/rmap.h~rmap-24-no-rmap-fastcalls include/linux/rmap.h
--- 25/include/linux/rmap.h~rmap-24-no-rmap-fastcalls	2004-05-22 14:56:28.281792040 -0700
+++ 25-akpm/include/linux/rmap.h	2004-05-22 14:59:35.968259360 -0700
@@ -6,7 +6,6 @@
  */
 
 #include <linux/config.h>
-#include <linux/linkage.h>
 
 #define page_map_lock(page) \
 	bit_spin_lock(PG_maplock, (unsigned long *)&(page)->flags)
@@ -15,10 +14,9 @@
 
 #ifdef CONFIG_MMU
 
-void fastcall page_add_anon_rmap(struct page *,
-		struct mm_struct *, unsigned long addr);
-void fastcall page_add_file_rmap(struct page *);
-void fastcall page_remove_rmap(struct page *);
+void page_add_anon_rmap(struct page *, struct mm_struct *, unsigned long);
+void page_add_file_rmap(struct page *);
+void page_remove_rmap(struct page *);
 
 /**
  * page_dup_rmap - duplicate pte mapping to a page
@@ -34,7 +32,7 @@ static inline void page_dup_rmap(struct 
 	page_map_unlock(page);
 }
 
-int fastcall mremap_move_anon_rmap(struct page *page, unsigned long addr);
+int mremap_move_anon_rmap(struct page *page, unsigned long addr);
 
 /**
  * mremap_moved_anon_rmap - does new address clash with that noted?
@@ -85,8 +83,8 @@ void exit_rmap(struct mm_struct *);
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int fastcall page_referenced(struct page *);
-int fastcall try_to_unmap(struct page *);
+int page_referenced(struct page *);
+int try_to_unmap(struct page *);
 
 #else	/* !CONFIG_MMU */
 
diff -puN mm/rmap.c~rmap-24-no-rmap-fastcalls mm/rmap.c
--- 25/mm/rmap.c~rmap-24-no-rmap-fastcalls	2004-05-22 14:56:28.283791736 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:35.971258904 -0700
@@ -259,8 +259,8 @@ static inline int page_referenced_anon(s
 	}
 
 	/*
-	 * The warning below may appear if page_referenced catches the
-	 * page in between page_add_{anon,file}_rmap and its replacement
+	 * The warning below may appear if page_referenced_anon catches
+	 * the page in between page_add_anon_rmap and its replacement
 	 * demanded by mremap_moved_anon_page: so remove the warning once
 	 * we're convinced that anonmm rmap really is finding its pages.
 	 */
@@ -343,7 +343,7 @@ out:
  * returns the number of ptes which referenced the page.
  * Caller needs to hold the rmap lock.
  */
-int fastcall page_referenced(struct page *page)
+int page_referenced(struct page *page)
 {
 	int referenced = 0;
 
@@ -370,7 +370,7 @@ int fastcall page_referenced(struct page
  *
  * The caller needs to hold the mm->page_table_lock.
  */
-void fastcall page_add_anon_rmap(struct page *page,
+void page_add_anon_rmap(struct page *page,
 	struct mm_struct *mm, unsigned long address)
 {
 	struct anonmm *anonmm = mm->anonmm;
@@ -396,7 +396,7 @@ void fastcall page_add_anon_rmap(struct 
  *
  * The caller needs to hold the mm->page_table_lock.
  */
-void fastcall page_add_file_rmap(struct page *page)
+void page_add_file_rmap(struct page *page)
 {
 	BUG_ON(PageAnon(page));
 	if (!pfn_valid(page_to_pfn(page)) || PageReserved(page))
@@ -415,7 +415,7 @@ void fastcall page_add_file_rmap(struct 
  *
  * Caller needs to hold the mm->page_table_lock.
  */
-void fastcall page_remove_rmap(struct page *page)
+void page_remove_rmap(struct page *page)
 {
 	BUG_ON(PageReserved(page));
 	BUG_ON(!page->mapcount);
@@ -444,7 +444,7 @@ void fastcall page_remove_rmap(struct pa
  * If it is shared, then caller must take a copy of the page instead:
  * not very clever, but too rare a case to merit cleverness.
  */
-int fastcall mremap_move_anon_rmap(struct page *page, unsigned long address)
+int mremap_move_anon_rmap(struct page *page, unsigned long address)
 {
 	int move = 0;
 	if (page->mapcount == 1) {
@@ -812,7 +812,7 @@ out:
  * SWAP_AGAIN	- we missed a trylock, try again later
  * SWAP_FAIL	- the page is unswappable
  */
-int fastcall try_to_unmap(struct page *page)
+int try_to_unmap(struct page *page)
 {
 	int ret;
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
