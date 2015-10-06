Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 484D06B0263
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:31:34 -0400 (EDT)
Received: by igxx6 with SMTP id x6so83143533igx.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:31:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 17si23130986iom.144.2015.10.06.08.24.30
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 08:24:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv12 33/37] migrate_pages: try to split pages on qeueuing
Date: Tue,  6 Oct 2015 18:24:00 +0300
Message-Id: <1444145044-72349-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are not able to migrate THPs. It means it's not enough to split only
PMD on migration -- we need to split compound page under it too.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/mempolicy.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8102f30a3895..4a02de4e173f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -489,14 +489,31 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 	struct page *page;
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
-	int nid;
+	int nid, ret;
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	split_huge_pmd(vma, pmd, addr);
-	if (pmd_trans_unstable(pmd))
-		return 0;
+	if (pmd_trans_huge(*pmd)) {
+		ptl = pmd_lock(walk->mm, pmd);
+		if (pmd_trans_huge(*pmd)) {
+			page = pmd_page(*pmd);
+			if (is_huge_zero_page(page)) {
+				spin_unlock(ptl);
+				split_huge_pmd(vma, pmd, addr);
+			} else {
+				get_page(page);
+				spin_unlock(ptl);
+				lock_page(page);
+				ret = split_huge_page(page);
+				unlock_page(page);
+				put_page(page);
+				if (ret)
+					return 0;
+			}
+		}
+	}
 
+retry:
 	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		if (!pte_present(*pte))
@@ -513,6 +530,21 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		nid = page_to_nid(page);
 		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 			continue;
+		if (PageTail(page) && PageAnon(page)) {
+			get_page(page);
+			pte_unmap_unlock(pte, ptl);
+			lock_page(page);
+			ret = split_huge_page(page);
+			unlock_page(page);
+			put_page(page);
+			/* Failed to split -- skip. */
+			if (ret) {
+				pte = pte_offset_map_lock(walk->mm, pmd,
+						addr, &ptl);
+				continue;
+			}
+			goto retry;
+		}
 
 		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 			migrate_page_add(page, qp->pagelist, flags);
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
