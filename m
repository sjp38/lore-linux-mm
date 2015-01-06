Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 78B1A6B0167
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:32 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id i17so61167qcy.35
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:32 -0800 (PST)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id c79si15821387qge.26.2015.01.06.13.27.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:31 -0800 (PST)
Received: by mail-qg0-f53.google.com with SMTP id l89so54020qgf.40
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:31 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 34/45] vfs, writeback: implement support for multiple inode_wb_link's
Date: Tue,  6 Jan 2015 16:26:11 -0500
Message-Id: <1420579582-8516-35-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

An inode may be written to from more than one cgroups and for cgroup
writeback support to work properly the inode needs to be on the dirty
lists of all wb's (bdi_writeback's) corresponding to the dirtying
cgroups so that writeback on each cgroup can keep track of and process
the inode.

The previous patches separated out iwbl (inode_wb_link which) is used
to dirty an inode against a wb (bdi_writeback).  Currently, there's
only one embedded iwbl per inode which can be used to dirty the inode
against the root wb.  This patch introduces icgwbl (inode_cgwb_link)
which includes iwbl and can be used to link an inode to a non-root
cgroup wb.

Each icgwbl points to the associated inode directly and wb through its
iwbl, and is linked on inode->i_cgwb_links and wb->icgwbls.  They're
created on demand and destroyed only when either the associated inode
or wb is destroyed.  When a page is about to be dirtied, the matching
i[cg]wbl is looked up or created and recorded in the newly added
dirty_context->iwbl field.  The next patch will use the field to link
inodes against their matching cgroup wb's.

Currently, icgwbls are linked on a linked list on each inode and
linearly looked up on each dirtying attempt, which is an obvious
scalability bottleneck.  We want an RCU-safe balanced tree here but
the kernel doesn't have such indexing structure in tree yet.  Given
that dirtying the same inode from numerous different cgroups isn't too
frequent, I think the linear list is a bandaid we can use for now but
we really should switch to something proper (e.g. a bonsai tree) soon.

This patch adds a struct hlist_head to struct inode when
CONFIG_CGROUP_WRITEBACK adding the size of a pointer to it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 121 ++++++++++++++++++++++++++++++++++-----
 fs/inode.c                       |   3 +
 include/linux/backing-dev-defs.h |  34 +++++++++++
 include/linux/backing-dev.h      |  77 +++++++++++++++++++++++--
 include/linux/fs.h               |   3 +
 mm/backing-dev.c                 |  80 ++++++++++++++++++++++++++
 6 files changed, 300 insertions(+), 18 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index ab77ed2..d10c231 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -182,6 +182,18 @@ static void iwbl_del_locked(struct inode_wb_link *iwbl,
 	}
 }
 
+static void iwbl_del(struct inode_wb_link *iwbl)
+{
+	struct bdi_writeback *wb = iwbl_to_wb(iwbl);
+
+	if (list_empty(&iwbl->dirty_list))
+		return;
+
+	spin_lock(&wb->list_lock);
+	iwbl_del_locked(iwbl, wb);
+	spin_unlock(&wb->list_lock);
+}
+
 /*
  * Wait for writeback on an inode to complete. Called with i_lock held.
  * Caller must make sure inode cannot go away when we drop i_lock.
@@ -260,16 +272,34 @@ static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
 	 * back to the root blkcg.
 	 */
 	blkcg_css = page_blkcg_attach_dirty(dctx->page);
