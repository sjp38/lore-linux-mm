Date: Fri, 21 Nov 2003 18:48:10 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] Re-send of TLB flush optimizations for s/390.
Message-ID: <20031121174810.GA1341@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
this is a re-send of the tlb flush optimization for s/390 that was
discussed some weeks ago. I have some more mm patches and two of
them are dependent on this one, so here it is again.

blue skies,
  Martin.

diffstat:
 include/asm-generic/pgtable.h |   57 ++++++++++++++++++++++++++++++++++
 include/asm-i386/pgtable.h    |    8 ++++
 include/asm-ia64/pgtable.h    |    8 ++++
 include/asm-parisc/pgtable.h  |    8 ++++
 include/asm-ppc/pgtable.h     |    9 +++++
 include/asm-ppc64/pgtable.h   |    9 +++++
 include/asm-s390/pgalloc.h    |   25 ---------------
 include/asm-s390/pgtable.h    |   69 ++++++++++++++++++++++++++++++++++++++----
 include/asm-sh/pgtable.h      |    8 ++++
 include/asm-x86_64/pgtable.h  |    8 ++++
 mm/memory.c                   |   30 ++++++------------
 mm/mremap.c                   |   16 ++++++---
 mm/msync.c                    |    5 +--
 mm/rmap.c                     |    3 -
 14 files changed, 202 insertions(+), 61 deletions(-)

diff -urN linux-2.6/include/asm-generic/pgtable.h linux-2.6-s390/include/asm-generic/pgtable.h
--- linux-2.6/include/asm-generic/pgtable.h	Sat Oct 25 20:43:20 2003
+++ linux-2.6-s390/include/asm-generic/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -1,6 +1,23 @@
 #ifndef _ASM_GENERIC_PGTABLE_H
 #define _ASM_GENERIC_PGTABLE_H
 
+#ifndef __HAVE_ARCH_PTEP_ESTABLISH
+/*
+ * Establish a new mapping:
+ *  - flush the old one
+ *  - update the page tables
+ *  - inform the TLB about the new one
+ *
+ * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
+ */
+#define ptep_establish(__vma, __address, __ptep, __entry)		\
+do {									\
+	set_pte(__ptep, __entry);					\
+	flush_tlb_page(__vma, __address);				\
+} while (0)
+#endif
+
+#ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 static inline int ptep_test_and_clear_young(pte_t *ptep)
 {
 	pte_t pte = *ptep;
@@ -9,7 +26,19 @@
 	set_pte(ptep, pte_mkold(pte));
 	return 1;
 }
+#endif
+
+#ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
+#define ptep_clear_flush_young(__vma, __address, __ptep)		\
+({									\
+	int __young = ptep_test_and_clear_young(__ptep);		\
+	if (__young)							\
+		flush_tlb_page(__vma, __address);			\
+	__young;							\
+})
+#endif
 
+#ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 static inline int ptep_test_and_clear_dirty(pte_t *ptep)
 {
 	pte_t pte = *ptep;
@@ -18,26 +47,54 @@
 	set_pte(ptep, pte_mkclean(pte));
 	return 1;
 }
+#endif
 
+#ifndef __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
+#define ptep_clear_flush_dirty(__vma, __address, __ptep)		\
+({									\
+	int __dirty = ptep_test_and_clear_dirty(__ptep);		\
+	if (__dirty)							\
+		flush_tlb_page(__vma, __address);			\
+	__dirty;							\
+})
+#endif
+
+#ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(pte_t *ptep)
 {
 	pte_t pte = *ptep;
 	pte_clear(ptep);
 	return pte;
 }
+#endif
+
+#ifndef __HAVE_ARCH_PTEP_CLEAR_FLUSH
+#define ptep_clear_flush(__vma, __address, __ptep)			\
+({									\
+	pte_t __pte = ptep_get_and_clear(__ptep);			\
+	flush_tlb_page(__vma, __address);				\
+	__pte;								\
+})
+#endif
 
