Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 416686B03AF
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:38:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u202so7034845pgb.9
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:38:20 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m67si20665127pfm.52.2017.04.05.06.38.18
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:38:19 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2 6/9] mm: rmap: Use correct helper when poisoning hugepages
Date: Wed,  5 Apr 2017 14:37:19 +0100
Message-Id: <20170405133722.6406-7-punit.agrawal@arm.com>
In-Reply-To: <20170405133722.6406-1-punit.agrawal@arm.com>
References: <20170405133722.6406-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, mark.rutland@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com

Using set_pte_at() does not do the right thing when putting down
HWPOISON swap entries for hugepages on architectures that support
contiguous ptes.

Fix this problem by using set_huge_swap_pte_at() which was introduced to
fix exactly this problem.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index f6838015810f..e07c7912a166 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1386,15 +1386,19 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		update_hiwater_rss(mm);
 
 		if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
+			pteval = swp_entry_to_pte(make_hwpoison_entry(subpage));
 			if (PageHuge(page)) {
 				int nr = 1 << compound_order(page);
 				hugetlb_count_sub(nr, mm);
+				set_huge_swap_pte_at(mm, address,
+						     pvmw.pte, pteval,
+						     vma_mmu_pagesize(vma));
 			} else {
 				dec_mm_counter(mm, mm_counter(page));
+				set_pte_at(mm, address, pvmw.pte, pteval);
 			}
 
-			pteval = swp_entry_to_pte(make_hwpoison_entry(subpage));
-			set_pte_at(mm, address, pvmw.pte, pteval);
+
 		} else if (pte_unused(pteval)) {
 			/*
 			 * The guest indicated that the page content is of no
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
