Date: Mon, 6 Oct 2003 20:04:56 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: TLB flush optimization on s/390.
Message-ID: <20031006180456.GA14206@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
on the s/390 architecture we still have the issue with tlb flushing and
the ipte instruction. We can optimize the tlb flushing a lot with some
minor interface changes between the arch backend and the memory management
core. 
In the end the whole thing is about the Invalidate Page Table Entry (ipte)
instruction. The instruction sets the invalid bit in the pte and removes
the tlb for the page on all cpus for the virtual to physical mapping of
the page in a particular address space. The nice thing is that only the
tlb for this page gets removed, all the other tlbs stay valid. The reason
we can't use ipte to implement flush_tlb_page() is one of the requirements
of the instruction: the pte that should get flushed needs to be *valid*.

I'd like to add the following four functions to the mm interface:

 * ptep_establish: Establish a new mapping. This sets a pte entry to a
   page table and flushes the tlb of the old entry on all cpus if it
   exists. This is more or less what establish_pte in mm/memory.c does
   right now but without the update_mmu_cache call.

 * ptep_test_and_clear_and_flush_young. Do what ptep_test_and_clear_young
   does and flush the tlb.

 * ptep_test_and_clear_and_flush_dirty. Do what ptep_test_and_clear_dirty
   does and flush the tlb.

 * ptep_get_and_clear_and_flush: Do what ptep_get_and_clear does and
   flush the tlb.

The s/390 specific functions in include/pgtable.h define their own optimized
version of these four functions by use of the ipte.

I avoid the definition of these function for every architecture I added them
to include/asm-generic/pgtable.h. Since i386/x86 and others don't include
this header yet and define their own version of the functions found there
I #ifdef'd all functions in include/asm-generic/pgtable.h to be able to
pick the ones that are needed for each architecture (see patch for details).

With the new functions in place it is easy to do the optimization, e.g.
the sequence

	ptep_get_and_clear(ptep);
	flush_tlb_page(vma, address);

gets replace by

	ptep_get_and_clear_and_flush(vma, address, ptep);

The old sequence still works but it is suboptimal on s/390.

Comments ?

blue skies,
  Martin.

diff -urN linux-bk/include/asm-generic/pgtable.h linux-ptep/include/asm-generic/pgtable.h
--- linux-bk/include/asm-generic/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-generic/pgtable.h	Mon Oct  6 18:39:34 2003
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
+#ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_AND_FLUSH_YOUNG
+#define ptep_test_and_clear_and_flush_young(__vma, __address, __ptep)	\
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
 
+#ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_AND_FLUSH_DIRTY
+#define ptep_test_and_clear_and_flush_dirty(__vma, __address, __ptep)	\
+({									\
+	int __dirty = ptep_test_and_clear_dirty(__ptep);		\
+	if (__dirty)							\
+		flush_tlb_page(__vma, __address);			\
+	__dirty;							\
+})
+#endif
+
+#ifndef __HAVE_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(pte_t *ptep)
 {
 	pte_t pte = *ptep;
 	pte_clear(ptep);
 	return pte;
 }
+#endif
+
+#ifndef __HAVE_PTEP_GET_AND_CLEAR_AND_FLUSH
+#define ptep_get_and_clear_and_flush(__vma, __address, __ptep)		\
+({									\
+	pte_t __pte = ptep_get_and_clear(__ptep);			\
+	flush_tlb_page(__vma, __address);				\
+	__pte;								\
+})
+#endif
 
+#ifndef __HAVE_PTEP_SET_WRPROTECT
 static inline void ptep_set_wrprotect(pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
 	set_pte(ptep, pte_wrprotect(old_pte));
 }
+#endif
 
+#ifndef __HAVE_PTEP_MKDIRTY
 static inline void ptep_mkdirty(pte_t *ptep)
 {
 	pte_t old_pte = *ptep;
 	set_pte(ptep, pte_mkdirty(old_pte));
 }
+#endif
 
