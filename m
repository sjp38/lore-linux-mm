Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF2A66B0390
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 16:47:58 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u30so16971354qtu.14
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 13:47:58 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 33si6029405qkx.134.2017.04.20.13.47.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 13:47:57 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v5 02/11] mm: mempolicy: add queue_pages_node_check()
Date: Thu, 20 Apr 2017 16:47:43 -0400
Message-Id: <20170420204752.79703-3-zi.yan@sent.com>
In-Reply-To: <20170420204752.79703-1-zi.yan@sent.com>
References: <20170420204752.79703-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Introduce a separate check routine related to MPOL_MF_INVERT flag.
This patch just does cleanup, no behavioral change.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index dc8a2672c407..fb18ce891586 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -477,6 +477,15 @@ struct queue_pages {
 	struct vm_area_struct *prev;
 };
 
+static inline bool queue_pages_node_check(struct page *page,
+					struct queue_pages *qp)
+{
+	int nid = page_to_nid(page);
+	unsigned long flags = qp->flags;
+
+	return node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT);
+}
+
 /*
  * Scan through pages checking if pages follow certain conditions,
  * and move them to the pagelist if they do.
@@ -530,8 +539,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		 */
 		if (PageReserved(page))
 			continue;
-		nid = page_to_nid(page);
-		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+		if (queue_pages_node_check(page, qp))
 			continue;
 		if (PageTransCompound(page)) {
 			get_page(page);
@@ -563,7 +571,6 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
 #ifdef CONFIG_HUGETLB_PAGE
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
-	int nid;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
@@ -573,8 +580,7 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
 	if (!pte_present(entry))
 		goto unlock;
 	page = pte_page(entry);
-	nid = page_to_nid(page);
-	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+	if (queue_pages_node_check(page, qp))
 		goto unlock;
 	/* With MPOL_MF_MOVE, we migrate only unshared hugepage. */
 	if (flags & (MPOL_MF_MOVE_ALL) ||
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
