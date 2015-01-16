Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E17906B0078
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:13:36 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so22884487pdb.8
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:13:36 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cm5si5762714pad.14.2015.01.16.06.13.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:13:35 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 5/6] list_lru: add helpers to isolate items
Date: Fri, 16 Jan 2015 17:13:05 +0300
Message-ID: <7cd4d58c4559f9c1a324a496701c2e671d4e91b1.1421411660.git.vdavydov@parallels.com>
In-Reply-To: <cover.1421411660.git.vdavydov@parallels.com>
References: <cover.1421411660.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, the isolate callback passed to the list_lru_walk family of
functions is supposed to just delete an item from the list upon
returning LRU_REMOVED or LRU_REMOVED_RETRY, while nr_items counter is
fixed by __list_lru_walk_one after the callback returns. Since the
callback is allowed to drop the lock after removing an item (it has to
return LRU_REMOVED_RETRY then), the nr_items can be less than the actual
number of elements on the list even if we check them under the lock.
This makes it difficult to move items from one list_lru_one to another,
which is required for per-memcg list_lru reparenting - we can't just
splice the lists, we have to move entries one by one.

This patch therefore introduces helpers that must be used by callback
functions to isolate items instead of raw list_del/list_move. These are
list_lru_isolate and list_lru_isolate_move. They not only remove the
entry from the list, but also fix the nr_items counter, making sure
nr_items always reflects the actual number of elements on the list if
checked under the appropriate lock.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/dcache.c              |   21 +++++++++++----------
 fs/gfs2/quota.c          |    5 +++--
 fs/inode.c               |    8 ++++----
 fs/xfs/xfs_buf.c         |    6 ++++--
 fs/xfs/xfs_qm.c          |    5 +++--
 include/linux/list_lru.h |    9 +++++++--
 mm/list_lru.c            |   19 ++++++++++++++++---
 mm/workingset.c          |    3 ++-
 8 files changed, 50 insertions(+), 26 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 9d71d6d2478a..fc576d5341ee 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -400,19 +400,20 @@ static void d_shrink_add(struct dentry *dentry, struct list_head *list)
  * LRU lists entirely, while shrink_move moves it to the indicated
  * private list.
  */
-static void d_lru_isolate(struct dentry *dentry)
+static void d_lru_isolate(struct list_lru_one *lru, struct dentry *dentry)
 {
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
-	list_del_init(&dentry->d_lru);
+	list_lru_isolate(lru, &dentry->d_lru);
 }
 
-static void d_lru_shrink_move(struct dentry *dentry, struct list_head *list)
+static void d_lru_shrink_move(struct list_lru_one *lru, struct dentry *dentry,
+			      struct list_head *list)
 {
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags |= DCACHE_SHRINK_LIST;
-	list_move_tail(&dentry->d_lru, list);
+	list_lru_isolate_move(lru, &dentry->d_lru, list);
 }
 
 /*
@@ -869,8 +870,8 @@ static void shrink_dentry_list(struct list_head *list)
 	}
 }
 
-static enum lru_status
-dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
+static enum lru_status dentry_lru_isolate(struct list_head *item,
+		struct list_lru_one *lru, spinlock_t *lru_lock, void *arg)
 {
 	struct list_head *freeable = arg;
 	struct dentry	*dentry = container_of(item, struct dentry, d_lru);
@@ -890,7 +891,7 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 	 * another pass through the LRU.
 	 */
 	if (dentry->d_lockref.count) {
-		d_lru_isolate(dentry);
+		d_lru_isolate(lru, dentry);
 		spin_unlock(&dentry->d_lock);
 		return LRU_REMOVED;
 	}
@@ -921,7 +922,7 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 		return LRU_ROTATE;
 	}
 
-	d_lru_shrink_move(dentry, freeable);
+	d_lru_shrink_move(lru, dentry, freeable);
 	spin_unlock(&dentry->d_lock);
 
 	return LRU_REMOVED;
