From: linux-kernel@vger.kernel.org
Subject: [patch 04/19] debugging checks for page_file_cache()
Date: Wed, 02 Jan 2008 17:41:48 -0500
Message-ID: <20080102224154.006301705@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758698AbYABXXb@vger.kernel.org>
Content-Disposition: inline; filename=rvr-page_file_cache-debug.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

Debug whether we end up classifying the wrong pages as
filesystem backed.  This has not triggered in stress
tests on my system, but who knows...

DEBUGGING ONLY: NOT FOR UPSTREAM MERGE

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc6-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mm_inline.h	2008-01-02 12:37:22.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mm_inline.h	2008-01-02 12:37:27.000000000 -0500
@@ -1,6 +1,8 @@
 #ifndef LINUX_MM_INLINE_H
 #define LINUX_MM_INLINE_H
 
+#include <linux/fs.h>  /* for struct address_space */
+
 /**
  * page_file_cache(@page)
  * Returns !0 if @page is page cache page backed by a regular filesystem,
@@ -10,11 +12,19 @@
  * needs to survive until the page is last deleted from the LRU, which
  * could be as far down as __page_cache_release.
  */
+extern const struct address_space_operations shmem_aops;
 static inline int page_file_cache(struct page *page)
 {
+	struct address_space * mapping = page_mapping(page);
+
 	if (PageSwapBacked(page))
 		return 0;
 
+	/* These pages should all be marked PG_swapbacked */
+	WARN_ON(PageAnon(page));
+	WARN_ON(PageSwapCache(page));
+	WARN_ON(mapping && mapping->a_ops && mapping->a_ops == &shmem_aops);
+
 	/* The page is page cache backed by a normal filesystem. */
 	return 2;
 }
Index: linux-2.6.24-rc6-mm1/mm/shmem.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/shmem.c	2008-01-02 12:37:22.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/shmem.c	2008-01-02 12:37:27.000000000 -0500
@@ -179,7 +179,7 @@ static inline void shmem_unacct_blocks(u
 }
 
 static const struct super_operations shmem_ops;
-static const struct address_space_operations shmem_aops;
+const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
@@ -2344,7 +2344,7 @@ static void destroy_inodecache(void)
 	kmem_cache_destroy(shmem_inode_cachep);
 }
 
-static const struct address_space_operations shmem_aops = {
+const struct address_space_operations shmem_aops = {
 	.writepage	= shmem_writepage,
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS

-- 
All Rights Reversed

