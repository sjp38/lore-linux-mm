Date: Fri, 21 Nov 2003 18:48:36 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] Physical dirty and referenced bits.
Message-ID: <20031121174836.GB1341@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
this is another s/390 related mm patch. It introduces the concept of
physical dirty and referenced bits into the common mm code. I always
had the nagging feeling that the pte functions for setting/clearing
the dirty and referenced bits are not appropriate for s/390. It works
but it is a bit of a hack. 
After the wake of rmap it is now possible to put a much better solution
into place. The idea is simple: since there are not dirty/referenced
bits in the pte make these function nops on s/390 and add operations
on the physical page to the appropriate places. For the referenced bit
this is the page_referenced() function. For the dirty bit there are
two relevant spots: in page_remove_rmap after the last user of the
page removed its reverse mapping and in try_to_unmap after the last
user was unmapped. There are two new functions to accomplish this:

 * page_test_and_clear_dirty: Test and clear the dirty bit of a
   physical page. This function is analog to ptep_test_and_clear_dirty
   but gets a struct page as argument instead of a pte_t pointer.

 * page_test_and_clear_young: Test and clear the referenced bit
   of a physical page. This function is analog to ptep_test_and_clear_young
   but gets a struct page as argument instead of a pte_t pointer.

Its pretty straightforward and with it the s/390 mm makes much more
sense. You'll need the tls flush optimization patch for the patch.
Comments ?

blue skies,
  Martin.

diffstat:
 include/asm-generic/pgtable.h |    8 +++
 include/asm-s390/pgtable.h    |   96 ++++++++++++++++++++++++------------------
 mm/msync.c                    |   17 +++----
 mm/rmap.c                     |   13 +++++
 4 files changed, 85 insertions(+), 49 deletions(-)

diff -urN linux-2.6/include/asm-generic/pgtable.h linux-2.6-s390/include/asm-generic/pgtable.h
--- linux-2.6/include/asm-generic/pgtable.h	Fri Nov 21 16:20:28 2003
+++ linux-2.6-s390/include/asm-generic/pgtable.h	Fri Nov 21 16:20:28 2003
@@ -97,4 +97,12 @@
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
 #endif
 
+#ifndef __HAVE_ARCH_PAGE_TEST_AND_CLEAR_DIRTY
+#define page_test_and_clear_dirty(page) (0)
+#endif
+
+#ifndef __HAVE_ARCH_PAGE_TEST_AND_CLEAR_YOUNG
+#define page_test_and_clear_young(page) (0)
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff -urN linux-2.6/include/asm-s390/pgtable.h linux-2.6-s390/include/asm-s390/pgtable.h
--- linux-2.6/include/asm-s390/pgtable.h	Fri Nov 21 16:20:28 2003
+++ linux-2.6-s390/include/asm-s390/pgtable.h	Fri Nov 21 16:20:28 2003
@@ -213,9 +213,6 @@
 #define _PAGE_RO        0x200          /* HW read-only                     */
 #define _PAGE_INVALID   0x400          /* HW invalid                       */
 
-/* Software bits in the page table entry */
-#define _PAGE_ISCLEAN   0x002
-
 /* Mask and four different kinds of invalid pages. */
 #define _PAGE_INVALID_MASK	0x601
 #define _PAGE_INVALID_EMPTY	0x400
@@ -283,12 +280,12 @@
  * No mapping available
  */
 #define PAGE_NONE_SHARED  __pgprot(_PAGE_INVALID_NONE)
-#define PAGE_NONE_PRIVATE __pgprot(_PAGE_INVALID_NONE|_PAGE_ISCLEAN)
+#define PAGE_NONE_PRIVATE __pgprot(_PAGE_INVALID_NONE)
 #define PAGE_RO_SHARED	  __pgprot(_PAGE_RO)
-#define PAGE_RO_PRIVATE	  __pgprot(_PAGE_RO|_PAGE_ISCLEAN)
-#define PAGE_COPY	  __pgprot(_PAGE_RO|_PAGE_ISCLEAN)
+#define PAGE_RO_PRIVATE	  __pgprot(_PAGE_RO)
+#define PAGE_COPY	  __pgprot(_PAGE_RO)
 #define PAGE_SHARED	  __pgprot(0)
