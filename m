Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id B1FA06B0073
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:51:13 -0400 (EDT)
Received: by qgf2 with SMTP id 2so20487905qgf.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:13 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id q5si3311515qce.7.2015.05.28.11.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:51:13 -0700 (PDT)
Received: by qgfa63 with SMTP id a63so20535363qgf.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:12 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/9] writeback: add lockdep annotation to inode_to_wb()
Date: Thu, 28 May 2015 14:50:55 -0400
Message-Id: <1432839057-17609-8-git-send-email-tj@kernel.org>
In-Reply-To: <1432839057-17609-1-git-send-email-tj@kernel.org>
References: <1432839057-17609-1-git-send-email-tj@kernel.org>
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

v5: might_lock() removed.  It annotates that the lock is grabbed w/
    irq enabled which isn't the case and triggering lockdep warning
    spuriously.

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
 include/linux/backing-dev.h | 34 ++++++++++++++++++++++++++++++++--
 2 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 25458fa..6b99dee 100644
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
@@ -622,7 +623,7 @@ int inode_congested(struct inode *inode, int cong_bits)
 	 * Once set, ->i_wb never becomes NULL while the inode is alive.
 	 * Start transaction iff ->i_wb is visible.
 	 */
-	if (inode && inode_to_wb(inode)) {
+	if (inode && inode_to_wb_is_valid(inode)) {
 		struct bdi_writeback *wb;
 		bool locked, congested;
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 73ffa32..dfce808 100644
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
 
@@ -360,7 +380,12 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
 
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
@@ -459,6 +484,11 @@ wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
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
