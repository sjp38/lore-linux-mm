Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 4FD306B0068
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:35:10 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 16/25] xfs: convert buftarg LRU to generic code
Date: Fri,  7 Jun 2013 00:34:49 +0400
Message-Id: <1370550898-26711-17-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>

From: Dave Chinner <dchinner@redhat.com>

Convert the buftarg LRU to use the new generic LRU list and take
advantage of the functionality it supplies to make the buffer cache
shrinker node aware.

* v7: Add NUMA aware flag

Signed-off-by: Glauber Costa <glommer@openvz.org>
Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_buf.c | 170 ++++++++++++++++++++++++++-----------------------------
 fs/xfs/xfs_buf.h |   5 +-
 2 files changed, 82 insertions(+), 93 deletions(-)

diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 1b2472a..b19b8a4 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -85,20 +85,14 @@ xfs_buf_vmap_len(
  * The LRU takes a new reference to the buffer so that it will only be freed
  * once the shrinker takes the buffer off the LRU.
  */
-STATIC void
+static void
 xfs_buf_lru_add(
 	struct xfs_buf	*bp)
 {
-	struct xfs_buftarg *btp = bp->b_target;
-
-	spin_lock(&btp->bt_lru_lock);
-	if (list_empty(&bp->b_lru)) {
-		atomic_inc(&bp->b_hold);
-		list_add_tail(&bp->b_lru, &btp->bt_lru);
-		btp->bt_lru_nr++;
+	if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru)) {
 		bp->b_lru_flags &= ~_XBF_LRU_DISPOSE;
+		atomic_inc(&bp->b_hold);
 	}
-	spin_unlock(&btp->bt_lru_lock);
 }
 
 /*
@@ -107,24 +101,13 @@ xfs_buf_lru_add(
  * The unlocked check is safe here because it only occurs when there are not
  * b_lru_ref counts left on the inode under the pag->pag_buf_lock. it is there
  * to optimise the shrinker removing the buffer from the LRU and calling
- * xfs_buf_free(). i.e. it removes an unnecessary round trip on the
- * bt_lru_lock.
+ * xfs_buf_free().
  */
-STATIC void
+static void
 xfs_buf_lru_del(
 	struct xfs_buf	*bp)
 {
-	struct xfs_buftarg *btp = bp->b_target;
-
-	if (list_empty(&bp->b_lru))
-		return;
-
-	spin_lock(&btp->bt_lru_lock);
-	if (!list_empty(&bp->b_lru)) {
-		list_del_init(&bp->b_lru);
-		btp->bt_lru_nr--;
-	}
-	spin_unlock(&btp->bt_lru_lock);
+	list_lru_del(&bp->b_target->bt_lru, &bp->b_lru);
 }
 
 /*
@@ -151,18 +134,10 @@ xfs_buf_stale(
 	bp->b_flags &= ~_XBF_DELWRI_Q;
 
 	atomic_set(&(bp)->b_lru_ref, 0);
-	if (!list_empty(&bp->b_lru)) {
-		struct xfs_buftarg *btp = bp->b_target;
-
-		spin_lock(&btp->bt_lru_lock);
-		if (!list_empty(&bp->b_lru) &&
-		    !(bp->b_lru_flags & _XBF_LRU_DISPOSE)) {
-			list_del_init(&bp->b_lru);
-			btp->bt_lru_nr--;
-			atomic_dec(&bp->b_hold);
-		}
-		spin_unlock(&btp->bt_lru_lock);
-	}
+	if (!(bp->b_lru_flags & _XBF_LRU_DISPOSE) &&
+	    (list_lru_del(&bp->b_target->bt_lru, &bp->b_lru)))
+		atomic_dec(&bp->b_hold);
+
 	ASSERT(atomic_read(&bp->b_hold) >= 1);
 }
 
@@ -1501,83 +1476,97 @@ xfs_buf_iomove(
  * returned. These buffers will have an elevated hold count, so wait on those
  * while freeing all the buffers only held by the LRU.
  */
