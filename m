Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5D46B01CC
	for <linux-mm@kvack.org>; Thu, 27 May 2010 20:32:37 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 7/8] HWPOISON, hugetlb: detect hwpoison in hugetlb code
Date: Fri, 28 May 2010 09:29:21 +0900
Message-Id: <1275006562-18946-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch enables to block access to hwpoisoned hugepage and
also enables to block unmapping for it.

Dependency:
  "HWPOISON, hugetlb: enable error handling path for hugepage"

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/hugetlb.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git v2.6.34/mm/hugetlb.c v2.6.34/mm/hugetlb.c
index aaba3cc..5580568 100644
--- v2.6.34/mm/hugetlb.c
+++ v2.6.34/mm/hugetlb.c
@@ -19,6 +19,8 @@
 #include <linux/sysfs.h>
 #include <linux/slab.h>
 #include <linux/rmap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -2145,6 +2147,19 @@ nomem:
 	return -ENOMEM;
 }
 
+static int is_hugetlb_entry_hwpoisoned(pte_t pte)
+{
+	swp_entry_t swp;
+
+	if (huge_pte_none(pte) || pte_present(pte))
+		return 0;
+	swp = pte_to_swp_entry(pte);
+	if (non_swap_entry(swp) && is_hwpoison_entry(swp)) {
+		return 1;
+	} else
+		return 0;
+}
+
 void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			    unsigned long end, struct page *ref_page)
 {
@@ -2203,6 +2218,12 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 		if (huge_pte_none(pte))
 			continue;
 
+		/*
+		 * HWPoisoned hugepage is already unmapped and dropped reference
+		 */
+		if (unlikely(is_hugetlb_entry_hwpoisoned(pte)))
+			continue;
+
 		page = pte_page(pte);
 		if (pte_dirty(pte))
 			set_page_dirty(page);
@@ -2487,6 +2508,18 @@ retry:
 	}
 
 	/*
+	 * Since memory error handler replaces pte into hwpoison swap entry
+	 * at the time of error handling, a process which reserved but not have
+	 * the mapping to the error hugepage does not have hwpoison swap entry.
+	 * So we need to block accesses from such a process by checking
+	 * PG_hwpoison bit here.
+	 */
+	if (unlikely(PageHWPoison(page))) {
+		ret = VM_FAULT_HWPOISON;
+		goto backout_unlocked;
+	}
+
+	/*
 	 * If we are going to COW a private mapping later, we examine the
 	 * pending reservations for this page now. This will ensure that
 	 * any allocations necessary to record that reservation occur outside
@@ -2540,6 +2573,13 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
 
+	ptep = huge_pte_offset(mm, address);
+	if (ptep) {
+		entry = huge_ptep_get(ptep);
+		if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
+			return VM_FAULT_HWPOISON;
+	}
+
 	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
 	if (!ptep)
 		return VM_FAULT_OOM;
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
