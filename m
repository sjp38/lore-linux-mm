Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 445A38D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:33:25 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 7/7] HWPOISON, hugetlb: fix hard offline for hugepage backed KVM guest
Date: Fri, 21 Jan 2011 15:29:00 +0900
Message-Id: <1295591340-1862-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

When a qemu-kvm process touches HWPOISONed pages,
we expect that a SIGBUS signal causes MCE on the guest OS.
But currently it doesn't work on a hugepage backed KVM guest
because is_hwpoison_address() can't detect the HWPOISON entry
on PMD and the guest repeats page fault infinitely.

This patch fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Huang Ying <ying.huang@intel.com>
---
 include/linux/swapops.h |   12 ++++++++++++
 mm/hugetlb.c            |    4 +++-
 mm/memory-failure.c     |    2 +-
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git v2.6.38-rc1/include/linux/swapops.h v2.6.38-rc1/include/linux/swapops.h
index a220ef5..2c1a942 100644
--- v2.6.38-rc1/include/linux/swapops.h
+++ v2.6.38-rc1/include/linux/swapops.h
@@ -177,3 +177,15 @@ extern void migration_hugepage_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 static inline void migration_hugepage_entry_wait(struct mm_struct *mm,
 				 pmd_t *pmd, unsigned long address) { }
 #endif
+
+#if defined(CONFIG_MEMORY_FAILURE) && defined(CONFIG_HUGETLB_PAGE)
+extern int is_hugetlb_entry_hwpoisoned(pte_t pte);
+#else
+static inline int is_hugetlb_entry_hwpoisoned(pte_t pte)
+{
+	return 0;
+}
+#endif
+
+
+
diff --git v2.6.38-rc1/mm/hugetlb.c v2.6.38-rc1/mm/hugetlb.c
index b777c81..c65922e 100644
--- v2.6.38-rc1/mm/hugetlb.c
+++ v2.6.38-rc1/mm/hugetlb.c
@@ -2185,7 +2185,8 @@ static int is_hugetlb_entry_migration(pte_t pte)
 		return 0;
 }
 
-static int is_hugetlb_entry_hwpoisoned(pte_t pte)
+#ifdef CONFIG_MEMORY_FAILURE
+int is_hugetlb_entry_hwpoisoned(pte_t pte)
 {
 	swp_entry_t swp;
 
@@ -2197,6 +2198,7 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 	} else
 		return 0;
 }
+#endif
 
 void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			    unsigned long end, struct page *ref_page)
diff --git v2.6.38-rc1/mm/memory-failure.c v2.6.38-rc1/mm/memory-failure.c
index eed1846..8ee5038 100644
--- v2.6.38-rc1/mm/memory-failure.c
+++ v2.6.38-rc1/mm/memory-failure.c
@@ -1461,7 +1461,7 @@ int is_hwpoison_address(unsigned long addr)
 	pmdp = pmd_offset(pudp, addr);
 	pmd = *pmdp;
 	if (!pmd_present(pmd) || pmd_large(pmd))
-		return 0;
+		return is_hugetlb_entry_hwpoisoned(*(pte_t *)pmdp);
 	ptep = pte_offset_map(pmdp, addr);
 	pte = *ptep;
 	pte_unmap(ptep);
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
