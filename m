Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E79368D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:32:41 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/7] hugetlb: check swap entry in follow_hugetlb_page()
Date: Fri, 21 Jan 2011 15:28:54 +0900
Message-Id: <1295591340-1862-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KVM host calls follow_hugetlb_page() in HVA-PFN translation
(through get_user_pages(),) so we need to have it handle swap
entry to detect HWPOISONed or migrating hugepages.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git v2.6.38-rc1/mm/hugetlb.c v2.6.38-rc1/mm/hugetlb.c
index bb0b7c1..97c7471 100644
--- v2.6.38-rc1/mm/hugetlb.c
+++ v2.6.38-rc1/mm/hugetlb.c
@@ -2731,6 +2731,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
 		int absent;
+		int swap;
 		struct page *page;
 
 		/*
@@ -2740,6 +2741,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
 		absent = !pte || huge_pte_none(huge_ptep_get(pte));
+		swap = !absent && !pte_present(*pte);
 
 		/*
 		 * When coredumping, it suits get_dump_page if we just return
@@ -2754,7 +2756,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			break;
 		}
 
-		if (absent ||
+		if (absent || swap ||
 		    ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
 			int ret;
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
