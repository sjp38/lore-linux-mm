Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 48F3A6B0082
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 19:02:26 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so129206566pab.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 16:02:26 -0700 (PDT)
Date: Thu, 9 Apr 2015 09:02:03 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2][v2] blk-plug: don't flush nested plug lists
Message-ID: <20150408230203.GG15810@dastard>
References: <1428347694-17704-1-git-send-email-jmoyer@redhat.com>
 <1428347694-17704-2-git-send-email-jmoyer@redhat.com>
 <x49wq1nrcoe.fsf_-_@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49wq1nrcoe.fsf_-_@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Roger Pau Monn?? <roger.pau@citrix.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Neil Brown <neilb@suse.de>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>, Steven Whitehouse <swhiteho@redhat.com>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, xfs@oss.sgi.com, Christoph Hellwig <hch@lst.de>, Weston Andros Adamson <dros@primarydata.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Sagi Grimberg <sagig@mellanox.com>, Tejun Heo <tj@kernel.org>, Fabian Frederick <fabf@skynet.be>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ming Lei <ming.lei@canonical.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Wang Sheng-Hui <shhuiw@gmail.com>, Michal Hocko <mhocko@suse.cz>, Joe Perches <joe@perches.com>, Miklos Szeredi <mszeredi@suse.cz>, Namjae Jeon <namjae.jeon@samsung.com>, Mark Rustad <mark.d.rustad@intel.com>, Jianyu Zhan <nasa4836@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Suleiman Souhlal <suleiman@google.com>, linux-kernel@vger.kernel.org, dm-devel@redhat.com, xen-devel@lists.xenproject.org, linux-raid@vger.kernel.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 07, 2015 at 02:55:13PM -0400, Jeff Moyer wrote:
> The way the on-stack plugging currently works, each nesting level
> flushes its own list of I/Os.  This can be less than optimal (read
> awful) for certain workloads.  For example, consider an application
> that issues asynchronous O_DIRECT I/Os.  It can send down a bunch of
> I/Os together in a single io_submit call, only to have each of them
> dispatched individually down in the bowels of the dirct I/O code.
> The reason is that there are blk_plug-s instantiated both at the upper
> call site in do_io_submit and down in do_direct_IO.  The latter will
> submit as little as 1 I/O at a time (if you have a small enough I/O
> size) instead of performing the batching that the plugging
> infrastructure is supposed to provide.

I'm wondering what impact this will have on filesystem metadata IO
that needs to be issued immediately. e.g. we are doing writeback, so
there is a high level plug in place and we need to page in btree
blocks to do extent allocation. We do readahead at this point,
but it looks like this change will prevent the readahead from being
issued by the unplug in xfs_buf_iosubmit().

So while I can see how this can make your single microbenchmark
better (because it's only doing concurrent direct IO to the block
device and hence there are no dependencies between individual IOs),
I have significant reservations that it's actually a win for
filesystem-based workloads where we need direct control of flushing
to minimise IO latency due to IO dependencies...

Patches like this one:

https://lkml.org/lkml/2015/3/20/442

show similar real-world workload improvements to your patchset by
being smarter about using high level plugging to enable cross-file
merging of IO, but it still relies on the lower layers of plugging
to resolve latency bubbles caused by IO dependencies in the
filesystems.

> NOTE TO SUBSYSTEM MAINTAINERS: Before this patch, blk_finish_plug
> would always flush the plug list.  After this patch, this is only the
> case for the outer-most plug.  If you require the plug list to be
> flushed, you should be calling blk_flush_plug(current).  Btrfs and dm
> maintainers should take a close look at this patch and ensure they get
> the right behavior in the end.

IOWs, you are saying we need to change all our current unplugs to
blk_flush_plug(current) to maintain the same behaviour as we
currently have?

If that is the case, shouldn't you actually be trying to fix the
specific plugging problem you've identified (i.e. do_direct_IO() is
flushing far too frequently) rather than making a sweeping
generalisation that the IO stack plugging infrastructure
needs to be fundamentally changed?

Cheers,

Dave.

