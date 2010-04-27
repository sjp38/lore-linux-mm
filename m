Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E96626B01E3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 17:30:57 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when page tables are being moved after the VMA has already moved
Date: Tue, 27 Apr 2010 22:30:52 +0100
Message-Id: <1272403852-10479-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

During exec(), a temporary stack is setup and moved later to its final
location. There is a race between migration and exec whereby a migration
PTE can be placed in the temporary stack. When this VMA is moved under the
lock, migration no longer knows where the PTE is, fails to remove the PTE
and the migration PTE gets copied to the new location.  This later causes
a bug when the migration PTE is discovered but the page is not locked.

This patch handles the situation by removing the migration PTE when page
tables are being moved in case migration fails to find them. The alternative
would require significant modification to vma_adjust() and the locks taken
to ensure a VMA move and page table copy is atomic with respect to migration.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/migrate.h |    7 +++++++
 mm/migrate.c            |    2 +-
 mm/mremap.c             |   29 +++++++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 7a07b17..05d2292 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -22,6 +22,8 @@ extern int migrate_prep(void);
 extern int migrate_vmas(struct mm_struct *mm,
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
+extern int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
+			unsigned long addr, void *old);
 #else
 #define PAGE_MIGRATION 0
 
@@ -42,5 +44,10 @@ static inline int migrate_vmas(struct mm_struct *mm,
 #define migrate_page NULL
 #define fail_migrate_page NULL
 
+static inline int remove_migration_pte(struct page *new,
+		struct vm_area_struct *vma, unsigned long addr, void *old)
+{
+}
+
 #endif /* CONFIG_MIGRATION */
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 4afd6fe..053fd39 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -75,7 +75,7 @@ void putback_lru_pages(struct list_head *l)
 /*
  * Restore a potential migration pte to a working pte entry
  */
-static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
+int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 				 unsigned long addr, void *old)
 {
 	struct mm_struct *mm = vma->vm_mm;
diff --git a/mm/mremap.c b/mm/mremap.c
index cde56ee..601bba0 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -13,12 +13,14 @@
 #include <linux/ksm.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
+#include <linux/swapops.h>
 #include <linux/capability.h>
 #include <linux/fs.h>
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
+#include <linux/migrate.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -78,10 +80,13 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
 	unsigned long old_start;
+	swp_entry_t entry;
+	struct page *page;
 
 	old_start = old_addr;
 	mmu_notifier_invalidate_range_start(vma->vm_mm,
 					    old_start, old_end);
+restart:
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -111,6 +116,12 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 				   new_pte++, new_addr += PAGE_SIZE) {
 		if (pte_none(*old_pte))
 			continue;
+		if (unlikely(!pte_present(*old_pte))) {
+			entry = pte_to_swp_entry(*old_pte);
+			if (is_migration_entry(entry))
+				break;
+		}
+
 		pte = ptep_clear_flush(vma, old_addr, old_pte);
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		set_pte_at(mm, new_addr, new_pte, pte);
@@ -123,6 +134,24 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
+
+	/*
+	 * In this context, we cannot call migration_entry_wait() as we
+	 * are racing with migration. If migration finishes between when
+	 * PageLocked was checked and migration_entry_wait takes the
+	 * locks, it'll BUG. Instead, lock the page and remove the PTE
+	 * before restarting.
+	 */
+	if (old_addr != old_end) {
+		page = pfn_to_page(swp_offset(entry));
+		get_page(page);
+		lock_page(page);
+		remove_migration_pte(page, vma, old_addr, page);
+		unlock_page(page);
+		put_page(page);
+		goto restart;
+	}
+
 	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
