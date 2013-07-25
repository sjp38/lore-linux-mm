Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 8CF446B0036
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 00:55:44 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/8] migrate: add hugepage migration code to move_pages()
Date: Thu, 25 Jul 2013 00:54:59 -0400
Message-Id: <1374728103-17468-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch extends move_pages() to handle vma with VM_HUGETLB set.
We will be able to migrate hugepage with move_pages(2) after
applying the enablement patch which comes later in this series.

We avoid getting refcount on tail pages of hugepage, because unlike thp,
hugepage is not split and we need not care about races with splitting.

And migration of larger (1GB for x86_64) hugepage are not enabled.

ChangeLog v4:
 - use get_page instead of get_page_foll
 - add comment in follow_page_mask

ChangeLog v3:
 - revert introducing migrate_movable_pages
 - follow_page_mask(FOLL_GET) returns NULL for tail pages
 - use isolate_huge_page

ChangeLog v2:
 - updated description and renamed patch title

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory.c  | 17 +++++++++++++++--
 mm/migrate.c | 13 +++++++++++--
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git v3.11-rc1.orig/mm/memory.c v3.11-rc1/mm/memory.c
index 1ce2e2a..7ec1252 100644
--- v3.11-rc1.orig/mm/memory.c
+++ v3.11-rc1/mm/memory.c
@@ -1496,7 +1496,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pud_none(*pud))
 		goto no_page_table;
 	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		BUG_ON(flags & FOLL_GET);
+		if (flags & FOLL_GET)
+			goto out;
 		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
 		goto out;
 	}
@@ -1507,8 +1508,20 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pmd_none(*pmd))
 		goto no_page_table;
 	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		BUG_ON(flags & FOLL_GET);
 		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
+		if (flags & FOLL_GET) {
+			/*
+			 * Refcount on tail pages are not well-defined and
+			 * shouldn't be taken. The caller should handle a NULL
+			 * return when trying to follow tail pages.
+			 */
+			if (PageHead(page))
+				get_page(page);
+			else {
+				page = NULL;
+				goto out;
+			}
+		}
 		goto out;
 	}
 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
diff --git v3.11-rc1.orig/mm/migrate.c v3.11-rc1/mm/migrate.c
index 3ec47d3..d313737 100644
--- v3.11-rc1.orig/mm/migrate.c
+++ v3.11-rc1/mm/migrate.c
@@ -1092,7 +1092,11 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 
 	*result = &pm->status;
 
-	return alloc_pages_exact_node(pm->node,
+	if (PageHuge(p))
+		return alloc_huge_page_node(page_hstate(compound_head(p)),
+					pm->node);
+	else
+		return alloc_pages_exact_node(pm->node,
 				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
 }
 
@@ -1152,6 +1156,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 				!migrate_all)
 			goto put_and_set;
 
+		if (PageHuge(page)) {
+			isolate_huge_page(page, &pagelist);
+			goto put_and_set;
+		}
+
 		err = isolate_lru_page(page);
 		if (!err) {
 			list_add_tail(&page->lru, &pagelist);
@@ -1174,7 +1183,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
 		if (err)
-			putback_lru_pages(&pagelist);
+			putback_movable_pages(&pagelist);
 	}
 
 	up_read(&mm->mmap_sem);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
