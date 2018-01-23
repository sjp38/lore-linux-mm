Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30CA4800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:19:22 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w125so1359079itf.0
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:19:22 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y11si8578137itf.124.2018.01.23.09.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 09:19:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/3] x86/mm/encrypt: Rewrite sme_populate_pgd() and sme_populate_pgd_large()
Date: Tue, 23 Jan 2018 20:19:09 +0300
Message-Id: <20180123171910.55841-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
References: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

sme_populate_pgd() and sme_populate_pgd_large() operate on the identity
mapping, which means they want virtual addresses to be equal to physical
one, without PAGE_OFFSET shift.

We also need to avoid paravirtualizaion call there.

Getting this done is tricky. We cannot use usual page table helpers.
It forces us to open-code a lot of things. It makes code ugly and hard
to modify.

We can get it work with the page table helpers, but it requires few
preprocessor tricks.

  - Define __pa() and __va() to be compatible with identity mapping.

  - Undef CONFIG_PARAVIRT and CONFIG_PARAVIRT_SPINLOCKS before including
    any file. This way we can avoid pearavirtualization calls.

Now we can user normal page table helpers just fine.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mem_encrypt_identity.c | 158 +++++++++++++++++--------------------
 1 file changed, 71 insertions(+), 87 deletions(-)

diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
index dbf7a98f657d..400c0d931882 100644
--- a/arch/x86/mm/mem_encrypt_identity.c
+++ b/arch/x86/mm/mem_encrypt_identity.c
@@ -12,6 +12,23 @@
 
 #define DISABLE_BRANCH_PROFILING
 
+/*
+ * Since we're dealing with identity mappings, physical and virtual
+ * addresses are the same, so override these defines which are ultimately
+ * used by the headers in misc.h.
+ */
+#define __pa(x)  ((unsigned long)(x))
+#define __va(x)  ((void *)((unsigned long)(x)))
+
+/*
+ * Special hack: we have to be careful, because no indirections are
+ * allowed here, and paravirt_ops is a kind of one. As it will only run in
+ * baremetal anyway, we just keep it from happening. (This list needs to
+ * be extended when new paravirt and debugging variants are added.)
+ */
+#undef CONFIG_PARAVIRT
+#undef CONFIG_PARAVIRT_SPINLOCKS
+
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include "mm_internal.h"
@@ -21,114 +38,81 @@
 #define PUD_FLAGS		_KERNPG_TABLE_NOENC
 #define PMD_FLAGS		_KERNPG_TABLE_NOENC
 