+#ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
 static inline void ptep_set_wrprotect(pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
 	set_pte(ptep, pte_wrprotect(old_pte));
 }
+#endif
 
+#ifndef __HAVE_ARCH_PTEP_MKDIRTY
 static inline void ptep_mkdirty(pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
 	set_pte(ptep, pte_mkdirty(old_pte));
 }
+#endif
 
+#ifndef __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
+#endif
 
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff -urN linux-2.6/include/asm-i386/pgtable.h linux-2.6-s390/include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h	Sat Oct 25 20:44:13 2003
+++ linux-2.6-s390/include/asm-i386/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -341,4 +341,12 @@
 
 #define io_remap_page_range remap_page_range
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _I386_PGTABLE_H */
diff -urN linux-2.6/include/asm-ia64/pgtable.h linux-2.6-s390/include/asm-ia64/pgtable.h
--- linux-2.6/include/asm-ia64/pgtable.h	Fri Nov 21 16:18:48 2003
+++ linux-2.6-s390/include/asm-ia64/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -498,4 +498,12 @@
 #define FIXADDR_USER_START	GATE_ADDR
 #define FIXADDR_USER_END	(GATE_ADDR + 2*PAGE_SIZE)
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _ASM_IA64_PGTABLE_H */
diff -urN linux-2.6/include/asm-parisc/pgtable.h linux-2.6-s390/include/asm-parisc/pgtable.h
--- linux-2.6/include/asm-parisc/pgtable.h	Sat Oct 25 20:44:37 2003
+++ linux-2.6-s390/include/asm-parisc/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -460,4 +460,12 @@
 
 #define HAVE_ARCH_UNMAPPED_AREA
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _PARISC_PGTABLE_H */
diff -urN linux-2.6/include/asm-ppc/pgtable.h linux-2.6-s390/include/asm-ppc/pgtable.h
--- linux-2.6/include/asm-ppc/pgtable.h	Sat Oct 25 20:43:07 2003
+++ linux-2.6-s390/include/asm-ppc/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -661,5 +661,14 @@
 typedef pte_t *pte_addr_t;
 
 #endif /* !__ASSEMBLY__ */
+
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _PPC_PGTABLE_H */
 #endif /* __KERNEL__ */
diff -urN linux-2.6/include/asm-ppc64/pgtable.h linux-2.6-s390/include/asm-ppc64/pgtable.h
--- linux-2.6/include/asm-ppc64/pgtable.h	Sat Oct 25 20:44:46 2003
+++ linux-2.6-s390/include/asm-ppc64/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -411,4 +411,13 @@
 			 unsigned long hpteflags, int bolted, int large);
 
 #endif /* __ASSEMBLY__ */
+
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _PPC64_PGTABLE_H */
diff -urN linux-2.6/include/asm-s390/pgalloc.h linux-2.6-s390/include/asm-s390/pgalloc.h
--- linux-2.6/include/asm-s390/pgalloc.h	Fri Nov 21 16:18:59 2003
+++ linux-2.6-s390/include/asm-s390/pgalloc.h	Fri Nov 21 16:20:27 2003
@@ -159,29 +159,4 @@
  */
 #define set_pgdir(addr,entry) do { } while(0)
 
-static inline pte_t ptep_invalidate(struct vm_area_struct *vma, 
-                                    unsigned long address, pte_t *ptep)
-{
-	pte_t pte = *ptep;
-#ifndef __s390x__
-	if (!(pte_val(pte) & _PAGE_INVALID)) {
-		/* S390 has 1mb segments, we are emulating 4MB segments */
-		pte_t *pto = (pte_t *) (((unsigned long) ptep) & 0x7ffffc00);
-		__asm__ __volatile__ ("ipte %0,%1" : : "a" (pto), "a" (address));
-	}
-#else /* __s390x__ */
-	if (!(pte_val(pte) & _PAGE_INVALID)) 
-		__asm__ __volatile__ ("ipte %0,%1" : : "a" (ptep), "a" (address));
-#endif /* __s390x__ */
-	pte_clear(ptep);
-	return pte;
-}
-
-static inline void ptep_establish(struct vm_area_struct *vma, 
-                                  unsigned long address, pte_t *ptep, pte_t entry)
-{
-	ptep_invalidate(vma, address, ptep);
-	set_pte(ptep, entry);
-}
-
 #endif /* _S390_PGALLOC_H */
