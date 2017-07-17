Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8B76B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:40:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h15so77262851qte.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:40:29 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id i124si57667qkd.315.2017.07.17.12.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 12:40:28 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v9 01/10] mm: mempolicy: add queue_pages_required()
Date: Mon, 17 Jul 2017 15:39:46 -0400
Message-Id: <20170717193955.20207-2-zi.yan@sent.com>
In-Reply-To: <20170717193955.20207-1-zi.yan@sent.com>
References: <20170717193955.20207-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Introduce a separate check routine related to MPOL_MF_INVERT flag.
This patch just does cleanup, no behavioral change.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/mempolicy.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d911fa5cb2a7..58166bf1d1fd 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -412,6 +412,21 @@ struct queue_pages {
 };
 
 /*
+ * Check if the page's nid is in qp->nmask.
+ *
+ * If MPOL_MF_INVERT is set in qp->flags, check if the nid is
+ * in the invert of qp->nmask.
+ */
+static inline bool queue_pages_required(struct page *page,
+					struct queue_pages *qp)
+{
+	int nid = page_to_nid(page);
+	unsigned long flags = qp->flags;
+
+	return node_isset(nid, *qp->nmask) == !(flags & MPOL_MF_INVERT);
+}
+
+/*
  * Scan through pages checking if pages follow certain conditions,
  * and move them to the pagelist if they do.
  */
@@ -464,8 +479,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		 */
 		if (PageReserved(page))
 			continue;
-		nid = page_to_nid(page);
-		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+		if (!queue_pages_required(page, qp))
 			continue;
 		if (PageTransCompound(page)) {
 			get_page(page);
@@ -497,7 +511,6 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
 #ifdef CONFIG_HUGETLB_PAGE
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
-	int nid;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
@@ -507,8 +520,7 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
 	if (!pte_present(entry))
 		goto unlock;
 	page = pte_page(entry);
-	nid = page_to_nid(page);
-	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+	if (!queue_pages_required(page, qp))
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
