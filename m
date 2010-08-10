Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34CD86B02BE
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 05:32:48 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 5/9] hugetlb: hugepage migration core
Date: Tue, 10 Aug 2010 18:27:40 +0900
Message-Id: <1281432464-14833-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch extends page migration code to support hugepage migration.
One of the potential users of this feature is soft offlining which
is triggered by memory corrected errors (added by the next patch.)

Todo: there are other users of page migration such as memory policy,
memory hotplug and memocy compaction.
They are not ready for hugepage support for now.

ChangeLog since v1:
- divide migration code path for hugepage
- define routine checking migration swap entry for hugetlb
- replace "goto" with "if/else" in remove_migration_pte()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 fs/hugetlbfs/inode.c    |   15 ++++
 include/linux/migrate.h |   12 +++
 mm/hugetlb.c            |   18 ++++-
 mm/migrate.c            |  196 ++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 220 insertions(+), 21 deletions(-)

diff --git linux-mce-hwpoison/fs/hugetlbfs/inode.c linux-mce-hwpoison/fs/hugetlbfs/inode.c
index a4e9a7e..fee99e8 100644
--- linux-mce-hwpoison/fs/hugetlbfs/inode.c
+++ linux-mce-hwpoison/fs/hugetlbfs/inode.c
@@ -31,6 +31,7 @@
 #include <linux/statfs.h>
 #include <linux/security.h>
 #include <linux/magic.h>
+#include <linux/migrate.h>
 
 #include <asm/uaccess.h>
 
@@ -589,6 +590,19 @@ static int hugetlbfs_set_page_dirty(struct page *page)
 	return 0;
 }
 
+static int hugetlbfs_migrate_page(struct address_space *mapping,
+				struct page *newpage, struct page *page)
+{
+	int rc;
+
+	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
+	if (rc)
+		return rc;
+	migrate_page_copy(newpage, page);
+
+	return 0;
+}
+
 static int hugetlbfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(dentry->d_sb);
@@ -675,6 +689,7 @@ static const struct address_space_operations hugetlbfs_aops = {
 	.write_begin	= hugetlbfs_write_begin,
 	.write_end	= hugetlbfs_write_end,
 	.set_page_dirty	= hugetlbfs_set_page_dirty,
+	.migratepage    = hugetlbfs_migrate_page,
 };
 
 
diff --git linux-mce-hwpoison/include/linux/migrate.h linux-mce-hwpoison/include/linux/migrate.h
index 7238231..f4c15ff 100644
--- linux-mce-hwpoison/include/linux/migrate.h
+++ linux-mce-hwpoison/include/linux/migrate.h
@@ -23,6 +23,9 @@ extern int migrate_prep_local(void);
 extern int migrate_vmas(struct mm_struct *mm,
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
+extern void migrate_page_copy(struct page *newpage, struct page *page);
+extern int migrate_huge_page_move_mapping(struct address_space *mapping,
+				  struct page *newpage, struct page *page);
 #else
 #define PAGE_MIGRATION 0
 
@@ -40,6 +43,15 @@ static inline int migrate_vmas(struct mm_struct *mm,
 	return -ENOSYS;
 }
 
+static inline void migrate_page_copy(struct page *newpage,
+				     struct page *page) {}
+
+extern int migrate_huge_page_move_mapping(struct address_space *mapping,
+				  struct page *newpage, struct page *page)
+{
+	return -ENOSYS;
+}
+
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
 #define fail_migrate_page NULL
diff --git linux-mce-hwpoison/mm/hugetlb.c linux-mce-hwpoison/mm/hugetlb.c
index 2fb8679..0805524 100644
--- linux-mce-hwpoison/mm/hugetlb.c
+++ linux-mce-hwpoison/mm/hugetlb.c
@@ -2239,6 +2239,19 @@ nomem:
 	return -ENOMEM;
 }
 
