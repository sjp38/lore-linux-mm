Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC776B004A
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 00:25:21 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/4] hugetlb, rmap: use hugepage_add_new_anon_rmap() in hugetlb_cow()
Date: Fri, 10 Sep 2010 13:23:04 +0900
Message-Id: <1284092586-1179-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Obviously, setting anon_vma for COWed hugepage should be done
by hugepage_add_new_anon_rmap() to scan vmas faster.
This patch fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git v2.6.36-rc3/mm/hugetlb.c v2.6.36-rc3/mm/hugetlb.c
index cc5be78..9519f3f 100644
--- v2.6.36-rc3/mm/hugetlb.c
+++ v2.6.36-rc3/mm/hugetlb.c
@@ -2404,7 +2404,7 @@ retry_avoidcopy:
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page);
-		hugepage_add_anon_rmap(new_page, vma, address);
+		hugepage_add_new_anon_rmap(new_page, vma, address);
 		/* Make the old page be freed below */
 		new_page = old_page;
 		mmu_notifier_invalidate_range_end(mm,
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
