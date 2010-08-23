Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 786826B03C9
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 12:20:44 -0400 (EDT)
Received: by pxi5 with SMTP id 5so2671256pxi.14
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 09:20:42 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] compaction: fix COMPACTPAGEFAILED counting
Date: Tue, 24 Aug 2010 01:15:14 +0900
Message-Id: <1282580114-2136-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>
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

This patch introude new argument 'cleanup' to migrate_pages.
Only if we set 1 to 'cleanup', migrate_page will clean up the lists.
Otherwise, caller need to clean up the lists so it has a chance to postprocess
the pages.

Cc: Hugh Dickins <hughd@google.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/migrate.h |    7 +++++--
 mm/compaction.c         |    2 +-
 mm/memory-failure.c     |    2 +-
 mm/memory_hotplug.c     |    2 +-
 mm/mempolicy.c          |    4 ++--
 mm/migrate.c            |   12 ++++++++----
 6 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 7238231..babdaa2 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -13,7 +13,7 @@ extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
-			unsigned long private, int offlining);
+			unsigned long private, int offlining, int cleanup);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -28,7 +28,10 @@ extern int migrate_vmas(struct mm_struct *mm,
 
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
-		unsigned long private, int offlining) { return -ENOSYS; }
+		unsigned long private, int offlining, int cleanup)
+{
+	return -ENOSYS;
+}
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
diff --git a/mm/compaction.c b/mm/compaction.c
index 4d709ee..aef77d8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -394,7 +394,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		nr_migrate = cc->nr_migratepages;
 		migrate_pages(&cc->migratepages, compaction_alloc,
-						(unsigned long)cc, 0);
+						(unsigned long)cc, 0, 0);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9c26eec..737b51b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1337,7 +1337,7 @@ int soft_offline_page(struct page *page, int flags)
 		LIST_HEAD(pagelist);
 
 		list_add(&page->lru, &pagelist);
-		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0);
+		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0, 1);
 		if (ret) {
 			pr_debug("soft offline: %#lx: migration failed %d, type %lx\n",
 				pfn, ret, page->flags);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a4cfcdc..b9b0d2a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -730,7 +730,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 	if (list_empty(&source))
 		goto out;
 	/* this function returns # of failed pages */
-	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
+	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1, 1);
 
 out:
 	return ret;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f969da5..7f57098 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -932,7 +932,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist))
-		err = migrate_pages(&pagelist, new_node_page, dest, 0);
+		err = migrate_pages(&pagelist, new_node_page, dest, 0, 1);
 
 	return err;
 }
@@ -1149,7 +1149,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 		if (!list_empty(&pagelist))
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
-						(unsigned long)vma, 0);
+						(unsigned long)vma, 0, 1);
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
diff --git a/mm/migrate.c b/mm/migrate.c
index 38e7cad..9788435 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -735,10 +735,13 @@ move_newpage:
  * or no retryable pages exist anymore. All pages will be
  * returned to the LRU or freed.
  *
+ * If you set cleanup to 1, The function don't leave pages on the
+ * lists passed. Otherwise, caller have to clean up the lists.
+ *
  * Return: Number of pages not migrated or error code.
  */
-int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private, int offlining)
+int migrate_pages(struct list_head *from, new_page_t get_new_page,
+		unsigned long private, int offlining, int cleanup)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -780,7 +783,8 @@ out:
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
-	putback_lru_pages(from);
+	if (cleanup)
+		putback_lru_pages(from);
 
 	if (rc)
 		return rc;
@@ -892,7 +896,7 @@ set_status:
 	err = 0;
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm, 0);
+				(unsigned long)pm, 0, 1);
 
 	up_read(&mm->mmap_sem);
 	return err;
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
