Message-Id: <200405222213.i4MMDlr14496@mail.osdl.org>
Subject: [patch 49/57] rmap 33 install_arg_page vma
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:13:11 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

anon_vma will need to pass vma to put_dirty_page, so change it and its
various callers (setup_arg_pages and its 32-on-64-bit arch variants); and
please, let's rename it to install_arg_page.

Earlier attempt to do this (rmap 26 __setup_arg_pages) tried to clean up
those callers instead, but failed to boot: so now apply rmap 27's memset
initialization of vmas to these callers too; which relieves them from
needing the recently included linux/mempolicy.h.

While there, moved install_arg_page's flush_dcache_page up before
page_table_lock - doesn't in fact matter at all, just saves one worry when
researching flush_dcache_page locking constraints.


---

 25-akpm/arch/ia64/ia32/binfmt_elf32.c  |   10 +++-------
 25-akpm/arch/ia64/kernel/perfmon.c     |    1 -
 25-akpm/arch/ia64/mm/init.c            |    3 +--
 25-akpm/arch/s390/kernel/compat_exec.c |    9 +++------
 25-akpm/arch/x86_64/ia32/ia32_binfmt.c |   10 +++-------
 25-akpm/fs/exec.c                      |   20 ++++++++++----------
 25-akpm/include/linux/mm.h             |    3 +--
 7 files changed, 21 insertions(+), 35 deletions(-)

diff -puN arch/ia64/ia32/binfmt_elf32.c~rmap-33-install_arg_page-vma arch/ia64/ia32/binfmt_elf32.c
--- 25/arch/ia64/ia32/binfmt_elf32.c~rmap-33-install_arg_page-vma	2004-05-22 14:56:29.212650528 -0700
+++ 25-akpm/arch/ia64/ia32/binfmt_elf32.c	2004-05-22 14:56:29.224648704 -0700
@@ -14,7 +14,6 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/security.h>
-#include <linux/mempolicy.h>
 
 #include <asm/param.h>
 #include <asm/signal.h>
@@ -169,6 +168,8 @@ ia32_setup_arg_pages (struct linux_binpr
 		return -ENOMEM;
 	}
 
+	memset(mpnt, 0, sizeof(*mpnt));
+
 	down_write(&current->mm->mmap_sem);
 	{
 		mpnt->vm_mm = current->mm;
@@ -182,11 +183,6 @@ ia32_setup_arg_pages (struct linux_binpr
 			mpnt->vm_flags = VM_STACK_FLAGS;
 		mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC)?
 					PAGE_COPY_EXEC: PAGE_COPY;
-		mpnt->vm_ops = NULL;
-		mpnt->vm_pgoff = 0;
-		mpnt->vm_file = NULL;
-		mpnt->vm_private_data = 0;
-		mpol_set_vma_default(mpnt);
 		insert_vm_struct(current->mm, mpnt);
 		current->mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	}
@@ -195,7 +191,7 @@ ia32_setup_arg_pages (struct linux_binpr
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			put_dirty_page(current, page, stack_base, mpnt->vm_page_prot);
+			install_arg_page(mpnt, page, stack_base);
 		}
 		stack_base += PAGE_SIZE;
 	}
diff -puN arch/ia64/kernel/perfmon.c~rmap-33-install_arg_page-vma arch/ia64/kernel/perfmon.c
--- 25/arch/ia64/kernel/perfmon.c~rmap-33-install_arg_page-vma	2004-05-22 14:56:29.214650224 -0700
+++ 25-akpm/arch/ia64/kernel/perfmon.c	2004-05-22 14:56:29.228648096 -0700
@@ -38,7 +38,6 @@
 #include <linux/pagemap.h>
 #include <linux/mount.h>
 #include <linux/version.h>
-#include <linux/mempolicy.h>
 
 #include <asm/bitops.h>
 #include <asm/errno.h>
diff -puN arch/ia64/mm/init.c~rmap-33-install_arg_page-vma arch/ia64/mm/init.c
--- 25/arch/ia64/mm/init.c~rmap-33-install_arg_page-vma	2004-05-22 14:56:29.215650072 -0700
+++ 25-akpm/arch/ia64/mm/init.c	2004-05-22 14:56:29.229647944 -0700
@@ -19,7 +19,6 @@
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
-#include <linux/mempolicy.h>
 
 #include <asm/a.out.h>
 #include <asm/bitops.h>
@@ -218,7 +217,7 @@ free_initrd_mem (unsigned long start, un
 }
 
 /*
- * This is like put_dirty_page() but installs a clean page in the kernel's page table.
+ * This installs a clean page in the kernel's page table.
  */
 struct page *
 put_kernel_page (struct page *page, unsigned long address, pgprot_t pgprot)
diff -puN arch/s390/kernel/compat_exec.c~rmap-33-install_arg_page-vma arch/s390/kernel/compat_exec.c
--- 25/arch/s390/kernel/compat_exec.c~rmap-33-install_arg_page-vma	2004-05-22 14:56:29.217649768 -0700
+++ 25-akpm/arch/s390/kernel/compat_exec.c	2004-05-22 14:56:29.230647792 -0700
@@ -58,6 +58,8 @@ int setup_arg_pages32(struct linux_binpr
 		return -ENOMEM;
 	}
 
