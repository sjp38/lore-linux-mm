Subject: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1183962981.5961.3.camel@localhost.localdomain>
References: <1183952874.3388.349.camel@localhost.localdomain>
	 <1183962981.5961.3.camel@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 09 Jul 2007 16:45:44 +1000
Message-Id: <1183963544.5961.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Use mmu_gather for fork() instead of flush_tlb_mm()

This patch uses an mmu_gather for copying page tables instead of
flush_tlb_mm(). This allows archs like ppc32 with hash table to
avoid walking the page tables a second time to invalidate hash
entries, and to only flush PTEs that have actually been changed
from RW to RO.

Note that this contain a small change to the mmu gather stuff,
it must not call free_pages_and_swap_cache() if no page have been
queued up for freeing (if we are only invalidating PTEs). Calling
it on fork can deadlock (I haven't dug why but it looks like a
good idea to test anyway if we're going to use the mmu_gather for
more than just removing pages).

If the patch gets accepted, I will split that bit from the rest
of the patch and send it separately.

The main possible issue I see is with huge pages. Arch code might
have relied on flush_tlb_mm() and might not cope with
tlb_remove_tlb_entry() called for huge PTEs.

Other possible issues are if archs make assumptions about
flush_tlb_mm() being called in fork for different unrelated reasons.

Ah also, we could probably improve the tracking of start/end, in
the case of lock breaking, the outside function will still finish
the batch with the entire range. It doesn't matter on ppc and x86
I think though.

Index: linux-work/include/linux/hugetlb.h
===================================================================
--- linux-work.orig/include/linux/hugetlb.h	2007-07-09 16:17:04.000000000 +1000
+++ linux-work/include/linux/hugetlb.h	2007-07-09 16:26:38.000000000 +1000
@@ -15,7 +15,7 @@ static inline int is_vm_hugetlb_page(str
 }
 
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
-int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
+int copy_hugetlb_page_range(struct mmu_gather **tlbp, struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int);
 void unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
 void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
@@ -107,7 +107,7 @@ static inline unsigned long hugetlb_tota
 
 #define follow_hugetlb_page(m,v,p,vs,a,b,i)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
-#define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
+#define copy_hugetlb_page_range(tlbp, src, dst, vma)	({ BUG(); 0; })
 #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
 #define unmap_hugepage_range(vma, start, end)	BUG()
 #define hugetlb_report_meminfo(buf)		0
