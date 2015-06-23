Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1806B008A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:47:45 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so7785373pdb.1
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:47:45 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id b1si31539348pat.26.2015.06.23.06.47.21
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 30/36] thp: add option to setup migration entiries during PMD split
Date: Tue, 23 Jun 2015 16:46:40 +0300
Message-Id: <1435067206-92901-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to use migration PTE entires to stabilize page counts.
If the page is mapped with PMDs we need to split the PMD and setup
migration enties. It's reasonable to combine these operations to avoid
double-scanning over the page table.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cd0e6addb662..259d9d4b3ece 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -24,6 +24,7 @@
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/swapops.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2576,7 +2577,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 }
 
 static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long haddr)
+		unsigned long haddr, bool freeze)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
@@ -2614,12 +2615,18 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
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
@@ -2671,7 +2678,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
 	if (likely(pmd_trans_huge(*pmd)))
-		__split_huge_pmd_locked(vma, pmd, haddr);
+		__split_huge_pmd_locked(vma, pmd, haddr, false);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
