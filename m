Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7E776B0277
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 06:56:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j16so143567pga.6
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:56:20 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p64si4368199pga.766.2017.09.18.03.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 03:56:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 18/19] x86/mm: Redefine some of page table helpers as macros
Date: Mon, 18 Sep 2017 13:55:52 +0300
Message-Id: <20170918105553.27914-19-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is preparation for the next patch, which would change
pgtable_l5_enabled to be cpu_feature_enabled(X86_FEATURE_LA57).

The change makes PTE_FLAGS_MASK and other things to be dependent on
cpu_feature_enabled() definition from cpufeature.h. And cpufeature.h
depends on pgtable_types.h

Let's re-define some of helpers as macros to break this dependency loop.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/paravirt.h      | 23 +++++++------
 arch/x86/include/asm/pgtable_types.h | 67 +++++++++---------------------------
 2 files changed, 29 insertions(+), 61 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 757fdac42a4a..b1c37dd99902 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -567,19 +567,22 @@ static inline p4dval_t p4d_val(p4d_t p4d)
 	return PVOP_CALLEE1(p4dval_t, pv_mmu_ops.p4d_val, p4d.p4d);
 }
 
-static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
+static inline void __set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
-	if (pgtable_l5_enabled)
-		PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgd));
-	else
-		set_p4d((p4d_t *)(pgdp), (p4d_t) { pgd.pgd });
+	PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgd));
 }
 
-static inline void pgd_clear(pgd_t *pgdp)
-{
-	if (pgtable_l5_enabled)
-		set_pgd(pgdp, __pgd(0));
-}
+#define set_pgd(pgdp, pgdval) do {					\
+	if (pgtable_l5_enabled)						\
+		__set_pgd(pgdp, pgdval);				\
+	else								\
+		set_p4d((p4d_t *)(pgdp), (p4d_t) { (pgdval).pgd });	\
+} while (0)
+
+#define pgd_clear(pgdp) do {						\
+	if (pgtable_l5_enabled)						\
+		set_pgd(pgdp, __pgd(0));				\
+} while (0)
 
 #endif  /* CONFIG_PGTABLE_LEVELS == 5 */
 
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index f1492473f10e..ee7d8c17aee5 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -290,10 +290,7 @@ static inline pgdval_t native_pgd_val(pgd_t pgd)
 	return pgd.pgd;
 }
 
-static inline pgdval_t pgd_flags(pgd_t pgd)
-{
-	return native_pgd_val(pgd) & PTE_FLAGS_MASK;
-}
+#define pgd_flags(pgd) (native_pgd_val(pgd) & PTE_FLAGS_MASK)
 
 #if CONFIG_PGTABLE_LEVELS > 4
 typedef struct { p4dval_t p4d; } p4d_t;
@@ -363,57 +360,28 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 }
 #endif
 
-static inline p4dval_t p4d_pfn_mask(p4d_t p4d)
-{
-	/* No 512 GiB huge pages yet */
-	return PTE_PFN_MASK;
-}
+/* No 512 GiB huge pages yet */
+#define p4d_pfn_mask(p4d) PTE_PFN_MASK
 
-static inline p4dval_t p4d_flags_mask(p4d_t p4d)
-{
-	return ~p4d_pfn_mask(p4d);
-}
+#define p4d_flags_mask(p4d) (~p4d_pfn_mask(p4d))
 
-static inline p4dval_t p4d_flags(p4d_t p4d)
-{
-	return native_p4d_val(p4d) & p4d_flags_mask(p4d);
-}
+#define p4d_flags(p4d) (native_p4d_val(p4d) & p4d_flags_mask(p4d))
 
-static inline pudval_t pud_pfn_mask(pud_t pud)
-{
-	if (native_pud_val(pud) & _PAGE_PSE)
-		return PHYSICAL_PUD_PAGE_MASK;
-	else
-		return PTE_PFN_MASK;
-}
+#define pud_pfn_mask(pud) \
+	(native_pud_val(pud) & _PAGE_PSE ? \
+	 PHYSICAL_PUD_PAGE_MASK : PTE_PFN_MASK)
 
-static inline pudval_t pud_flags_mask(pud_t pud)
-{
-	return ~pud_pfn_mask(pud);
-}
+#define pud_flags_mask(pud) (~pud_pfn_mask(pud))
 
-static inline pudval_t pud_flags(pud_t pud)
-{
-	return native_pud_val(pud) & pud_flags_mask(pud);
-}
+#define pud_flags(pud) (native_pud_val(pud) & pud_flags_mask(pud))
 
-static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
-{
-	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return PHYSICAL_PMD_PAGE_MASK;
-	else
-		return PTE_PFN_MASK;
-}
+#define pmd_pfn_mask(pmd) \
+	(native_pmd_val(pmd) & _PAGE_PSE ? \
+	 PHYSICAL_PMD_PAGE_MASK : PTE_PFN_MASK)
 
-static inline pmdval_t pmd_flags_mask(pmd_t pmd)
-{
-	return ~pmd_pfn_mask(pmd);
-}
+#define pmd_flags_mask(pmd) (~pmd_pfn_mask(pmd))
 
-static inline pmdval_t pmd_flags(pmd_t pmd)
-{
-	return native_pmd_val(pmd) & pmd_flags_mask(pmd);
-}
+#define pmd_flags(pmd) (native_pmd_val(pmd) & pmd_flags_mask(pmd))
 
 static inline pte_t native_make_pte(pteval_t val)
 {
@@ -425,10 +393,7 @@ static inline pteval_t native_pte_val(pte_t pte)
 	return pte.pte;
 }
 
-static inline pteval_t pte_flags(pte_t pte)
-{
-	return native_pte_val(pte) & PTE_FLAGS_MASK;
-}
+#define pte_flags(pte) (native_pte_val(pte) & PTE_FLAGS_MASK)
 
 #define pgprot_val(x)	((x).pgprot)
 #define __pgprot(x)	((pgprot_t) { (x) } )
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
