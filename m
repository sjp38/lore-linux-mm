Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B077A6B0038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:24:15 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so213601366pac.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:24:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ep1si49593225pbd.256.2015.10.06.08.24.14
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 08:24:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv12 04/37] mm, thp: adjust conditions when we can reuse the page on WP fault
Date: Tue,  6 Oct 2015 18:23:31 +0300
Message-Id: <1444145044-72349-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/swap.h |  3 ++-
 mm/huge_memory.c     | 12 +++++++++++-
 mm/swapfile.c        |  3 +++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 9c7c4b418498..1184fdbd30ba 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -540,7 +540,8 @@ static inline int swp_swapcount(swp_entry_t entry)
 	return 0;
 }
 
-#define reuse_swap_page(page)	(page_mapcount(page) == 1)
+#define reuse_swap_page(page) \
+	(!PageTransCompound(page) && page_mapcount(page) == 1)
 
 static inline int try_to_free_swap(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7c41c0606e98..76a845b12d8d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1230,7 +1230,17 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
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
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f131bc1838d3..c6aec93c8c0b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -929,6 +929,9 @@ int reuse_swap_page(struct page *page)
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
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
