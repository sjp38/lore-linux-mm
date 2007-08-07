From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:53 +1000
Subject: [RFC/PATCH 11/12] Use mmu_gather for fork() instead of flush_tlb_mm()
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807072000.2E5D9DDE09@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch uses an mmu_gather for copying page tables instead of
flush_tlb_mm(). This allows archs like ppc32 with hash table to
avoid walking the page tables a second time to invalidate hash
entries, and to only flush PTEs that have actually been changed
from RW to RO.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 include/linux/hugetlb.h |    4 ++--
 include/linux/mm.h      |    4 ++--
 kernel/fork.c           |   10 ++++++++--
 mm/hugetlb.c            |   11 ++++++++---
 mm/memory.c             |   45 ++++++++++++++++++++++++++++-----------------
 5 files changed, 48 insertions(+), 26 deletions(-)

Index: linux-work/include/linux/hugetlb.h
===================================================================
--- linux-work.orig/include/linux/hugetlb.h	2007-08-07 16:23:53.000000000 +1000
+++ linux-work/include/linux/hugetlb.h	2007-08-07 16:51:37.000000000 +1000
@@ -18,7 +18,7 @@ static inline int is_vm_hugetlb_page(str
 
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
-int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
+int copy_hugetlb_page_range(struct mmu_gather *tlb, struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int);
 void unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
 void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
@@ -111,7 +111,7 @@ static inline unsigned long hugetlb_tota
 
 #define follow_hugetlb_page(m,v,p,vs,a,b,i)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
-#define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
+#define copy_hugetlb_page_range(tlb, src, dst, vma)	({ BUG(); 0; })
 #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
 #define unmap_hugepage_range(vma, start, end)	BUG()
 #define hugetlb_report_meminfo(buf)		0
Index: linux-work/include/linux/mm.h
===================================================================
--- linux-work.orig/include/linux/mm.h	2007-08-07 16:23:53.000000000 +1000
+++ linux-work/include/linux/mm.h	2007-08-07 16:48:03.000000000 +1000
@@ -777,8 +777,8 @@ void free_pgd_range(struct mmu_gather *t
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
-int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma);
+int copy_page_range(struct mmu_gather *tlb, struct mm_struct *dst,
+		    struct mm_struct *src, struct vm_area_struct *vma);
 int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
 			unsigned long size, pgprot_t prot);
 void unmap_mapping_range(struct address_space *mapping,
Index: linux-work/kernel/fork.c
===================================================================
--- linux-work.orig/kernel/fork.c	2007-08-07 16:07:08.000000000 +1000
+++ linux-work/kernel/fork.c	2007-08-07 16:52:32.000000000 +1000
@@ -57,6 +57,7 @@
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
+#include <asm/tlb.h>
 
 /*
  * Protected counters by write_lock_irq(&tasklist_lock)
@@ -202,6 +203,7 @@ static inline int dup_mmap(struct mm_str
 	int retval;
 	unsigned long charge;
 	struct mempolicy *pol;
+	struct mmu_gather tlb;
 
 	down_write(&oldmm->mmap_sem);
 	flush_cache_dup_mm(oldmm);
@@ -222,6 +224,8 @@ static inline int dup_mmap(struct mm_str
 	rb_parent = NULL;
 	pprev = &mm->mmap;
 
+	tlb_gather_mmu(&tlb, oldmm);
+
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
 
@@ -243,6 +247,7 @@ static inline int dup_mmap(struct mm_str
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
+
 		pol = mpol_copy(vma_policy(mpnt));
 		retval = PTR_ERR(pol);
 		if (IS_ERR(pol))
@@ -279,7 +284,7 @@ static inline int dup_mmap(struct mm_str
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(&tlb, mm, oldmm, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
@@ -292,12 +297,13 @@ static inline int dup_mmap(struct mm_str
 	retval = 0;
 out:
 	up_write(&mm->mmap_sem);
-	flush_tlb_mm(oldmm);
+	tlb_finish_mmu(&tlb);
 	up_write(&oldmm->mmap_sem);
 	return retval;
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
+	tlb_finish_mmu(&tlb);
 	retval = -ENOMEM;
 	vm_unacct_memory(charge);
 	goto out;
Index: linux-work/mm/hugetlb.c
===================================================================
--- linux-work.orig/mm/hugetlb.c	2007-08-06 13:48:31.000000000 +1000
+++ linux-work/mm/hugetlb.c	2007-08-07 16:53:49.000000000 +1000
@@ -17,6 +17,8 @@
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
+#include <asm/tlbflush.h>
+#include <asm/tlb.h>
 
 #include <linux/hugetlb.h>
 #include "internal.h"
@@ -358,8 +360,8 @@ static void set_huge_ptep_writable(struc
 }
 
 
-int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
-			    struct vm_area_struct *vma)
+int copy_hugetlb_page_range(struct mmu_gather *tlb, struct mm_struct *dst,
+			    struct mm_struct *src, struct vm_area_struct *vma)
 {
 	pte_t *src_pte, *dst_pte, entry;
 	struct page *ptepage;
@@ -378,8 +380,10 @@ int copy_hugetlb_page_range(struct mm_st
 		spin_lock(&dst->page_table_lock);
 		spin_lock(&src->page_table_lock);
 		if (!pte_none(*src_pte)) {
-			if (cow)
+			if (cow) {
 				ptep_set_wrprotect(src, addr, src_pte);
+				tlb_remove_tlb_entry(tlb, src_pte, addr);
+			}
 			entry = *src_pte;
 			ptepage = pte_page(entry);
 			get_page(ptepage);
@@ -388,6 +392,7 @@ int copy_hugetlb_page_range(struct mm_st
 		spin_unlock(&src->page_table_lock);
 		spin_unlock(&dst->page_table_lock);
 	}
+
 	return 0;
 
 nomem:
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-08-07 16:27:30.000000000 +1000
+++ linux-work/mm/memory.c	2007-08-07 16:50:03.000000000 +1000
@@ -430,9 +430,9 @@ struct page *vm_normal_page(struct vm_ar
  */
 
 static inline void
-copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
-		unsigned long addr, int *rss)
+copy_one_pte(struct mmu_gather *tlb, struct mm_struct *dst_mm,
+	     struct mm_struct *src_mm, pte_t *dst_pte, pte_t *src_pte,
+	     struct vm_area_struct *vma, unsigned long addr, int *rss)
 {
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
@@ -471,8 +471,11 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	 * in the parent and the child
 	 */
 	if (is_cow_mapping(vm_flags)) {
+		pte_t old = *src_pte;
 		ptep_set_wrprotect(src_mm, addr, src_pte);
 		pte = pte_wrprotect(pte);
+		if (tlb && !pte_same(old, *src_pte))
+			tlb_remove_tlb_entry(tlb, src_pte, addr);
 	}
 
 	/*
@@ -494,12 +497,14 @@ out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
 }
 
-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+static int copy_pte_range(struct mmu_gather *tlb,
+		struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end)
 {
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
+	unsigned long start_addr = addr;
 	int progress = 0;
 	int rss[2];
 
@@ -529,22 +534,27 @@ again:
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		copy_one_pte(tlb, dst_mm, src_mm, dst_pte, src_pte,
+			     vma, addr, rss);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
 	arch_leave_lazy_mmu_mode();
+	tlb_pte_lock_break(tlb);
 	spin_unlock(src_ptl);
 	pte_unmap_nested(src_pte - 1);
 	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
 	cond_resched();
-	if (addr != end)
+	if (addr != end) {
+		start_addr = addr;
 		goto again;
+	}
 	return 0;
 }
 
-static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+static inline int copy_pmd_range(struct mmu_gather *tlb,
+		struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end)
 {
@@ -559,14 +569,15 @@ static inline int copy_pmd_range(struct 
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(src_pmd))
 			continue;
-		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
+		if (copy_pte_range(tlb, dst_mm, src_mm, dst_pmd, src_pmd,
+				   vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+static inline int copy_pud_range(struct mmu_gather *tlb,
+		struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end)
 {
@@ -581,15 +592,15 @@ static inline int copy_pud_range(struct 
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(src_pud))
 			continue;
-		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
+		if (copy_pmd_range(tlb, dst_mm, src_mm, dst_pud, src_pud,
+				   vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pud++, src_pud++, addr = next, addr != end);
 	return 0;
 }
 
-int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		struct vm_area_struct *vma)
+int copy_page_range(struct mmu_gather *tlb, struct mm_struct *dst_mm,
+		    struct mm_struct *src_mm, struct vm_area_struct *vma)
 {
 	pgd_t *src_pgd, *dst_pgd;
 	unsigned long next;
@@ -608,7 +619,7 @@ int copy_page_range(struct mm_struct *ds
 	}
 
 	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
+		return copy_hugetlb_page_range(tlb, dst_mm, src_mm, vma);
 
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
@@ -616,8 +627,8 @@ int copy_page_range(struct mm_struct *ds
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
+		if (copy_pud_range(tlb, dst_mm, src_mm, dst_pgd, src_pgd,
+				   vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
