Subject: [RFC/PATCH 02/15 v3] preparation: host memory management changes
	for s390 kvm
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1206458154.6217.12.camel@cotte.boeblingen.de.ibm.com>
References: <1206030270.6690.51.camel@cotte.boeblingen.de.ibm.com>
	 <1206205354.7177.82.camel@cotte.boeblingen.de.ibm.com>
	 <1206458154.6217.12.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Tue, 25 Mar 2008 18:47:12 +0100
Message-Id: <1206467232.6507.38.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, os@de.ibm.com, borntraeger@de.ibm.com, hollisb@us.ibm.com, EHRHARDT@de.ibm.com, jeroney@us.ibm.com, aliguori@us.ibm.com, jblunck@suse.de, rvdheij@gmail.com, rusty@rustcorp.com.au, arnd@arndb.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>, oliver.paukstadt@millenux.com
List-ID: <linux-mm.kvack.org>

This patch changes the s390 memory management defintions to use the pgste field
for dirty and reference bit tracking of host and guest code. Usually on s390, 
dirty and referenced are tracked in storage keys, which belong to the physical
page. This changes with virtualization: The guest and host dirty/reference bits
are defined to be the logical OR of the values for the mapping and the physical
page. This patch implements the necessary changes in pgtable.h for s390.


There is a common code change in mm/rmap.c, the call to page_test_and_clear_young
must be moved. This is a no-op for all architecture but s390. page_referenced
checks the referenced bits for the physiscal page and for all mappings:
o The physical page is checked with page_test_and_clear_young.
o The mappings are checked with ptep_test_and_clear_young and friends.

Without pgstes (the current implementation on Linux s390) the physical page
check is implemented but the mapping callbacks are no-ops because dirty 
and referenced are not tracked in the s390 page tables. The pgstes introduces 
guest and host dirty and reference bits for s390 in the host mapping. These
mapping must be checked before page_test_and_clear_young resets the reference
bit. 

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---
 include/asm-s390/pgtable.h |   92 +++++++++++++++++++++++++++++++++++++++++++--
 mm/rmap.c                  |    7 +--
 2 files changed, 93 insertions(+), 6 deletions(-)

Index: kvm/include/asm-s390/pgtable.h
===================================================================
--- kvm.orig/include/asm-s390/pgtable.h
+++ kvm/include/asm-s390/pgtable.h
@@ -30,6 +30,7 @@
  */
 #ifndef __ASSEMBLY__
 #include <linux/mm_types.h>
+#include <asm/bitops.h>
 #include <asm/bug.h>
 #include <asm/processor.h>
 
@@ -258,6 +259,13 @@ extern char empty_zero_page[PAGE_SIZE];
  * swap pte is 1011 and 0001, 0011, 0101, 0111 are invalid.
  */
 
+/* Page status table bits for virtualization */
+#define RCP_PCL_BIT	55
+#define RCP_HR_BIT	54
+#define RCP_HC_BIT	53
+#define RCP_GR_BIT	50
+#define RCP_GC_BIT	49
+
 #ifndef __s390x__
 
 /* Bits in the segment table address-space-control-element */
@@ -513,6 +521,48 @@ static inline int pte_file(pte_t pte)
 #define __HAVE_ARCH_PTE_SAME
 #define pte_same(a,b)  (pte_val(a) == pte_val(b))
 
