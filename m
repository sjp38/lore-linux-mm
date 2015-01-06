Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 67BDF6B012C
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:40 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id f51so65595qge.22
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:40 -0800 (PST)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id 7si23379227qgk.40.2015.01.06.13.26.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:38 -0800 (PST)
Received: by mail-qc0-f169.google.com with SMTP id w7so64028qcr.28
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:38 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 05/45] writeback: make backing_dev_info host cgroup-specific bdi_writebacks
Date: Tue,  6 Jan 2015 16:25:42 -0500
Message-Id: <1420579582-8516-6-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

For the planned cgroup writeback support, on each bdi
(backing_dev_info), each cgroup will be served by a separate wb
(bdi_writeback).  This patch updates bdi so that a bdi can host
multiple wbs (bdi_writebacks).

bdi->wb remains unchanged and will keep serving the root cgroup.
cgwb's (cgroup wb's) for non-root cgroups are created on-demand or
looked up during init_cgwb_dirty_page_contex() according to the dirty
blkcg of the page being dirtied.  Each cgwb is indexed on
bdi->cgwb_tree by its blkcg id.

Once dirty_context is initialized for a page, the page's wb can be
looked up using page_cgwb_{dirty|wb}() while the page is dirty or
under writeback respectively.  Once created, a cgwb is destroyed iff
either its associated bdi or blkcg is destroyed, meaning that as long
as a page is dirty or under writeback, its associated cgwb is
accessible without further locking.

dirty_context grew a new field ->wb which caches the selected wb and
account_page_dirtied() is updated to use that instead of
unconditionally using bdi->wb.

Currently, none of the filesystems has FS_CGROUP_WRITEBACK and all
pages will keep being associated with bdi->wb.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 block/blk-cgroup.c               |  11 ++-
 fs/fs-writeback.c                |  19 +++-
 include/linux/backing-dev-defs.h |  17 +++-
 include/linux/backing-dev.h      | 123 +++++++++++++++++++++++++
 include/linux/blk-cgroup.h       |   4 +
 mm/backing-dev.c                 | 189 +++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              |   4 +-
 7 files changed, 361 insertions(+), 6 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 9e0fe38..8bebaa9 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/err.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/slab.h>
 #include <linux/genhd.h>
 #include <linux/delay.h>
@@ -813,6 +814,11 @@ static void blkcg_css_offline(struct cgroup_subsys_state *css)
 	spin_unlock_irq(&blkcg->lock);
 }
 
+static void blkcg_css_released(struct cgroup_subsys_state *css)
+{
+	cgwb_blkcg_released(css);
+}
+
 static void blkcg_css_free(struct cgroup_subsys_state *css)
 {
 	struct blkcg *blkcg = css_to_blkcg(css);
@@ -841,7 +847,9 @@ done:
 	spin_lock_init(&blkcg->lock);
 	INIT_RADIX_TREE(&blkcg->blkg_tree, GFP_ATOMIC);
 	INIT_HLIST_HEAD(&blkcg->blkg_list);
-
+#ifdef CONFIG_CGROUP_WRITEBACK
+	INIT_LIST_HEAD(&blkcg->cgwb_list);
+#endif
 	return &blkcg->css;
 }
 
