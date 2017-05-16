Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6C9A6B0350
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u12so131852723pgo.4
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:24:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f3si12808823pld.186.2017.05.16.02.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:24:09 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9NmWM133300
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:08 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afwhj3hrq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:08 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 03:24:07 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 8/9] powerpc/mm/hugetlb: Remove follow_huge_addr for powerpc
Date: Tue, 16 May 2017 14:53:31 +0530
In-Reply-To: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494926612-23928-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With generic code now handling hugetlb entries at pgd level and also
supporting hugepage directory format, we can now remove the powerpc
sepcific follow_huge_addr implementation.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c | 64 -------------------------------------------
 1 file changed, 64 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 5c829a83a4cc..1816b965a142 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -619,11 +619,6 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 	} while (addr = next, addr != end);
 }
 
-/*
- * 64 bit book3s use generic follow_page_mask
- */
-#ifdef CONFIG_PPC_BOOK3S_64
-
 struct page *follow_huge_pd(struct vm_area_struct *vma,
 			    unsigned long address, hugepd_t hpd,
 			    int flags, int pdshift)
@@ -657,65 +652,6 @@ struct page *follow_huge_pd(struct vm_area_struct *vma,
 	return page;
 }
 
-#else /* !CONFIG_PPC_BOOK3S_64 */
-
-/*
- * We are holding mmap_sem, so a parallel huge page collapse cannot run.
- * To prevent hugepage split, disable irq.
- */
-struct page *
-follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
-{
-	bool is_thp;
-	pte_t *ptep, pte;
-	unsigned shift;
-	unsigned long mask, flags;
-	struct page *page = ERR_PTR(-EINVAL);
-
-	local_irq_save(flags);
-	ptep = find_linux_pte_or_hugepte(mm->pgd, address, &is_thp, &shift);
-	if (!ptep)
-		goto no_page;
-	pte = READ_ONCE(*ptep);
-	/*
-	 * Verify it is a huge page else bail.
-	 * Transparent hugepages are handled by generic code. We can skip them
-	 * here.
-	 */
-	if (!shift || is_thp)
-		goto no_page;
-
-	if (!pte_present(pte)) {
-		page = NULL;
-		goto no_page;
-	}
-	mask = (1UL << shift) - 1;
-	page = pte_page(pte);
-	if (page)
-		page += (address & mask) / PAGE_SIZE;
-
-no_page:
-	local_irq_restore(flags);
-	return page;
-}
-
-struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd, int write)
-{
-	BUG();
-	return NULL;
-}
-
-struct page *
-follow_huge_pud(struct mm_struct *mm, unsigned long address,
-		pud_t *pud, int write)
-{
-	BUG();
-	return NULL;
-}
-#endif
-
 static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
 				      unsigned long sz)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
