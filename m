Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 693326B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 13:03:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o74so107247217pfi.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:03:08 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 14si8898997plb.203.2017.06.19.10.03.07
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 10:03:07 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v5 8/8] mm: rmap: Use correct helper when poisoning hugepages
Date: Mon, 19 Jun 2017 18:01:45 +0100
Message-Id: <20170619170145.25577-9-punit.agrawal@arm.com>
In-Reply-To: <20170619170145.25577-1-punit.agrawal@arm.com>
References: <20170619170145.25577-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com

Using set_pte_at() does not do the right thing when putting down
HWPOISON swap entries for hugepages on architectures that support
contiguous ptes.

Fix this problem by using set_huge_swap_pte_at() which was introduced to
fix exactly this problem.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Acked-by: Steve Capper <steve.capper@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index d405f0e0ee96..feb2352aa95f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1379,15 +1379,18 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
