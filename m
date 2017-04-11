Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 781D06B03A0
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 13:42:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o68so2051782pfj.20
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:42:56 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id i5si17481238pgh.191.2017.04.11.10.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 10:42:55 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i5so647892pfc.3
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:42:55 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH 1/9] mm/huge_memory: Use zap_deposited_table() more
Date: Wed, 12 Apr 2017 03:42:25 +1000
Message-Id: <20170411174233.21902-2-oohall@gmail.com>
In-Reply-To: <20170411174233.21902-1-oohall@gmail.com>
References: <20170411174233.21902-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: arbab@linux.vnet.ibm.com, bsingharora@gmail.com, linux-nvdimm@lists.01.org, Oliver O'Halloran <oohall@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

Depending flags of the PMD being zapped there may or may not be a
deposited pgtable to be freed. In two of the three cases this is open
coded while the third uses the zap_deposited_table() helper. This patch
converts the others to use the helper to clean things up a bit.

Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
For reference:

void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
{
        pgtable_t pgtable;

        pgtable = pgtable_trans_huge_withdraw(mm, pmd);
        pte_free(mm, pgtable);
        atomic_long_dec(&mm->nr_ptes);
}
---
 mm/huge_memory.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b787c4cfda0e..aa01dd47cc65 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1615,8 +1615,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		if (is_huge_zero_pmd(orig_pmd))
 			tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else if (is_huge_zero_pmd(orig_pmd)) {
-		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
-		atomic_long_dec(&tlb->mm->nr_ptes);
+		zap_deposited_table(tlb->mm, pmd);
 		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else {
@@ -1625,10 +1624,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 		VM_BUG_ON_PAGE(!PageHead(page), page);
 		if (PageAnon(page)) {
-			pgtable_t pgtable;
-			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
-			pte_free(tlb->mm, pgtable);
-			atomic_long_dec(&tlb->mm->nr_ptes);
+			zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 		} else {
 			if (arch_needs_pgtable_deposit())
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
