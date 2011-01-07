Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 12A976B00BE
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 13:22:54 -0500 (EST)
Subject: [PATCH] mm: add replace_page_cache_page() function
Message-Id: <E1PbGxV-0001ug-2r@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 07 Jan 2011 19:22:41 +0100
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here's an updated patch, addressing the review comments.

Hiroyuki-san, can you please review the newly introduced
mem_cgroup_replace_cache_page(), as I'm not fully familiar with the
memory cgroup code.

Thanks,
Miklos
---

From: Miklos Szeredi <mszeredi@suse.cz>
Subject: mm: add replace_page_cache_page() function

This function basically does:

     remove_from_page_cache(old);
     page_cache_release(old);
     add_to_page_cache_locked(new);

Except it does this atomically, so there's no possibility for the
"add" to fail because of a race.

This is used by fuse to move pages into the page cache.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dev.c              |   10 +++------
 include/linux/memcontrol.h |    8 +++++++
 include/linux/pagemap.h    |    1 
 mm/filemap.c               |   50 +++++++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c            |   38 ++++++++++++++++++++++++++++++++++
 5 files changed, 101 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2011-01-07 17:53:39.000000000 +0100
+++ linux-2.6/mm/filemap.c	2011-01-07 19:14:45.000000000 +0100
@@ -390,6 +390,56 @@ int filemap_write_and_wait_range(struct
 EXPORT_SYMBOL(filemap_write_and_wait_range);
 
 /**
+ * replace_page_cache_page - replace a pagecache page with a new one
+ * @old:	page to be replaced
+ * @new:	page to replace with
+ * @gfp_mask:	page allocation mode
+ *
+ * This function replaces a page in the pagecache with a new one.  On
+ * success it acquires the pagecache reference for the new page and
+ * drop it for the old page.  Both the old and new pages must be
+ * locked.  This function does not add the new page to the LRU, the
+ * caller must do that.
+ *
+ * The remove + add is atomic.  The only way this function can fail is
+ * memory allocation failure.
+ */
+int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
+{
+	int error;
+
+	VM_BUG_ON(!PageLocked(old));
+	VM_BUG_ON(!PageLocked(new));
+	VM_BUG_ON(new->mapping);
+
+	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	if (!error) {
+		struct address_space *mapping = old->mapping;
+		pgoff_t offset = old->index;
+
+		page_cache_get(new);
+		new->mapping = mapping;
+		new->index = offset;
+
+		spin_lock_irq(&mapping->tree_lock);
+		__remove_from_page_cache(old);
+		error = radix_tree_insert(&mapping->page_tree, offset, new);
+		BUG_ON(error);
+		mapping->nrpages++;
+		__inc_zone_page_state(new, NR_FILE_PAGES);
+		if (PageSwapBacked(new))
+			__inc_zone_page_state(new, NR_SHMEM);
+		spin_unlock_irq(&mapping->tree_lock);
+		radix_tree_preload_end();
+		mem_cgroup_replace_cache_page(old, new);
+		page_cache_release(old);
+	}
+
+	return error;
+}
+EXPORT_SYMBOL_GPL(replace_page_cache_page);
+
+/**
  * add_to_page_cache_locked - add a locked page to the pagecache
  * @page:	page to add
  * @mapping:	the page's address_space
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2011-01-07 17:53:39.000000000 +0100
+++ linux-2.6/include/linux/pagemap.h	2011-01-07 19:14:45.000000000 +0100
@@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *p
 				pgoff_t index, gfp_t gfp_mask);
 extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
+int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2011-01-07 17:53:39.000000000 +0100
+++ linux-2.6/fs/fuse/dev.c	2011-01-07 19:14:45.000000000 +0100
@@ -737,14 +737,12 @@ static int fuse_try_move_page(struct fus
 	if (WARN_ON(PageMlocked(oldpage)))
 		goto out_fallback_unlock;
 
-	remove_from_page_cache(oldpage);
-	page_cache_release(oldpage);
-
-	err = add_to_page_cache_locked(newpage, mapping, index, GFP_KERNEL);
+	err = replace_page_cache_page(oldpage, newpage, GFP_KERNEL);
 	if (err) {
-		printk(KERN_WARNING "fuse_try_move_page: failed to add page");
-		goto out_fallback_unlock;
+		unlock_page(newpage);
+		return err;
 	}
+
 	page_cache_get(newpage);
 
 	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
Index: linux-2.6/include/linux/memcontrol.h
===================================================================
--- linux-2.6.orig/include/linux/memcontrol.h	2011-01-07 17:53:39.000000000 +0100
+++ linux-2.6/include/linux/memcontrol.h	2011-01-07 19:14:45.000000000 +0100
@@ -95,6 +95,9 @@ mem_cgroup_prepare_migration(struct page
 extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 	struct page *oldpage, struct page *newpage);
 
+extern void mem_cgroup_replace_cache_page(struct page *oldpage,
+					  struct page *newpage);
+
 /*
  * For memory reclaim.
  */
@@ -236,6 +239,11 @@ static inline void mem_cgroup_end_migrat
 {
 }
 
+static inline void mem_cgroup_replace_cache_page(struct page *oldpage,
+					 	struct page *newpage)
+{
+}
+
 static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
 {
 	return 0;
Index: linux-2.6/mm/memcontrol.c
===================================================================
--- linux-2.6.orig/mm/memcontrol.c	2011-01-07 17:53:39.000000000 +0100
+++ linux-2.6/mm/memcontrol.c	2011-01-07 19:20:41.000000000 +0100
@@ -2905,6 +2905,44 @@ void mem_cgroup_end_migration(struct mem
 }
 
 /*
+ * This function moves the charge from oldpage to newpage.  The new
+ * page must not be already charged.
+ */
+void mem_cgroup_replace_cache_page(struct page *oldpage, struct page *newpage)
+{
+	struct page_cgroup *old_pc;
+	struct page_cgroup *new_pc;
+	struct mem_cgroup *mem;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	old_pc = lookup_page_cgroup(oldpage);
+	lock_page_cgroup(old_pc);
+	if (!PageCgroupUsed(old_pc)) {
+		unlock_page_cgroup(old_pc);
+		return;
+	}
+
+	mem = old_pc->mem_cgroup;
+	css_get(&mem->css);
+	ClearPageCgroupUsed(old_pc);
+	unlock_page_cgroup(old_pc);
+
+	new_pc = lookup_page_cgroup(newpage);
+	lock_page_cgroup(new_pc);
+	BUG_ON(PageCgroupUsed(new_pc));
+
+	new_pc->mem_cgroup = mem;
+	smp_wmb();
+	SetPageCgroupCache(new_pc);
+	SetPageCgroupUsed(new_pc);
+	unlock_page_cgroup(new_pc);
+	css_put(&mem->css);
+}
+
+
+/*
  * A call to try to shrink memory usage on charge failure at shmem's swapin.
  * Calling hierarchical_reclaim is not enough because we should update
  * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
