Date: Mon, 22 Aug 2005 22:29:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [RFT][PATCH 1/2] pagefault scalability alternative
In-Reply-To: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.61.0508222227590.22924@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

First remove Christoph's pagefault scalability from 2.6.13-rc6-mm1...

--- 26136m1/arch/i386/Kconfig	2005-08-19 14:30:02.000000000 +0100
+++ 26136m1-/arch/i386/Kconfig	2005-08-20 16:44:38.000000000 +0100
@@ -909,11 +909,6 @@ config HAVE_DEC_LOCK
 	depends on (SMP || PREEMPT) && X86_CMPXCHG
 	default y
 
-config ATOMIC_TABLE_OPS
-	bool
-	depends on SMP && X86_CMPXCHG && !X86_PAE
-	default y
-
 # turning this on wastes a bunch of space.
 # Summit needs it only when NUMA is on
 config BOOT_IOREMAP
--- 26136m1/arch/ia64/Kconfig	2005-08-19 14:30:02.000000000 +0100
+++ 26136m1-/arch/ia64/Kconfig	2005-08-20 16:44:38.000000000 +0100
@@ -297,11 +297,6 @@ config PREEMPT
 
 source "mm/Kconfig"
 
-config ATOMIC_TABLE_OPS
-	bool
-	depends on SMP
-	default y
-
 config HAVE_DEC_LOCK
 	bool
 	depends on (SMP || PREEMPT)
--- 26136m1/arch/x86_64/Kconfig	2005-08-19 14:30:04.000000000 +0100
+++ 26136m1-/arch/x86_64/Kconfig	2005-08-20 16:44:38.000000000 +0100
@@ -221,11 +221,6 @@ config SCHED_SMT
 	  cost of slightly increased overhead in some places. If unsure say
 	  N here.
 
-config ATOMIC_TABLE_OPS
-	bool
-	  depends on SMP
-	  default y
-
 source "kernel/Kconfig.preempt"
 
 config K8_NUMA
--- 26136m1/include/asm-generic/4level-fixup.h	2005-08-19 14:30:11.000000000 +0100
+++ 26136m1-/include/asm-generic/4level-fixup.h	2005-08-20 16:44:38.000000000 +0100
@@ -26,7 +26,6 @@
 #define pud_present(pud)		1
 #define pud_ERROR(pud)			do { } while (0)
 #define pud_clear(pud)			pgd_clear(pud)
-#define pud_populate			pgd_populate
 
 #undef pud_free_tlb
 #define pud_free_tlb(tlb, x)            do { } while (0)
--- 26136m1/include/asm-generic/pgtable-nopmd.h	2005-08-19 14:30:11.000000000 +0100
+++ 26136m1-/include/asm-generic/pgtable-nopmd.h	2005-08-20 16:44:38.000000000 +0100
@@ -31,11 +31,6 @@ static inline void pud_clear(pud_t *pud)
 #define pmd_ERROR(pmd)				(pud_ERROR((pmd).pud))
 
 #define pud_populate(mm, pmd, pte)		do { } while (0)
