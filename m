Message-Id: <200405222215.i4MMFWr14793@mail.osdl.org>
Subject: [patch 53/57] rmap 37 page_add_anon_rmap vma
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:15:00 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Silly final patch for anonmm rmap: change page_add_anon_rmap's mm arg to vma
arg like anon_vma rmap, to smooth the transition between them.


---

 25-akpm/fs/exec.c            |    2 +-
 25-akpm/include/linux/rmap.h |    5 ++++-
 25-akpm/mm/memory.c          |    8 ++++----
 25-akpm/mm/rmap.c            |    6 +++---
 25-akpm/mm/swapfile.c        |    2 +-
 5 files changed, 13 insertions(+), 10 deletions(-)

diff -puN fs/exec.c~rmap-37-page_add_anon_rmap-vma fs/exec.c
--- 25/fs/exec.c~rmap-37-page_add_anon_rmap-vma	2004-05-22 14:56:29.803560696 -0700
+++ 25-akpm/fs/exec.c	2004-05-22 14:59:35.604314688 -0700
@@ -321,7 +321,7 @@ void install_arg_page(struct vm_area_str
 	lru_cache_add_active(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
-	page_add_anon_rmap(page, mm, address);
+	page_add_anon_rmap(page, vma, address);
 	pte_unmap(pte);
 	spin_unlock(&mm->page_table_lock);
 
diff -puN include/linux/rmap.h~rmap-37-page_add_anon_rmap-vma include/linux/rmap.h
--- 25/include/linux/rmap.h~rmap-37-page_add_anon_rmap-vma	2004-05-22 14:56:29.804560544 -0700
+++ 25-akpm/include/linux/rmap.h	2004-05-22 14:59:35.803284440 -0700
@@ -14,7 +14,10 @@
 
 #ifdef CONFIG_MMU
 
-void page_add_anon_rmap(struct page *, struct mm_struct *, unsigned long);
+/*
+ * rmap interfaces called when adding or removing pte of page
+ */
+void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
 void page_remove_rmap(struct page *);
 
diff -puN mm/memory.c~rmap-37-page_add_anon_rmap-vma mm/memory.c
--- 25/mm/memory.c~rmap-37-page_add_anon_rmap-vma	2004-05-22 14:56:29.806560240 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:35.806283984 -0700
@@ -1088,7 +1088,7 @@ static int do_wp_page(struct mm_struct *
 			page_remove_rmap(old_page);
 		break_cow(vma, new_page, address, page_table);
 		lru_cache_add_active(new_page);
-		page_add_anon_rmap(new_page, mm, address);
+		page_add_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
 		new_page = old_page;
@@ -1366,7 +1366,7 @@ static int do_swap_page(struct mm_struct
 
 	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
-	page_add_anon_rmap(page, mm, address);
+	page_add_anon_rmap(page, vma, address);
 
 	if (write_access || mremap_moved_anon_rmap(page, address)) {
 		if (do_wp_page(mm, vma, address,
@@ -1425,7 +1425,7 @@ do_anonymous_page(struct mm_struct *mm, 
 				      vma);
 		lru_cache_add_active(page);
 		mark_page_accessed(page);
-		page_add_anon_rmap(page, mm, addr);
+		page_add_anon_rmap(page, vma, addr);
 	}
 
 	set_pte(page_table, entry);
@@ -1532,7 +1532,7 @@ retry:
 		set_pte(page_table, entry);
 		if (anon) {
 			lru_cache_add_active(new_page);
-			page_add_anon_rmap(new_page, mm, address);
+			page_add_anon_rmap(new_page, vma, address);
 		} else
 			page_add_file_rmap(new_page);
 		pte_unmap(page_table);
diff -puN mm/rmap.c~rmap-37-page_add_anon_rmap-vma mm/rmap.c
--- 25/mm/rmap.c~rmap-37-page_add_anon_rmap-vma	2004-05-22 14:56:29.808559936 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:35.810283376 -0700
@@ -365,15 +365,15 @@ int page_referenced(struct page *page)
 /**
  * page_add_anon_rmap - add pte mapping to an anonymous page
  * @page:	the page to add the mapping to
- * @mm:		the mm in which the mapping is added
+ * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
  *
  * The caller needs to hold the mm->page_table_lock.
  */
 void page_add_anon_rmap(struct page *page,
-	struct mm_struct *mm, unsigned long address)
+	struct vm_area_struct *vma, unsigned long address)
 {
-	struct anonmm *anonmm = mm->anonmm;
+	struct anonmm *anonmm = vma->vm_mm->anonmm;
 
 	BUG_ON(PageReserved(page));
 
diff -puN mm/swapfile.c~rmap-37-page_add_anon_rmap-vma mm/swapfile.c
--- 25/mm/swapfile.c~rmap-37-page_add_anon_rmap-vma	2004-05-22 14:56:29.809559784 -0700
+++ 25-akpm/mm/swapfile.c	2004-05-22 14:59:35.811283224 -0700
@@ -433,7 +433,7 @@ unuse_pte(struct vm_area_struct *vma, un
 	vma->vm_mm->rss++;
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	page_add_anon_rmap(page, vma->vm_mm, address);
+	page_add_anon_rmap(page, vma, address);
 	swap_free(entry);
 }
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
