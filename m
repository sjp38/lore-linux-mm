Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 235256B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:54:13 -0400 (EDT)
Received: from EXHQ.corp.stratus.com (exhq.corp.stratus.com [134.111.201.100])
	by mailhub5.stratus.com (8.12.11/8.12.11) with ESMTP id p57KsALi001319
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 16:54:11 -0400
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: [PATCH] REPOST: Dirty page tracking for physical system migration
Date: Tue, 7 Jun 2011 16:54:10 -0400
Message-ID: <AC1B83CE65082B4DBDDB681ED2F6B2EF1ACDA0@EXHQ.corp.stratus.com>
From: "Paradis, James" <James.Paradis@stratus.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Apologies for that last broken post in HTML.  Try this again:

This patch implements a system to track re-dirtied pages and modified
PTEs.  It is used by Stratus Technologies for both our ftLinux product
and
our new GPL Live Kernel Self Migration project (lksm.sourceforge.net).
In both cases, we bring a backup server online by copying the primary
server's state while it is running.  We start by copying all of memory
top to bottom.  We then go back and re-copy any pages that were changed
during the first copy pass.  After several such passes we momentarily
suspend processing so we can copy the last few pages over and bring up
the secondary system.  This patch keeps track of which pages need to be
copied during these passes.

 arch/x86/Kconfig                      |   11 +++++++++++
 arch/x86/include/asm/hugetlb.h        |    3 +++
 arch/x86/include/asm/pgtable-2level.h |    4 ++++
 arch/x86/include/asm/pgtable-3level.h |   11 +++++++++++
 arch/x86/include/asm/pgtable.h        |    4 ++--
 arch/x86/include/asm/pgtable_32.h     |    1 +
 arch/x86/include/asm/pgtable_64.h     |    7 +++++++
 arch/x86/include/asm/pgtable_types.h  |    5 ++++-
 arch/x86/mm/Makefile                  |    2 ++
 mm/huge_memory.c                      |    4 ++--
 11 files changed, 48 insertions(+), 6 deletions(-)

Signed-off-by: "James Paradis" <james.paradis@stratus.com>

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cc6c53a..cc778a4 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1146,6 +1146,17 @@ config DIRECT_GBPAGES
 	  support it. This can improve the kernel's performance a tiny
bit by
 	  reducing TLB pressure. If in doubt, say "Y".
=20
+config TRACK_DIRTY_PAGES
+	bool "Enable dirty page tracking"
+	default n
+	depends on !KMEMCHECK
+	---help---
+	  Turning this on enables tracking of re-dirtied and
+	  changed pages.  This is needed by the Live Kernel
+	  Self Migration project (lksm.sourceforge.net) to perform
+	  live copying of memory and system state to another system.
+	  Most users will say n here.
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
diff --git a/arch/x86/include/asm/hugetlb.h
b/arch/x86/include/asm/hugetlb.h
index 439a9ac..8266873 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -2,6 +2,7 @@
 #define _ASM_X86_HUGETLB_H
=20
 #include <asm/page.h>
+#include <asm/mm_track.h>
=20
=20
 static inline int is_hugepage_only_range(struct mm_struct *mm,
@@ -39,12 +40,14 @@ static inline void hugetlb_free_pgd_range(struct
mmu_gather *tlb,
 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long
addr,
 				   pte_t *ptep, pte_t pte)
 {
+	mm_track_pmd((pmd_t *)ptep);
 	set_pte_at(mm, addr, ptep, pte);
 }
=20
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t
*ptep)
 {
+	mm_track_pmd((pmd_t *)ptep);
 	return ptep_get_and_clear(mm, addr, ptep);
 }
=20
diff --git a/arch/x86/include/asm/pgtable-2level.h
b/arch/x86/include/asm/pgtable-2level.h
index 98391db..a59deb5 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -13,11 +13,13 @@
  */
 static inline void native_set_pte(pte_t *ptep , pte_t pte)
 {
+	mm_track_pte(ptep);
 	*ptep =3D pte;
 }
=20
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
+	mm_track_pmd(pmdp);
 	*pmdp =3D pmd;
 }
=20
@@ -34,12 +36,14 @@ static inline void native_pmd_clear(pmd_t *pmdp)
 static inline void native_pte_clear(struct mm_struct *mm,
 				    unsigned long addr, pte_t *xp)
 {
+	mm_track_pte(xp);
 	*xp =3D native_make_pte(0);
 }
