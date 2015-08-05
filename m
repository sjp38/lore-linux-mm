Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id E3A979003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 17:45:34 -0400 (EDT)
Received: by oihn130 with SMTP id n130so30018707oih.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 14:45:34 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id v1si2981445oec.93.2015.08.05.14.45.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 14:45:27 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 8/10] x86/mm: Fix try_preserve_large_page() to handle large PAT bit
Date: Wed,  5 Aug 2015 15:43:31 -0600
Message-Id: <1438811013-30983-9-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

try_preserve_large_page() is called from __change_page_attr() to
change the map attribute by preserving the large page.  This
function uses pte_pfn() and pte_pgprot() for PUD/PMD, which do not
handle the large PAT bit properly.

Fix try_preserve_large_page() to use corresponding p?d_pfn() and
p?d_pgprot().

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/mm/pageattr.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index ecc24e5..2724755 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -469,7 +469,7 @@ static int
 try_preserve_large_page(pte_t *kpte, unsigned long address,
 			struct cpa_data *cpa)
 {
-	unsigned long nextpage_addr, numpages, pmask, psize, addr, pfn;
+	unsigned long nextpage_addr, numpages, pmask, psize, addr, pfn, old_pfn;
 	pte_t new_pte, old_pte, *tmp;
 	pgprot_t old_prot, new_prot, req_prot;
 	int i, do_split = 1;
@@ -489,17 +489,21 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 
 	switch (level) {
 	case PG_LEVEL_2M:
-#ifdef CONFIG_X86_64
+		old_prot = pmd_pgprot(*(pmd_t *)kpte);
+		old_pfn = pmd_pfn(*(pmd_t *)kpte);
+		break;
 	case PG_LEVEL_1G:
-#endif
-		psize = page_level_size(level);
-		pmask = page_level_mask(level);
+		old_prot = pud_pgprot(*(pud_t *)kpte);
+		old_pfn = pud_pfn(*(pud_t *)kpte);
 		break;
 	default:
 		do_split = -EINVAL;
 		goto out_unlock;
 	}
 
+	psize = page_level_size(level);
+	pmask = page_level_mask(level);
+
 	/*
 	 * Calculate the number of pages, which fit into this large
 	 * page starting at address:
@@ -515,7 +519,7 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 	 * up accordingly.
 	 */
 	old_pte = *kpte;
-	old_prot = req_prot = pgprot_large_2_4k(pte_pgprot(old_pte));
+	old_prot = req_prot = pgprot_large_2_4k(old_prot);
 
 	pgprot_val(req_prot) &= ~pgprot_val(cpa->mask_clr);
 	pgprot_val(req_prot) |= pgprot_val(cpa->mask_set);
@@ -541,10 +545,10 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 	req_prot = canon_pgprot(req_prot);
 
 	/*
-	 * old_pte points to the large page base address. So we need
+	 * old_pfn points to the large page base pfn. So we need
 	 * to add the offset of the virtual address:
 	 */
-	pfn = pte_pfn(old_pte) + ((address & (psize - 1)) >> PAGE_SHIFT);
+	pfn = old_pfn + ((address & (psize - 1)) >> PAGE_SHIFT);
 	cpa->pfn = pfn;
 
 	new_prot = static_protections(req_prot, address, pfn);
@@ -555,7 +559,7 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 	 * the pages in the range we try to preserve:
 	 */
 	addr = address & pmask;
-	pfn = pte_pfn(old_pte);
+	pfn = old_pfn;
 	for (i = 0; i < (psize >> PAGE_SHIFT); i++, addr += PAGE_SIZE, pfn++) {
 		pgprot_t chk_prot = static_protections(req_prot, addr, pfn);
 
@@ -585,7 +589,7 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 		 * The address is aligned and the number of pages
 		 * covers the full page.
 		 */
-		new_pte = pfn_pte(pte_pfn(old_pte), new_prot);
+		new_pte = pfn_pte(old_pfn, new_prot);
 		__set_pmd_pte(kpte, address, new_pte);
 		cpa->flags |= CPA_FLUSHTLB;
 		do_split = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
