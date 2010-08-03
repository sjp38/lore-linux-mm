Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7A797620122
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 11:00:00 -0400 (EDT)
Date: Tue, 3 Aug 2010 23:07:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/9] Reduce writeback from page reclaim context V5
Message-ID: <20100803150759.GA786@localhost>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
 <20100729084523.GA537@infradead.org>
 <20100803073449.GA21452@localhost>
 <20100803125249.GD3322@quack.suse.cz>
 <20100803150446.GB32335@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
In-Reply-To: <20100803150446.GB32335@localhost>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Sorry, forgot the attachment :)

Thanks,
Fengguang

On Tue, Aug 03, 2010 at 11:04:46PM +0800, Wu Fengguang wrote:
> On Tue, Aug 03, 2010 at 08:52:49PM +0800, Jan Kara wrote:
> > On Tue 03-08-10 15:34:49, Wu Fengguang wrote:
> > > On Thu, Jul 29, 2010 at 04:45:23PM +0800, Christoph Hellwig wrote:
> > > > Btw, I'm very happy with all this writeback related progress we've made
> > > > for the 2.6.36 cycle.  The only major thing that's really missing, and
> > > > which should help dramatically with the I/O patters is stopping direct
> > > > writeback from balance_dirty_pages().  I've seen patches frrom Wu and
> > > > and Jan for this and lots of discussion.  If we get either variant in
> > > > this should be once of the best VM release from the filesystem point of
> > > > view.
> > > 
> > > Sorry for the delay. But I'm not feeling good about the current
> > > patches, both mine and Jan's.
> > > 
> > > Accounting overheads/accuracy are the obvious problem. Both patches do
> > > not perform well on large NUMA machines and fast storage. They are found
> > > hard to improve in previous discussions.
> >   Yes, my patch for balance_dirty_pages() has a problem with percpu counter
> > (im)precision and resorting to pure atomic type could result in bouncing
> > of the cache line among CPUs completing the IO (at least that is the reason
> > why all other BDI stats are per-cpu I believe).
> >   We could solve the problem by doing the accounting on page IO submission
> > time (there using the atomic type should be fine as we mostly submit IO
> > from the flusher thread anyway). It's just that doing the accounting on
> > completion time has the nice property that we really hold the throttled
> > thread upto the moment when vm can really reuse the pages.
> 
> Could try this and check how it works with NFS. The attached patch
> will also be necessary for the test. It implements a writeback wait
> queue for NFS, without it all dirty pages may be put to writeback.
> 
> I suspect the resulting fluctuations will be the same. Because
> balance_dirty_pages() will wait on some background writeback (as you
> proposed), which will block on the NFS writeback queue, which in turn
> wait for the completion of COMMIT RPCs (the current patches directly
> wait here). On the completion of one COMMIT, lots of pages may be
> freed in a burst, which makes the whole stack progress very bumpy.
> 
> > > We might do dirty throttling based on throughput, ignoring the
> > > writeback completions totally. The basic idea is, for current process,
> > > we already have a per-bdi-and-task threshold B as the local throttle
> >   Do we? The limit is currently just per-bdi, isn't it? Or do you mean
> 
> bdi_dirty_limit() calls task_dirty_limit(), so it's also related to
> the current task. For convenience we called it per-bdi writeback :)
> 
> > the ratelimiting - i.e. how often do we call balance_dirty_pages()?
> > That is per-cpu if I'm right.
> > > target. When dirty pages go beyond B*80% for example, we start
> > > throttling the task's writeback throughput. The more closer to B, the
> > > lower throughput. When reaches B or global threshold, we completely
> > > stop it. The hope is, the throughput will be sustained at some balance
> > > point. This will need careful calculation to perform stable/robust.
> >   But what do you exactly mean by throttling the task in your scenario?
> > What would it wait on?
> 
> It will simply wait for eg. 10ms for every N pages written. The more
> closer to B, the less N will be.
> 
> Thanks,
> Fengguang
> 
> > > In this way, the throttle can be made very smooth.  My old experiments
> > > show that the current writeback completion based throttling fluctuates
> > > a lot for the stall time. In particular it makes bumpy writeback for
> > > NFS, so that some times the network pipe is not active at all and
> > > performance is impacted noticeably.
> > > 
> > > By the way, we'll harvest a writeback IO controller :)
> > 
> > 								Honza
> > -- 
> > Jan Kara <jack@suse.cz>
> > SUSE Labs, CR

