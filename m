Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B113C6B014C
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 09:07:41 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so1572259pdj.10
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 06:07:41 -0700 (PDT)
Received: from psmtp.com ([74.125.245.128])
        by mx.google.com with SMTP id gv2si899311pbb.41.2013.10.18.06.07.39
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 06:07:40 -0700 (PDT)
Received: by mail-we0-f173.google.com with SMTP id u57so3764444wes.32
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 06:07:37 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH 2/2] arm: mm: implement get_user_pages_fast
Date: Fri, 18 Oct 2013 14:07:13 +0100
Message-Id: <1382101634-4723-3-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1382101634-4723-1-git-send-email-steve.capper@linaro.org>
References: <1382101634-4723-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, Zi Shen Lim <zishen.lim@linaro.org>, patches@linaro.org, linaro-kernel@lists.linaro.org, Steve Capper <steve.capper@linaro.org>

An implementation of get_user_pages_fast for ARM. It is based loosely
on the PowerPC implementation, but has a few subtle differences.

Under other architectures, the get_user_pages_fast implementations
disable the IRQs in the critical section. This protects against pages
backing page tables from being freed and from THP splits occurring as
these both call TLB invalidations which trigger an IPI which blocks
until the IRQs are re-enabled in get_user_page_fast.

Under ARM, TLB invalidations are usually broadcast in hardware thus
obviating the need for an IPI. After some discussion with Will Deacon:
http://marc.info/?l=linux-mm&m=138089480306901&w=2
It was decided that atomics should be used to protect the critical
section in get_user_pages_fast.

Calls to get_user_pages_fast, cause an atomic, gup_readers, to be
incremented. This guarantees that pages backing page tables won't be
freed from under it as both pte_free and tlb_flush_mmu will block on
non-zero values of gup_readers. Also, this guarantees that THPs will
not split, as an implementation of pmdp_splitting_flush is provided
that also blocks on non-zero values of gup_readers.

Reported-by: Zi Shen Lim <zishen.lim@linaro.org>
Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/include/asm/mmu.h            |   1 +
 arch/arm/include/asm/pgalloc.h        |   9 ++
 arch/arm/include/asm/pgtable-2level.h |   1 +
 arch/arm/include/asm/pgtable-3level.h |  21 +++
 arch/arm/include/asm/pgtable.h        |  18 +++
 arch/arm/include/asm/tlb.h            |   8 ++
 arch/arm/mm/Makefile                  |   2 +-
 arch/arm/mm/gup.c                     | 234 ++++++++++++++++++++++++++++++++++
 8 files changed, 293 insertions(+), 1 deletion(-)
 create mode 100644 arch/arm/mm/gup.c

diff --git a/arch/arm/include/asm/mmu.h b/arch/arm/include/asm/mmu.h
index 6f18da0..8d22dda 100644
--- a/arch/arm/include/asm/mmu.h
+++ b/arch/arm/include/asm/mmu.h
@@ -11,6 +11,7 @@ typedef struct {
 #endif
 	unsigned int	vmalloc_seq;
 	unsigned long	sigpage;
+	atomic_t	gup_readers;
 } mm_context_t;
 
 #ifdef CONFIG_CPU_HAS_ASID
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 943504f..49f054c 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -123,6 +123,15 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
 	pgtable_page_dtor(pte);
+
+	/*
+	 * Before freeing page, check to see whether or not
+	 * __get_user_pages_fast is still walking pages in the mm.
+	 * If this is the case, wait until gup has finished.
+	 */
+	while (atomic_read(&mm->context.gup_readers) != 0)
+		cpu_relax();
+
 	__free_page(pte);
 }
 
diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index f97ee02..19a11a7 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -179,6 +179,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 /* we don't need complex calculations here as the pmd is folded into the pgd */
 #define pmd_addr_end(addr,end) (end)
 
+#define pmd_protnone(pmd)	(0)
 #define set_pte_ext(ptep,pte,ext) cpu_set_pte_ext(ptep,pte,ext)
 
 #endif /* __ASSEMBLY__ */
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 5689c18..46047f2 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -227,6 +227,7 @@ PMD_BIT_FUNC(mkyoung,   |= PMD_SECT_AF);
 #define pfn_pmd(pfn,prot)	(__pmd(((phys_addr_t)(pfn) << PAGE_SHIFT) | pgprot_val(prot)))
 #define mk_pmd(page,prot)	pfn_pmd(page_to_pfn(page),prot)
 