-	dctx->wb = cgwb_lookup_create(bdi, blkcg_css);
-	if (!dctx->wb) {
-		page_blkcg_detach_dirty(dctx->page);
-		goto force_root;
+
+	/* if iwbl already exists, wb can be determined from that too */
+	dctx->iwbl = iwbl_lookup(dctx->inode, blkcg_css);
+	if (dctx->iwbl) {
+		dctx->wb = iwbl_to_wb(dctx->iwbl);
+		return;
 	}
+
+	/* slow path, let's create wb and iwbl */
+	dctx->wb = cgwb_lookup_create(bdi, blkcg_css);
+	if (!dctx->wb)
+		goto detach_dirty;
+
+	dctx->iwbl = iwbl_create(dctx->inode, dctx->wb);
+	if (!dctx->iwbl)
+		goto detach_dirty;
+
 	return;
 
+detach_dirty:
+	page_blkcg_detach_dirty(dctx->page);
 force_root:
 	page_blkcg_force_root_dirty(dctx->page);
 	dctx->wb = &bdi->wb;
+	if (dctx->inode)
+		dctx->iwbl = &dctx->inode->i_wb_link;
+	else
+		dctx->iwbl = NULL;
 }
 
 /**
@@ -420,11 +450,78 @@ static void inode_sleep_on_writeback(struct inode *inode)
 	finish_wait(wqh, &wait);
 }
 
+static inline struct inode_cgwb_link *icgwbl_first(struct inode *inode)
+{
+	struct hlist_node *node =
+		rcu_dereference_check(hlist_first_rcu(&inode->i_cgwb_links),
+			lockdep_is_held(&inode_to_bdi(inode)->icgwbls_lock));
+
+	return hlist_entry_safe(node, struct inode_cgwb_link, inode_node);
+}
+
+static inline struct inode_cgwb_link *icgwbl_next(struct inode_cgwb_link *pos,
+						  struct inode *inode)
+{
+	struct hlist_node *node =
+		rcu_dereference_check(hlist_next_rcu(&pos->inode_node),
+			lockdep_is_held(&inode_to_bdi(inode)->icgwbls_lock));
+
+	return hlist_entry_safe(node, struct inode_cgwb_link, inode_node);
+}
+
+/**
+ * inode_for_each_icgwbl - walk all icgwbl's of an inode
+ * @cur: cursor struct inode_cgwb_link pointer
+ * @nxt: temp struct inode_cgwb_link pointer
+ * @inode: inode to walk icgwbl's of
+ *
+ * Walk @inode's icgwbl's (inode_cgwb_link's).  rcu_read_lock() must be
+ * held throughout iteration.
+ */
+#define inode_for_each_icgwbl(cur, nxt, inode)				\
+	for ((cur) = icgwbl_first((inode)),				\
+	     (nxt) = (cur) ? icgwbl_next((cur), (inode)) : NULL;	\
+	     (cur);							\
+	     (cur) = (nxt),						\
+	     (nxt) = (nxt) ? icgwbl_next((nxt), (inode)) : NULL)
+
+static void inode_icgwbls_del(struct inode *inode)
+{
+	LIST_HEAD(to_free);
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct inode_cgwb_link *icgwbl, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bdi->icgwbls_lock, flags);
+
+	/* I_FREEING must be set here to disallow further iwbl_create() */
+	WARN_ON_ONCE(!(inode->i_state & I_FREEING));
+
+	/*
+	 * We don't wanna nest wb->list_lock under bdi->icgwbls_lock as the
+	 * latter is irq-safe and the former isn't.  Queue icgwbls on
+	 * @to_free and perform iwbl_del() and freeing after releasing
+	 * bdi->icgwbls_lock.
+	 */
+	inode_for_each_icgwbl(icgwbl, next, inode) {
+		hlist_del_rcu(&icgwbl->inode_node);
+		list_move(&icgwbl->wb_node, &to_free);
+	}
+
+	spin_unlock_irqrestore(&bdi->icgwbls_lock, flags);
+
+	list_for_each_entry_safe(icgwbl, next, &to_free, wb_node) {
+		iwbl_del(&icgwbl->iwbl);
+		kfree_rcu(icgwbl, rcu);
+	}
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
 {
 	dctx->wb = &dctx->mapping->backing_dev_info->wb;
+	dctx->iwbl = dctx->inode ? &dctx->inode->i_wb_link : NULL;
 }
 
 static long wb_split_bdi_pages(struct bdi_writeback *wb, long nr_pages)
@@ -467,6 +564,10 @@ static void inode_sleep_on_writeback(struct inode *inode)
 	finish_wait(wqh, &wait);
 }
 