@@ -951,7 +952,7 @@ long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc)
 }
 
 static enum lru_status dentry_lru_isolate_shrink(struct list_head *item,
-						spinlock_t *lru_lock, void *arg)
+		struct list_lru_one *lru, spinlock_t *lru_lock, void *arg)
 {
 	struct list_head *freeable = arg;
 	struct dentry	*dentry = container_of(item, struct dentry, d_lru);
@@ -964,7 +965,7 @@ static enum lru_status dentry_lru_isolate_shrink(struct list_head *item,
 	if (!spin_trylock(&dentry->d_lock))
 		return LRU_SKIP;
 
-	d_lru_shrink_move(dentry, freeable);
+	d_lru_shrink_move(lru, dentry, freeable);
 	spin_unlock(&dentry->d_lock);
 
 	return LRU_REMOVED;
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 56db71d5c95f..5073da38cf06 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -145,7 +145,8 @@ static void gfs2_qd_dispose(struct list_head *list)
 }
 
 
-static enum lru_status gfs2_qd_isolate(struct list_head *item, spinlock_t *lock, void *arg)
+static enum lru_status gfs2_qd_isolate(struct list_head *item,
+		struct list_lru_one *lru, spinlock_t *lru_lock, void *arg)
 {
 	struct list_head *dispose = arg;
 	struct gfs2_quota_data *qd = list_entry(item, struct gfs2_quota_data, qd_lru);
@@ -155,7 +156,7 @@ static enum lru_status gfs2_qd_isolate(struct list_head *item, spinlock_t *lock,
 
 	if (qd->qd_lockref.count == 0) {
 		lockref_mark_dead(&qd->qd_lockref);
-		list_move(&qd->qd_lru, dispose);
+		list_lru_isolate_move(lru, &qd->qd_lru, dispose);
 	}
 
 	spin_unlock(&qd->qd_lockref.lock);
diff --git a/fs/inode.c b/fs/inode.c
index b80b17a09d36..198dbcd6554a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -684,8 +684,8 @@ int invalidate_inodes(struct super_block *sb, bool kill_dirty)
  * LRU does not have strict ordering. Hence we don't want to reclaim inodes
  * with this flag set because they are the inodes that are out of order.
  */
-static enum lru_status
-inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
+static enum lru_status inode_lru_isolate(struct list_head *item,
+		struct list_lru_one *lru, spinlock_t *lru_lock, void *arg)
 {
 	struct list_head *freeable = arg;
 	struct inode	*inode = container_of(item, struct inode, i_lru);
@@ -703,7 +703,7 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 	 */
 	if (atomic_read(&inode->i_count) ||
 	    (inode->i_state & ~I_REFERENCED)) {
-		list_del_init(&inode->i_lru);
+		list_lru_isolate(lru, &inode->i_lru);
 		spin_unlock(&inode->i_lock);
 		this_cpu_dec(nr_unused);
 		return LRU_REMOVED;
@@ -737,7 +737,7 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 
 	WARN_ON(inode->i_state & I_NEW);
 	inode->i_state |= I_FREEING;
-	list_move(&inode->i_lru, freeable);
+	list_lru_isolate_move(lru, &inode->i_lru, freeable);
 	spin_unlock(&inode->i_lock);
 
 	this_cpu_dec(nr_unused);
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 15c9d224c721..1790b00bea7a 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1488,6 +1488,7 @@ xfs_buf_iomove(
 static enum lru_status
 xfs_buftarg_wait_rele(
 	struct list_head	*item,
+	struct list_lru_one	*lru,
 	spinlock_t		*lru_lock,
 	void			*arg)
 
@@ -1509,7 +1510,7 @@ xfs_buftarg_wait_rele(
 	 */
 	atomic_set(&bp->b_lru_ref, 0);
 	bp->b_state |= XFS_BSTATE_DISPOSE;
-	list_move(item, dispose);
+	list_lru_isolate_move(lru, item, dispose);
 	spin_unlock(&bp->b_lock);
 	return LRU_REMOVED;
 }
@@ -1546,6 +1547,7 @@ xfs_wait_buftarg(
 static enum lru_status
 xfs_buftarg_isolate(
 	struct list_head	*item,
+	struct list_lru_one	*lru,
 	spinlock_t		*lru_lock,
 	void			*arg)
 {
@@ -1569,7 +1571,7 @@ xfs_buftarg_isolate(
 	}
 
 	bp->b_state |= XFS_BSTATE_DISPOSE;
-	list_move(item, dispose);
+	list_lru_isolate_move(lru, item, dispose);
 	spin_unlock(&bp->b_lock);
 	return LRU_REMOVED;
 }
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index d77bf6d8312a..3bd04531a349 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -430,6 +430,7 @@ struct xfs_qm_isolate {
 static enum lru_status
 xfs_qm_dquot_isolate(
 	struct list_head	*item,
+	struct list_lru_one	*lru,
 	spinlock_t		*lru_lock,
 	void			*arg)
 		__releases(lru_lock) __acquires(lru_lock)
@@ -450,7 +451,7 @@ xfs_qm_dquot_isolate(
 		XFS_STATS_INC(xs_qm_dqwants);
 
 		trace_xfs_dqreclaim_want(dqp);
-		list_del_init(&dqp->q_lru);
+		list_lru_isolate(lru, &dqp->q_lru);
 		XFS_STATS_DEC(xs_qm_dquot_unused);
 		return LRU_REMOVED;
 	}
@@ -494,7 +495,7 @@ xfs_qm_dquot_isolate(
 	xfs_dqunlock(dqp);
 
 	ASSERT(dqp->q_nrefs == 0);
-	list_move_tail(&dqp->q_lru, &isol->dispose);
+	list_lru_isolate_move(lru, &dqp->q_lru, &isol->dispose);
 	XFS_STATS_DEC(xs_qm_dquot_unused);
 	trace_xfs_dqreclaim_done(dqp);
 	XFS_STATS_INC(xs_qm_dqreclaims);
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 305b598abac2..7edf9c9ab9eb 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -125,8 +125,13 @@ static inline unsigned long list_lru_count(struct list_lru *lru)
 	return count;
 }
 
-typedef enum lru_status
-(*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
+void list_lru_isolate(struct list_lru_one *list, struct list_head *item);
+void list_lru_isolate_move(struct list_lru_one *list, struct list_head *item,
+			   struct list_head *head);
+
+typedef enum lru_status (*list_lru_walk_cb)(struct list_head *item,
+		struct list_lru_one *list, spinlock_t *lock, void *cb_arg);
+
 /**
  * list_lru_walk_one: walk a list_lru, isolating and disposing freeable items.
  * @lru: the lru pointer.
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 79aee70c3b9d..8d9d168c6c38 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -132,6 +132,21 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
+void list_lru_isolate(struct list_lru_one *list, struct list_head *item)
+{
+	list_del_init(item);
+	list->nr_items--;
+}
+EXPORT_SYMBOL_GPL(list_lru_isolate);
+
+void list_lru_isolate_move(struct list_lru_one *list, struct list_head *item,
+			   struct list_head *head)
+{
+	list_move(item, head);
+	list->nr_items--;
+}
+EXPORT_SYMBOL_GPL(list_lru_isolate_move);
+
 static unsigned long __list_lru_count_one(struct list_lru *lru,
 					  int nid, int memcg_idx)
 {
@@ -194,13 +209,11 @@ restart:
 			break;
 		--*nr_to_walk;
 
-		ret = isolate(item, &nlru->lock, cb_arg);
+		ret = isolate(item, l, &nlru->lock, cb_arg);
 		switch (ret) {
 		case LRU_REMOVED_RETRY:
 			assert_spin_locked(&nlru->lock);
 		case LRU_REMOVED:
-			l->nr_items--;
-			WARN_ON_ONCE(l->nr_items < 0);
 			isolated++;
 			/*
 			 * If the lru lock has been dropped, our list
diff --git a/mm/workingset.c b/mm/workingset.c
index d4fa7fb10a52..aa017133744b 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -302,6 +302,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 }
 
 static enum lru_status shadow_lru_isolate(struct list_head *item,
+					  struct list_lru_one *lru,
 					  spinlock_t *lru_lock,
 					  void *arg)
 {
@@ -332,7 +333,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		goto out;
 	}
 
-	list_del_init(item);
+	list_lru_isolate(lru, item);
 	spin_unlock(lru_lock);
 
 	/*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
