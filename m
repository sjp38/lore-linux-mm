Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C1E8B6B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 03:43:12 -0400 (EDT)
Date: Thu, 30 May 2013 17:43:07 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v8 16/34] xfs: convert buftarg LRU to generic code
Message-ID: <20130530074307.GN29466@dastard>
References: <1369391368-31562-1-git-send-email-glommer@openvz.org>
 <1369391368-31562-17-git-send-email-glommer@openvz.org>
 <20130525002759.GK24543@dastard>
 <51A4D3B5.6060802@parallels.com>
 <20130529101519.GA29466@dastard>
 <51A5DDCE.509@parallels.com>
 <20130529122512.GB29466@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529122512.GB29466@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Dave Chinner <dchinner@redhat.com>

On Wed, May 29, 2013 at 10:25:12PM +1000, Dave Chinner wrote:
> On Wed, May 29, 2013 at 02:51:58PM +0400, Glauber Costa wrote:
> > On 05/29/2013 02:15 PM, Dave Chinner wrote:
> > > As it is, the XFS buffer LRU reclaimation is modelled on the
> > > inode/dentry cache lru reclaimation where the "on dispose list" flag
> > > is managed by a lock in the inode/dentry and wraps around the
> > > outside of the LRU locks. The simplest fix to XFS is to add a
> > > spinlock to the buffer to handle this in the same way as inodes and
> > > dentries. I think I might be able to do it in a way that avoids
> > > the spin lock but I just haven't had time to look at it that closely.
> > > 
> > > Cheers,
> > > 
> > Ok. In the interest of having the series merged - we seem to be running
> > out of problems - I see two courses of action:
> > 
> > 1) Don't convert this to LRU at all, just convert to the new count/ scan
> > interface,
> > 
> > 2) Use a temporary spinlock, and you fix that later.
> > 
> > I would actually prefer 2). Reason is that this patch actually do both,
> > meaning I would have to rewrite the patch to do this scan / count loop
> > without the new list_lru aid. Besides being more error-prone, it is of
> > course a lot more work.
> > 
> > Which one you prefer?
> 
> 3) I'll fix it tomorrow and send you the patch.

Patch below.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

xfs: rework buffer dispose list tracking

From: Dave Chinner <dchinner@redhat.com>

In converting the buffer lru lists to use the generic code, the
locking for marking the buffers as on the dispose list was lost.
This results in confusion in LRU buffer tracking and acocunting,
resulting in reference counts being mucked up and filesystem beig
unmountable.

To fix this, introduce an internal buffer spinlock to protect the
state field that holds the dispose list information. Because there
is now locking needed around xfs_buf_lru_add/del, and they are used
in exactly one place each two lines apart, get rid of the wrappers
and code the logic directly in place.

Further, the LRU emptying code used on unmount is less than optimal.
Convert it to use a dispose list as per a normal shrinker walk, and
repeat the walk that fills the dispose list until the LRU is empty.
Thi avoids needing to drop and regain the LRU lock for every item
being freed, and allows the same logic as the shrinker isolate call
to be used. Simpler, easier to understand.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_buf.c |  125 +++++++++++++++++++++++++++++++-----------------------
 fs/xfs/xfs_buf.h |   12 ++++--
 2 files changed, 79 insertions(+), 58 deletions(-)

diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 802b65b..4342fcf 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -80,37 +80,6 @@ xfs_buf_vmap_len(
 }
 
 /*
- * xfs_buf_lru_add - add a buffer to the LRU.
- *
- * The LRU takes a new reference to the buffer so that it will only be freed
- * once the shrinker takes the buffer off the LRU.
- */
-static void
-xfs_buf_lru_add(
-	struct xfs_buf	*bp)
-{
-	if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru)) {
-		bp->b_lru_flags &= ~_XBF_LRU_DISPOSE;
-		atomic_inc(&bp->b_hold);
-	}
-}
-
-/*
- * xfs_buf_lru_del - remove a buffer from the LRU
- *
- * The unlocked check is safe here because it only occurs when there are not
- * b_lru_ref counts left on the inode under the pag->pag_buf_lock. it is there
- * to optimise the shrinker removing the buffer from the LRU and calling
- * xfs_buf_free().
- */
-static void
-xfs_buf_lru_del(
-	struct xfs_buf	*bp)
-{
-	list_lru_del(&bp->b_target->bt_lru, &bp->b_lru);
-}
-
-/*
  * When we mark a buffer stale, we remove the buffer from the LRU and clear the
  * b_lru_ref count so that the buffer is freed immediately when the buffer
  * reference count falls to zero. If the buffer is already on the LRU, we need
@@ -133,12 +102,14 @@ xfs_buf_stale(
 	 */
 	bp->b_flags &= ~_XBF_DELWRI_Q;
 