=20
 #ifdef CONFIG_SMP
 static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 {
+	mm_track_pte(xp);
 	return __pte(xchg(&xp->pte_low, 0));
 }
 #else
diff --git a/arch/x86/include/asm/pgtable-3level.h
b/arch/x86/include/asm/pgtable-3level.h
index effff47..b75d753 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -26,6 +26,7 @@
  */
 static inline void native_set_pte(pte_t *ptep, pte_t pte)
 {
+	mm_track_pte(ptep);
 	ptep->pte_high =3D pte.pte_high;
 	smp_wmb();
 	ptep->pte_low =3D pte.pte_low;
@@ -33,16 +34,19 @@ static inline void native_set_pte(pte_t *ptep, pte_t
pte)
=20
 static inline void native_set_pte_atomic(pte_t *ptep, pte_t pte)
 {
+	mm_track_pte(ptep);
 	set_64bit((unsigned long long *)(ptep), native_pte_val(pte));
 }
=20
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
+	mm_track_pmd(pmdp);
 	set_64bit((unsigned long long *)(pmdp), native_pmd_val(pmd));
 }
=20
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
 {
+	mm_track_pud(pudp);
 	set_64bit((unsigned long long *)(pudp), native_pud_val(pud));
 }
=20
@@ -54,6 +58,7 @@ static inline void native_set_pud(pud_t *pudp, pud_t
pud)
 static inline void native_pte_clear(struct mm_struct *mm, unsigned long
addr,
 				    pte_t *ptep)
 {
+	mm_track_pte(ptep);
 	ptep->pte_low =3D 0;
 	smp_wmb();
 	ptep->pte_high =3D 0;
@@ -62,6 +67,9 @@ static inline void native_pte_clear(struct mm_struct
*mm, unsigned long addr,
 static inline void native_pmd_clear(pmd_t *pmd)
 {
 	u32 *tmp =3D (u32 *)pmd;
+
+	mm_track_pmd(pmd);
+
 	*tmp =3D 0;
 	smp_wmb();
 	*(tmp + 1) =3D 0;
@@ -69,6 +77,7 @@ static inline void native_pmd_clear(pmd_t *pmd)
=20
 static inline void pud_clear(pud_t *pudp)
 {
+	mm_track_pud(pudp);
 	set_pud(pudp, __pud(0));
=20
 	/*
@@ -88,6 +97,8 @@ static inline pte_t native_ptep_get_and_clear(pte_t
*ptep)
 {
 	pte_t res;
=20
+	mm_track_pte(ptep);
+
 	/* xchg acts as a barrier before the setting of the high bits */
 	res.pte_low =3D xchg(&ptep->pte_low, 0);
 	res.pte_high =3D ptep->pte_high;
diff --git a/arch/x86/include/asm/pgtable.h
b/arch/x86/include/asm/pgtable.h
index 18601c8..30bb916 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -89,7 +89,7 @@ extern struct mm_struct *pgd_page_get_mm(struct page
*page);
  */
 static inline int pte_dirty(pte_t pte)
 {
-	return pte_flags(pte) & _PAGE_DIRTY;
+	return pte_flags(pte) & (_PAGE_DIRTY | _PAGE_SOFTDIRTY);
 }
=20
 static inline int pte_young(pte_t pte)
@@ -183,7 +183,7 @@ static inline pte_t pte_clear_flags(pte_t pte,
pteval_t clear)
=20
 static inline pte_t pte_mkclean(pte_t pte)
 {
-	return pte_clear_flags(pte, _PAGE_DIRTY);
+	return pte_clear_flags(pte, (_PAGE_DIRTY | _PAGE_SOFTDIRTY));
 }
=20
 static inline pte_t pte_mkold(pte_t pte)
diff --git a/arch/x86/include/asm/pgtable_32.h
b/arch/x86/include/asm/pgtable_32.h
index 0c92113..78415fb 100644
--- a/arch/x86/include/asm/pgtable_32.h
+++ b/arch/x86/include/asm/pgtable_32.h
@@ -21,6 +21,7 @@
 #include <linux/bitops.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <asm/mm_track.h>
=20
 struct mm_struct;
 struct vm_area_struct;
diff --git a/arch/x86/include/asm/pgtable_64.h
b/arch/x86/include/asm/pgtable_64.h
index 975f709..0848e9e 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -13,6 +13,7 @@
 #include <asm/processor.h>
 #include <linux/bitops.h>
 #include <linux/threads.h>
+#include <asm/mm_track.h>
=20
 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];
@@ -46,11 +47,13 @@ void set_pte_vaddr_pud(pud_t *pud_page, unsigned
long vaddr, pte_t new_pte);
 static inline void native_pte_clear(struct mm_struct *mm, unsigned long
addr,
 				    pte_t *ptep)
 {
+	mm_track_pte(ptep);
 	*ptep =3D native_make_pte(0);
 }
=20
 static inline void native_set_pte(pte_t *ptep, pte_t pte)
 {
+	mm_track_pte(ptep);
 	*ptep =3D pte;
 }
=20
@@ -61,6 +64,7 @@ static inline void native_set_pte_atomic(pte_t *ptep,
pte_t pte)
=20
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
+	mm_track_pmd(pmdp);
 	*pmdp =3D pmd;
 }
=20
@@ -71,6 +75,7 @@ static inline void native_pmd_clear(pmd_t *pmd)
=20
 static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 {
+	mm_track_pte(xp);
 #ifdef CONFIG_SMP
 	return native_make_pte(xchg(&xp->pte, 0));
 #else
@@ -97,6 +102,7 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t
*xp)
=20
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
 {
+	mm_track_pud(pudp);
 	*pudp =3D pud;
 }
=20
@@ -107,6 +113,7 @@ static inline void native_pud_clear(pud_t *pud)
=20
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
+	mm_track_pgd(pgdp);
 	*pgdp =3D pgd;
 }
=20
diff --git a/arch/x86/include/asm/pgtable_types.h
b/arch/x86/include/asm/pgtable_types.h
index d56187c..7f366d0 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -23,6 +23,7 @@
 #define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_UNUSED1
 #define _PAGE_BIT_SPLITTING	_PAGE_BIT_UNUSED1 /* only valid on a PSE
pmd */
+#define _PAGE_BIT_SOFTDIRTY	_PAGE_BIT_HIDDEN
 #define _PAGE_BIT_NX           63       /* No execute: only valid after
cpuid check */
=20
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
@@ -47,6 +48,7 @@
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
 #define _PAGE_CPA_TEST	(_AT(pteval_t, 1) << _PAGE_BIT_CPA_TEST)
 #define _PAGE_SPLITTING	(_AT(pteval_t, 1) <<
_PAGE_BIT_SPLITTING)
+#define _PAGE_SOFTDIRTY	(_AT(pteval_t, 1) <<
_PAGE_BIT_SOFTDIRTY)
 #define __HAVE_ARCH_PTE_SPECIAL
