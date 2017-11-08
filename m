Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 354066B02DE
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:00 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v78so3006626pfk.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:00 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id o18si4616532pgc.140.2017.11.08.11.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:46:59 -0800 (PST)
Subject: [PATCH 01/30] x86, mm: do not set _PAGE_USER for init_mm page tables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:46:47 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194647.ABC9BC79@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, tglx@linutronix.de, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

init_mm is for kernel-exclusive use.  If someone is allocating page
tables for it, do not set _PAGE_USER on them.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/pgalloc.h |   33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

diff -puN arch/x86/include/asm/pgalloc.h~kaiser-prep-clear-_PAGE_USER-for-init_mm arch/x86/include/asm/pgalloc.h
--- a/arch/x86/include/asm/pgalloc.h~kaiser-prep-clear-_PAGE_USER-for-init_mm	2017-11-08 10:45:25.928681403 -0800
+++ b/arch/x86/include/asm/pgalloc.h	2017-11-08 10:45:25.931681403 -0800
@@ -61,20 +61,37 @@ static inline void __pte_free_tlb(struct
 	___pte_free_tlb(tlb, pte);
 }
 
+/*
+ * init_mm is for kernel-exclusive use.  Any page tables that
+ * are seteup for it should not be usable by userspace.
+ *
+ * This also *signals* to code (like KAISER) that this page table
+ * entry is for kernel-exclusive use.
+ */
+static inline pteval_t mm_pgtable_flags(struct mm_struct *mm)
+{
+	if (!mm || (mm == &init_mm))
+		return _KERNPG_TABLE;
+	return _PAGE_TABLE;
+}
+
 static inline void pmd_populate_kernel(struct mm_struct *mm,
 				       pmd_t *pmd, pte_t *pte)
 {
+	pteval_t pgtable_flags = mm_pgtable_flags(mm);
+
 	paravirt_alloc_pte(mm, __pa(pte) >> PAGE_SHIFT);
-	set_pmd(pmd, __pmd(__pa(pte) | _PAGE_TABLE));
+	set_pmd(pmd, __pmd(__pa(pte) | pgtable_flags));
 }
 
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 				struct page *pte)
 {
+	pteval_t pgtable_flags = mm_pgtable_flags(mm);
 	unsigned long pfn = page_to_pfn(pte);
 
 	paravirt_alloc_pte(mm, pfn);
-	set_pmd(pmd, __pmd(((pteval_t)pfn << PAGE_SHIFT) | _PAGE_TABLE));
+	set_pmd(pmd, __pmd(((pteval_t)pfn << PAGE_SHIFT) | pgtable_flags));
 }
 
 #define pmd_pgtable(pmd) pmd_page(pmd)
@@ -117,16 +134,20 @@ extern void pud_populate(struct mm_struc
 #else	/* !CONFIG_X86_PAE */
 static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 {
+	pteval_t pgtable_flags = mm_pgtable_flags(mm);
+
 	paravirt_alloc_pmd(mm, __pa(pmd) >> PAGE_SHIFT);
-	set_pud(pud, __pud(_PAGE_TABLE | __pa(pmd)));
+	set_pud(pud, __pud(__pa(pmd) | pgtable_flags));
 }
 #endif	/* CONFIG_X86_PAE */
 
 #if CONFIG_PGTABLE_LEVELS > 3
 static inline void p4d_populate(struct mm_struct *mm, p4d_t *p4d, pud_t *pud)
 {
+	pteval_t pgtable_flags = mm_pgtable_flags(mm);
+
 	paravirt_alloc_pud(mm, __pa(pud) >> PAGE_SHIFT);
-	set_p4d(p4d, __p4d(_PAGE_TABLE | __pa(pud)));
+	set_p4d(p4d, __p4d(__pa(pud) | pgtable_flags));
 }
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
@@ -155,8 +176,10 @@ static inline void __pud_free_tlb(struct
 #if CONFIG_PGTABLE_LEVELS > 4
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, p4d_t *p4d)
 {
+	pteval_t pgtable_flags = mm_pgtable_flags(mm);
+
 	paravirt_alloc_p4d(mm, __pa(p4d) >> PAGE_SHIFT);
-	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(p4d)));
+	set_pgd(pgd, __pgd(__pa(p4d) | pgtable_flags));
 }
 
 static inline p4d_t *p4d_alloc_one(struct mm_struct *mm, unsigned long addr)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
