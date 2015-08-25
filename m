Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id CEC126B0254
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:58:04 -0400 (EDT)
Received: by igcse8 with SMTP id se8so25093397igc.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:58:04 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id 23si10806643ioj.119.2015.08.25.14.57.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 14:57:29 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 10/11] x86/mm: Fix __split_large_page() to handle large PAT bit
Date: Tue, 25 Aug 2015 15:55:10 -0600
Message-Id: <1440539711-2985-11-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
References: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

__split_large_page() is called from __change_page_attr() to change
the mapping attribute by splitting a given large page into smaller
pages.  This function uses pte_pfn() and pte_pgprot() for PUD/PMD,
which do not handle the large PAT bit properly.

Fix __split_large_page() by using the corresponding pud/pmd pfn/
pgprot interfaces.

Also remove '#ifdef CONFIG_X86_64', which is not necessary.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/mm/pageattr.c |   31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index d055557..b64a451 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -623,7 +623,7 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 		   struct page *base)
 {
 	pte_t *pbase = (pte_t *)page_address(base);
-	unsigned long pfn, pfninc = 1;
+	unsigned long ref_pfn, pfn, pfninc = 1;
 	unsigned int i, level;
 	pte_t *tmp;
 	pgprot_t ref_prot;
@@ -640,26 +640,33 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 	}
 
 	paravirt_alloc_pte(&init_mm, page_to_pfn(base));
-	ref_prot = pte_pgprot(pte_clrhuge(*kpte));
 
-	/* promote PAT bit to correct position */
-	if (level == PG_LEVEL_2M)
+	switch (level) {
+	case PG_LEVEL_2M:
+		ref_prot = pmd_pgprot(*(pmd_t *)kpte);
+		/* clear PSE and promote PAT bit to correct position */
 		ref_prot = pgprot_large_2_4k(ref_prot);
+		ref_pfn = pmd_pfn(*(pmd_t *)kpte);
+		break;
 
-#ifdef CONFIG_X86_64
-	if (level == PG_LEVEL_1G) {
+	case PG_LEVEL_1G:
+		ref_prot = pud_pgprot(*(pud_t *)kpte);
+		ref_pfn = pud_pfn(*(pud_t *)kpte);
 		pfninc = PMD_PAGE_SIZE >> PAGE_SHIFT;
+
 		/*
-		 * Set the PSE flags only if the PRESENT flag is set
+		 * Clear the PSE flags if the PRESENT flag is not set
 		 * otherwise pmd_present/pmd_huge will return true
 		 * even on a non present pmd.
 		 */
-		if (pgprot_val(ref_prot) & _PAGE_PRESENT)
-			pgprot_val(ref_prot) |= _PAGE_PSE;
-		else
+		if (!(pgprot_val(ref_prot) & _PAGE_PRESENT))
 			pgprot_val(ref_prot) &= ~_PAGE_PSE;
+		break;
+
+	default:
+		spin_unlock(&pgd_lock);
+		return 1;
 	}
-#endif
 
 	/*
 	 * Set the GLOBAL flags only if the PRESENT flag is set
@@ -675,7 +682,7 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 	/*
 	 * Get the target pfn from the original entry:
 	 */
-	pfn = pte_pfn(*kpte);
+	pfn = ref_pfn;
 	for (i = 0; i < PTRS_PER_PTE; i++, pfn += pfninc)
 		set_pte(&pbase[i], pfn_pte(pfn, canon_pgprot(ref_prot)));
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
