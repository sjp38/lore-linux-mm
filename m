Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 55F41900016
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:40 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kx10so12336404pab.13
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id km8si5087460pbc.254.2015.02.12.08.19.39
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 07/24] mm, thp: adjust conditions when we can reuse the page on WP fault
Date: Thu, 12 Feb 2015 18:18:21 +0200
Message-Id: <1423757918-197669-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we will be able map the same compound page with
PTEs and PMDs. It requires adjustment to conditions when we can reuse
the page on write-protection fault.

For PTE fault we can't reuse the page if it's part of huge page.

For PMD we can only reuse the page if nobody else maps the huge page or
it's part. We can do it by checking page_mapcount() on each sub-page,
but it's expensive.

The cheaper way is to check page_count() to be equal 1: every mapcount
takes page reference, so this way we can guarantee, that the PMD is the
only mapping.

This approach can give false negative if somebody pinned the page, but
that doesn't affect correctness.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/swap.h |  3 ++-
 mm/huge_memory.c     | 12 +++++++++++-
 mm/rmap.c            |  2 +-
 mm/swapfile.c        |  3 +++
 4 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7067eca501e2..f0e4868f63b1 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -523,7 +523,8 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
-#define reuse_swap_page(page)	(page_mapcount(page) == 1)
+#define reuse_swap_page(page) \
+	(!PageTransCompound(page) && page_mapcount(page) == 1)
 
 static inline int try_to_free_swap(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 17be7a978f17..156f34b9e334 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1092,7 +1092,17 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(orig_pmd);
 	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
-	if (page_mapcount(page) == 1) {
+	/*
+	 * We can only reuse the page if nobody else maps the huge page or it's
+	 * part. We can do it by checking page_mapcount() on each sub-page, but
+	 * it's expensive.
+	 * The cheaper way is to check page_count() to be equal 1: every
+	 * mapcount takes page reference reference, so this way we can
+	 * guarantee, that the PMD is the only mapping.
+	 * This can give false negative if somebody pinned the page, but that's
+	 * fine.
+	 */
+	if (page_mapcount(page) == 1 && page_count(page) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
diff --git a/mm/rmap.c b/mm/rmap.c
index 333938475831..db8b99e48966 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1215,7 +1215,7 @@ void page_remove_rmap(struct page *page, bool compound)
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 		/* The page can be mapped with ptes */
-		for (i = 0; i < HPAGE_PMD_NR; i++)
+		for (i = 0; i < hpage_nr_pages(page); i++)
 			if (page_mapcount(page + i))
 				nr--;
 	}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 200298895cee..99f97c31ede5 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -887,6 +887,9 @@ int reuse_swap_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	if (unlikely(PageKsm(page)))
 		return 0;
+	/* The page is part of THP and cannot be reused */
+	if (PageTransCompound(page))
+		return 0;
 	count = page_mapcount(page);
 	if (count <= 1 && PageSwapCache(page)) {
 		count += page_swapcount(page);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
