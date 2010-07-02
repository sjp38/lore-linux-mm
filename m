Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 15DA76B01E6
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 01:50:10 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 6/7] hugetlb: hugepage migration core
Date: Fri,  2 Jul 2010 14:47:25 +0900
Message-Id: <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch extends page migration code to support hugepage migration.
One of the potential users of this feature is soft offlining which
is triggered by memory corrected errors (added by the next patch.)

Todo: there are other users of page migration such as memory policy,
memory hotplug and memocy compaction.
They are not ready for hugepage support for now.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 fs/hugetlbfs/inode.c    |    2 ++
 include/linux/hugetlb.h |    1 +
 mm/hugetlb.c            |   10 ++++++++--
 mm/migrate.c            |   44 ++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 53 insertions(+), 4 deletions(-)

diff --git v2.6.35-rc3-hwpoison/fs/hugetlbfs/inode.c v2.6.35-rc3-hwpoison/fs/hugetlbfs/inode.c
index a4e9a7e..8fd5967 100644
--- v2.6.35-rc3-hwpoison/fs/hugetlbfs/inode.c
+++ v2.6.35-rc3-hwpoison/fs/hugetlbfs/inode.c
@@ -31,6 +31,7 @@
 #include <linux/statfs.h>
 #include <linux/security.h>
 #include <linux/magic.h>
+#include <linux/migrate.h>
 
 #include <asm/uaccess.h>
 
@@ -675,6 +676,7 @@ static const struct address_space_operations hugetlbfs_aops = {
 	.write_begin	= hugetlbfs_write_begin,
 	.write_end	= hugetlbfs_write_end,
 	.set_page_dirty	= hugetlbfs_set_page_dirty,
+	.migratepage    = migrate_page,
 };
 
 
diff --git v2.6.35-rc3-hwpoison/include/linux/hugetlb.h v2.6.35-rc3-hwpoison/include/linux/hugetlb.h
index 0b73c53..952e3ce 100644
--- v2.6.35-rc3-hwpoison/include/linux/hugetlb.h
+++ v2.6.35-rc3-hwpoison/include/linux/hugetlb.h
@@ -320,6 +320,7 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 {
 	return 1;
 }
+#define page_hstate(p) NULL
 #endif
 
 #endif /* _LINUX_HUGETLB_H */
diff --git v2.6.35-rc3-hwpoison/mm/hugetlb.c v2.6.35-rc3-hwpoison/mm/hugetlb.c
index d7c462b..6e7f5f2 100644
--- v2.6.35-rc3-hwpoison/mm/hugetlb.c
+++ v2.6.35-rc3-hwpoison/mm/hugetlb.c
@@ -2640,8 +2640,14 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	ptep = huge_pte_offset(mm, address);
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
-		if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
-			return VM_FAULT_HWPOISON;
+		if (!(huge_pte_none(entry) || pte_present(entry))) {
+			if (is_migration_entry(pte_to_swp_entry(entry))) {
+				migration_entry_wait(mm, (pmd_t *)ptep,
+						     address);
+				return 0;
+			} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
+				return VM_FAULT_HWPOISON;
+		}
 	}
 
 	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
diff --git v2.6.35-rc3-hwpoison/mm/migrate.c v2.6.35-rc3-hwpoison/mm/migrate.c
index e4a381c..e7af148 100644
--- v2.6.35-rc3-hwpoison/mm/migrate.c
+++ v2.6.35-rc3-hwpoison/mm/migrate.c
@@ -32,6 +32,7 @@
 #include <linux/security.h>
 #include <linux/memcontrol.h>
 #include <linux/syscalls.h>
+#include <linux/hugetlb.h>
 #include <linux/gfp.h>
 
 #include "internal.h"
@@ -74,6 +75,8 @@ void putback_lru_pages(struct list_head *l)
 	struct page *page2;
 
 	list_for_each_entry_safe(page, page2, l, lru) {
+		if (PageHuge(page))
+			break;
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
@@ -95,6 +98,12 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	pte_t *ptep, pte;
  	spinlock_t *ptl;
 
+	if (unlikely(PageHuge(new))) {
+		ptep = huge_pte_offset(mm, addr);
+		ptl = &mm->page_table_lock;
+		goto check;
+	}
+
  	pgd = pgd_offset(mm, addr);
 	if (!pgd_present(*pgd))
 		goto out;
@@ -115,6 +124,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
  	}
 
  	ptl = pte_lockptr(mm, pmd);
+check:
  	spin_lock(ptl);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
@@ -130,10 +140,17 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
+	if (PageHuge(new))
+		pte = pte_mkhuge(pte);
 	flush_cache_page(vma, addr, pte_pfn(pte));
 	set_pte_at(mm, addr, ptep, pte);
 
-	if (PageAnon(new))
+	if (PageHuge(new)) {
+		if (PageAnon(new))
+			hugepage_add_anon_rmap(new, vma, addr);
+		else
+			page_dup_rmap(new);
+	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr);
 	else
 		page_add_file_rmap(new);
@@ -267,7 +284,14 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	 * Note that anonymous pages are accounted for
 	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
 	 * are mapped to swap space.
+	 *
+	 * Not account hugepage here for now because hugepage has
+	 * separate accounting rule.
 	 */
+	if (PageHuge(newpage)) {
+		spin_unlock_irq(&mapping->tree_lock);
+		return 0;
+	}
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
 	if (PageSwapBacked(page)) {
@@ -284,7 +308,17 @@ static int migrate_page_move_mapping(struct address_space *mapping,
  */
 static void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	copy_highpage(newpage, page);
+	int i;
+	struct hstate *h;
+	if (!PageHuge(newpage))
+		copy_highpage(newpage, page);
+	else {
+		h = page_hstate(newpage);
+		for (i = 0; i < pages_per_huge_page(h); i++) {
+			cond_resched();
+			copy_highpage(newpage + i, page + i);
+		}
+	}
 
 	if (PageError(page))
 		SetPageError(newpage);
@@ -718,6 +752,11 @@ unlock:
 	put_page(page);
 
 	if (rc != -EAGAIN) {
+		if (PageHuge(newpage)) {
+			put_page(newpage);
+			goto out;
+		}
+
  		/*
  		 * A page that has been migrated has all references
  		 * removed and will be freed. A page that has not been
@@ -738,6 +777,7 @@ move_newpage:
 	 */
 	putback_lru_page(newpage);
 
+out:
 	if (result) {
 		if (rc)
 			*result = rc;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
