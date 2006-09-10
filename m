Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8AD9RSZ176600
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 13:09:27 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8ADBZog1974400
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 14:11:35 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8AD9Q1U009413
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 14:09:26 +0100
Date: Sun, 10 Sep 2006 15:08:32 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [patch 2/2] convert s390 page handling macros to functions v3
Message-ID: <20060910130832.GB12084@osiris.ibm.com>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.64.0609092248400.6762@scrub.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609092248400.6762@scrub.home>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

 
Convert s390 page handling macros to functions. In particular this fixes a
problem with s390's SetPageUptodate macro which uses its input parameter
twice which again can cause subtle bugs.
 
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
--- 

 include/asm-s390/pgtable.h |   85 +++++++++++++++++++++------------------------
 include/linux/page-flags.h |   11 ++---
 2 files changed, 46 insertions(+), 50 deletions(-)

Index: linux-2.6.18-rc6-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/page-flags.h	2006-09-10 14:40:07.000000000 +0200
+++ linux-2.6.18-rc6-mm1/include/linux/page-flags.h	2006-09-10 14:54:08.000000000 +0200
@@ -130,12 +130,11 @@
 
 #define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
 #ifdef CONFIG_S390
-#define SetPageUptodate(_page) \
-	do {								      \
-		struct page *__page = (_page);				      \
-		if (!test_and_set_bit(PG_uptodate, &__page->flags))	      \
-			page_test_and_clear_dirty(_page);		      \
-	} while (0)
+static inline void SetPageUptodate(struct page *page)
+{
+	if (!test_and_set_bit(PG_uptodate, &page->flags))
+		page_test_and_clear_dirty(page);
+}
 #else
 #define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
 #endif
Index: linux-2.6.18-rc6-mm1/include/asm-s390/pgtable.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/asm-s390/pgtable.h	2006-09-10 14:40:07.000000000 +0200
+++ linux-2.6.18-rc6-mm1/include/asm-s390/pgtable.h	2006-09-10 14:54:34.000000000 +0200
@@ -31,9 +31,9 @@
  * the S390 page table tree.
  */
 #ifndef __ASSEMBLY__
+#include <linux/mm_types.h>
 #include <asm/bug.h>
 #include <asm/processor.h>
-#include <linux/threads.h>
 
 struct vm_area_struct; /* forward declaration (include/linux/mm.h) */
 struct mm_struct;
@@ -604,30 +604,31 @@
  * should therefore only be called if it is not mapped in any
  * address space.
  */
-#define page_test_and_clear_dirty(_page)				  \
-({									  \
-	struct page *__page = (_page);					  \
-	unsigned long __physpage = __pa((__page-mem_map) << PAGE_SHIFT);  \
-	int __skey = page_get_storage_key(__physpage);			  \
-	if (__skey & _PAGE_CHANGED)					  \
-		page_set_storage_key(__physpage, __skey & ~_PAGE_CHANGED);\
-	(__skey & _PAGE_CHANGED);					  \
-})
+static inline int page_test_and_clear_dirty(struct page *page)
+{
+	unsigned long physpage = __pa((page - mem_map) << PAGE_SHIFT);
+	int skey = page_get_storage_key(physpage);
+
+	if (skey & _PAGE_CHANGED)
+		page_set_storage_key(physpage, skey & ~_PAGE_CHANGED);
+	return skey & _PAGE_CHANGED;
+}
 
 /*
  * Test and clear referenced bit in storage key.
  */
-#define page_test_and_clear_young(page)					  \
-({									  \
-	struct page *__page = (page);					  \
-	unsigned long __physpage = __pa((__page-mem_map) << PAGE_SHIFT);  \
-	int __ccode;							  \
-	asm volatile ("rrbe 0,%1\n\t"					  \
-		      "ipm  %0\n\t"					  \
-		      "srl  %0,28\n\t" 					  \
-                      : "=d" (__ccode) : "a" (__physpage) : "cc" );	  \
-	(__ccode & 2);							  \
-})
+static inline int page_test_and_clear_young(struct page *page)
+{
+	unsigned long physpage = __pa((page - mem_map) << PAGE_SHIFT);
+	int ccode;
+
+	asm volatile (
+		"rrbe 0,%1\n"
+		"ipm  %0\n"
+		"srl  %0,28\n"
+		: "=d" (ccode) : "a" (physpage) : "cc" );
+	return ccode & 2;
+}
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
@@ -640,32 +641,28 @@
 	return __pte;
 }
 
-#define mk_pte(pg, pgprot)                                                \
-({                                                                        \
-	struct page *__page = (pg);                                       \
-	pgprot_t __pgprot = (pgprot);					  \
-	unsigned long __physpage = __pa((__page-mem_map) << PAGE_SHIFT);  \
-	pte_t __pte = mk_pte_phys(__physpage, __pgprot);                  \
-	__pte;                                                            \
-})
-
-#define pfn_pte(pfn, pgprot)                                              \
-({                                                                        \
-	pgprot_t __pgprot = (pgprot);					  \
-	unsigned long __physpage = __pa((pfn) << PAGE_SHIFT);             \
-	pte_t __pte = mk_pte_phys(__physpage, __pgprot);                  \
-	__pte;                                                            \
-})
+static inline pte_t mk_pte(struct page *page, pgprot_t pgprot)
+{
+	unsigned long physpage = __pa((page - mem_map) << PAGE_SHIFT);
+
+	return mk_pte_phys(physpage, pgprot);
+}
+
+static inline pte_t pfn_pte(unsigned long pfn, pgprot_t pgprot)
+{
+	unsigned long physpage = __pa((pfn) << PAGE_SHIFT);
+
+	return mk_pte_phys(physpage, pgprot);
+}
 
 #ifdef __s390x__
 
-#define pfn_pmd(pfn, pgprot)                                              \
-({                                                                        \
-	pgprot_t __pgprot = (pgprot);                                     \
-	unsigned long __physpage = __pa((pfn) << PAGE_SHIFT);             \
-	pmd_t __pmd = __pmd(__physpage + pgprot_val(__pgprot));           \
-	__pmd;                                                            \
-})
+static inline pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
+{
+	unsigned long physpage = __pa((pfn) << PAGE_SHIFT);
+
+	return __pmd(physpage + pgprot_val(pgprot));
+}
 
 #endif /* __s390x__ */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