-#define __ARCH_HAVE_PUD_TEST_AND_POPULATE
-static inline int pud_test_and_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
-{
-	return 1;
-}
 
 /*
  * (pmds are folded into puds so this doesn't get actually called,
--- 26136m1/include/asm-generic/pgtable-nopud.h	2005-08-19 14:30:11.000000000 +0100
+++ 26136m1-/include/asm-generic/pgtable-nopud.h	2005-08-20 16:44:38.000000000 +0100
@@ -27,14 +27,8 @@ static inline int pgd_bad(pgd_t pgd)		{ 
 static inline int pgd_present(pgd_t pgd)	{ return 1; }
 static inline void pgd_clear(pgd_t *pgd)	{ }
 #define pud_ERROR(pud)				(pgd_ERROR((pud).pgd))
-#define pgd_populate(mm, pgd, pud)		do { } while (0)
-
-#define __HAVE_ARCH_PGD_TEST_AND_POPULATE
-static inline int pgd_test_and_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
-{
-	return 1;
-}
 
+#define pgd_populate(mm, pgd, pud)		do { } while (0)
 /*
  * (puds are folded into pgds so this doesn't get actually called,
  * but the define is needed for a generic inline function.)
--- 26136m1/include/asm-generic/pgtable.h	2005-08-19 14:30:11.000000000 +0100
+++ 26136m1-/include/asm-generic/pgtable.h	2005-08-20 16:44:38.000000000 +0100
@@ -127,191 +127,6 @@ do {									\
 })
 #endif
 
-#ifdef CONFIG_ATOMIC_TABLE_OPS
-
-/*
- * The architecture does support atomic table operations.
- * We may be able to provide atomic ptep_xchg and ptep_cmpxchg using
- * cmpxchg and xchg.
- */
-#ifndef __HAVE_ARCH_PTEP_XCHG
-#define ptep_xchg(__mm, __address, __ptep, __pteval) \
-	__pte(xchg(&pte_val(*(__ptep)), pte_val(__pteval)))
-#endif
-
-#ifndef __HAVE_ARCH_PTEP_CMPXCHG
-#define ptep_cmpxchg(__mm, __address, __ptep,__oldval,__newval)		\
-	(cmpxchg(&pte_val(*(__ptep)),					\
-			pte_val(__oldval),				\
-			pte_val(__newval)				\
-		) == pte_val(__oldval)					\
-	)
-#endif
-
-#ifndef __HAVE_ARCH_PTEP_XCHG_FLUSH
-#define ptep_xchg_flush(__vma, __address, __ptep, __pteval)		\
-({									\
-	pte_t __pte = ptep_xchg(__vma, __address, __ptep, __pteval);	\
-	flush_tlb_page(__vma, __address);				\
-	__pte;								\
-})
-#endif
-
-/*
- * page_table_atomic_start and page_table_atomic_stop may be used to
- * define special measures that an arch needs to guarantee atomic
- * operations outside of a spinlock. In the case that an arch does
- * not support atomic page table operations we will fall back to the
- * page table lock.
- */
-#ifndef __HAVE_ARCH_PAGE_TABLE_ATOMIC_START
-#define page_table_atomic_start(mm) do { } while (0)
-#endif
-
-#ifndef __HAVE_ARCH_PAGE_TABLE_ATOMIC_START
-#define page_table_atomic_stop(mm) do { } while (0)
-#endif
-
-/*
- * Fallback functions for atomic population of higher page table
- * structures. These simply acquire the page_table_lock for
- * synchronization. An architecture may override these generic
- * functions to provide atomic populate functions to make these
- * more effective.
- */
-
-#ifndef __HAVE_ARCH_PGD_TEST_AND_POPULATE
-#define pgd_test_and_populate(__mm, __pgd, __pud)			\
-({									\
-	int __rc;							\
-	spin_lock(&mm->page_table_lock);				\
-	__rc = pgd_none(*(__pgd));					\
-	if (__rc) pgd_populate(__mm, __pgd, __pud);			\
-	spin_unlock(&mm->page_table_lock);				\
-	__rc;								\
-})
-#endif
-
-#ifndef __HAVE_ARCH_PUD_TEST_AND_POPULATE
-#define pud_test_and_populate(__mm, __pud, __pmd)			\
-({									\
-	int __rc;							\
-	spin_lock(&mm->page_table_lock);				\
-	__rc = pud_none(*(__pud));					\
-	if (__rc) pud_populate(__mm, __pud, __pmd);			\
-	spin_unlock(&mm->page_table_lock);				\
-	__rc;								\
-})
-#endif
-
-#ifndef __HAVE_ARCH_PMD_TEST_AND_POPULATE
-#define pmd_test_and_populate(__mm, __pmd, __page)			\
-({									\
-	int __rc;							\
-	spin_lock(&mm->page_table_lock);				\
-	__rc = !pmd_present(*(__pmd));					\
-	if (__rc) pmd_populate(__mm, __pmd, __page);			\
-	spin_unlock(&mm->page_table_lock);				\
-	__rc;								\
-})
-#endif
-
-#else
-
-/*
- * No support for atomic operations on the page table.
- * Exchanging of pte values is done by first swapping zeros into
- * a pte and then putting new content into the pte entry.
- * However, these functions will generate an empty pte for a
- * short time frame. This means that the page_table_lock must be held
- * to avoid a page fault that would install a new entry.
- */
-
-/* Fall back to the page table lock to synchronize page table access */
-#define page_table_atomic_start(mm)	spin_lock(&(mm)->page_table_lock)
-#define page_table_atomic_stop(mm)	spin_unlock(&(mm)->page_table_lock)
-
-#ifndef __HAVE_ARCH_PTEP_XCHG
-#define ptep_xchg(__mm, __address, __ptep, __pteval)			\
-({									\
-	pte_t __pte = ptep_get_and_clear(__mm, __address, __ptep);	\
-	set_pte_at(__mm, __address, __ptep, __pteval);			\
-	__pte;								\
-})
-#endif
-
-#ifndef __HAVE_ARCH_PTEP_XCHG_FLUSH
-#ifndef __HAVE_ARCH_PTEP_XCHG
-#define ptep_xchg_flush(__vma, __address, __ptep, __pteval)		\
-({									\
-	pte_t __pte = ptep_clear_flush(__vma, __address, __ptep);	\
-	set_pte_at((__vma)->vm_mm, __address, __ptep, __pteval);		\
-	__pte;								\
-})
-#else
-#define ptep_xchg_flush(__vma, __address, __ptep, __pteval)		\
-({									\
-	pte_t __pte = ptep_xchg((__vma)->vm_mm, __address, __ptep, __pteval);\
-	flush_tlb_page(__vma, __address);				\
-	__pte;								\
-})
-#endif
-#endif
-
-/*
- * The fallback function for ptep_cmpxchg avoids any real use of cmpxchg
- * since cmpxchg may not be available on certain architectures. Instead
- * the clearing of a pte is used as a form of locking mechanism.
- * This approach will only work if the page_table_lock is held to insure
- * that the pte is not populated by a page fault generated on another
- * CPU.
- */
-#ifndef __HAVE_ARCH_PTEP_CMPXCHG
-#define ptep_cmpxchg(__mm, __address, __ptep, __old, __new)		\
-({									\
-	pte_t prev = ptep_get_and_clear(__mm, __address, __ptep);	\
-	int r = pte_val(prev) == pte_val(__old);			\
-	set_pte_at(__mm, __address, __ptep, r ? (__new) : prev);	\
-	r;								\
-})
-#endif
-
-/*
- * Fallback functions for atomic population of higher page table
- * structures. These rely on the page_table_lock being held.
- */
-#ifndef __HAVE_ARCH_PGD_TEST_AND_POPULATE
-#define pgd_test_and_populate(__mm, __pgd, __pud)			\
-({									\
-	int __rc;							\
-	__rc = pgd_none(*(__pgd));					\
-	if (__rc) pgd_populate(__mm, __pgd, __pud);			\
-	__rc;								\
-})
-#endif
-
-#ifndef __HAVE_ARCH_PUD_TEST_AND_POPULATE
-#define pud_test_and_populate(__mm, __pud, __pmd)			\
-({									\
-       int __rc;							\
-       __rc = pud_none(*(__pud));					\
-       if (__rc) pud_populate(__mm, __pud, __pmd);			\
-       __rc;								\
-})
-#endif
-
-#ifndef __HAVE_ARCH_PMD_TEST_AND_POPULATE
-#define pmd_test_and_populate(__mm, __pmd, __page)			\
-({									\
-       int __rc;							\
-       __rc = !pmd_present(*(__pmd));					\
-       if (__rc) pmd_populate(__mm, __pmd, __page);			\
-       __rc;								\
-})
-#endif
-
-#endif
-
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define ptep_set_wrprotect(__mm, __address, __ptep)			\
 ({									\
--- 26136m1/include/asm-ia64/pgalloc.h	2005-08-19 14:30:12.000000000 +0100
+++ 26136m1-/include/asm-ia64/pgalloc.h	2005-08-20 16:44:38.000000000 +0100
@@ -1,10 +1,6 @@
 #ifndef _ASM_IA64_PGALLOC_H
 #define _ASM_IA64_PGALLOC_H
 
-/* Empty entries of PMD and PGD */
-#define PMD_NONE       0
-#define PUD_NONE       0
-
 /*
  * This file contains the functions and defines necessary to allocate
  * page tables.
@@ -90,21 +86,6 @@ static inline void pgd_free(pgd_t * pgd)
 	pgtable_quicklist_free(pgd);
 }
 
-/* Atomic populate */
-static inline int
-pud_test_and_populate (struct mm_struct *mm, pud_t *pud_entry, pmd_t *pmd)
-{
-	return ia64_cmpxchg8_acq(pud_entry,__pa(pmd), PUD_NONE) == PUD_NONE;
-}
-
-/* Atomic populate */
-static inline int
-pmd_test_and_populate (struct mm_struct *mm, pmd_t *pmd_entry, struct page *pte)
-{
-	return ia64_cmpxchg8_acq(pmd_entry, page_to_phys(pte), PMD_NONE) == PMD_NONE;
-}
-
-
 static inline void
 pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
 {
--- 26136m1/include/asm-ia64/pgtable.h	2005-08-19 14:30:12.000000000 +0100
+++ 26136m1-/include/asm-ia64/pgtable.h	2005-08-20 16:44:38.000000000 +0100
@@ -565,8 +565,6 @@ do {											\
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
-#define __HAVE_ARCH_PUD_TEST_AND_POPULATE
-#define __HAVE_ARCH_PMD_TEST_AND_POPULATE
 
 #include <asm-generic/pgtable-nopud.h>
 #include <asm-generic/pgtable.h>
--- 26136m1/include/linux/page-flags.h	2005-08-19 14:30:13.000000000 +0100
+++ 26136m1-/include/linux/page-flags.h	2005-08-20 16:44:38.000000000 +0100
@@ -132,12 +132,6 @@ struct page_state {
 
 	unsigned long pgrotated;	/* pages rotated to tail of the LRU */
 	unsigned long nr_bounce;	/* pages for bounce buffers */
-	unsigned long spurious_page_faults;	/* Faults with no ops */
-	unsigned long cmpxchg_fail_flag_update;	/* cmpxchg failures for pte flag update */
-	unsigned long cmpxchg_fail_flag_reuse;	/* cmpxchg failures when cow reuse of pte */
-
-	unsigned long cmpxchg_fail_anon_read;	/* cmpxchg failures on anonymous read */
-	unsigned long cmpxchg_fail_anon_write;	/* cmpxchg failures on anonymous write */
 };
 
 extern void get_page_state(struct page_state *ret);
--- 26136m1/include/linux/sched.h	2005-08-19 14:30:13.000000000 +0100
+++ 26136m1-/include/linux/sched.h	2005-08-20 16:44:38.000000000 +0100
@@ -227,43 +227,12 @@ arch_get_unmapped_area_topdown(struct fi
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 
-#ifdef CONFIG_ATOMIC_TABLE_OPS
-/*
- * No spinlock is held during atomic page table operations. The
- * counters are not protected anymore and must also be
- * incremented atomically.
-*/
-#ifdef ATOMIC64_INIT
-#define set_mm_counter(mm, member, value) atomic64_set(&(mm)->_##member, value)
-#define get_mm_counter(mm, member) ((unsigned long)atomic64_read(&(mm)->_##member))
-#define add_mm_counter(mm, member, value) atomic64_add(value, &(mm)->_##member)
-#define inc_mm_counter(mm, member) atomic64_inc(&(mm)->_##member)
-#define dec_mm_counter(mm, member) atomic64_dec(&(mm)->_##member)
-typedef atomic64_t mm_counter_t;
-#else
-/*
- * This may limit process memory to 2^31 * PAGE_SIZE which may be around 8TB
- * if using 4KB page size
- */
-#define set_mm_counter(mm, member, value) atomic_set(&(mm)->_##member, value)
-#define get_mm_counter(mm, member) ((unsigned long)atomic_read(&(mm)->_##member))
-#define add_mm_counter(mm, member, value) atomic_add(value, &(mm)->_##member)
-#define inc_mm_counter(mm, member) atomic_inc(&(mm)->_##member)
-#define dec_mm_counter(mm, member) atomic_dec(&(mm)->_##member)
-typedef atomic_t mm_counter_t;
-#endif
-#else
-/*
- * No atomic page table operations. Counters are protected by
- * the page table lock
- */
 #define set_mm_counter(mm, member, value) (mm)->_##member = (value)
 #define get_mm_counter(mm, member) ((mm)->_##member)
 #define add_mm_counter(mm, member, value) (mm)->_##member += (value)
 #define inc_mm_counter(mm, member) (mm)->_##member++
 #define dec_mm_counter(mm, member) (mm)->_##member--
 typedef unsigned long mm_counter_t;
-#endif
 
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
--- 26136m1/mm/memory.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1-/mm/memory.c	2005-08-20 16:54:41.000000000 +0100
@@ -36,8 +36,6 @@
  *		(Gerhard.Wichert@pdb.siemens.de)
  *
  * Aug/Sep 2004 Changed to four level page tables (Andi Kleen)
- * Jan 2005 	Scalability improvement by reducing the use and the length of time
- *		the page table lock is held (Christoph Lameter)
  */
 
 #include <linux/kernel_stat.h>
@@ -553,22 +551,16 @@ static void zap_pte_range(struct mmu_gat
 				     page->index > details->last_index))
 					continue;
 			}
-			if (unlikely(!page)) {
-				ptent = ptep_get_and_clear_full(tlb->mm, addr,
+			ptent = ptep_get_and_clear_full(tlb->mm, addr,
 							pte, tlb->fullmm);
-				tlb_remove_tlb_entry(tlb, pte, addr);
-				continue;
-			}
-			if (unlikely(details) && details->nonlinear_vma &&
-				linear_page_index(details->nonlinear_vma,
-						addr) != page->index) {
-				ptent = ptep_xchg(tlb->mm, addr, pte,
-						  pgoff_to_pte(page->index));
-			} else {
-				ptent = ptep_get_and_clear_full(tlb->mm, addr,
-							pte, tlb->fullmm);
-			}
 			tlb_remove_tlb_entry(tlb, pte, addr);
+			if (unlikely(!page))
+				continue;
+			if (unlikely(details) && details->nonlinear_vma
+			    && linear_page_index(details->nonlinear_vma,
+						addr) != page->index)
+				set_pte_at(tlb->mm, addr, pte,
+					   pgoff_to_pte(page->index));
 			if (pte_dirty(ptent))
 				set_page_dirty(page);
 			if (PageAnon(page))
@@ -982,7 +974,7 @@ int get_user_pages(struct task_struct *t
 				 */
 				if (ret & VM_FAULT_WRITE)
 					write_access = 0;
-
+				
 				switch (ret & ~VM_FAULT_WRITE) {
 				case VM_FAULT_MINOR:
 					tsk->min_flt++;
@@ -1651,7 +1643,8 @@ void swapin_readahead(swp_entry_t entry,
 }
 
 /*
- * We hold the mm semaphore and have started atomic pte operations
+ * We hold the mm semaphore and the page_table_lock on entry and
+ * should release the pagetable lock on exit..
  */
 static int do_swap_page(struct mm_struct * mm,
 	struct vm_area_struct * vma, unsigned long address,
@@ -1663,14 +1656,15 @@ static int do_swap_page(struct mm_struct
 	int ret = VM_FAULT_MINOR;
 
 	pte_unmap(page_table);
-	page_table_atomic_stop(mm);
+	spin_unlock(&mm->page_table_lock);
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
  		page = read_swap_cache_async(entry, vma, address);
 		if (!page) {
 			/*
-			 * Back out if somebody else faulted in this pte
+			 * Back out if somebody else faulted in this pte while
+			 * we released the page table lock.
 			 */
 			spin_lock(&mm->page_table_lock);
 			page_table = pte_offset_map(pmd, address);
@@ -1693,7 +1687,8 @@ static int do_swap_page(struct mm_struct
 	lock_page(page);
 
 	/*
-	 * Back out if somebody else faulted in this pte
+	 * Back out if somebody else faulted in this pte while we
+	 * released the page table lock.
 	 */
 	spin_lock(&mm->page_table_lock);
 	page_table = pte_offset_map(pmd, address);
@@ -1748,75 +1743,61 @@ out_nomap:
 }
 
 /*
- * We are called with atomic operations started and the
- * value of the pte that was read in orig_entry.
+ * We are called with the MM semaphore and page_table_lock
+ * spinlock held to protect against concurrent faults in
+ * multithreaded programs. 
  */
 static int
 do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_t *page_table, pmd_t *pmd, int write_access,
-		unsigned long addr, pte_t orig_entry)
+		unsigned long addr)
 {
 	pte_t entry;
-	struct page * page;
+	struct page * page = ZERO_PAGE(addr);
 
-	if (unlikely(!write_access)) {
+	/* Read-only mapping of ZERO_PAGE. */
+	entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
 
-		/* Read-only mapping of ZERO_PAGE. */
-		entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr),
-					vma->vm_page_prot));
+	/* ..except if it's a write access */
+	if (write_access) {
+		/* Allocate our own private page. */
+		pte_unmap(page_table);
+		spin_unlock(&mm->page_table_lock);
 
-		/*
-		 * If the cmpxchg fails then another cpu may
-		 * already have populated the entry
-		 */
-		if (ptep_cmpxchg(mm, addr, page_table, orig_entry, entry)) {
-			update_mmu_cache(vma, addr, entry);
-			lazy_mmu_prot_update(entry);
-		} else {
-			inc_page_state(cmpxchg_fail_anon_read);
+		if (unlikely(anon_vma_prepare(vma)))
+			goto no_mem;
+		page = alloc_zeroed_user_highpage(vma, addr);
+		if (!page)
+			goto no_mem;
+
+		spin_lock(&mm->page_table_lock);
+		page_table = pte_offset_map(pmd, addr);
+
+		if (!pte_none(*page_table)) {
+			pte_unmap(page_table);
+			page_cache_release(page);
+			spin_unlock(&mm->page_table_lock);
+			goto out;
 		}
-		goto minor_fault;
+		inc_mm_counter(mm, rss);
+		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
+							 vma->vm_page_prot)),
+				      vma);
+		lru_cache_add_active(page);
+		SetPageReferenced(page);
+		page_add_anon_rmap(page, vma, addr);
 	}
 
-	/* This leaves the write case */
-	page_table_atomic_stop(mm);
+	set_pte_at(mm, addr, page_table, entry);
 	pte_unmap(page_table);
-	if (unlikely(anon_vma_prepare(vma)))
-		goto oom;
 
-	page = alloc_zeroed_user_highpage(vma, addr);
-	if (!page)
-		goto oom;
-
-	entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
-						vma->vm_page_prot)),
-				vma);
-	page_table = pte_offset_map(pmd, addr);
-	page_table_atomic_start(mm);
-
-	if (!ptep_cmpxchg(mm, addr, page_table, orig_entry, entry)) {
-		page_cache_release(page);
-		inc_page_state(cmpxchg_fail_anon_write);
-		goto minor_fault;
-        }
-
-	/*
-	 * These two functions must come after the cmpxchg
-	 * because if the page is on the LRU then try_to_unmap may come
-	 * in and unmap the pte.
-	 */
-	page_add_anon_rmap(page, vma, addr);
-	lru_cache_add_active(page);
-	inc_mm_counter(mm, rss);
+	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, entry);
 	lazy_mmu_prot_update(entry);
