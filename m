Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AC4958D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 21:03:51 -0500 (EST)
Date: Fri, 4 Mar 2011 10:01:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 09/27] nfs: writeback pages wait queue
Message-ID: <20110304020157.GB7976@localhost>
References: <20110303064505.718671603@intel.com>
 <20110303074949.809203319@intel.com>
 <1299168481.1310.56.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299168481.1310.56.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Chris Mason <chris.mason@oracle.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 04, 2011 at 12:08:01AM +0800, Peter Zijlstra wrote:
> On Thu, 2011-03-03 at 14:45 +0800, Wu Fengguang wrote:
> > +static void nfs_wakeup_congested(long nr,
> > +                                struct backing_dev_info *bdi,
> > +                                wait_queue_head_t *wqh)
> > +{
> > +       long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
> > +
> > +       if (nr < 2 * limit - min(limit / 8, NFS_WAIT_PAGES)) {
> > +               if (test_bit(BDI_sync_congested, &bdi->state)) {
> > +                       clear_bdi_congested(bdi, BLK_RW_SYNC);
> > +                       smp_mb__after_clear_bit();
> > +               }
> > +               if (waitqueue_active(&wqh[BLK_RW_SYNC]))
> > +                       wake_up(&wqh[BLK_RW_SYNC]);
> > +       }
> > +       if (nr < limit - min(limit / 8, NFS_WAIT_PAGES)) {
> > +               if (test_bit(BDI_async_congested, &bdi->state)) {
> > +                       clear_bdi_congested(bdi, BLK_RW_ASYNC);
> > +                       smp_mb__after_clear_bit();
> > +               }
> > +               if (waitqueue_active(&wqh[BLK_RW_ASYNC]))
> > +                       wake_up(&wqh[BLK_RW_ASYNC]);
> > +       }
> > +} 
> 
> memory barriers want a comment - always - explaining what they order and
> against whoem.

OK. Added this comment:

                        clear_bdi_congested(bdi, BLK_RW_SYNC);
                        /*
                         * On the following wake_up(), nfs_wait_congested()
                         * will see the cleared bit and quit.
                         */
                        smp_mb__after_clear_bit();
                }
                if (waitqueue_active(&wqh[BLK_RW_SYNC]))
                        wake_up(&wqh[BLK_RW_SYNC]);

Thanks,
Fengguang
---
Subject: nfs: writeback pages wait queue
Date: Tue Aug 03 22:47:07 CST 2010

The generic writeback routines are departing from congestion_wait()
in preference of get_request_wait(), aka. waiting on the block queues.

Introduce the missing writeback wait queue for NFS, otherwise its
writeback pages will grow out of control, exhausting all PG_dirty pages.

CC: Jens Axboe <axboe@kernel.dk>
CC: Chris Mason <chris.mason@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/client.c           |    2 
 fs/nfs/write.c            |   97 +++++++++++++++++++++++++++++++-----
 include/linux/nfs_fs_sb.h |    1 
 3 files changed, 89 insertions(+), 11 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2011-03-03 14:44:16.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-03-04 09:58:38.000000000 +0800
