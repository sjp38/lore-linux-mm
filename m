Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 917846B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 03:57:05 -0500 (EST)
Date: Fri, 18 Nov 2011 09:57:01 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111118085701.GD1615@x4.trippels.de>
References: <20111118072519.GA1615@x4.trippels.de>
 <20111118075521.GB1615@x4.trippels.de>
 <1321605837.30341.551.camel@debian>
 <20111118085436.GC1615@x4.trippels.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111118085436.GC1615@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>

On 2011.11.18 at 09:54 +0100, Markus Trippelsdorf wrote:
> On 2011.11.18 at 16:43 +0800, Alex,Shi wrote:
> > > > 
> > > > The dirty flag comes from a bunch of unrelated xfs patches from Christoph, that
> > > > I'm testing right now.
> > 
> > Where is the xfs patchset? I am wondering if it is due to slub code. It
> > is also possible xfs set a incorrect page flags. 
> 
> http://thread.gmane.org/gmane.comp.file-systems.xfs.general/41810

This is the diff:

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 574d4ee..b436581 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -26,6 +26,7 @@
 #include "xfs_bmap_btree.h"
 #include "xfs_dinode.h"
 #include "xfs_inode.h"
+#include "xfs_inode_item.h"
 #include "xfs_alloc.h"
 #include "xfs_error.h"
 #include "xfs_rw.h"
@@ -99,24 +100,6 @@ xfs_destroy_ioend(
 }
 
 /*
- * If the end of the current ioend is beyond the current EOF,
- * return the new EOF value, otherwise zero.
- */
-STATIC xfs_fsize_t
-xfs_ioend_new_eof(
-	xfs_ioend_t		*ioend)
-{
-	xfs_inode_t		*ip = XFS_I(ioend->io_inode);
-	xfs_fsize_t		isize;
-	xfs_fsize_t		bsize;
-
-	bsize = ioend->io_offset + ioend->io_size;
-	isize = MAX(ip->i_size, ip->i_new_size);
-	isize = MIN(isize, bsize);
-	return isize > ip->i_d.di_size ? isize : 0;
-}
-
-/*
  * Fast and loose check if this write could update the on-disk inode size.
  */
 static inline bool xfs_ioend_is_append(struct xfs_ioend *ioend)
@@ -131,30 +114,40 @@ static inline bool xfs_ioend_is_append(struct xfs_ioend *ioend)
  * will be the intended file size until i_size is updated.  If this write does
  * not extend all the way to the valid file size then restrict this update to
  * the end of the write.
