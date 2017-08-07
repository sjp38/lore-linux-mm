Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 329E96B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:16:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p20so5125652pfj.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:16:39 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f13si4641667pgr.65.2017.08.07.07.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 07:16:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 09/13] x86/mm: Fold p4d page table layer at runtime
Date: Mon,  7 Aug 2017 17:14:47 +0300
Message-Id: <20170807141451.80934-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
References: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch changes page table helpers to fold p4d at runtime.
The logic is the same as in <asm-generic/pgtable-nop4d.h>.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/paravirt.h | 10 ++++++----
 arch/x86/include/asm/pgalloc.h  |  5 ++++-
 arch/x86/include/asm/pgtable.h  | 10 +++++++++-
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 9ccac1926587..69c3cb792f34 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -606,14 +606,16 @@ static inline p4dval_t p4d_val(p4d_t p4d)
 
 static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
-	pgdval_t val = native_pgd_val(pgd);
-
-	PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, val);
+	if (p4d_folded)
+		set_p4d((p4d_t *)(pgdp), (p4d_t) { pgd.pgd });
+	else
+		PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgd));
 }
 
 static inline void pgd_clear(pgd_t *pgdp)
 {
-	set_pgd(pgdp, __pgd(0));
+	if (!p4d_folded)
+		set_pgd(pgdp, __pgd(0));
 }
 
 #endif  /* CONFIG_PGTABLE_LEVELS == 5 */
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index b2d0cd8288aa..5c42262169d0 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -155,6 +155,8 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 #if CONFIG_PGTABLE_LEVELS > 4
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, p4d_t *p4d)
 {
+	if (p4d_folded)
+		return;
 	paravirt_alloc_p4d(mm, __pa(p4d) >> PAGE_SHIFT);
 	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(p4d)));
 }
@@ -179,7 +181,8 @@ extern void ___p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d);
 static inline void __p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,
 				  unsigned long address)
 {
-	___p4d_free_tlb(tlb, p4d);
+	if (!p4d_folded)
+		___p4d_free_tlb(tlb, p4d);
 }
 
 #endif	/* CONFIG_PGTABLE_LEVELS > 4 */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index bbeae4a2bd01..5114495e4bfd 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -65,7 +65,7 @@ extern pmdval_t early_pmd_flags;
 
 #ifndef __PAGETABLE_P4D_FOLDED
 #define set_pgd(pgdp, pgd)		native_set_pgd(pgdp, pgd)
-#define pgd_clear(pgd)			native_pgd_clear(pgd)
+#define pgd_clear(pgd)			(!p4d_folded ? native_pgd_clear(pgd) : 0)
 #endif
 
 #ifndef set_p4d
@@ -861,6 +861,8 @@ static inline unsigned long p4d_index(unsigned long address)
 #if CONFIG_PGTABLE_LEVELS > 4
 static inline int pgd_present(pgd_t pgd)
 {
+	if (p4d_folded)
+		return 1;
 	return pgd_flags(pgd) & _PAGE_PRESENT;
 }
 
@@ -878,16 +880,22 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
 /* to find an entry in a page-table-directory. */
 static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)
 {
+	if (p4d_folded)
+		return (p4d_t *)pgd;
 	return (p4d_t *)pgd_page_vaddr(*pgd) + p4d_index(address);
 }
 
 static inline int pgd_bad(pgd_t pgd)
 {
+	if (p4d_folded)
+		return 0;
 	return (pgd_flags(pgd) & ~_PAGE_USER) != _KERNPG_TABLE;
 }
 
 static inline int pgd_none(pgd_t pgd)
 {
+	if (p4d_folded)
+		return 0;
 	/*
 	 * There is no need to do a workaround for the KNL stray
 	 * A/D bit erratum here.  PGDs only point to page tables
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