+#define pmd_protnone(pmd)	(pmd_val(pmd) & PMD_SECT_NONE)
 /* represent a notpresent pmd by zero, this is used by pmdp_invalidate */
 #define pmd_mknotpresent(pmd)	(__pmd(0))
 
@@ -256,6 +257,26 @@ static inline int has_transparent_hugepage(void)
 	return 1;
 }
 
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+static inline void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	pmd_t pmd = pmd_mksplitting(*pmdp);
+	VM_BUG_ON(address & ~PMD_MASK);
+	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
+
+	/*
+	 * Hold off until __get_user_pages_fast or arch_block_thp_splitting
+	 * have finished.
+	 *
+	 * The set_pmd_at above finishes with a dsb. This ensures that the
+	 * software splitting bit is observed by the critical section in
+	 * __get_user_pages_fast before we potentially start spinning below.
+	 */
+	while (atomic_read(&vma->vm_mm->context.gup_readers) != 0)
+		cpu_relax();
+}
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_PGTABLE_3LEVEL_H */
diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index be956db..f613620 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -220,6 +220,7 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
 #define pte_dirty(pte)		(pte_val(pte) & L_PTE_DIRTY)
 #define pte_young(pte)		(pte_val(pte) & L_PTE_YOUNG)
 #define pte_exec(pte)		(!(pte_val(pte) & L_PTE_XN))
+#define pte_protnone(pte)	(pte_val(pte) & L_PTE_NONE)
 #define pte_special(pte)	(0)
 
 #define pte_present_user(pte)  (pte_present(pte) && (pte_val(pte) & L_PTE_USER))
@@ -323,6 +324,23 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 
 #define pgtable_cache_init() do { } while (0)
 
+static inline void inc_gup_readers(struct mm_struct *mm)
+{
+	atomic_inc(&mm->context.gup_readers);
+	smp_mb__after_atomic_inc();
+}
+
+static inline void dec_gup_readers(struct mm_struct *mm)
+{
+	smp_mb__before_atomic_dec();
+	atomic_dec(&mm->context.gup_readers);
+}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define arch_block_thp_split(mm)	inc_gup_readers(mm)
+#define arch_unblock_thp_split(mm)	dec_gup_readers(mm)
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* CONFIG_MMU */
diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 0baf7f0..470ef9e 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -100,6 +100,14 @@ static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
+	/*
+	 * Before freeing pages, check to see whether or not
+	 * __get_user_pages_fast is still walking pages in the mm.
+	 * If this is the case, wait until gup has finished.
+	 */
+	while (atomic_read(&tlb->mm->context.gup_readers) != 0)
+		cpu_relax();
+
 	tlb_flush(tlb);
 	free_pages_and_swap_cache(tlb->pages, tlb->nr);
 	tlb->nr = 0;
diff --git a/arch/arm/mm/Makefile b/arch/arm/mm/Makefile
index ecfe6e5..45cc6d8 100644
--- a/arch/arm/mm/Makefile
+++ b/arch/arm/mm/Makefile
@@ -6,7 +6,7 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   iomap.o
 
 obj-$(CONFIG_MMU)		+= fault-armv.o flush.o idmap.o ioremap.o \
-				   mmap.o pgd.o mmu.o
+				   mmap.o pgd.o mmu.o gup.o
 
 ifneq ($(CONFIG_MMU),y)
 obj-y				+= nommu.o
