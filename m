Date: Sat, 3 Nov 2007 18:55:37 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 4/10] debug page_file_cache
Message-ID: <20071103185537.20c42f7a@bree.surriel.com>
In-Reply-To: <20071103184229.3f20e2f0@bree.surriel.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Debug whether we end up classifying the wrong pages as
filesystem backed.  This has not triggered in stress
tests on my system, but who knows...

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.23-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/mm_inline.h
+++ linux-2.6.23-mm1/include/linux/mm_inline.h
@@ -1,6 +1,8 @@
 #ifndef LINUX_MM_INLINE_H
 #define LINUX_MM_INLINE_H
 
+#include <linux/fs.h>  /* for struct address_space */
+
 /**
  * page_file_cache(@page)
  * Returns !0 if @page is page cache page backed by a regular file,
@@ -9,11 +11,19 @@
  * We would like to get this info without a page flag, but the state
  * needs to propagate to whereever the page is last deleted from the LRU.
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
Index: linux-2.6.23-mm1/mm/shmem.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/shmem.c
+++ linux-2.6.23-mm1/mm/shmem.c
@@ -180,7 +180,7 @@ static inline void shmem_unacct_blocks(u
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
