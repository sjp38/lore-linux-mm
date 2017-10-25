Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF0486B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 02:01:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q127so420370wmd.1
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 23:01:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b74sor608966wme.62.2017.10.24.23.01.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 23:01:27 -0700 (PDT)
Date: Wed, 25 Oct 2017 08:01:24 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 7/7] block: Assign a lock_class per gendisk used for
 wait_for_completion()
Message-ID: <20171025060123.6mugpdpje6hx32nx@gmail.com>
References: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
 <1508908272-15757-8-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508908272-15757-8-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, axboe@kernel.dk, johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> Darrick posted the following warning and Dave Chinner analyzed it:
> 
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 4.14.0-rc1-fixes #1 Tainted: G        W
> > ------------------------------------------------------
> > loop0/31693 is trying to acquire lock:
> >  (&(&ip->i_mmaplock)->mr_lock){++++}, at: [<ffffffffa00f1b0c>] xfs_ilock+0x23c/0x330 [xfs]
> >
> > but now in release context of a crosslock acquired at the following:
> >  ((complete)&ret.event){+.+.}, at: [<ffffffff81326c1f>] submit_bio_wait+0x7f/0xb0
> >
> > which lock already depends on the new lock.
> >
> > the existing dependency chain (in reverse order) is:
> >
> > -> #2 ((complete)&ret.event){+.+.}:
> >        lock_acquire+0xab/0x200
> >        wait_for_completion_io+0x4e/0x1a0
> >        submit_bio_wait+0x7f/0xb0
> >        blkdev_issue_zeroout+0x71/0xa0
> >        xfs_bmapi_convert_unwritten+0x11f/0x1d0 [xfs]
> >        xfs_bmapi_write+0x374/0x11f0 [xfs]
> >        xfs_iomap_write_direct+0x2ac/0x430 [xfs]
> >        xfs_file_iomap_begin+0x20d/0xd50 [xfs]
> >        iomap_apply+0x43/0xe0
> >        dax_iomap_rw+0x89/0xf0
> >        xfs_file_dax_write+0xcc/0x220 [xfs]
> >        xfs_file_write_iter+0xf0/0x130 [xfs]
> >        __vfs_write+0xd9/0x150
> >        vfs_write+0xc8/0x1c0
> >        SyS_write+0x45/0xa0
> >        entry_SYSCALL_64_fastpath+0x1f/0xbe
> >
> > -> #1 (&xfs_nondir_ilock_class){++++}:
> >        lock_acquire+0xab/0x200
> >        down_write_nested+0x4a/0xb0
> >        xfs_ilock+0x263/0x330 [xfs]
> >        xfs_setattr_size+0x152/0x370 [xfs]
> >        xfs_vn_setattr+0x6b/0x90 [xfs]
> >        notify_change+0x27d/0x3f0
> >        do_truncate+0x5b/0x90
> >        path_openat+0x237/0xa90
> >        do_filp_open+0x8a/0xf0
> >        do_sys_open+0x11c/0x1f0
> >        entry_SYSCALL_64_fastpath+0x1f/0xbe
> >
> > -> #0 (&(&ip->i_mmaplock)->mr_lock){++++}:
> >        up_write+0x1c/0x40
> >        xfs_iunlock+0x1d0/0x310 [xfs]
> >        xfs_file_fallocate+0x8a/0x310 [xfs]
> >        loop_queue_work+0xb7/0x8d0
> >        kthread_worker_fn+0xb9/0x1f0
> >
> > Chain exists of:
> >   &(&ip->i_mmaplock)->mr_lock --> &xfs_nondir_ilock_class --> (complete)&ret.event
> >
> >  Possible unsafe locking scenario by crosslock:
> >
> >        CPU0                    CPU1
> >        ----                    ----
> >   lock(&xfs_nondir_ilock_class);
> >   lock((complete)&ret.event);
> >                                lock(&(&ip->i_mmaplock)->mr_lock);
> >                                unlock((complete)&ret.event);
> >
> >                *** DEADLOCK ***
> 
> The warning is a false positive, caused by the fact that all
> wait_for_completion()s in submit_bio_wait() are waiting with the same
> lock class.
> 
> However, some bios have nothing to do with others, for example, the case
> might happen while using loop devices, between bios of an upper device
> and a lower device(=loop device).
> 
> The safest way to assign different lock classes to different devices is
> to do it for each gendisk. In other words, this patch assigns a
> lockdep_map per gendisk and uses it when initializing completion in
> submit_bio_wait().
> 
> Of course, it might be too conservative. But, making it safest for now
> and extended by block layer experts later is good, at the moment.
> 
> Reported-by: Darrick J. Wong <darrick.wong@oracle.com>
> Analyzed-by: Dave Chinner <david@fromorbit.com>
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  block/bio.c           |  2 +-
>  block/genhd.c         | 10 ++--------
>  include/linux/genhd.h | 24 ++++++++++++++++++++++--
>  3 files changed, 25 insertions(+), 11 deletions(-)
> 
> diff --git a/block/bio.c b/block/bio.c
> index 99d0ca5..a3cb1d1 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -935,7 +935,7 @@ static void submit_bio_wait_endio(struct bio *bio)
>   */
>  int submit_bio_wait(struct bio *bio)
>  {
> -	DECLARE_COMPLETION_ONSTACK(done);
> +	DECLARE_COMPLETION_ONSTACK_MAP(done, bio->bi_disk->lockdep_map);
>  
>  	bio->bi_private = &done;
>  	bio->bi_end_io = submit_bio_wait_endio;
> diff --git a/block/genhd.c b/block/genhd.c
> index dd305c6..630c0da 100644
> --- a/block/genhd.c
> +++ b/block/genhd.c
> @@ -1354,13 +1354,7 @@ dev_t blk_lookup_devt(const char *name, int partno)
>  }
>  EXPORT_SYMBOL(blk_lookup_devt);
>  
> -struct gendisk *alloc_disk(int minors)
> -{
> -	return alloc_disk_node(minors, NUMA_NO_NODE);
> -}
> -EXPORT_SYMBOL(alloc_disk);
> -
> -struct gendisk *alloc_disk_node(int minors, int node_id)
> +struct gendisk *__alloc_disk_node(int minors, int node_id)
>  {
>  	struct gendisk *disk;
>  	struct disk_part_tbl *ptbl;
> @@ -1411,7 +1405,7 @@ struct gendisk *alloc_disk_node(int minors, int node_id)
>  	}
>  	return disk;
>  }
> -EXPORT_SYMBOL(alloc_disk_node);
> +EXPORT_SYMBOL(__alloc_disk_node);
>  
>  struct kobject *get_disk(struct gendisk *disk)
>  {
> diff --git a/include/linux/genhd.h b/include/linux/genhd.h
> index 6d85a75..f6ec6a2 100644
> --- a/include/linux/genhd.h
> +++ b/include/linux/genhd.h
> @@ -206,6 +206,9 @@ struct gendisk {
>  #endif	/* CONFIG_BLK_DEV_INTEGRITY */
>  	int node_id;
>  	struct badblocks *bb;
> +#ifdef CONFIG_LOCKDEP
> +	struct lockdep_map lockdep_map;
> +#endif
>  };
>  
>  static inline struct gendisk *part_to_disk(struct hd_struct *part)
> @@ -590,8 +593,7 @@ extern struct hd_struct * __must_check add_partition(struct gendisk *disk,
>  extern void delete_partition(struct gendisk *, int);
>  extern void printk_all_partitions(void);
>  
> -extern struct gendisk *alloc_disk_node(int minors, int node_id);
> -extern struct gendisk *alloc_disk(int minors);
> +extern struct gendisk *__alloc_disk_node(int minors, int node_id);
>  extern struct kobject *get_disk(struct gendisk *disk);
>  extern void put_disk(struct gendisk *disk);
>  extern void blk_register_region(dev_t devt, unsigned long range,
> @@ -615,6 +617,24 @@ extern ssize_t part_fail_store(struct device *dev,
>  			       const char *buf, size_t count);
>  #endif /* CONFIG_FAIL_MAKE_REQUEST */
>  
> +#define alloc_disk_node(m, id) \
> +({									\
> +	static struct lock_class_key __key;				\
> +	const char *__name;						\
> +	struct gendisk *ret;						\
> +									\
> +	__name = "(complete)"#m"("#id")";				\
> +									\
> +	ret = __alloc_disk_node(m, id);					\
> +									\
> +	if (ret)							\
> +		lockdep_init_map(&ret->lockdep_map, __name, &__key, 0); \
> +									\
> +	ret;								\
> +})

Beyond the #ifdef reduction I mentioned in the other thread, there's four other 
things I noticed that need to be fixed in this patch:

 - Please write out 'minor' instead of the 'm' abbreviation that is meaningless. 
   'm' is only used for trivial wrappers, but this wrapper is not trivial - so 
   proper canonical variable names should be used.

 - Since __key and __name is already double underscores that is customary for
   macros to avoid variable name shadowing, why is 'ret' not such a name?

 - But, 'ret' is the typical name used for integer returns, not for pointers! 
   Please check the gendisk code for what the typical name for gendisk pointers
   is and use that instead of making up new, weird patterns ...

 - The "(complete)"#minor"("#id")" generated name is pretty bad. Firstly 
   "complete" is a verb (or adjective), while lock(dep) symbol names should be 
   nouns! But even "completion" is pretty opaque, how about "gendisk_completion"?

More careful patches please!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
