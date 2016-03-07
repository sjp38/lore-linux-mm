Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B66E9828E1
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 06:57:23 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj10so78137401pad.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 03:57:23 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id x12si2719063pfa.98.2016.03.07.03.57.22
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 03:57:22 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 3/4] mm: make remove_migration_ptes() beyond mm/migration.c
Date: Mon,  7 Mar 2016 14:57:17 +0300
Message-Id: <1457351838-114702-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch makes remove_migration_ptes() available to be used in
split_huge_page().

New parameter 'locked' added: as with try_to_umap() we need a way to
indicate that caller holds rmap lock.

We also shouldn't try to mlock() pte-mapped huge pages: pte-mapeed THP
pages are never mlocked.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  2 ++
 mm/migrate.c         | 15 +++++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 3d975e2252d4..49eb4f8ebac9 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -243,6 +243,8 @@ int page_mkclean(struct page *);
  */
 int try_to_munlock(struct page *);
 
+void remove_migration_ptes(struct page *old, struct page *new, bool locked);
+
 /*
  * Called by memory-failure.c to kill processes.
  */
diff --git a/mm/migrate.c b/mm/migrate.c
index 577c94b8e959..6c822a7b27e0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -172,7 +172,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	else
 		page_add_file_rmap(new);
 
-	if (vma->vm_flags & VM_LOCKED)
+	if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
 		mlock_vma_page(new);
 
 	/* No need to invalidate - it was non-present before */
@@ -187,14 +187,17 @@ out:
  * Get rid of all migration entries and replace them by
  * references to the indicated page.
  */
-static void remove_migration_ptes(struct page *old, struct page *new)
+void remove_migration_ptes(struct page *old, struct page *new, bool locked)
 {
 	struct rmap_walk_control rwc = {
 		.rmap_one = remove_migration_pte,
 		.arg = old,
 	};
 
-	rmap_walk(new, &rwc);
+	if (locked)
+		rmap_walk_locked(new, &rwc);
+	else
+		rmap_walk(new, &rwc);
 }
 
 /*
@@ -702,7 +705,7 @@ static int writeout(struct address_space *mapping, struct page *page)
 	 * At this point we know that the migration attempt cannot
 	 * be successful.
 	 */
-	remove_migration_ptes(page, page);
+	remove_migration_ptes(page, page, false);
 
 	rc = mapping->a_ops->writepage(page, &wbc);
 
@@ -900,7 +903,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 
 	if (page_was_mapped)
 		remove_migration_ptes(page,
-			rc == MIGRATEPAGE_SUCCESS ? newpage : page);
+			rc == MIGRATEPAGE_SUCCESS ? newpage : page, false);
 
 out_unlock_both:
 	unlock_page(newpage);
@@ -1070,7 +1073,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 
 	if (page_was_mapped)
 		remove_migration_ptes(hpage,
-			rc == MIGRATEPAGE_SUCCESS ? new_hpage : hpage);
+			rc == MIGRATEPAGE_SUCCESS ? new_hpage : hpage, false);
 
 	unlock_page(new_hpage);
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
