Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEE86B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 10:19:55 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j58so77200398qtc.2
        for <linux-mm@kvack.org>; Thu, 25 May 2017 07:19:55 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id q62si3224183qkd.51.2017.05.25.07.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 07:19:54 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v6 01/10] mm: mempolicy: add queue_pages_required()
Date: Thu, 25 May 2017 10:19:36 -0400
Message-Id: <20170525141945.56028-2-zi.yan@sent.com>
In-Reply-To: <20170525141945.56028-1-zi.yan@sent.com>
References: <20170525141945.56028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Introduce a separate check routine related to MPOL_MF_INVERT flag.
This patch just does cleanup, no behavioral change.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/mempolicy.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 37d0b334bfe9..64f9eed068b8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -481,6 +481,21 @@ struct queue_pages {
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
@@ -533,8 +548,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		 */
 		if (PageReserved(page))
 			continue;
-		nid = page_to_nid(page);
-		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+		if (!queue_pages_required(page, qp))
 			continue;
 		if (PageTransCompound(page)) {
 			get_page(page);
@@ -566,7 +580,6 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
 #ifdef CONFIG_HUGETLB_PAGE
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
-	int nid;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
@@ -576,8 +589,7 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
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