diff -urN linux-2.6/include/asm-s390/pgtable.h linux-2.6-s390/include/asm-s390/pgtable.h
--- linux-2.6/include/asm-s390/pgtable.h	Fri Nov 21 16:18:59 2003
+++ linux-2.6-s390/include/asm-s390/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -33,6 +33,8 @@
 #include <asm/processor.h>
 #include <linux/threads.h>
 
+struct vm_area_struct; /* forward declaration (include/linux/mm.h) */
+
 extern pgd_t swapper_pg_dir[] __attribute__ ((aligned (4096)));
 extern void paging_init(void);
 
@@ -493,22 +495,22 @@
 	 * sske instruction is slow. It is faster to let the
 	 * next instruction set the dirty bit.
 	 */
-	pte_val(pte) &= ~ _PAGE_ISCLEAN;
 	return pte;
 }
 
 extern inline pte_t pte_mkold(pte_t pte)
 {
-	asm volatile ("rrbe 0,%0" : : "a" (pte_val(pte)) : "cc" );
+	/* S/390 doesn't keep its dirty/referenced bit in the pte.
+	 * There is no point in clearing the real referenced bit.
+	 */
 	return pte;
 }
 
 extern inline pte_t pte_mkyoung(pte_t pte)
 {
-	/* To set the referenced bit we read the first word from the real
-	 * page with a special instruction: load using real address (lura).
-	 * Isn't S/390 a nice architecture ?! */
-	asm volatile ("lura 0,%0" : : "a" (pte_val(pte) & PAGE_MASK) : "0" );
+	/* S/390 doesn't keep its dirty/referenced bit in the pte.
+	 * There is no point in setting the real referenced bit.
+	 */
 	return pte;
 }
 
@@ -523,6 +525,14 @@
 	return ccode & 2;
 }
 
+static inline int
+ptep_clear_flush_young(struct vm_area_struct *vma,
+			unsigned long address, pte_t *ptep)
+{
+	/* No need to flush TLB; bits are in storage key */
+	return ptep_test_and_clear_young(ptep);
+}
+
 static inline int ptep_test_and_clear_dirty(pte_t *ptep)
 {
 	int skey;
@@ -539,6 +549,14 @@
 	return 1;
 }
 
+static inline int
+ptep_clear_flush_dirty(struct vm_area_struct *vma,
+			unsigned long address, pte_t *ptep)
+{
+	/* No need to flush TLB; bits are in storage key */
+	return ptep_test_and_clear_dirty(ptep);
+}
+
 static inline pte_t ptep_get_and_clear(pte_t *ptep)
 {
 	pte_t pte = *ptep;
@@ -546,6 +564,25 @@
 	return pte;
 }
 
+static inline pte_t
+ptep_clear_flush(struct vm_area_struct *vma,
+		 unsigned long address, pte_t *ptep)
+{
+	pte_t pte = *ptep;
+#ifndef __s390x__
+	if (!(pte_val(pte) & _PAGE_INVALID)) {
+		/* S390 has 1mb segments, we are emulating 4MB segments */
+		pte_t *pto = (pte_t *) (((unsigned long) ptep) & 0x7ffffc00);
+		__asm__ __volatile__ ("ipte %0,%1" : : "a" (pto), "a" (address));
+	}
+#else /* __s390x__ */
+	if (!(pte_val(pte) & _PAGE_INVALID)) 
+		__asm__ __volatile__ ("ipte %0,%1" : : "a" (ptep), "a" (address));
+#endif /* __s390x__ */
+	pte_clear(ptep);
+	return pte;
+}
+
 static inline void ptep_set_wrprotect(pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
@@ -557,6 +594,14 @@
 	pte_mkdirty(*ptep);
 }
 
