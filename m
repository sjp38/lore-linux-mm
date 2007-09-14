From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:25 -0400
Message-Id: <20070914205425.6536.69946.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon() function
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 03/14 Reclaim Scalability: Define page_anon() function
	to answer the question: is page backed by swap space?

Against:  2.6.23-rc4-mm1

Originally part of Rik van Riel's split-lru patch.  Extracted
to make available for other, independent reclaim patches.

Moved page_anon() inline function to linux/mm_inline.h where it will
be needed by subsequent "split LRU" and "noreclaim" patches.  

page_anon() requires the definition of struct address_space() from
linux/fs.h.  A patch in 2.6.23-rc1-mm* removed the include of fs.h
from linux/mm.h in favor of including it where it's needed.   Add it
back to mm_inline.h, which is included from very few places.  These
include all the places where page_anon() is needed--so far.

Originally posted, but not Signed-off-by:  Rik van Riel <riel@redhat.com>
Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm_inline.h |   29 +++++++++++++++++++++++++++++
 mm/shmem.c                |    4 ++--
 2 files changed, 31 insertions(+), 2 deletions(-)

Index: Linux/include/linux/mm_inline.h
===================================================================
--- Linux.orig/include/linux/mm_inline.h	2007-07-08 19:32:17.000000000 -0400
+++ Linux/include/linux/mm_inline.h	2007-09-10 11:45:22.000000000 -0400
@@ -1,3 +1,31 @@
+#ifndef LINUX_MM_INLINE_H
+#define LINUX_MM_INLINE_H
+
+#include <linux/fs.h> 	/* need struct address_space for page_anon() */
+
+/*
+ * Returns true if this page is anonymous, tmpfs or otherwise swap backed.
+ */
+extern const struct address_space_operations shmem_aops;
+static inline int page_anon(struct page *page)
+{
+	struct address_space *mapping;
+
+	if (PageAnon(page) || PageSwapCache(page))
+		return 1;
+	mapping = page_mapping(page);
+	if (!mapping || !mapping->a_ops)
+		return 0;
+	if (mapping->a_ops == &shmem_aops)
+		return 1;
+	/* Should ramfs pages go onto an mlocked list instead? */
+	if ((unlikely(mapping->a_ops->writepage == NULL && PageDirty(page))))
+		return 1;
+
+	/* The page is page cache backed by a normal filesystem. */
+	return 0;
+}
+
 static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
 {
@@ -38,3 +66,4 @@ del_page_from_lru(struct zone *zone, str
 	}
 }
 
+#endif
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/shmem.c	2007-09-10 11:45:22.000000000 -0400
@@ -180,7 +180,7 @@ static inline void shmem_unacct_blocks(u
 }
 
 static const struct super_operations shmem_ops;
-static const struct address_space_operations shmem_aops;
+const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
@@ -2353,7 +2353,7 @@ static void destroy_inodecache(void)
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
