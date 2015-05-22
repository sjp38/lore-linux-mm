Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9B900829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:01 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so22207561qkg.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:01 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id 23si3728978qhc.26.2015.05.22.14.15.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:00 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so22207139qkg.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:00 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 23/51] writeback: make backing_dev_info host cgroup-specific bdi_writebacks
Date: Fri, 22 May 2015 17:13:37 -0400
Message-Id: <1432329245-5844-24-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>

For the planned cgroup writeback support, on each bdi
(backing_dev_info), each memcg will be served by a separate wb
(bdi_writeback).  This patch updates bdi so that a bdi can host
multiple wbs (bdi_writebacks).

On the default hierarchy, blkcg implicitly enables memcg.  This allows
using memcg's page ownership for attributing writeback IOs, and every
memcg - blkcg combination can be served by its own wb by assigning a
dedicated wb to each memcg.  This means that there may be multiple
wb's of a bdi mapped to the same blkcg.  As congested state is per
blkcg - bdi combination, those wb's should share the same congested
state.  This is achieved by tracking congested state via
bdi_writeback_congested structs which are keyed by blkcg.

bdi->wb remains unchanged and will keep serving the root cgroup.
cgwb's (cgroup wb's) for non-root cgroups are created on-demand or
looked up while dirtying an inode according to the memcg of the page
being dirtied or current task.  Each cgwb is indexed on bdi->cgwb_tree
by its memcg id.  Once an inode is associated with its wb, it can be
retrieved using inode_to_wb().

Currently, none of the filesystems has FS_CGROUP_WRITEBACK and all
pages will keep being associated with bdi->wb.

v3: inode_attach_wb() in account_page_dirtied() moved inside
    mapping_cap_account_dirty() block where it's known to be !NULL.
    Also, an unnecessary NULL check before kfree() removed.  Both
    detected by the kbuild bot.

v2: Updated so that wb association is per inode and wb is per memcg
    rather than blkcg.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: kbuild test robot <fengguang.wu@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 block/blk-cgroup.c               |   7 +-
 fs/fs-writeback.c                |   8 +-
 fs/inode.c                       |   1 +
 include/linux/backing-dev-defs.h |  59 +++++-
 include/linux/backing-dev.h      | 195 +++++++++++++++++++
 include/linux/blk-cgroup.h       |   4 +
 include/linux/fs.h               |   4 +
 include/linux/memcontrol.h       |   4 +
 mm/backing-dev.c                 | 397 +++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c                  |  19 +-
 mm/page-writeback.c              |  11 +-
 11 files changed, 698 insertions(+), 11 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 54ec172..979cfdb 100644
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
@@ -797,6 +798,8 @@ static void blkcg_css_offline(struct cgroup_subsys_state *css)
 	}
 
 	spin_unlock_irq(&blkcg->lock);
+
+	wb_blkcg_offline(blkcg);
 }
 
 static void blkcg_css_free(struct cgroup_subsys_state *css)
@@ -827,7 +830,9 @@ blkcg_css_alloc(struct cgroup_subsys_state *parent_css)
 	spin_lock_init(&blkcg->lock);
 	INIT_RADIX_TREE(&blkcg->blkg_tree, GFP_ATOMIC);
 	INIT_HLIST_HEAD(&blkcg->blkg_list);