+static inline void rcp_lock(pte_t *ptep)
+{
+#ifdef CONFIG_PGSTE
+	unsigned long *pgste = (unsigned long *) (ptep + PTRS_PER_PTE);
+	preempt_disable();
+	while (test_and_set_bit(RCP_PCL_BIT, pgste))
+		;
+#endif
+}
+
+static inline void rcp_unlock(pte_t *ptep)
+{
+#ifdef CONFIG_PGSTE
+	unsigned long *pgste = (unsigned long *) (ptep + PTRS_PER_PTE);
+	clear_bit(RCP_PCL_BIT, pgste);
+	preempt_enable();
+#endif
+}
+
+/* forward declaration for SetPageUptodate in page-flags.h*/
+static inline void page_clear_dirty(struct page *page);
+#include <linux/page-flags.h>
+
+static inline void ptep_rcp_copy(pte_t *ptep)
+{
+#ifdef CONFIG_PGSTE
+	struct page *page = virt_to_page(pte_val(*ptep));
+	unsigned int skey;
+	unsigned long *pgste = (unsigned long *) (ptep + PTRS_PER_PTE);
+
+	skey = page_get_storage_key(page_to_phys(page));
+	if (skey & _PAGE_CHANGED)
+		set_bit(RCP_GC_BIT, pgste);
+	if (skey & _PAGE_REFERENCED)
+		set_bit(RCP_GR_BIT, pgste);
+	if (test_and_clear_bit(RCP_HC_BIT, pgste))
+		SetPageDirty(page);
+	if (test_and_clear_bit(RCP_HR_BIT, pgste))
+		SetPageReferenced(page);
+#endif
+}
+
 /*
  * query functions pte_write/pte_dirty/pte_young only work if
  * pte_present() is true. Undefined behaviour if not..
@@ -599,6 +649,8 @@ static inline void pmd_clear(pmd_t *pmd)
 
 static inline void pte_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
+	if (mm->context.pgstes)
+		ptep_rcp_copy(ptep);
 	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
 	if (mm->context.noexec)
 		pte_val(ptep[PTRS_PER_PTE]) = _PAGE_TYPE_EMPTY;
@@ -667,6 +719,24 @@ static inline pte_t pte_mkyoung(pte_t pt
 static inline int ptep_test_and_clear_young(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
 {
+#ifdef CONFIG_PGSTE
+	unsigned long physpage;
+	int young;
+	unsigned long *pgste;
+
+	if (!vma->vm_mm->context.pgstes)
+		return 0;
+	physpage = pte_val(*ptep) & PAGE_MASK;
+	pgste = (unsigned long *) (ptep + PTRS_PER_PTE);
+
+	young = ((page_get_storage_key(physpage) & _PAGE_REFERENCED) != 0);
+	rcp_lock(ptep);
+	if (young)
+		set_bit(RCP_GR_BIT, pgste);
+	young |= test_and_clear_bit(RCP_HR_BIT, pgste);
+	rcp_unlock(ptep);
+	return young;
+#endif
 	return 0;
 }
 
@@ -674,7 +744,13 @@ static inline int ptep_test_and_clear_yo
 static inline int ptep_clear_flush_young(struct vm_area_struct *vma,
 					 unsigned long address, pte_t *ptep)
 {
-	/* No need to flush TLB; bits are in storage key */
+	/* No need to flush TLB
+	 * On s390 reference bits are in storage key and never in TLB
+	 * With virtualization we handle the reference bit, without we
+	 * we can simply return */
+#ifdef CONFIG_PGSTE
+	return ptep_test_and_clear_young(vma, address, ptep);
+#endif
 	return 0;
 }
 
@@ -693,15 +769,25 @@ static inline void __ptep_ipte(unsigned 
 			: "=m" (*ptep) : "m" (*ptep),
 			  "a" (pto), "a" (address));
 	}
-	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
 }
 
 static inline void ptep_invalidate(struct mm_struct *mm,
 				   unsigned long address, pte_t *ptep)
 {
+	if (mm->context.pgstes) {
+		rcp_lock(ptep);
+		__ptep_ipte(address, ptep);
+		ptep_rcp_copy(ptep);
+		pte_val(*ptep) = _PAGE_TYPE_EMPTY;
+		rcp_unlock(ptep);
+		return;
+	}
 	__ptep_ipte(address, ptep);
-	if (mm->context.noexec)
+	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
+	if (mm->context.noexec) {
 		__ptep_ipte(address, ptep + PTRS_PER_PTE);
+		pte_val(*(ptep + PTRS_PER_PTE)) = _PAGE_TYPE_EMPTY;
+	}
 }
 
 /*
Index: kvm/mm/rmap.c
===================================================================
--- kvm.orig/mm/rmap.c
+++ kvm/mm/rmap.c
@@ -413,9 +413,6 @@ int page_referenced(struct page *page, i
 {
 	int referenced = 0;
 
-	if (page_test_and_clear_young(page))
-		referenced++;
-
 	if (TestClearPageReferenced(page))
 		referenced++;
 
@@ -433,6 +430,10 @@ int page_referenced(struct page *page, i
 			unlock_page(page);
 		}
 	}
+
+	if (page_test_and_clear_young(page))
+		referenced++;
+
 	return referenced;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
