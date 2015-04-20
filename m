Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5CA6B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:02:40 -0400 (EDT)
Received: by wgso17 with SMTP id o17so182624140wgs.1
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 08:02:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ls4si32522659wjb.83.2015.04.20.08.02.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 08:02:38 -0700 (PDT)
Date: Mon, 20 Apr 2015 17:02:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 12/49] writeback: move backing_dev_info->bdi_stat[] into
 bdi_writeback
Message-ID: <20150420150231.GA17020@quack.suse.cz>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-13-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428350318-8215-13-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Miklos Szeredi <miklos@szeredi.hu>, Trond Myklebust <trond.myklebust@primarydata.com>

On Mon 06-04-15 15:58:01, Tejun Heo wrote:
> Currently, a bdi (backing_dev_info) embeds single wb (bdi_writeback)
> and the role of the separation is unclear.  For cgroup support for
> writeback IOs, a bdi will be updated to host multiple wb's where each
> wb serves writeback IOs of a different cgroup on the bdi.  To achieve
> that, a wb should carry all states necessary for servicing writeback
> IOs for a cgroup independently.
> 
> This patch moves bdi->bdi_stat[] into wb.
> 
> * enum bdi_stat_item is renamed to wb_stat_item and the prefix of all
>   enums is changed from BDI_ to WB_.
> 
> * BDI_STAT_BATCH() -> WB_STAT_BATCH()
> 
> * [__]{add|inc|dec|sum}_wb_stat(bdi, ...) -> [__]{add|inc}_wb_stat(wb, ...)
> 
> * bdi_stat[_error]() -> wb_stat[_error]()
> 
> * bdi_writeout_inc() -> wb_writeout_inc()
> 
> * stat init is moved to bdi_wb_init() and bdi_wb_exit() is added and
>   frees stat.
  Maybe bdi_wb_destroy() would be somewhat more descriptive than