diff --git a/arch/arm/mm/gup.c b/arch/arm/mm/gup.c
new file mode 100644
index 0000000..bff1f95
--- /dev/null
+++ b/arch/arm/mm/gup.c
@@ -0,0 +1,234 @@
+/*
+ * arch/arm/mm/gup.c
+ *
+ * Copyright (C) 2013 Linaro Ltd.
+ *
+ * Based on arch/powerpc/mm/gup.c which is:
+ * Copyright (C) 2008 Nick Piggin
+ * Copyright (C) 2008 Novell Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/rwsem.h>
+#include <linux/hugetlb.h>
+#include <asm/pgtable.h>
+
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	pte_t *ptep, *ptem;
+	int ret = 0;
+
+	ptem = ptep = pte_offset_map(&pmd, addr);
+	do {
+		pte_t pte = ACCESS_ONCE(*ptep);
+		struct page *page;
+
+		if (!pte_present_user(pte) || pte_protnone(pte)
+			|| (write && !pte_write(pte)))
+			goto pte_unmap;
+
+		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+		page = pte_page(pte);
+
+		if (!page_cache_get_speculative(page))
+			goto pte_unmap;
+
+		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+			put_page(page);
+			goto pte_unmap;
+		}
+
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (ptep++, addr += PAGE_SIZE, addr != end);
+
+	ret = 1;
+
+pte_unmap:
+	pte_unmap(ptem);
+	return ret;
+}
+
+static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	struct page *head, *page, *tail;
+	int refs;
+
+	if (!pmd_present(orig) || pmd_protnone(orig)
+		|| (write && !pmd_write(orig)))
+		return 0;
+
+	refs = 0;
+	head = pmd_page(orig);
+	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	tail = page;
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+
+	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+
+	/*
+	 * Tail pages have their _mapcount bumped, see
+	 * __get_page_tail_foll for more information.
+	 */
+	while (refs--) {
+		if (PageTail(tail))
+			get_huge_page_tail(tail);
+		tail++;
+	}
+
+	return 1;
+}
+
+static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pmd_t *pmdp;
+
+	pmdp = pmd_offset(&pud, addr);
+	do {
+		pmd_t pmd = ACCESS_ONCE(*pmdp);
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+			return 0;
+
+		if (unlikely(pmd_huge(pmd) || pmd_trans_huge(pmd))) {
+			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
+				pages, nr))
+				return 0;
+		} else {
+			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+				return 0;
+		}
+	} while (pmdp++, addr = next, addr != end);
+
+	return 1;
+}
+
+static int gup_pud_range(pgd_t *pgdp, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pud_t *pudp;
+
+	pudp = pud_offset(pgdp, addr);
+	do {
+		pud_t pud = ACCESS_ONCE(*pudp);
+		next = pud_addr_end(addr, end);
+		if (pud_none(pud))
+			return 0;
+		else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
+			return 0;
+	} while (pudp++, addr = next, addr != end);
+
+	return 1;
+}
+
+/*
+ * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
+ * back to the regular GUP.
+ */
+int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			  struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long addr, len, end;
+	unsigned long next;
+	pgd_t *pgdp;
+	int nr = 0;
+
+	start &= PAGE_MASK;
+	addr = start;
+	len = (unsigned long) nr_pages << PAGE_SHIFT;
+	end = start + len;
+
+	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
+					start, len)))
+		return 0;
+
+	/*
+	 * A non-zero gup_readers value will block page table pages
+	 * from being freed and also block THP splitting.
+	 * This allows us to walk the page tables and pin pages.
+	 */
+	inc_gup_readers(mm);
+
+	pgdp = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(*pgdp))
+			break;
+		else if (!gup_pud_range(pgdp, addr, next, write, pages, &nr))
+			break;
+	} while (pgdp++, addr = next, addr != end);
+
+	dec_gup_readers(mm);
+
+	return nr;
+}
+
+int get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	int nr, ret;
+
+	start &= PAGE_MASK;
+	nr = __get_user_pages_fast(start, nr_pages, write, pages);
+	ret = nr;
+
+	if (nr < nr_pages) {
+		/* Try to get the remaining pages with get_user_pages */
+		start += nr << PAGE_SHIFT;
+		pages += nr;
+
+		down_read(&mm->mmap_sem);
+		ret = get_user_pages(current, mm, start,
+				     nr_pages - nr, write, 0, pages, NULL);
+		up_read(&mm->mmap_sem);
+
+		/* Have to be a bit careful with return values */
+		if (nr > 0) {
+			if (ret < 0)
+				ret = nr;
+			else
+				ret += nr;
+		}
+	}
+
+	return ret;
+}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
