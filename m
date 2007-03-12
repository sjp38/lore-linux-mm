From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070312042611.5536.11505.sendpatchset@linux.site>
In-Reply-To: <20070312042553.5536.73828.sendpatchset@linux.site>
References: <20070312042553.5536.73828.sendpatchset@linux.site>
Subject: [patch 2/4] mm: move and rename install_arg_page
Date: Mon, 12 Mar 2007 07:38:53 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Move install_arg_page to to mm/memory.c, where it belongs, rename it to
install_new_anon_page, and return proper error codes rather than SIGKILL
on error (behaviour of callers remains the same).

Signed-off-by: Nick Piggin <npiggin@suse.de>

 arch/ia64/ia32/binfmt_elf32.c  |    5 +++-
 arch/x86_64/ia32/ia32_binfmt.c |    5 +++-
 fs/exec.c                      |   43 +++--------------------------------------
 include/linux/mm.h             |    2 -
 mm/memory.c                    |   40 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 53 insertions(+), 42 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2128,6 +2128,46 @@ out_nomap:
 }
 
 /*
+ * This routine is used to map in an anonymous page into an address space:
+ * needed by execve() for the initial stack and environment pages.
+ *
+ * vma->vm_mm->mmap_sem must be held.
+ *
+ * Returns 0 on success, otherwise the failure code.
+ *
+ * The routine consumes the reference on the page if it is successful,
+ * otherwise the caller must free it.
+ */
+int install_new_anon_page(struct vm_area_struct *vma,
+			struct page *page, unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t * pte;
+	spinlock_t *ptl;
+
+	if (unlikely(anon_vma_prepare(vma)))
+		return -ENOMEM;
+
+	flush_dcache_page(page);
+	pte = get_locked_pte(mm, address, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	if (!pte_none(*pte)) {
+		pte_unmap_unlock(pte, ptl);
+		return -EEXIST;
+	}
+	inc_mm_counter(mm, anon_rss);
+	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
+					page, vma->vm_page_prot))));
+	lru_cache_add_active(page);
+	page_add_new_anon_rmap(page, vma, address);
+	pte_unmap_unlock(pte, ptl);
+
+	/* no need for flush_tlb */
+	return 0;
+}
+
+/*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -786,7 +786,7 @@ static inline int handle_mm_fault(struct
 
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
-void install_arg_page(struct vm_area_struct *, struct page *, unsigned long);
+int install_new_anon_page(struct vm_area_struct *, struct page *, unsigned long);
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
 		int len, int write, int force, struct page **pages, struct vm_area_struct **vmas);
Index: linux-2.6/fs/exec.c
===================================================================
--- linux-2.6.orig/fs/exec.c
+++ linux-2.6/fs/exec.c
@@ -297,44 +297,6 @@ int copy_strings_kernel(int argc,char **
 EXPORT_SYMBOL(copy_strings_kernel);
 
 #ifdef CONFIG_MMU
-/*
- * This routine is used to map in a page into an address space: needed by
- * execve() for the initial stack and environment pages.
- *
- * vma->vm_mm->mmap_sem is held for writing.
- */
-void install_arg_page(struct vm_area_struct *vma,
-			struct page *page, unsigned long address)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	pte_t * pte;
-	spinlock_t *ptl;
-
-	if (unlikely(anon_vma_prepare(vma)))
-		goto out;
-
-	flush_dcache_page(page);
-	pte = get_locked_pte(mm, address, &ptl);
-	if (!pte)
-		goto out;
-	if (!pte_none(*pte)) {
-		pte_unmap_unlock(pte, ptl);
-		goto out;
-	}
-	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
-	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
-	page_add_new_anon_rmap(page, vma, address);
-	pte_unmap_unlock(pte, ptl);
-
-	/* no need for flush_tlb */
-	return;
-out:
-	__free_page(page);
-	force_sig(SIGKILL, current);
-}
-
 #define EXTRA_STACK_VM_PAGES	20	/* random */
 
 int setup_arg_pages(struct linux_binprm *bprm,
@@ -442,7 +404,10 @@ int setup_arg_pages(struct linux_binprm 
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
+			if (install_new_anon_page(mpnt, page, stack_base)) {
+				__free_page(page);
+				force_sig(SIGKILL, current);
+			}
 		}
 		stack_base += PAGE_SIZE;
 	}
Index: linux-2.6/arch/ia64/ia32/binfmt_elf32.c
===================================================================
--- linux-2.6.orig/arch/ia64/ia32/binfmt_elf32.c
+++ linux-2.6/arch/ia64/ia32/binfmt_elf32.c
@@ -240,7 +240,10 @@ ia32_setup_arg_pages (struct linux_binpr
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
+			if (install_new_anon_page(mpnt, page, stack_base)) {
+				__free_page(page);
+				force_sig(SIGKILL, current);
+			}
 		}
 		stack_base += PAGE_SIZE;
 	}
Index: linux-2.6/arch/x86_64/ia32/ia32_binfmt.c
===================================================================
--- linux-2.6.orig/arch/x86_64/ia32/ia32_binfmt.c
+++ linux-2.6/arch/x86_64/ia32/ia32_binfmt.c
@@ -327,7 +327,10 @@ int ia32_setup_arg_pages(struct linux_bi
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
+			if (install_new_anon_page(mpnt, page, stack_base)) {
+				__free_page(page);
+				force_sig(SIGKILL, current);
+			}
 		}
 		stack_base += PAGE_SIZE;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