-
+#ifdef CONFIG_CGROUP_WRITEBACK
+	INIT_LIST_HEAD(&blkcg->cgwb_list);
+#endif
 	return &blkcg->css;
 }
 
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 34d1cb8..99a2440 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -185,11 +185,11 @@ void bdi_start_background_writeback(struct backing_dev_info *bdi)
  */
 void inode_wb_list_del(struct inode *inode)
 {
-	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct bdi_writeback *wb = inode_to_wb(inode);
 
-	spin_lock(&bdi->wb.list_lock);
+	spin_lock(&wb->list_lock);
 	list_del_init(&inode->i_wb_list);
-	spin_unlock(&bdi->wb.list_lock);
+	spin_unlock(&wb->list_lock);
 }
 
 /*
@@ -1268,6 +1268,8 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 	if ((inode->i_state & flags) != flags) {
 		const int was_dirty = inode->i_state & I_DIRTY;
 
+		inode_attach_wb(inode, NULL);
+
 		if (flags & I_DIRTY_INODE)
 			inode->i_state &= ~I_DIRTY_TIME;
 		inode->i_state |= flags;
diff --git a/fs/inode.c b/fs/inode.c
index ea37cd1..efc9eda 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -223,6 +223,7 @@ EXPORT_SYMBOL(free_inode_nonrcu);
 void __destroy_inode(struct inode *inode)
 {
 	BUG_ON(inode_has_buffers(inode));
+	inode_detach_wb(inode);
 	security_inode_free(inode);
 	fsnotify_inode_delete(inode);
 	locks_free_lock_context(inode->i_flctx);
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 9e9eafa..a1e9c40 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -2,8 +2,11 @@
 #define __LINUX_BACKING_DEV_DEFS_H
 
 #include <linux/list.h>
+#include <linux/radix-tree.h>
+#include <linux/rbtree.h>
 #include <linux/spinlock.h>
 #include <linux/percpu_counter.h>
+#include <linux/percpu-refcount.h>
 #include <linux/flex_proportions.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
@@ -37,10 +40,43 @@ enum wb_stat_item {
 
 #define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
 
+/*
+ * For cgroup writeback, multiple wb's may map to the same blkcg.  Those
+ * wb's can operate mostly independently but should share the congested
+ * state.  To facilitate such sharing, the congested state is tracked using
+ * the following struct which is created on demand, indexed by blkcg ID on
+ * its bdi, and refcounted.
+ */
 struct bdi_writeback_congested {
 	unsigned long state;		/* WB_[a]sync_congested flags */
+
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct backing_dev_info *bdi;	/* the associated bdi */
+	atomic_t refcnt;		/* nr of attached wb's and blkg */
+	int blkcg_id;			/* ID of the associated blkcg */
+	struct rb_node rb_node;		/* on bdi->cgwb_congestion_tree */
+#endif
 };
 
