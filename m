Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9031A6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:43:33 -0400 (EDT)
Received: by pxi5 with SMTP id 5so816047pxi.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 08:43:31 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2] compaction: fix COMPACTPAGEFAILED counting
Date: Fri, 27 Aug 2010 00:43:00 +0900
Message-Id: <1282837380-6799-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Now update_nr_listpages doesn't have a role. That's because
lists passed is always empty just after calling migrate_pages.
The migrate_pages cleans up page list which have failed to migrate
before returning by aaa994b3.

 [PATCH] page migration: handle freeing of pages in migrate_pages()

 Do not leave pages on the lists passed to migrate_pages().  Seems that we will
 not need any postprocessing of pages.  This will simplify the handling of
 pages by the callers of migrate_pages().

At that time, we thought we don't need any postprocessing of pages.
But the situation is changed. The compaction need to know the number of
failed to migrate for COMPACTPAGEFAILED stat

This patch makes new rule for caller of migrate_pages to call putback_lru_pages.
So caller need to clean up the lists so it has a chance to postprocess the pages.
[suggested by Christoph Lameter]

Cc: Hugh Dickins <hughd@google.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memory-failure.c |    1 +
 mm/memory_hotplug.c |    2 ++
 mm/mempolicy.c      |   10 ++++++++--
 mm/migrate.c        |   12 +++++++-----
 4 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9c26eec..5267861 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1339,6 +1339,7 @@ int soft_offline_page(struct page *page, int flags)
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0);
 		if (ret) {
+			putback_lru_pages(&pagelist);
 			pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
 				pfn, ret, page->flags);
 			if (ret > 0)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a4cfcdc..2638079 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -731,6 +731,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		goto out;
 	/* this function returns # of failed pages */
 	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
+	if (ret)
+		putback_lru_pages(&source);
 
 out:
 	return ret;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f969da5..21243b2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -931,8 +931,11 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
-	if (!list_empty(&pagelist))
+	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_node_page, dest, 0);
+		if (err)
+			putback_lru_pages(&pagelist);
+	}
 
 	return err;
 }
@@ -1147,9 +1150,12 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 		err = mbind_range(mm, start, end, new);
 
-		if (!list_empty(&pagelist))
+		if (!list_empty(&pagelist)) {
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
 						(unsigned long)vma, 0);
+			if (nr_failed)
+				putback_lru_pages(&pagelist);
+		}
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
diff --git a/mm/migrate.c b/mm/migrate.c
index 38e7cad..ed38c22 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -732,8 +732,9 @@ move_newpage:
  *
  * The function returns after 10 attempts or if no pages
  * are movable anymore because to has become empty
- * or no retryable pages exist anymore. All pages will be
- * returned to the LRU or freed.
+ * or no retryable pages exist anymore.
+ * Caller should call putback_lru_pages to return pages to the LRU
+ * or free list.
  *
  * Return: Number of pages not migrated or error code.
  */
@@ -780,8 +781,6 @@ out:
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
-	putback_lru_pages(from);
-
 	if (rc)
 		return rc;
 
@@ -890,9 +889,12 @@ set_status:
 	}
 
 	err = 0;
-	if (!list_empty(&pagelist))
+	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm, 0);
+		if (err)
+			putback_lru_pages(&pagelist);
+	}
 
 	up_read(&mm->mmap_sem);
 	return err;
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
