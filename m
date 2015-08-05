Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id C34F29003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 17:45:32 -0400 (EDT)
Received: by oihn130 with SMTP id n130so30018271oih.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 14:45:32 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id e198si3005583oig.70.2015.08.05.14.45.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 14:45:26 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 7/10] x86/mm: Fix gup_huge_p?d() to handle large PAT bit
Date: Wed,  5 Aug 2015 15:43:30 -0600
Message-Id: <1438811013-30983-8-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
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