+/*
+ * Each wb (bdi_writeback) can perform writeback operations, is measured
+ * and throttled, independently.  Without cgroup writeback, each bdi
+ * (bdi_writeback) is served by its embedded bdi->wb.
+ *
+ * On the default hierarchy, blkcg implicitly enables memcg.  This allows
+ * using memcg's page ownership for attributing writeback IOs, and every
+ * memcg - blkcg combination can be served by its own wb by assigning a
+ * dedicated wb to each memcg, which enables isolation across different
+ * cgroups and propagation of IO back pressure down from the IO layer upto
+ * the tasks which are generating the dirty pages to be written back.
+ *
+ * A cgroup wb is indexed on its bdi by the ID of the associated memcg,
+ * refcounted with the number of inodes attached to it, and pins the memcg
+ * and the corresponding blkcg.  As the corresponding blkcg for a memcg may
+ * change as blkcg is disabled and enabled higher up in the hierarchy, a wb
+ * is tested for blkcg after lookup and removed from index on mismatch so
+ * that a new wb for the combination can be created.
+ */
 struct bdi_writeback {
 	struct backing_dev_info *bdi;	/* our parent bdi */
 
@@ -78,6 +114,19 @@ struct bdi_writeback {
 	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
 	struct list_head work_list;
 	struct delayed_work dwork;	/* work item used for writeback */
+
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct percpu_ref refcnt;	/* used only for !root wb's */
+	struct cgroup_subsys_state *memcg_css; /* the associated memcg */
+	struct cgroup_subsys_state *blkcg_css; /* and blkcg */
+	struct list_head memcg_node;	/* anchored at memcg->cgwb_list */
+	struct list_head blkcg_node;	/* anchored at blkcg->cgwb_list */
+
+	union {
+		struct work_struct release_work;
+		struct rcu_head rcu;
+	};
+#endif
 };
 
 struct backing_dev_info {
@@ -92,9 +141,13 @@ struct backing_dev_info {
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
 
-	struct bdi_writeback wb;  /* default writeback info for this bdi */
-	struct bdi_writeback_congested wb_congested;
-
+	struct bdi_writeback wb;  /* the root writeback info for this bdi */
+	struct bdi_writeback_congested wb_congested; /* its congested state */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct radix_tree_root cgwb_tree; /* radix tree of active cgroup wbs */
+	struct rb_root cgwb_congested_tree; /* their congested states */
+	atomic_t usage_cnt; /* counts both cgwbs and cgwb_contested's */
+#endif
 	struct device *dev;
 
 	struct timer_list laptop_mode_wb_timer;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 6bb3123..8ae59df 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -13,6 +13,7 @@
 #include <linux/sched.h>
 #include <linux/blkdev.h>
 #include <linux/writeback.h>
+#include <linux/blk-cgroup.h>
 #include <linux/backing-dev-defs.h>
 
 int __must_check bdi_init(struct backing_dev_info *bdi);
@@ -234,6 +235,16 @@ static inline int bdi_sched_wait(void *word)
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+struct bdi_writeback_congested *
+wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp);
+void wb_congested_put(struct bdi_writeback_congested *congested);
+struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
+				    struct cgroup_subsys_state *memcg_css,
+				    gfp_t gfp);
+void __inode_attach_wb(struct inode *inode, struct page *page);
+void wb_memcg_offline(struct mem_cgroup *memcg);
+void wb_blkcg_offline(struct blkcg *blkcg);
+
 /**
  * inode_cgwb_enabled - test whether cgroup writeback is enabled on an inode
  * @inode: inode of interest
@@ -250,6 +261,135 @@ static inline bool inode_cgwb_enabled(struct inode *inode)
 		(inode->i_sb->s_type->fs_flags & FS_CGROUP_WRITEBACK);
 }
 
+/**
+ * wb_tryget - try to increment a wb's refcount
+ * @wb: bdi_writeback to get
+ */
+static inline bool wb_tryget(struct bdi_writeback *wb)
+{
+	if (wb != &wb->bdi->wb)
+		return percpu_ref_tryget(&wb->refcnt);
+	return true;
+}
+
+/**
+ * wb_get - increment a wb's refcount
+ * @wb: bdi_writeback to get
+ */
+static inline void wb_get(struct bdi_writeback *wb)
+{
+	if (wb != &wb->bdi->wb)
+		percpu_ref_get(&wb->refcnt);
+}
+
+/**
+ * wb_put - decrement a wb's refcount
+ * @wb: bdi_writeback to put
+ */
+static inline void wb_put(struct bdi_writeback *wb)
+{
+	if (wb != &wb->bdi->wb)
+		percpu_ref_put(&wb->refcnt);
+}
+
+/**
+ * wb_find_current - find wb for %current on a bdi
+ * @bdi: bdi of interest
+ *
+ * Find the wb of @bdi which matches both the memcg and blkcg of %current.
+ * Must be called under rcu_read_lock() which protects the returend wb.
+ * NULL if not found.
+ */
+static inline struct bdi_writeback *wb_find_current(struct backing_dev_info *bdi)
+{
+	struct cgroup_subsys_state *memcg_css;
+	struct bdi_writeback *wb;
+
+	memcg_css = task_css(current, memory_cgrp_id);
+	if (!memcg_css->parent)
+		return &bdi->wb;
+
+	wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
+
+	/*
+	 * %current's blkcg equals the effective blkcg of its memcg.  No
+	 * need to use the relatively expensive cgroup_get_e_css().
+	 */
+	if (likely(wb && wb->blkcg_css == task_css(current, blkio_cgrp_id)))
+		return wb;
+	return NULL;
+}
+
+/**
+ * wb_get_create_current - get or create wb for %current on a bdi
+ * @bdi: bdi of interest
+ * @gfp: allocation mask
+ *
+ * Equivalent to wb_get_create() on %current's memcg.  This function is
+ * called from a relatively hot path and optimizes the common cases using
+ * wb_find_current().
+ */
+static inline struct bdi_writeback *
+wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
+{
+	struct bdi_writeback *wb;
+
+	rcu_read_lock();
+	wb = wb_find_current(bdi);
+	if (wb && unlikely(!wb_tryget(wb)))
+		wb = NULL;
+	rcu_read_unlock();
+
+	if (unlikely(!wb)) {
+		struct cgroup_subsys_state *memcg_css;
+
+		memcg_css = task_get_css(current, memory_cgrp_id);
+		wb = wb_get_create(bdi, memcg_css, gfp);
+		css_put(memcg_css);
+	}
+	return wb;
+}
+
+/**
+ * inode_attach_wb - associate an inode with its wb
+ * @inode: inode of interest
+ * @page: page being dirtied (may be NULL)
+ *
+ * If @inode doesn't have its wb, associate it with the wb matching the
+ * memcg of @page or, if @page is NULL, %current.  May be called w/ or w/o
+ * @inode->i_lock.
+ */
+static inline void inode_attach_wb(struct inode *inode, struct page *page)
+{
+	if (!inode->i_wb)
+		__inode_attach_wb(inode, page);
+}
+
+/**
+ * inode_detach_wb - disassociate an inode from its wb
+ * @inode: inode of interest
+ *
+ * @inode is being freed.  Detach from its wb.
+ */
+static inline void inode_detach_wb(struct inode *inode)
+{
+	if (inode->i_wb) {
+		wb_put(inode->i_wb);
+		inode->i_wb = NULL;
+	}
+}
+
+/**
+ * inode_to_wb - determine the wb of an inode
+ * @inode: inode of interest
+ *
+ * Returns the wb @inode is currently associated with.
+ */
+static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
+{
+	return inode->i_wb;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline bool inode_cgwb_enabled(struct inode *inode)
@@ -257,6 +397,61 @@ static inline bool inode_cgwb_enabled(struct inode *inode)
 	return false;
 }
 
+static inline struct bdi_writeback_congested *
+wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
+{
+	return bdi->wb.congested;
+}
+
+static inline void wb_congested_put(struct bdi_writeback_congested *congested)
+{
+}
+
+static inline bool wb_tryget(struct bdi_writeback *wb)
+{
+	return true;
+}
+
+static inline void wb_get(struct bdi_writeback *wb)
+{
+}
+
+static inline void wb_put(struct bdi_writeback *wb)
+{
+}
+
+static inline struct bdi_writeback *wb_find_current(struct backing_dev_info *bdi)
+{
+	return &bdi->wb;
+}
+
+static inline struct bdi_writeback *
+wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
+{
+	return &bdi->wb;
+}
+
+static inline void inode_attach_wb(struct inode *inode, struct page *page)
+{
+}
+
+static inline void inode_detach_wb(struct inode *inode)
+{
+}
+
+static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
+{
+	return &inode_to_bdi(inode)->wb;
+}
+
+static inline void wb_memcg_offline(struct mem_cgroup *memcg)
+{
+}
+
+static inline void wb_blkcg_offline(struct blkcg *blkcg)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 #endif	/* _LINUX_BACKING_DEV_H */
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
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 74e0ae0..67a42ec 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -35,6 +35,7 @@
 #include <uapi/linux/fs.h>
 
 struct backing_dev_info;
+struct bdi_writeback;
 struct export_operations;
 struct hd_geometry;
 struct iovec;
@@ -635,6 +636,9 @@ struct inode {
 
 	struct hlist_node	i_hash;
 	struct list_head	i_wb_list;	/* backing dev IO list */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct bdi_writeback	*i_wb;		/* the associated cgroup wb */
+#endif
 	struct list_head	i_lru;		/* inode LRU list */
 	struct list_head	i_sb_list;
 	union {
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 637ef62..662a953 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -388,6 +388,10 @@ enum {
 	OVER_LIMIT,
 };
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg);
+#endif
+
 struct sock;
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 void sock_update_memcg(struct sock *sk);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 5ec7658..4c9386c 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -368,6 +368,401 @@ static void wb_exit(struct bdi_writeback *wb)
 	fprop_local_destroy_percpu(&wb->completions);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+#include <linux/memcontrol.h>
+
+/*
+ * cgwb_lock protects bdi->cgwb_tree, bdi->cgwb_congested_tree,
+ * blkcg->cgwb_list, and memcg->cgwb_list.  bdi->cgwb_tree is also RCU
+ * protected.  cgwb_release_wait is used to wait for the completion of cgwb
+ * releases from bdi destruction path.
+ */
+static DEFINE_SPINLOCK(cgwb_lock);
+static DECLARE_WAIT_QUEUE_HEAD(cgwb_release_wait);
+
+/**
+ * wb_congested_get_create - get or create a wb_congested
+ * @bdi: associated bdi
+ * @blkcg_id: ID of the associated blkcg
+ * @gfp: allocation mask
+ *
+ * Look up the wb_congested for @blkcg_id on @bdi.  If missing, create one.
+ * The returned wb_congested has its reference count incremented.  Returns
+ * NULL on failure.
+ */
+struct bdi_writeback_congested *
+wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
+{
+	struct bdi_writeback_congested *new_congested = NULL, *congested;
+	struct rb_node **node, *parent;
+	unsigned long flags;
+
+	if (blkcg_id == 1)
+		return &bdi->wb_congested;
+retry:
+	spin_lock_irqsave(&cgwb_lock, flags);
+
+	node = &bdi->cgwb_congested_tree.rb_node;
+	parent = NULL;
+
+	while (*node != NULL) {
+		parent = *node;
+		congested = container_of(parent, struct bdi_writeback_congested,
+					 rb_node);
+		if (congested->blkcg_id < blkcg_id)
+			node = &parent->rb_left;
+		else if (congested->blkcg_id > blkcg_id)
+			node = &parent->rb_right;
+		else
+			goto found;
+	}
+
+	if (new_congested) {
+		/* !found and storage for new one already allocated, insert */
+		congested = new_congested;
+		new_congested = NULL;
+		rb_link_node(&congested->rb_node, parent, node);
+		rb_insert_color(&congested->rb_node, &bdi->cgwb_congested_tree);
+		atomic_inc(&bdi->usage_cnt);
+		goto found;
+	}
+
+	spin_unlock_irqrestore(&cgwb_lock, flags);
+
+	/* allocate storage for new one and retry */
+	new_congested = kzalloc(sizeof(*new_congested), gfp);
+	if (!new_congested)
+		return NULL;
+
+	atomic_set(&new_congested->refcnt, 0);
+	new_congested->bdi = bdi;
+	new_congested->blkcg_id = blkcg_id;
+	goto retry;
+
+found:
+	atomic_inc(&congested->refcnt);
+	spin_unlock_irqrestore(&cgwb_lock, flags);
+	kfree(new_congested);
+	return congested;
+}
+
+/**
+ * wb_congested_put - put a wb_congested
+ * @congested: wb_congested to put
+ *
+ * Put @congested and destroy it if the refcnt reaches zero.
+ */
+void wb_congested_put(struct bdi_writeback_congested *congested)
+{
+	struct backing_dev_info *bdi = congested->bdi;
+	unsigned long flags;
+
+	if (congested->blkcg_id == 1)
+		return;
+
+	local_irq_save(flags);
+	if (!atomic_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
+		local_irq_restore(flags);
+		return;
+	}
+
+	rb_erase(&congested->rb_node, &congested->bdi->cgwb_congested_tree);
+	spin_unlock_irqrestore(&cgwb_lock, flags);
+	kfree(congested);
+
+	if (atomic_dec_and_test(&bdi->usage_cnt))
+		wake_up_all(&cgwb_release_wait);
+}
+
+static void cgwb_release_workfn(struct work_struct *work)
+{
+	struct bdi_writeback *wb = container_of(work, struct bdi_writeback,
+						release_work);
+	struct backing_dev_info *bdi = wb->bdi;
+
+	wb_shutdown(wb);
+
+	css_put(wb->memcg_css);
+	css_put(wb->blkcg_css);
+	wb_congested_put(wb->congested);
+
+	percpu_ref_exit(&wb->refcnt);
+	wb_exit(wb);
+	kfree_rcu(wb, rcu);
+
+	if (atomic_dec_and_test(&bdi->usage_cnt))
+		wake_up_all(&cgwb_release_wait);
+}
+
+static void cgwb_release(struct percpu_ref *refcnt)
+{
+	struct bdi_writeback *wb = container_of(refcnt, struct bdi_writeback,
+						refcnt);
+	schedule_work(&wb->release_work);
+}
+
+static void cgwb_kill(struct bdi_writeback *wb)
+{
+	lockdep_assert_held(&cgwb_lock);
+
+	WARN_ON(!radix_tree_delete(&wb->bdi->cgwb_tree, wb->memcg_css->id));
+	list_del(&wb->memcg_node);
+	list_del(&wb->blkcg_node);
+	percpu_ref_kill(&wb->refcnt);
+}
+
+static int cgwb_create(struct backing_dev_info *bdi,
+		       struct cgroup_subsys_state *memcg_css, gfp_t gfp)
+{
+	struct mem_cgroup *memcg;
+	struct cgroup_subsys_state *blkcg_css;
+	struct blkcg *blkcg;
+	struct list_head *memcg_cgwb_list, *blkcg_cgwb_list;
+	struct bdi_writeback *wb;
+	unsigned long flags;
+	int ret = 0;
+
+	memcg = mem_cgroup_from_css(memcg_css);
+	blkcg_css = cgroup_get_e_css(memcg_css->cgroup, &blkio_cgrp_subsys);
+	blkcg = css_to_blkcg(blkcg_css);
+	memcg_cgwb_list = mem_cgroup_cgwb_list(memcg);
+	blkcg_cgwb_list = &blkcg->cgwb_list;
+
+	/* look up again under lock and discard on blkcg mismatch */
+	spin_lock_irqsave(&cgwb_lock, flags);
+	wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
+	if (wb && wb->blkcg_css != blkcg_css) {
+		cgwb_kill(wb);
+		wb = NULL;
+	}
+	spin_unlock_irqrestore(&cgwb_lock, flags);
+	if (wb)
+		goto out_put;
+
+	/* need to create a new one */
+	wb = kmalloc(sizeof(*wb), gfp);
+	if (!wb)
+		return -ENOMEM;
+
+	ret = wb_init(wb, bdi, gfp);
+	if (ret)
+		goto err_free;
+
+	ret = percpu_ref_init(&wb->refcnt, cgwb_release, 0, gfp);
+	if (ret)
+		goto err_wb_exit;
+
+	wb->congested = wb_congested_get_create(bdi, blkcg_css->id, gfp);
+	if (!wb->congested)
+		goto err_ref_exit;
+
+	wb->memcg_css = memcg_css;
+	wb->blkcg_css = blkcg_css;
+	INIT_WORK(&wb->release_work, cgwb_release_workfn);
+	set_bit(WB_registered, &wb->state);
+
+	/*
+	 * The root wb determines the registered state of the whole bdi and
+	 * memcg_cgwb_list and blkcg_cgwb_list's next pointers indicate
+	 * whether they're still online.  Don't link @wb if any is dead.
+	 * See wb_memcg_offline() and wb_blkcg_offline().
+	 */
+	ret = -ENODEV;
+	spin_lock_irqsave(&cgwb_lock, flags);
+	if (test_bit(WB_registered, &bdi->wb.state) &&
+	    blkcg_cgwb_list->next && memcg_cgwb_list->next) {
+		/* we might have raced another instance of this function */
+		ret = radix_tree_insert(&bdi->cgwb_tree, memcg_css->id, wb);
+		if (!ret) {
+			atomic_inc(&bdi->usage_cnt);
+			list_add(&wb->memcg_node, memcg_cgwb_list);
+			list_add(&wb->blkcg_node, blkcg_cgwb_list);
+			css_get(memcg_css);
+			css_get(blkcg_css);
+		}
+	}
+	spin_unlock_irqrestore(&cgwb_lock, flags);
+	if (ret) {
+		if (ret == -EEXIST)
+			ret = 0;
+		goto err_put_congested;
+	}
+	goto out_put;
+
+err_put_congested:
+	wb_congested_put(wb->congested);
+err_ref_exit:
+	percpu_ref_exit(&wb->refcnt);
+err_wb_exit:
+	wb_exit(wb);
+err_free:
+	kfree(wb);
+out_put:
+	css_put(blkcg_css);
+	return ret;
+}
+
+/**
+ * wb_get_create - get wb for a given memcg, create if necessary
+ * @bdi: target bdi
+ * @memcg_css: cgroup_subsys_state of the target memcg (must have positive ref)
+ * @gfp: allocation mask to use
+ *
+ * Try to get the wb for @memcg_css on @bdi.  If it doesn't exist, try to
+ * create one.  The returned wb has its refcount incremented.
+ *
+ * This function uses css_get() on @memcg_css and thus expects its refcnt
+ * to be positive on invocation.  IOW, rcu_read_lock() protection on
+ * @memcg_css isn't enough.  try_get it before calling this function.
+ *
+ * A wb is keyed by its associated memcg.  As blkcg implicitly enables
+ * memcg on the default hierarchy, memcg association is guaranteed to be
+ * more specific (equal or descendant to the associated blkcg) and thus can
+ * identify both the memcg and blkcg associations.
+ *
+ * Because the blkcg associated with a memcg may change as blkcg is enabled
+ * and disabled closer to root in the hierarchy, each wb keeps track of
+ * both the memcg and blkcg associated with it and verifies the blkcg on
+ * each lookup.  On mismatch, the existing wb is discarded and a new one is
+ * created.
+ */
+struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
+				    struct cgroup_subsys_state *memcg_css,
+				    gfp_t gfp)
+{
+	struct bdi_writeback *wb;
+
+	might_sleep_if(gfp & __GFP_WAIT);
+
+	if (!memcg_css->parent)
+		return &bdi->wb;
+
+	do {
+		rcu_read_lock();
+		wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
+		if (wb) {
+			struct cgroup_subsys_state *blkcg_css;
+
+			/* see whether the blkcg association has changed */
+			blkcg_css = cgroup_get_e_css(memcg_css->cgroup,
+						     &blkio_cgrp_subsys);
+			if (unlikely(wb->blkcg_css != blkcg_css ||
+				     !wb_tryget(wb)))
+				wb = NULL;
+			css_put(blkcg_css);
+		}
+		rcu_read_unlock();
+	} while (!wb && !cgwb_create(bdi, memcg_css, gfp));
+
+	return wb;
+}
+
+void __inode_attach_wb(struct inode *inode, struct page *page)
+{
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct bdi_writeback *wb = NULL;
+
+	if (inode_cgwb_enabled(inode)) {
+		struct cgroup_subsys_state *memcg_css;
+
+		if (page) {
+			memcg_css = mem_cgroup_css_from_page(page);
+			wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
+		} else {
+			/* must pin memcg_css, see wb_get_create() */
+			memcg_css = task_get_css(current, memory_cgrp_id);
+			wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
+			css_put(memcg_css);
+		}
+	}
+
+	if (!wb)
+		wb = &bdi->wb;
+
+	/*
+	 * There may be multiple instances of this function racing to
+	 * update the same inode.  Use cmpxchg() to tell the winner.
+	 */
+	if (unlikely(cmpxchg(&inode->i_wb, NULL, wb)))
+		wb_put(wb);
+}
+
+static void cgwb_bdi_init(struct backing_dev_info *bdi)
+{
+	bdi->wb.memcg_css = mem_cgroup_root_css;
+	bdi->wb.blkcg_css = blkcg_root_css;
+	bdi->wb_congested.blkcg_id = 1;
+	INIT_RADIX_TREE(&bdi->cgwb_tree, GFP_ATOMIC);
+	bdi->cgwb_congested_tree = RB_ROOT;
+	atomic_set(&bdi->usage_cnt, 1);
+}
+
+static void cgwb_bdi_destroy(struct backing_dev_info *bdi)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+
+	WARN_ON(test_bit(WB_registered, &bdi->wb.state));
+
+	spin_lock_irq(&cgwb_lock);
+	radix_tree_for_each_slot(slot, &bdi->cgwb_tree, &iter, 0)
+		cgwb_kill(*slot);
+	spin_unlock_irq(&cgwb_lock);
+
+	/*
+	 * All cgwb's and their congested states must be shutdown and
+	 * released before returning.  Drain the usage counter to wait for
+	 * all cgwb's and cgwb_congested's ever created on @bdi.
+	 */
+	atomic_dec(&bdi->usage_cnt);
+	wait_event(cgwb_release_wait, !atomic_read(&bdi->usage_cnt));
+}
+
+/**
+ * wb_memcg_offline - kill all wb's associated with a memcg being offlined
+ * @memcg: memcg being offlined
+ *
+ * Also prevents creation of any new wb's associated with @memcg.
+ */
+void wb_memcg_offline(struct mem_cgroup *memcg)
+{
+	LIST_HEAD(to_destroy);
+	struct list_head *memcg_cgwb_list = mem_cgroup_cgwb_list(memcg);
+	struct bdi_writeback *wb, *next;
+
+	spin_lock_irq(&cgwb_lock);
+	list_for_each_entry_safe(wb, next, memcg_cgwb_list, memcg_node)
+		cgwb_kill(wb);
+	memcg_cgwb_list->next = NULL;	/* prevent new wb's */
+	spin_unlock_irq(&cgwb_lock);
+}
+
+/**
+ * wb_blkcg_offline - kill all wb's associated with a blkcg being offlined
+ * @blkcg: blkcg being offlined
+ *
+ * Also prevents creation of any new wb's associated with @blkcg.
+ */
+void wb_blkcg_offline(struct blkcg *blkcg)
+{
+	LIST_HEAD(to_destroy);
+	struct bdi_writeback *wb, *next;
+
+	spin_lock_irq(&cgwb_lock);
+	list_for_each_entry_safe(wb, next, &blkcg->cgwb_list, blkcg_node)
+		cgwb_kill(wb);
+	blkcg->cgwb_list.next = NULL;	/* prevent new wb's */
+	spin_unlock_irq(&cgwb_lock);
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static void cgwb_bdi_init(struct backing_dev_info *bdi) { }
+static void cgwb_bdi_destroy(struct backing_dev_info *bdi) { }
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 int bdi_init(struct backing_dev_info *bdi)
 {
 	int err;
@@ -386,6 +781,7 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->wb_congested.state = 0;
 	bdi->wb.congested = &bdi->wb_congested;
 
+	cgwb_bdi_init(bdi);
 	return 0;
 }
 EXPORT_SYMBOL(bdi_init);
@@ -459,6 +855,7 @@ void bdi_destroy(struct backing_dev_info *bdi)
 	/* make sure nobody finds us on the bdi_list anymore */
 	bdi_remove_from_list(bdi);
 	wb_shutdown(&bdi->wb);
+	cgwb_bdi_destroy(bdi);
 
 	if (bdi->dev) {
 		bdi_debug_unregister(bdi);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 763f8f3..6732c2c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -348,6 +348,10 @@ struct mem_cgroup {
 	atomic_t	numainfo_updating;
 #endif
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct list_head cgwb_list;
+#endif
+
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -4011,6 +4015,15 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 }
 #endif
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg)
+{
+	return &memcg->cgwb_list;
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 /*
  * DO NOT USE IN NEW FILES.
  *
@@ -4475,7 +4488,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_MEMCG_KMEM
 	memcg->kmemcg_id = -1;
 #endif
-
+#ifdef CONFIG_CGROUP_WRITEBACK
+	INIT_LIST_HEAD(&memcg->cgwb_list);
+#endif
 	return &memcg->css;
 
 free_out:
@@ -4563,6 +4578,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	vmpressure_cleanup(&memcg->vmpressure);
 
 	memcg_deactivate_kmem(memcg);
+
+	wb_memcg_offline(memcg);
 }
 
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 78ef551..9b95cf8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2097,16 +2097,21 @@ int __set_page_dirty_no_writeback(struct page *page)
 void account_page_dirtied(struct page *page, struct address_space *mapping,
 			  struct mem_cgroup *memcg)
 {
+	struct inode *inode = mapping->host;
+
 	trace_writeback_dirty_page(page, mapping);
 
 	if (mapping_cap_account_dirty(mapping)) {
-		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+		struct bdi_writeback *wb;
+
+		inode_attach_wb(inode, page);
+		wb = inode_to_wb(inode);
 
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
-		__inc_wb_stat(&bdi->wb, WB_RECLAIMABLE);
-		__inc_wb_stat(&bdi->wb, WB_DIRTIED);
+		__inc_wb_stat(wb, WB_RECLAIMABLE);
+		__inc_wb_stat(wb, WB_DIRTIED);
 		task_io_account_write(PAGE_CACHE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
