Message-Id: <20080328015422.497634000@nick.local0.net>
References: <20080328015238.519230000@nick.local0.net>
Date: Fri, 28 Mar 2008 12:52:44 +1100
From: npiggin@suse.de
Subject: [patch 6/7] s390: implement pte special bit
Content-Disposition: inline; filename=s390-implement-pte_special.patch
To: akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Carsten Otte <cotte@de.ibm.com>

Implement pte_special pte bit for s390. s390 has trouble making pfn_valid
do exactly what we'd like for VM_MIXEDMAP, because it has a very dynamic
memory model, and it would have to take a semaphore and walk a list for
each pfn_valid call. Use pte_special instead which is just a single bit
test.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jared Hulbert <jaredeh@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 include/asm-s390/pgtable.h |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/include/asm-s390/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-s390/pgtable.h
+++ linux-2.6/include/asm-s390/pgtable.h
@@ -219,6 +219,8 @@ extern char empty_zero_page[PAGE_SIZE];
 /* Software bits in the page table entry */
 #define _PAGE_SWT	0x001		/* SW pte type bit t */
 #define _PAGE_SWX	0x002		/* SW pte type bit x */
+#define _PAGE_SPECIAL	0x004		/* SW associated with special page */
+#define __HAVE_ARCH_PTE_SPECIAL
 
 /* Six different types of pages. */
 #define _PAGE_TYPE_EMPTY	0x400
@@ -512,7 +514,7 @@ static inline int pte_file(pte_t pte)
 
 static inline int pte_special(pte_t pte)
 {
-	return 0;
+	return (pte_val(pte) & _PAGE_SPECIAL);
 }
 
 #define __HAVE_ARCH_PTE_SAME
@@ -670,6 +672,7 @@ static inline pte_t pte_mkyoung(pte_t pt
 
 static inline pte_t pte_mkspecial(pte_t pte)
 {
+	pte_val(pte) |= _PAGE_SPECIAL;
 	return pte;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