bdi_wb_exit()? Otherwise the patch looks good to me. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> * As there's still only one bdi_writeback per backing_dev_info, all
>   uses of bdi->stat[] are mechanically replaced with bdi->wb.stat[]
>   introducing no behavior changes.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Miklos Szeredi <miklos@szeredi.hu>
> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/fs-writeback.c           |  2 +-
>  fs/fuse/file.c              | 12 ++++----
>  fs/nfs/internal.h           |  2 +-
>  fs/nfs/write.c              |  3 +-
>  include/linux/backing-dev.h | 68 +++++++++++++++++++++------------------------
>  mm/backing-dev.c            | 60 ++++++++++++++++++++++++---------------
>  mm/filemap.c                |  2 +-
>  mm/page-writeback.c         | 53 +++++++++++++++++------------------
>  mm/truncate.c               |  4 +--
>  9 files changed, 108 insertions(+), 98 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index fea13fe..992a065 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -822,7 +822,7 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
>  	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
>  		return true;
>  
> -	if (bdi_stat(bdi, BDI_RECLAIMABLE) >
> +	if (wb_stat(&bdi->wb, WB_RECLAIMABLE) >
>  				bdi_dirty_limit(bdi, background_thresh))
>  		return true;
>  
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index c01ec3b..997c88a 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -1469,9 +1469,9 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
>  
>  	list_del(&req->writepages_entry);
>  	for (i = 0; i < req->num_pages; i++) {
> -		dec_bdi_stat(bdi, BDI_WRITEBACK);
> +		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
>  		dec_zone_page_state(req->pages[i], NR_WRITEBACK_TEMP);
> -		bdi_writeout_inc(bdi);
> +		wb_writeout_inc(&bdi->wb);
>  	}
>  	wake_up(&fi->page_waitq);
>  }
> @@ -1658,7 +1658,7 @@ static int fuse_writepage_locked(struct page *page)
>  	req->end = fuse_writepage_end;
>  	req->inode = inode;
>  
> -	inc_bdi_stat(inode_to_bdi(inode), BDI_WRITEBACK);
> +	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_WRITEBACK);
>  	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
>  
>  	spin_lock(&fc->lock);
> @@ -1773,9 +1773,9 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
>  		copy_highpage(old_req->pages[0], page);
>  		spin_unlock(&fc->lock);
>  
> -		dec_bdi_stat(bdi, BDI_WRITEBACK);
> +		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
>  		dec_zone_page_state(page, NR_WRITEBACK_TEMP);
> -		bdi_writeout_inc(bdi);
> +		wb_writeout_inc(&bdi->wb);
>  		fuse_writepage_free(fc, new_req);
>  		fuse_request_free(new_req);
>  		goto out;
> @@ -1872,7 +1872,7 @@ static int fuse_writepages_fill(struct page *page,
>  	req->page_descs[req->num_pages].offset = 0;
>  	req->page_descs[req->num_pages].length = PAGE_SIZE;
>  
> -	inc_bdi_stat(inode_to_bdi(inode), BDI_WRITEBACK);
> +	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_WRITEBACK);
>  	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
>  
>  	err = 0;
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 9e6475b..7e3c460 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -607,7 +607,7 @@ void nfs_mark_page_unstable(struct page *page)
>  	struct inode *inode = page_file_mapping(page)->host;
>  
>  	inc_zone_page_state(page, NR_UNSTABLE_NFS);
> -	inc_bdi_stat(inode_to_bdi(inode), BDI_RECLAIMABLE);
> +	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_RECLAIMABLE);
>  	 __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>  }
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 849ed78..8bbeafe 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -853,7 +853,8 @@ static void
>  nfs_clear_page_commit(struct page *page)
>  {
>  	dec_zone_page_state(page, NR_UNSTABLE_NFS);
> -	dec_bdi_stat(inode_to_bdi(page_file_mapping(page)->host), BDI_RECLAIMABLE);
> +	dec_wb_stat(&inode_to_bdi(page_file_mapping(page)->host)->wb,
> +		    WB_RECLAIMABLE);
>  }
>  
>  /* Called holding inode (/cinfo) lock */
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index eb14f98..fe7a907 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -36,15 +36,15 @@ enum wb_state {
>  
>  typedef int (congested_fn)(void *, int);
>  
> -enum bdi_stat_item {
> -	BDI_RECLAIMABLE,
> -	BDI_WRITEBACK,
> -	BDI_DIRTIED,
> -	BDI_WRITTEN,
> -	NR_BDI_STAT_ITEMS
> +enum wb_stat_item {
> +	WB_RECLAIMABLE,
> +	WB_WRITEBACK,
> +	WB_DIRTIED,
> +	WB_WRITTEN,
> +	NR_WB_STAT_ITEMS
>  };
>  
> -#define BDI_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
> +#define WB_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
>  
>  struct bdi_writeback {
>  	struct backing_dev_info *bdi;	/* our parent bdi */
> @@ -58,6 +58,8 @@ struct bdi_writeback {
>  	struct list_head b_more_io;	/* parked for more writeback */
>  	struct list_head b_dirty_time;	/* time stamps are dirty */
>  	spinlock_t list_lock;		/* protects the b_* lists */
> +
> +	struct percpu_counter stat[NR_WB_STAT_ITEMS];
>  };
>  
>  struct backing_dev_info {
> @@ -69,8 +71,6 @@ struct backing_dev_info {
>  
>  	char *name;
>  
> -	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
> -
>  	unsigned long bw_time_stamp;	/* last time write bw is updated */
>  	unsigned long dirtied_stamp;
>  	unsigned long written_stamp;	/* pages written at bw_time_stamp */
> @@ -137,78 +137,74 @@ static inline int wb_has_dirty_io(struct bdi_writeback *wb)
>  	       !list_empty(&wb->b_more_io);
>  }
>  
> -static inline void __add_bdi_stat(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item, s64 amount)
> +static inline void __add_wb_stat(struct bdi_writeback *wb,
> +				 enum wb_stat_item item, s64 amount)
>  {
> -	__percpu_counter_add(&bdi->bdi_stat[item], amount, BDI_STAT_BATCH);
> +	__percpu_counter_add(&wb->stat[item], amount, WB_STAT_BATCH);
>  }
>  
> -static inline void __inc_bdi_stat(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item)
> +static inline void __inc_wb_stat(struct bdi_writeback *wb,
> +				 enum wb_stat_item item)
>  {
> -	__add_bdi_stat(bdi, item, 1);
> +	__add_wb_stat(wb, item, 1);
>  }
>  
> -static inline void inc_bdi_stat(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item)
> +static inline void inc_wb_stat(struct bdi_writeback *wb, enum wb_stat_item item)
>  {
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
> -	__inc_bdi_stat(bdi, item);
> +	__inc_wb_stat(wb, item);
>  	local_irq_restore(flags);
>  }
>  
> -static inline void __dec_bdi_stat(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item)
> +static inline void __dec_wb_stat(struct bdi_writeback *wb,
> +				 enum wb_stat_item item)
>  {
> -	__add_bdi_stat(bdi, item, -1);
> +	__add_wb_stat(wb, item, -1);
>  }
>  
> -static inline void dec_bdi_stat(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item)
> +static inline void dec_wb_stat(struct bdi_writeback *wb, enum wb_stat_item item)
>  {
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
> -	__dec_bdi_stat(bdi, item);
> +	__dec_wb_stat(wb, item);
>  	local_irq_restore(flags);
>  }
>  
> -static inline s64 bdi_stat(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item)
> +static inline s64 wb_stat(struct bdi_writeback *wb, enum wb_stat_item item)
>  {
> -	return percpu_counter_read_positive(&bdi->bdi_stat[item]);
> +	return percpu_counter_read_positive(&wb->stat[item]);
>  }
>  
> -static inline s64 __bdi_stat_sum(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item)
> +static inline s64 __wb_stat_sum(struct bdi_writeback *wb,
> +				enum wb_stat_item item)
>  {
> -	return percpu_counter_sum_positive(&bdi->bdi_stat[item]);
> +	return percpu_counter_sum_positive(&wb->stat[item]);
>  }
>  
> -static inline s64 bdi_stat_sum(struct backing_dev_info *bdi,
> -		enum bdi_stat_item item)
> +static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
>  {
>  	s64 sum;
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
> -	sum = __bdi_stat_sum(bdi, item);
> +	sum = __wb_stat_sum(wb, item);
>  	local_irq_restore(flags);
>  
>  	return sum;
>  }
>  
> -extern void bdi_writeout_inc(struct backing_dev_info *bdi);
> +extern void wb_writeout_inc(struct bdi_writeback *wb);
>  
>  /*
>   * maximal error of a stat counter.
>   */
> -static inline unsigned long bdi_stat_error(struct backing_dev_info *bdi)
> +static inline unsigned long wb_stat_error(struct bdi_writeback *wb)
>  {
>  #ifdef CONFIG_SMP
> -	return nr_cpu_ids * BDI_STAT_BATCH;
> +	return nr_cpu_ids * WB_STAT_BATCH;
>  #else
>  	return 1;
>  #endif
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index b23cf0e..7b1d191 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -84,13 +84,13 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  		   "b_dirty_time:       %10lu\n"
>  		   "bdi_list:           %10u\n"
>  		   "state:              %10lx\n",
> -		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
> -		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
> +		   (unsigned long) K(wb_stat(wb, WB_WRITEBACK)),
> +		   (unsigned long) K(wb_stat(wb, WB_RECLAIMABLE)),
>  		   K(bdi_thresh),
>  		   K(dirty_thresh),
>  		   K(background_thresh),
> -		   (unsigned long) K(bdi_stat(bdi, BDI_DIRTIED)),
> -		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
> +		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
> +		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
>  		   (unsigned long) K(bdi->write_bandwidth),
>  		   nr_dirty,
>  		   nr_io,
> @@ -376,8 +376,10 @@ void bdi_unregister(struct backing_dev_info *bdi)
>  }
>  EXPORT_SYMBOL(bdi_unregister);
>  
> -static void bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
> +static int bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
>  {
> +	int i, err;
> +
>  	memset(wb, 0, sizeof(*wb));
>  
>  	wb->bdi = bdi;
> @@ -388,6 +390,27 @@ static void bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
>  	INIT_LIST_HEAD(&wb->b_dirty_time);
>  	spin_lock_init(&wb->list_lock);
>  	INIT_DELAYED_WORK(&wb->dwork, bdi_writeback_workfn);
> +
> +	for (i = 0; i < NR_WB_STAT_ITEMS; i++) {
> +		err = percpu_counter_init(&wb->stat[i], 0, GFP_KERNEL);
> +		if (err) {
> +			while (--i)
> +				percpu_counter_destroy(&wb->stat[i]);
> +			return err;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static void bdi_wb_exit(struct bdi_writeback *wb)
> +{
> +	int i;
> +
> +	WARN_ON(delayed_work_pending(&wb->dwork));
> +
> +	for (i = 0; i < NR_WB_STAT_ITEMS; i++)
> +		percpu_counter_destroy(&wb->stat[i]);
>  }
>  
>  /*
> @@ -397,7 +420,7 @@ static void bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
>  
>  int bdi_init(struct backing_dev_info *bdi)
>  {
> -	int i, err;
> +	int err;
>  
>  	bdi->dev = NULL;
>  
> @@ -408,13 +431,9 @@ int bdi_init(struct backing_dev_info *bdi)
>  	INIT_LIST_HEAD(&bdi->bdi_list);
>  	INIT_LIST_HEAD(&bdi->work_list);
>  
> -	bdi_wb_init(&bdi->wb, bdi);
> -
> -	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
> -		err = percpu_counter_init(&bdi->bdi_stat[i], 0, GFP_KERNEL);
> -		if (err)
> -			goto err;
> -	}
> +	err = bdi_wb_init(&bdi->wb, bdi);
> +	if (err)
> +		return err;
>  
>  	bdi->dirty_exceeded = 0;
>  
> @@ -427,25 +446,20 @@ int bdi_init(struct backing_dev_info *bdi)
>  	bdi->avg_write_bandwidth = INIT_BW;
>  
>  	err = fprop_local_init_percpu(&bdi->completions, GFP_KERNEL);
> -
>  	if (err) {
> -err:
> -		while (i--)
> -			percpu_counter_destroy(&bdi->bdi_stat[i]);
> +		bdi_wb_exit(&bdi->wb);
> +		return err;
>  	}
>  
> -	return err;
> +	return 0;
>  }
>  EXPORT_SYMBOL(bdi_init);
>  
>  void bdi_destroy(struct backing_dev_info *bdi)
>  {
> -	int i;
> -
>  	bdi_wb_shutdown(bdi);
>  
>  	WARN_ON(!list_empty(&bdi->work_list));
> -	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
>  
>  	if (bdi->dev) {
>  		bdi_debug_unregister(bdi);
> @@ -453,8 +467,8 @@ void bdi_destroy(struct backing_dev_info *bdi)
>  		bdi->dev = NULL;
>  	}
>  
> -	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
> -		percpu_counter_destroy(&bdi->bdi_stat[i]);
> +	bdi_wb_exit(&bdi->wb);
> +
>  	fprop_local_destroy_percpu(&bdi->completions);
>  }
>  EXPORT_SYMBOL(bdi_destroy);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 21cebb6..a2b098b 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -215,7 +215,7 @@ void __delete_from_page_cache(struct page *page, void *shadow,
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
>  		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
>  		dec_zone_page_state(page, NR_FILE_DIRTY);
> -		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_RECLAIMABLE);
> +		dec_wb_stat(&inode_to_bdi(mapping->host)->wb, WB_RECLAIMABLE);
>  	}
>  }
>  
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 9b6277a..af3edb6 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -396,11 +396,11 @@ static unsigned long wp_next_time(unsigned long cur_time)
>   * Increment the BDI's writeout completion count and the global writeout
>   * completion count. Called from test_clear_page_writeback().
>   */
> -static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
> +static inline void __wb_writeout_inc(struct bdi_writeback *wb)
>  {
> -	__inc_bdi_stat(bdi, BDI_WRITTEN);
> -	__fprop_inc_percpu_max(&writeout_completions, &bdi->completions,
> -			       bdi->max_prop_frac);
> +	__inc_wb_stat(wb, WB_WRITTEN);
> +	__fprop_inc_percpu_max(&writeout_completions, &wb->bdi->completions,
> +			       wb->bdi->max_prop_frac);
>  	/* First event after period switching was turned off? */
>  	if (!unlikely(writeout_period_time)) {
>  		/*
> @@ -414,15 +414,15 @@ static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
>  	}
>  }
>  
> -void bdi_writeout_inc(struct backing_dev_info *bdi)
> +void wb_writeout_inc(struct bdi_writeback *wb)
>  {
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
> -	__bdi_writeout_inc(bdi);
> +	__wb_writeout_inc(wb);
>  	local_irq_restore(flags);
>  }
> -EXPORT_SYMBOL_GPL(bdi_writeout_inc);
> +EXPORT_SYMBOL_GPL(wb_writeout_inc);
>  
>  /*
>   * Obtain an accurate fraction of the BDI's portion.
> @@ -1130,8 +1130,8 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>  	if (elapsed < BANDWIDTH_INTERVAL)
>  		return;
>  
> -	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
> -	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
> +	dirtied = percpu_counter_read(&bdi->wb.stat[WB_DIRTIED]);
> +	written = percpu_counter_read(&bdi->wb.stat[WB_WRITTEN]);
>  
>  	/*
>  	 * Skip quiet periods when disk bandwidth is under-utilized.
> @@ -1288,7 +1288,8 @@ static inline void bdi_dirty_limits(struct backing_dev_info *bdi,
>  				    unsigned long *bdi_thresh,
>  				    unsigned long *bdi_bg_thresh)
>  {
> -	unsigned long bdi_reclaimable;
> +	struct bdi_writeback *wb = &bdi->wb;
> +	unsigned long wb_reclaimable;
>  
>  	/*
>  	 * bdi_thresh is not treated as some limiting factor as
> @@ -1320,14 +1321,12 @@ static inline void bdi_dirty_limits(struct backing_dev_info *bdi,
>  	 * actually dirty; with m+n sitting in the percpu
>  	 * deltas.
>  	 */
> -	if (*bdi_thresh < 2 * bdi_stat_error(bdi)) {
> -		bdi_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
> -		*bdi_dirty = bdi_reclaimable +
> -			bdi_stat_sum(bdi, BDI_WRITEBACK);
> +	if (*bdi_thresh < 2 * wb_stat_error(wb)) {
> +		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE);
> +		*bdi_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
>  	} else {
> -		bdi_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> -		*bdi_dirty = bdi_reclaimable +
> -			bdi_stat(bdi, BDI_WRITEBACK);
> +		wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE);
> +		*bdi_dirty = wb_reclaimable + wb_stat(wb, WB_WRITEBACK);
>  	}
>  }
>  
> @@ -1514,9 +1513,9 @@ pause:
>  		 * In theory 1 page is enough to keep the comsumer-producer
>  		 * pipe going: the flusher cleans 1 page => the task dirties 1
>  		 * more page. However bdi_dirty has accounting errors.  So use
> -		 * the larger and more IO friendly bdi_stat_error.
> +		 * the larger and more IO friendly wb_stat_error.
>  		 */
> -		if (bdi_dirty <= bdi_stat_error(bdi))
> +		if (bdi_dirty <= wb_stat_error(&bdi->wb))
>  			break;
>  
>  		if (fatal_signal_pending(current))
> @@ -2106,8 +2105,8 @@ void account_page_dirtied(struct page *page, struct address_space *mapping,
>  		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
>  		__inc_zone_page_state(page, NR_FILE_DIRTY);
>  		__inc_zone_page_state(page, NR_DIRTIED);
> -		__inc_bdi_stat(bdi, BDI_RECLAIMABLE);
> -		__inc_bdi_stat(bdi, BDI_DIRTIED);
> +		__inc_wb_stat(&bdi->wb, WB_RECLAIMABLE);
> +		__inc_wb_stat(&bdi->wb, WB_DIRTIED);
>  		task_io_account_write(PAGE_CACHE_SIZE);
>  		current->nr_dirtied++;
>  		this_cpu_inc(bdp_ratelimits);
> @@ -2174,7 +2173,7 @@ void account_page_redirty(struct page *page)
>  	if (mapping && mapping_cap_account_dirty(mapping)) {
>  		current->nr_dirtied--;
>  		dec_zone_page_state(page, NR_DIRTIED);
> -		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_DIRTIED);
> +		dec_wb_stat(&inode_to_bdi(mapping->host)->wb, WB_DIRTIED);
>  	}
>  }
>  EXPORT_SYMBOL(account_page_redirty);
> @@ -2320,8 +2319,8 @@ int clear_page_dirty_for_io(struct page *page)
>  		if (TestClearPageDirty(page)) {
>  			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
> -			dec_bdi_stat(inode_to_bdi(mapping->host),
> -					BDI_RECLAIMABLE);
> +			dec_wb_stat(&inode_to_bdi(mapping->host)->wb,
> +				    WB_RECLAIMABLE);
>  			ret = 1;
>  		}
>  		mem_cgroup_end_page_stat(memcg);
> @@ -2349,8 +2348,8 @@ int test_clear_page_writeback(struct page *page)
>  						page_index(page),
>  						PAGECACHE_TAG_WRITEBACK);
>  			if (bdi_cap_account_writeback(bdi)) {
> -				__dec_bdi_stat(bdi, BDI_WRITEBACK);
> -				__bdi_writeout_inc(bdi);
> +				__dec_wb_stat(&bdi->wb, WB_WRITEBACK);
> +				__wb_writeout_inc(&bdi->wb);
>  			}
>  		}
>  		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> @@ -2384,7 +2383,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
>  						page_index(page),
>  						PAGECACHE_TAG_WRITEBACK);
>  			if (bdi_cap_account_writeback(bdi))
> -				__inc_bdi_stat(bdi, BDI_WRITEBACK);
> +				__inc_wb_stat(&bdi->wb, WB_WRITEBACK);
>  		}
>  		if (!PageDirty(page))
>  			radix_tree_tag_clear(&mapping->page_tree,
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 059cac7..df16f8c 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -116,8 +116,8 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
>  		if (mapping && mapping_cap_account_dirty(mapping)) {
>  			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
> -			dec_bdi_stat(inode_to_bdi(mapping->host),
> -					BDI_RECLAIMABLE);
> +			dec_wb_stat(&inode_to_bdi(mapping->host)->wb,
> +				    WB_RECLAIMABLE);
>  			if (account_size)
>  				task_io_account_cancelled_write(account_size);
>  		}
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