Index: linux-work/include/linux/mm.h
===================================================================
--- linux-work.orig/include/linux/mm.h	2007-07-09 16:17:04.000000000 +1000
+++ linux-work/include/linux/mm.h	2007-07-09 16:26:38.000000000 +1000
@@ -748,8 +748,8 @@ void free_pgd_range(struct mmu_gather **
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
-int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma);
+int copy_page_range(struct mmu_gather **tlbp, struct mm_struct *dst,
+		    struct mm_struct *src, struct vm_area_struct *vma);
 int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
 			unsigned long size, pgprot_t prot);
 void unmap_mapping_range(struct address_space *mapping,
Index: linux-work/kernel/fork.c
===================================================================
--- linux-work.orig/kernel/fork.c	2007-07-09 16:17:04.000000000 +1000
+++ linux-work/kernel/fork.c	2007-07-09 16:26:38.000000000 +1000
@@ -56,6 +56,7 @@
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
+#include <asm/tlb.h>
 
 /*
  * Protected counters by write_lock_irq(&tasklist_lock)
@@ -199,8 +200,9 @@ static inline int dup_mmap(struct mm_str
 	struct vm_area_struct *mpnt, *tmp, **pprev;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
-	unsigned long charge;
+	unsigned long charge, tlb_start, tlb_end;
 	struct mempolicy *pol;
+	struct mmu_gather *tlb;
 
 	down_write(&oldmm->mmap_sem);
 	flush_cache_dup_mm(oldmm);
@@ -220,6 +222,10 @@ static inline int dup_mmap(struct mm_str
 	rb_link = &mm->mm_rb.rb_node;

 	rb_parent = NULL;
 	pprev = &mm->mmap;
+	tlb_start = -1;
+	tlb_end = 0;
+
+	tlb = tlb_gather_mmu(oldmm, 1);
 
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
@@ -242,6 +248,11 @@ static inline int dup_mmap(struct mm_str
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
+
+		if (unlikely(tlb_start == -1))
+			tlb_start = mpnt->vm_start;
+		tlb_end = mpnt->vm_end;
+
 		pol = mpol_copy(vma_policy(mpnt));
 		retval = PTR_ERR(pol);
 		if (IS_ERR(pol))
@@ -278,7 +289,7 @@ static inline int dup_mmap(struct mm_str
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(&tlb, mm, oldmm, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
@@ -291,12 +302,15 @@ static inline int dup_mmap(struct mm_str
 	retval = 0;
 out:
 	up_write(&mm->mmap_sem);
-	flush_tlb_mm(oldmm);
+	if (tlb && tlb_start < tlb_end)
+		tlb_finish_mmu(tlb, tlb_start, tlb_end);
 	up_write(&oldmm->mmap_sem);
 	return retval;
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
+	if (tlb && tlb_start < tlb_end)
+		tlb_finish_mmu(tlb, tlb_start, tlb_end);
 	retval = -ENOMEM;
 	vm_unacct_memory(charge);
 	goto out;
Index: linux-work/mm/hugetlb.c
===================================================================
--- linux-work.orig/mm/hugetlb.c	2007-07-09 16:17:04.000000000 +1000
+++ linux-work/mm/hugetlb.c	2007-07-09 16:26:38.000000000 +1000
@@ -333,8 +333,8 @@ static void set_huge_ptep_writable(struc
 }
 
 
-int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
-			    struct vm_area_struct *vma)
+int copy_hugetlb_page_range(struct mmu_gather **tlbp, struct mm_struct *dst,
+			    struct mm_struct *src, struct vm_area_struct *vma)
 {
 	pte_t *src_pte, *dst_pte, entry;
 	struct page *ptepage;
@@ -353,8 +353,10 @@ int copy_hugetlb_page_range(struct mm_st
 		spin_lock(&dst->page_table_lock);
 		spin_lock(&src->page_table_lock);
 		if (!pte_none(*src_pte)) {
-			if (cow)
+			if (cow) {
 				ptep_set_wrprotect(src, addr, src_pte);
+				tlb_remove_tlb_entry((*tlbp), src_pte, addr);
+			}
 			entry = *src_pte;
 			ptepage = pte_page(entry);
 			get_page(ptepage);
@@ -363,6 +365,7 @@ int copy_hugetlb_page_range(struct mm_st
 		spin_unlock(&src->page_table_lock);
 		spin_unlock(&dst->page_table_lock);
 	}
+
 	return 0;
 
 nomem:
Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-07-09 16:17:04.000000000 +1000
+++ linux-work/mm/memory.c	2007-07-09 16:34:54.000000000 +1000
@@ -425,9 +425,9 @@ struct page *vm_normal_page(struct vm_ar
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
@@ -466,8 +466,11 @@ copy_one_pte(struct mm_struct *dst_mm, s
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
@@ -489,13 +492,15 @@ out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
 }
 
-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+static int copy_pte_range(struct mmu_gather **tlbp,
+		struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end)
 {
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
-	int progress = 0;
+	unsigned long start_addr = addr;
+	int fullmm, progress = 0;
 	int rss[2];
 
 again:
@@ -524,7 +529,8 @@ again:
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		copy_one_pte(*tlbp, dst_mm, src_mm, dst_pte, src_pte,
+			     vma, addr, rss);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
@@ -533,13 +539,19 @@ again:
 	pte_unmap_nested(src_pte - 1);
 	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
+	fullmm = (*tlbp)->fullmm;
+	tlb_finish_mmu(*tlbp, start_addr, addr);
 	cond_resched();
-	if (addr != end)
+	if (addr != end) {
+		*tlbp = tlb_gather_mmu(src_mm, fullmm);
+		start_addr = addr;
 		goto again;
+	}
 	return 0;
 }
 
-static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+static inline int copy_pmd_range(struct mmu_gather **tlbp,
+		struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end)
 {
@@ -554,14 +566,15 @@ static inline int copy_pmd_range(struct 
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(src_pmd))
 			continue;
-		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
+		if (copy_pte_range(tlbp, dst_mm, src_mm, dst_pmd, src_pmd,
+				   vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+static inline int copy_pud_range(struct mmu_gather **tlbp,
+		struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end)
 {
@@ -576,15 +589,15 @@ static inline int copy_pud_range(struct 
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(src_pud))
 			continue;
-		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
+		if (copy_pmd_range(tlbp, dst_mm, src_mm, dst_pud, src_pud,
+				   vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pud++, src_pud++, addr = next, addr != end);
 	return 0;
 }
 
-int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		struct vm_area_struct *vma)
+int copy_page_range(struct mmu_gather **tlbp, struct mm_struct *dst_mm,
+		    struct mm_struct *src_mm, struct vm_area_struct *vma)
 {
 	pgd_t *src_pgd, *dst_pgd;
 	unsigned long next;
@@ -603,7 +616,7 @@ int copy_page_range(struct mm_struct *ds
 	}
 
 	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
+		return copy_hugetlb_page_range(tlbp, dst_mm, src_mm, vma);
 
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
@@ -611,8 +624,8 @@ int copy_page_range(struct mm_struct *ds
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
+		if (copy_pud_range(tlbp, dst_mm, src_mm, dst_pgd, src_pgd,
+				   vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 	return 0;
Index: linux-work/include/asm-generic/tlb.h
===================================================================
--- linux-work.orig/include/asm-generic/tlb.h	2007-07-09 16:17:04.000000000 +1000
+++ linux-work/include/asm-generic/tlb.h	2007-07-09 16:26:38.000000000 +1000
@@ -72,7 +72,7 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
 		return;
 	tlb->need_flush = 0;
 	tlb_flush(tlb);
-	if (!tlb_fast_mode(tlb)) {
+	if (!tlb_fast_mode(tlb) && tlb->nr) {
 		free_pages_and_swap_cache(tlb->pages, tlb->nr);
 		tlb->nr = 0;
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
