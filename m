Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DBF090013E
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 04:56:56 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 10/13] xfs: convert buftarg LRU to generic code
Date: Tue, 23 Aug 2011 18:56:23 +1000
Message-Id: <1314089786-20535-11-git-send-email-david@fromorbit.com>
In-Reply-To: <1314089786-20535-1-git-send-email-david@fromorbit.com>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

From: Dave Chinner <dchinner@redhat.com>

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_buf.c |  143 +++++++++++++++++++++++-------------------------------
 fs/xfs/xfs_buf.h |    5 +-
 2 files changed, 62 insertions(+), 86 deletions(-)

diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index b2eea9e..25c8ffd 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -98,19 +98,12 @@ xfs_buf_vmap_len(
  * The LRU takes a new reference to the buffer so that it will only be freed
  * once the shrinker takes the buffer off the LRU.
  */
-STATIC void
+static inline void
 xfs_buf_lru_add(
 	struct xfs_buf	*bp)
 {
-	struct xfs_buftarg *btp = bp->b_target;
-
-	spin_lock(&btp->bt_lru_lock);
-	if (list_empty(&bp->b_lru)) {
+	if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru))
 		atomic_inc(&bp->b_hold);
-		list_add_tail(&bp->b_lru, &btp->bt_lru);
-		btp->bt_lru_nr++;
-	}
-	spin_unlock(&btp->bt_lru_lock);
 }
 
 /*
@@ -119,24 +112,16 @@ xfs_buf_lru_add(
  * The unlocked check is safe here because it only occurs when there are not
  * b_lru_ref counts left on the inode under the pag->pag_buf_lock. it is there
  * to optimise the shrinker removing the buffer from the LRU and calling
- * xfs_buf_free(). i.e. it removes an unnecessary round trip on the
- * bt_lru_lock.
+ * xfs_buf_free().
  */
-STATIC void
+static inline void
 xfs_buf_lru_del(
 	struct xfs_buf	*bp)
 {
-	struct xfs_buftarg *btp = bp->b_target;
-
 	if (list_empty(&bp->b_lru))
 		return;
 
-	spin_lock(&btp->bt_lru_lock);
-	if (!list_empty(&bp->b_lru)) {
-		list_del_init(&bp->b_lru);
-		btp->bt_lru_nr--;
-	}
-	spin_unlock(&btp->bt_lru_lock);
+	list_lru_del(&bp->b_target->bt_lru, &bp->b_lru);
 }
 
 /*
@@ -153,17 +138,10 @@ xfs_buf_stale(
 {
 	bp->b_flags |= XBF_STALE;
 	atomic_set(&(bp)->b_lru_ref, 0);
-	if (!list_empty(&bp->b_lru)) {
-		struct xfs_buftarg *btp = bp->b_target;
+	if (!list_empty(&bp->b_lru) &&
+	    list_lru_del(&bp->b_target->bt_lru, &bp->b_lru))
+		atomic_dec(&bp->b_hold);
 
-		spin_lock(&btp->bt_lru_lock);
-		if (!list_empty(&bp->b_lru)) {
-			list_del_init(&bp->b_lru);
-			btp->bt_lru_nr--;
-			atomic_dec(&bp->b_hold);
-		}
-		spin_unlock(&btp->bt_lru_lock);
-	}
 	ASSERT(atomic_read(&bp->b_hold) >= 1);
 }
 
@@ -1429,31 +1407,59 @@ xfs_buf_iomove(
  * returned. These buffers will have an elevated hold count, so wait on those
  * while freeing all the buffers only held by the LRU.
  */