@@ -185,11 +185,72 @@ static int wb_priority(struct writeback_
  * NFS congestion control
  */
 
+#define NFS_WAIT_PAGES	(1024L >> (PAGE_SHIFT - 10))
 int nfs_congestion_kb;
 
-#define NFS_CONGESTION_ON_THRESH 	(nfs_congestion_kb >> (PAGE_SHIFT-10))
-#define NFS_CONGESTION_OFF_THRESH	\
-	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
+/*
+ * SYNC requests will block on (2*limit) and wakeup on (2*limit-NFS_WAIT_PAGES)
+ * ASYNC requests will block on (limit) and wakeup on (limit - NFS_WAIT_PAGES)
+ * In this way SYNC writes will never be blocked by ASYNC ones.
+ */
+
+static void nfs_set_congested(long nr, struct backing_dev_info *bdi)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr > limit && !test_bit(BDI_async_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_ASYNC);
+	else if (nr > 2 * limit && !test_bit(BDI_sync_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_SYNC);
+}
+
+static void nfs_wait_congested(int is_sync,
+			       struct backing_dev_info *bdi,
+			       wait_queue_head_t *wqh)
+{
+	int waitbit = is_sync ? BDI_sync_congested : BDI_async_congested;
+	DEFINE_WAIT(wait);
+
+	if (!test_bit(waitbit, &bdi->state))
+		return;
+
+	for (;;) {
+		prepare_to_wait(&wqh[is_sync], &wait, TASK_UNINTERRUPTIBLE);
+		if (!test_bit(waitbit, &bdi->state))
+			break;
+
+		io_schedule();
+	}
+	finish_wait(&wqh[is_sync], &wait);
+}
+
+static void nfs_wakeup_congested(long nr,
+				 struct backing_dev_info *bdi,
+				 wait_queue_head_t *wqh)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr < 2 * limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_sync_congested, &bdi->state)) {
+			clear_bdi_congested(bdi, BLK_RW_SYNC);
+			/*
+			 * On the following wake_up(), nfs_wait_congested()
+			 * will see the cleared bit and quit.
+			 */
+			smp_mb__after_clear_bit();
+		}
+		if (waitqueue_active(&wqh[BLK_RW_SYNC]))
+			wake_up(&wqh[BLK_RW_SYNC]);
+	}
+	if (nr < limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_async_congested, &bdi->state)) {
+			clear_bdi_congested(bdi, BLK_RW_ASYNC);
+			smp_mb__after_clear_bit();
+		}
+		if (waitqueue_active(&wqh[BLK_RW_ASYNC]))
+			wake_up(&wqh[BLK_RW_ASYNC]);
+	}
+}
 
 static int nfs_set_page_writeback(struct page *page)
 {
@@ -200,11 +261,8 @@ static int nfs_set_page_writeback(struct
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		page_cache_get(page);
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+		nfs_set_congested(atomic_long_inc_return(&nfss->writeback),
+				  &nfss->backing_dev_info);
 	}
 	return ret;
 }
@@ -216,8 +274,10 @@ static void nfs_end_page_writeback(struc
 
 	end_page_writeback(page);
 	page_cache_release(page);
-	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	nfs_wakeup_congested(atomic_long_dec_return(&nfss->writeback),
+			     &nfss->backing_dev_info,
+			     nfss->writeback_wait);
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblock)
@@ -318,19 +378,34 @@ static int nfs_writepage_locked(struct p
 
 int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret;
 
 	ret = nfs_writepage_locked(page, wbc);
 	unlock_page(page);
+
+	nfs_wait_congested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	return ret;
 }
 
-static int nfs_writepages_callback(struct page *page, struct writeback_control *wbc, void *data)
+static int nfs_writepages_callback(struct page *page,
+				   struct writeback_control *wbc, void *data)
 {
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret;
 
 	ret = nfs_do_writepage(page, wbc, data);
 	unlock_page(page);
+
+	nfs_wait_congested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	return ret;
 }
 
--- linux-next.orig/include/linux/nfs_fs_sb.h	2011-03-03 14:44:15.000000000 +0800
+++ linux-next/include/linux/nfs_fs_sb.h	2011-03-03 14:44:16.000000000 +0800
@@ -102,6 +102,7 @@ struct nfs_server {
 	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
+	wait_queue_head_t	writeback_wait[2];
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux-next.orig/fs/nfs/client.c	2011-03-03 14:44:15.000000000 +0800
+++ linux-next/fs/nfs/client.c	2011-03-03 14:44:16.000000000 +0800
@@ -1042,6 +1042,8 @@ static struct nfs_server *nfs_alloc_serv
 	INIT_LIST_HEAD(&server->delegations);
 
 	atomic_set(&server->active, 0);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