> 
> ---
> Changelog:
> v1->v2: Keep the blk_start_plug interface the same, suggested by Ming Lei.
> 
> Test results
> ------------
> Virtio-blk:
> 
> unpatched:
> 
> job1: (groupid=0, jobs=1): err= 0: pid=8032: Tue Apr  7 13:33:53 2015
>   read : io=2736.1MB, bw=280262KB/s, iops=70065, runt= 10000msec
>     slat (usec): min=40, max=10472, avg=207.82, stdev=364.02
>     clat (usec): min=211, max=35883, avg=14379.83, stdev=2213.95
>      lat (usec): min=862, max=36000, avg=14587.72, stdev=2223.80
>     clat percentiles (usec):
>      |  1.00th=[11328],  5.00th=[12096], 10.00th=[12480], 20.00th=[12992],
>      | 30.00th=[13376], 40.00th=[13760], 50.00th=[14144], 60.00th=[14400],
>      | 70.00th=[14784], 80.00th=[15168], 90.00th=[15936], 95.00th=[16768],
>      | 99.00th=[24448], 99.50th=[25216], 99.90th=[28544], 99.95th=[35072],
>      | 99.99th=[36096]
>     bw (KB  /s): min=265984, max=302720, per=100.00%, avg=280549.84, stdev=10264.36
>     lat (usec) : 250=0.01%, 1000=0.01%
>     lat (msec) : 2=0.02%, 4=0.02%, 10=0.05%, 20=96.57%, 50=3.34%
>   cpu          : usr=7.56%, sys=55.57%, ctx=6174, majf=0, minf=523
>   IO depths    : 1=0.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.1%, 32=0.1%, >=64=100.0%
>      submit    : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.0%
>      complete  : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.1%
>      issued    : total=r=700656/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
>      latency   : target=0, window=0, percentile=100.00%, depth=1024
> 
> Run status group 0 (all jobs):
>    READ: io=2736.1MB, aggrb=280262KB/s, minb=280262KB/s, maxb=280262KB/s, mint=10000msec, maxt=10000msec
> 
> Disk stats (read/write):
>   vdd: ios=695490/0, merge=0/0, ticks=785741/0, in_queue=785442, util=90.69%
> 
> 
> patched:
> job1: (groupid=0, jobs=1): err= 0: pid=7743: Tue Apr  7 13:19:07 2015
>   read : io=8126.6MB, bw=832158KB/s, iops=208039, runt= 10000msec
>     slat (usec): min=20, max=14351, avg=55.08, stdev=143.47
>     clat (usec): min=283, max=20003, avg=4846.77, stdev=1355.35
>      lat (usec): min=609, max=20074, avg=4901.95, stdev=1362.40
>     clat percentiles (usec):
>      |  1.00th=[ 4016],  5.00th=[ 4048], 10.00th=[ 4080], 20.00th=[ 4128],
>      | 30.00th=[ 4192], 40.00th=[ 4192], 50.00th=[ 4256], 60.00th=[ 4512],
>      | 70.00th=[ 4896], 80.00th=[ 5664], 90.00th=[ 5920], 95.00th=[ 6752],
>      | 99.00th=[11968], 99.50th=[13632], 99.90th=[15552], 99.95th=[17024],
>      | 99.99th=[19840]
>     bw (KB  /s): min=740992, max=896640, per=100.00%, avg=836978.95, stdev=51034.87
>     lat (usec) : 500=0.01%, 750=0.01%, 1000=0.01%
>     lat (msec) : 4=0.50%, 10=97.79%, 20=1.70%, 50=0.01%
>   cpu          : usr=20.28%, sys=69.11%, ctx=879, majf=0, minf=522
>   IO depths    : 1=0.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.1%, 32=0.1%, >=64=100.0%
>      submit    : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.0%
>      complete  : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.1%
>      issued    : total=r=2080396/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
>      latency   : target=0, window=0, percentile=100.00%, depth=1024
> 
> Run status group 0 (all jobs):
>    READ: io=8126.6MB, aggrb=832158KB/s, minb=832158KB/s, maxb=832158KB/s, mint=10000msec, maxt=10000msec
> 
> Disk stats (read/write):
>   vdd: ios=127877/0, merge=1918166/0, ticks=23118/0, in_queue=23047, util=94.08%
> 
> micron p320h:
> 
> unpatched:
> 
> job1: (groupid=0, jobs=1): err= 0: pid=3244: Tue Apr  7 13:29:14 2015
>   read : io=6728.9MB, bw=688968KB/s, iops=172241, runt= 10001msec
>     slat (usec): min=43, max=6273, avg=81.79, stdev=125.96
>     clat (usec): min=78, max=12485, avg=5852.06, stdev=1154.76
>      lat (usec): min=146, max=12572, avg=5933.92, stdev=1163.75
>     clat percentiles (usec):
>      |  1.00th=[ 4192],  5.00th=[ 4384], 10.00th=[ 4576], 20.00th=[ 5600],
>      | 30.00th=[ 5664], 40.00th=[ 5728], 50.00th=[ 5792], 60.00th=[ 5856],
>      | 70.00th=[ 6112], 80.00th=[ 6176], 90.00th=[ 6240], 95.00th=[ 6368],
>      | 99.00th=[11840], 99.50th=[11968], 99.90th=[12096], 99.95th=[12096],
>      | 99.99th=[12224]
>     bw (KB  /s): min=648328, max=859264, per=98.80%, avg=680711.16, stdev=62016.70
>     lat (usec) : 100=0.01%, 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
>     lat (msec) : 2=0.01%, 4=0.04%, 10=97.07%, 20=2.87%
>   cpu          : usr=10.28%, sys=73.61%, ctx=104436, majf=0, minf=6217
>   IO depths    : 1=0.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.1%, 32=0.1%, >=64=100.0%
>      submit    : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.0%
>      complete  : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.1%
>      issued    : total=r=1722592/w=0/d=0, short=r=0/w=0/d=0
>      latency   : target=0, window=0, percentile=100.00%, depth=1024
> 
> Run status group 0 (all jobs):
>    READ: io=6728.9MB, aggrb=688967KB/s, minb=688967KB/s, maxb=688967KB/s, mint=10001msec, maxt=10001msec
> 
> Disk stats (read/write):
>   rssda: ios=1688772/0, merge=0/0, ticks=188820/0, in_queue=188678, util=96.61%
> 
> patched:
> 
> job1: (groupid=0, jobs=1): err= 0: pid=9531: Tue Apr  7 13:22:28 2015
>   read : io=11607MB, bw=1160.6MB/s, iops=297104, runt= 10001msec
>     slat (usec): min=21, max=6376, avg=43.05, stdev=81.82
>     clat (usec): min=116, max=9844, avg=3393.90, stdev=752.57
>      lat (usec): min=167, max=9889, avg=3437.01, stdev=757.02
>     clat percentiles (usec):
>      |  1.00th=[ 2832],  5.00th=[ 2992], 10.00th=[ 3056], 20.00th=[ 3120],
>      | 30.00th=[ 3152], 40.00th=[ 3248], 50.00th=[ 3280], 60.00th=[ 3344],
>      | 70.00th=[ 3376], 80.00th=[ 3504], 90.00th=[ 3728], 95.00th=[ 3824],
>      | 99.00th=[ 9152], 99.50th=[ 9408], 99.90th=[ 9664], 99.95th=[ 9664],
>      | 99.99th=[ 9792]
>     bw (MB  /s): min= 1139, max= 1183, per=100.00%, avg=1161.07, stdev=10.58
>     lat (usec) : 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
>     lat (msec) : 2=0.01%, 4=98.31%, 10=1.67%
>   cpu          : usr=18.59%, sys=66.65%, ctx=55655, majf=0, minf=6218
>   IO depths    : 1=0.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.1%, 32=0.1%, >=64=100.0%
>      submit    : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.0%
>      complete  : 0=0.0%, 4=0.0%, 8=0.0%, 16=100.0%, 32=0.0%, 64=0.0%, >=64=0.1%
>      issued    : total=r=2971338/w=0/d=0, short=r=0/w=0/d=0
>      latency   : target=0, window=0, percentile=100.00%, depth=1024
> 
> Run status group 0 (all jobs):
>    READ: io=11607MB, aggrb=1160.6MB/s, minb=1160.6MB/s, maxb=1160.6MB/s, mint=10001msec, maxt=10001msec
> 
> Disk stats (read/write):
>   rssda: ios=183005/0, merge=2745105/0, ticks=31972/0, in_queue=31948, util=97.63%
> ---
>  block/blk-core.c                    | 29 ++++++++++++++++-------------
>  block/blk-lib.c                     |  2 +-
>  block/blk-throttle.c                |  2 +-
>  drivers/block/xen-blkback/blkback.c |  2 +-
>  drivers/md/dm-bufio.c               |  6 +++---
>  drivers/md/dm-crypt.c               |  2 +-
>  drivers/md/dm-kcopyd.c              |  2 +-
>  drivers/md/dm-thin.c                |  2 +-
>  drivers/md/md.c                     |  2 +-
>  drivers/md/raid1.c                  |  2 +-
>  drivers/md/raid10.c                 |  2 +-
>  drivers/md/raid5.c                  |  4 ++--
>  drivers/target/target_core_iblock.c |  2 +-
>  fs/aio.c                            |  2 +-
>  fs/block_dev.c                      |  2 +-
>  fs/btrfs/scrub.c                    |  2 +-
>  fs/btrfs/transaction.c              |  2 +-
>  fs/btrfs/tree-log.c                 | 12 ++++++------
>  fs/btrfs/volumes.c                  |  6 +++---
>  fs/buffer.c                         |  2 +-
>  fs/direct-io.c                      |  2 +-
>  fs/ext4/file.c                      |  2 +-
>  fs/ext4/inode.c                     |  4 ++--
>  fs/f2fs/checkpoint.c                |  2 +-
>  fs/f2fs/gc.c                        |  2 +-
>  fs/f2fs/node.c                      |  2 +-
>  fs/gfs2/log.c                       |  2 +-
>  fs/hpfs/buffer.c                    |  2 +-
>  fs/jbd/checkpoint.c                 |  2 +-
>  fs/jbd/commit.c                     |  4 ++--
>  fs/jbd2/checkpoint.c                |  2 +-
>  fs/jbd2/commit.c                    |  2 +-
>  fs/mpage.c                          |  2 +-
>  fs/nfs/blocklayout/blocklayout.c    |  4 ++--
>  fs/xfs/xfs_buf.c                    |  4 ++--
>  fs/xfs/xfs_dir2_readdir.c           |  2 +-
>  fs/xfs/xfs_itable.c                 |  2 +-
>  include/linux/blkdev.h              |  5 +++--
>  mm/madvise.c                        |  2 +-
>  mm/page-writeback.c                 |  2 +-
>  mm/readahead.c                      |  2 +-
>  mm/swap_state.c                     |  2 +-
>  mm/vmscan.c                         |  2 +-
>  43 files changed, 74 insertions(+), 70 deletions(-)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 794c3e7..fcd9c2f 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -3018,21 +3018,21 @@ void blk_start_plug(struct blk_plug *plug)
>  {
>  	struct task_struct *tsk = current;
>  
> +	if (tsk->plug) {
> +		tsk->plug->depth++;
> +		return;
> +	}
> +
> +	plug->depth = 1;
>  	INIT_LIST_HEAD(&plug->list);
>  	INIT_LIST_HEAD(&plug->mq_list);
>  	INIT_LIST_HEAD(&plug->cb_list);
>  
>  	/*
> -	 * If this is a nested plug, don't actually assign it. It will be
> -	 * flushed on its own.
> +	 * Store ordering should not be needed here, since a potential
> +	 * preempt will imply a full memory barrier
>  	 */
> -	if (!tsk->plug) {
> -		/*
> -		 * Store ordering should not be needed here, since a potential
> -		 * preempt will imply a full memory barrier
> -		 */
> -		tsk->plug = plug;
> -	}
> +	tsk->plug = plug;
>  }
>  EXPORT_SYMBOL(blk_start_plug);
>  
> @@ -3177,12 +3177,15 @@ void blk_flush_plug_list(struct blk_plug *plug, bool from_schedule)
>  	local_irq_restore(flags);
>  }
>  
> -void blk_finish_plug(struct blk_plug *plug)
> +void blk_finish_plug(void)
>  {
> -	blk_flush_plug_list(plug, false);
> +	struct blk_plug *plug = current->plug;
>  
> -	if (plug == current->plug)
> -		current->plug = NULL;
> +	if (--plug->depth > 0)
> +		return;
> +
> +	blk_flush_plug_list(plug, false);
> +	current->plug = NULL;
>  }
>  EXPORT_SYMBOL(blk_finish_plug);
>  
> diff --git a/block/blk-lib.c b/block/blk-lib.c
> index 7688ee3..ac347d3 100644
> --- a/block/blk-lib.c
> +++ b/block/blk-lib.c
> @@ -128,7 +128,7 @@ int blkdev_issue_discard(struct block_device *bdev, sector_t sector,
>  		 */
>  		cond_resched();
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	/* Wait for bios in-flight */
>  	if (!atomic_dec_and_test(&bb.done))
> diff --git a/block/blk-throttle.c b/block/blk-throttle.c
> index 5b9c6d5..222a77a 100644
> --- a/block/blk-throttle.c
> +++ b/block/blk-throttle.c
> @@ -1281,7 +1281,7 @@ static void blk_throtl_dispatch_work_fn(struct work_struct *work)
>  		blk_start_plug(&plug);
>  		while((bio = bio_list_pop(&bio_list_on_stack)))
>  			generic_make_request(bio);
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  	}
>  }
>  
> diff --git a/drivers/block/xen-blkback/blkback.c b/drivers/block/xen-blkback/blkback.c
> index 2a04d34..74bea21 100644
> --- a/drivers/block/xen-blkback/blkback.c
> +++ b/drivers/block/xen-blkback/blkback.c
> @@ -1374,7 +1374,7 @@ static int dispatch_rw_block_io(struct xen_blkif *blkif,
>  		submit_bio(operation, biolist[i]);
>  
>  	/* Let the I/Os go.. */
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	if (operation == READ)
>  		blkif->st_rd_sect += preq.nr_sects;
> diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
> index 86dbbc7..502c63b 100644
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -715,7 +715,7 @@ static void __flush_write_list(struct list_head *write_list)
>  		submit_io(b, WRITE, b->block, write_endio);
>  		dm_bufio_cond_resched();
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  /*
> @@ -1126,7 +1126,7 @@ void dm_bufio_prefetch(struct dm_bufio_client *c,
>  				&write_list);
>  		if (unlikely(!list_empty(&write_list))) {
>  			dm_bufio_unlock(c);
> -			blk_finish_plug(&plug);
> +			blk_finish_plug();
>  			__flush_write_list(&write_list);
>  			blk_start_plug(&plug);
>  			dm_bufio_lock(c);
> @@ -1149,7 +1149,7 @@ void dm_bufio_prefetch(struct dm_bufio_client *c,
>  	dm_bufio_unlock(c);
>  
>  flush_plug:
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  EXPORT_SYMBOL_GPL(dm_bufio_prefetch);
>  
> diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> index 713a962..65d7b72 100644
> --- a/drivers/md/dm-crypt.c
> +++ b/drivers/md/dm-crypt.c
> @@ -1224,7 +1224,7 @@ pop_from_list:
>  			rb_erase(&io->rb_node, &write_tree);
>  			kcryptd_io_write(io);
>  		} while (!RB_EMPTY_ROOT(&write_tree));
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  	}
>  	return 0;
>  }
> diff --git a/drivers/md/dm-kcopyd.c b/drivers/md/dm-kcopyd.c
> index 3a7cade..4a76e42 100644
> --- a/drivers/md/dm-kcopyd.c
> +++ b/drivers/md/dm-kcopyd.c
> @@ -593,7 +593,7 @@ static void do_work(struct work_struct *work)
>  	process_jobs(&kc->complete_jobs, kc, run_complete_job);
>  	process_jobs(&kc->pages_jobs, kc, run_pages_job);
>  	process_jobs(&kc->io_jobs, kc, run_io_job);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  /*
> diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
> index 921aafd..be42bf5 100644
> --- a/drivers/md/dm-thin.c
> +++ b/drivers/md/dm-thin.c
> @@ -1824,7 +1824,7 @@ static void process_thin_deferred_bios(struct thin_c *tc)
>  			dm_pool_issue_prefetches(pool->pmd);
>  		}
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  static int cmp_cells(const void *lhs, const void *rhs)
> diff --git a/drivers/md/md.c b/drivers/md/md.c
> index 717daad..c4ec179 100644
> --- a/drivers/md/md.c
> +++ b/drivers/md/md.c
> @@ -7686,7 +7686,7 @@ void md_do_sync(struct md_thread *thread)
>  	/*
>  	 * this also signals 'finished resyncing' to md_stop
>  	 */
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	wait_event(mddev->recovery_wait, !atomic_read(&mddev->recovery_active));
>  
>  	/* tell personality that we are finished */
> diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
> index d34e238..4f8fad4 100644
> --- a/drivers/md/raid1.c
> +++ b/drivers/md/raid1.c
> @@ -2441,7 +2441,7 @@ static void raid1d(struct md_thread *thread)
>  		if (mddev->flags & ~(1<<MD_CHANGE_PENDING))
>  			md_check_recovery(mddev);
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  static int init_resync(struct r1conf *conf)
> diff --git a/drivers/md/raid10.c b/drivers/md/raid10.c
> index a7196c4..92bb5dd 100644
> --- a/drivers/md/raid10.c
> +++ b/drivers/md/raid10.c
> @@ -2835,7 +2835,7 @@ static void raid10d(struct md_thread *thread)
>  		if (mddev->flags & ~(1<<MD_CHANGE_PENDING))
>  			md_check_recovery(mddev);
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  static int init_resync(struct r10conf *conf)
> diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
> index cd2f96b..695bf0f 100644
> --- a/drivers/md/raid5.c
> +++ b/drivers/md/raid5.c
> @@ -5281,7 +5281,7 @@ static void raid5_do_work(struct work_struct *work)
>  	pr_debug("%d stripes handled\n", handled);
>  
>  	spin_unlock_irq(&conf->device_lock);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	pr_debug("--- raid5worker inactive\n");
>  }
> @@ -5352,7 +5352,7 @@ static void raid5d(struct md_thread *thread)
>  	spin_unlock_irq(&conf->device_lock);
>  
>  	async_tx_issue_pending_all();
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	pr_debug("--- raid5d inactive\n");
>  }
> diff --git a/drivers/target/target_core_iblock.c b/drivers/target/target_core_iblock.c
> index d4a4b0f..17d8730 100644
> --- a/drivers/target/target_core_iblock.c
> +++ b/drivers/target/target_core_iblock.c
> @@ -367,7 +367,7 @@ static void iblock_submit_bios(struct bio_list *list, int rw)
>  	blk_start_plug(&plug);
>  	while ((bio = bio_list_pop(list)))
>  		submit_bio(rw, bio);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  static void iblock_end_io_flush(struct bio *bio, int err)
> diff --git a/fs/aio.c b/fs/aio.c
> index f8e52a1..b873698 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -1616,7 +1616,7 @@ long do_io_submit(aio_context_t ctx_id, long nr,
>  		if (ret)
>  			break;
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	percpu_ref_put(&ctx->users);
>  	return i ? i : ret;
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 975266b..f5848de 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -1609,7 +1609,7 @@ ssize_t blkdev_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  		if (err < 0)
>  			ret = err;
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(blkdev_write_iter);
> diff --git a/fs/btrfs/scrub.c b/fs/btrfs/scrub.c
> index ec57687..f314cfb8 100644
> --- a/fs/btrfs/scrub.c
> +++ b/fs/btrfs/scrub.c
> @@ -3316,7 +3316,7 @@ out:
>  	scrub_wr_submit(sctx);
>  	mutex_unlock(&sctx->wr_ctx.wr_lock);
>  
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	btrfs_free_path(path);
>  	btrfs_free_path(ppath);
>  	return ret < 0 ? ret : 0;
> diff --git a/fs/btrfs/transaction.c b/fs/btrfs/transaction.c
> index 8be4278..fee10af 100644
> --- a/fs/btrfs/transaction.c
> +++ b/fs/btrfs/transaction.c
> @@ -983,7 +983,7 @@ static int btrfs_write_and_wait_marked_extents(struct btrfs_root *root,
>  
>  	blk_start_plug(&plug);
>  	ret = btrfs_write_marked_extents(root, dirty_pages, mark);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	ret2 = btrfs_wait_marked_extents(root, dirty_pages, mark);
>  
>  	if (ret)
> diff --git a/fs/btrfs/tree-log.c b/fs/btrfs/tree-log.c
> index c5b8ba3..879c7fd 100644
> --- a/fs/btrfs/tree-log.c
> +++ b/fs/btrfs/tree-log.c
> @@ -2574,7 +2574,7 @@ int btrfs_sync_log(struct btrfs_trans_handle *trans,
>  	blk_start_plug(&plug);
>  	ret = btrfs_write_marked_extents(log, &log->dirty_log_pages, mark);
>  	if (ret) {
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  		btrfs_abort_transaction(trans, root, ret);
>  		btrfs_free_logged_extents(log, log_transid);
>  		btrfs_set_log_full_commit(root->fs_info, trans);
> @@ -2619,7 +2619,7 @@ int btrfs_sync_log(struct btrfs_trans_handle *trans,
>  		if (!list_empty(&root_log_ctx.list))
>  			list_del_init(&root_log_ctx.list);
>  
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  		btrfs_set_log_full_commit(root->fs_info, trans);
>  
>  		if (ret != -ENOSPC) {
> @@ -2635,7 +2635,7 @@ int btrfs_sync_log(struct btrfs_trans_handle *trans,
>  	}
>  
>  	if (log_root_tree->log_transid_committed >= root_log_ctx.log_transid) {
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  		mutex_unlock(&log_root_tree->log_mutex);
>  		ret = root_log_ctx.log_ret;
>  		goto out;
> @@ -2643,7 +2643,7 @@ int btrfs_sync_log(struct btrfs_trans_handle *trans,
>  
>  	index2 = root_log_ctx.log_transid % 2;
>  	if (atomic_read(&log_root_tree->log_commit[index2])) {
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  		ret = btrfs_wait_marked_extents(log, &log->dirty_log_pages,
>  						mark);
>  		btrfs_wait_logged_extents(trans, log, log_transid);
> @@ -2669,7 +2669,7 @@ int btrfs_sync_log(struct btrfs_trans_handle *trans,
>  	 * check the full commit flag again
>  	 */
>  	if (btrfs_need_log_full_commit(root->fs_info, trans)) {
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  		btrfs_wait_marked_extents(log, &log->dirty_log_pages, mark);
>  		btrfs_free_logged_extents(log, log_transid);
>  		mutex_unlock(&log_root_tree->log_mutex);
> @@ -2680,7 +2680,7 @@ int btrfs_sync_log(struct btrfs_trans_handle *trans,
>  	ret = btrfs_write_marked_extents(log_root_tree,
>  					 &log_root_tree->dirty_log_pages,
>  					 EXTENT_DIRTY | EXTENT_NEW);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	if (ret) {
>  		btrfs_set_log_full_commit(root->fs_info, trans);
>  		btrfs_abort_transaction(trans, root, ret);
> diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
> index 8222f6f..16db068 100644
> --- a/fs/btrfs/volumes.c
> +++ b/fs/btrfs/volumes.c
> @@ -358,7 +358,7 @@ loop_lock:
>  		if (pending_bios == &device->pending_sync_bios) {
>  			sync_pending = 1;
>  		} else if (sync_pending) {
> -			blk_finish_plug(&plug);
> +			blk_finish_plug();
>  			blk_start_plug(&plug);
>  			sync_pending = 0;
>  		}
> @@ -415,7 +415,7 @@ loop_lock:
>  		}
>  		/* unplug every 64 requests just for good measure */
>  		if (batch_run % 64 == 0) {
> -			blk_finish_plug(&plug);
> +			blk_finish_plug();
>  			blk_start_plug(&plug);
>  			sync_pending = 0;
>  		}
> @@ -431,7 +431,7 @@ loop_lock:
>  	spin_unlock(&device->io_lock);
>  
>  done:
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  static void pending_bios_fn(struct btrfs_work *work)
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 20805db..8181c44 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -758,7 +758,7 @@ static int fsync_buffers_list(spinlock_t *lock, struct list_head *list)
>  	}
>  
>  	spin_unlock(lock);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	spin_lock(lock);
>  
>  	while (!list_empty(&tmp)) {
> diff --git a/fs/direct-io.c b/fs/direct-io.c
> index e181b6b..16f16ed 100644
> --- a/fs/direct-io.c
> +++ b/fs/direct-io.c
> @@ -1262,7 +1262,7 @@ do_blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
>  	if (sdio.bio)
>  		dio_bio_submit(dio, &sdio);
>  
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	/*
>  	 * It is possible that, we return short IO due to end of file.
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 33a09da..3a293eb 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -183,7 +183,7 @@ ext4_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  			ret = err;
>  	}
>  	if (o_direct)
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  
>  errout:
>  	if (aio_mutex)
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 5cb9a21..90ce0cb 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -2302,7 +2302,7 @@ static int ext4_writepages(struct address_space *mapping,
>  
>  		blk_start_plug(&plug);
>  		ret = write_cache_pages(mapping, wbc, __writepage, mapping);
> -		blk_finish_plug(&plug);
> +		blk_finish_plug();
>  		goto out_writepages;
>  	}
>  
> @@ -2438,7 +2438,7 @@ retry:
>  		if (ret)
>  			break;
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	if (!ret && !cycled && wbc->nr_to_write > 0) {
>  		cycled = 1;
>  		mpd.last_page = writeback_index - 1;
> diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
> index 7f794b7..86ba453 100644
> --- a/fs/f2fs/checkpoint.c
> +++ b/fs/f2fs/checkpoint.c
> @@ -846,7 +846,7 @@ retry_flush_nodes:
>  		goto retry_flush_nodes;
>  	}
>  out:
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	return err;
>  }
>  
> diff --git a/fs/f2fs/gc.c b/fs/f2fs/gc.c
> index 76adbc3..abeef77 100644
> --- a/fs/f2fs/gc.c
> +++ b/fs/f2fs/gc.c
> @@ -678,7 +678,7 @@ static void do_garbage_collect(struct f2fs_sb_info *sbi, unsigned int segno,
>  		gc_data_segment(sbi, sum->entries, gc_list, segno, gc_type);
>  		break;
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	stat_inc_seg_count(sbi, GET_SUM_TYPE((&sum->footer)));
>  	stat_inc_call_count(sbi->stat_info);
> diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
> index 97bd9d3..c4aa9e2 100644
> --- a/fs/f2fs/node.c
> +++ b/fs/f2fs/node.c
> @@ -1098,7 +1098,7 @@ repeat:
>  		ra_node_page(sbi, nid);
>  	}
>  
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	lock_page(page);
>  	if (unlikely(page->mapping != NODE_MAPPING(sbi))) {
> diff --git a/fs/gfs2/log.c b/fs/gfs2/log.c
> index 536e7a6..06f25d17 100644
> --- a/fs/gfs2/log.c
> +++ b/fs/gfs2/log.c
> @@ -159,7 +159,7 @@ restart:
>  			goto restart;
>  	}
>  	spin_unlock(&sdp->sd_ail_lock);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	trace_gfs2_ail_flush(sdp, wbc, 0);
>  }
>  
> diff --git a/fs/hpfs/buffer.c b/fs/hpfs/buffer.c
> index 8057fe4..138462d 100644
> --- a/fs/hpfs/buffer.c
> +++ b/fs/hpfs/buffer.c
> @@ -35,7 +35,7 @@ void hpfs_prefetch_sectors(struct super_block *s, unsigned secno, int n)
>  		secno++;
>  		n--;
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  /* Map a sector into a buffer and return pointers to it and to the buffer. */
> diff --git a/fs/jbd/checkpoint.c b/fs/jbd/checkpoint.c
> index 08c0304..cd6b09f 100644
> --- a/fs/jbd/checkpoint.c
> +++ b/fs/jbd/checkpoint.c
> @@ -263,7 +263,7 @@ __flush_batch(journal_t *journal, struct buffer_head **bhs, int *batch_count)
>  	blk_start_plug(&plug);
>  	for (i = 0; i < *batch_count; i++)
>  		write_dirty_buffer(bhs[i], WRITE_SYNC);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	for (i = 0; i < *batch_count; i++) {
>  		struct buffer_head *bh = bhs[i];
> diff --git a/fs/jbd/commit.c b/fs/jbd/commit.c
> index bb217dc..e1046c3 100644
> --- a/fs/jbd/commit.c
> +++ b/fs/jbd/commit.c
> @@ -447,7 +447,7 @@ void journal_commit_transaction(journal_t *journal)
>  	blk_start_plug(&plug);
>  	err = journal_submit_data_buffers(journal, commit_transaction,
>  					  write_op);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	/*
>  	 * Wait for all previously submitted IO to complete.
> @@ -697,7 +697,7 @@ start_journal_io:
>  		}
>  	}
>  
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	/* Lo and behold: we have just managed to send a transaction to
>             the log.  Before we can commit it, wait for the IO so far to
> diff --git a/fs/jbd2/checkpoint.c b/fs/jbd2/checkpoint.c
> index 988b32e..6aa0039 100644
> --- a/fs/jbd2/checkpoint.c
> +++ b/fs/jbd2/checkpoint.c
> @@ -187,7 +187,7 @@ __flush_batch(journal_t *journal, int *batch_count)
>  	blk_start_plug(&plug);
>  	for (i = 0; i < *batch_count; i++)
>  		write_dirty_buffer(journal->j_chkpt_bhs[i], WRITE_SYNC);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	for (i = 0; i < *batch_count; i++) {
>  		struct buffer_head *bh = journal->j_chkpt_bhs[i];
> diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
> index b73e021..8f532c8 100644
> --- a/fs/jbd2/commit.c
> +++ b/fs/jbd2/commit.c
> @@ -805,7 +805,7 @@ start_journal_io:
>  			__jbd2_journal_abort_hard(journal);
>  	}
>  
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	/* Lo and behold: we have just managed to send a transaction to
>             the log.  Before we can commit it, wait for the IO so far to
> diff --git a/fs/mpage.c b/fs/mpage.c
> index 3e79220..bf7d6c3 100644
> --- a/fs/mpage.c
> +++ b/fs/mpage.c
> @@ -695,7 +695,7 @@ mpage_writepages(struct address_space *mapping,
>  		if (mpd.bio)
>  			mpage_bio_submit(WRITE, mpd.bio);
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	return ret;
>  }
>  EXPORT_SYMBOL(mpage_writepages);
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 1cac3c1..e93b6a8 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -311,7 +311,7 @@ bl_read_pagelist(struct nfs_pgio_header *header)
>  	}
>  out:
>  	bl_submit_bio(READ, bio);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	put_parallel(par);
>  	return PNFS_ATTEMPTED;
>  }
> @@ -433,7 +433,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
>  	header->res.count = header->args.count;
>  out:
>  	bl_submit_bio(WRITE, bio);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	put_parallel(par);
>  	return PNFS_ATTEMPTED;
>  }
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index 1790b00..2f89ca2 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1289,7 +1289,7 @@ _xfs_buf_ioapply(
>  		if (size <= 0)
>  			break;	/* all done */
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  /*
> @@ -1823,7 +1823,7 @@ __xfs_buf_delwri_submit(
>  
>  		xfs_buf_submit(bp);
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	return pinned;
>  }
> diff --git a/fs/xfs/xfs_dir2_readdir.c b/fs/xfs/xfs_dir2_readdir.c
> index 098cd78..7e8fa3f 100644
> --- a/fs/xfs/xfs_dir2_readdir.c
> +++ b/fs/xfs/xfs_dir2_readdir.c
> @@ -455,7 +455,7 @@ xfs_dir2_leaf_readbuf(
>  			}
>  		}
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  out:
>  	*bpp = bp;
> diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
> index 82e3142..c3ac5ec 100644
> --- a/fs/xfs/xfs_itable.c
> +++ b/fs/xfs/xfs_itable.c
> @@ -196,7 +196,7 @@ xfs_bulkstat_ichunk_ra(
>  					     &xfs_inode_buf_ops);
>  		}
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  }
>  
>  /*
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index 7f9a516..188133f 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -1091,6 +1091,7 @@ static inline void blk_post_runtime_resume(struct request_queue *q, int err) {}
>   * schedule() where blk_schedule_flush_plug() is called.
>   */
>  struct blk_plug {
> +	int depth; /* number of nested plugs */
>  	struct list_head list; /* requests */
>  	struct list_head mq_list; /* blk-mq requests */
>  	struct list_head cb_list; /* md requires an unplug callback */
> @@ -1107,7 +1108,7 @@ struct blk_plug_cb {
>  extern struct blk_plug_cb *blk_check_plugged(blk_plug_cb_fn unplug,
>  					     void *data, int size);
>  extern void blk_start_plug(struct blk_plug *);
> -extern void blk_finish_plug(struct blk_plug *);
> +extern void blk_finish_plug(void);
>  extern void blk_flush_plug_list(struct blk_plug *, bool);
>  
>  static inline void blk_flush_plug(struct task_struct *tsk)
> @@ -1646,7 +1647,7 @@ static inline void blk_start_plug(struct blk_plug *plug)
>  {
>  }
>  
> -static inline void blk_finish_plug(struct blk_plug *plug)
> +static inline void blk_finish_plug(void)
>  {
>  }
>  
> diff --git a/mm/madvise.c b/mm/madvise.c
> index d551475..18a34ee 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -539,7 +539,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  			vma = find_vma(current->mm, start);
>  	}
>  out:
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	if (write)
>  		up_write(&current->mm->mmap_sem);
>  	else
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 644bcb6..4570f6e 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2020,7 +2020,7 @@ int generic_writepages(struct address_space *mapping,
>  
>  	blk_start_plug(&plug);
>  	ret = write_cache_pages(mapping, wbc, __writepage, mapping);
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	return ret;
>  }
>  
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 9356758..64182a2 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -136,7 +136,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
>  	ret = 0;
>  
>  out:
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	return ret;
>  }
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 405923f..5721f64 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -478,7 +478,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  			SetPageReadahead(page);
>  		page_cache_release(page);
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  
>  	lru_add_drain();	/* Push any new pages onto the LRU now */
>  skip:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5e8eadd..56bb274 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2222,7 +2222,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
>  
>  		scan_adjusted = true;
>  	}
> -	blk_finish_plug(&plug);
> +	blk_finish_plug();
>  	sc->nr_reclaimed += nr_reclaimed;
>  
>  	/*
> -- 
> 1.8.3.1
> 
> 

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
