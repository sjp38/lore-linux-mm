Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6356B006E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:47:10 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so7775821pdb.1
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:47:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id gq6si34781375pac.114.2015.06.23.06.47.07
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 04/36] mm, thp: adjust conditions when we can reuse the page on WP fault
Date: Tue, 23 Jun 2015 16:46:14 +0300
Message-Id: <1435067206-92901-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
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
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/swap.h |  3 ++-
 mm/huge_memory.c     | 12 +++++++++++-
 mm/swapfile.c        |  3 +++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 0428e4c84e1d..17cdd6b9456b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -524,7 +524,8 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
-#define reuse_swap_page(page)	(page_mapcount(page) == 1)
+#define reuse_swap_page(page) \
+	(!PageTransCompound(page) && page_mapcount(page) == 1)
 
 static inline int try_to_free_swap(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1043b9b0659c..6035cc92be6b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1128,7 +1128,17 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
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
index 6dd365d1c488..3cd5f188b996 100644
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
