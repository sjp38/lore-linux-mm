Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4F5A06B011A
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 14:18:30 -0400 (EDT)
Message-Id: <201203281818.q2SIIS59027945@farm-0027.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Wed, 28 Mar 2012 13:59:18 -0400
Subject: [PATCH] arch/tile: allow building Linux with transparent huge pages enabled
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Dmitry Torokhov <dmitry.torokhov@gmail.com>, Lucas De Marchi <lucas.demarchi@profusion.mobi>, linux-arch@vger.kernel.org, linux-mm@kvack.org

The change adds some infrastructure for managing tile pmd's more generally,
using pte_pmd() and pmd_pte() methods to translate pmd values to and
from ptes, since on TILEPro a pmd is really just a nested structure
holding a pgd (aka pte).  Several existing pmd methods are moved into
this framework, and a whole raft of additional pmd accessors are defined
that are used by the transparent hugepage framework.

The tile PTE now has a "client2" bit.  The bit is used to indicate a
transparent huge page is in the process of being split into subpages.

This change also fixes a generic bug where the return value of the
generic pmdp_splitting_flush() was incorrect.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
The extra cc's on this email are just for the generic
pmdp_splitting_flush() signature change, so any Ack for that
is mostly what I'd appreciate.  Thanks!

 arch/tile/include/asm/pgtable.h    |   89 +++++++++++++++++++++++++++++++++--
 arch/tile/include/asm/pgtable_32.h |   26 +++-------
 arch/tile/include/asm/pgtable_64.h |   29 +++---------
 arch/tile/include/hv/hypervisor.h  |   11 ++++-
 include/asm-generic/pgtable.h      |    5 +-
 mm/pgtable-generic.c               |    4 +-
 6 files changed, 111 insertions(+), 53 deletions(-)

diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 1a20b7e..17ad0ed 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -188,6 +188,7 @@ static inline void __pte_clear(pte_t *ptep)
  * Undefined behaviour if not..
  */
 #define pte_present hv_pte_get_present
+#define pte_mknotpresent hv_pte_clear_present
 #define pte_user hv_pte_get_user
 #define pte_read hv_pte_get_readable
 #define pte_dirty hv_pte_get_dirty
@@ -313,7 +314,7 @@ extern void check_mm_caching(struct mm_struct *prev, struct mm_struct *next);
  */
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
-	return pfn_pte(hv_pte_get_pfn(pte), newprot);
+	return pfn_pte(pte_pfn(pte), newprot);
 }
 
 /*
@@ -411,6 +412,46 @@ static inline unsigned long pmd_index(unsigned long address)
 	return (address >> PMD_SHIFT) & (PTRS_PER_PMD - 1);
 }
 
+#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
+static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+					    unsigned long address,
+					    pmd_t *pmdp)
+{
+	return ptep_test_and_clear_young(vma, address, pmdp_ptep(pmdp));
+}
+
+#define __HAVE_ARCH_PMDP_SET_WRPROTECT
+static inline void pmdp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long address, pmd_t *pmdp)
+{
+	ptep_set_wrprotect(mm, address, pmdp_ptep(pmdp));
+}
+
+
+#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm,
+				       unsigned long address,
+				       pmd_t *pmdp)
+{
+	return pte_pmd(ptep_get_and_clear(mm, address, pmdp_ptep(pmdp)));
+}
+
+static inline void __set_pmd(pmd_t *pmdp, pmd_t pmdval)
+{
+	set_pte(pmdp_ptep(pmdp), pmd_pte(pmdval));
+}
+
+#define set_pmd_at(mm, addr, pmdp, pmdval) __set_pmd(pmdp, pmdval)
+
+/* Create a pmd from a PTFN. */
+static inline pmd_t ptfn_pmd(unsigned long ptfn, pgprot_t prot)
+{
+	return pte_pmd(hv_pte_set_ptfn(prot, ptfn));
+}
+
+/* Return the page-table frame number (ptfn) that a pmd_t points at. */
+#define pmd_ptfn(pmd) hv_pte_get_ptfn(pmd_pte(pmd))
+
 /*
  * A given kernel pmd_t maps to a specific virtual address (either a
  * kernel huge page or a kernel pte_t table).  Since kernel pte_t
@@ -433,6 +474,47 @@ static inline unsigned long pmd_page_vaddr(pmd_t pmd)
  */
 #define pmd_page(pmd) pfn_to_page(HV_PTFN_TO_PFN(pmd_ptfn(pmd)))
 