-#define PAGE_KERNEL	  __pgprot(_PAGE_ISCLEAN)
+#define PAGE_KERNEL	  __pgprot(0)
 
 /*
  * The S390 can't do page protection for execute, and considers that the
@@ -403,20 +400,20 @@
 
 extern inline int pte_dirty(pte_t pte)
 {
-	int skey;
-
-	if (pte_val(pte) & _PAGE_ISCLEAN)
-		return 0;
-	asm volatile ("iske %0,%1" : "=d" (skey) : "a" (pte_val(pte)));
-	return skey & _PAGE_CHANGED;
+	/* A pte is neither clean nor dirty on s/390. The dirty bit
+	 * is in the storage key. See page_test_and_clear_dirty for
+	 * details.
+	 */
+	return 0;
 }
 
 extern inline int pte_young(pte_t pte)
 {
-	int skey;
-
-	asm volatile ("iske %0,%1" : "=d" (skey) : "a" (pte_val(pte)));
-	return skey & _PAGE_REFERENCED;
+	/* A pte is neither young nor old on s/390. The young bit
+	 * is in the storage key. See page_test_and_clear_young for
+	 * details.
+	 */
+	return 0;
 }
 
 /*
@@ -461,8 +458,8 @@
  */
 extern inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
-	pte_val(pte) &= PAGE_MASK | _PAGE_ISCLEAN;
-	pte_val(pte) |= pgprot_val(newprot) & ~_PAGE_ISCLEAN;
+	pte_val(pte) &= PAGE_MASK;
+	pte_val(pte) |= pgprot_val(newprot);
 	return pte;
 }
 
@@ -476,7 +473,7 @@
 
 extern inline pte_t pte_mkwrite(pte_t pte) 
 {
-	pte_val(pte) &= ~(_PAGE_RO | _PAGE_ISCLEAN);
+	pte_val(pte) &= ~_PAGE_RO;
 	return pte;
 }
 
@@ -516,13 +513,7 @@
 
 static inline int ptep_test_and_clear_young(pte_t *ptep)
 {
-	int ccode;
-
-	asm volatile ("rrbe 0,%1\n\t"
-		      "ipm  %0\n\t"
-		      "srl  %0,28\n\t" 
-                      : "=d" (ccode) : "a" (pte_val(*ptep)) : "cc" );
-	return ccode & 2;
+	return 0;
 }
 
 static inline int
@@ -535,18 +526,7 @@
 
 static inline int ptep_test_and_clear_dirty(pte_t *ptep)
 {
-	int skey;
-
-	if (pte_val(*ptep) & _PAGE_ISCLEAN)
-		return 0;
-	asm volatile ("iske %0,%1" : "=d" (skey) : "a" (*ptep));
-	if ((skey & _PAGE_CHANGED) == 0)
-		return 0;
-	/* We can't clear the changed bit atomically. For now we
-         * clear (!) the page referenced bit. */
-	asm volatile ("sske %0,%1" 
-	              : : "d" (0), "a" (*ptep));
-	return 1;
+	return 0;
 }
 
 static inline int
@@ -603,6 +583,42 @@
 }
 
 /*
+ * Test and clear dirty bit in storage key.
+ * We can't clear the changed bit atomically. This is a potential
+ * race against modification of the referenced bit. This function
+ * should therefore only be called if it is not mapped in any
+ * address space.
+ */
+#define page_test_and_clear_dirty(page)					  \
+({									  \
+	struct page *__page = (page);					  \
+	unsigned long __physpage = __pa((__page-mem_map) << PAGE_SHIFT);  \
+	int __skey;							  \
+	asm volatile ("iske %0,%1" : "=d" (__skey) : "a" (__physpage));   \
+	if (__skey & _PAGE_CHANGED) {					  \
+		asm volatile ("sske %0,%1"				  \
+			      : : "d" (__skey & ~_PAGE_CHANGED),	  \
+			          "a" (__physpage));			  \
+	}								  \
+	(__skey & _PAGE_CHANGED);					  \
+})
+
+/*
+ * Test and clear referenced bit in storage key.
+ */
+#define page_test_and_clear_young(page)					  \
+({									  \
+	struct page *__page = (page);					  \
+	unsigned long __physpage = __pa((__page-mem_map) << PAGE_SHIFT);  \
+	int __ccode;							  \
+	asm volatile ("rrbe 0,%1\n\t"					  \
+		      "ipm  %0\n\t"					  \
+		      "srl  %0,28\n\t" 					  \
+                      : "=d" (__ccode) : "a" (__physpage) : "cc" );	  \
+	(__ccode & 2);							  \
+})
+
+/*
  * Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
  */
