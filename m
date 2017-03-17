Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40F896B038E
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:55:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c87so76685994pfl.6
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:55:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q6si9440490plk.257.2017.03.17.11.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 11:55:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/6] x86/xen: Change __xen_pgd_walk() and xen_cleanmfnmap() to support p4d
Date: Fri, 17 Mar 2017 21:55:14 +0300
Message-Id: <20170317185515.8636-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
References: <20170317185515.8636-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Xiong Zhang <xiong.y.zhang@intel.com>

Split these helpers into few per-level functions and add support of
additional page table level.

Signed-off-by: Xiong Zhang <xiong.y.zhang@intel.com>
[kirill.shutemov@linux.intel.com: split off into separate patch]
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/xen/mmu.c | 245 ++++++++++++++++++++++++++++++++---------------------
 arch/x86/xen/mmu.h |   1 +
 2 files changed, 150 insertions(+), 96 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 7adda9be6189..b3c4f13e48a4 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -593,6 +593,64 @@ static void xen_set_pgd(pgd_t *ptr, pgd_t val)
 }
 #endif	/* CONFIG_PGTABLE_LEVELS == 4 */
 
+static int xen_pmd_walk(struct mm_struct *mm, pmd_t *pmd,
+		int (*func)(struct mm_struct *mm, struct page *, enum pt_level),
+		bool last, unsigned long limit)
+{
+	int i, nr, flush = 0;
+
+	nr = last ? pmd_index(limit) + 1 : PTRS_PER_PMD;
+	for (i = 0; i < nr; i++) {
+		if (!pmd_none(pmd[i]))
+			flush |= (*func)(mm, pmd_page(pmd[i]), PT_PTE);
+	}
+	return flush;
+}
+
+static int xen_pud_walk(struct mm_struct *mm, pud_t *pud,
+		int (*func)(struct mm_struct *mm, struct page *, enum pt_level),
+		bool last, unsigned long limit)
+{
+	int i, nr, flush = 0;
+
+	nr = last ? pud_index(limit) + 1 : PTRS_PER_PUD;
+	for (i = 0; i < nr; i++) {
+		pmd_t *pmd;
+
+		if (pud_none(pud[i]))
+			continue;
+
+		pmd = pmd_offset(&pud[i], 0);
+		if (PTRS_PER_PMD > 1)
+			flush |= (*func)(mm, virt_to_page(pmd), PT_PMD);
+		flush |= xen_pmd_walk(mm, pmd, func,
+				last && i == nr - 1, limit);
+	}
+	return flush;
+}
+
+static int xen_p4d_walk(struct mm_struct *mm, p4d_t *p4d,
+		int (*func)(struct mm_struct *mm, struct page *, enum pt_level),
+		bool last, unsigned long limit)
+{
+	int i, nr, flush = 0;
+
+	nr = last ? p4d_index(limit) + 1 : PTRS_PER_P4D;
+	for (i = 0; i < nr; i++) {
+		pud_t *pud;
+
+		if (p4d_none(p4d[i]))
+			continue;
+
+		pud = pud_offset(&p4d[i], 0);
+		if (PTRS_PER_PUD > 1)
+			flush |= (*func)(mm, virt_to_page(pud), PT_PUD);
+		flush |= xen_pud_walk(mm, pud, func,
+				last && i == nr - 1, limit);
+	}
+	return flush;
+}
+
 /*
  * (Yet another) pagetable walker.  This one is intended for pinning a
  * pagetable.  This means that it walks a pagetable and calls the
@@ -613,10 +671,8 @@ static int __xen_pgd_walk(struct mm_struct *mm, pgd_t *pgd,
 				      enum pt_level),
 			  unsigned long limit)
 {
-	int flush = 0;
+	int i, nr, flush = 0;
 	unsigned hole_low, hole_high;
-	unsigned pgdidx_limit, pudidx_limit, pmdidx_limit;
-	unsigned pgdidx, pudidx, pmdidx;
 
 	/* The limit is the last byte to be touched */
 	limit--;
