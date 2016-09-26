Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08F0D6B02AE
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:14 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f187so189774802qkd.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:14 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id m73si3726413qkl.19.2016.09.26.08.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:13 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 09/12] mm: mempolicy: mbind and migrate_pages support thp migration
Date: Mon, 26 Sep 2016 11:22:31 -0400
Message-Id: <20160926152234.14809-10-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for mbind(2) and migrate_pages(2).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 92 ++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 70 insertions(+), 22 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index dc8e913..c10f71b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -94,6 +94,7 @@
 #include <linux/mm_inline.h>
 #include <linux/mmu_notifier.h>
 #include <linux/printk.h>
+#include <linux/swapops.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -484,6 +485,49 @@ static inline bool queue_pages_node_check(struct page *page,
 	return node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT);
 }
 
+static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	int ret = 0;
+	struct page *page;
+	struct queue_pages *qp = walk->private;
+	unsigned long flags;
+
+	if (unlikely(is_pmd_migration_entry(*pmd))) {
+		ret = 1;
+		goto unlock;
+	}
+	page = pmd_page(*pmd);
+	if (is_huge_zero_page(page)) {
+		spin_unlock(ptl);
+		split_huge_pmd(walk->vma, pmd, addr);
+		goto out;
+	}
+	if ((end - addr != HPAGE_PMD_SIZE) || !thp_migration_supported()) {
+		get_page(page);
+		spin_unlock(ptl);
+		lock_page(page);
+		ret = split_huge_page(page);
+		unlock_page(page);
+		put_page(page);
+		goto out;
+	}
+	if (queue_pages_node_check(page, qp)) {
+		ret = 1;
+		goto unlock;
+	}
+
+	ret = 1;
+	flags = qp->flags;
+	/* go to thp migration */
+	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+		migrate_page_add(page, qp->pagelist, flags);
+unlock:
+	spin_unlock(ptl);
+out:
+	return ret;
+}
+
 /*
  * Scan through pages checking if pages follow certain conditions,
  * and move them to the pagelist if they do.
@@ -495,30 +539,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 	struct page *page;
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
-	int nid, ret;
+	int ret;
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge(*pmd)) {
-		ptl = pmd_lock(walk->mm, pmd);
-		if (pmd_trans_huge(*pmd)) {
-			page = pmd_page(*pmd);
-			if (is_huge_zero_page(page)) {
-				spin_unlock(ptl);
-				split_huge_pmd(vma, pmd, addr);
-			} else {
-				get_page(page);
-				spin_unlock(ptl);
-				lock_page(page);
-				ret = split_huge_page(page);
-				unlock_page(page);
-				put_page(page);
-				if (ret)
-					return 0;
-			}
-		} else {
-			spin_unlock(ptl);
-		}
+	ptl = pmd_trans_huge_lock(pmd, vma);
+	if (ptl) {
+		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
+		if (ret)
+			return 0;
 	}
 
 	if (pmd_trans_unstable(pmd))
@@ -979,7 +1008,17 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
-	else
+	else if (thp_migration_supported() && PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(node,
+			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
+			HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
 		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
 						    __GFP_THISNODE, 0);
 }
@@ -1145,6 +1184,15 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
 	if (PageHuge(page)) {
 		BUG_ON(!vma);
 		return alloc_huge_page_noerr(vma, address, 1);
+	} else if (thp_migration_supported() && PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
+					 HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
 	}
 	/*
 	 * if !vma, alloc_page_vma() will use task or system default policy
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
