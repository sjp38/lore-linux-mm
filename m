From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 06/11] RFP prot support: fix get_user_pages() on VM_MANYPROTS
	vmas
Date: Sat, 31 Mar 2007 02:35:41 +0200
Message-ID: <20070331003541.3415.67315.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

*Non unit-tested patch* - I've not written a test case to verify functionality of
ptrace on VM_MANYPROTS area.

get_user_pages may well call __handle_mm_fault() wanting to override protections,
so in this case __handle_mm_fault() should still avoid checking VM access rights.

Also, get_user_pages() may give write faults on present readonly PTEs in
VM_MANYPROTS areas (think of PTRACE_POKETEXT), so we must still do do_wp_page
even on VM_MANYPROTS areas.

So, possibly use VM_MAYWRITE and/or VM_MAYREAD in the access_mask and check
VM_MANYPROTS in maybe_mkwrite_file (new variant of maybe_mkwrite).

API Note: there are many flags parameter which can be constructed but which
don't make any sense, but the code very freely interprets them too.
For instance VM_MAYREAD|VM_WRITE is interpreted as VM_MAYWRITE|VM_WRITE.

This is fixed in next patch (to merge here).

====
pte_to_pgprot is to be used only with encoded PTEs.

This is needed since now pte_to_pgprot does heavy changes to the pte, it looks
for _PAGE_FILE_PROTNONE and translates it to _PAGE_PROTNONE.
---

 mm/memory.c |   36 +++++++++++++++++++++++++++++-------
 1 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d66c8ca..8572033 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -984,6 +984,7 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 {
 	int i;
 	unsigned int vm_flags;
+	int ft_flags;
 
 	/* 
 	 * Require read or write permissions.
@@ -991,6 +992,7 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	 */
 	vm_flags  = write ? (VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
 	vm_flags &= force ? (VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
+	ft_flags = (write ? FT_WRITE : FT_READ) | (force ? FT_FORCE : 0);
 	i = 0;
 
 	do {
@@ -1057,22 +1059,25 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		do {
 			struct page *page;
 
-			if (write)
+			if (write) {
 				foll_flags |= FOLL_WRITE;
+				ft_flags |= FT_WRITE;
+			}
 
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
-				ret = __handle_mm_fault(mm, vma, start,
-						foll_flags & FOLL_WRITE);
+				ret = __handle_mm_fault(mm, vma, start, ft_flags);
 				/*
 				 * The VM_FAULT_WRITE bit tells us that do_wp_page has
 				 * broken COW when necessary, even if maybe_mkwrite
 				 * decided not to set pte_write. We can thus safely do
 				 * subsequent page lookups as if they were reads.
 				 */
-				if (ret & VM_FAULT_WRITE)
+				if (ret & VM_FAULT_WRITE) {
 					foll_flags &= ~FOLL_WRITE;
+					ft_flags &= ~FT_WRITE;
+				}
 				
 				switch (ret & ~VM_FAULT_WRITE) {
 				case VM_FAULT_MINOR:
@@ -1486,7 +1491,20 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
  * servicing faults for write access.  In the normal case, do always want
  * pte_mkwrite.  But get_user_pages can cause write faults for mappings
  * that do not have writing enabled, when used by access_process_vm.
+ *
+ * Also, we must never change protections on VM_MANYPROTS pages; that's only
+ * allowed in do_no_page(), so test only VMA protections there. For other cases
+ * we *know* that VM_MANYPROTS is clear, such as anonymous/swap pages, and in
+ * that case using plain maybe_mkwrite() is an optimization.
+ * Instead, when we may be mapping a file, we must use maybe_mkwrite_file.
  */
+static inline pte_t maybe_mkwrite_file(pte_t pte, struct vm_area_struct *vma)
+{
+	if (likely((vma->vm_flags & (VM_WRITE | VM_MANYPROTS)) == VM_WRITE))
+		pte = pte_mkwrite(pte);
+	return pte;
+}
+
 static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 {
 	if (likely(vma->vm_flags & VM_WRITE))
@@ -1539,6 +1557,9 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
+ *
+ * Note that a page here can be a shared readonly page where
+ * get_user_pages() (for instance for ptrace()) wants to write to it!
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -1604,7 +1625,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (reuse) {
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = pte_mkyoung(orig_pte);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		/* Since it can be shared, it can be VM_MANYPROTS! */
+		entry = maybe_mkwrite_file(pte_mkdirty(entry), vma);
 		ptep_set_access_flags(vma, address, page_table, entry, 1);
 		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
@@ -1647,7 +1669,7 @@ gotten:
 			inc_mm_counter(mm, anon_rss);
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = maybe_mkwrite_file(pte_mkdirty(entry), vma);
 		lazy_mmu_prot_update(entry);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
@@ -2109,7 +2131,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = maybe_mkwrite_file(pte_mkdirty(pte), vma);
 		write_access = 0;
 	}
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
