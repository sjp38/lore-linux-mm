Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAEE6B02BD
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:36:41 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so23607271qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:36:40 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id 137si2131512qhc.74.2015.05.22.15.36.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:36:40 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so23588773qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:36:40 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/9] writeback: add lockdep annotation to inode_to_wb()
Date: Fri, 22 May 2015 18:36:21 -0400
Message-Id: <1432334183-6324-8-git-send-email-tj@kernel.org>
In-Reply-To: <1432334183-6324-1-git-send-email-tj@kernel.org>
References: <1432334183-6324-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

With the previous three patches, all operations which acquire wb from
inode are either under one of inode->i_lock, mapping->tree_lock or
wb->list_lock or protected by unlocked_inode_to_wb transaction.  This
will be depended upon by foreign inode wb switching.

This patch adds lockdep assertion to inode_to_wb() so that usages
outside the above list locks can be caught easily.  There are three
exceptions.

* locked_inode_to_wb_and_lock_list() is holding wb->list_lock but the
  wb may not be the inode's.  Ensuring that is the function's role
  after all.  Updated to deref inode->i_wb directly.

* inode_wb_stat_unlocked_begin() is usually protected by combination
  of !I_WB_SWITCH and rcu_read_lock().  Updated to deref inode->i_wb
  directly.

* inode_congested() wants to test whether inode->i_wb is set before
  starting the transaction.  Added inode_to_wb_is_valid() which tests
  inode->i_wb directly.

v4: might_lock() added to unlocked_inode_to_wb_begin().

v3: inode_congested() conversion added.

v2: locked_inode_to_wb_and_lock_list() was missing in the first
    version.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c           |  5 +++--
 include/linux/backing-dev.h | 36 ++++++++++++++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index eb94b00..e468073 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -285,7 +285,8 @@ locked_inode_to_wb_and_lock_list(struct inode *inode)
 		spin_lock(&wb->list_lock);
 		wb_put(wb);		/* not gonna deref it anymore */
 
-		if (likely(wb == inode_to_wb(inode)))
+		/* i_wb may have changed inbetween, can't use inode_to_wb() */
+		if (likely(wb == inode->i_wb))
 			return wb;	/* @inode already has ref */
 
 		spin_unlock(&wb->list_lock);
@@ -613,7 +614,7 @@ int inode_congested(struct inode *inode, int cong_bits)
 	 * Once set, ->i_wb never becomes NULL while the inode is alive.
 	 * Start transaction iff ->i_wb is visible.
 	 */
-	if (inode && inode_to_wb(inode)) {
+	if (inode && inode_to_wb_is_valid(inode)) {
 		struct bdi_writeback *wb;
 		bool locked, congested;
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 73ffa32..7aaebb9 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -322,13 +322,33 @@ wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
 }
 
 /**
+ * inode_to_wb_is_valid - test whether an inode has a wb associated
+ * @inode: inode of interest
+ *
+ * Returns %true if @inode has a wb associated.  May be called without any
+ * locking.
+ */
+static inline bool inode_to_wb_is_valid(struct inode *inode)
+{
+	return inode->i_wb;
+}
+
+/**
  * inode_to_wb - determine the wb of an inode
  * @inode: inode of interest
  *
- * Returns the wb @inode is currently associated with.
+ * Returns the wb @inode is currently associated with.  The caller must be
+ * holding either @inode->i_lock, @inode->i_mapping->tree_lock, or the
+ * associated wb's list_lock.
  */
 static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 {
+#ifdef CONFIG_LOCKDEP
+	WARN_ON_ONCE(debug_locks &&
+		     (!lockdep_is_held(&inode->i_lock) &&
+		      !lockdep_is_held(&inode->i_mapping->tree_lock) &&
+		      !lockdep_is_held(&inode->i_wb->list_lock)));
+#endif
 	return inode->i_wb;
 }
 
@@ -350,6 +370,8 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 static inline struct bdi_writeback *
 unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
 {
+	might_lock(&inode->i_mapping->tree_lock);
+
 	rcu_read_lock();
 
 	/*
@@ -360,7 +382,12 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
 
 	if (unlikely(*lockedp))
 		spin_lock_irq(&inode->i_mapping->tree_lock);
-	return inode_to_wb(inode);
+
+	/*
+	 * Protected by either !I_WB_SWITCH + rcu_read_lock() or tree_lock.
+	 * inode_to_wb() will bark.  Deref directly.
+	 */
+	return inode->i_wb;
 }
 
 /**
@@ -459,6 +486,11 @@ wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
 	return &bdi->wb;
 }
 
+static inline bool inode_to_wb_is_valid(struct inode *inode)
+{
+	return true;
+}
+
 static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 {
 	return &inode_to_bdi(inode)->wb;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