-static pmd_t __init *sme_prepare_pgd(struct sme_populate_pgd_data *ppd)
+static pud_t __init *sme_prepare_pgd(struct sme_populate_pgd_data *ppd)
 {
-	pgd_t *pgd_p;
-	p4d_t *p4d_p;
-	pud_t *pud_p;
-	pmd_t *pmd_p;
-
-	pgd_p = ppd->pgd + pgd_index(ppd->vaddr);
-	if (native_pgd_val(*pgd_p)) {
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
-			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-		else
-			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pgd_t pgd;
-
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-			p4d_p = ppd->pgtable_area;
-			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
-			ppd->pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
-
-			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
-		} else {
-			pud_p = ppd->pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			ppd->pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
-		}
-		native_set_pgd(pgd_p, pgd);
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = ppd->pgd + pgd_index(ppd->vaddr);
+	if (pgd_none(*pgd)) {
+		p4d = ppd->pgtable_area;
+		memset(p4d, 0, sizeof(*p4d) * PTRS_PER_P4D);
+		ppd->pgtable_area += sizeof(*p4d) * PTRS_PER_P4D;
+		set_pgd(pgd, __pgd(PGD_FLAGS | __pa(p4d)));
 	}
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_p += p4d_index(ppd->vaddr);
-		if (native_p4d_val(*p4d_p)) {
-			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
-		} else {
-			p4d_t p4d;
-
-			pud_p = ppd->pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			ppd->pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			p4d = native_make_p4d((pudval_t)pud_p + P4D_FLAGS);
-			native_set_p4d(p4d_p, p4d);
-		}
+	p4d = p4d_offset(pgd, ppd->vaddr);
+	if (p4d_none(*p4d)) {
+		pud = ppd->pgtable_area;
+		memset(pud, 0, sizeof(*pud) * PTRS_PER_PUD);
+		ppd->pgtable_area += sizeof(*pud) * PTRS_PER_PUD;
+		set_p4d(p4d, __p4d(P4D_FLAGS | __pa(pud)));
 	}
 
-	pud_p += pud_index(ppd->vaddr);
-	if (native_pud_val(*pud_p)) {
-		if (native_pud_val(*pud_p) & _PAGE_PSE)
-			return NULL;
-
-		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pud_t pud;
-
-		pmd_p = ppd->pgtable_area;
-		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
-		ppd->pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
-
-		pud = native_make_pud((pmdval_t)pmd_p + PUD_FLAGS);
-		native_set_pud(pud_p, pud);
+	pud = pud_offset(p4d, ppd->vaddr);
+	if (pud_none(*pud)) {
+		pmd = ppd->pgtable_area;
+		memset(pmd, 0, sizeof(*pmd) * PTRS_PER_PMD);
+		ppd->pgtable_area += sizeof(*pmd) * PTRS_PER_PMD;
+		set_pud(pud, __pud(PUD_FLAGS | __pa(pmd)));
 	}
 
-	return pmd_p;
+	if (pud_large(*pud))
+		return NULL;
+
+	return pud;
 }
 
 void __init sme_populate_pgd_large(struct sme_populate_pgd_data *ppd)
 {
-	pmd_t *pmd_p;
+	pud_t *pud;
+	pmd_t *pmd;
 
-	pmd_p = sme_prepare_pgd(ppd);
-	if (!pmd_p)
+	pud = sme_prepare_pgd(ppd);
+	if (!pud)
 		return;
 
-	pmd_p += pmd_index(ppd->vaddr);
-	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
-		native_set_pmd(pmd_p, native_make_pmd(ppd->paddr | ppd->pmd_flags));
+	pmd = pmd_offset(pud, ppd->vaddr);
+	if (pmd_large(*pmd))
+		return;
+
+	set_pmd(pmd, __pmd(ppd->paddr | ppd->pmd_flags));
 }
 
 void __init sme_populate_pgd(struct sme_populate_pgd_data *ppd)
 {
-	pmd_t *pmd_p;
-	pte_t *pte_p;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
 
-	pmd_p = sme_prepare_pgd(ppd);
-	if (!pmd_p)
+	pud = sme_prepare_pgd(ppd);
+	if (!pud)
 		return;
 
-	pmd_p += pmd_index(ppd->vaddr);
-	if (native_pmd_val(*pmd_p)) {
-		if (native_pmd_val(*pmd_p) & _PAGE_PSE)
-			return;
-
-		pte_p = (pte_t *)(native_pmd_val(*pmd_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pmd_t pmd;
-
-		pte_p = ppd->pgtable_area;
-		memset(pte_p, 0, sizeof(*pte_p) * PTRS_PER_PTE);
-		ppd->pgtable_area += sizeof(*pte_p) * PTRS_PER_PTE;
-
-		pmd = native_make_pmd((pteval_t)pte_p + PMD_FLAGS);
-		native_set_pmd(pmd_p, pmd);
+	pmd = pmd_offset(pud, ppd->vaddr);
+	if (pmd_none(*pmd)) {
+		pte = ppd->pgtable_area;
+		memset(pte, 0, sizeof(pte) * PTRS_PER_PTE);
+		ppd->pgtable_area += sizeof(pte) * PTRS_PER_PTE;
+		set_pmd(pmd, __pmd(PMD_FLAGS | __pa(pte)));
 	}
 
-	pte_p += pte_index(ppd->vaddr);
-	if (!native_pte_val(*pte_p))
-		native_set_pte(pte_p, native_make_pte(ppd->paddr | ppd->pte_flags));
+	if (pmd_large(*pmd))
+		return;
+
+	pte = pte_offset_map(pmd, ppd->vaddr);
+	if (pte_none(*pte))
+		set_pte(pte, __pte(ppd->paddr | ppd->pte_flags));
 }
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