+static inline void pmd_clear(pmd_t *pmdp)
+{
+	__pte_clear(pmdp_ptep(pmdp));
+}
+
+#define pmd_mknotpresent(pmd)	pte_pmd(pte_mknotpresent(pmd_pte(pmd)))
+#define pmd_young(pmd)		pte_young(pmd_pte(pmd))
+#define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
+#define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
+#define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
+#define pmd_write(pmd)		pte_write(pmd_pte(pmd))
+#define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
+#define pmd_mkdirty(pmd)	pte_pmd(pte_mkdirty(pmd_pte(pmd)))
+#define pmd_huge_page(pmd)	pte_huge(pmd_pte(pmd))
+#define pmd_mkhuge(pmd)		pte_pmd(pte_mkhuge(pmd_pte(pmd)))
+#define __HAVE_ARCH_PMD_WRITE
+
+#define pfn_pmd(pfn, pgprot)	pte_pmd(pfn_pte((pfn), (pgprot)))
+#define pmd_pfn(pmd)		pte_pfn(pmd_pte(pmd))
+#define mk_pmd(page, pgprot)	pfn_pmd(page_to_pfn(page), (pgprot))
+
+static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	return pfn_pmd(pmd_pfn(pmd), newprot);
+}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define has_transparent_hugepage() 1
+#define pmd_trans_huge pmd_huge_page
+
+static inline pmd_t pmd_mksplitting(pmd_t pmd)
+{
+	return pte_pmd(hv_pte_set_client2(pmd_pte(pmd)));
+}
+
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return hv_pte_get_client2(pmd_pte(pmd));
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 /*
  * The pte page can be thought of an array like this: pte_t[PTRS_PER_PTE]
  *
@@ -449,11 +531,6 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
        return (pte_t *)pmd_page_vaddr(*pmd) + pte_index(address);
 }
 
-static inline int pmd_huge_page(pmd_t pmd)
-{
-	return pmd_val(pmd) & _PAGE_HUGE_PAGE;
-}
-
 #include <asm-generic/pgtable.h>
 
 /* Support /proc/NN/pgtable API. */
diff --git a/arch/tile/include/asm/pgtable_32.h b/arch/tile/include/asm/pgtable_32.h
index 9f98529..27e20f6 100644
--- a/arch/tile/include/asm/pgtable_32.h
+++ b/arch/tile/include/asm/pgtable_32.h
@@ -111,24 +111,14 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 	return pte;
 }
 
-static inline void __set_pmd(pmd_t *pmdp, pmd_t pmdval)
-{
-	set_pte(&pmdp->pud.pgd, pmdval.pud.pgd);
-}
-
-/* Create a pmd from a PTFN. */
-static inline pmd_t ptfn_pmd(unsigned long ptfn, pgprot_t prot)
-{
-	return (pmd_t){ { hv_pte_set_ptfn(prot, ptfn) } };
-}
-
-/* Return the page-table frame number (ptfn) that a pmd_t points at. */
-#define pmd_ptfn(pmd) hv_pte_get_ptfn((pmd).pud.pgd)
-
-static inline void pmd_clear(pmd_t *pmdp)
-{
-	__pte_clear(&pmdp->pud.pgd);
-}
+/*
+ * pmds are wrappers around pgds, which are the same as ptes.
+ * It's often convenient to "cast" back and forth and use the pte methods,
+ * which are the methods supplied by the hypervisor.
+ */
+#define pmd_pte(pmd) ((pmd).pud.pgd)
+#define pmdp_ptep(pmdp) (&(pmdp)->pud.pgd)
+#define pte_pmd(pte) ((pmd_t){ { (pte) } })
 
 #endif /* __ASSEMBLY__ */
 
diff --git a/arch/tile/include/asm/pgtable_64.h b/arch/tile/include/asm/pgtable_64.h
index fd80328..e105f3a 100644
--- a/arch/tile/include/asm/pgtable_64.h
+++ b/arch/tile/include/asm/pgtable_64.h
@@ -108,28 +108,6 @@ static inline unsigned long pud_index(unsigned long address)
 #define pmd_offset(pud, address) \
 	((pmd_t *)pud_page_vaddr(*(pud)) + pmd_index(address))
 
