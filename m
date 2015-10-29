Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2190182F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 18:10:41 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so52521235pad.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 15:10:40 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id bc4si5483186pad.141.2015.10.29.15.10.38
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 15:10:39 -0700 (PDT)
Date: Fri, 30 Oct 2015 09:10:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151029221022.GB10656@dastard>
References: <20151022131555.GC4378@alap3.anarazel.de>
 <20151024213912.GE8773@dastard>
 <20151028092752.GF29811@alap3.anarazel.de>
 <20151028204834.GP8773@dastard>
 <20151028232312.GL29811@alap3.anarazel.de>
 <20151029015422.GT8773@dastard>
 <20151029162356.GQ29811@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029162356.GQ29811@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 29, 2015 at 05:23:56PM +0100, Andres Freund wrote:
> On 2015-10-29 12:54:22 +1100, Dave Chinner wrote:
> > On Thu, Oct 29, 2015 at 12:23:12AM +0100, Andres Freund wrote:
> > > By calling sync_file_range() over small ranges of pages shortly after
> > > they've been written we make it unlikely (but still possible) that much
> > > data has to be flushed at fsync() time.
> > 
> > Right, but you still need the fsync call, whereas with a async fsync
> > call you don't - when you gather the completion, no further action
> > needs to be taken on that dirty range.
> 
> I assume that the actual IOs issued by the async fsync and a plain fsync
> would be pretty similar. So the problem that an fsync of large amounts
> of dirty data causes latency increases for other issuers of IO wouldn't
> be gone, no?

Yes, they'd be the same if the async operation is not range limited.

> > > At the moment using fdatasync() instead of fsync() is a considerable
> > > performance advantage... If I understand the above proposal correctly,
> > > it'd allow specifying ranges, is that right?
> > 
> > Well, the patch I sent doesn't do ranges, but it could easily be
> > passed in as the iocb has offset/len parameters that are used by
> > IOCB_CMD_PREAD/PWRITE.
> 
> That'd be cool. Then we could issue those for asynchronous transaction
> commits, and to have more wal writes concurrently in progress by the
> background wal writer.

Updated patch that allows ranged aio fsync below. In the
application, do this for a ranged fsync:

	io_prep_fsync(iocb, fd);
	iocb->u.c.offset = offset;	/* start of range */
	iocb->u.c.nbytes = len;		/* size (in bytes) to sync */
	error = io_submit(ctx, 1, &iocb);

> I'll try the patch from 20151028232641.GS8773@dastard and see wether I
> can make it be advantageous for throughput (for WAL flushing, not the
> checkpointer process).  Wish I had a better storage system, my guess
> it'll be more advantageous there. We'll see.

A $100 SATA ssd is all you need to get the IOPS rates in the
thousands for these sorts of tests...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

aio: wire up generic aio_fsync method

From: Dave Chinner <dchinner@redhat.com>

We've had plenty of requests for an asynchronous fsync over the past
few years, and we've got the infrastructure there to do it. But
nobody has wired it up to test it. The common request we get from
userspace storage applications is to do a post-write pass over a set
of files that were just written (i.e. bulk background fsync) for
point-in-time checkpointing or flushing purposes.

So, just to see if I could brute force an effective implementation,
wire up aio_fsync, add a workqueue and push all the fsync calls off
to the workqueue. The workqueue will allow parallel dispatch, switch
execution if a fsync blocks for any reason, etc. Brute force and
very effective....

This also allows us to do ranged f(data)sync calls. the libaio
io_prep_fsync() function zeros the unused sections of the iocb
passed to the kernel, so the offset/byte count in the iocb should
always be zero. Hence if we get a non-zero byte count, we can treat
it as a ranges operation. This allows applications to commit ranges
of files to stable storage, rather than just he entire file. TO do
this, we need to be able to pass the length to ->aio_fsync(), but
this is trivial to change because no subsystem currently implements
this method.

So, I hacked up fs_mark to enable fsync via the libaio io_fsync()
interface to run some tests. The quick test is:

	- write 10000 4k files into the cache
	- run a post write open-fsync-close pass (sync mode 5)
	- run 5 iterations
	- run a single thread, then 4 threads.

First I ran it on a 500TB sparse filesystem on a SSD.