+static int is_hugetlb_entry_migration(pte_t pte)
+{
+	swp_entry_t swp;
+
+	if (huge_pte_none(pte) || pte_present(pte))
+		return 0;
+	swp = pte_to_swp_entry(pte);
+	if (non_swap_entry(swp) && is_migration_entry(swp)) {
+		return 1;
+	} else
+		return 0;
+}
+
 static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 {
 	swp_entry_t swp;
@@ -2678,7 +2691,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	ptep = huge_pte_offset(mm, address);
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
-		if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
+		if (unlikely(is_hugetlb_entry_migration(entry))) {
+			migration_entry_wait(mm, (pmd_t *)ptep, address);
+			return 0;
+		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON;
 	}
 
diff --git linux-mce-hwpoison/mm/migrate.c linux-mce-hwpoison/mm/migrate.c
index 4205b1d..7f9a37c 100644
--- linux-mce-hwpoison/mm/migrate.c
+++ linux-mce-hwpoison/mm/migrate.c
@@ -32,6 +32,7 @@
 #include <linux/security.h>
 #include <linux/memcontrol.h>
 #include <linux/syscalls.h>
+#include <linux/hugetlb.h>
 #include <linux/gfp.h>
 
 #include "internal.h"
@@ -95,26 +96,34 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	pte_t *ptep, pte;
  	spinlock_t *ptl;
 
- 	pgd = pgd_offset(mm, addr);
-	if (!pgd_present(*pgd))
-		goto out;
+	if (unlikely(PageHuge(new))) {
+		ptep = huge_pte_offset(mm, addr);
+		if (!ptep)
+			goto out;
+		ptl = &mm->page_table_lock;
+	} else {
+		pgd = pgd_offset(mm, addr);
+		if (!pgd_present(*pgd))
+			goto out;
 
-	pud = pud_offset(pgd, addr);
-	if (!pud_present(*pud))
-		goto out;
+		pud = pud_offset(pgd, addr);
+		if (!pud_present(*pud))
+			goto out;
 
-	pmd = pmd_offset(pud, addr);
-	if (!pmd_present(*pmd))
-		goto out;
+		pmd = pmd_offset(pud, addr);
+		if (!pmd_present(*pmd))
+			goto out;
 
-	ptep = pte_offset_map(pmd, addr);
+		ptep = pte_offset_map(pmd, addr);
 
-	if (!is_swap_pte(*ptep)) {
-		pte_unmap(ptep);
-		goto out;
- 	}
+		if (!is_swap_pte(*ptep)) {
+			pte_unmap(ptep);
+			goto out;
+		}
+
+		ptl = pte_lockptr(mm, pmd);
+	}
 
- 	ptl = pte_lockptr(mm, pmd);
  	spin_lock(ptl);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
@@ -130,10 +139,17 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
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
@@ -276,11 +292,59 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 }
 
 /*
+ * The expected number of remaining references is the same as that
+ * of migrate_page_move_mapping().
+ */
+int migrate_huge_page_move_mapping(struct address_space *mapping,
+				   struct page *newpage, struct page *page)
+{
+	int expected_count;
+	void **pslot;
+
+	if (!mapping) {
+		if (page_count(page) != 1)
+			return -EAGAIN;
+		return 0;
+	}
+
+	spin_lock_irq(&mapping->tree_lock);
+
+	pslot = radix_tree_lookup_slot(&mapping->page_tree,
+					page_index(page));
+
+	expected_count = 2 + page_has_private(page);
+	if (page_count(page) != expected_count ||
+	    (struct page *)radix_tree_deref_slot(pslot) != page) {
+		spin_unlock_irq(&mapping->tree_lock);
+		return -EAGAIN;
+	}
+
+	if (!page_freeze_refs(page, expected_count)) {
+		spin_unlock_irq(&mapping->tree_lock);
+		return -EAGAIN;
+	}
+
+	get_page(newpage);
+
+	radix_tree_replace_slot(pslot, newpage);
+
+	page_unfreeze_refs(page, expected_count);
+
+	__put_page(page);
+
+	spin_unlock_irq(&mapping->tree_lock);
+	return 0;
+}
+
+/*
  * Copy the page to its new location
  */
