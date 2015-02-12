Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 86A386B0070
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:20:13 -0500 (EST)
Received: by pdjz10 with SMTP id z10so12844383pdj.12
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:20:13 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dh1si1708434pbc.142.2015.02.12.08.20.08
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:20:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 08/24] mm: adjust FOLL_SPLIT for new refcounting
Date: Thu, 12 Feb 2015 18:18:22 +0200
Message-Id: <1423757918-197669-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We prepare kernel to allow transhuge pages to be mapped with ptes too.
We need to handle FOLL_SPLIT in follow_page_pte().

Also we use split_huge_page() directly instead of split_huge_page_pmd().
split_huge_page_pmd() will gone.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 65 ++++++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 45 insertions(+), 20 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index a6e24e246f86..022d7a91de03 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -79,6 +79,20 @@ retry:
 		page = pte_page(pte);
 	}
 
+	if (flags & FOLL_SPLIT && PageTransCompound(page)) {
+		int ret;
+		page = compound_head(page);
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
@@ -186,27 +200,38 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	}
 	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		return no_page_table(vma, flags);
-	if (pmd_trans_huge(*pmd)) {
-		if (flags & FOLL_SPLIT) {
-			split_huge_page_pmd(vma, address, pmd);
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
-			spin_unlock(ptl);
+	if (likely(!pmd_trans_huge(*pmd)))
+		return follow_page_pte(vma, address, pmd, flags);
+
+	ptl = pmd_lock(mm, pmd);
+	if (unlikely(!pmd_trans_huge(*pmd))) {
+		spin_unlock(ptl);
+		return follow_page_pte(vma, address, pmd, flags);
 	}
-	return follow_page_pte(vma, address, pmd, flags);
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
+		get_page(page);
+		spin_unlock(ptl);
+		lock_page(page);
+		ret = split_huge_page(page);
+		unlock_page(page);
+		put_page(page);
+		return ret ? ERR_PTR(ret) :
+			follow_page_pte(vma, address, pmd, flags);
+	}
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
