Date: Thu, 22 May 2003 13:20:00 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] dirty bit clearing on s390.
Message-ID: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@digeo.com, phillips@arcor.de
List-ID: <linux-mm.kvack.org>

Hi,
I'd like to propose a small change in the common memory management that
would enable s390 to get its dirty bits finally right. The change is a
architecture hook in SetPageUptodate.

The problem I want to solve: s390 does not keept its dirty bits in the
page table entries like other architectures do but in the "storage key".
The storage key is a 8 bit value associated with each physical(!) page.
It is accessed with some special instructions (iske, ivsk, sske, rrbe).
The storage key contains the access-control bits, the fetch-protection
bit, the referenced bit and the change bit (=dirty bit). Linux only
uses the referenced and the change/dirty bit.
This means that each physical page always has a dirty bit. On i386 a
page is implicitly clean if no page table entry points to it (and
PG_dirty is 0). This is not true on s390. A new page without any pte
pointing to it usually starts off dirty because nobody has reset the
dirty bit in the storage key. Worse, a write access due to i/o will
set the dirty bit! We need to clear the dirty bit somewhere or we'll
end up writing every page back to the disk before it becomes clean.
Up to now s390 uses a special bit in the pte that is set in mk_pte
for the first user of a page and makes set_pte to clear the storage
key. The problem is that this is a race condition if two processes
want to access the same page simultaneously. Then the page count is
already > 1 in mk_pte and nobody will clear the storage key. It
doesn't lead to any data loss because what happens is that a clean
page is considered dirty and is written back to the disk. The worst
scenario is a read only disk where this results in i/o errors (but no
data loss). 
Our solution is to move the clearing of the storage key (dirty bit)
from set_pte to SetPageUptodate. A patch that implements this is
attached. What do you think ?

blue skies,
  Martin.
----

Move clearing of the dirty bit from mk_pte/set_pte to SetPageUptodate.

diffstat:
 include/asm-s390/pgtable.h |   33 ++++++++-------------------------
 include/linux/page-flags.h |   11 ++++++++++-
 2 files changed, 18 insertions(+), 26 deletions(-)

diff -urN linux-2.5.69/include/asm-s390/pgtable.h linux-2.5.69-s390/include/asm-s390/pgtable.h
--- linux-2.5.69/include/asm-s390/pgtable.h	Thu May 22 10:42:25 2003
+++ linux-2.5.69-s390/include/asm-s390/pgtable.h	Thu May 22 10:42:32 2003
@@ -212,8 +212,7 @@
 #define _PAGE_INVALID   0x400          /* HW invalid                       */
 
 /* Software bits in the page table entry */
-#define _PAGE_MKCLEAN   0x002
-#define _PAGE_ISCLEAN   0x004
+#define _PAGE_ISCLEAN   0x002
 
 /* Mask and four different kinds of invalid pages. */
 #define _PAGE_INVALID_MASK	0x601
@@ -320,15 +319,6 @@
  */
 extern inline void set_pte(pte_t *pteptr, pte_t pteval)
 {
-	if ((pte_val(pteval) & (_PAGE_MKCLEAN|_PAGE_INVALID))
-	    == _PAGE_MKCLEAN) 
-	{
-		pte_val(pteval) &= ~_PAGE_MKCLEAN;
-               
-		asm volatile ("sske %0,%1" 
-				: : "d" (0), "a" (pte_val(pteval)));
-	}
-
 	*pteptr = pteval;
 }
 
@@ -501,7 +491,7 @@
 	 * sske instruction is slow. It is faster to let the
 	 * next instruction set the dirty bit.
 	 */
-	pte_val(pte) &= ~(_PAGE_MKCLEAN | _PAGE_ISCLEAN);
+	pte_val(pte) &= ~ _PAGE_ISCLEAN;
 	return pte;
 }
 
@@ -582,30 +572,23 @@
 	pgprot_t __pgprot = (pgprot);					  \
 	unsigned long __physpage = __pa((__page-mem_map) << PAGE_SHIFT);  \
 	pte_t __pte = mk_pte_phys(__physpage, __pgprot);                  \
-	                                                                  \
-	if (!(pgprot_val(__pgprot) & _PAGE_ISCLEAN)) {			  \
-		int __users = !!PagePrivate(__page) + !!__page->mapping;  \
-		if (__users + page_count(__page) == 1)                    \
-			pte_val(__pte) |= _PAGE_MKCLEAN;                  \
-	}								  \
 	__pte;                                                            \
 })
 
 #define pfn_pte(pfn, pgprot)                                              \
 ({                                                                        \
-	struct page *__page = mem_map+(pfn);                              \
 	pgprot_t __pgprot = (pgprot);					  \
 	unsigned long __physpage = __pa((pfn) << PAGE_SHIFT);             \
 	pte_t __pte = mk_pte_phys(__physpage, __pgprot);                  \
-	                                                                  \
-	if (!(pgprot_val(__pgprot) & _PAGE_ISCLEAN)) {			  \
-		int __users = !!PagePrivate(__page) + !!__page->mapping;  \
-		if (__users + page_count(__page) == 1)                    \
-			pte_val(__pte) |= _PAGE_MKCLEAN;                  \
-	}								  \
 	__pte;                                                            \
 })
 
+#define arch_set_page_uptodate(__page)					  \
+	do {								  \
+		asm volatile ("sske %0,%1" : : "d" (0),			  \
+			      "a" (__pa((__page-mem_map) << PAGE_SHIFT)));\
+	} while (0)
+
 #ifdef __s390x__
 
 #define pfn_pmd(pfn, pgprot)                                              \
diff -urN linux-2.5.69/include/linux/page-flags.h linux-2.5.69-s390/include/linux/page-flags.h
--- linux-2.5.69/include/linux/page-flags.h	Mon May  5 01:53:35 2003
+++ linux-2.5.69-s390/include/linux/page-flags.h	Thu May 22 10:42:32 2003
@@ -7,6 +7,7 @@
 
 #include <linux/percpu.h>
 #include <linux/cache.h>
+#include <asm/pgtable.h>
 
 /*
  * Various page->flags bits:
@@ -158,8 +159,16 @@
 #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define TestClearPageReferenced(page) test_and_clear_bit(PG_referenced, &(page)->flags)
 
+#ifndef arch_set_page_uptodate
+#define arch_set_page_uptodate(page)
+#endif
+
 #define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
-#define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
+#define SetPageUptodate(page) \
+	do {								\
+		arch_set_page_uptodate(page);				\
+		set_bit(PG_uptodate, &(page)->flags);			\
+	} while (0)
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
 #define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
