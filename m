Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C87096B04AF
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:40:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f19-v6so19459161pgv.4
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:40:06 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z9-v6si21682595plk.94.2018.05.09.01.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 01:40:05 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2 18/21] mm, THP, swap: Support PMD swap mapping in mincore()
Date: Wed,  9 May 2018 16:38:43 +0800
Message-Id: <20180509083846.14823-19-ying.huang@intel.com>
In-Reply-To: <20180509083846.14823-1-ying.huang@intel.com>
References: <20180509083846.14823-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

During mincore(), for PMD swap mapping, swap cache will be looked up.
If the resulting page isn't compound page, the PMD swap mapping will
be split and fallback to PTE swap mapping processing.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/mincore.c | 37 +++++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index a66f2052c7b1..897dd2c187e8 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -48,7 +48,8 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
  * and is up to date; i.e. that no page-in operation would be required
  * at this time if an application were to map and access this page.
  */
-static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
+static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff,
+				  bool *compound)
 {
 	unsigned char present = 0;
 	struct page *page;
@@ -86,6 +87,8 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 #endif
 	if (page) {
 		present = PageUptodate(page);
+		if (compound)
+			*compound = PageCompound(page);
 		put_page(page);
 	}
 
@@ -103,7 +106,8 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 
 		pgoff = linear_page_index(vma, addr);
 		for (i = 0; i < nr; i++, pgoff++)
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+			vec[i] = mincore_page(vma->vm_file->f_mapping,
+					      pgoff, NULL);
 	} else {
 		for (i = 0; i < nr; i++)
 			vec[i] = 0;
@@ -127,14 +131,36 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *ptep;
 	unsigned char *vec = walk->private;
 	int nr = (end - addr) >> PAGE_SHIFT;
+	swp_entry_t entry;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
-		memset(vec, 1, nr);
+		unsigned char val = 1;
+		bool compound;
+
+		if (thp_swap_supported() && is_swap_pmd(*pmd)) {
+			entry = pmd_to_swp_entry(*pmd);
+			if (!non_swap_entry(entry)) {
+				val = mincore_page(swap_address_space(entry),
+						   swp_offset(entry),
+						   &compound);
+				/*
+				 * The huge swap cluster has been
+				 * split under us
+				 */
+				if (!compound) {
+					__split_huge_swap_pmd(vma, addr, pmd);
+					spin_unlock(ptl);
+					goto fallback;
+				}
+			}
+		}
+		memset(vec, val, nr);
 		spin_unlock(ptl);
 		goto out;
 	}
 
+fallback:
 	if (pmd_trans_unstable(pmd)) {
 		__mincore_unmapped_range(addr, end, vma, vec);
 		goto out;
@@ -150,8 +176,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		else if (pte_present(pte))
 			*vec = 1;
 		else { /* pte is a swap entry */
-			swp_entry_t entry = pte_to_swp_entry(pte);
-
+			entry = pte_to_swp_entry(pte);
 			if (non_swap_entry(entry)) {
 				/*
 				 * migration or hwpoison entries are always
@@ -161,7 +186,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			} else {
 #ifdef CONFIG_SWAP
 				*vec = mincore_page(swap_address_space(entry),
-						    swp_offset(entry));
+						    swp_offset(entry), NULL);
 #else
 				WARN_ON(1);
 				*vec = 1;
-- 
2.16.1