- *
- * This function does not block as blocking on the inode lock in IO completion
- * can lead to IO completion order dependency deadlocks.. If it can't get the
- * inode ilock it will return EAGAIN. Callers must handle this.
  */
 STATIC int
 xfs_setfilesize(
-	xfs_ioend_t		*ioend)
+	struct xfs_ioend	*ioend)
 {
-	xfs_inode_t		*ip = XFS_I(ioend->io_inode);
+	struct xfs_inode	*ip = XFS_I(ioend->io_inode);
+	struct xfs_mount	*mp = ip->i_mount;
+	struct xfs_trans	*tp;
 	xfs_fsize_t		isize;
+	int			error = 0;
+
+	xfs_ilock(ip, XFS_ILOCK_EXCL);
+	isize = xfs_new_eof(ip, ioend->io_offset + ioend->io_size);
+	xfs_iunlock(ip, XFS_ILOCK_EXCL);
+
+	if (!isize)
+		return 0;
 
-	if (!xfs_ilock_nowait(ip, XFS_ILOCK_EXCL))
-		return EAGAIN;
+	trace_xfs_setfilesize(ip, ioend->io_offset, ioend->io_size);
 
-	isize = xfs_ioend_new_eof(ioend);
-	if (isize) {
-		trace_xfs_setfilesize(ip, ioend->io_offset, ioend->io_size);
-		ip->i_d.di_size = isize;
-		xfs_mark_inode_dirty(ip);
+	tp = xfs_trans_alloc(mp, XFS_TRANS_FSYNC_TS);
+	error = xfs_trans_reserve(tp, 0, XFS_FSYNC_TS_LOG_RES(mp), 0, 0, 0);
+	if (error) {
+		xfs_trans_cancel(tp, 0);
+		return error;
 	}
 
-	xfs_iunlock(ip, XFS_ILOCK_EXCL);
-	return 0;
+	xfs_ilock(ip, XFS_ILOCK_EXCL);
+
+	ip->i_d.di_size = isize;
+	xfs_trans_ijoin(tp, ip, XFS_ILOCK_EXCL);
+	xfs_trans_log_inode(tp, ip, XFS_ILOG_CORE);
+
+	return xfs_trans_commit(tp, 0);
 }
 
 /*
@@ -168,10 +161,12 @@ xfs_finish_ioend(
 	struct xfs_ioend	*ioend)
 {
 	if (atomic_dec_and_test(&ioend->io_remaining)) {
+		struct xfs_mount	*mp = XFS_I(ioend->io_inode)->i_mount;
+
 		if (ioend->io_type == IO_UNWRITTEN)
-			queue_work(xfsconvertd_workqueue, &ioend->io_work);
+			queue_work(mp->m_unwritten_workqueue, &ioend->io_work);
 		else if (xfs_ioend_is_append(ioend))
-			queue_work(xfsdatad_workqueue, &ioend->io_work);
+			queue_work(mp->m_data_workqueue, &ioend->io_work);
 		else
 			xfs_destroy_ioend(ioend);
 	}
@@ -206,29 +201,14 @@ xfs_end_io(
 			ioend->io_error = -error;
 			goto done;
 		}
+	} else if (xfs_ioend_is_append(ioend)) {
+		error = xfs_setfilesize(ioend);
+		if (error)
+			ioend->io_error = error;
 	}
 
-	/*
-	 * We might have to update the on-disk file size after extending
-	 * writes.
-	 */
-	error = xfs_setfilesize(ioend);
-	ASSERT(!error || error == EAGAIN);
-
 done:
-	/*
-	 * If we didn't complete processing of the ioend, requeue it to the
-	 * tail of the workqueue for another attempt later. Otherwise destroy
-	 * it.
-	 */
-	if (error == EAGAIN) {
-		atomic_inc(&ioend->io_remaining);
-		xfs_finish_ioend(ioend);
-		/* ensure we don't spin on blocked ioends */
-		delay(1);
-	} else {
-		xfs_destroy_ioend(ioend);
-	}
+	xfs_destroy_ioend(ioend);
 }
 
 /*
@@ -385,13 +365,6 @@ xfs_submit_ioend_bio(
 	bio->bi_private = ioend;
 	bio->bi_end_io = xfs_end_bio;
 
-	/*
-	 * If the I/O is beyond EOF we mark the inode dirty immediately
-	 * but don't update the inode size until I/O completion.
-	 */
-	if (xfs_ioend_new_eof(ioend))
-		xfs_mark_inode_dirty(XFS_I(ioend->io_inode));
-
 	submit_bio(wbc->sync_mode == WB_SYNC_ALL ? WRITE_SYNC : WRITE, bio);
 }
 
diff --git a/fs/xfs/xfs_aops.h b/fs/xfs/xfs_aops.h
index 116dd5c..06e4caf 100644
--- a/fs/xfs/xfs_aops.h
+++ b/fs/xfs/xfs_aops.h
@@ -18,8 +18,6 @@
 #ifndef __XFS_AOPS_H__
 #define __XFS_AOPS_H__
 
-extern struct workqueue_struct *xfsdatad_workqueue;
-extern struct workqueue_struct *xfsconvertd_workqueue;
 extern mempool_t *xfs_ioend_pool;
 
 /*
diff --git a/fs/xfs/xfs_attr_leaf.c b/fs/xfs/xfs_attr_leaf.c
index d4906e7..8bb1052 100644
--- a/fs/xfs/xfs_attr_leaf.c
+++ b/fs/xfs/xfs_attr_leaf.c
@@ -110,6 +110,7 @@ xfs_attr_namesp_match(int arg_flags, int ondisk_flags)
 /*
  * Query whether the requested number of additional bytes of extended
  * attribute space will be able to fit inline.
+ *
  * Returns zero if not, else the di_forkoff fork offset to be used in the
  * literal area for attribute data once the new bytes have been added.
  *
@@ -136,11 +137,26 @@ xfs_attr_shortform_bytesfit(xfs_inode_t *dp, int bytes)
 		return (offset >= minforkoff) ? minforkoff : 0;
 	}
 
-	if (!(mp->m_flags & XFS_MOUNT_ATTR2)) {
-		if (bytes <= XFS_IFORK_ASIZE(dp))
-			return dp->i_d.di_forkoff;
+	/*
+	 * If the requested numbers of bytes is smaller or equal to the
+	 * current attribute fork size we can always proceed.
+	 *
+	 * Note that if_bytes in the data fork might actually be larger than
+	 * the current data fork size is due to delalloc extents. In that
+	 * case either the extent count will go down when they are converted
+	 * to ral extents, or the delalloc conversion will take care of the
+	 * literal area rebalancing.
+	 */
+	if (bytes <= XFS_IFORK_ASIZE(dp))
+		return dp->i_d.di_forkoff;
+
+	/*
+	 * For attr2 we can try to move the forkoff if there is space in the
+	 * literal area, but for the old format we are done if there is no
+	 * space in the fixes attribute fork.
+	 */
+	if (!(mp->m_flags & XFS_MOUNT_ATTR2))
 		return 0;