=20
 #ifdef CONFIG_KMEMCHECK
@@ -71,7 +73,8 @@
=20
 /* Set of bits not changed in pte_modify */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |
\
-			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY)
+			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |
\
+			 _PAGE_SOFTDIRTY)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
=20
 #define _PAGE_CACHE_MASK	(_PAGE_PCD | _PAGE_PWT)
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 3e608ed..a416317 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -30,3 +30,5 @@ obj-$(CONFIG_NUMA_EMU)		+=3D
numa_emulation.o
 obj-$(CONFIG_HAVE_MEMBLOCK)		+=3D memblock.o
=20
 obj-$(CONFIG_MEMTEST)		+=3D memtest.o
+
+obj-$(CONFIG_TRACK_DIRTY_PAGES)	+=3D track.o
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 83326ad..b94aad6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -795,7 +795,7 @@ static int do_huge_pmd_wp_page_fallback(struct
mm_struct *mm,
 					unsigned long haddr)
 {
 	pgtable_t pgtable;
-	pmd_t _pmd;
+	pmd_t _pmd =3D {0};
 	int ret =3D 0, i;
 	struct page **pages;
=20
@@ -1265,7 +1265,7 @@ static int __split_huge_page_map(struct page
*page,
 				 unsigned long address)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
-	pmd_t *pmd, _pmd;
+	pmd_t *pmd, _pmd =3D {0};
 	int ret =3D 0, i;
 	pgtable_t pgtable;
 	unsigned long haddr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
