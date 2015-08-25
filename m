Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id AAE226B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:57:24 -0400 (EDT)
Received: by igbjg10 with SMTP id jg10so24962851igb.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:57:24 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id j21si10798898ioo.187.2015.08.25.14.57.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 14:57:22 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 3/11] x86/asm: Add pud/pmd mask interfaces to handle large PAT bit
Date: Tue, 25 Aug 2015 15:55:03 -0600
Message-Id: <1440539711-2985-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
References: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
is used for masking pfn and flags for all levels.

Add pud/pmd mask interfaces to handle pfn and flags properly by using
P?D_PAGE_MASK when PUD/PMD mappings are used, i.e. PSE bit is set.

Suggested-by: Juergen Gross <jgross@suse.com>
Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/include/asm/pgtable_types.h |   36 ++++++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 13f310b..7c8f797 100644
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
@@ -276,11 +276,43 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
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
 	return native_pud_val(pud) & PTE_FLAGS_MASK;
 }
 
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
+}
+
 static inline pmdval_t pmd_flags(pmd_t pmd)
 {
 	return native_pmd_val(pmd) & PTE_FLAGS_MASK;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