-void
-xfs_wait_buftarg(
-	struct xfs_buftarg	*btp)
+static int
+xfs_buftarg_wait_rele(
+	struct list_head	*item,
+	spinlock_t		*lru_lock,
+	void			*arg)
 {
-	struct xfs_buf		*bp;
+	struct xfs_buf		*bp = container_of(item, struct xfs_buf, b_lru);
 
-restart:
-	spin_lock(&btp->bt_lru_lock);
-	while (!list_empty(&btp->bt_lru)) {
-		bp = list_first_entry(&btp->bt_lru, struct xfs_buf, b_lru);
-		if (atomic_read(&bp->b_hold) > 1) {
-			spin_unlock(&btp->bt_lru_lock);
-			delay(100);
-			goto restart;
-		}
+	if (atomic_read(&bp->b_hold) > 1) {
+		/* need to wait */
+		spin_unlock(lru_lock);
+		delay(100);
+	} else {
 		/*
-		 * clear the LRU reference count so the bufer doesn't get
+		 * clear the LRU reference count so the buffer doesn't get
 		 * ignored in xfs_buf_rele().
 		 */
 		atomic_set(&bp->b_lru_ref, 0);
-		spin_unlock(&btp->bt_lru_lock);
+		spin_unlock(lru_lock);
 		xfs_buf_rele(bp);
-		spin_lock(&btp->bt_lru_lock);
 	}
-	spin_unlock(&btp->bt_lru_lock);
+	return 3;
+}
+void
+xfs_wait_buftarg(
+	struct xfs_buftarg	*btp)
+{
+	list_lru_walk(&btp->bt_lru, xfs_buftarg_wait_rele, NULL, LONG_MAX);
+}
+
+static int
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
+		return 1;
+
+	/*
+	 * remove the buffer from the LRU now to avoid needing another
+	 * lock round trip inside xfs_buf_rele().
+	 */
+	list_move(item, dispose);
+	return 0;
 }
 
 static long
@@ -1463,42 +1469,14 @@ xfs_buftarg_shrink_scan(
 {
 	struct xfs_buftarg	*btp = container_of(shrink,
 					struct xfs_buftarg, bt_shrinker);
-	struct xfs_buf		*bp;
-	int nr_to_scan = sc->nr_to_scan;
-	int freed = 0;
+	long freed = 0;
 	LIST_HEAD(dispose);
 
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
-		freed++;
-	}
-	spin_unlock(&btp->bt_lru_lock);
+	freed = list_lru_walk(&btp->bt_lru, xfs_buftarg_isolate,
+		      &dispose, sc->nr_to_scan);
 
 	while (!list_empty(&dispose)) {
+		struct xfs_buf *bp;
 		bp = list_first_entry(&dispose, struct xfs_buf, b_lru);
 		list_del_init(&bp->b_lru);
 		xfs_buf_rele(bp);
@@ -1514,7 +1492,7 @@ xfs_buftarg_shrink_count(
 {
 	struct xfs_buftarg	*btp = container_of(shrink,
 					struct xfs_buftarg, bt_shrinker);
-	return btp->bt_lru_nr;
+	return list_lru_count(&btp->bt_lru);
 }
 
 void
@@ -1608,8 +1586,7 @@ xfs_alloc_buftarg(
 	if (!btp->bt_bdi)
 		goto error;
 
-	INIT_LIST_HEAD(&btp->bt_lru);
-	spin_lock_init(&btp->bt_lru_lock);
+	list_lru_init(&btp->bt_lru);
 	if (xfs_setsize_buftarg_early(btp, bdev))
 		goto error;
 	if (xfs_alloc_delwrite_queue(btp, fsname))
diff --git a/fs/xfs/xfs_buf.h b/fs/xfs/xfs_buf.h
index 620972b..f8dafde 100644
--- a/fs/xfs/xfs_buf.h
+++ b/fs/xfs/xfs_buf.h
@@ -26,6 +26,7 @@
 #include <linux/fs.h>
 #include <linux/buffer_head.h>
 #include <linux/uio.h>
+#include <linux/list_lru.h>
 
 /*
  *	Base types
@@ -111,9 +112,7 @@ typedef struct xfs_buftarg {
 
 	/* LRU control structures */
 	struct shrinker		bt_shrinker;
-	struct list_head	bt_lru;
-	spinlock_t		bt_lru_lock;
-	unsigned int		bt_lru_nr;
+	struct list_lru		bt_lru;
 } xfs_buftarg_t;
 
 struct xfs_buf;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
