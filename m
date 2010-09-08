Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A630F6B007B
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 21:28:58 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 04/10] hugetlb: hugepage migration core
Date: Wed,  8 Sep 2010 10:19:35 +0900
Message-Id: <1283908781-13810-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch extends page migration code to support hugepage migration.
One of the potential users of this feature is soft offlining which
is triggered by memory corrected errors (added by the next patch.)

Todo:
- there are other users of page migration such as memory policy,
  memory hotplug and memocy compaction.
  They are not ready for hugepage support for now.

ChangeLog since v4:
- define migrate_huge_pages()
- remove changes on isolation/putback_lru_page()

ChangeLog since v2:
- refactor isolate/putback_lru_page() to handle hugepage
- add comment about race on unmap_and_move_huge_page()

ChangeLog since v1:
- divide migration code path for hugepage
- define routine checking migration swap entry for hugetlb
- replace "goto" with "if/else" in remove_migration_pte()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 fs/hugetlbfs/inode.c    |   15 +++
 include/linux/migrate.h |   16 +++
 mm/hugetlb.c            |   18 ++++-
 mm/migrate.c            |  232 +++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 262 insertions(+), 19 deletions(-)

diff --git v2.6.36-rc2/fs/hugetlbfs/inode.c v2.6.36-rc2/fs/hugetlbfs/inode.c
index 6e5bd42..1f7ca50 100644
--- v2.6.36-rc2/fs/hugetlbfs/inode.c
+++ v2.6.36-rc2/fs/hugetlbfs/inode.c
@@ -31,6 +31,7 @@
 #include <linux/statfs.h>
 #include <linux/security.h>
 #include <linux/magic.h>
+#include <linux/migrate.h>
 
 #include <asm/uaccess.h>
 
@@ -573,6 +574,19 @@ static int hugetlbfs_set_page_dirty(struct page *page)
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
@@ -659,6 +673,7 @@ static const struct address_space_operations hugetlbfs_aops = {
 	.write_begin	= hugetlbfs_write_begin,
 	.write_end	= hugetlbfs_write_end,
 	.set_page_dirty	= hugetlbfs_set_page_dirty,
+	.migratepage    = hugetlbfs_migrate_page,
 };
 
 
diff --git v2.6.36-rc2/include/linux/migrate.h v2.6.36-rc2/include/linux/migrate.h
index 7238231..3c1941e 100644
--- v2.6.36-rc2/include/linux/migrate.h
+++ v2.6.36-rc2/include/linux/migrate.h
@@ -14,6 +14,8 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, int offlining);
+extern int migrate_huge_pages(struct list_head *l, new_page_t x,
+			unsigned long private, int offlining);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -23,12 +25,17 @@ extern int migrate_prep_local(void);
 extern int migrate_vmas(struct mm_struct *mm,
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
+extern void migrate_page_copy(struct page *newpage, struct page *page);
+extern int migrate_huge_page_move_mapping(struct address_space *mapping,
+				  struct page *newpage, struct page *page);
 #else
 #define PAGE_MIGRATION 0
 
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, int offlining) { return -ENOSYS; }
+static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
+		unsigned long private, int offlining) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
@@ -40,6 +47,15 @@ static inline int migrate_vmas(struct mm_struct *mm,
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
diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
index 351f8d1..55f3e2d 100644
--- v2.6.36-rc2/mm/hugetlb.c
+++ v2.6.36-rc2/mm/hugetlb.c
@@ -2217,6 +2217,19 @@ nomem:
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
@@ -2651,7 +2664,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
 
diff --git v2.6.36-rc2/mm/migrate.c v2.6.36-rc2/mm/migrate.c
index 38e7cad..55dbc45 100644
--- v2.6.36-rc2/mm/migrate.c
+++ v2.6.36-rc2/mm/migrate.c
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
@@ -724,6 +788,92 @@ move_newpage:
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
+ *
+ * There is also no race when direct I/O is issued on the page under migration,
+ * because then pte is replaced with migration swap entry and direct I/O code
+ * will wait in the page fault for migration to complete.
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
+	if (rc != -EAGAIN) {
+		list_del(&hpage->lru);
+		put_page(hpage);
+	}
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
@@ -788,6 +938,52 @@ out:
 	return nr_failed + retry;
 }
 
+int migrate_huge_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private, int offlining)
+{
+	int retry = 1;
+	int nr_failed = 0;
+	int pass = 0;
+	struct page *page;
+	struct page *page2;
+	int rc;
+
+	for (pass = 0; pass < 10 && retry; pass++) {
+		retry = 0;
+
+		list_for_each_entry_safe(page, page2, from, lru) {
+			cond_resched();
+
+			rc = unmap_and_move_huge_page(get_new_page,
+					private, page, pass > 2, offlining);
+
+			switch(rc) {
+			case -ENOMEM:
+				goto out;
+			case -EAGAIN:
+				retry++;
+				break;
+			case 0:
+				break;
+			default:
+				/* Permanent failure */
+				nr_failed++;
+				break;
+			}
+		}
+	}
+	rc = 0;
+out:
+
+	list_for_each_entry_safe(page, page2, from, lru)
+		put_page(page);
+
+	if (rc)
+		return rc;
+
+	return nr_failed + retry;
+}
+
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
