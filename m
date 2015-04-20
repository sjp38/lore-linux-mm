Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id BB4A46B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:37:16 -0400 (EDT)
Received: by wizk4 with SMTP id k4so104506293wiz.1
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 08:37:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dv1si16640299wib.97.2015.04.20.08.37.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 08:37:15 -0700 (PDT)
Date: Mon, 20 Apr 2015 17:37:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 17/49] writeback: separate out
 include/linux/backing-dev-defs.h
Message-ID: <20150420153710.GG17020@quack.suse.cz>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-18-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428350318-8215-18-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon 06-04-15 15:58:06, Tejun Heo wrote:
> With the planned cgroup writeback support, backing-dev related
> declarations will be more widely used across block and cgroup;
> unfortunately, including backing-dev.h from include/linux/blkdev.h
> makes cyclic include dependency quite likely.
> 
> This patch separates out backing-dev-defs.h which only has the
> essential definitions and updates blkdev.h to include it.  c files
> which need access to more backing-dev details now include
> backing-dev.h directly.  This takes backing-dev.h off the common
> include dependency chain making it a lot easier to use it across block
> and cgroup.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  block/blk-integrity.c            |   1 +
>  block/blk-sysfs.c                |   1 +
>  block/bounce.c                   |   1 +
>  block/genhd.c                    |   1 +
>  drivers/block/drbd/drbd_int.h    |   1 +
>  drivers/block/pktcdvd.c          |   1 +
>  drivers/char/raw.c               |   1 +
>  drivers/md/bcache/request.c      |   1 +
>  drivers/md/dm.h                  |   1 +
>  drivers/md/md.h                  |   1 +
>  drivers/mtd/devices/block2mtd.c  |   1 +
>  fs/block_dev.c                   |   1 +
>  fs/ext4/extents.c                |   1 +
>  fs/ext4/mballoc.c                |   1 +
>  fs/ext4/super.c                  |   1 +
>  fs/f2fs/segment.h                |   1 +
>  fs/hfs/super.c                   |   1 +
>  fs/hfsplus/super.c               |   1 +
>  fs/nfs/filelayout/filelayout.c   |   1 +
>  fs/ocfs2/file.c                  |   1 +
>  fs/reiserfs/super.c              |   1 +
>  fs/ufs/super.c                   |   1 +
>  fs/xfs/xfs_file.c                |   1 +
>  include/linux/backing-dev-defs.h | 106 +++++++++++++++++++++++++++++++++++++++
>  include/linux/backing-dev.h      | 102 +------------------------------------
>  include/linux/blkdev.h           |   2 +-
>  mm/madvise.c                     |   1 +
>  27 files changed, 132 insertions(+), 102 deletions(-)
>  create mode 100644 include/linux/backing-dev-defs.h
> 
> diff --git a/block/blk-integrity.c b/block/blk-integrity.c
> index 79ffb48..f548b64 100644
> --- a/block/blk-integrity.c
> +++ b/block/blk-integrity.c
> @@ -21,6 +21,7 @@
>   */
>  
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/mempool.h>
>  #include <linux/bio.h>
>  #include <linux/scatterlist.h>
> diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
> index 5677eb7..1b60941 100644
> --- a/block/blk-sysfs.c
> +++ b/block/blk-sysfs.c
> @@ -6,6 +6,7 @@
>  #include <linux/module.h>
>  #include <linux/bio.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/blktrace_api.h>
>  #include <linux/blk-mq.h>
>  #include <linux/blk-cgroup.h>
> diff --git a/block/bounce.c b/block/bounce.c
> index ab21ba2..c616a60 100644
> --- a/block/bounce.c
> +++ b/block/bounce.c
> @@ -13,6 +13,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/mempool.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/init.h>
>  #include <linux/hash.h>
>  #include <linux/highmem.h>
> diff --git a/block/genhd.c b/block/genhd.c
> index 0a536dc..d46ba56 100644
> --- a/block/genhd.c
> +++ b/block/genhd.c
> @@ -8,6 +8,7 @@
>  #include <linux/kdev_t.h>
>  #include <linux/kernel.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/init.h>
>  #include <linux/spinlock.h>
>  #include <linux/proc_fs.h>
> diff --git a/drivers/block/drbd/drbd_int.h b/drivers/block/drbd/drbd_int.h
> index b905e98..efd19c2 100644
> --- a/drivers/block/drbd/drbd_int.h
> +++ b/drivers/block/drbd/drbd_int.h
> @@ -38,6 +38,7 @@
>  #include <linux/mutex.h>
>  #include <linux/major.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/genhd.h>
>  #include <linux/idr.h>
>  #include <net/tcp.h>
> diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
> index 09e628da..4c20c22 100644
> --- a/drivers/block/pktcdvd.c
> +++ b/drivers/block/pktcdvd.c
> @@ -61,6 +61,7 @@
>  #include <linux/freezer.h>
>  #include <linux/mutex.h>
>  #include <linux/slab.h>
> +#include <linux/backing-dev.h>
>  #include <scsi/scsi_cmnd.h>
>  #include <scsi/scsi_ioctl.h>
>  #include <scsi/scsi.h>
> diff --git a/drivers/char/raw.c b/drivers/char/raw.c
> index 6e29bf2..ee47e59 100644
> --- a/drivers/char/raw.c
> +++ b/drivers/char/raw.c
> @@ -12,6 +12,7 @@
>  #include <linux/fs.h>
>  #include <linux/major.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/module.h>
>  #include <linux/raw.h>
>  #include <linux/capability.h>
> diff --git a/drivers/md/bcache/request.c b/drivers/md/bcache/request.c
> index ab43fad..9c083b9 100644
> --- a/drivers/md/bcache/request.c
> +++ b/drivers/md/bcache/request.c
> @@ -15,6 +15,7 @@
>  #include <linux/module.h>
>  #include <linux/hash.h>
>  #include <linux/random.h>
> +#include <linux/backing-dev.h>
>  
>  #include <trace/events/bcache.h>
>  
> diff --git a/drivers/md/dm.h b/drivers/md/dm.h
> index 59f53e7..ae4a3ca 100644
> --- a/drivers/md/dm.h
> +++ b/drivers/md/dm.h
> @@ -14,6 +14,7 @@
>  #include <linux/device-mapper.h>
>  #include <linux/list.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/hdreg.h>
>  #include <linux/completion.h>
>  #include <linux/kobject.h>
> diff --git a/drivers/md/md.h b/drivers/md/md.h
> index 318ca8f..641abb5 100644
> --- a/drivers/md/md.h
> +++ b/drivers/md/md.h
> @@ -16,6 +16,7 @@
>  #define _MD_MD_H
>  
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/kobject.h>
>  #include <linux/list.h>
>  #include <linux/mm.h>
> diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
> index 66f0405..e22e40f 100644
> --- a/drivers/mtd/devices/block2mtd.c
> +++ b/drivers/mtd/devices/block2mtd.c
> @@ -12,6 +12,7 @@
>  #include <linux/module.h>
>  #include <linux/fs.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/bio.h>
>  #include <linux/pagemap.h>
>  #include <linux/list.h>
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 975266b..e4f5f71 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -14,6 +14,7 @@
>  #include <linux/device_cgroup.h>
>  #include <linux/highmem.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/module.h>
>  #include <linux/blkpg.h>
>  #include <linux/magic.h>
> diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
> index bed4308..21a7bcb 100644
> --- a/fs/ext4/extents.c
> +++ b/fs/ext4/extents.c
> @@ -39,6 +39,7 @@
>  #include <linux/slab.h>
>  #include <asm/uaccess.h>
>  #include <linux/fiemap.h>
> +#include <linux/backing-dev.h>
>  #include "ext4_jbd2.h"
>  #include "ext4_extents.h"
>  #include "xattr.h"
> diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
> index 8d1e602..440987c 100644
> --- a/fs/ext4/mballoc.c
> +++ b/fs/ext4/mballoc.c
> @@ -26,6 +26,7 @@
>  #include <linux/log2.h>
>  #include <linux/module.h>
>  #include <linux/slab.h>
> +#include <linux/backing-dev.h>
>  #include <trace/events/ext4.h>
>  
>  #ifdef CONFIG_EXT4_DEBUG
> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> index e061e66..6072515 100644
> --- a/fs/ext4/super.c
> +++ b/fs/ext4/super.c
> @@ -25,6 +25,7 @@
>  #include <linux/slab.h>
>  #include <linux/init.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/parser.h>
>  #include <linux/buffer_head.h>
>  #include <linux/exportfs.h>
> diff --git a/fs/f2fs/segment.h b/fs/f2fs/segment.h
> index 3a5bfcf..69a305c 100644
> --- a/fs/f2fs/segment.h
> +++ b/fs/f2fs/segment.h
> @@ -9,6 +9,7 @@
>   * published by the Free Software Foundation.
>   */
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  
>  /* constant macro */
>  #define NULL_SEGNO			((unsigned int)(~0))
> diff --git a/fs/hfs/super.c b/fs/hfs/super.c
> index eee7206..55c03b9 100644
> --- a/fs/hfs/super.c
> +++ b/fs/hfs/super.c
> @@ -14,6 +14,7 @@
>  
>  #include <linux/module.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/mount.h>
>  #include <linux/init.h>
>  #include <linux/nls.h>
> diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
> index 593af2f..7302d96 100644
> --- a/fs/hfsplus/super.c
> +++ b/fs/hfsplus/super.c
> @@ -11,6 +11,7 @@
>  #include <linux/init.h>
>  #include <linux/pagemap.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/fs.h>
>  #include <linux/slab.h>
>  #include <linux/vfs.h>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 91e88a7..87ea50c 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -32,6 +32,7 @@
>  #include <linux/nfs_fs.h>
>  #include <linux/nfs_page.h>
>  #include <linux/module.h>
> +#include <linux/backing-dev.h>
>  
>  #include <linux/sunrpc/metrics.h>
>  
> diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
> index 46e0d4e..0b20260 100644
> --- a/fs/ocfs2/file.c
> +++ b/fs/ocfs2/file.c
> @@ -37,6 +37,7 @@
>  #include <linux/falloc.h>
>  #include <linux/quotaops.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  
>  #include <cluster/masklog.h>
>  
> diff --git a/fs/reiserfs/super.c b/fs/reiserfs/super.c
> index 71fbbe3..badcf7b 100644
> --- a/fs/reiserfs/super.c
> +++ b/fs/reiserfs/super.c
> @@ -21,6 +21,7 @@
>  #include "xattr.h"
>  #include <linux/init.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/buffer_head.h>
>  #include <linux/exportfs.h>
>  #include <linux/quotaops.h>
> diff --git a/fs/ufs/super.c b/fs/ufs/super.c
> index 8092d37..3e39fc5 100644
> --- a/fs/ufs/super.c
> +++ b/fs/ufs/super.c
> @@ -80,6 +80,7 @@
>  #include <linux/stat.h>
>  #include <linux/string.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/init.h>
>  #include <linux/parser.h>
>  #include <linux/buffer_head.h>
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index a2e1cb8..e6ab446 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -42,6 +42,7 @@
>  #include <linux/dcache.h>
>  #include <linux/falloc.h>
>  #include <linux/pagevec.h>
> +#include <linux/backing-dev.h>
>  
>  static const struct vm_operations_struct xfs_file_vm_ops;
>  
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> new file mode 100644
> index 0000000..aa18c4b
> --- /dev/null
> +++ b/include/linux/backing-dev-defs.h
> @@ -0,0 +1,106 @@
> +#ifndef __LINUX_BACKING_DEV_DEFS_H
> +#define __LINUX_BACKING_DEV_DEFS_H
> +
> +#include <linux/list.h>
> +#include <linux/spinlock.h>
> +#include <linux/percpu_counter.h>
> +#include <linux/flex_proportions.h>
> +#include <linux/timer.h>
> +#include <linux/workqueue.h>
> +
> +struct page;
> +struct device;
> +struct dentry;
> +
> +/*
> + * Bits in bdi_writeback.state
> + */
> +enum wb_state {
> +	WB_async_congested,	/* The async (write) queue is getting full */
> +	WB_sync_congested,	/* The sync queue is getting full */
> +	WB_registered,		/* bdi_register() was done */
> +	WB_writeback_running,	/* Writeback is in progress */
> +};
> +
> +typedef int (congested_fn)(void *, int);
> +
> +enum wb_stat_item {
> +	WB_RECLAIMABLE,
> +	WB_WRITEBACK,
> +	WB_DIRTIED,
> +	WB_WRITTEN,
> +	NR_WB_STAT_ITEMS
> +};
> +
> +#define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
> +
> +struct bdi_writeback {
> +	struct backing_dev_info *bdi;	/* our parent bdi */
> +
> +	unsigned long state;		/* Always use atomic bitops on this */
> +	unsigned long last_old_flush;	/* last old data flush */
> +
> +	struct list_head b_dirty;	/* dirty inodes */
> +	struct list_head b_io;		/* parked for writeback */
> +	struct list_head b_more_io;	/* parked for more writeback */
> +	struct list_head b_dirty_time;	/* time stamps are dirty */
> +	spinlock_t list_lock;		/* protects the b_* lists */
> +
> +	struct percpu_counter stat[NR_WB_STAT_ITEMS];
> +
> +	unsigned long bw_time_stamp;	/* last time write bw is updated */
> +	unsigned long dirtied_stamp;
> +	unsigned long written_stamp;	/* pages written at bw_time_stamp */
> +	unsigned long write_bandwidth;	/* the estimated write bandwidth */
> +	unsigned long avg_write_bandwidth; /* further smoothed write bw */
> +
> +	/*
> +	 * The base dirty throttle rate, re-calculated on every 200ms.
> +	 * All the bdi tasks' dirty rate will be curbed under it.
> +	 * @dirty_ratelimit tracks the estimated @balanced_dirty_ratelimit
> +	 * in small steps and is much more smooth/stable than the latter.
> +	 */
> +	unsigned long dirty_ratelimit;
> +	unsigned long balanced_dirty_ratelimit;
> +
> +	struct fprop_local_percpu completions;
> +	int dirty_exceeded;
> +
> +	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
> +	struct list_head work_list;
> +	struct delayed_work dwork;	/* work item used for writeback */
> +};
> +
> +struct backing_dev_info {
> +	struct list_head bdi_list;
> +	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
> +	unsigned int capabilities; /* Device capabilities */
> +	congested_fn *congested_fn; /* Function pointer if device is md/dm */
> +	void *congested_data;	/* Pointer to aux data for congested func */
> +
> +	char *name;
> +
> +	unsigned int min_ratio;
> +	unsigned int max_ratio, max_prop_frac;
> +
> +	struct bdi_writeback wb;  /* default writeback info for this bdi */
> +
> +	struct device *dev;
> +
> +	struct timer_list laptop_mode_wb_timer;
> +
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *debug_dir;
> +	struct dentry *debug_stats;
> +#endif
> +};
> +
> +enum {
> +	BLK_RW_ASYNC	= 0,
> +	BLK_RW_SYNC	= 1,
> +};
> +
> +void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
> +void set_bdi_congested(struct backing_dev_info *bdi, int sync);
> +
> +#endif	/* __LINUX_BACKING_DEV_DEFS_H */
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index d796f49..5e39f7a 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -8,104 +8,11 @@
>  #ifndef _LINUX_BACKING_DEV_H
>  #define _LINUX_BACKING_DEV_H
>  
> -#include <linux/percpu_counter.h>
> -#include <linux/log2.h>
> -#include <linux/flex_proportions.h>
>  #include <linux/kernel.h>
>  #include <linux/fs.h>
>  #include <linux/sched.h>
> -#include <linux/timer.h>
>  #include <linux/writeback.h>
> -#include <linux/atomic.h>
> -#include <linux/sysctl.h>
> -#include <linux/workqueue.h>
> -
> -struct page;
> -struct device;
> -struct dentry;
> -
> -/*
> - * Bits in bdi_writeback.state
> - */
> -enum wb_state {
> -	WB_async_congested,	/* The async (write) queue is getting full */
> -	WB_sync_congested,	/* The sync queue is getting full */
> -	WB_registered,		/* bdi_register() was done */
> -	WB_writeback_running,	/* Writeback is in progress */
> -};
> -
> -typedef int (congested_fn)(void *, int);
> -
> -enum wb_stat_item {
> -	WB_RECLAIMABLE,
> -	WB_WRITEBACK,
> -	WB_DIRTIED,
> -	WB_WRITTEN,
> -	NR_WB_STAT_ITEMS
> -};
> -
> -#define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
> -
> -struct bdi_writeback {
> -	struct backing_dev_info *bdi;	/* our parent bdi */
> -
> -	unsigned long state;		/* Always use atomic bitops on this */
> -	unsigned long last_old_flush;	/* last old data flush */
> -
> -	struct list_head b_dirty;	/* dirty inodes */
> -	struct list_head b_io;		/* parked for writeback */
> -	struct list_head b_more_io;	/* parked for more writeback */
> -	struct list_head b_dirty_time;	/* time stamps are dirty */
> -	spinlock_t list_lock;		/* protects the b_* lists */
> -
> -	struct percpu_counter stat[NR_WB_STAT_ITEMS];
> -
> -	unsigned long bw_time_stamp;	/* last time write bw is updated */
> -	unsigned long dirtied_stamp;
> -	unsigned long written_stamp;	/* pages written at bw_time_stamp */
> -	unsigned long write_bandwidth;	/* the estimated write bandwidth */
> -	unsigned long avg_write_bandwidth; /* further smoothed write bw */
> -
> -	/*
> -	 * The base dirty throttle rate, re-calculated on every 200ms.
> -	 * All the bdi tasks' dirty rate will be curbed under it.
> -	 * @dirty_ratelimit tracks the estimated @balanced_dirty_ratelimit
> -	 * in small steps and is much more smooth/stable than the latter.
> -	 */
> -	unsigned long dirty_ratelimit;
> -	unsigned long balanced_dirty_ratelimit;
> -
> -	struct fprop_local_percpu completions;
> -	int dirty_exceeded;
> -
> -	spinlock_t work_lock;		/* protects work_list & dwork scheduling */
> -	struct list_head work_list;
> -	struct delayed_work dwork;	/* work item used for writeback */
> -};
> -
> -struct backing_dev_info {
> -	struct list_head bdi_list;
> -	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
> -	unsigned int capabilities; /* Device capabilities */
> -	congested_fn *congested_fn; /* Function pointer if device is md/dm */
> -	void *congested_data;	/* Pointer to aux data for congested func */
> -
> -	char *name;
> -
> -	unsigned int min_ratio;
> -	unsigned int max_ratio, max_prop_frac;
> -
> -	struct bdi_writeback wb;  /* default writeback info for this bdi */
> -
> -	struct device *dev;
> -
> -	struct timer_list laptop_mode_wb_timer;
> -
> -#ifdef CONFIG_DEBUG_FS
> -	struct dentry *debug_dir;
> -	struct dentry *debug_stats;
> -#endif
> -};
> +#include <linux/backing-dev-defs.h>
>  
>  struct backing_dev_info *inode_to_bdi(struct inode *inode);
>  
> @@ -265,13 +172,6 @@ static inline int bdi_rw_congested(struct backing_dev_info *bdi)
>  				  (1 << WB_async_congested));
>  }
>  
> -enum {
> -	BLK_RW_ASYNC	= 0,
> -	BLK_RW_SYNC	= 1,
> -};
> -
> -void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
> -void set_bdi_congested(struct backing_dev_info *bdi, int sync);
>  long congestion_wait(int sync, long timeout);
>  long wait_iff_congested(struct zone *zone, int sync, long timeout);
>  int pdflush_proc_obsolete(struct ctl_table *table, int write,
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index 7f9a516..28ea264 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -12,7 +12,7 @@
>  #include <linux/timer.h>
>  #include <linux/workqueue.h>
>  #include <linux/pagemap.h>
> -#include <linux/backing-dev.h>
> +#include <linux/backing-dev-defs.h>
>  #include <linux/wait.h>
>  #include <linux/mempool.h>
>  #include <linux/bio.h>
> diff --git a/mm/madvise.c b/mm/madvise.c
> index d551475..64bb8a2 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -17,6 +17,7 @@
>  #include <linux/fs.h>
>  #include <linux/file.h>
>  #include <linux/blkdev.h>
> +#include <linux/backing-dev.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  
> -- 
> 2.1.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
