Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF378D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 07:31:19 -0500 (EST)
Subject: [PATCH] mm: prevent concurrent unmap_mapping_range() on the same inode
Message-Id: <E1PftfG-0007w1-Ek@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 20 Jan 2011 13:30:58 +0100
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hughd@google.com, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Miklos Szeredi <mszeredi@suse.cz>

Running a fuse filesystem with multiple open()'s in parallel can
trigger a "kernel BUG at mm/truncate.c:475"

The reason is, unmap_mapping_range() is not prepared for more than
one concurrent invocation per inode.  For example:

  thread1: going through a big range, stops in the middle of a vma and
     stores the restart address in vm_truncate_count.

  thread2: comes in with a small (e.g. single page) unmap request on
     the same vma, somewhere before restart_address, finds that the
     vma was already unmapped up to the restart address and happily
     returns without doing anything.

Another scenario would be two big unmap requests, both having to
restart the unmapping and each one setting vm_truncate_count to its
own value.  This could go on forever without any of them being able to
finish.

Truncate and hole punching already serialize with i_mutex.  Other
callers of unmap_mapping_range() do not, and it's difficult to get
i_mutex protection for all callers.  In particular ->d_revalidate(),
which calls invalidate_inode_pages2_range() in fuse, may be called
with or without i_mutex.

This patch adds a new mutex to 'struct address_space' to prevent
running multiple concurrent unmap_mapping_range() on the same mapping.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
Reported-by: Michael Leun <lkml20101129@newton.leun.net>
Tested-by: Gurudas Pai <gurudas.pai@oracle.com>
---
 fs/gfs2/main.c     |    9 +--------
 fs/inode.c         |   22 +++++++++++++++-------
 fs/nilfs2/btnode.c |    5 -----
 fs/nilfs2/btnode.h |    1 -
 fs/nilfs2/mdt.c    |    4 ++--
 fs/nilfs2/page.c   |   13 -------------
 fs/nilfs2/page.h   |    1 -
 fs/nilfs2/super.c  |    2 +-
 include/linux/fs.h |    2 ++
 mm/memory.c        |    2 ++
 10 files changed, 23 insertions(+), 38 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2011-01-17 09:33:44.000000000 +0100
