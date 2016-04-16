Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C49D0828DF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:24:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so214558563pfe.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 17:24:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q76si5201007pfa.60.2016.04.15.17.24.37
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 17:24:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 08/29] thp: support file pages in zap_huge_pmd()
Date: Sat, 16 Apr 2016 03:23:39 +0300
Message-Id: <1460766240-84565-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index cece53a94192..29ba922a9c26 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1696,10 +1696,16 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
 		tlb_remove_page(tlb, page);
 	}
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
