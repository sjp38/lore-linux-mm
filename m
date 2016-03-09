Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 808886B0259
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 07:12:09 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fl4so38138145pad.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 04:12:09 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id b19si12159567pfd.242.2016.03.09.04.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 04:12:05 -0800 (PST)
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 22:12:01 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 308F82BB005A
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 23:11:59 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29CBpLn57933968
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:59 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29CBPuV021915
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:26 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 7/9] powerpc/hugetlb: Change follow_huge_* routines for BOOK3S 64K
Date: Wed,  9 Mar 2016 17:40:48 +0530
Message-Id: <1457525450-4262-7-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

With this change, BOOK3S 64K platforms will not use 'follow_huge_addr'
function any more and always return ERR_PTR(-ENIVAL), hence skipping
the BUG_ON(flags & FOLL_GET) test in 'follow_page_mask' function. These
platforms will then fall back on generic follow_huge_* functions for
everything else. While being here, also added 'follow_huge_pgd' function
which was missing earlier.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index f6e4712..89b748a 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -631,6 +631,10 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 	unsigned long mask, flags;
 	struct page *page = ERR_PTR(-EINVAL);
 
+#if defined(CONFIG_PPC_64K_PAGES) && defined(CONFIG_PPC_BOOK3S_64)
+	return ERR_PTR(-EINVAL);
+#endif
+
 	local_irq_save(flags);
 	ptep = find_linux_pte_or_hugepte(mm->pgd, address, &is_thp, &shift);
 	if (!ptep)
@@ -658,6 +662,7 @@ no_page:
 	return page;
 }
 
+#if !defined(CONFIG_PPC_64K_PAGES) || !defined(CONFIG_PPC_BOOK3S_64)
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
@@ -674,6 +679,15 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 	return NULL;
 }
 
+struct page *
+follow_huge_pgd(struct mm_struct *mm, unsigned long address,
+		pgd_t *pgd, int write)
+{
+	BUG();
+	return NULL;
+}
+#endif /* !defined(CONFIG_PPC_64K_PAGE) || !defined(CONFIG_BOOK3S_64) */
+
 static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
 				      unsigned long sz)
 {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