+	memset(mpnt, 0, sizeof(*mpnt));
+
 	down_write(&mm->mmap_sem);
 	{
 		mpnt->vm_mm = mm;
@@ -66,11 +68,6 @@ int setup_arg_pages32(struct linux_binpr
 		/* executable stack setting would be applied here */
 		mpnt->vm_page_prot = PAGE_COPY;
 		mpnt->vm_flags = VM_STACK_FLAGS;
-		mpnt->vm_ops = NULL;
-		mpnt->vm_pgoff = 0;
-		mpnt->vm_file = NULL;
-		mpol_set_vma_default(mpnt);
-		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
 		mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	} 
@@ -79,7 +76,7 @@ int setup_arg_pages32(struct linux_binpr
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			put_dirty_page(current,page,stack_base,PAGE_COPY);
+			install_arg_page(mpnt, page, stack_base);
 		}
 		stack_base += PAGE_SIZE;
 	}
diff -puN arch/x86_64/ia32/ia32_binfmt.c~rmap-33-install_arg_page-vma arch/x86_64/ia32/ia32_binfmt.c
--- 25/arch/x86_64/ia32/ia32_binfmt.c~rmap-33-install_arg_page-vma	2004-05-22 14:56:29.218649616 -0700
+++ 25-akpm/arch/x86_64/ia32/ia32_binfmt.c	2004-05-22 14:56:29.230647792 -0700
@@ -15,7 +15,6 @@
 #include <linux/binfmts.h>
 #include <linux/mm.h>
 #include <linux/security.h>
-#include <linux/mempolicy.h>
 
 #include <asm/segment.h> 
 #include <asm/ptrace.h>
@@ -350,6 +349,8 @@ int setup_arg_pages(struct linux_binprm 
 		return -ENOMEM;
 	}
 
+	memset(mpnt, 0, sizeof(*mpnt));
+
 	down_write(&mm->mmap_sem);
 	{
 		mpnt->vm_mm = mm;
@@ -363,11 +364,6 @@ int setup_arg_pages(struct linux_binprm 
 			mpnt->vm_flags = vm_stack_flags32;
  		mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC) ? 
  			PAGE_COPY_EXEC : PAGE_COPY;
-		mpnt->vm_ops = NULL;
-		mpnt->vm_pgoff = 0;
-		mpnt->vm_file = NULL;
-		mpol_set_vma_default(mpnt);
-		mpnt->vm_private_data = (void *) 0;
 		insert_vm_struct(mm, mpnt);
 		mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	} 
@@ -376,7 +372,7 @@ int setup_arg_pages(struct linux_binprm 
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			put_dirty_page(current,page,stack_base,mpnt->vm_page_prot);
+			install_arg_page(mpnt, page, stack_base);
 		}
 		stack_base += PAGE_SIZE;
 	}
diff -puN fs/exec.c~rmap-33-install_arg_page-vma fs/exec.c
--- 25/fs/exec.c~rmap-33-install_arg_page-vma	2004-05-22 14:56:29.220649312 -0700
+++ 25-akpm/fs/exec.c	2004-05-22 14:59:35.968259360 -0700
@@ -46,7 +46,6 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/rmap.h>
-#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
@@ -294,17 +293,19 @@ EXPORT_SYMBOL(copy_strings_kernel);
  * This routine is used to map in a page into an address space: needed by
  * execve() for the initial stack and environment pages.
  *
- * tsk->mm->mmap_sem is held for writing.
+ * vma->vm_mm->mmap_sem is held for writing.
  */
-void put_dirty_page(struct task_struct *tsk, struct page *page,
-			unsigned long address, pgprot_t prot)
+void install_arg_page(struct vm_area_struct *vma,
+			struct page *page, unsigned long address)
 {
-	struct mm_struct *mm = tsk->mm;
+	struct mm_struct *mm = vma->vm_mm;
 	pgd_t * pgd;
 	pmd_t * pmd;
 	pte_t * pte;
 
+	flush_dcache_page(page);
 	pgd = pgd_offset(mm, address);
+
 	spin_lock(&mm->page_table_lock);
 	pmd = pmd_alloc(mm, pgd, address);
 	if (!pmd)
@@ -318,8 +319,8 @@ void put_dirty_page(struct task_struct *
 	}
 	mm->rss++;
 	lru_cache_add_active(page);
-	flush_dcache_page(page);
-	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, prot))));
+	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(
+					page, vma->vm_page_prot))));
 	page_add_anon_rmap(page, mm, address);
 	pte_unmap(pte);
 	spin_unlock(&mm->page_table_lock);
@@ -329,7 +330,7 @@ void put_dirty_page(struct task_struct *
 out:
 	spin_unlock(&mm->page_table_lock);
 	__free_page(page);
-	force_sig(SIGKILL, tsk);
+	force_sig(SIGKILL, current);
 }
 
 int setup_arg_pages(struct linux_binprm *bprm, int executable_stack)
@@ -435,8 +436,7 @@ int setup_arg_pages(struct linux_binprm 
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			put_dirty_page(current, page, stack_base,
-					mpnt->vm_page_prot);
+			install_arg_page(mpnt, page, stack_base);
 		}
 		stack_base += PAGE_SIZE;
 	}
diff -puN include/linux/mm.h~rmap-33-install_arg_page-vma include/linux/mm.h
--- 25/include/linux/mm.h~rmap-33-install_arg_page-vma	2004-05-22 14:56:29.221649160 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:36.266214064 -0700
@@ -530,8 +530,7 @@ extern int install_file_pte(struct mm_st
 extern int handle_mm_fault(struct mm_struct *mm,struct vm_area_struct *vma, unsigned long address, int write_access);
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
-void put_dirty_page(struct task_struct *tsk, struct page *page,
-			unsigned long address, pgprot_t prot);
+void install_arg_page(struct vm_area_struct *, struct page *, unsigned long);
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
 		int len, int write, int force, struct page **pages, struct vm_area_struct **vmas);

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