--T4sUOijqQbZv57TR
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-nfs-request-queue.patch"

Subject: NFS: introduce writeback wait queue
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Tue Aug 03 22:47:07 CST 2010

The generic writeback routines are departing from congestion_wait()
in preferance of get_request_wait(), aka. waiting on the block queues.

Introduce the missing writeback wait queue for NFS, otherwise its
writeback pages may grow out of control.

In perticular, balance_dirty_pages() will exit after it pushes
write_chunk pages into the PG_writeback page pool, _OR_ when the
background writeback work quits. The latter is new behavior, and could
not only quit (normally) after below background threshold, but also
quit when it finds _zero_ dirty pages to write. The latter case gives
rise to the number of PG_writeback pages if it is not explicitly limited.

CC: Jens Axboe <jens.axboe@oracle.com>
CC: Chris Mason <chris.mason@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Peter Staubach <staubach@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---

The wait time and network throughput varies a lot! this is a major problem.
This means nfs_end_page_writeback() is not called smoothly over time,
even when there are plenty of PG_writeback pages on the client side.

[  397.828509] write_bandwidth: comm=nfsiod pages=192 time=16ms
[  397.850976] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  403.065244] write_bandwidth: comm=nfsiod pages=192 time=5212ms
[  403.549134] write_bandwidth: comm=nfsiod pages=1536 time=144ms
[  403.570717] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  403.595749] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  403.622171] write_bandwidth: comm=nfsiod pages=192 time=24ms
[  403.651779] write_bandwidth: comm=nfsiod pages=192 time=28ms
[  403.680543] write_bandwidth: comm=nfsiod pages=192 time=24ms
[  403.712572] write_bandwidth: comm=nfsiod pages=192 time=28ms
[  403.751552] write_bandwidth: comm=nfsiod pages=192 time=36ms
[  403.785979] write_bandwidth: comm=nfsiod pages=192 time=28ms
[  403.823995] write_bandwidth: comm=nfsiod pages=192 time=36ms
[  403.858970] write_bandwidth: comm=nfsiod pages=192 time=32ms
[  403.880786] write_bandwidth: comm=nfsiod pages=192 time=16ms
[  403.902732] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  403.925925] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  403.952044] write_bandwidth: comm=nfsiod pages=258 time=24ms
[  403.974006] write_bandwidth: comm=nfsiod pages=192 time=16ms
[  403.995989] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  405.031049] write_bandwidth: comm=nfsiod pages=192 time=1032ms
[  405.257635] write_bandwidth: comm=nfsiod pages=1536 time=192ms
[  405.279069] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  405.300843] write_bandwidth: comm=nfsiod pages=192 time=16ms
[  405.326031] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  405.350843] write_bandwidth: comm=nfsiod pages=192 time=24ms
[  405.375160] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  409.331015] write_bandwidth: comm=nfsiod pages=192 time=3952ms
[  409.587928] write_bandwidth: comm=nfsiod pages=1536 time=152ms
[  409.610068] write_bandwidth: comm=nfsiod pages=192 time=20ms
[  409.635736] write_bandwidth: comm=nfsiod pages=192 time=24ms

# vmmon -d 1 nr_writeback nr_dirty nr_unstable

     nr_writeback         nr_dirty      nr_unstable
            11227            41463            38044
            11227            41463            38044
            11227            41463            38044
            11227            41463            38044
            11045            53987             6490
            11033            53120             8145
            11195            52143            10886
            11211            52144            10913
            11211            52144            10913
            11211            52144            10913
            11056            56887             3876
            11062            55298             8155
            11214            54485             9838
            11225            54461             9852
            11225            54461             9852
            11225            54461             4582
            22342            35535             7823