-	}
 
 	dsize = dp->i_df.if_bytes;
 	
@@ -157,10 +173,9 @@ xfs_attr_shortform_bytesfit(xfs_inode_t *dp, int bytes)
 		    xfs_default_attroffset(dp))
 			dsize = XFS_BMDR_SPACE_CALC(MINDBTPTRS);
 		break;
-		
 	case XFS_DINODE_FMT_BTREE:
 		/*
-		 * If have data btree then keep forkoff if we have one,
+		 * If have a data btree then keep forkoff if we have one,
 		 * otherwise we are adding a new attr, so then we set 
 		 * minforkoff to where the btree root can finish so we have 
 		 * plenty of room for attrs
@@ -168,10 +183,9 @@ xfs_attr_shortform_bytesfit(xfs_inode_t *dp, int bytes)
 		if (dp->i_d.di_forkoff) {
 			if (offset < dp->i_d.di_forkoff) 
 				return 0;
-			else 
-				return dp->i_d.di_forkoff;
-		} else
-			dsize = XFS_BMAP_BROOT_SPACE(dp->i_df.if_broot);
+			return dp->i_d.di_forkoff;
+		}
+		dsize = XFS_BMAP_BROOT_SPACE(dp->i_df.if_broot);
 		break;
 	}
 	
@@ -186,10 +200,10 @@ xfs_attr_shortform_bytesfit(xfs_inode_t *dp, int bytes)
 	maxforkoff = XFS_LITINO(mp) - XFS_BMDR_SPACE_CALC(MINABTPTRS);
 	maxforkoff = maxforkoff >> 3;	/* rounded down */
 
-	if (offset >= minforkoff && offset < maxforkoff)
-		return offset;
 	if (offset >= maxforkoff)
 		return maxforkoff;
+	if (offset >= minforkoff)
+		return offset;
 	return 0;
 }
 
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index cf0ac05..fcde6c3 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -45,8 +45,6 @@ static kmem_zone_t *xfs_buf_zone;
 STATIC int xfsbufd(void *);
 
 static struct workqueue_struct *xfslogd_workqueue;
-struct workqueue_struct *xfsdatad_workqueue;
-struct workqueue_struct *xfsconvertd_workqueue;
 
 #ifdef XFS_BUF_LOCK_TRACKING
 # define XB_SET_OWNER(bp)	((bp)->b_last_holder = current->pid)
@@ -1797,21 +1795,8 @@ xfs_buf_init(void)
 	if (!xfslogd_workqueue)
 		goto out_free_buf_zone;
 
-	xfsdatad_workqueue = alloc_workqueue("xfsdatad", WQ_MEM_RECLAIM, 1);
-	if (!xfsdatad_workqueue)
-		goto out_destroy_xfslogd_workqueue;
-
-	xfsconvertd_workqueue = alloc_workqueue("xfsconvertd",
-						WQ_MEM_RECLAIM, 1);
-	if (!xfsconvertd_workqueue)
-		goto out_destroy_xfsdatad_workqueue;
-
 	return 0;
 
- out_destroy_xfsdatad_workqueue:
-	destroy_workqueue(xfsdatad_workqueue);
- out_destroy_xfslogd_workqueue:
-	destroy_workqueue(xfslogd_workqueue);
  out_free_buf_zone:
 	kmem_zone_destroy(xfs_buf_zone);
  out:
@@ -1821,8 +1806,6 @@ xfs_buf_init(void)
 void
 xfs_buf_terminate(void)
 {
-	destroy_workqueue(xfsconvertd_workqueue);
-	destroy_workqueue(xfsdatad_workqueue);
 	destroy_workqueue(xfslogd_workqueue);
 	kmem_zone_destroy(xfs_buf_zone);
 }
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 753ed9b..2560248 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -436,6 +436,36 @@ xfs_aio_write_isize_update(
 	}
 }
 
+STATIC int
+xfs_aio_write_isize_reset(
+	struct xfs_inode	*ip)
+{
+	struct xfs_mount	*mp = ip->i_mount;
+	struct xfs_trans	*tp;
+	int			error = 0;
+
+	tp = xfs_trans_alloc(mp, XFS_TRANS_FSYNC_TS);
+	error = xfs_trans_reserve(tp, 0, XFS_FSYNC_TS_LOG_RES(mp), 0, 0, 0);
+	if (error) {
+		xfs_trans_cancel(tp, 0);
+		return error;
+	}
+
+	xfs_ilock(ip, XFS_ILOCK_EXCL);
+
+	if (ip->i_d.di_size <= ip->i_size) {
+		xfs_iunlock(ip, XFS_ILOCK_EXCL);
+		xfs_trans_cancel(tp, 0);
+		return 0;
+	}
+
+	ip->i_d.di_size = ip->i_size;
+	xfs_trans_ijoin(tp, ip, XFS_ILOCK_EXCL);
+	xfs_trans_log_inode(tp, ip, XFS_ILOG_CORE);
+
+	return xfs_trans_commit(tp, 0);
+}
+
 /*
  * If this was a direct or synchronous I/O that failed (such as ENOSPC) then
  * part of the I/O may have been written to disk before the error occurred.  In
@@ -447,14 +477,18 @@ xfs_aio_write_newsize_update(
 	struct xfs_inode	*ip,
 	xfs_fsize_t		new_size)
 {
+	bool			reset = false;
 	if (new_size == ip->i_new_size) {
 		xfs_rw_ilock(ip, XFS_ILOCK_EXCL);
 		if (new_size == ip->i_new_size)
 			ip->i_new_size = 0;
 		if (ip->i_d.di_size > ip->i_size)
-			ip->i_d.di_size = ip->i_size;
+			reset = true;
 		xfs_rw_iunlock(ip, XFS_ILOCK_EXCL);
 	}
+
+	if (reset)
+		xfs_aio_write_isize_reset(ip);
 }
 
 /*
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 760140d..8ed926b 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -278,6 +278,20 @@ static inline struct inode *VFS_I(struct xfs_inode *ip)
 }
 
 /*
+ * If this I/O goes past the on-disk inode size update it unless it would
+ * be past the current in-core or write in-progress inode size.
+ */
+static inline xfs_fsize_t
+xfs_new_eof(struct xfs_inode *ip, xfs_fsize_t new_size)
+{
+	xfs_fsize_t i_size = max(ip->i_size, ip->i_new_size);
+
+	if (new_size > i_size)
+		new_size = i_size;
+	return new_size > ip->i_d.di_size ? new_size : 0;
+}
+
+/*
  * i_flags helper functions
  */
 static inline void
diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
index 9afa282..9c86fa1 100644
--- a/fs/xfs/xfs_iomap.c
+++ b/fs/xfs/xfs_iomap.c
@@ -31,6 +31,7 @@
 #include "xfs_ialloc_btree.h"
 #include "xfs_dinode.h"
 #include "xfs_inode.h"
+#include "xfs_inode_item.h"
 #include "xfs_btree.h"
 #include "xfs_bmap.h"
 #include "xfs_rtalloc.h"