@@ -926,6 +934,7 @@ static int blkcg_can_attach(struct cgroup_subsys_state *css,
 struct cgroup_subsys blkio_cgrp_subsys = {
 	.css_alloc = blkcg_css_alloc,
 	.css_offline = blkcg_css_offline,
+	.css_released = blkcg_css_released,
 	.css_free = blkcg_css_free,
 	.can_attach = blkcg_can_attach,
 	.legacy_cftypes = blkcg_files,
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 138a5ea..3b54835 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -117,21 +117,37 @@ out_unlock:
  */
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
 {
+	struct backing_dev_info *bdi = dctx->mapping->backing_dev_info;
+	struct cgroup_subsys_state *blkcg_css;
+
 	/* cgroup writeback requires support from both the bdi and filesystem */
 	if (!mapping_cgwb_enabled(dctx->mapping))
 		goto force_root;
 
-	page_blkcg_attach_dirty(dctx->page);
+	/*
+	 * @dctx->page is a candidate for cgroup writeback and about to be
+	 * dirtied.  Attach the dirty blkcg to the page and pre-allocate
+	 * all resources necessary for cgroup writeback.  On failure, fall
+	 * back to the root blkcg.
+	 */
+	blkcg_css = page_blkcg_attach_dirty(dctx->page);
+	dctx->wb = cgwb_lookup_create(bdi, blkcg_css);
+	if (!dctx->wb) {
+		page_blkcg_detach_dirty(dctx->page);
+		goto force_root;
+	}
 	return;
 
 force_root:
 	page_blkcg_force_root_dirty(dctx->page);
+	dctx->wb = &bdi->wb;
 }
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
 {
+	dctx->wb = &dctx->mapping->backing_dev_info->wb;
 }
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
@@ -176,6 +192,7 @@ void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode)
 {
 	memset(dctx, 0, sizeof(*dctx));
 	dctx->inode = inode;
+	dctx->wb = &inode_to_bdi(inode)->wb;
 }
 
 static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index bf20ef1..511066f 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -2,6 +2,7 @@
 #define __LINUX_BACKING_DEV_DEFS_H
 
 #include <linux/list.h>
+#include <linux/radix-tree.h>
 #include <linux/spinlock.h>
 #include <linux/percpu_counter.h>
 #include <linux/flex_proportions.h>
@@ -68,6 +69,15 @@ struct bdi_writeback {
 	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
 	struct list_head work_list;
 	struct delayed_work dwork;	/* work item used for writeback */
+
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct cgroup_subsys_state *blkcg_css; /* the blkcg we belong to */
+	struct list_head blkcg_node;	/* anchored at blkcg->wb_list */
+	union {
+		struct list_head shutdown_node;
+		struct rcu_head rcu;
+	};
+#endif
 };
 
 struct backing_dev_info {
@@ -82,8 +92,10 @@ struct backing_dev_info {
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
 
-	struct bdi_writeback wb;  /* default writeback info for this bdi */
-
+	struct bdi_writeback wb; /* the root writeback info for this bdi */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct radix_tree_root cgwb_tree; /* radix tree of !root cgroup wbs */
+#endif
 	struct device *dev;
 
 	struct timer_list laptop_mode_wb_timer;
@@ -102,6 +114,7 @@ struct dirty_context {
 	struct page		*page;
 	struct inode		*inode;
 	struct address_space	*mapping;
+	struct bdi_writeback	*wb;
 };
 
 enum {
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 7a20cff..3722796 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -13,6 +13,7 @@
 #include <linux/sched.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include <linux/blk-cgroup.h>
 
 #include <linux/backing-dev-defs.h>
 
@@ -273,6 +274,10 @@ void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode);
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css);
+int __cgwb_create(struct backing_dev_info *bdi,
+		  struct cgroup_subsys_state *blkcg_css);
+
 /**
  * mapping_cgwb_enabled - test whether cgroup writeback is enabled on a mapping
  * @mapping: address_space of interest
@@ -290,6 +295,97 @@ static inline bool mapping_cgwb_enabled(struct address_space *mapping)
 		inode && (inode->i_sb->s_type->fs_flags & FS_CGROUP_WRITEBACK);
 }
 
+/**
+ * cgwb_lookup - lookup cgwb for a given blkcg on a bdi
+ * @bdi: target bdi
+ * @blkcg_css: target blkcg
+ *
+ * Look up the cgwb (cgroup bdi_writeback) for @blkcg_css on @bdi.  The
+ * returned cgwb is accessible as long as @bdi and @blkcg_css stay alive.
+ *
+ * Returns the pointer to the found cgwb on success, NULL on failure.
+ */
+static inline struct bdi_writeback *
+cgwb_lookup(struct backing_dev_info *bdi, struct cgroup_subsys_state *blkcg_css)
+{
+	struct bdi_writeback *cgwb;
+
+	if (blkcg_css == blkcg_root_css)
+		return &bdi->wb;
+
+	/*
+	 * RCU locking protects the radix tree itself.  The looked up cgwb
+	 * is protected by the caller ensuring that @bdi and the blkcg w/
+	 * @blkcg_id are alive.
+	 */
+	rcu_read_lock();
+	cgwb = radix_tree_lookup(&bdi->cgwb_tree, blkcg_css->id);
+	rcu_read_unlock();
+	return cgwb;
+}
+
+/**
+ * cgwb_lookup_create - try to lookup cgwb and create one if not found
+ * @bdi: target bdi
+ * @blkcg_css: cgroup_subsys_state of the target blkcg
+ *
+ * Try to look up the cgwb (cgroup bdi_writeback) for the blkcg with
+ * @blkcg_css on @bdi.  If it doesn't exist, try to create one.  This
+ * function can be called under any context without locking as long as @bdi
+ * and @blkcg_css are kept alive.  See cgwb_lookup() for details.
+ *
+ * Returns the pointer to the found cgwb on success, NULL if such cgwb
+ * doesn't exist and creation failed due to memory pressure.
+ */
+static inline struct bdi_writeback *
+cgwb_lookup_create(struct backing_dev_info *bdi,
+		   struct cgroup_subsys_state *blkcg_css)
+{
+	struct bdi_writeback *wb;
+
+	do {
+		wb = cgwb_lookup(bdi, blkcg_css);
+		if (wb)
+			return wb;
+	} while (!__cgwb_create(bdi, blkcg_css));
+
+	return NULL;
+}
+
+/**
+ * page_cgwb_dirty - lookup the dirty cgwb of a page
+ * @page: target page
+ *
+ * Returns the dirty cgwb (cgroup bdi_writeback) of @page.  The returned
+ * wb is accessible as long as @page is dirty.
+ */
+static inline struct bdi_writeback *page_cgwb_dirty(struct page *page)
+{
+	struct backing_dev_info *bdi = page->mapping->backing_dev_info;
+	struct bdi_writeback *wb = cgwb_lookup(bdi, page_blkcg_dirty(page));
+
+	if (WARN_ON_ONCE(!wb))
+		return &bdi->wb;
+	return wb;
+}
+
+/**
+ * page_cgwb_wb - lookup the writeback cgwb of a page
+ * @page: target page
+ *
+ * Returns the writeback cgwb (cgroup bdi_writeback) of @page.  The
+ * returned wb is accessible as long as @page is under writeback.
+ */
+static inline struct bdi_writeback *page_cgwb_wb(struct page *page)
+{
+	struct backing_dev_info *bdi = page->mapping->backing_dev_info;
+	struct bdi_writeback *wb = cgwb_lookup(bdi, page_blkcg_wb(page));
+
+	if (WARN_ON_ONCE(!wb))
+		return &bdi->wb;
+	return wb;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline bool mapping_cgwb_enabled(struct address_space *mapping)
@@ -297,6 +393,33 @@ static inline bool mapping_cgwb_enabled(struct address_space *mapping)
 	return false;
 }
 
+static inline void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css)
+{
+}
+
+static inline struct bdi_writeback *
+cgwb_lookup(struct backing_dev_info *bdi, struct cgroup_subsys_state *blkcg_css)
+{
+	return &bdi->wb;
+}
+
+static inline struct bdi_writeback *
+cgwb_lookup_create(struct backing_dev_info *bdi,
+		   struct cgroup_subsys_state *blkcg_css)
+{
+	return &bdi->wb;
+}
+
+static inline struct bdi_writeback *page_cgwb_dirty(struct page *page)
+{
+	return &page->mapping->backing_dev_info->wb;
+}
+
+static inline struct bdi_writeback *page_cgwb_wb(struct page *page)
+{
+	return &page->mapping->backing_dev_info->wb;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 #endif		/* _LINUX_BACKING_DEV_H */
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 4dc643f..3033eb1 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -53,6 +53,10 @@ struct blkcg {
 	/* TODO: per-policy storage in blkcg */
 	unsigned int			cfq_weight;	/* belongs to cfq */
 	unsigned int			cfq_leaf_weight;
+
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct list_head		cgwb_list;
+#endif
 };
 
 struct blkg_stat {
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 1c9b70e..c6dda82 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -440,6 +440,192 @@ static void wb_exit(struct bdi_writeback *wb)
 	fprop_local_destroy_percpu(&wb->completions);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/*
+ * cgwb_lock protects bdi->cgwb_tree and blkcg->cgwb_list where the former
+ * is also RCU protected.  cgwb_shutdown_mutex synchronizes shutdown
+ * attempts from bdi and blkcg destructions.  For details, see
+ * cgwb_shutdown_prepare/commit().
+ */
+static DEFINE_SPINLOCK(cgwb_lock);
+static DEFINE_MUTEX(cgwb_shutdown_mutex);
+
+int __cgwb_create(struct backing_dev_info *bdi,
+		  struct cgroup_subsys_state *blkcg_css)
+{
+	struct blkcg *blkcg = css_to_blkcg(blkcg_css);
+	struct bdi_writeback *wb;
+	unsigned long flags;
+	int ret;
+
+	wb = kzalloc(sizeof(*wb), GFP_ATOMIC);
+	if (!wb)
+		return -ENOMEM;
+
+	ret = wb_init(wb, bdi, GFP_ATOMIC);
+	if (ret) {
+		kfree(wb);
+		return -ENOMEM;
+	}
+
+	wb->blkcg_css = blkcg_css;
+	set_bit(WB_registered, &wb->state); /* cgwbs are always registered */
+
+	ret = -ENODEV;
+	spin_lock_irqsave(&cgwb_lock, flags);
+	/* the root wb determines the registered state of the whole bdi */
+	if (test_bit(WB_registered, &bdi->wb.state)) {
+		/* we might have raced w/ another instance of this function */
+		ret = radix_tree_insert(&bdi->cgwb_tree, blkcg_css->id, wb);
+		if (!ret)
+			list_add_tail(&wb->blkcg_node, &blkcg->cgwb_list);
+	}
+	spin_unlock_irqrestore(&cgwb_lock, flags);
+	if (ret) {
+		wb_exit(wb);
+		if (ret != -EEXIST)
+			return ret;
+	}
+	return 0;
+}
+
+/**
+ * cgwb_shutdown_prepare - prepare to shutdown a cgwb
+ * @wb: cgwb to be shutdown
+ * @to_shutdown: list to queue @wb on
+ *
+ * This function is called to queue @wb for shutdown on @to_shutdown.  The
+ * bdi_writeback indexes use the cgwb_lock spinlock but wb_shutdown() needs
+ * process context, so this function can be called while holding cgwb_lock
+ * and cgwb_shutdown_mutex to queue cgwbs for shutdown.  Once all target
+ * cgwbs are queued, the caller should release cgwb_lock and invoke
+ * cgwb_shutdown_commit().
+ */
+static void cgwb_shutdown_prepare(struct bdi_writeback *wb,
+				  struct list_head *to_shutdown)
+{
+	lockdep_assert_held(&cgwb_lock);
+	lockdep_assert_held(&cgwb_shutdown_mutex);
+
+	WARN_ON(!test_bit(WB_registered, &wb->state));
+	clear_bit(WB_registered, &wb->state);
+	list_add_tail(&wb->shutdown_node, to_shutdown);
+}
+
+/**
+ * cgwb_shutdown_commit - commit cgwb shutdowns
+ * @to_shutdown: list of cgwbs to shutdown
+ *
+ * This function is called after @to_shutdown is built by calls to
+ * cgwb_shutdown_prepare() and cgwb_lock is released.  It invokes
+ * wb_shutdown() on all cgwbs on the list.  bdi and blkcg may try to
+ * shutdown the same cgwbs and should wait till completion if shutdown is
+ * initiated by the other.  This synchronization is achieved through
+ * cgwb_shutdown_mutex which should have been acquired before the
+ * cgwb_shutdown_prepare() invocations.
+ */
+static void cgwb_shutdown_commit(struct list_head *to_shutdown)
+{
+	struct bdi_writeback *wb;
+
+	lockdep_assert_held(&cgwb_shutdown_mutex);
+
+	list_for_each_entry(wb, to_shutdown, shutdown_node)
+		wb_shutdown(wb);
+}
+
+static void cgwb_exit(struct bdi_writeback *wb)
+{
+	WARN_ON(!radix_tree_delete(&wb->bdi->cgwb_tree, wb->blkcg_css->id));
+	list_del(&wb->blkcg_node);
+	wb_exit(wb);
+	kfree_rcu(wb, rcu);
+}
+
+static void cgwb_bdi_init(struct backing_dev_info *bdi)
+{
+	bdi->wb.blkcg_css = blkcg_root_css;
+	INIT_RADIX_TREE(&bdi->cgwb_tree, GFP_ATOMIC);
+}
+
+/**
+ * cgwb_bdi_shutdown - @bdi is being shut down, shut down all cgwbs
+ * @bdi: bdi being shut down
+ */
+static void cgwb_bdi_shutdown(struct backing_dev_info *bdi)
+{
+	LIST_HEAD(to_shutdown);
+	struct radix_tree_iter iter;
+	void **slot;
+
+	WARN_ON(test_bit(WB_registered, &bdi->wb.state));
+
+	mutex_lock(&cgwb_shutdown_mutex);
+	spin_lock_irq(&cgwb_lock);
+
+	radix_tree_for_each_slot(slot, &bdi->cgwb_tree, &iter, 0)
+		cgwb_shutdown_prepare(*slot, &to_shutdown);
+
+	spin_unlock_irq(&cgwb_lock);
+	cgwb_shutdown_commit(&to_shutdown);
+	mutex_unlock(&cgwb_shutdown_mutex);
+}
+
+/**
+ * cgwb_bdi_exit - @bdi is being exit, exit all its cgwbs
+ * @bdi: bdi being shut down
+ */
+static void cgwb_bdi_exit(struct backing_dev_info *bdi)
+{
+	LIST_HEAD(to_free);
+	struct radix_tree_iter iter;
+	void **slot;
+
+	spin_lock_irq(&cgwb_lock);
+	radix_tree_for_each_slot(slot, &bdi->cgwb_tree, &iter, 0) {
+		struct bdi_writeback *wb = *slot;
+
+		WARN_ON(test_bit(WB_registered, &wb->state));
+		cgwb_exit(wb);
+	}
+	spin_unlock_irq(&cgwb_lock);
+}
+
+/**
+ * cgwb_blkcg_released - a blkcg is being destroyed, release all matching cgwbs
+ * @blkcg_css: blkcg being destroyed
+ */
+void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css)
+{
+	LIST_HEAD(to_shutdown);
+	struct blkcg *blkcg = css_to_blkcg(blkcg_css);
+	struct bdi_writeback *wb, *next;
+
+	mutex_lock(&cgwb_shutdown_mutex);
+	spin_lock_irq(&cgwb_lock);
+
+	list_for_each_entry_safe(wb, next, &blkcg->cgwb_list, blkcg_node)
+		cgwb_shutdown_prepare(wb, &to_shutdown);
+
+	spin_unlock_irq(&cgwb_lock);
+	cgwb_shutdown_commit(&to_shutdown);
+	mutex_unlock(&cgwb_shutdown_mutex);
+
+	spin_lock_irq(&cgwb_lock);
+	list_for_each_entry_safe(wb, next, &blkcg->cgwb_list, blkcg_node)
+		cgwb_exit(wb);
+	spin_unlock_irq(&cgwb_lock);
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static void cgwb_bdi_init(struct backing_dev_info *bdi) { }
+static void cgwb_bdi_shutdown(struct backing_dev_info *bdi) { }
+static void cgwb_bdi_exit(struct backing_dev_info *bdi) { }
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 int bdi_init(struct backing_dev_info *bdi)
 {
 	int err;
@@ -455,6 +641,7 @@ int bdi_init(struct backing_dev_info *bdi)
 	if (err)
 		return err;
 
+	cgwb_bdi_init(bdi);
 	return 0;
 }
 EXPORT_SYMBOL(bdi_init);
@@ -532,6 +719,7 @@ void bdi_unregister(struct backing_dev_info *bdi)
 			/* make sure nobody finds us on the bdi_list anymore */
 			bdi_remove_from_list(bdi);
 			wb_shutdown(&bdi->wb);
+			cgwb_bdi_shutdown(bdi);
 		}
 
 		bdi_debug_unregister(bdi);
@@ -544,6 +732,7 @@ EXPORT_SYMBOL(bdi_unregister);
 void bdi_destroy(struct backing_dev_info *bdi)
 {
 	bdi_unregister(bdi);
+	cgwb_bdi_exit(bdi);
 	wb_exit(&bdi->wb);
 }
 EXPORT_SYMBOL(bdi_destroy);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 72a0edf..6475504 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2102,8 +2102,8 @@ void account_page_dirtied(struct dirty_context *dctx)
 
 	__inc_zone_page_state(page, NR_FILE_DIRTY);
 	__inc_zone_page_state(page, NR_DIRTIED);
-	__inc_wb_stat(&mapping->backing_dev_info->wb, WB_RECLAIMABLE);
-	__inc_wb_stat(&mapping->backing_dev_info->wb, WB_DIRTIED);
+	__inc_wb_stat(dctx->wb, WB_RECLAIMABLE);
+	__inc_wb_stat(dctx->wb, WB_DIRTIED);
 	task_io_account_write(PAGE_CACHE_SIZE);
 	current->nr_dirtied++;
 	this_cpu_inc(bdp_ratelimits);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
