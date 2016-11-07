Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C41A6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 20:15:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so59514635pfx.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 17:15:51 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id b189si33431461pgc.333.2016.11.07.15.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:37 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 144so8955305pfv.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:37 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 10/12] mm: mempolicy: mbind and migrate_pages support thp migration
Date: Tue,  8 Nov 2016 08:31:55 +0900
Message-Id: <1478561517-4317-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch enables thp migration for mbind(2) and migrate_pages(2).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1 -> v2:
- support pte-mapped and doubly-mapped thp
---
 mm/mempolicy.c | 108 +++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 79 insertions(+), 29 deletions(-)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/mempolicy.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mempolicy.c
index 77d0668..96507ee 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/mempolicy.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mempolicy.c
@@ -94,6 +94,7 @@
 #include <linux/mm_inline.h>
 #include <linux/mmu_notifier.h>
 #include <linux/printk.h>
+#include <linux/swapops.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -486,6 +487,49 @@ static inline bool queue_pages_node_check(struct page *page,
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
@@ -497,30 +541,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
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
@@ -541,7 +570,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 			continue;
 		if (queue_pages_node_check(page, qp))
 			continue;
-		if (PageTransCompound(page)) {
+		if (PageTransCompound(page) && !thp_migration_supported()) {
 			get_page(page);
 			pte_unmap_unlock(pte, ptl);
 			lock_page(page);
@@ -959,19 +988,21 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 
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
@@ -981,7 +1012,17 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
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
@@ -1147,6 +1188,15 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