+static inline void
+ptep_establish(struct vm_area_struct *vma, 
+	       unsigned long address, pte_t *ptep, pte_t entry)
+{
+	ptep_clear_flush(vma, address, ptep);
+	set_pte(ptep, entry);
+}
+
 /*
  * Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
@@ -727,5 +772,17 @@
 # define HAVE_ARCH_UNMAPPED_AREA
 #endif /* __s390x__ */
 
+#define __HAVE_ARCH_PTEP_ESTABLISH
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_CLEAR_FLUSH
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _S390_PAGE_H */
 
diff -urN linux-2.6/include/asm-sh/pgtable.h linux-2.6-s390/include/asm-sh/pgtable.h
--- linux-2.6/include/asm-sh/pgtable.h	Sat Oct 25 20:45:06 2003
+++ linux-2.6-s390/include/asm-sh/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -280,5 +280,13 @@
 extern unsigned int kobjsize(const void *objp);
 #endif /* !CONFIG_MMU */
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* __ASM_SH_PAGE_H */
 
diff -urN linux-2.6/include/asm-x86_64/pgtable.h linux-2.6-s390/include/asm-x86_64/pgtable.h
--- linux-2.6/include/asm-x86_64/pgtable.h	Sat Oct 25 20:44:09 2003
+++ linux-2.6-s390/include/asm-x86_64/pgtable.h	Fri Nov 21 16:20:27 2003
@@ -408,4 +408,12 @@
 #define	kc_offset_to_vaddr(o) \
    (((o) & (1UL << (__VIRTUAL_MASK_SHIFT-1))) ? ((o) | (~__VIRTUAL_MASK)) : (o))
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT
+#define __HAVE_ARCH_PTEP_MKDIRTY
+#define __HAVE_ARCH_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _X86_64_PGTABLE_H */
diff -urN linux-2.6/mm/memory.c linux-2.6-s390/mm/memory.c
--- linux-2.6/mm/memory.c	Fri Nov 21 16:20:27 2003
+++ linux-2.6-s390/mm/memory.c	Fri Nov 21 16:20:27 2003
@@ -963,28 +963,17 @@
 EXPORT_SYMBOL(remap_page_range);
 
 /*
- * Establish a new mapping:
- *  - flush the old one
- *  - update the page tables
- *  - inform the TLB about the new one
- *
- * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
- */
-static inline void establish_pte(struct vm_area_struct * vma, unsigned long address, pte_t *page_table, pte_t entry)
-{
-	set_pte(page_table, entry);
-	flush_tlb_page(vma, address);
-	update_mmu_cache(vma, address, entry);
-}
-
-/*
  * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
  */
 static inline void break_cow(struct vm_area_struct * vma, struct page * new_page, unsigned long address, 
 		pte_t *page_table)
 {
+	pte_t entry;
+
 	flush_cache_page(vma, address);
-	establish_pte(vma, address, page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
+	entry = pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot)));
+	ptep_establish(vma, address, page_table, entry);
+	update_mmu_cache(vma, address, entry);
 }
 
 /*
@@ -1013,6 +1002,7 @@
 	struct page *old_page, *new_page;
 	unsigned long pfn = pte_pfn(pte);
 	struct pte_chain *pte_chain;
+	pte_t entry;
 
 	if (unlikely(!pfn_valid(pfn))) {
 		/*
@@ -1033,8 +1023,9 @@
 		unlock_page(old_page);
 		if (reuse) {
 			flush_cache_page(vma, address);
-			establish_pte(vma, address, page_table,
-				pte_mkyoung(pte_mkdirty(pte_mkwrite(pte))));
+			entry = pte_mkyoung(pte_mkdirty(pte_mkwrite(pte)));
+			ptep_establish(vma, address, page_table, entry);
+			update_mmu_cache(vma, address, entry);
 			pte_unmap(page_table);
 			spin_unlock(&mm->page_table_lock);
 			return VM_FAULT_MINOR;
@@ -1593,7 +1584,8 @@
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	establish_pte(vma, address, pte, entry);
+	ptep_establish(vma, address, pte, entry);
+	update_mmu_cache(vma, address, entry);
 	pte_unmap(pte);
 	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_MINOR;
diff -urN linux-2.6/mm/mremap.c linux-2.6-s390/mm/mremap.c
--- linux-2.6/mm/mremap.c	Sat Oct 25 20:43:47 2003
+++ linux-2.6-s390/mm/mremap.c	Fri Nov 21 16:20:27 2003
@@ -80,8 +80,8 @@
 }
 
 static int
-copy_one_pte(struct mm_struct *mm, pte_t *src, pte_t *dst,
-		struct pte_chain **pte_chainp)
+copy_one_pte(struct vm_area_struct *vma, unsigned long old_addr,
+	     pte_t *src, pte_t *dst, struct pte_chain **pte_chainp)
 {
 	int error = 0;
 	pte_t pte;
@@ -93,7 +93,7 @@
 	if (!pte_none(*src)) {
 		if (page)
 			page_remove_rmap(page, src);
-		pte = ptep_get_and_clear(src);
+		pte = ptep_clear_flush(vma, old_addr, src);
 		if (!dst) {
 			/* No dest?  We must put it back. */
 			dst = src;
