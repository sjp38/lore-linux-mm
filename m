Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7781728029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:25:03 -0400 (EDT)
Received: by oibn4 with SMTP id n4so32140459oib.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:25:03 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id mm1si4148988obb.103.2015.07.15.09.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:25:02 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 3/4] x86: Fix pud/pmd interfaces to handle large PAT bit
Date: Wed, 15 Jul 2015 10:23:54 -0600
Message-Id: <1436977435-31826-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
References: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
is corrently used for masking pfn and flags for all cases.

Fix pud/pmd interfaces to handle pfn and flags properly by using
P?D_PAGE_MASK when PUD/PMD mappings are used, i.e. PSE bit is set.

Suggested-by: Juergen Gross <jgross@suse.com>
Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/include/asm/pgtable.h       |   14 +++++++-----
 arch/x86/include/asm/pgtable_types.h |   40 +++++++++++++++++++++++++++++++---
 2 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 867da5b..0733ec7 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -142,12 +142,12 @@ static inline unsigned long pte_pfn(pte_t pte)
 
 static inline unsigned long pmd_pfn(pmd_t pmd)
 {
-	return (pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT;
+	return (pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
 }
 
 static inline unsigned long pud_pfn(pud_t pud)
 {
-	return (pud_val(pud) & PTE_PFN_MASK) >> PAGE_SHIFT;
+	return (pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT;
 }
 
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
@@ -502,14 +502,15 @@ static inline int pmd_none(pmd_t pmd)
 
 static inline unsigned long pmd_page_vaddr(pmd_t pmd)
 {
-	return (unsigned long)__va(pmd_val(pmd) & PTE_PFN_MASK);
+	return (unsigned long)__va(pmd_val(pmd) & pmd_pfn_mask(pmd));
 }
 
 /*
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
+#define pmd_page(pmd)		\
+	pfn_to_page((pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT)
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
@@ -570,14 +571,15 @@ static inline int pud_present(pud_t pud)
 
 static inline unsigned long pud_page_vaddr(pud_t pud)
 {
-	return (unsigned long)__va((unsigned long)pud_val(pud) & PTE_PFN_MASK);
+	return (unsigned long)__va(pud_val(pud) & pud_pfn_mask(pud));
 }
 
 /*
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pud_page(pud)		pfn_to_page(pud_val(pud) >> PAGE_SHIFT)
+#define pud_page(pud)		\
+	pfn_to_page((pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT)
 
 /* Find an entry in the second-level page table.. */
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 13f310b..dd5b0aa 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -209,10 +209,10 @@ enum page_cache_mode {
 
 #include <linux/types.h>
 
-/* PTE_PFN_MASK extracts the PFN from a (pte|pmd|pud|pgd)val_t */
+/* Extracts the PFN from a (pte|pmd|pud|pgd)val_t of a 4KB page */
 #define PTE_PFN_MASK		((pteval_t)PHYSICAL_PAGE_MASK)
 
-/* PTE_FLAGS_MASK extracts the flags from a (pte|pmd|pud|pgd)val_t */
+/* Extracts the flags from a (pte|pmd|pud|pgd)val_t of a 4KB page */
 #define PTE_FLAGS_MASK		(~PTE_PFN_MASK)
 
 typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
@@ -276,14 +276,46 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 }
 #endif
 
+static inline pudval_t pud_pfn_mask(pud_t pud)
+{
+	if (native_pud_val(pud) & _PAGE_PSE)
+		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+	else
+		return PTE_PFN_MASK;
+}
+
+static inline pudval_t pud_flags_mask(pud_t pud)
+{
+	if (native_pud_val(pud) & _PAGE_PSE)
+		return ~(PUD_PAGE_MASK & (pudval_t)PHYSICAL_PAGE_MASK);
+	else
+		return ~PTE_PFN_MASK;
+}
+
 static inline pudval_t pud_flags(pud_t pud)
 {
-	return native_pud_val(pud) & PTE_FLAGS_MASK;
+	return native_pud_val(pud) & pud_flags_mask(pud);
+}
+
+static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
+{
+	if (native_pmd_val(pmd) & _PAGE_PSE)
+		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+	else
+		return PTE_PFN_MASK;
+}
+
+static inline pmdval_t pmd_flags_mask(pmd_t pmd)
+{
+	if (native_pmd_val(pmd) & _PAGE_PSE)
+		return ~(PMD_PAGE_MASK & (pmdval_t)PHYSICAL_PAGE_MASK);
+	else
+		return ~PTE_PFN_MASK;
 }
 
 static inline pmdval_t pmd_flags(pmd_t pmd)
 {
-	return native_pmd_val(pmd) & PTE_FLAGS_MASK;
+	return native_pmd_val(pmd) & pmd_flags_mask(pmd);
 }
 
 static inline pte_t native_make_pte(pteval_t val)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