-static inline void __set_pmd(pmd_t *pmdp, pmd_t pmdval)
-{
-	set_pte(pmdp, pmdval);
-}
-
-/* Create a pmd from a PTFN and pgprot. */
-static inline pmd_t ptfn_pmd(unsigned long ptfn, pgprot_t prot)
-{
-	return hv_pte_set_ptfn(prot, ptfn);
-}
-
-/* Return the page-table frame number (ptfn) that a pmd_t points at. */
-static inline unsigned long pmd_ptfn(pmd_t pmd)
-{
-	return hv_pte_get_ptfn(pmd);
-}
-
-static inline void pmd_clear(pmd_t *pmdp)
-{
-	__pte_clear(pmdp);
-}
-
 /* Normalize an address to having the correct high bits set. */
 #define pgd_addr_normalize pgd_addr_normalize
 static inline unsigned long pgd_addr_normalize(unsigned long addr)
@@ -170,6 +148,13 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 	return hv_pte(__insn_exch(&ptep->val, 0UL));
 }
 
+/*
+ * pmds are the same as pgds and ptes, so converting is a no-op.
+ */
+#define pmd_pte(pmd) (pmd)
+#define pmdp_ptep(pmdp) (pmdp)
+#define pte_pmd(pte) (pte)
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_TILE_PGTABLE_64_H */
diff --git a/arch/tile/include/hv/hypervisor.h b/arch/tile/include/hv/hypervisor.h
index 72ec1e9..793123e 100644
--- a/arch/tile/include/hv/hypervisor.h
+++ b/arch/tile/include/hv/hypervisor.h
@@ -1855,8 +1855,7 @@ int hv_flush_remote(HV_PhysAddr cache_pa, unsigned long cache_control,
                                               future use. */
 #define HV_PTE_INDEX_MODE            16  /**< Page mode; see HV_PTE_MODE_xxx */
 #define HV_PTE_MODE_BITS              3  /**< Number of bits in mode */
-                                         /*   Bit 19 is reserved for
-                                              future use. */
+#define HV_PTE_INDEX_CLIENT2         19  /**< Page client state 2 */
 #define HV_PTE_INDEX_LOTAR           20  /**< Page's LOTAR; must be high bits
                                               of word */
 #define HV_PTE_LOTAR_BITS            12  /**< Number of bits in a LOTAR */
@@ -2046,6 +2045,13 @@ int hv_flush_remote(HV_PhysAddr cache_pa, unsigned long cache_control,
  */
 #define HV_PTE_CLIENT1               (__HV_PTE_ONE << HV_PTE_INDEX_CLIENT1)
 
+/** Client-private bit in PTE.
+ *
+ * This bit is guaranteed not to be inspected or modified by the
+ * hypervisor.
+ */
+#define HV_PTE_CLIENT2               (__HV_PTE_ONE << HV_PTE_INDEX_CLIENT2)
+
 /** Non-coherent (NC) bit in PTE.
  *
  * If this bit is set, the mapping that is set up will be non-coherent
@@ -2180,6 +2186,7 @@ _HV_BIT(present,         PRESENT)
 _HV_BIT(page,            PAGE)
 _HV_BIT(client0,         CLIENT0)
 _HV_BIT(client1,         CLIENT1)
+_HV_BIT(client2,         CLIENT2)
 _HV_BIT(migrating,       MIGRATING)
 _HV_BIT(nc,              NC)
 _HV_BIT(readable,        READABLE)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 76bff2b..c21959f 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -157,9 +157,8 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern pmd_t pmdp_splitting_flush(struct vm_area_struct *vma,
-				  unsigned long address,
-				  pmd_t *pmdp);
+extern void pmdp_splitting_flush(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp);
 #endif
 
 #ifndef __HAVE_ARCH_PTE_SAME
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index eb663fb..326bb60 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -108,8 +108,8 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 
 #ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-pmd_t pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			   pmd_t *pmdp)
+void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
 {
 	pmd_t pmd = pmd_mksplitting(*pmdp);
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
