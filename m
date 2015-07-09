Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFF76B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 13:04:53 -0400 (EDT)
Received: by ykee186 with SMTP id e186so41566462yke.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 10:04:53 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id s190si4139818ywd.126.2015.07.09.10.04.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 10:04:51 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 1/2] x86: Fix pXd_flags() to handle _PAGE_PAT_LARGE
Date: Thu,  9 Jul 2015 11:03:50 -0600
Message-Id: <1436461431-27305-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1436461431-27305-1-git-send-email-toshi.kani@hp.com>
References: <1436461431-27305-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
is corrently used for masking the flag bits for all cases.

Fix pud_flags() and pmd_flags() to cover the PAT bit, _PAGE_PAT_LARGE,
when they are used to map a large page with _PAGE_PSE set.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Robert Elliott <elliott@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/include/asm/pgtable_types.h |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 13f310b..caaf45c 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -212,9 +212,13 @@ enum page_cache_mode {
 /* PTE_PFN_MASK extracts the PFN from a (pte|pmd|pud|pgd)val_t */
 #define PTE_PFN_MASK		((pteval_t)PHYSICAL_PAGE_MASK)
 
-/* PTE_FLAGS_MASK extracts the flags from a (pte|pmd|pud|pgd)val_t */
+/* Extracts the flags from a (pte|pmd|pud|pgd)val_t of a 4KB page */
 #define PTE_FLAGS_MASK		(~PTE_PFN_MASK)
 
+/* Extracts the flags from a (pmd|pud)val_t of a (1GB|2MB) page */
+#define PMD_FLAGS_MASK_LARGE	((~PTE_PFN_MASK) | _PAGE_PAT_LARGE)
+#define PUD_FLAGS_MASK_LARGE	((~PTE_PFN_MASK) | _PAGE_PAT_LARGE)
+
 typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
 
 typedef struct { pgdval_t pgd; } pgd_t;
@@ -278,12 +282,18 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 
 static inline pudval_t pud_flags(pud_t pud)
 {
-	return native_pud_val(pud) & PTE_FLAGS_MASK;
+	if (native_pud_val(pud) & _PAGE_PSE)
+		return native_pud_val(pud) & PUD_FLAGS_MASK_LARGE;
+	else
+		return native_pud_val(pud) & PTE_FLAGS_MASK;
 }
 
 static inline pmdval_t pmd_flags(pmd_t pmd)
 {
-	return native_pmd_val(pmd) & PTE_FLAGS_MASK;
+	if (native_pmd_val(pmd) & _PAGE_PSE)
+		return native_pmd_val(pmd) & PMD_FLAGS_MASK_LARGE;
+	else
+		return native_pmd_val(pmd) & PTE_FLAGS_MASK;
 }
 
 static inline pte_t native_make_pte(pteval_t val)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