-static void migrate_page_copy(struct page *newpage, struct page *page)
+void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	copy_highpage(newpage, page);
+	if (PageHuge(page))
+		copy_huge_page(newpage, page);
+	else
+		copy_highpage(newpage, page);
 
 	if (PageError(page))
 		SetPageError(newpage);
@@ -728,6 +792,86 @@ move_newpage:
 }
 
 /*
+ * Counterpart of unmap_and_move_page() for hugepage migration.
+ *
+ * This function doesn't wait the completion of hugepage I/O
+ * because there is no race between I/O and migration for hugepage.
+ * Note that currently hugepage I/O occurs only in direct I/O
+ * where no lock is held and PG_writeback is irrelevant,
+ * and writeback status of all subpages are counted in the reference
+ * count of the head page (i.e. if all subpages of a 2MB hugepage are
+ * under direct I/O, the reference of the head page is 512 and a bit more.)
+ * This means that when we try to migrate hugepage whose subpages are
+ * doing direct I/O, some references remain after try_to_unmap() and
+ * hugepage migration fails without data corruption.
+ */
+static int unmap_and_move_huge_page(new_page_t get_new_page,
+				unsigned long private, struct page *hpage,
+				int force, int offlining)
+{
+	int rc = 0;
+	int *result = NULL;
+	struct page *new_hpage = get_new_page(hpage, private, &result);
+	int rcu_locked = 0;
+	struct anon_vma *anon_vma = NULL;
+
+	if (!new_hpage)
+		return -ENOMEM;
+
+	rc = -EAGAIN;
+
+	if (!trylock_page(hpage)) {
+		if (!force)
+			goto out;
+		lock_page(hpage);
+	}
+
+	if (PageAnon(hpage)) {
+		rcu_read_lock();
+		rcu_locked = 1;
+
+		if (page_mapped(hpage)) {
+			anon_vma = page_anon_vma(hpage);
+			atomic_inc(&anon_vma->external_refcount);
+		}
+	}
+
+	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+
+	if (!page_mapped(hpage))
+		rc = move_to_new_page(new_hpage, hpage, 1);
+
+	if (rc)
+		remove_migration_ptes(hpage, hpage);
+
+	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount,
+					    &anon_vma->lock)) {
+		int empty = list_empty(&anon_vma->head);
+		spin_unlock(&anon_vma->lock);
+		if (empty)
+			anon_vma_free(anon_vma);
+	}
+
+	if (rcu_locked)
+		rcu_read_unlock();
+out:
+	unlock_page(hpage);
+
+	if (rc != -EAGAIN)
+		put_page(hpage);
+
+	put_page(new_hpage);
+
+	if (result) {
+		if (rc)
+			*result = rc;
+		else
+			*result = page_to_nid(new_hpage);
+	}
+	return rc;
+}
+
+/*
  * migrate_pages
  *
  * The function takes one list of pages to migrate and a function
@@ -751,6 +895,7 @@ int migrate_pages(struct list_head *from,
 	struct page *page2;
 	int swapwrite = current->flags & PF_SWAPWRITE;
 	int rc;
+	int putback_lru = 1;
 
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
@@ -761,7 +906,17 @@ int migrate_pages(struct list_head *from,
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
 
-			rc = unmap_and_move(get_new_page, private,
+			/*
+			 * Hugepage should be handled differently from
+			 * non-hugepage because it's not linked to LRU list
+			 * and reference counting policy is different.
+			 */
+			if (PageHuge(page)) {
+				rc = unmap_and_move_huge_page(get_new_page,
+					private, page, pass > 2, offlining);
+				putback_lru = 0;
+			} else
+				rc = unmap_and_move(get_new_page, private,
 						page, pass > 2, offlining);
 
 			switch(rc) {
@@ -784,7 +939,8 @@ out:
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
-	putback_lru_pages(from);
+	if (putback_lru)
+		putback_lru_pages(from);
 
 	if (rc)
 		return rc;
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
