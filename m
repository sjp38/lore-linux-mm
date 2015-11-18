Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F0CFF6B0258
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:25:46 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so59448700pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:25:46 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tq4si7233407pab.243.2015.11.18.15.25.46
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 15:25:46 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 7/9] thp: support file pages in zap_huge_pmd()
Date: Thu, 19 Nov 2015 01:25:34 +0200
Message-Id: <1447889136-6928-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For file pages we don't deposit page table on mapping: no need to
withdraw it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9c1db950341a..661e144a619d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1531,10 +1531,16 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
