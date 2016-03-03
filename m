Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D8E0E6B0253
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:06 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fy10so10112640pac.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:06 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id q26si41739829pfi.106.2016.03.02.23.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:06 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id 124so10265486pfg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:06 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 01/11] mm: mempolicy: add queue_pages_node_check()
Date: Thu,  3 Mar 2016 16:41:48 +0900
Message-Id: <1456990918-30906-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Introduce a separate check routine related to MPOL_MF_INVERT flag. This patch
just does cleanup, no behavioral change.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/mempolicy.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/mempolicy.c
index 8c5fd08..840a0ad 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/mempolicy.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/mempolicy.c
@@ -478,6 +478,15 @@ struct queue_pages {
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
@@ -529,8 +538,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		 */
 		if (PageReserved(page))
 			continue;
-		nid = page_to_nid(page);
-		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
+		if (queue_pages_node_check(page, qp))
 			continue;
 		if (PageTail(page) && PageAnon(page)) {
 			get_page(page);
@@ -562,7 +570,6 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
 #ifdef CONFIG_HUGETLB_PAGE
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
-	int nid;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
@@ -572,8 +579,7 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
