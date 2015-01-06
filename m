Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4570C6B0126
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:32 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i8so55551qcq.39
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:32 -0800 (PST)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id l6si29397714qao.88.2015.01.06.13.26.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:31 -0800 (PST)
Received: by mail-qg0-f41.google.com with SMTP id e89so71120qgf.14
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:30 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 01/45] writeback: add struct dirty_context
Date: Tue,  6 Jan 2015 16:25:38 -0500
Message-Id: <1420579582-8516-2-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

Add struct dirty_context and make page and inode dirty paths use it as
the parameter carrier.  dirty_context currently hosts ->page,
->mapping and ->inode and is initialized by init_dirty_inode_context()
or init_dirty_page_context() for non-data inode and data page dirtying
respectively.

For non-data dirtying, mark_inode_dirty_dctx() is added and
__mark_inode_dirty() is made a simple wrapper on top of it as
__mark_inode_dirty() has quite a few users.  For page dirtying,
account_page_dirtied() is updated to take dirty_context so that both
the inode and page dirtying can use the same dirty_context.

This currently doesn't make any functional difference but cgroup
writeback support will add more fields to the struct and use them to
share context between page and inode dirtying.

Include of backing-dev-defs.h is added to fs.h and mm.h for
dirty_context and the now unnecessary explicit declaration of
backing_def_info is removed from fs.h.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/buffer.c                      |  9 ++++---
 fs/fs-writeback.c                | 56 +++++++++++++++++++++++++++++++++++++---
 fs/xfs/xfs_aops.c                |  7 +++--
 include/linux/backing-dev-defs.h | 10 +++++++
 include/linux/backing-dev.h      |  4 +++
 include/linux/fs.h               |  3 ++-
 include/linux/mm.h               |  3 ++-
 mm/page-writeback.c              | 14 ++++++----
 8 files changed, 91 insertions(+), 15 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 20805db..2dab7dd 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/capability.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/file.h>
 #include <linux/quotaops.h>
 #include <linux/highmem.h>
@@ -627,17 +628,19 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
 static void __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
+	struct dirty_context dctx;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
-	if (page->mapping) {	/* Race with truncate? */
+	init_dirty_page_context(&dctx, page, mapping);
+	if (dctx.mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
-		account_page_dirtied(page, mapping);
+		account_page_dirtied(&dctx);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+	mark_inode_dirty_dctx(&dctx, I_DIRTY_PAGES);
 }
 
 /*
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5130895..97c92b3 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -106,6 +106,46 @@ out_unlock:
 	spin_unlock_bh(&wb->work_lock);
 }
 
+/**
+ * init_dirty_page_context - init dirty_context for page dirtying
+ * @dctx: dirty_context to initialize
+ * @page: page to be dirtied
+ *
+ * @page is about to be dirtied, prepare @dctx accordingly.  Must be called
+ * with @mapping->tree_lock held.  The inode dirtying due to @page dirtying
+ * should use the same @dctx.
+ *
+ * @mapping may have been obtained before the lock was acquired and
+ * @dctx->mapping can be set to NULL even if @mapping isn't if truncate
+ * took place in-between.  @dctx->inode is always set to @mapping->inode.
+ */
+void init_dirty_page_context(struct dirty_context *dctx, struct page *page,
+			     struct address_space *mapping)
+{
+	lockdep_assert_held(&mapping->tree_lock);
+
+	dctx->page = page;
+	dctx->inode = mapping->host;
+	dctx->mapping = page_mapping(page);
+
+	BUG_ON(dctx->mapping != mapping);
+}
+EXPORT_SYMBOL_GPL(init_dirty_page_context);
+
+/**
+ * init_dirty_inode_context - init dirty_context for inode dirtying
+ * @dctx: dirty_context to initialize
+ * @inode: inode to be dirtied
+ *
+ * @inode is about to be dirtied w/o a page belonging to it being dirtied,
+ * prepare @dctx accordingly.
+ */
+void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode)
+{
+	memset(dctx, 0, sizeof(*dctx));
+	dctx->inode = inode;
+}
+
 static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 				 bool range_cyclic, enum wb_reason reason)
 {
@@ -1107,8 +1147,8 @@ static noinline void block_dump___mark_inode_dirty(struct inode *inode)
 }
 
 /**
- *	__mark_inode_dirty -	internal function
- *	@inode: inode to mark
+ *	mark_inode_dirty_dctx -	internal function
+ *	@dctx: dirty_context containing the target inode
  *	@flags: what kind of dirty (i.e. I_DIRTY_SYNC)
  *	Mark an inode as dirty. Callers should use mark_inode_dirty or
  *  	mark_inode_dirty_sync.
@@ -1130,8 +1170,9 @@ static noinline void block_dump___mark_inode_dirty(struct inode *inode)
  * page->mapping->host, so the page-dirtying time is recorded in the internal
  * blockdev inode.
  */