+#ifndef __HAVE_PTE_SAME
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
+#endif
 
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff -urN linux-bk/include/asm-i386/pgtable.h linux-ptep/include/asm-i386/pgtable.h
--- linux-bk/include/asm-i386/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-i386/pgtable.h	Mon Oct  6 18:14:00 2003
@@ -341,4 +341,12 @@
 
 #define io_remap_page_range remap_page_range
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _I386_PGTABLE_H */
diff -urN linux-bk/include/asm-ia64/pgtable.h linux-ptep/include/asm-ia64/pgtable.h
--- linux-bk/include/asm-ia64/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-ia64/pgtable.h	Mon Oct  6 18:16:15 2003
@@ -501,4 +501,12 @@
 #define FIXADDR_USER_START	GATE_ADDR
 #define FIXADDR_USER_END	(GATE_ADDR + 2*PAGE_SIZE)
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _ASM_IA64_PGTABLE_H */
diff -urN linux-bk/include/asm-parisc/pgtable.h linux-ptep/include/asm-parisc/pgtable.h
--- linux-bk/include/asm-parisc/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-parisc/pgtable.h	Mon Oct  6 18:16:34 2003
@@ -460,4 +460,12 @@
 
 #define HAVE_ARCH_UNMAPPED_AREA
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _PARISC_PGTABLE_H */
diff -urN linux-bk/include/asm-ppc/pgtable.h linux-ptep/include/asm-ppc/pgtable.h
--- linux-bk/include/asm-ppc/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-ppc/pgtable.h	Mon Oct  6 18:16:57 2003
@@ -661,5 +661,14 @@
 typedef pte_t *pte_addr_t;
 
 #endif /* !__ASSEMBLY__ */
+
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _PPC_PGTABLE_H */
 #endif /* __KERNEL__ */
diff -urN linux-bk/include/asm-ppc64/pgtable.h linux-ptep/include/asm-ppc64/pgtable.h
--- linux-bk/include/asm-ppc64/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-ppc64/pgtable.h	Mon Oct  6 18:17:12 2003
@@ -414,4 +414,13 @@
 			 unsigned long hpteflags, int bolted, int large);
 
 #endif /* __ASSEMBLY__ */
+
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _PPC64_PGTABLE_H */
diff -urN linux-bk/include/asm-s390/pgalloc.h linux-ptep/include/asm-s390/pgalloc.h
--- linux-bk/include/asm-s390/pgalloc.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-s390/pgalloc.h	Mon Oct  6 18:20:34 2003
@@ -155,29 +155,4 @@
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
diff -urN linux-bk/include/asm-s390/pgtable.h linux-ptep/include/asm-s390/pgtable.h
--- linux-bk/include/asm-s390/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-s390/pgtable.h	Mon Oct  6 18:18:51 2003
@@ -32,6 +32,8 @@
 #include <asm/processor.h>
 #include <linux/threads.h>
 
+struct vm_area_struct; /* forward declaration (include/linux/mm.h) */
+
 extern pgd_t swapper_pg_dir[] __attribute__ ((aligned (4096)));
 extern void paging_init(void);
 
@@ -520,6 +522,14 @@
 	return ccode & 2;
 }
 
+static inline int
+ptep_test_and_clear_and_flush_young(struct vm_area_struct *vma,
+				    unsigned long address, pte_t *ptep)
+{
+	/* No need to flush TLB; bits are in storage key */
+	return ptep_test_and_clear_young(ptep);
+}
+
 static inline int ptep_test_and_clear_dirty(pte_t *ptep)
 {
 	int skey;
@@ -536,6 +546,14 @@
 	return 1;
 }
 
+static inline int
+ptep_test_and_clear_and_flush_dirty(struct vm_area_struct *vma,
+				    unsigned long address, pte_t *ptep)
+{
+	/* No need to flush TLB; bits are in storage key */
+	return ptep_test_and_clear_young(ptep);
+}
+
 static inline pte_t ptep_get_and_clear(pte_t *ptep)
 {
 	pte_t pte = *ptep;
@@ -543,6 +561,25 @@
 	return pte;
 }
 
+static inline pte_t
+ptep_get_and_clear_and_flush(struct vm_area_struct *vma,
+			     unsigned long address, pte_t *ptep)
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
@@ -554,6 +591,14 @@
 	pte_mkdirty(*ptep);
 }
 
+static inline void
+ptep_establish(struct vm_area_struct *vma, 
+	       unsigned long address, pte_t *ptep, pte_t entry)
+{
+	ptep_get_and_clear_and_flush(vma, address, ptep);
+	set_pte(ptep, entry);
+}
+
 /*
  * Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
@@ -723,6 +768,18 @@
 #ifdef __s390x__
 # define HAVE_ARCH_UNMAPPED_AREA
 #endif /* __s390x__ */
+
+#define __HAVE_ARCH_PTEP_ESTABLISH
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_AND_FLUSH_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_AND_FLUSH_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_GET_AND_CLEAR_AND_FLUSH
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
 
 #endif /* _S390_PAGE_H */
 