FSUse%        Count         Size    Files/sec     App Overhead
     0        10000         4096        507.5           184435
     0        20000         4096        527.2           184815
     0        30000         4096        530.4           183798
     0        40000         4096        531.0           189431
     0        50000         4096        554.2           181557

real    1m34.548s
user    0m0.819s
sys     0m10.596s

Runs at around 500 log forces/s resulting in 500 log writes/s
giving a sustained IO load of about 1200 IOPS.

Using io_fsync():

FSUse%        Count         Size    Files/sec     App Overhead
     0        10000         4096       4124.1           151359
     0        20000         4096       5506.4           112704
     0        30000         4096       7347.1            97967
     0        40000         4096       7110.1            97089
     0        50000         4096       7075.3            94942

real    0m8.554s
user    0m0.350s
sys     0m3.684s

Runs at around 7,000 log forces/s, which are mostly aggregated down
to around 700 log writes/s, for a total sustained load of ~8000 IOPS.
The parallel dispatch of fsync operations allows the log to
aggregate them effectively, reducing journal IO by a factor of 10

Run the same workload, 4 threads at a time. Normal fsync:

FSUse%        Count         Size    Files/sec     App Overhead
     0        40000         4096       2156.0           690185
     0        80000         4096       1859.6           693849
     0       120000         4096       1858.8           723889
     0       160000         4096       1848.5           708657
     0       200000         4096       1842.7           736587

Runs at ~2000 log forces/s, resulting in ~1000 log writes/s and
3,000 IOPS. We see the journal writes being aggregated, but nowhere
near the rate of the previous async fsync run.

Using io_fsync():

SUse%        Count         Size    Files/sec     App Overhead
     0        40000         4096      18956.0           633011
     0        80000         4096      18972.1           635786
     0       120000         4096      23719.6           433334
     0       160000         4096      25780.6           403199
     0       200000         4096      24848.7           480086

real    0m9.512s
user    0m1.307s
sys     0m14.844s

Almost perfect scaling! ~24,000 log forces/s resulting in ~700 log
writes/s, so we've not got a 35:1 journal write aggregation
occurring, and so the total sustained IOPS is only ~25000 IOPS.

Just checking to see how far I can push it.

threads		files/s		IOPS		log aggregation
  1		 7000		 8000		 10:1
  4		24000		25000		 35:1
  8		32000		34000		100:1
 16		33000		35000		100:1
 32		30000		35000		 90:1

At 32 threads it's becoming context switch bound and burning
13-14 CPUs. It's pushing 6-800,000 context switches/s, and the
overhead in the blk_mq tag code is killing everything:

-   23.73%    23.73%  [kernel]            [k] _raw_spin_unlock_irqrestore
   - _raw_spin_unlock_irqrestore
      - 64.15% prepare_to_wait
         - 99.35% bt_get
              blk_mq_get_tag
....
      - 14.23% virtio_queue_rq
         - __blk_mq_run_hw_queue
            - blk_mq_run_hw_queue
               - 93.89% blk_mq_insert_requests
                    blk_mq_flush_plug_list
.....
   13.30%    13.30%  [kernel]            [k] _raw_spin_unlock_irq
   - _raw_spin_unlock_irq
      - 69.27% finish_task_switch
         - __schedule
            - 94.53% schedule
               - 68.36% schedule_timeout
                  - 85.22% io_schedule_timeout
                     + 93.52% bt_get
                     + 6.48% bit_wait_io
                  + 14.39% wait_for_completion
      - 15.36% blk_insert_flush
           blk_sq_make_request
           generic_make_request
         - submit_bio
            - 99.24% submit_bio_wait
                 blkdev_issue_flush
                 xfs_blkdev_issue_flush
                 xfs_file_fsync
                 vfs_fsync_range
                 vfs_fsync
                 generic_aio_fsync_work


So, essentiall, close on 30% of the CPU being used (2.5 of 8 CPUs
being spent on this workload) is being spent on lock contention on
the blk mq request and tag wait queues due to the amount of task
switching going on...

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/aio.c           | 69 +++++++++++++++++++++++++++++++++++++++++++++++-------
 include/linux/fs.h |  2 +-
 2 files changed, 61 insertions(+), 10 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 155f842..109433b 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -188,6 +188,20 @@ struct aio_kiocb {
 	struct eventfd_ctx	*ki_eventfd;
 };
 