-void __mark_inode_dirty(struct inode *inode, int flags)
+void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 {
+	struct inode *inode = dctx->inode;
 	struct super_block *sb = inode->i_sb;
 	struct backing_dev_info *bdi = NULL;
 
@@ -1222,6 +1263,15 @@ out_unlock_inode:
 	spin_unlock(&inode->i_lock);
 
 }
+EXPORT_SYMBOL(mark_inode_dirty_dctx);
+
+void __mark_inode_dirty(struct inode *inode, int flags)
+{
+	struct dirty_context dctx;
+
+	init_dirty_inode_context(&dctx, inode);
+	mark_inode_dirty_dctx(&dctx, flags);
+}
 EXPORT_SYMBOL(__mark_inode_dirty);
 
 static void wait_sb_inodes(struct super_block *sb)
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 18e2f3b..fb94975 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -36,6 +36,7 @@
 #include <linux/mpage.h>
 #include <linux/pagevec.h>
 #include <linux/writeback.h>
+#include <linux/backing-dev.h>
 
 void
 xfs_count_page_state(
@@ -1814,17 +1815,19 @@ xfs_vm_set_page_dirty(
 
 	if (newly_dirty) {
 		/* sigh - __set_page_dirty() is static, so copy it here, too */
+		struct dirty_context dctx;
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
+		init_dirty_page_context(&dctx, page, mapping);
 		if (page->mapping) {	/* Race with truncate? */
 			WARN_ON_ONCE(!PageUptodate(page));
-			account_page_dirtied(page, mapping);
+			account_page_dirtied(&dctx);
 			radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+		mark_inode_dirty_dctx(&dctx, I_DIRTY_PAGES);
 	}
 	return newly_dirty;
 }
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 2874d83..bf20ef1 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -94,6 +94,16 @@ struct backing_dev_info {
 #endif
 };
 
+/*
+ * The following structure carries context used during page and inode
+ * dirtying.  Should be initialized with init_dirty_{inode|page}_context().
+ */
+struct dirty_context {
+	struct page		*page;
+	struct inode		*inode;
+	struct address_space	*mapping;
+};
+
 enum {
 	BLK_RW_ASYNC	= 0,
 	BLK_RW_SYNC	= 1,
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 3c6fd34..34fe620 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -263,4 +263,8 @@ static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
 	return sb->s_bdi;
 }
 
+void init_dirty_page_context(struct dirty_context *dctx, struct page *page,
+			     struct address_space *mapping);
+void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode);
+
 #endif		/* _LINUX_BACKING_DEV_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8639770..9b63758 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -30,6 +30,7 @@
 #include <linux/lockdep.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/blk_types.h>
+#include <linux/backing-dev-defs.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -394,7 +395,6 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 
-struct backing_dev_info;
 struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
@@ -1749,6 +1749,7 @@ struct super_operations {
 
 #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
 
+extern void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags);
 extern void __mark_inode_dirty(struct inode *, int);
 static inline void mark_inode_dirty(struct inode *inode)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0c15841..825acb8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -20,6 +20,7 @@
 #include <linux/shrinker.h>
 #include <linux/resource.h>
 #include <linux/page_ext.h>
+#include <linux/backing-dev-defs.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1250,7 +1251,7 @@ int __set_page_dirty_nobuffers(struct page *page);
 int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
-void account_page_dirtied(struct page *page, struct address_space *mapping);
+void account_page_dirtied(struct dirty_context *dctx);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0632a43..0e35ff4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2090,8 +2090,11 @@ int __set_page_dirty_no_writeback(struct page *page)
  * Helper function for set_page_dirty family.
  * NOTE: This relies on being atomic wrt interrupts.
  */
-void account_page_dirtied(struct page *page, struct address_space *mapping)
+void account_page_dirtied(struct dirty_context *dctx)
 {
+	struct page *page = dctx->page;
+	struct address_space *mapping = dctx->mapping;
+
 	trace_writeback_dirty_page(page, mapping);
 
 	if (!mapping_cap_account_dirty(mapping))
@@ -2123,21 +2126,22 @@ int __set_page_dirty_nobuffers(struct page *page)
 {
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
+		struct dirty_context dctx;
 		unsigned long flags;
 
 		if (!mapping)
 			return 1;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
-		BUG_ON(page_mapping(page) != mapping);
+		init_dirty_page_context(&dctx, page, mapping);
 		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
-		account_page_dirtied(page, mapping);
+		account_page_dirtied(&dctx);
 		radix_tree_tag_set(&mapping->page_tree, page_index(page),
 				   PAGECACHE_TAG_DIRTY);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		if (mapping->host) {
+		if (dctx.inode) {
 			/* !PageAnon && !swapper_space */
-			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+			mark_inode_dirty_dctx(&dctx, I_DIRTY_PAGES);
 		}
 		return 1;
 	}
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
