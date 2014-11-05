Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id F24426B00AA
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:51 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so889894pdj.10
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:51 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id au4si3160374pbd.174.2014.11.05.06.50.46
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/19] mm, thp: adjust conditions when we can reuse the page on WP fault
Date: Wed,  5 Nov 2014 16:49:42 +0200
Message-Id: <1415198994-15252-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we will be able map the same compound page with
PTEs and PMDs. It requires adjustment to conditions when we can reuse
the page on write-protection fault.

For PTE fault we can't reuse the page if it's part of huge page.

For PMD we can only reuse the page if nobody else maps the huge page or
it's part. We can do it by checking page_mapcount() on each sub-page,
but it's expensive.
The cheaper way is to check page_count() to be equal 1: every mapcount
takes page reference reference, so this way we can guarantee, that the
PMD is the only mapping.
This can give false negative if somebody pinned the page, but that's
fine.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/swap.h |  8 +++++++-
 mm/huge_memory.c     | 12 +++++++++++-
 mm/swapfile.c        |  3 +++
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1b72060f093a..79333ea921c8 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -555,7 +555,13 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
-#define reuse_swap_page(page)	(page_mapcount(page) == 1)
+static inline int reuse_swap_page(struct page *page)
+{
+	/* The page is part of THP and cannot be reused */
+	if (PageTransCompound(page))
+		return 0;
+	return page_mapcount(page) == 1;
+}
 
 static inline int try_to_free_swap(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 869f9bcf481e..aa22350673a7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1106,7 +1106,17 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
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
index 57252bb35041..dfc81ba15697 100644
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
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