@@ -782,6 +798,8 @@
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTEP_MKDIRTY
 #define __HAVE_ARCH_PTE_SAME
+#define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_DIRTY
+#define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_YOUNG
 #include <asm-generic/pgtable.h>
 
 #endif /* _S390_PAGE_H */
diff -urN linux-2.6/mm/msync.c linux-2.6-s390/mm/msync.c
--- linux-2.6/mm/msync.c	Fri Nov 21 16:20:28 2003
+++ linux-2.6-s390/mm/msync.c	Fri Nov 21 16:20:28 2003
@@ -24,16 +24,15 @@
 	unsigned long address, unsigned int flags)
 {
 	pte_t pte = *ptep;
+	unsigned long pfn = pte_pfn(pte);
+	struct page *page;
 
-	if (pte_present(pte) && pte_dirty(pte)) {
-		struct page *page;
-		unsigned long pfn = pte_pfn(pte);
-		if (pfn_valid(pfn)) {
-			page = pfn_to_page(pfn);
-			if (!PageReserved(page) &&
-			    ptep_clear_flush_dirty(vma, address, ptep))
-				set_page_dirty(page);
-		}
+	if (pte_present(pte) && pfn_valid(pfn)) {
+		page = pfn_to_page(pfn);
+		if (!PageReserved(page) &&
+		    (ptep_clear_flush_dirty(vma, address, ptep) ||
+		     page_test_and_clear_dirty(page)))
+			set_page_dirty(page);
 	}
 	return 0;
 }
diff -urN linux-2.6/mm/rmap.c linux-2.6-s390/mm/rmap.c
--- linux-2.6/mm/rmap.c	Fri Nov 21 16:20:28 2003
+++ linux-2.6-s390/mm/rmap.c	Fri Nov 21 16:20:28 2003
@@ -117,6 +117,9 @@
 	struct pte_chain *pc;
 	int referenced = 0;
 
+	if (page_test_and_clear_young(page))
+		mark_page_accessed(page);
+
 	if (TestClearPageReferenced(page))
 		referenced++;
 
@@ -267,6 +270,8 @@
 		}
 	}
 out:
+	if (page->pte.direct == 0 && page_test_and_clear_dirty(page))
+		set_page_dirty(page);
 	if (!page_mapped(page))
 		dec_page_state(nr_mapped);
 out_unlock:
@@ -356,7 +361,6 @@
 		set_page_dirty(page);
 
 	mm->rss--;
-	page_cache_release(page);
 	ret = SWAP_SUCCESS;
 
 out_unlock:
@@ -395,6 +399,9 @@
 	if (PageDirect(page)) {
 		ret = try_to_unmap_one(page, page->pte.direct);
 		if (ret == SWAP_SUCCESS) {
+			if (page_test_and_clear_dirty(page))
+				set_page_dirty(page);
+			page_cache_release(page);
 			page->pte.direct = 0;
 			ClearPageDirect(page);
 		}
@@ -431,6 +438,10 @@
 				} else {
 					start->next_and_idx++;
 				}
+				if (page->pte.direct == 0 &&
+				    page_test_and_clear_dirty(page))
+					set_page_dirty(page);
+				page_cache_release(page);
 				break;
 			case SWAP_AGAIN:
 				/* Skip this pte, remembering status. */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
