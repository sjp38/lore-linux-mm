Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id EA2619003C8
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:42:38 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so171370015pab.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 10:42:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bu1si14815880pbc.87.2015.07.10.10.42.25
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 10:42:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 05/36] mm: adjust FOLL_SPLIT for new refcounting
Date: Fri, 10 Jul 2015 20:41:39 +0300
Message-Id: <1436550130-112636-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to prepare kernel to allow transhuge pages to be mapped with
ptes too. We need to handle FOLL_SPLIT in follow_page_pte().

Also we use split_huge_page() directly instead of split_huge_page_pmd().
split_huge_page_pmd() will gone.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/gup.c | 67 +++++++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 49 insertions(+), 18 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6297f6bccfb1..2dd6706ea29f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -79,6 +79,19 @@ retry:
 		page = pte_page(pte);
 	}
 
+	if (flags & FOLL_SPLIT && PageTransCompound(page)) {
+		int ret;
+		get_page(page);
+		pte_unmap_unlock(ptep, ptl);
+		lock_page(page);
+		ret = split_huge_page(page);
+		unlock_page(page);
+		put_page(page);
+		if (ret)
+			return ERR_PTR(ret);
+		goto retry;
+	}
+
 	if (flags & FOLL_GET)
 		get_page_foll(page);
 	if (flags & FOLL_TOUCH) {
@@ -186,27 +199,45 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	}
 	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		return no_page_table(vma, flags);
-	if (pmd_trans_huge(*pmd)) {
-		if (flags & FOLL_SPLIT) {
+	if (likely(!pmd_trans_huge(*pmd)))
+		return follow_page_pte(vma, address, pmd, flags);
+
+	ptl = pmd_lock(mm, pmd);
+	if (unlikely(!pmd_trans_huge(*pmd))) {
+		spin_unlock(ptl);
+		return follow_page_pte(vma, address, pmd, flags);
+	}
+
+	if (unlikely(pmd_trans_splitting(*pmd))) {
+		spin_unlock(ptl);
+		wait_split_huge_page(vma->anon_vma, pmd);
+		return follow_page_pte(vma, address, pmd, flags);
+	}
+
+	if (flags & FOLL_SPLIT) {
+		int ret;
+		page = pmd_page(*pmd);
+		if (is_huge_zero_page(page)) {
+			spin_unlock(ptl);
+			ret = 0;
 			split_huge_page_pmd(vma, address, pmd);
-			return follow_page_pte(vma, address, pmd, flags);
-		}
-		ptl = pmd_lock(mm, pmd);
-		if (likely(pmd_trans_huge(*pmd))) {
-			if (unlikely(pmd_trans_splitting(*pmd))) {
-				spin_unlock(ptl);
-				wait_split_huge_page(vma->anon_vma, pmd);
-			} else {
-				page = follow_trans_huge_pmd(vma, address,
-							     pmd, flags);
-				spin_unlock(ptl);
-				*page_mask = HPAGE_PMD_NR - 1;
-				return page;
-			}
-		} else
+		} else {
+			get_page(page);
 			spin_unlock(ptl);
+			lock_page(page);
+			ret = split_huge_page(page);
+			unlock_page(page);
+			put_page(page);
+		}
+
+		return ret ? ERR_PTR(ret) :
+			follow_page_pte(vma, address, pmd, flags);
 	}
-	return follow_page_pte(vma, address, pmd, flags);
+
+	page = follow_trans_huge_pmd(vma, address, pmd, flags);
+	spin_unlock(ptl);
+	*page_mask = HPAGE_PMD_NR - 1;
+	return page;
 }
 
 static int get_gate_page(struct mm_struct *mm, unsigned long address,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
