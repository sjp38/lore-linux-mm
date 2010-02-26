Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 18F846B00A1
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:25 -0500 (EST)
Message-Id: <20100226200900.058965638@redhat.com>
Date: Fri, 26 Feb 2010 21:04:41 +0100
From: aarcange@redhat.com
Subject: [patch 08/35] add pmd paravirt ops
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=pmd_paravirt_ops
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Paravirt ops pmd_update/pmd_update_defer/pmd_set_at. Not all might be necessary
(vmware needs pmd_update, Xen needs set_pmd_at, nobody needs pmd_update_defer),
but this is to keep full simmetry with pte paravirt ops, which looks cleaner
and simpler from a common code POV.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/x86/include/asm/paravirt.h       |   23 +++++++++++++++++++++++
 arch/x86/include/asm/paravirt_types.h |    6 ++++++
 arch/x86/kernel/paravirt.c            |    3 +++
 3 files changed, 32 insertions(+)

--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -449,6 +449,11 @@ static inline void pte_update(struct mm_
 {
 	PVOP_VCALL3(pv_mmu_ops.pte_update, mm, addr, ptep);
 }
+static inline void pmd_update(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp)
+{
+	PVOP_VCALL3(pv_mmu_ops.pmd_update, mm, addr, pmdp);
+}
 
 static inline void pte_update_defer(struct mm_struct *mm, unsigned long addr,
 				    pte_t *ptep)
@@ -456,6 +461,12 @@ static inline void pte_update_defer(stru
 	PVOP_VCALL3(pv_mmu_ops.pte_update_defer, mm, addr, ptep);
 }
 
+static inline void pmd_update_defer(struct mm_struct *mm, unsigned long addr,
+				    pmd_t *pmdp)
+{
+	PVOP_VCALL3(pv_mmu_ops.pmd_update_defer, mm, addr, pmdp);
+}
+
 static inline pte_t __pte(pteval_t val)
 {
 	pteval_t ret;
@@ -557,6 +568,18 @@ static inline void set_pte_at(struct mm_
 		PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pte.pte);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t pmd)
+{
+	if (sizeof(pmdval_t) > sizeof(long))
+		/* 5 arg words */
+		pv_mmu_ops.set_pmd_at(mm, addr, pmdp, pmd);
+	else
+		PVOP_VCALL4(pv_mmu_ops.set_pmd_at, mm, addr, pmdp, pmd.pmd);
+}
+#endif
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	pmdval_t val = native_pmd_val(pmd);
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -266,10 +266,16 @@ struct pv_mmu_ops {
 	void (*set_pte_at)(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep, pte_t pteval);
 	void (*set_pmd)(pmd_t *pmdp, pmd_t pmdval);
+	void (*set_pmd_at)(struct mm_struct *mm, unsigned long addr,
+			   pmd_t *pmdp, pmd_t pmdval);
 	void (*pte_update)(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep);
 	void (*pte_update_defer)(struct mm_struct *mm,
 				 unsigned long addr, pte_t *ptep);
+	void (*pmd_update)(struct mm_struct *mm, unsigned long addr,
+			   pmd_t *pmdp);
+	void (*pmd_update_defer)(struct mm_struct *mm,
+				 unsigned long addr, pmd_t *pmdp);
 
 	pte_t (*ptep_modify_prot_start)(struct mm_struct *mm, unsigned long addr,
 					pte_t *ptep);
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -422,8 +422,11 @@ struct pv_mmu_ops pv_mmu_ops = {
 	.set_pte = native_set_pte,
 	.set_pte_at = native_set_pte_at,
 	.set_pmd = native_set_pmd,
+	.set_pmd_at = native_set_pmd_at,
 	.pte_update = paravirt_nop,
 	.pte_update_defer = paravirt_nop,
+	.pmd_update = paravirt_nop,
+	.pmd_update_defer = paravirt_nop,
 
 	.ptep_modify_prot_start = __ptep_modify_prot_start,
 	.ptep_modify_prot_commit = __ptep_modify_prot_commit,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
