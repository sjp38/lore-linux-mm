Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C0E9E8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 20:09:53 -0400 (EDT)
Date: Wed, 30 Mar 2011 11:09:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS memory allocation deadlock in 2.6.38
Message-ID: <20110330000942.GI3008@dastard>
References: <081DDE43F61F3D43929A181B477DCA95639B52FD@MSXAOA6.twosigma.com>
 <081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
 <20110324174311.GA31576@infradead.org>
 <AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
 <BANLkTin0jJevStg5P2hqsLbqMzo3o30sYg@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B534E@MSXAOA6.twosigma.com>
 <081DDE43F61F3D43929A181B477DCA95639B5359@MSXAOA6.twosigma.com>
 <20110329192434.GA10536@infradead.org>
 <081DDE43F61F3D43929A181B477DCA95639B535D@MSXAOA6.twosigma.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <081DDE43F61F3D43929A181B477DCA95639B535D@MSXAOA6.twosigma.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Noonan <Sean.Noonan@twosigma.com>
Cc: 'Christoph Hellwig' <hch@infradead.org>, 'Michel Lespinasse' <walken@google.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, Martin Bligh <Martin.Bligh@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, "'linux-xfs@oss.sgi.com'" <linux-xfs@oss.sgi.com>, Stephen Degler <Stephen.Degler@twosigma.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

On Tue, Mar 29, 2011 at 03:54:12PM -0400, Sean Noonan wrote:
> > Can you check if the brute force patch below helps?  
> 
> Not sure if this helps at all, but here is the stack from all three processes involved.  This is without MAP_POPULATE and with the patch you just sent.
> 
> # ps aux | grep 'D[+]*[[:space:]]'
> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
> root      2314  0.2  0.0      0     0 ?        D    19:44   0:00 [flush-8:0]
> root      2402  0.0  0.0      0     0 ?        D    19:44   0:00 [xfssyncd/sda9]
> root      3861  2.6  9.9 16785280 4912848 pts/0 D+  19:45   0:07 ./vmtest /xfs/hugefile.dat 17179869184
> 
> # for p in 2314 2402 3861; do echo $p; cat /proc/$p/stack; done
> 2314
> [<ffffffff810d634a>] congestion_wait+0x7a/0x130
> [<ffffffff8129721c>] kmem_alloc+0x6c/0xf0
> [<ffffffff8127c07e>] xfs_inode_item_format+0x36e/0x3b0
> [<ffffffff8128401f>] xfs_log_commit_cil+0x4f/0x3b0
> [<ffffffff8128ff31>] _xfs_trans_commit+0x1f1/0x2b0
> [<ffffffff8127c716>] xfs_iomap_write_allocate+0x1a6/0x340
> [<ffffffff81298883>] xfs_map_blocks+0x193/0x2c0
> [<ffffffff812992fa>] xfs_vm_writepage+0x1ca/0x520
> [<ffffffff810c4bd2>] __writepage+0x12/0x40
> [<ffffffff810c53dd>] write_cache_pages+0x1dd/0x4f0
> [<ffffffff810c573c>] generic_writepages+0x4c/0x70
> [<ffffffff812986b8>] xfs_vm_writepages+0x58/0x70
> [<ffffffff810c577c>] do_writepages+0x1c/0x40
> [<ffffffff811247d1>] writeback_single_inode+0xf1/0x240
> [<ffffffff81124edd>] writeback_sb_inodes+0xdd/0x1b0
> [<ffffffff81125966>] writeback_inodes_wb+0x76/0x160
> [<ffffffff81125d93>] wb_writeback+0x343/0x550
> [<ffffffff81126126>] wb_do_writeback+0x186/0x2e0
> [<ffffffff81126342>] bdi_writeback_thread+0xc2/0x310
> [<ffffffff81067846>] kthread+0x96/0xa0
> [<ffffffff8165a414>] kernel_thread_helper+0x4/0x10
> [<ffffffffffffffff>] 0xffffffffffffffff

So, it's trying to allocate a buffer for the inode extent list, so
should only be a couple of hundred bytes, and at most ~2kB if you
are using large inodes. That still doesn't seem like it should be
having memory allocation problems here with 44GB of free RAM....

Hmmmm. I wonder - the process is doing a random walk of 16GB, so
it's probably created tens of thousands of delayed allocation
extents before any real allocation was done. xfs_inode_item_format()
uses the in-core data fork size for the extent buffer allocation
which in this case would be much larger than what can possibly fit
inside the inode data fork.

Lets see - worst case is 8GB of sparse blocks, which is 2^21
delalloc blocks, which gives a worst case allocation size of 2^21 *
sizeof(struct xfs_bmbt_rec), which is roughly 64MB. Which would
overflow the return value. Even at 1k delalloc extents, we'll be
asking for an order-15 allocation when all we really need is an
order-0 allocation.

Ok, so that looks like root cause of the problem. can you try the
patch below to see if it fixes the problem (without any other
patches applied or reverted).

Cheers,,

Dave.
-- 
Dave Chinner
david@fromorbit.com

xfs: fix extent format buffer allocation size

From: Dave Chinner <dchinner@redhat.com>

When formatting an inode item, we have to allocate a separate buffer
to hold extents when there are delayed allocation extents on the
inode and it is in extent format. The allocation size is derived
from the in-core data fork representation, which accounts for
delayed allocation extents, while the on-disk representation does
not contain any delalloc extents.

