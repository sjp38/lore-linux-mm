Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 65E2982F68
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:24:52 -0400 (EDT)
Received: by iofh134 with SMTP id h134so226035195iof.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:24:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 92si23132933iok.118.2015.10.06.08.24.29
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 08:24:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv12 30/37] thp: add option to setup migration entries during PMD split
Date: Tue,  6 Oct 2015 18:23:57 +0300
Message-Id: <1444145044-72349-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to use migration PTE entries to stabilize page counts.
If the page is mapped with PMDs we need to split the PMD and setup
migration entries. It's reasonable to combine these operations to avoid
double-scanning over the page table.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/huge_memory.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d2a86df4dd00..4a2a263790b2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2806,7 +2806,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 }
 
 static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long haddr)
+		unsigned long haddr, bool freeze)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
@@ -2850,12 +2850,18 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		 * transferred to avoid any possibility of altering
 		 * permissions across VMAs.
 		 */
-		entry = mk_pte(page + i, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (!write)
-			entry = pte_wrprotect(entry);
-		if (!young)
-			entry = pte_mkold(entry);
+		if (freeze) {
+			swp_entry_t swp_entry;
+			swp_entry = make_migration_entry(page + i, write);
+			entry = swp_entry_to_pte(swp_entry);
+		} else {
+			entry = mk_pte(page + i, vma->vm_page_prot);
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			if (!write)
+				entry = pte_wrprotect(entry);
+			if (!young)
+				entry = pte_mkold(entry);
+		}
 		pte = pte_offset_map(&_pmd, haddr);
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, haddr, pte, entry);
@@ -2896,7 +2902,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
 	if (likely(pmd_trans_huge(*pmd)))
-		__split_huge_pmd_locked(vma, pmd, haddr);
+		__split_huge_pmd_locked(vma, pmd, haddr, false);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
 }
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