@@ -633,65 +689,22 @@ static int __xen_pgd_walk(struct mm_struct *mm, pgd_t *pgd,
 	hole_low = pgd_index(USER_LIMIT);
 	hole_high = pgd_index(PAGE_OFFSET);
 
-	pgdidx_limit = pgd_index(limit);
-#if PTRS_PER_PUD > 1
-	pudidx_limit = pud_index(limit);
-#else
-	pudidx_limit = 0;
-#endif
-#if PTRS_PER_PMD > 1
-	pmdidx_limit = pmd_index(limit);
-#else
-	pmdidx_limit = 0;
-#endif
-
-	for (pgdidx = 0; pgdidx <= pgdidx_limit; pgdidx++) {
-		pud_t *pud;
+	nr = pgd_index(limit) + 1;
+	for (i = 0; i < nr; i++) {
+		p4d_t *p4d;
 
-		if (pgdidx >= hole_low && pgdidx < hole_high)
+		if (i >= hole_low && i < hole_high)
 			continue;
 
-		if (!pgd_val(pgd[pgdidx]))
+		if (pgd_none(pgd[i]))
 			continue;
 
-		pud = pud_offset(&pgd[pgdidx], 0);
-
-		if (PTRS_PER_PUD > 1) /* not folded */
-			flush |= (*func)(mm, virt_to_page(pud), PT_PUD);
-
-		for (pudidx = 0; pudidx < PTRS_PER_PUD; pudidx++) {
-			pmd_t *pmd;
-
-			if (pgdidx == pgdidx_limit &&
-			    pudidx > pudidx_limit)
-				goto out;
-
-			if (pud_none(pud[pudidx]))
-				continue;
-
-			pmd = pmd_offset(&pud[pudidx], 0);
-
-			if (PTRS_PER_PMD > 1) /* not folded */
-				flush |= (*func)(mm, virt_to_page(pmd), PT_PMD);
-
-			for (pmdidx = 0; pmdidx < PTRS_PER_PMD; pmdidx++) {
-				struct page *pte;
-
-				if (pgdidx == pgdidx_limit &&
-				    pudidx == pudidx_limit &&
-				    pmdidx > pmdidx_limit)
-					goto out;
-
-				if (pmd_none(pmd[pmdidx]))
-					continue;
-
-				pte = pmd_page(pmd[pmdidx]);
-				flush |= (*func)(mm, pte, PT_PTE);
-			}
-		}
+		p4d = p4d_offset(&pgd[i], 0);
+		if (PTRS_PER_P4D > 1)
+			flush |= (*func)(mm, virt_to_page(p4d), PT_P4D);
+		flush |= xen_p4d_walk(mm, p4d, func, i == nr - 1, limit);
 	}
 
-out:
 	/* Do the top level last, so that the callbacks can use it as
 	   a cue to do final things like tlb flushes. */
 	flush |= (*func)(mm, virt_to_page(pgd), PT_PGD);
@@ -1150,57 +1163,97 @@ static void __init xen_cleanmfnmap_free_pgtbl(void *pgtbl, bool unpin)
 	xen_free_ro_pages(pa, PAGE_SIZE);
 }
 
+static void __init xen_cleanmfnmap_pmd(pmd_t *pmd, bool unpin)
+{
+	unsigned long pa;
+	pte_t *pte_tbl;
+	int i;
+
+	if (pmd_large(*pmd)) {
+		pa = pmd_val(*pmd) & PHYSICAL_PAGE_MASK;
+		xen_free_ro_pages(pa, PMD_SIZE);
+		return;
+	}
+
+	pte_tbl = pte_offset_kernel(pmd, 0);
+	for (i = 0; i < PTRS_PER_PTE; i++) {
+		if (pte_none(pte_tbl[i]))
+			continue;
+		pa = pte_pfn(pte_tbl[i]) << PAGE_SHIFT;
+		xen_free_ro_pages(pa, PAGE_SIZE);
+	}
+	set_pmd(pmd, __pmd(0));
+	xen_cleanmfnmap_free_pgtbl(pte_tbl, unpin);
+}
+
+static void __init xen_cleanmfnmap_pud(pud_t *pud, bool unpin)
+{
+	unsigned long pa;
+	pmd_t *pmd_tbl;
+	int i;
+
+	if (pud_large(*pud)) {
+		pa = pud_val(*pud) & PHYSICAL_PAGE_MASK;
+		xen_free_ro_pages(pa, PUD_SIZE);
+		return;
+	}
+
+	pmd_tbl = pmd_offset(pud, 0);
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		if (pmd_none(pmd_tbl[i]))
+			continue;
+		xen_cleanmfnmap_pmd(pmd_tbl + i, unpin);
+	}
+	set_pud(pud, __pud(0));
+	xen_cleanmfnmap_free_pgtbl(pmd_tbl, unpin);
+}
+
+static void __init xen_cleanmfnmap_p4d(p4d_t *p4d, bool unpin)
+{
+	unsigned long pa;
+	pud_t *pud_tbl;
+	int i;
+
+	if (p4d_large(*p4d)) {
+		pa = p4d_val(*p4d) & PHYSICAL_PAGE_MASK;
+		xen_free_ro_pages(pa, P4D_SIZE);
+		return;
+	}
+
+	pud_tbl = pud_offset(p4d, 0);
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		if (pud_none(pud_tbl[i]))
+			continue;
+		xen_cleanmfnmap_pud(pud_tbl + i, unpin);
+	}
+	set_p4d(p4d, __p4d(0));
+	xen_cleanmfnmap_free_pgtbl(pud_tbl, unpin);
+}
+
 /*
  * Since it is well isolated we can (and since it is perhaps large we should)
  * also free the page tables mapping the initial P->M table.
  */
 static void __init xen_cleanmfnmap(unsigned long vaddr)
 {
-	unsigned long va = vaddr & PMD_MASK;
-	unsigned long pa;
-	pgd_t *pgd = pgd_offset_k(va);
-	pud_t *pud_page = pud_offset(pgd, 0);
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
+	pgd_t *pgd;
+	p4d_t *p4d;
 	unsigned int i;
 	bool unpin;
 
 	unpin = (vaddr == 2 * PGDIR_SIZE);
-	set_pgd(pgd, __pgd(0));
-	do {
-		pud = pud_page + pud_index(va);
-		if (pud_none(*pud)) {
-			va += PUD_SIZE;
-		} else if (pud_large(*pud)) {
-			pa = pud_val(*pud) & PHYSICAL_PAGE_MASK;
-			xen_free_ro_pages(pa, PUD_SIZE);
-			va += PUD_SIZE;
-		} else {
-			pmd = pmd_offset(pud, va);
-			if (pmd_large(*pmd)) {
-				pa = pmd_val(*pmd) & PHYSICAL_PAGE_MASK;
-				xen_free_ro_pages(pa, PMD_SIZE);
-			} else if (!pmd_none(*pmd)) {
-				pte = pte_offset_kernel(pmd, va);
-				set_pmd(pmd, __pmd(0));
-				for (i = 0; i < PTRS_PER_PTE; ++i) {
-					if (pte_none(pte[i]))
-						break;
-					pa = pte_pfn(pte[i]) << PAGE_SHIFT;
-					xen_free_ro_pages(pa, PAGE_SIZE);
-				}
-				xen_cleanmfnmap_free_pgtbl(pte, unpin);
-			}
-			va += PMD_SIZE;
-			if (pmd_index(va))
-				continue;
-			set_pud(pud, __pud(0));
-			xen_cleanmfnmap_free_pgtbl(pmd, unpin);
-		}
-
-	} while (pud_index(va) || pmd_index(va));
-	xen_cleanmfnmap_free_pgtbl(pud_page, unpin);
+	vaddr &= PMD_MASK;
+	pgd = pgd_offset_k(vaddr);
+	p4d = p4d_offset(pgd, 0);
+	for (i = 0; i < PTRS_PER_P4D; i++) {
+		if (p4d_none(p4d[i]))
+			continue;
+		xen_cleanmfnmap_p4d(p4d + i, unpin);
+	}
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		set_pgd(pgd, __pgd(0));
+		xen_cleanmfnmap_free_pgtbl(p4d, unpin);
+	}
 }
 
 static void __init xen_pagetable_p2m_free(void)
diff --git a/arch/x86/xen/mmu.h b/arch/x86/xen/mmu.h
index 73809bb951b4..3fe2b3292915 100644
--- a/arch/x86/xen/mmu.h
+++ b/arch/x86/xen/mmu.h
@@ -5,6 +5,7 @@
 
 enum pt_level {
 	PT_PGD,
+	PT_P4D,
 	PT_PUD,
 	PT_PMD,
 	PT_PTE
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