+static void inode_icgwbls_del(struct inode *inode)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /**
@@ -510,6 +611,7 @@ void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode)
 	memset(dctx, 0, sizeof(*dctx));
 	dctx->inode = inode;
 	dctx->wb = &inode_to_bdi(inode)->wb;
+	dctx->iwbl = &inode->i_wb_link;
 }
 
 void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
@@ -565,15 +667,8 @@ void wb_start_background_writeback(struct bdi_writeback *wb)
  */
 void inode_wb_list_del(struct inode *inode)
 {
-	struct inode_wb_link *iwbl = &inode->i_wb_link;
-	struct bdi_writeback *wb = iwbl_to_wb(iwbl);
-
-	if (list_empty(&iwbl->dirty_list))
-		return;
-
-	spin_lock(&wb->list_lock);
-	iwbl_del_locked(iwbl, wb);
-	spin_unlock(&wb->list_lock);
+	iwbl_del(&inode->i_wb_link);
+	inode_icgwbls_del(inode);
 }
 
 /*
diff --git a/fs/inode.c b/fs/inode.c
index 66c9b68..8a55494 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -374,6 +374,9 @@ void inode_init_once(struct inode *inode)
 	INIT_LIST_HEAD(&inode->i_lru);
 	address_space_init_once(&inode->i_data);
 	i_size_ordered_init(inode);
+#ifdef CONFIG_CGROUP_WRITEBACK
+	INIT_HLIST_HEAD(&inode->i_cgwb_links);
+#endif
 #ifdef CONFIG_FSNOTIFY
 	INIT_HLIST_HEAD(&inode->i_fsnotify_marks);
 #endif
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 01f27e3..e448edc 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -99,6 +99,7 @@ struct bdi_writeback {
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct cgroup_subsys_state *blkcg_css; /* the blkcg we belong to */
 	struct list_head blkcg_node;	/* anchored at blkcg->wb_list */
+	struct list_head icgwbls;	/* inode_cgwb_links of this wb */
 	union {
 		struct list_head shutdown_node;
 		struct rcu_head rcu;
@@ -127,6 +128,7 @@ struct backing_dev_info {
 	struct bdi_writeback wb; /* the root writeback info for this bdi */
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct radix_tree_root cgwb_tree; /* radix tree of !root cgroup wbs */
+	spinlock_t icgwbls_lock; /* protects wb->icgwbls and inode->i_cgwb_links */
 #endif
 	wait_queue_head_t wb_waitq;
 
@@ -157,6 +159,37 @@ struct inode_wb_link {
 };
 
 /*
+ * Used to link a dirty inode on a non-root wb (bdi_writeback).  An inode
+ * may have multiple of these as it gets dirtied on non-root wb's.  Linked
+ * on both the inode and wb and destroyed when either goes away.
+ *
+ * TODO: When an inode is being dirtied against a non-root wb, its
+ * ->i_wb_link is searched linearly to locate the matching icgwbl
+ * (inode_cgwb_link).  The linear search is a scalability bottleneck but
+ * the kernel currently don't have an indexing data structure which would
+ * fit this use case.  A balanced tree which can be walked under RCU read
+ * lock is necessary (e.g. bonsai tree).  Once such indexing data structure
+ * is necessary, icgwbl should be converted to use that.
+ */
+struct inode_cgwb_link {
+	struct inode_wb_link	iwbl;
+
+	struct inode		*inode;		/* the associated inode */
+
+	/*
+	 * ->inode_node is anchored at inode->i_wb_links and ->wb_node at
+	 * bdi_writeback->icgwbls.  Both are write-protected by
+	 * bdi->icgwbls_lock but the former can be traversed under RCU and
+	 * is sorted by the associated blkcg ID to allow traversal
+	 * continuation after dropping RCU read lock.
+	 */
+	struct hlist_node	inode_node;	/* RCU-safe, sorted */
+	struct list_head	wb_node;
+
+	struct rcu_head		rcu;
+};
+
+/*
  * The following structure carries context used during page and inode
  * dirtying.  Should be initialized with init_dirty_{inode|page}_context().
  */
@@ -165,6 +198,7 @@ struct dirty_context {
 	struct inode		*inode;
 	struct address_space	*mapping;
 	struct bdi_writeback	*wb;
+	struct inode_wb_link	*iwbl;
 };
 
 enum {
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index bc69c7f..6c16d10 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -274,16 +274,13 @@ void init_dirty_page_context(struct dirty_context *dctx, struct page *page,
 			     struct address_space *mapping);
 void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode);
 
-static inline struct inode *iwbl_to_inode(struct inode_wb_link *iwbl)
-{
-	return container_of(iwbl, struct inode, i_wb_link);
-}
-
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css);
 int __cgwb_create(struct backing_dev_info *bdi,
 		  struct cgroup_subsys_state *blkcg_css);
+struct inode_wb_link *iwbl_create(struct inode *inode,
+				  struct bdi_writeback *wb);
 int mapping_congested(struct address_space *mapping, struct task_struct *task,
 		      int bdi_bits);
 
@@ -469,6 +466,60 @@ static inline struct bdi_writeback *iwbl_to_wb(struct inode_wb_link *iwbl)
 	return (void *)(iwbl->data & ~IWBL_FLAGS_MASK);
 }
 
