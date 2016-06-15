Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3586B0267
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:07:17 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l5so65646173ioa.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:07:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wa12si5647479pac.138.2016.06.15.13.07.00
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:07:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 13/37] thp: support file pages in zap_huge_pmd()
Date: Wed, 15 Jun 2016 23:06:18 +0300
Message-Id: <1466021202-61880-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

split_huge_pmd() for file mappings (and DAX too) is implemented by just
clearing pmd entry as we can re-fill this area from page cache on pte
level later.

This means we don't need deposit page tables when file THP is mapped.
Therefore we shouldn't try to withdraw a page table on zap_huge_pmd()
file THP PMD.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b24b7993c369..d8fd49073280 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1693,10 +1693,16 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		struct page *page = pmd_page(orig_pmd);
 		page_remove_rmap(page, true);
 		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 		VM_BUG_ON_PAGE(!PageHead(page), page);
-		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
-		atomic_long_dec(&tlb->mm->nr_ptes);
+		if (PageAnon(page)) {
+			pgtable_t pgtable;
+			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
+			pte_free(tlb->mm, pgtable);
+			atomic_long_dec(&tlb->mm->nr_ptes);
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+		} else {
+			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+		}
 		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
 	}
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