-void
-xfs_wait_buftarg(
-	struct xfs_buftarg	*btp)
+static enum lru_status
+xfs_buftarg_wait_rele(
+	struct list_head	*item,
+	spinlock_t		*lru_lock,
+	void			*arg)
+
 {
-	struct xfs_buf		*bp;
+	struct xfs_buf		*bp = container_of(item, struct xfs_buf, b_lru);
 
-restart:
-	spin_lock(&btp->bt_lru_lock);
-	while (!list_empty(&btp->bt_lru)) {
-		bp = list_first_entry(&btp->bt_lru, struct xfs_buf, b_lru);
-		if (atomic_read(&bp->b_hold) > 1) {
-			trace_xfs_buf_wait_buftarg(bp, _RET_IP_);
-			list_move_tail(&bp->b_lru, &btp->bt_lru);
-			spin_unlock(&btp->bt_lru_lock);
-			delay(100);
-			goto restart;
-		}
+	if (atomic_read(&bp->b_hold) > 1) {
+		/* need to wait */
+		trace_xfs_buf_wait_buftarg(bp, _RET_IP_);
+		spin_unlock(lru_lock);
+		delay(100);
+	} else {
 		/*
 		 * clear the LRU reference count so the buffer doesn't get
 		 * ignored in xfs_buf_rele().
 		 */
 		atomic_set(&bp->b_lru_ref, 0);
-		spin_unlock(&btp->bt_lru_lock);
+		spin_unlock(lru_lock);
 		xfs_buf_rele(bp);
-		spin_lock(&btp->bt_lru_lock);
 	}
-	spin_unlock(&btp->bt_lru_lock);
+
+	spin_lock(lru_lock);
+	return LRU_RETRY;
 }
 
-int
-xfs_buftarg_shrink(
+void
+xfs_wait_buftarg(
+	struct xfs_buftarg	*btp)
+{
+	while (list_lru_count(&btp->bt_lru))
+		list_lru_walk(&btp->bt_lru, xfs_buftarg_wait_rele,
+			      NULL, LONG_MAX);
+}
+
+static enum lru_status
+xfs_buftarg_isolate(
+	struct list_head	*item,
+	spinlock_t		*lru_lock,
+	void			*arg)
+{
+	struct xfs_buf		*bp = container_of(item, struct xfs_buf, b_lru);
+	struct list_head	*dispose = arg;
+
+	/*
+	 * Decrement the b_lru_ref count unless the value is already
+	 * zero. If the value is already zero, we need to reclaim the
+	 * buffer, otherwise it gets another trip through the LRU.
+	 */
+	if (!atomic_add_unless(&bp->b_lru_ref, -1, 0))
+		return LRU_ROTATE;
+
+	bp->b_lru_flags |= _XBF_LRU_DISPOSE;
+	list_move(item, dispose);
+	return LRU_REMOVED;
+}
+
+static long
+xfs_buftarg_shrink_scan(
 	struct shrinker		*shrink,
 	struct shrink_control	*sc)
 {
 	struct xfs_buftarg	*btp = container_of(shrink,
 					struct xfs_buftarg, bt_shrinker);
-	struct xfs_buf		*bp;
-	int nr_to_scan = sc->nr_to_scan;
 	LIST_HEAD(dispose);
+	long			freed;
+	unsigned long		nr_to_scan = sc->nr_to_scan;
 
-	if (!nr_to_scan)
-		return btp->bt_lru_nr;
-
-	spin_lock(&btp->bt_lru_lock);
-	while (!list_empty(&btp->bt_lru)) {
-		if (nr_to_scan-- <= 0)
-			break;
-
-		bp = list_first_entry(&btp->bt_lru, struct xfs_buf, b_lru);
-
-		/*
-		 * Decrement the b_lru_ref count unless the value is already
-		 * zero. If the value is already zero, we need to reclaim the
-		 * buffer, otherwise it gets another trip through the LRU.
-		 */
-		if (!atomic_add_unless(&bp->b_lru_ref, -1, 0)) {
-			list_move_tail(&bp->b_lru, &btp->bt_lru);
-			continue;
-		}
-
-		/*
-		 * remove the buffer from the LRU now to avoid needing another
-		 * lock round trip inside xfs_buf_rele().
-		 */
-		list_move(&bp->b_lru, &dispose);
-		btp->bt_lru_nr--;
-		bp->b_lru_flags |= _XBF_LRU_DISPOSE;
-	}
-	spin_unlock(&btp->bt_lru_lock);
+	freed = list_lru_walk_node(&btp->bt_lru, sc->nid, xfs_buftarg_isolate,
+				       &dispose, &nr_to_scan);
 
 	while (!list_empty(&dispose)) {
+		struct xfs_buf *bp;
 		bp = list_first_entry(&dispose, struct xfs_buf, b_lru);
 		list_del_init(&bp->b_lru);
 		xfs_buf_rele(bp);
 	}
 
-	return btp->bt_lru_nr;
+	return freed;
+}
+
+static long
+xfs_buftarg_shrink_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+{
+	struct xfs_buftarg	*btp = container_of(shrink,
+					struct xfs_buftarg, bt_shrinker);
+	return list_lru_count_node(&btp->bt_lru, sc->nid);
 }
 
 void
@@ -1659,12 +1648,13 @@ xfs_alloc_buftarg(
 	if (!btp->bt_bdi)
 		goto error;
 
-	INIT_LIST_HEAD(&btp->bt_lru);
-	spin_lock_init(&btp->bt_lru_lock);
+	list_lru_init(&btp->bt_lru);
 	if (xfs_setsize_buftarg_early(btp, bdev))
 		goto error;
-	btp->bt_shrinker.shrink = xfs_buftarg_shrink;
+	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
+	btp->bt_shrinker.scan_objects = xfs_buftarg_shrink_scan;
 	btp->bt_shrinker.seeks = DEFAULT_SEEKS;
+	btp->bt_shrinker.flags = SHRINKER_NUMA_AWARE;
 	register_shrinker(&btp->bt_shrinker);
 	return btp;
 
diff --git a/fs/xfs/xfs_buf.h b/fs/xfs/xfs_buf.h
index 433a12e..5ec7d35 100644
--- a/fs/xfs/xfs_buf.h
+++ b/fs/xfs/xfs_buf.h
@@ -25,6 +25,7 @@
 #include <linux/fs.h>
 #include <linux/buffer_head.h>
 #include <linux/uio.h>
+#include <linux/list_lru.h>
 
 /*
  *	Base types
@@ -92,9 +93,7 @@ typedef struct xfs_buftarg {
 
 	/* LRU control structures */
 	struct shrinker		bt_shrinker;
-	struct list_head	bt_lru;
-	spinlock_t		bt_lru_lock;
-	unsigned int		bt_lru_nr;
+	struct list_lru		bt_lru;
 } xfs_buftarg_t;
 
 struct xfs_buf;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
