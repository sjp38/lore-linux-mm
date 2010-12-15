Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 62ED06B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 10:50:13 -0500 (EST)
Subject: [PATCH] mm: add replace_page_cache_page() function
Message-Id: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 15 Dec 2010 16:49:58 +0100
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Miklos Szeredi <mszeredi@suse.cz>

This function basically does:

     remove_from_page_cache(old);
     page_cache_release(old);
     add_to_page_cache_locked(new);

Except it does this atomically, so there's no possibility for the
"add" to fail because of a race.

This is used by fuse to move pages into the page cache.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dev.c           |   10 ++++------
 include/linux/pagemap.h |    1 +
 mm/filemap.c            |   41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2010-12-15 16:39:55.000000000 +0100
+++ linux-2.6/mm/filemap.c	2010-12-15 16:41:24.000000000 +0100
@@ -389,6 +389,47 @@ int filemap_write_and_wait_range(struct
 }
 EXPORT_SYMBOL(filemap_write_and_wait_range);
 
+int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
+{
+	int error;
+
+	VM_BUG_ON(!PageLocked(old));
+	VM_BUG_ON(!PageLocked(new));
+	VM_BUG_ON(new->mapping);
+
+	error = mem_cgroup_cache_charge(new, current->mm,
+					gfp_mask & GFP_RECLAIM_MASK);
+	if (error)
+		goto out;
+
+	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	if (error == 0) {
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
+		mem_cgroup_uncharge_cache_page(old);
+		page_cache_release(old);
+	} else
+		mem_cgroup_uncharge_cache_page(new);
+out:
+	return error;
+}
+EXPORT_SYMBOL_GPL(replace_page_cache_page);
+
 /**
  * add_to_page_cache_locked - add a locked page to the pagecache
  * @page:	page to add
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2010-12-15 16:39:39.000000000 +0100
+++ linux-2.6/include/linux/pagemap.h	2010-12-15 16:41:24.000000000 +0100
@@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *p
 				pgoff_t index, gfp_t gfp_mask);
 extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
+int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2010-12-15 16:39:39.000000000 +0100
+++ linux-2.6/fs/fuse/dev.c	2010-12-15 16:41:24.000000000 +0100
@@ -729,14 +729,12 @@ static int fuse_try_move_page(struct fus
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
