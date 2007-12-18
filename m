Message-Id: <20071218211549.179361388@redhat.com>
References: <20071218211539.250334036@redhat.com>
Date: Tue, 18 Dec 2007 16:15:45 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 06/20] debugging checks for page_file_cache()
Content-Disposition: inline; filename=rvr-page_file_cache-debug.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Debug whether we end up classifying the wrong pages as
filesystem backed.  This has not triggered in stress
tests on my system, but who knows...

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc3-mm2/include/linux/mm_inline.h
===================================================================
--- linux-2.6.24-rc3-mm2.orig/include/linux/mm_inline.h
+++ linux-2.6.24-rc3-mm2/include/linux/mm_inline.h
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
Index: linux-2.6.24-rc3-mm2/mm/shmem.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/shmem.c
+++ linux-2.6.24-rc3-mm2/mm/shmem.c
@@ -178,7 +178,7 @@ static inline void shmem_unacct_blocks(u
 }
 
 static const struct super_operations shmem_ops;
-static const struct address_space_operations shmem_aops;
+const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
@@ -2232,7 +2232,7 @@ static void destroy_inodecache(void)
 	kmem_cache_destroy(shmem_inode_cachep);
 }
 
-static const struct address_space_operations shmem_aops = {
+const struct address_space_operations shmem_aops = {
 	.writepage	= shmem_writepage,
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