-
-minor_fault:
-	page_table_atomic_stop(mm);
-	pte_unmap(page_table);
+	spin_unlock(&mm->page_table_lock);
+out:
 	return VM_FAULT_MINOR;
-
-oom:
+no_mem:
 	return VM_FAULT_OOM;
 }
 
@@ -1829,12 +1810,12 @@ oom:
  * As this is called only for pages that do not currently exist, we
  * do not need to flush old virtual caches or the TLB.
  *
- * This is called with the MM semaphore held and atomic pte operations started.
+ * This is called with the MM semaphore held and the page table
+ * spinlock held. Exit with the spinlock released.
  */
 static int
 do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-	unsigned long address, int write_access, pte_t *page_table,
-        pmd_t *pmd, pte_t orig_entry)
+	unsigned long address, int write_access, pte_t *page_table, pmd_t *pmd)
 {
 	struct page * new_page;
 	struct address_space *mapping = NULL;
@@ -1845,9 +1826,9 @@ do_no_page(struct mm_struct *mm, struct 
 
 	if (!vma->vm_ops || !vma->vm_ops->nopage)
 		return do_anonymous_page(mm, vma, page_table,
-					pmd, write_access, address, orig_entry);
+					pmd, write_access, address);
 	pte_unmap(page_table);
-	page_table_atomic_stop(mm);
+	spin_unlock(&mm->page_table_lock);
 
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
@@ -1954,7 +1935,7 @@ oom:
  * nonlinear vmas.
  */
 static int do_file_page(struct mm_struct * mm, struct vm_area_struct * vma,
-	unsigned long address, int write_access, pte_t *pte, pmd_t *pmd, pte_t entry)
+	unsigned long address, int write_access, pte_t *pte, pmd_t *pmd)
 {
 	unsigned long pgoff;
 	int err;
@@ -1967,13 +1948,13 @@ static int do_file_page(struct mm_struct
 	if (!vma->vm_ops->populate ||
 			(write_access && !(vma->vm_flags & VM_SHARED))) {
 		pte_clear(mm, address, pte);
-		return do_no_page(mm, vma, address, write_access, pte, pmd, entry);
+		return do_no_page(mm, vma, address, write_access, pte, pmd);
 	}
 
-	pgoff = pte_to_pgoff(entry);
+	pgoff = pte_to_pgoff(*pte);
 
 	pte_unmap(pte);
-	page_table_atomic_stop(mm);
+	spin_unlock(&mm->page_table_lock);
 
 	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE, vma->vm_page_prot, pgoff, 0);
 	if (err == -ENOMEM)
@@ -1992,80 +1973,49 @@ static int do_file_page(struct mm_struct
  * with external mmu caches can use to update those (ie the Sparc or
  * PowerPC hashed page tables that act as extended TLBs).
  *
- * Note that kswapd only ever _removes_ pages, never adds them.
- * We exploit that case if possible to avoid taking the
- * page table lock.
-*/
+ * Note the "page_table_lock". It is to protect against kswapd removing
+ * pages from under us. Note that kswapd only ever _removes_ pages, never
+ * adds them. As such, once we have noticed that the page is not present,
+ * we can drop the lock early.
+ *
+ * The adding of pages is protected by the MM semaphore (which we hold),
+ * so we don't need to worry about a page being suddenly been added into
+ * our VM.
+ *
+ * We enter with the pagetable spinlock held, we are supposed to
+ * release it when done.
+ */
 static inline int handle_pte_fault(struct mm_struct *mm,
 	struct vm_area_struct * vma, unsigned long address,
 	int write_access, pte_t *pte, pmd_t *pmd)
 {
 	pte_t entry;
-	pte_t new_entry;
 
 	entry = *pte;
 	if (!pte_present(entry)) {
 		/*
-		 * Pass the value of the pte to do_no_page and do_file_page
-		 * This value may be used to verify that the pte is still
-		 * not present allowing atomic insertion of ptes.
+		 * If it truly wasn't present, we know that kswapd
+		 * and the PTE updates will not touch it later. So
+		 * drop the lock.
 		 */
 		if (pte_none(entry))
-			return do_no_page(mm, vma, address, write_access,
-						pte, pmd, entry);
+			return do_no_page(mm, vma, address, write_access, pte, pmd);
 		if (pte_file(entry))
-			return do_file_page(mm, vma, address, write_access,
-						pte, pmd, entry);
-		return do_swap_page(mm, vma, address, pte, pmd,
-						entry, write_access);
+			return do_file_page(mm, vma, address, write_access, pte, pmd);
+		return do_swap_page(mm, vma, address, pte, pmd, entry, write_access);
 	}
 
-	new_entry = pte_mkyoung(entry);
 	if (write_access) {
-		if (!pte_write(entry)) {
-#ifdef CONFIG_ATOMIC_TABLE_OPS
-			/*
-			 * do_wp_page modifies a pte. We can add a pte without
-			 * the page_table_lock but not modify a pte since a
-			 * cmpxchg does not allow us to verify that the page
-			 * was not changed under us. So acquire the page table
-			 * lock.
-			 */
-			spin_lock(&mm->page_table_lock);
-			if (pte_same(entry, *pte))
-				return do_wp_page(mm, vma, address, pte,
-							pmd, entry);
-			/*
-			 * pte was changed under us. Another processor may have
-			 * done what we needed to do.
-			 */
-			pte_unmap(pte);
-			spin_unlock(&mm->page_table_lock);
-			return VM_FAULT_MINOR;
-#else
+		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address, pte, pmd, entry);
-#endif
-		}
-		new_entry = pte_mkdirty(new_entry);
+		entry = pte_mkdirty(entry);
 	}
-
-	/*
-	 * If the cmpxchg fails then another processor may have done
-	 * the changes for us. If not then another fault will bring
-	 * another chance to do this again.
-	*/
-	if (ptep_cmpxchg(mm, address, pte, entry, new_entry)) {
-		flush_tlb_page(vma, address);
-		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
-	} else {
-		inc_page_state(cmpxchg_fail_flag_update);
-	}
-
+	entry = pte_mkyoung(entry);
+	ptep_set_access_flags(vma, address, pte, entry, write_access);
+	update_mmu_cache(vma, address, entry);
+	lazy_mmu_prot_update(entry);
 	pte_unmap(pte);
-	page_table_atomic_stop(mm);
-	if (pte_val(new_entry) == pte_val(entry))
-		inc_page_state(spurious_page_faults);
+	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_MINOR;
 }
 
@@ -2084,90 +2034,33 @@ int __handle_mm_fault(struct mm_struct *
 
 	inc_page_state(pgfault);
 
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		goto sigbus;		/* mapping truncation does this. */
+	if (is_vm_hugetlb_page(vma))
+		return VM_FAULT_SIGBUS;	/* mapping truncation does this. */
 
 	/*
-	 * We try to rely on the mmap_sem and the SMP-safe atomic PTE updates.
-	 * to synchronize with kswapd. However, the arch may fall back
-	 * in page_table_atomic_start to the page table lock.
-	 *
-	 * We may be able to avoid taking and releasing the page_table_lock
-	 * for the p??_alloc functions through atomic operations so we
-	 * duplicate the functionality of pmd_alloc, pud_alloc and
-	 * pte_alloc_map here.
+	 * We need the page table lock to synchronize with kswapd
+	 * and the SMP-safe atomic PTE updates.
 	 */
-	page_table_atomic_start(mm);
 	pgd = pgd_offset(mm, address);
-	if (unlikely(pgd_none(*pgd))) {
-#ifdef __ARCH_HAS_4LEVEL_HACK
-		/* The hack does not allow a clean fall back.
-		 * We need to insert a pmd entry into a pgd. pgd_test_and_populate is set
-		 * up to take a pmd entry. pud_none(pgd) == 0, therefore
-		 * the pud population branch will never be taken.
-		 */
-		pmd_t *new;
-
-		page_table_atomic_stop(mm);
-		new = pmd_alloc_one(mm, address);
-#else
-		pud_t *new;
-
-		page_table_atomic_stop(mm);
-		new = pud_alloc_one(mm, address);
-#endif
-
-		if (!new)
-			goto oom;
-
-		page_table_atomic_start(mm);
-		if (!pgd_test_and_populate(mm, pgd, new))
-			pud_free(new);
-	}
-
-	pud = pud_offset(pgd, address);
-	if (unlikely(pud_none(*pud))) {
-		pmd_t *new;
-
-		page_table_atomic_stop(mm);
-		new = pmd_alloc_one(mm, address);
-
-		if (!new)
-			goto oom;
-
-		page_table_atomic_start(mm);
-
-		if (!pud_test_and_populate(mm, pud, new))
-			pmd_free(new);
-	}
-
-	pmd = pmd_offset(pud, address);
-	if (unlikely(!pmd_present(*pmd))) {
-		struct page *new;
-
-		page_table_atomic_stop(mm);
-		new = pte_alloc_one(mm, address);
-
-		if (!new)
-			goto oom;
+	spin_lock(&mm->page_table_lock);
 
-		page_table_atomic_start(mm);
+	pud = pud_alloc(mm, pgd, address);
+	if (!pud)
+		goto oom;
 
-		if (!pmd_test_and_populate(mm, pmd, new))
-			pte_free(new);
-		else {
-			inc_page_state(nr_page_table_pages);
-			inc_mm_counter(mm, nr_ptes);
-		}
-	}
+	pmd = pmd_alloc(mm, pud, address);
+	if (!pmd)
+		goto oom;
 
-	pte = pte_offset_map(pmd, address);
+	pte = pte_alloc_map(mm, pmd, address);
+	if (!pte)
+		goto oom;
+	
 	return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
-oom:
-	return VM_FAULT_OOM;
 
-sigbus:
-	return VM_FAULT_SIGBUS;
+ oom:
+	spin_unlock(&mm->page_table_lock);
+	return VM_FAULT_OOM;
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED
--- 26136m1/mm/mprotect.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1-/mm/mprotect.c	2005-08-20 16:44:38.000000000 +0100
@@ -32,19 +32,17 @@ static void change_pte_range(struct mm_s
 
 	pte = pte_offset_map(pmd, addr);
 	do {
-		pte_t ptent;
-redo:
-		ptent = *pte;
-		if (!pte_present(ptent))
-			continue;
+		if (pte_present(*pte)) {
+			pte_t ptent;
 
-		/* Deal with a potential SMP race with hardware/arch
-		 * interrupt updating dirty/clean bits through the use
-		 * of ptep_cmpxchg.
-		 */
-		if (!ptep_cmpxchg(mm, addr, pte, ptent, pte_modify(ptent, newprot)))
-				goto redo;
-		lazy_mmu_prot_update(ptent);
+			/* Avoid an SMP race with hardware updated dirty/clean
+			 * bits by wiping the pte and then setting the new pte
+			 * into place.
+			 */
+			ptent = pte_modify(ptep_get_and_clear(mm, addr, pte), newprot);
+			set_pte_at(mm, addr, pte, ptent);
+			lazy_mmu_prot_update(ptent);
+		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap(pte - 1);
 }
--- 26136m1/mm/page_alloc.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1-/mm/page_alloc.c	2005-08-20 16:44:38.000000000 +0100
@@ -2286,12 +2286,6 @@ static char *vmstat_text[] = {
 
 	"pgrotated",
 	"nr_bounce",
-	"spurious_page_faults",
-	"cmpxchg_fail_flag_update",
-	"cmpxchg_fail_flag_reuse",
-
-	"cmpxchg_fail_anon_read",
-	"cmpxchg_fail_anon_write",
 };
 
 static void *vmstat_start(struct seq_file *m, loff_t *pos)
--- 26136m1/mm/rmap.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1-/mm/rmap.c	2005-08-20 16:44:38.000000000 +0100
@@ -539,6 +539,11 @@ static int try_to_unmap_one(struct page 
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	/* Move the dirty bit to the physical page now the pte is gone. */
+	if (pte_dirty(pteval))
+		set_page_dirty(page);
 
 	if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page->private };
@@ -553,15 +558,10 @@ static int try_to_unmap_one(struct page 
 			list_add(&mm->mmlist, &init_mm.mmlist);
 			spin_unlock(&mmlist_lock);
 		}
-		pteval = ptep_xchg_flush(vma, address, pte, swp_entry_to_pte(entry));
+		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
 		dec_mm_counter(mm, anon_rss);
-	} else
-		pteval = ptep_clear_flush(vma, address, pte);
-
-	/* Move the dirty bit to the physical page now the pte is gone. */
-	if (pte_dirty(pteval))
-		set_page_dirty(page);
+	}
 
 	dec_mm_counter(mm, rss);
 	page_remove_rmap(page);
@@ -653,15 +653,15 @@ static void try_to_unmap_cluster(unsigne
 		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
+		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pfn);
+		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
-			pteval = ptep_xchg_flush(vma, address, pte, pgoff_to_pte(page->index));
-		else
-			pteval = ptep_clear_flush(vma, address, pte);
+			set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
 
-		/* Move the dirty bit to the physical page now that the pte is gone. */
+		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))
 			set_page_dirty(page);
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
