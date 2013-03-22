Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 260BE6B006E
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 16:24:35 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 06/10] migrate: add hugepage migration code to move_pages()
Date: Fri, 22 Mar 2013 16:23:51 -0400
Message-Id: <1363983835-20184-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

This patch extends move_pages() to handle vma with VM_HUGETLB set.
We will be able to migrate hugepage with move_pages(2) after
applying the enablement patch which comes later in this series.

We avoid getting refcount on tail pages of hugepage, because unlike thp,
hugepage is not split and we need not care about races with splitting.

And migration of larger (1GB for x86_64) hugepage are not enabled.

ChangeLog v2:
 - updated description and renamed patch title

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory.c  |  6 ++++--
 mm/migrate.c | 26 +++++++++++++++++++-------
 2 files changed, 23 insertions(+), 9 deletions(-)

diff --git v3.9-rc3.orig/mm/memory.c v3.9-rc3/mm/memory.c
index 494526a..3b6ad3d 100644
--- v3.9-rc3.orig/mm/memory.c
+++ v3.9-rc3/mm/memory.c
@@ -1503,7 +1503,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pud_none(*pud))
 		goto no_page_table;
 	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		BUG_ON(flags & FOLL_GET);
+		if (flags & FOLL_GET)
+			goto out;
 		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
 		goto out;
 	}
@@ -1514,8 +1515,9 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pmd_none(*pmd))
 		goto no_page_table;
 	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
-		BUG_ON(flags & FOLL_GET);
 		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
+		if (flags & FOLL_GET && PageHead(page))
+			get_page_foll(page);
 		goto out;
 	}
 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
index 38912ae..ef8e4e3 100644
--- v3.9-rc3.orig/mm/migrate.c
+++ v3.9-rc3/mm/migrate.c
@@ -1104,7 +1104,11 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 
 	*result = &pm->status;
 
-	return alloc_pages_exact_node(pm->node,
+	if (PageHuge(p))
+		return alloc_huge_page_node(page_hstate(compound_head(p)),
+					pm->node);
+	else
+		return alloc_pages_exact_node(pm->node,
 				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
 }
 
@@ -1150,6 +1154,13 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (PageReserved(page))
 			goto put_and_set;
 
+		/*
+		 * follow_page(FOLL_GET) didn't get refcount for tail pages of
+		 * hugepage, so here we skip putting it.
+		 */
+		if (PageHuge(page) && PageTail(page))
+			goto set_status;
+
 		pp->page = page;
 		err = page_to_nid(page);
 
@@ -1164,6 +1175,12 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 				!migrate_all)
 			goto put_and_set;
 
+		if (PageHuge(page)) {
+			get_page(page);
+			list_move_tail(&page->lru, &pagelist);
+			goto put_and_set;
+		}
+
 		err = isolate_lru_page(page);
 		if (!err) {
 			list_add_tail(&page->lru, &pagelist);
@@ -1181,13 +1198,8 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		pp->status = err;
 	}
 
-	err = 0;
-	if (!list_empty(&pagelist)) {
-		err = migrate_pages(&pagelist, new_page_node,
+	err = migrate_movable_pages(&pagelist, new_page_node,
 				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
-		if (err)
-			putback_lru_pages(&pagelist);
-	}
 
 	up_read(&mm->mmap_sem);
 	return err;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