+static inline bool iwbl_is_root(struct inode_wb_link *iwbl)
+{
+	struct bdi_writeback *wb = iwbl_to_wb(iwbl);
+
+	return wb->blkcg_css == blkcg_root_css;
+}
+
+static inline struct inode *iwbl_to_inode(struct inode_wb_link *iwbl)
+{
+	if (iwbl_is_root(iwbl)) {
+		return container_of(iwbl, struct inode, i_wb_link);
+	} else {
+		struct inode_cgwb_link *icgwbl =
+			container_of(iwbl, struct inode_cgwb_link, iwbl);
+		return icgwbl->inode;
+	}
+}
+
+/**
+ * iwbl_lookup - lookup iwbl for dirtying an inode against a blkcg_css
+ * @inode: target inode
+ * @blkcg_css: target blkcg_css
+ *
+ * Lookup iwbl (inode_wb_link) for dirtying @inode against @blkcg_css.  If
+ * found, the returned iwbl is associated with the bdi_writeback of
+ * @blkcg_css on @inode's bdi.  If not found, %NULL is returned.
+ *
+ * The returned iwbl remains accessible as long as both @inode and
+ * @blkcg_css are alive.
+ */
+static inline struct inode_wb_link *
+iwbl_lookup(struct inode *inode, struct cgroup_subsys_state *blkcg_css)
+{
+	struct inode_wb_link *iwbl = NULL;
+	struct inode_cgwb_link *icgwbl;
+
+	if (blkcg_css == blkcg_root_css)
+		return &inode->i_wb_link;
+
+	/*
+	 * RCU protects the lookup itself.  Once looked up, the iwbl's
+	 * lifetime is governed by those of @inode and @blkcg_css.
+	 */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(icgwbl, &inode->i_cgwb_links, inode_node) {
+		if (iwbl_to_wb(&icgwbl->iwbl)->blkcg_css == blkcg_css) {
+			iwbl = &icgwbl->iwbl;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return iwbl;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline bool mapping_cgwb_enabled(struct address_space *mapping)
@@ -522,6 +573,11 @@ static inline void init_i_wb_link(struct inode *inode)
 {
 }
 
+static inline struct inode *iwbl_to_inode(struct inode_wb_link *iwbl)
+{
+	return container_of(iwbl, struct inode, i_wb_link);
+}
+
 static inline struct bdi_writeback *iwbl_to_wb(struct inode_wb_link *iwbl)
 {
 	struct inode *inode = iwbl_to_inode(iwbl);
@@ -529,6 +585,17 @@ static inline struct bdi_writeback *iwbl_to_wb(struct inode_wb_link *iwbl)
 	return &inode_to_bdi(inode)->wb;
 }
 
+static inline bool iwbl_is_root(struct inode_wb_link *iwbl)
+{
+	return true;
+}
+
+static inline struct inode_wb_link *
+iwbl_lookup(struct inode *inode, struct cgroup_subsys_state *blkcg_css)
+{
+	return &inode->i_wb_link;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline int mapping_read_congested(struct address_space *mapping,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index fb261b4..b394821 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -609,6 +609,9 @@ struct inode {
 
 	struct hlist_node	i_hash;
 	struct inode_wb_link	i_wb_link;	/* backing dev IO list */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct hlist_head	i_cgwb_links;	/* sorted inode_cgwb_links */
+#endif
 	struct list_head	i_lru;		/* inode LRU list */
 	struct list_head	i_sb_list;
 	union {
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index cc8d21a..e4db465 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -464,6 +464,7 @@ int __cgwb_create(struct backing_dev_info *bdi,
 		return -ENOMEM;
 	}
 
+	INIT_LIST_HEAD(&wb->icgwbls);
 	wb->blkcg_css = blkcg_css;
 	set_bit(WB_registered, &wb->state); /* cgwbs are always registered */
 
@@ -532,16 +533,31 @@ static void cgwb_shutdown_commit(struct list_head *to_shutdown)
 
 static void cgwb_exit(struct bdi_writeback *wb)
 {
+	struct inode_cgwb_link *icgwbl, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&wb->bdi->icgwbls_lock, flags);
+	list_for_each_entry_safe(icgwbl, next, &wb->icgwbls, wb_node) {
+		WARN_ON_ONCE(!list_empty(&icgwbl->iwbl.dirty_list));
+		hlist_del_rcu(&icgwbl->inode_node);
+		list_del(&icgwbl->wb_node);
+		kfree_rcu(icgwbl, rcu);
+	}
+	spin_unlock_irqrestore(&wb->bdi->icgwbls_lock, flags);
+
 	WARN_ON(!radix_tree_delete(&wb->bdi->cgwb_tree, wb->blkcg_css->id));
 	list_del(&wb->blkcg_node);
+
 	wb_exit(wb);
 	kfree_rcu(wb, rcu);
 }
 
 static void cgwb_bdi_init(struct backing_dev_info *bdi)
 {
+	INIT_LIST_HEAD(&bdi->wb.icgwbls);
 	bdi->wb.blkcg_css = blkcg_root_css;
 	INIT_RADIX_TREE(&bdi->cgwb_tree, GFP_ATOMIC);
+	spin_lock_init(&bdi->icgwbls_lock);
 }
 
 /**
@@ -613,6 +629,70 @@ void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css)
 	spin_unlock_irq(&cgwb_lock);
 }
 
+/**
+ * iwbl_create - create an inode_cgwb_link
+ * @inode: target inode
+ * @wb: target bdi_writeback
+ *
+ * Try to create an iwbl (inode_wb_link) for dirtying @inode against @wb.
+ * This function can be called under any context without locking as long as
+ * @inode and @wb are kept alive.  See iwbl_lookup() for details.
+ *
+ * Returns the pointer to the created or found icgwbl on success, %NULL on
+ * failure.
+ */
+struct inode_wb_link *iwbl_create(struct inode *inode, struct bdi_writeback *wb)
+{
+	struct inode_wb_link *iwbl = NULL;
+	struct inode_cgwb_link *icgwbl;
+	unsigned long flags;
+
+	icgwbl = kzalloc(sizeof(*icgwbl), GFP_ATOMIC);
+	if (!icgwbl)
+		return NULL;
+
+	icgwbl->iwbl.data = (unsigned long)wb;
+	INIT_LIST_HEAD(&icgwbl->iwbl.dirty_list);
+	icgwbl->inode = inode;
+
+	spin_lock_irqsave(&wb->bdi->icgwbls_lock, flags);
+
+	/*
+	 * Testing I_FREEING under icgwbls_lock guarantees that no new
+	 * icgwbl's will be created after inode_icgwbls_del().
+	 */
+	if (inode->i_state & I_FREEING)
+		goto out_unlock;
+
+	iwbl = iwbl_lookup(inode, wb->blkcg_css);
+	if (!iwbl) {
+		struct inode_cgwb_link *prev = NULL, *pos;
+		int blkcg_id = wb->blkcg_css->id;
+
+		/* i_cgwb_links is sorted by blkcg ID */
+		hlist_for_each_entry_rcu(pos, &inode->i_cgwb_links, inode_node) {
+			if (iwbl_to_wb(&pos->iwbl)->blkcg_css->id > blkcg_id)
+				break;
+			prev = pos;
+		}
+		if (prev)
+			hlist_add_behind_rcu(&icgwbl->inode_node,
+					     &prev->inode_node);
+		else
+			hlist_add_head_rcu(&icgwbl->inode_node,
+					   &inode->i_cgwb_links);
+
+		list_add(&icgwbl->wb_node, &wb->icgwbls);
+
+		iwbl = &icgwbl->iwbl;
+		icgwbl = NULL;
+	}
+out_unlock:
+	spin_unlock_irqrestore(&wb->bdi->icgwbls_lock, flags);
+	kfree(icgwbl);
+	return iwbl;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void cgwb_bdi_init(struct backing_dev_info *bdi) { }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
