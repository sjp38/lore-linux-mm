Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E80A082F64
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 11:02:53 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so53588018pad.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:02:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sp4si14187340pac.151.2015.09.18.08.02.24
        for <linux-mm@kvack.org>;
        Fri, 18 Sep 2015 08:02:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv11 33/37] migrate_pages: try to split pages on qeueuing
Date: Fri, 18 Sep 2015 18:01:36 +0300
Message-Id: <1442588500-77331-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1442588500-77331-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1442588500-77331-1-git-send-email-kirill.shutemov@linux.intel.com>
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
 mm/mempolicy.c | 37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8102f30a3895..8f128379172e 100644
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
@@ -513,6 +530,18 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		nid = page_to_nid(page);
 		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 			continue;
+		if (PageTail(page) && PageAnon(page)) {
+			get_page(page);
+			pte_unmap_unlock(pte - 1, ptl);
+			lock_page(page);
+			ret = split_huge_page(page);
+			unlock_page(page);
+			put_page(page);
+			/* Failed to split -- skip. */
+			if (ret)
+				continue;
+			goto retry;
+		}
 
 		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 			migrate_page_add(page, qp->pagelist, flags);
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