diff -urN linux-bk/include/asm-sh/pgtable.h linux-ptep/include/asm-sh/pgtable.h
--- linux-bk/include/asm-sh/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-sh/pgtable.h	Mon Oct  6 18:21:07 2003
@@ -280,5 +280,13 @@
 extern unsigned int kobjsize(const void *objp);
 #endif /* !CONFIG_MMU */
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* __ASM_SH_PAGE_H */
 
diff -urN linux-bk/include/asm-x86_64/pgtable.h linux-ptep/include/asm-x86_64/pgtable.h
--- linux-bk/include/asm-x86_64/pgtable.h	Mon Oct  6 18:44:11 2003
+++ linux-ptep/include/asm-x86_64/pgtable.h	Mon Oct  6 18:19:06 2003
@@ -408,4 +408,12 @@
 #define	kc_offset_to_vaddr(o) \
    (((o) & (1UL << (__VIRTUAL_MASK_SHIFT-1))) ? ((o) | (~__VIRTUAL_MASK)) : (o))
 
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
+#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
+#define __HAVE_PTEP_GET_AND_CLEAR
+#define __HAVE_PTEP_SET_WRPROTECT
+#define __HAVE_PTEP_MKDIRTY
+#define __HAVE_PTE_SAME
+#include <asm-generic/pgtable.h>
+
 #endif /* _X86_64_PGTABLE_H */
diff -urN linux-bk/mm/memory.c linux-ptep/mm/memory.c
--- linux-bk/mm/memory.c	Mon Oct  6 18:44:11 2003
+++ linux-ptep/mm/memory.c	Mon Oct  6 18:41:31 2003
@@ -941,28 +941,17 @@
 }
 
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
@@ -991,6 +980,7 @@
 	struct page *old_page, *new_page;
 	unsigned long pfn = pte_pfn(pte);
 	struct pte_chain *pte_chain = NULL;
+	pte_t entry;
 	int ret;
 
 	if (unlikely(!pfn_valid(pfn))) {
@@ -1011,8 +1001,9 @@
 		unlock_page(old_page);
 		if (reuse) {
 			flush_cache_page(vma, address);
-			establish_pte(vma, address, page_table,
-				pte_mkyoung(pte_mkdirty(pte_mkwrite(pte))));
+			entry = pte_mkyoung(pte_mkdirty(pte_mkwrite(pte)));
+			ptep_establish(vma, address, page_table, entry);
+			update_mmu_cache(vma, address, entry);
 			pte_unmap(page_table);
 			ret = VM_FAULT_MINOR;
 			goto out;
@@ -1571,7 +1562,8 @@
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	establish_pte(vma, address, pte, entry);
+	ptep_establish(vma, address, pte, entry);
+	update_mmu_cache(vma, address, entry);
 	pte_unmap(pte);
 	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_MINOR;
diff -urN linux-bk/mm/mremap.c linux-ptep/mm/mremap.c
--- linux-bk/mm/mremap.c	Mon Oct  6 18:44:11 2003
+++ linux-ptep/mm/mremap.c	Mon Oct  6 18:42:43 2003
@@ -79,9 +79,9 @@
 	return pte;
 }
 
-static int
-copy_one_pte(struct mm_struct *mm, pte_t *src, pte_t *dst,
-		struct pte_chain **pte_chainp)
+static inline int
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
+		pte = ptep_get_and_clear_and_flush(vma, old_addr, src);
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
diff -urN linux-bk/mm/msync.c linux-ptep/mm/msync.c
--- linux-bk/mm/msync.c	Mon Oct  6 18:44:11 2003
+++ linux-ptep/mm/msync.c	Mon Oct  6 18:43:11 2003
@@ -30,10 +30,9 @@
 		unsigned long pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
 			page = pfn_to_page(pfn);
-			if (!PageReserved(page) && ptep_test_and_clear_dirty(ptep)) {
-				flush_tlb_page(vma, address);
+			if (!PageReserved(page) &&
+			    ptep_test_and_clear_and_flush_dirty(vma, address, ptep))
 				set_page_dirty(page);
-			}
 		}
 	}
 	return 0;
diff -urN linux-bk/mm/rmap.c linux-ptep/mm/rmap.c
--- linux-bk/mm/rmap.c	Mon Oct  6 18:44:11 2003
+++ linux-ptep/mm/rmap.c	Mon Oct  6 18:43:25 2003
@@ -329,8 +329,7 @@
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address);
-	pte = ptep_get_and_clear(ptep);
-	flush_tlb_page(vma, address);
+	pte = ptep_get_and_clear_and_flush(vma, address, ptep);
 
 	if (PageSwapCache(page)) {
 		/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