As a result of this mismatch, the allocated buffer can be far larger
than needed to hold the real extent list which, due to the fact the
inode is in extent format, is limited to the size of the literal
area of the inode. However, we can have thousands of delalloc
extents, resulting in an allocation size orders of magnitude larger
than is needed to hold all the real extents.

Fix this by limiting the size of the buffer being allocated to the
size of the literal area of the inodes in the filesystem (i.e. the
maximum size an inode fork can grow to).

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_inode_item.c |   69 ++++++++++++++++++++++++++++------------------
 1 files changed, 42 insertions(+), 27 deletions(-)

diff --git a/fs/xfs/xfs_inode_item.c b/fs/xfs/xfs_inode_item.c
index 46cc401..12cdc39 100644
--- a/fs/xfs/xfs_inode_item.c
+++ b/fs/xfs/xfs_inode_item.c
@@ -198,6 +198,43 @@ xfs_inode_item_size(
 }
 
 /*
+ * xfs_inode_item_format_extents - convert in-core extents to on-disk form
+ *
+ * For either the data or attr fork in extent format, we need to endian convert
+ * the in-core extent as we place them into the on-disk inode. In this case, we
+ * ned to do this conversion before we write the extents into the log. Because
+ * we don't have the disk inode to write into here, we allocate a buffer and
+ * format the extents into it via xfs_iextents_copy(). We free the buffer in
+ * the unlock routine after the copy for the log has been made.
+ *
+ * For the data fork, there can be delayed allocation extents
+ * in the inode as well, so the in-core data fork can be much larger than the
+ * on-disk data representation of real inodes. Hence we need to limit the size
+ * of the allocation to what will fit in the inode fork, otherwise we could be
+ * asking for excessively large allocation sizes.
+ */
+STATIC void
+xfs_inode_item_format_extents(
+	struct xfs_inode	*ip,
+	struct xfs_log_iovec	*vecp,
+	int			whichfork,
+	int			type)
+{
+	xfs_bmbt_rec_t		*ext_buffer;
+
+	ext_buffer = kmem_alloc(XFS_IFORK_SIZE(ip, whichfork),
+							KM_SLEEP | KM_NOFS);
+	if (whichfork == XFS_DATA_FORK)
+		ip->i_itemp->ili_extents_buf = ext_buffer;
+	else
+		ip->i_itemp->ili_aextents_buf = ext_buffer;
+
+	vecp->i_addr = ext_buffer;
+	vecp->i_len = xfs_iextents_copy(ip, ext_buffer, whichfork);
+	vecp->i_type = type;
+}
+
+/*
  * This is called to fill in the vector of log iovecs for the
  * given inode log item.  It fills the first item with an inode
  * log format structure, the second with the on-disk inode structure,
@@ -213,7 +250,6 @@ xfs_inode_item_format(
 	struct xfs_inode	*ip = iip->ili_inode;
 	uint			nvecs;
 	size_t			data_bytes;
-	xfs_bmbt_rec_t		*ext_buffer;
 	xfs_mount_t		*mp;
 
 	vecp->i_addr = &iip->ili_format;
@@ -320,22 +356,8 @@ xfs_inode_item_format(
 			} else
 #endif
 			{
-				/*
-				 * There are delayed allocation extents
-				 * in the inode, or we need to convert
-				 * the extents to on disk format.
-				 * Use xfs_iextents_copy()
-				 * to copy only the real extents into
-				 * a separate buffer.  We'll free the
-				 * buffer in the unlock routine.
-				 */
-				ext_buffer = kmem_alloc(ip->i_df.if_bytes,
-					KM_SLEEP);
-				iip->ili_extents_buf = ext_buffer;
-				vecp->i_addr = ext_buffer;
-				vecp->i_len = xfs_iextents_copy(ip, ext_buffer,
-						XFS_DATA_FORK);
-				vecp->i_type = XLOG_REG_TYPE_IEXT;
+				xfs_inode_item_format_extents(ip, vecp,
+					XFS_DATA_FORK, XLOG_REG_TYPE_IEXT);
 			}
 			ASSERT(vecp->i_len <= ip->i_df.if_bytes);
 			iip->ili_format.ilf_dsize = vecp->i_len;
@@ -445,19 +467,12 @@ xfs_inode_item_format(
 			 */
 			vecp->i_addr = ip->i_afp->if_u1.if_extents;
 			vecp->i_len = ip->i_afp->if_bytes;
+			vecp->i_type = XLOG_REG_TYPE_IATTR_EXT;
 #else
 			ASSERT(iip->ili_aextents_buf == NULL);
-			/*
-			 * Need to endian flip before logging
-			 */
-			ext_buffer = kmem_alloc(ip->i_afp->if_bytes,
-				KM_SLEEP);
-			iip->ili_aextents_buf = ext_buffer;
-			vecp->i_addr = ext_buffer;
-			vecp->i_len = xfs_iextents_copy(ip, ext_buffer,
-					XFS_ATTR_FORK);
+			xfs_inode_item_format_extents(ip, vecp,
+					XFS_ATTR_FORK, XLOG_REG_TYPE_IATTR_EXT);
 #endif
-			vecp->i_type = XLOG_REG_TYPE_IATTR_EXT;
 			iip->ili_format.ilf_asize = vecp->i_len;
 			vecp++;
 			nvecs++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