----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw 
  0   0   9  92   0   0|   0     0 |  66B  306B|   0     0 |1003   377 
  0   1  39  60   0   1|   0     0 |  90k 1361k|   0     0 |1765  1599 
  0  15  12  43   0  31|   0     0 |2292k   34M|   0     0 |  12k   16k
  0   0  16  84   0   0|   0     0 | 132B  306B|   0     0 |1003   376 
  0   0  43  57   0   0|   0     0 |  66B  306B|   0     0 |1004   376 
  0   7  25  55   0  13|   0     0 |1202k   18M|   0     0 |7331  8921 
  0   8  21  55   0  15|   0     0 |1195k   18M|   0     0 |5382  6579 
  0   0  38  62   0   0|   0     0 |  66B  306B|   0     0 |1002   371 
  0   0  33  67   0   0|   0     0 |  66B  306B|   0     0 |1003   376 
  0  14  20  41   0  24|   0     0 |1621k   24M|   0     0 |8549    10k
  0   5  31  55   0   9|   0     0 | 769k   11M|   0     0 |4444  5180 
  0   0  18  82   0   0|   0     0 |  66B  568B|   0     0 |1004   377 
  0   1  41  54   0   3|   0     0 | 184k 2777k|   0     0 |2609  2619 
  1  13  22  43   0  22|   0     0 |1572k   23M|   0     0 |8138    10k
  0  11   9  59   0  20|   0     0 |1861k   27M|   0     0 |9576    13k
  0   5  23  66   0   5|   0     0 | 540k 8122k|   0     0 |2816  2885 

 fs/nfs/client.c           |    2 
 fs/nfs/write.c            |   92 +++++++++++++++++++++++++++++++-----
 include/linux/nfs_fs_sb.h |    1 
 3 files changed, 84 insertions(+), 11 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2010-07-11 08:06:25.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-08-03 22:47:33.000000000 +0800
@@ -187,11 +187,65 @@ static int wb_priority(struct writeback_
  * NFS congestion control
  */
 
+#define NFS_WAIT_PAGES	(1024L >> (PAGE_CACHE_SHIFT - 10))
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
+static void nfs_set_congested(long nr, long limit,
+			      struct backing_dev_info *bdi)
+{
+	if (nr > limit && !test_bit(BDI_async_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_ASYNC);
+	else if (nr > 2 * limit && !test_bit(BDI_sync_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_SYNC);
+}
+
+static void nfs_wait_contested(int is_sync,
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
+static void nfs_wakeup_congested(long nr, long limit,
+				 struct backing_dev_info *bdi,
+				 wait_queue_head_t *wqh)
+{
+	if (nr < 2*limit - min(limit/8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_sync_congested, &bdi->state)) {
+			clear_bdi_congested(bdi, BLK_RW_SYNC);
+			smp_mb__after_clear_bit();
+		}
+		if (waitqueue_active(&wqh[BLK_RW_SYNC]))
+			wake_up(&wqh[BLK_RW_SYNC]);
+	}
+	if (nr < limit - min(limit/8, NFS_WAIT_PAGES)) {
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
@@ -202,11 +256,9 @@ static int nfs_set_page_writeback(struct
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		page_cache_get(page);
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+		nfs_set_congested(atomic_long_inc_return(&nfss->writeback),
+				  nfs_congestion_kb >> (PAGE_SHIFT-10),
+				  &nfss->backing_dev_info);
 	}
 	return ret;
 }
@@ -218,8 +270,11 @@ static void nfs_end_page_writeback(struc
 
 	end_page_writeback(page);
 	page_cache_release(page);
-	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	nfs_wakeup_congested(atomic_long_dec_return(&nfss->writeback),
+			     nfs_congestion_kb >> (PAGE_SHIFT-10),
+			     &nfss->backing_dev_info,
+			     nfss->writeback_wait);
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page)
@@ -311,19 +366,34 @@ static int nfs_writepage_locked(struct p
 
 int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret;
 
 	ret = nfs_writepage_locked(page, wbc);
 	unlock_page(page);
+
+	nfs_wait_contested(wbc->sync_mode == WB_SYNC_ALL,
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
+	nfs_wait_contested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	return ret;
 }
 
--- linux-next.orig/include/linux/nfs_fs_sb.h	2010-06-24 14:32:02.000000000 +0800
+++ linux-next/include/linux/nfs_fs_sb.h	2010-08-03 22:42:59.000000000 +0800
@@ -104,6 +104,7 @@ struct nfs_server {
 	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
+	wait_queue_head_t	writeback_wait[2];
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux-next.orig/fs/nfs/client.c	2010-06-24 14:32:01.000000000 +0800
+++ linux-next/fs/nfs/client.c	2010-08-03 22:42:59.000000000 +0800
@@ -994,6 +994,8 @@ static struct nfs_server *nfs_alloc_serv
 	INIT_LIST_HEAD(&server->master_link);
 
 	atomic_set(&server->active, 0);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
