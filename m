Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48EB76B000C
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:25:54 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q13so2167610pgt.17
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:25:54 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b9si1651107pff.42.2018.02.14.10.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:25:53 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 7/9] x86/mm: Fold p4d page table layer at runtime
Date: Wed, 14 Feb 2018 21:25:40 +0300
Message-Id: <20180214182542.69302-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
References: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch changes page table helpers to fold p4d at runtime.
The logic is the same as in <asm-generic/pgtable-nop4d.h>.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/paravirt.h | 10 ++++++----
 arch/x86/include/asm/pgalloc.h  |  5 ++++-
 arch/x86/include/asm/pgtable.h  | 11 ++++++++++-
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 554841fab717..70d3c86927de 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -569,14 +569,16 @@ static inline p4dval_t p4d_val(p4d_t p4d)
 
 static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
-	pgdval_t val = native_pgd_val(pgd);
-
-	PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, val);
+	if (pgtable_l5_enabled)
+		PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgd));
+	else
+		set_p4d((p4d_t *)(pgdp), (p4d_t) { pgd.pgd });
 }
 
 static inline void pgd_clear(pgd_t *pgdp)
 {
-	set_pgd(pgdp, __pgd(0));
+	if (pgtable_l5_enabled)
+		set_pgd(pgdp, __pgd(0));
 }
 
 #endif  /* CONFIG_PGTABLE_LEVELS == 5 */
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index aff42e1da6ee..263c142a6a6c 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -167,6 +167,8 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 #if CONFIG_PGTABLE_LEVELS > 4
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, p4d_t *p4d)
 {
+	if (!pgtable_l5_enabled)
+		return;
 	paravirt_alloc_p4d(mm, __pa(p4d) >> PAGE_SHIFT);
 	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(p4d)));
 }
@@ -191,7 +193,8 @@ extern void ___p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d);
 static inline void __p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,
 				  unsigned long address)
 {
-	___p4d_free_tlb(tlb, p4d);
+	if (pgtable_l5_enabled)
+		___p4d_free_tlb(tlb, p4d);
 }
 
 #endif	/* CONFIG_PGTABLE_LEVELS > 4 */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 63c2552b6b65..c8baa7f12d1b 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -65,7 +65,7 @@ extern pmdval_t early_pmd_flags;
 
 #ifndef __PAGETABLE_P4D_FOLDED
 #define set_pgd(pgdp, pgd)		native_set_pgd(pgdp, pgd)
-#define pgd_clear(pgd)			native_pgd_clear(pgd)
+#define pgd_clear(pgd)			(pgtable_l5_enabled ? native_pgd_clear(pgd) : 0)
 #endif
 
 #ifndef set_p4d
@@ -859,6 +859,8 @@ static inline unsigned long p4d_index(unsigned long address)
 #if CONFIG_PGTABLE_LEVELS > 4
 static inline int pgd_present(pgd_t pgd)
 {
+	if (!pgtable_l5_enabled)
+		return 1;
 	return pgd_flags(pgd) & _PAGE_PRESENT;
 }
 
@@ -876,6 +878,8 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
 /* to find an entry in a page-table-directory. */
 static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)
 {
+	if (!pgtable_l5_enabled)
+		return (p4d_t *)pgd;
 	return (p4d_t *)pgd_page_vaddr(*pgd) + p4d_index(address);
 }
 
@@ -883,6 +887,9 @@ static inline int pgd_bad(pgd_t pgd)
 {
 	unsigned long ignore_flags = _PAGE_USER;
 
+	if (!pgtable_l5_enabled)
+		return 0;
+
 	if (IS_ENABLED(CONFIG_PAGE_TABLE_ISOLATION))
 		ignore_flags |= _PAGE_NX;
 
@@ -891,6 +898,8 @@ static inline int pgd_bad(pgd_t pgd)
 
 static inline int pgd_none(pgd_t pgd)
 {
+	if (!pgtable_l5_enabled)
+		return 0;
 	/*
 	 * There is no need to do a workaround for the KNL stray
 	 * A/D bit erratum here.  PGDs only point to page tables
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
