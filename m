Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1FBB26B0082
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:24 -0500 (EST)
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIANH6014076
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:23 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 06 of 25] add pmd paravirt ops
Message-Id: <f97bb928b2dacc27dafe.1258220304@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:24 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Paravirt ops pmd_update/pmd_update_defer/pmd_set_at. Not all might be necessary
(vmware needs pmd_update, Xen needs set_pmd_at, nobody needs pmd_update_defer),
but this is to keep full simmetry with pte paravirt ops, which looks cleaner
and simpler from a common code POV.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
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
@@ -557,6 +568,16 @@ static inline void set_pte_at(struct mm_
 		PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pte.pte);
 }
 
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t pmd)
+{
+	if (sizeof(pmdval_t) > sizeof(long))
+		/* 5 arg words */
+		pv_mmu_ops.set_pmd_at(mm, addr, pmdp, pmd);
+	else
+		PVOP_VCALL4(pv_mmu_ops.set_pmd_at, mm, addr, pmdp, pmd.pmd);
+}
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	pmdval_t val = native_pmd_val(pmd);
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
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
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
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
