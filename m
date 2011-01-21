Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8057D8D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:33:01 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/7] hugetlb, migration: add migration_hugepage_entry_wait()
Date: Fri, 21 Jan 2011 15:28:57 +0900
Message-Id: <1295591340-1862-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

migration_entry_wait() doesn't work for hugepage, because page->ptl
on hugepage is unused for now. So this patch introduces a hugepage
variant of this function.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/swapops.h |    8 ++++++++
 mm/hugetlb.c            |    3 ++-
 mm/migrate.c            |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 1 deletions(-)

diff --git v2.6.38-rc1/include/linux/swapops.h v2.6.38-rc1/include/linux/swapops.h
index cd42e30..a220ef5 100644
--- v2.6.38-rc1/include/linux/swapops.h
+++ v2.6.38-rc1/include/linux/swapops.h
@@ -169,3 +169,11 @@ static inline int non_swap_entry(swp_entry_t entry)
 	return 0;
 }
 #endif
+
+#if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_MIGRATION)
+extern void migration_hugepage_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+					unsigned long address);
+#else
+static inline void migration_hugepage_entry_wait(struct mm_struct *mm,
+				 pmd_t *pmd, unsigned long address) { }
+#endif
diff --git v2.6.38-rc1/mm/hugetlb.c v2.6.38-rc1/mm/hugetlb.c
index 97c7471..d3b856a 100644
--- v2.6.38-rc1/mm/hugetlb.c
+++ v2.6.38-rc1/mm/hugetlb.c
@@ -2618,7 +2618,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
-			migration_entry_wait(mm, (pmd_t *)ptep, address);
+			migration_hugepage_entry_wait(mm, (pmd_t *)ptep,
+						      address);
 			return 0;
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON_LARGE | 
diff --git v2.6.38-rc1/mm/migrate.c v2.6.38-rc1/mm/migrate.c
index 46fe8cc..363685f 100644
--- v2.6.38-rc1/mm/migrate.c
+++ v2.6.38-rc1/mm/migrate.c
@@ -220,6 +220,39 @@ out:
 	pte_unmap_unlock(ptep, ptl);
 }
 
+void migration_hugepage_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+				   unsigned long address)
+{
+	pte_t *ptep, pte;
+	spinlock_t *ptl;
+	swp_entry_t entry;
+	struct page *page;
+
+	ptep = (pte_t *)pmd;
+	ptl = &(mm)->page_table_lock;
+	spin_lock(ptl);
+	pte = *ptep;
+	if (!is_swap_pte(pte))
+		goto out;
+
+	entry = pte_to_swp_entry(pte);
+	if (!is_migration_entry(entry))
+		goto out;
+
+	page = migration_entry_to_page(entry);
+
+	if (!get_page_unless_zero(page))
+		goto out;
+	spin_unlock(ptl);
+	pte_unmap(ptep);
+	wait_on_page_locked(page);
+	put_page(page);
+	return;
+out:
+	spin_unlock(ptl);
+	pte_unmap(ptep);
+}
+
 /*
  * Replace the page in the mapping.
  *
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