@@ -135,11 +135,15 @@
 		dst = alloc_one_pte_map(mm, new_addr);
 		if (src == NULL)
 			src = get_one_pte_map_nested(mm, old_addr);
-		error = copy_one_pte(mm, src, dst, &pte_chain);
+		error = copy_one_pte(vma, old_addr, src, dst, &pte_chain);
 		pte_unmap_nested(src);
 		pte_unmap(dst);
-	}
-	flush_tlb_page(vma, old_addr);
+	} else
+		/*
+		 * Why do we need this flush ? If there is no pte for
+		 * old_addr, then there must not be a pte for it as well.
+		 */
+		flush_tlb_page(vma, old_addr);
 	spin_unlock(&mm->page_table_lock);
 	pte_chain_free(pte_chain);
 out:
diff -urN linux-2.6/mm/msync.c linux-2.6-s390/mm/msync.c
--- linux-2.6/mm/msync.c	Fri Nov 21 16:20:25 2003
+++ linux-2.6-s390/mm/msync.c	Fri Nov 21 16:20:27 2003
@@ -30,10 +30,9 @@
 		unsigned long pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
 			page = pfn_to_page(pfn);
-			if (!PageReserved(page) && ptep_test_and_clear_dirty(ptep)) {
-				flush_tlb_page(vma, address);
+			if (!PageReserved(page) &&
+			    ptep_clear_flush_dirty(vma, address, ptep))
 				set_page_dirty(page);
-			}
 		}
 	}
 	return 0;
diff -urN linux-2.6/mm/rmap.c linux-2.6-s390/mm/rmap.c
--- linux-2.6/mm/rmap.c	Fri Nov 21 16:20:26 2003
+++ linux-2.6-s390/mm/rmap.c	Fri Nov 21 16:20:27 2003
@@ -325,8 +325,7 @@
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address);
-	pte = ptep_get_and_clear(ptep);
-	flush_tlb_page(vma, address);
+	pte = ptep_clear_flush(vma, address, ptep);
 
 	if (PageSwapCache(page)) {
 		/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