@@ -645,6 +646,7 @@ xfs_iomap_write_unwritten(
 	xfs_trans_t	*tp;
 	xfs_bmbt_irec_t imap;
 	xfs_bmap_free_t free_list;
+	xfs_fsize_t	i_size;
 	uint		resblks;
 	int		committed;
 	int		error;
@@ -705,7 +707,22 @@ xfs_iomap_write_unwritten(
 		if (error)
 			goto error_on_bmapi_transaction;
 
-		error = xfs_bmap_finish(&(tp), &(free_list), &committed);
+		/*
+		 * Log the updated inode size as we go.  We have to be careful
+		 * to only log it up to the actual write offset if it is
+		 * halfway into a block.
+		 */
+		i_size = XFS_FSB_TO_B(mp, offset_fsb + count_fsb);
+		if (i_size > offset + count)
+			i_size = offset + count;
+
+		i_size = xfs_new_eof(ip, i_size);
+		if (i_size) {
+			ip->i_d.di_size = i_size;
+			xfs_trans_log_inode(tp, ip, XFS_ILOG_CORE);
+		}
+
+		error = xfs_bmap_finish(&tp, &free_list, &committed);
 		if (error)
 			goto error_on_bmapi_transaction;
 
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index bb24dac..4267fd8 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -211,6 +211,12 @@ typedef struct xfs_mount {
 	struct shrinker		m_inode_shrink;	/* inode reclaim shrinker */
 	int64_t			m_low_space[XFS_LOWSP_MAX];
 						/* low free space thresholds */
+
+	struct workqueue_struct	*m_data_workqueue;
+	struct workqueue_struct	*m_unwritten_workqueue;
+#define XFS_WQ_NAME_LEN		512
+	char			m_data_workqueue_name[XFS_WQ_NAME_LEN];
+	char			m_unwritten_workqueue_name[XFS_WQ_NAME_LEN];
 } xfs_mount_t;
 
 /*
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 3eca58f..8c7a6e4 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -769,6 +769,42 @@ xfs_setup_devices(
 	return 0;
 }
 
+STATIC int
+xfs_init_mount_workqueues(
+	struct xfs_mount	*mp)
+{
+	snprintf(mp->m_data_workqueue_name, XFS_WQ_NAME_LEN,
+		 "xfs-data/%s", mp->m_fsname);
+	mp->m_data_workqueue =
+		alloc_workqueue(mp->m_data_workqueue_name, WQ_MEM_RECLAIM, 1);
+	if (!mp->m_data_workqueue)
+		goto out;
+
+	snprintf(mp->m_unwritten_workqueue_name, XFS_WQ_NAME_LEN,
+		 "xfs-conv/%s", mp->m_fsname);
+	mp->m_unwritten_workqueue =
+		alloc_workqueue(mp->m_unwritten_workqueue_name,
+				WQ_MEM_RECLAIM, 1);
+	if (!mp->m_unwritten_workqueue)
+		goto out_destroy_data_iodone_queue;
+
+	return 0;
+
+out_destroy_data_iodone_queue:
+	destroy_workqueue(mp->m_data_workqueue);
+out:
+	return -ENOMEM;
+#undef XFS_WQ_NAME_LEN
+}
+
+STATIC void
+xfs_destroy_mount_workqueues(
+	struct xfs_mount	*mp)
+{
+	destroy_workqueue(mp->m_data_workqueue);
+	destroy_workqueue(mp->m_unwritten_workqueue);
+}
+
 /* Catch misguided souls that try to use this interface on XFS */
 STATIC struct inode *
 xfs_fs_alloc_inode(
@@ -1020,6 +1056,7 @@ xfs_fs_put_super(
 	xfs_unmountfs(mp);
 	xfs_freesb(mp);
 	xfs_icsb_destroy_counters(mp);
+	xfs_destroy_mount_workqueues(mp);
 	xfs_close_devices(mp);
 	xfs_free_fsname(mp);
 	kfree(mp);
@@ -1353,10 +1390,14 @@ xfs_fs_fill_super(
 	if (error)
 		goto out_free_fsname;
 
-	error = xfs_icsb_init_counters(mp);
+	error = xfs_init_mount_workqueues(mp);
 	if (error)
 		goto out_close_devices;
 
+	error = xfs_icsb_init_counters(mp);
+	if (error)
+		goto out_destroy_workqueues;
+
 	error = xfs_readsb(mp, flags);
 	if (error)
 		goto out_destroy_counters;
@@ -1419,6 +1460,8 @@ xfs_fs_fill_super(
 	xfs_freesb(mp);
  out_destroy_counters:
 	xfs_icsb_destroy_counters(mp);
+out_destroy_workqueues:
+	xfs_destroy_mount_workqueues(mp);
  out_close_devices:
 	xfs_close_devices(mp);
  out_free_fsname:

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
