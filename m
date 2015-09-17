Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id A5A8C6B0257
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:27:20 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so20128031obb.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:27:20 -0700 (PDT)
Received: from g1t6220.austin.hp.com (g1t6220.austin.hp.com. [15.73.96.84])
        by mx.google.com with ESMTPS id em3si2343796oeb.19.2015.09.17.11.27.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:27:16 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 RESEND 4/11] x86/asm: Fix pud/pmd interfaces to handle large PAT bit
Date: Thu, 17 Sep 2015 12:24:17 -0600
Message-Id: <1442514264-12475-5-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>

Now that we have pud/pmd mask interfaces, which handle pfn & flags
mask properly for the large PAT bit.

Fix pud/pmd pfn & flags interfaces by replacing PTE_PFN_MASK and
PTE_FLAGS_MASK with the pud/pmd mask interfaces.

Suggested-by: Juergen Gross <jgross@suse.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/include/asm/pgtable.h       |   14 ++++++++------
 arch/x86/include/asm/pgtable_types.h |    4 ++--
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 8338c81..714ad06 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -139,12 +139,12 @@ static inline unsigned long pte_pfn(pte_t pte)
 
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
@@ -499,14 +499,15 @@ static inline int pmd_none(pmd_t pmd)
 
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
@@ -567,14 +568,15 @@ static inline int pud_present(pud_t pud)
 
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
index 7c8f797..dd5b0aa 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -294,7 +294,7 @@ static inline pudval_t pud_flags_mask(pud_t pud)
 
 static inline pudval_t pud_flags(pud_t pud)
 {
-	return native_pud_val(pud) & PTE_FLAGS_MASK;
+	return native_pud_val(pud) & pud_flags_mask(pud);
 }
 
 static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
@@ -315,7 +315,7 @@ static inline pmdval_t pmd_flags_mask(pmd_t pmd)
 
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
