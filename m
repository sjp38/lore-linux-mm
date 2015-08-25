Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 116AA6B0254
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:58:01 -0400 (EDT)
Received: by igfj19 with SMTP id j19so23164831igf.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:58:00 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id x85si10804691ioi.90.2015.08.25.14.57.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 14:57:27 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 8/11] x86/mm: Fix gup_huge_p?d() to handle large PAT bit
Date: Tue, 25 Aug 2015 15:55:08 -0600
Message-Id: <1440539711-2985-9-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
References: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

gup_huge_pud() and gup_huge_pmd() cast *pud and *pmd to *pte,
and use pte_xxx() interfaces to obtain the flags and PFN.
However, the pte_xxx() interface does not handle the large
PAT bit properly for PUD/PMD.

Fix gup_huge_pud() and gup_huge_pmd() to use pud_xxx() and
pmd_xxx() interfaces according to their type.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/mm/gup.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 81bf3d2..ae9a37b 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -118,21 +118,20 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
 	unsigned long mask;
-	pte_t pte = *(pte_t *)&pmd;
 	struct page *head, *page;
 	int refs;
 
 	mask = _PAGE_PRESENT|_PAGE_USER;
 	if (write)
 		mask |= _PAGE_RW;
-	if ((pte_flags(pte) & mask) != mask)
+	if ((pmd_flags(pmd) & mask) != mask)
 		return 0;
 	/* hugepages are never "special" */
-	VM_BUG_ON(pte_flags(pte) & _PAGE_SPECIAL);
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+	VM_BUG_ON(pmd_flags(pmd) & _PAGE_SPECIAL);
+	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
 
 	refs = 0;
-	head = pte_page(pte);
+	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
@@ -195,21 +194,20 @@ static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
 	unsigned long mask;
-	pte_t pte = *(pte_t *)&pud;
 	struct page *head, *page;
 	int refs;
 
 	mask = _PAGE_PRESENT|_PAGE_USER;
 	if (write)
 		mask |= _PAGE_RW;
-	if ((pte_flags(pte) & mask) != mask)
+	if ((pud_flags(pud) & mask) != mask)
 		return 0;
 	/* hugepages are never "special" */
-	VM_BUG_ON(pte_flags(pte) & _PAGE_SPECIAL);
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+	VM_BUG_ON(pud_flags(pud) & _PAGE_SPECIAL);
+	VM_BUG_ON(!pfn_valid(pud_pfn(pud)));
 
 	refs = 0;
-	head = pte_page(pte);
+	head = pud_page(pud);
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
