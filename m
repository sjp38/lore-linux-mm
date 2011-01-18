Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1BB8D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 06:18:31 -0500 (EST)
Subject: [PATCH v4] mm: add replace_page_cache_page() function
Message-Id: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Jan 2011 12:18:11 +0100
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew,

Can you please apply this to -mm, for 2.6.39?

v4:
- updated to latest -git
- added acks
- updated changelog

Thanks,
Miklos
----

From: Miklos Szeredi <mszeredi@suse.cz>
Subject: mm: add replace_page_cache_page() function

This function basically does:

     remove_from_page_cache(old);
     page_cache_release(old);
     add_to_page_cache_locked(new);

Except it does this atomically, so there's no possibility for the
"add" to fail because of a race.

If memory cgroups are enabled, then the memory cgroup charge is also
moved from the old page to the new.

This function is currently used by fuse to move pages into the page
cache on read, instead of copying the page contents.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/fuse/dev.c              |   10 ++----
 include/linux/memcontrol.h |    4 +-
 include/linux/pagemap.h    |    1 
 mm/filemap.c               |   65 +++++++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c            |    4 +-
 mm/migrate.c               |    2 -
 6 files changed, 75 insertions(+), 11 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2011-01-17 09:33:44.000000000 +0100
+++ linux-2.6/mm/filemap.c	2011-01-18 11:50:08.000000000 +0100
@@ -387,6 +387,71 @@ int filemap_write_and_wait_range(struct
 EXPORT_SYMBOL(filemap_write_and_wait_range);
 
 /**
+ * replace_page_cache_page - replace a pagecache page with a new one
+ * @old:	page to be replaced
+ * @new:	page to replace with
+ * @gfp_mask:	allocation mode
+ *
+ * This function replaces a page in the pagecache with a new one.  On
+ * success it acquires the pagecache reference for the new page and
+ * drops it for the old page.  Both the old and new pages must be
+ * locked.  This function does not add the new page to the LRU, the
+ * caller must do that.
+ *
+ * The remove + add is atomic.  The only way this function can fail is
+ * memory allocation failure.
+ */
+int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
+{
+	int error;
+	struct mem_cgroup *memcg = NULL;
+
+	VM_BUG_ON(!PageLocked(old));
+	VM_BUG_ON(!PageLocked(new));
+	VM_BUG_ON(new->mapping);
+
+	/*
+	 * This is not page migration, but prepare_migration and
+	 * end_migration does enough work for charge replacement.
+	 *
+	 * In the longer term we probably want a specialized function
+	 * for moving the charge from old to new in a more efficient
+	 * manner.
+	 */
+	error = mem_cgroup_prepare_migration(old, new, &memcg, gfp_mask);
+	if (error)
+		return error;
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
+		page_cache_release(old);
+		mem_cgroup_end_migration(memcg, old, new, true);
+	} else {
+		mem_cgroup_end_migration(memcg, old, new, false);
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
--- linux-2.6.orig/include/linux/pagemap.h	2011-01-17 09:33:44.000000000 +0100
+++ linux-2.6/include/linux/pagemap.h	2011-01-18 11:50:08.000000000 +0100
@@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *p
 				pgoff_t index, gfp_t gfp_mask);
 extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
+int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2011-01-13 14:34:28.000000000 +0100
+++ linux-2.6/fs/fuse/dev.c	2011-01-18 11:50:08.000000000 +0100
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
--- linux-2.6.orig/include/linux/memcontrol.h	2011-01-17 09:33:44.000000000 +0100
+++ linux-2.6/include/linux/memcontrol.h	2011-01-18 11:50:08.000000000 +0100
@@ -96,7 +96,7 @@ extern struct cgroup_subsys_state *mem_c
 
 extern int
 mem_cgroup_prepare_migration(struct page *page,
-	struct page *newpage, struct mem_cgroup **ptr);
+	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask);
 extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 	struct page *oldpage, struct page *newpage, bool migration_ok);
 
@@ -245,7 +245,7 @@ static inline struct cgroup_subsys_state
 
 static inline int
 mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
-	struct mem_cgroup **ptr)
+	struct mem_cgroup **ptr, gfp_t gfp_mask)
 {
 	return 0;
 }
Index: linux-2.6/mm/memcontrol.c
===================================================================
--- linux-2.6.orig/mm/memcontrol.c	2011-01-17 09:33:44.000000000 +0100
+++ linux-2.6/mm/memcontrol.c	2011-01-18 11:50:08.000000000 +0100
@@ -2806,7 +2806,7 @@ static inline int mem_cgroup_move_swap_a
  * page belongs to.
  */
 int mem_cgroup_prepare_migration(struct page *page,
-	struct page *newpage, struct mem_cgroup **ptr)
+	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
@@ -2863,7 +2863,7 @@ int mem_cgroup_prepare_migration(struct
 		return 0;
 
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false, PAGE_SIZE);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, ptr, false, PAGE_SIZE);
 	css_put(&mem->css);/* drop extra refcnt */
 	if (ret || *ptr == NULL) {
 		if (PageAnon(page)) {
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2011-01-17 09:33:44.000000000 +0100
+++ linux-2.6/mm/migrate.c	2011-01-18 11:50:08.000000000 +0100
@@ -678,7 +678,7 @@ static int unmap_and_move(new_page_t get
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
+	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;
 		goto unlock;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
