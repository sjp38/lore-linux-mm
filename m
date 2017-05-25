Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 652756B02FA
	for <linux-mm@kvack.org>; Thu, 25 May 2017 10:19:57 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 23so82215972qks.12
        for <linux-mm@kvack.org>; Thu, 25 May 2017 07:19:57 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id h18si3174105qtb.259.2017.05.25.07.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 07:19:56 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v6 08/10] mm: mempolicy: mbind and migrate_pages support thp migration
Date: Thu, 25 May 2017 10:19:43 -0400
Message-Id: <20170525141945.56028-9-zi.yan@sent.com>
In-Reply-To: <20170525141945.56028-1-zi.yan@sent.com>
References: <20170525141945.56028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for mbind(2) and migrate_pages(2).

ChangeLog v1 -> v2:
- support pte-mapped and doubly-mapped thp

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog v2 -> v6:
- use the same gfp flag (GFP_TRANSHUGE) in mbind() and migrate_pages()
  for thp allocations.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/mempolicy.c | 108 +++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 79 insertions(+), 29 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 64f9eed068b8..292b7450e3e3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -97,6 +97,7 @@
 #include <linux/mm_inline.h>
 #include <linux/mmu_notifier.h>
 #include <linux/printk.h>
+#include <linux/swapops.h>
 
 #include <asm/tlbflush.h>
 #include <linux/uaccess.h>
@@ -495,6 +496,49 @@ static inline bool queue_pages_required(struct page *page,
 	return node_isset(nid, *qp->nmask) == !(flags & MPOL_MF_INVERT);
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
+		__split_huge_pmd(walk->vma, pmd, addr, false, NULL);
+		goto out;
+	}
+	if (!thp_migration_supported()) {
+		get_page(page);
+		spin_unlock(ptl);
+		lock_page(page);
+		ret = split_huge_page(page);
+		unlock_page(page);
+		put_page(page);
+		goto out;
+	}
+	if (!queue_pages_required(page, qp)) {
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
@@ -506,30 +550,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
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
-				__split_huge_pmd(vma, pmd, addr, false, NULL);
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
@@ -550,7 +579,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 			continue;
 		if (!queue_pages_required(page, qp))
 			continue;
-		if (PageTransCompound(page)) {
+		if (PageTransCompound(page) && !thp_migration_supported()) {
 			get_page(page);
 			pte_unmap_unlock(pte, ptl);
 			lock_page(page);
@@ -968,19 +997,21 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 
 #ifdef CONFIG_MIGRATION
 /*
- * page migration
+ * page migration, thp tail pages can be passed.
  */
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
+	struct page *head = compound_head(page);
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
-	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
-		if (!isolate_lru_page(page)) {
-			list_add_tail(&page->lru, pagelist);
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(head) == 1) {
+		if (!isolate_lru_page(head)) {
+			list_add_tail(&head->lru, pagelist);
+			mod_node_page_state(page_pgdat(head),
+				NR_ISOLATED_ANON + page_is_file_cache(head),
+				hpage_nr_pages(head));
 		}
 	}
 }
@@ -990,7 +1021,17 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
-	else
+	else if (thp_migration_supported() && PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(node,
+			(GFP_TRANSHUGE | __GFP_THISNODE),
+			HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
 		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
 						    __GFP_THISNODE, 0);
 }
@@ -1156,6 +1197,15 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