-	atomic_set(&(bp)->b_lru_ref, 0);
-	if (!(bp->b_lru_flags & _XBF_LRU_DISPOSE) &&
+	spin_lock(&bp->b_lock);
+	atomic_set(&bp->b_lru_ref, 0);
+	if (!(bp->b_state & XFS_BSTATE_DISPOSE) &&
 	    (list_lru_del(&bp->b_target->bt_lru, &bp->b_lru)))
 		atomic_dec(&bp->b_hold);
 
 	ASSERT(atomic_read(&bp->b_hold) >= 1);
+	spin_unlock(&bp->b_lock);
 }
 
 static int
@@ -202,6 +173,7 @@ _xfs_buf_alloc(
 	INIT_LIST_HEAD(&bp->b_list);
 	RB_CLEAR_NODE(&bp->b_rbnode);
 	sema_init(&bp->b_sema, 0); /* held, no waiters */
+	spin_lock_init(&bp->b_lock);
 	XB_SET_OWNER(bp);
 	bp->b_target = target;
 	bp->b_flags = flags;
@@ -890,12 +862,33 @@ xfs_buf_rele(
 
 	ASSERT(atomic_read(&bp->b_hold) > 0);
 	if (atomic_dec_and_lock(&bp->b_hold, &pag->pag_buf_lock)) {
-		if (!(bp->b_flags & XBF_STALE) &&
-			   atomic_read(&bp->b_lru_ref)) {
-			xfs_buf_lru_add(bp);
+		spin_lock(&bp->b_lock);
+		if (!(bp->b_flags & XBF_STALE) && atomic_read(&bp->b_lru_ref)) {
+			/*
+			 * If the buffer is added to the LRU take a new
+			 * reference to the buffer for the LRU and clear the
+			 * (now stale) dispose list state flag
+			 */
+			if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru)) {
+				bp->b_state &= ~XFS_BSTATE_DISPOSE;
+				atomic_inc(&bp->b_hold);
+			}
+			spin_unlock(&bp->b_lock);
 			spin_unlock(&pag->pag_buf_lock);
 		} else {
-			xfs_buf_lru_del(bp);
+			/*
+			 * most of the time buffers will already be removed from
+			 * the LRU, so optimise that case by checking for the
+			 * XFS_BSTATE_DISPOSE flag indicating the last list the
+			 * buffer was on was the disposal list
+			 */
+			if (!(bp->b_state & XFS_BSTATE_DISPOSE)) {
+				list_lru_del(&bp->b_target->bt_lru, &bp->b_lru);
+			} else {
+				ASSERT(list_empty(&bp->b_lru));
+			}
+			spin_unlock(&bp->b_lock);
+
 			ASSERT(!(bp->b_flags & _XBF_DELWRI_Q));
 			rb_erase(&bp->b_rbnode, &pag->pag_buf_tree);
 			spin_unlock(&pag->pag_buf_lock);
@@ -1484,33 +1477,48 @@ xfs_buftarg_wait_rele(
 
 {
 	struct xfs_buf		*bp = container_of(item, struct xfs_buf, b_lru);
+	struct list_head	*dispose = arg;
 
 	if (atomic_read(&bp->b_hold) > 1) {
-		/* need to wait */
+		/* need to wait, so skip it this pass */
 		trace_xfs_buf_wait_buftarg(bp, _RET_IP_);
-		spin_unlock(lru_lock);
-		delay(100);
-	} else {
-		/*
-		 * clear the LRU reference count so the buffer doesn't get
-		 * ignored in xfs_buf_rele().
-		 */
-		atomic_set(&bp->b_lru_ref, 0);
-		spin_unlock(lru_lock);
-		xfs_buf_rele(bp);
+		return LRU_SKIP;
 	}
+	if (!spin_trylock(&bp->b_lock))
+		return LRU_SKIP;
 
-	spin_lock(lru_lock);
-	return LRU_RETRY;
+	/*
+	 * clear the LRU reference count so the buffer doesn't get
+	 * ignored in xfs_buf_rele().
+	 */
+	atomic_set(&bp->b_lru_ref, 0);
+	bp->b_state |= XFS_BSTATE_DISPOSE;
+	list_move(item, dispose);
+	spin_unlock(&bp->b_lock);
+	return LRU_REMOVED;
 }
 
 void
 xfs_wait_buftarg(
 	struct xfs_buftarg	*btp)
 {
-	while (list_lru_count(&btp->bt_lru))
+	LIST_HEAD(dispose);
+	int loop = 0;
+
+	/* loop until there is nothing left on the lru list. */
+	while (list_lru_count(&btp->bt_lru)) {
 		list_lru_walk(&btp->bt_lru, xfs_buftarg_wait_rele,
-			      NULL, LONG_MAX);
+			      &dispose, LONG_MAX);
+
+		while (!list_empty(&dispose)) {
+			struct xfs_buf *bp;
+			bp = list_first_entry(&dispose, struct xfs_buf, b_lru);
+			list_del_init(&bp->b_lru);
+			xfs_buf_rele(bp);
+		}
+		if (loop++ != 0)
+			delay(100);
+	}
 }
 
 static enum lru_status
@@ -1523,15 +1531,24 @@ xfs_buftarg_isolate(
 	struct list_head	*dispose = arg;
 
 	/*
+	 * we are inverting the lru lock/bp->b_lock here, so use a trylock.
+	 * If we fail to get the lock, just skip it.
+	 */
+	if (!spin_trylock(&bp->b_lock))
+		return LRU_SKIP;
+	/*
 	 * Decrement the b_lru_ref count unless the value is already
 	 * zero. If the value is already zero, we need to reclaim the
 	 * buffer, otherwise it gets another trip through the LRU.
 	 */
-	if (!atomic_add_unless(&bp->b_lru_ref, -1, 0))
+	if (!atomic_add_unless(&bp->b_lru_ref, -1, 0)) {
+		spin_unlock(&bp->b_lock);
 		return LRU_ROTATE;
+	}
 
-	bp->b_lru_flags |= _XBF_LRU_DISPOSE;
+	bp->b_state |= XFS_BSTATE_DISPOSE;
 	list_move(item, dispose);
+	spin_unlock(&bp->b_lock);
 	return LRU_REMOVED;
 }
 
diff --git a/fs/xfs/xfs_buf.h b/fs/xfs/xfs_buf.h
index 5ec7d35..e656833 100644
--- a/fs/xfs/xfs_buf.h
+++ b/fs/xfs/xfs_buf.h
@@ -60,7 +60,6 @@ typedef enum {
 #define _XBF_KMEM	 (1 << 21)/* backed by heap memory */
 #define _XBF_DELWRI_Q	 (1 << 22)/* buffer on a delwri queue */
 #define _XBF_COMPOUND	 (1 << 23)/* compound buffer */
-#define _XBF_LRU_DISPOSE (1 << 24)/* buffer being discarded */
 
 typedef unsigned int xfs_buf_flags_t;
 
@@ -79,8 +78,12 @@ typedef unsigned int xfs_buf_flags_t;
 	{ _XBF_PAGES,		"PAGES" }, \
 	{ _XBF_KMEM,		"KMEM" }, \
 	{ _XBF_DELWRI_Q,	"DELWRI_Q" }, \
-	{ _XBF_COMPOUND,	"COMPOUND" }, \
-	{ _XBF_LRU_DISPOSE,	"LRU_DISPOSE" }
+	{ _XBF_COMPOUND,	"COMPOUND" }
+
+/*
+ * Internal state flags.
+ */
+#define XFS_BSTATE_DISPOSE	 (1 << 0)	/* buffer being discarded */
 
 typedef struct xfs_buftarg {
 	dev_t			bt_dev;
@@ -136,7 +139,8 @@ typedef struct xfs_buf {
 	 * bt_lru_lock and not by b_sema
 	 */
 	struct list_head	b_lru;		/* lru list */
-	xfs_buf_flags_t		b_lru_flags;	/* internal lru status flags */
+	spinlock_t		b_lock;		/* internal state lock */
+	unsigned int		b_state;	/* internal state flags */
 	wait_queue_head_t	b_waiters;	/* unpin waiters */
 	struct list_head	b_list;
 	struct xfs_perag	*b_pag;		/* contains rbtree root */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