+++ linux-2.6/mm/memory.c	2011-01-20 13:03:29.000000000 +0100
@@ -2650,6 +2650,7 @@ void unmap_mapping_range(struct address_
 		details.last_index = ULONG_MAX;
 	details.i_mmap_lock = &mapping->i_mmap_lock;
 
+	mutex_lock(&mapping->unmap_mutex);
 	spin_lock(&mapping->i_mmap_lock);
 
 	/* Protect against endless unmapping loops */
@@ -2666,6 +2667,7 @@ void unmap_mapping_range(struct address_
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
 	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->unmap_mutex);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
Index: linux-2.6/fs/gfs2/main.c
===================================================================
--- linux-2.6.orig/fs/gfs2/main.c	2011-01-12 12:27:59.000000000 +0100
+++ linux-2.6/fs/gfs2/main.c	2011-01-20 13:03:29.000000000 +0100
@@ -59,14 +59,7 @@ static void gfs2_init_gl_aspace_once(voi
 	struct address_space *mapping = (struct address_space *)(gl + 1);
 
 	gfs2_init_glock_once(gl);
-	memset(mapping, 0, sizeof(*mapping));
-	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
-	spin_lock_init(&mapping->tree_lock);
-	spin_lock_init(&mapping->i_mmap_lock);
-	INIT_LIST_HEAD(&mapping->private_list);
-	spin_lock_init(&mapping->private_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
-	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	address_space_init_once(mapping);
 }
 
 /**
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c	2011-01-12 12:27:59.000000000 +0100
+++ linux-2.6/fs/inode.c	2011-01-20 13:03:29.000000000 +0100
@@ -295,6 +295,20 @@ static void destroy_inode(struct inode *
 		call_rcu(&inode->i_rcu, i_callback);
 }
 
+void address_space_init_once(struct address_space *mapping)
+{
+	memset(mapping, 0, sizeof(*mapping));
+	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
+	spin_lock_init(&mapping->tree_lock);
+	spin_lock_init(&mapping->i_mmap_lock);
+	INIT_LIST_HEAD(&mapping->private_list);
+	spin_lock_init(&mapping->private_lock);
+	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
+	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	mutex_init(&mapping->unmap_mutex);
+}
+EXPORT_SYMBOL(address_space_init_once);
+
 /*
  * These are initializations that only need to be done
  * once, because the fields are idempotent across use
@@ -308,13 +322,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_devices);
 	INIT_LIST_HEAD(&inode->i_wb_list);
 	INIT_LIST_HEAD(&inode->i_lru);
-	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
-	spin_lock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
-	INIT_LIST_HEAD(&inode->i_data.private_list);
-	spin_lock_init(&inode->i_data.private_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
-	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
+	address_space_init_once(&inode->i_data);
 	i_size_ordered_init(inode);
 #ifdef CONFIG_FSNOTIFY
 	INIT_HLIST_HEAD(&inode->i_fsnotify_marks);
Index: linux-2.6/fs/nilfs2/btnode.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/btnode.c	2011-01-12 12:28:00.000000000 +0100
+++ linux-2.6/fs/nilfs2/btnode.c	2011-01-20 13:03:29.000000000 +0100
@@ -35,11 +35,6 @@
 #include "btnode.h"
 
 
-void nilfs_btnode_cache_init_once(struct address_space *btnc)
-{
-	nilfs_mapping_init_once(btnc);
-}
-
 static const struct address_space_operations def_btnode_aops = {
 	.sync_page		= block_sync_page,
 };
Index: linux-2.6/fs/nilfs2/btnode.h
===================================================================
--- linux-2.6.orig/fs/nilfs2/btnode.h	2011-01-12 12:28:00.000000000 +0100
+++ linux-2.6/fs/nilfs2/btnode.h	2011-01-20 13:03:29.000000000 +0100
@@ -37,7 +37,6 @@ struct nilfs_btnode_chkey_ctxt {
 	struct buffer_head *newbh;
 };
 
-void nilfs_btnode_cache_init_once(struct address_space *);
 void nilfs_btnode_cache_init(struct address_space *, struct backing_dev_info *);
 void nilfs_btnode_cache_clear(struct address_space *);
 struct buffer_head *nilfs_btnode_create_block(struct address_space *btnc,
Index: linux-2.6/fs/nilfs2/mdt.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/mdt.c	2011-01-12 12:28:00.000000000 +0100
+++ linux-2.6/fs/nilfs2/mdt.c	2011-01-20 13:03:29.000000000 +0100
@@ -454,9 +454,9 @@ int nilfs_mdt_setup_shadow_map(struct in
 	struct backing_dev_info *bdi = inode->i_sb->s_bdi;
 
 	INIT_LIST_HEAD(&shadow->frozen_buffers);
-	nilfs_mapping_init_once(&shadow->frozen_data);
+	address_space_init_once(&shadow->frozen_data);
 	nilfs_mapping_init(&shadow->frozen_data, bdi, &shadow_map_aops);
-	nilfs_mapping_init_once(&shadow->frozen_btnodes);
+	address_space_init_once(&shadow->frozen_btnodes);
 	nilfs_mapping_init(&shadow->frozen_btnodes, bdi, &shadow_map_aops);
 	mi->mi_shadow = shadow;
 	return 0;
Index: linux-2.6/fs/nilfs2/page.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/page.c	2011-01-12 12:28:00.000000000 +0100
+++ linux-2.6/fs/nilfs2/page.c	2011-01-20 13:03:29.000000000 +0100
@@ -492,19 +492,6 @@ unsigned nilfs_page_count_clean_buffers(
 	return nc;
 }
 
-void nilfs_mapping_init_once(struct address_space *mapping)
-{
-	memset(mapping, 0, sizeof(*mapping));
-	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
-	spin_lock_init(&mapping->tree_lock);
-	INIT_LIST_HEAD(&mapping->private_list);
-	spin_lock_init(&mapping->private_lock);
-
-	spin_lock_init(&mapping->i_mmap_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
-	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
-}
-
 void nilfs_mapping_init(struct address_space *mapping,
 			struct backing_dev_info *bdi,
 			const struct address_space_operations *aops)
Index: linux-2.6/fs/nilfs2/page.h
===================================================================
--- linux-2.6.orig/fs/nilfs2/page.h	2011-01-12 12:28:00.000000000 +0100
+++ linux-2.6/fs/nilfs2/page.h	2011-01-20 13:03:29.000000000 +0100
@@ -61,7 +61,6 @@ void nilfs_free_private_page(struct page
 int nilfs_copy_dirty_pages(struct address_space *, struct address_space *);
 void nilfs_copy_back_pages(struct address_space *, struct address_space *);
 void nilfs_clear_dirty_pages(struct address_space *);
-void nilfs_mapping_init_once(struct address_space *mapping);
 void nilfs_mapping_init(struct address_space *mapping,
 			struct backing_dev_info *bdi,
 			const struct address_space_operations *aops);
Index: linux-2.6/fs/nilfs2/super.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/super.c	2011-01-17 09:33:44.000000000 +0100
+++ linux-2.6/fs/nilfs2/super.c	2011-01-20 13:03:29.000000000 +0100
@@ -1278,7 +1278,7 @@ static void nilfs_inode_init_once(void *
 #ifdef CONFIG_NILFS_XATTR
 	init_rwsem(&ii->xattr_sem);
 #endif
-	nilfs_btnode_cache_init_once(&ii->i_btnode_cache);
+	address_space_init_once(&ii->i_btnode_cache);
 	ii->i_bmap = &ii->i_bmap_data;
 	inode_init_once(&ii->vfs_inode);
 }
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2011-01-20 13:03:13.000000000 +0100
+++ linux-2.6/include/linux/fs.h	2011-01-20 13:03:29.000000000 +0100
@@ -649,6 +649,7 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+	struct mutex		unmap_mutex;    /* to protect unmapping */
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -2225,6 +2226,7 @@ extern loff_t vfs_llseek(struct file *fi
 
 extern int inode_init_always(struct super_block *, struct inode *);
 extern void inode_init_once(struct inode *);
+extern void address_space_init_once(struct address_space *mapping);
 extern void ihold(struct inode * inode);
 extern void iput(struct inode *);
 extern struct inode * igrab(struct inode *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
