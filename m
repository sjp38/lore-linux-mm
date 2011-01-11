Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEE06B00E8
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 09:08:15 -0500 (EST)
Subject: [PATCH v3] mm: add replace_page_cache_page() function
Message-Id: <E1Pcet8-0007kg-3R@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 11 Jan 2011 15:07:54 +0100
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

(resent with fixed CC list, sorry for the duplicate)

Thanks for the review.

Here's an updated patch.  Modifications since the last post:

 - don't pass gfp_mask (since it's only able to deal with GFP_KERNEL
   anyway)

 - use mem_cgroup_prepare_migration() and mem_cgroup_end_migration()
   instead of intrdoucing mem_cgroup_replace_cache_page() helper.
   This can be done later if the performance impact of using the
   migration functions turns out to be excessive.

Applies on top of memcg-fix-memory-migration-of-shmem-swapcache.patch

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
 fs/fuse/dev.c           |   10 +++----
 include/linux/pagemap.h |    1 
 mm/filemap.c            |   64 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2011-01-11 14:38:12.000000000 +0100
+++ linux-2.6/mm/filemap.c	2011-01-11 14:38:17.000000000 +0100
@@ -387,6 +387,70 @@ int filemap_write_and_wait_range(struct
 EXPORT_SYMBOL(filemap_write_and_wait_range);
 
 /**
+ * replace_page_cache_page - replace a pagecache page with a new one
+ * @old:	page to be replaced
+ * @new:	page to replace with
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
+int replace_page_cache_page(struct page *old, struct page *new)
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
+	error = mem_cgroup_prepare_migration(old, new, &memcg);
+	if (error)
+		return error;
+
+	error = radix_tree_preload(GFP_KERNEL);
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
--- linux-2.6.orig/include/linux/pagemap.h	2011-01-11 14:38:12.000000000 +0100
+++ linux-2.6/include/linux/pagemap.h	2011-01-11 14:38:17.000000000 +0100
@@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *p
 				pgoff_t index, gfp_t gfp_mask);
 extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
+int replace_page_cache_page(struct page *old, struct page *new);
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2011-01-11 14:38:12.000000000 +0100
+++ linux-2.6/fs/fuse/dev.c	2011-01-11 14:38:17.000000000 +0100
@@ -737,14 +737,12 @@ static int fuse_try_move_page(struct fus
 	if (WARN_ON(PageMlocked(oldpage)))
 		goto out_fallback_unlock;
 
-	remove_from_page_cache(oldpage);
-	page_cache_release(oldpage);
-
-	err = add_to_page_cache_locked(newpage, mapping, index, GFP_KERNEL);
+	err = replace_page_cache_page(oldpage, newpage);
 	if (err) {
-		printk(KERN_WARNING "fuse_try_move_page: failed to add page");
-		goto out_fallback_unlock;
+		unlock_page(newpage);
+		return err;
 	}
+
 	page_cache_get(newpage);
 
 	if (!(buf->flags & PIPE_BUF_FLAG_LRU))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
