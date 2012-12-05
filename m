Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C6DF56B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 16:47:54 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/3] HWPOISON, hugetlbfs: fix "bad pmd" warning in unmapping hwpoisoned hugepage
Date: Wed,  5 Dec 2012 16:47:37 -0500
Message-Id: <1354744058-26373-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1354744058-26373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1354744058-26373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

When a process which used a hwpoisoned hugepage tries to exit() or
munmap(), the kernel can print out "bad pmd" message because page
table walker in free_pgtables() encounters 'hwpoisoned entry' on pmd.

This is because currently we fail to clear the hwpoisoned entry in
__unmap_hugepage_range(), so this patch simply does it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git v3.7-rc8.orig/mm/hugetlb.c v3.7-rc8/mm/hugetlb.c
index e61a749..fe7c2a7 100644
--- v3.7-rc8.orig/mm/hugetlb.c
+++ v3.7-rc8/mm/hugetlb.c
@@ -2387,8 +2387,10 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		/*
 		 * HWPoisoned hugepage is already unmapped and dropped reference
 		 */
-		if (unlikely(is_hugetlb_entry_hwpoisoned(pte)))
+		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
+			pte_clear(mm, address, ptep);
 			continue;
+		}
 
 		page = pte_page(pte);
 		/*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