+/*
+ * Generic async fsync work structure.  If the file does not supply
+ * an ->aio_fsync method but has a ->fsync method, then the f(d)sync request is
+ * passed to the aio_fsync_wq workqueue and is executed there.
+ */
+struct aio_fsync_args {
+	struct work_struct	work;
+	struct kiocb		*req;
+	size_t			len;		/* zero for full file fsync */
+	int			datasync;
+};
+
+static struct workqueue_struct *aio_fsync_wq;
+
 /*------ sysctl variables----*/
 static DEFINE_SPINLOCK(aio_nr_lock);
 unsigned long aio_nr;		/* current system wide number of aio requests */
@@ -257,6 +271,10 @@ static int __init aio_setup(void)
 	if (IS_ERR(aio_mnt))
 		panic("Failed to create aio fs mount.");
 
+	aio_fsync_wq = alloc_workqueue("aio-fsync", 0, 0);
+	if (!aio_fsync_wq)
+		panic("Failed to create aio fsync workqueue.");
+
 	kiocb_cachep = KMEM_CACHE(aio_kiocb, SLAB_HWCACHE_ALIGN|SLAB_PANIC);
 	kioctx_cachep = KMEM_CACHE(kioctx,SLAB_HWCACHE_ALIGN|SLAB_PANIC);
 
@@ -1396,6 +1414,40 @@ static int aio_setup_vectored_rw(int rw, char __user *buf, size_t len,
 				len, UIO_FASTIOV, iovec, iter);
 }
 
+static void generic_aio_fsync_work(struct work_struct *work)
+{
+	struct aio_fsync_args *args = container_of(work,
+						   struct aio_fsync_args, work);
+	struct kiocb *req = args->req;
+	int error;
+
+	if (!args->len)
+		error = vfs_fsync(req->ki_filp, args->datasync);
+	else
+		error = vfs_fsync_range(req->ki_filp, req->ki_pos,
+					req->ki_pos + args->len,
+					args->datasync);
+
+	aio_complete(req, error, 0);
+	kfree(args);
+}
+
+static int generic_aio_fsync(struct kiocb *req, size_t len, int datasync)
+{
+	struct aio_fsync_args	*args;
+
+	args = kzalloc(sizeof(struct aio_fsync_args), GFP_KERNEL);
+	if (!args)
+		return -ENOMEM;
+
+	INIT_WORK(&args->work, generic_aio_fsync_work);
+	args->req = req;
+	args->len = len;
+	args->datasync = datasync;
+	queue_work(aio_fsync_wq, &args->work);
+	return -EIOCBQUEUED;
+}
+
 /*
  * aio_run_iocb:
  *	Performs the initial checks and io submission.
@@ -1410,6 +1462,7 @@ static ssize_t aio_run_iocb(struct kiocb *req, unsigned opcode,
 	rw_iter_op *iter_op;
 	struct iovec inline_vecs[UIO_FASTIOV], *iovec = inline_vecs;
 	struct iov_iter iter;
+	int datasync = 0;
 
 	switch (opcode) {
 	case IOCB_CMD_PREAD:
@@ -1460,17 +1513,15 @@ rw_common:
 		break;
 
 	case IOCB_CMD_FDSYNC:
-		if (!file->f_op->aio_fsync)
-			return -EINVAL;
-
-		ret = file->f_op->aio_fsync(req, 1);
-		break;
-
+		datasync = 1;
+		/* fall through */
 	case IOCB_CMD_FSYNC:
-		if (!file->f_op->aio_fsync)
+		if (file->f_op->aio_fsync)
+			ret = file->f_op->aio_fsync(req, len, datasync);
+		else if (file->f_op->fsync)
+			ret = generic_aio_fsync(req, len, datasync);
+		else
 			return -EINVAL;
-
-		ret = file->f_op->aio_fsync(req, 0);
 		break;
 
 	default:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 72d8a84..8a74dfb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1626,7 +1626,7 @@ struct file_operations {
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
 	int (*fsync) (struct file *, loff_t, loff_t, int datasync);
-	int (*aio_fsync) (struct kiocb *, int datasync);
+	int (*aio_fsync) (struct kiocb *, size_t len, int datasync);
 	int (*fasync) (int, struct file *, int);
 	int (*lock) (struct file *, int, struct file_lock *);
 	ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
