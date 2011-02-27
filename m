Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DAA6D8D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 11:38:29 -0500 (EST)
Received: by pxi9 with SMTP id 9so751253pxi.14
        for <linux-mm@kvack.org>; Sun, 27 Feb 2011 08:38:27 -0800 (PST)
Date: Mon, 28 Feb 2011 01:38:15 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v5 4/9] writeback: create dirty_info structure
Message-ID: <20110227163815.GC3226@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-5-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298669760-26344-5-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Feb 25, 2011 at 01:35:55PM -0800, Greg Thelen wrote:
> Bundle dirty limits and dirty memory usage metrics into a dirty_info
> structure to simplify interfaces of routines that need all.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> ---
> Changelog since v4:
> - Within new dirty_info structure, replaced nr_reclaimable with nr_file_dirty
>   and nr_unstable_nfs to give callers finer grain dirty usage information.
> - Added new dirty_info_reclaimable() function.
> - Made more use of dirty_info structure in throttle_vm_writeout().
> 
> Changelog since v3:
> - This is a new patch in v4.
> 
>  fs/fs-writeback.c         |    7 ++---
>  include/linux/writeback.h |   15 ++++++++++++-
>  mm/backing-dev.c          |   18 +++++++++------
>  mm/page-writeback.c       |   50 ++++++++++++++++++++++----------------------
>  mm/vmstat.c               |    6 +++-
>  5 files changed, 57 insertions(+), 39 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 59c6e49..d75e4da 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -595,12 +595,11 @@ static void __writeback_inodes_sb(struct super_block *sb,
>  
>  static inline bool over_bground_thresh(void)
>  {
> -	unsigned long background_thresh, dirty_thresh;
> +	struct dirty_info info;
>  
> -	global_dirty_limits(&background_thresh, &dirty_thresh);
> +	global_dirty_info(&info);
>  
> -	return (global_page_state(NR_FILE_DIRTY) +
> -		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
> +	return dirty_info_reclaimable(&info) > info.background_thresh;
>  }

Get unnecessary nr_writeback.

>  
>  /*
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 0ead399..a06fb38 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -84,6 +84,19 @@ static inline void inode_sync_wait(struct inode *inode)
>  /*
>   * mm/page-writeback.c
>   */
> +struct dirty_info {
> +	unsigned long dirty_thresh;
> +	unsigned long background_thresh;
> +	unsigned long nr_file_dirty;
> +	unsigned long nr_writeback;
> +	unsigned long nr_unstable_nfs;
> +};
> +
> +static inline unsigned long dirty_info_reclaimable(struct dirty_info *info)
> +{
> +	return info->nr_file_dirty + info->nr_unstable_nfs;
> +}
> +
>  #ifdef CONFIG_BLOCK
>  void laptop_io_completion(struct backing_dev_info *info);
>  void laptop_sync_completion(void);
> @@ -124,7 +137,7 @@ struct ctl_table;
>  int dirty_writeback_centisecs_handler(struct ctl_table *, int,
>  				      void __user *, size_t *, loff_t *);
>  
> -void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
> +void global_dirty_info(struct dirty_info *info);
>  unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
>  			       unsigned long dirty);
>  
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 027100d..17a06ab 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -66,8 +66,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  {
>  	struct backing_dev_info *bdi = m->private;
>  	struct bdi_writeback *wb = &bdi->wb;
> -	unsigned long background_thresh;
> -	unsigned long dirty_thresh;
> +	struct dirty_info dirty_info;
>  	unsigned long bdi_thresh;
>  	unsigned long nr_dirty, nr_io, nr_more_io, nr_wb;
>  	struct inode *inode;
> @@ -82,8 +81,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  		nr_more_io++;
>  	spin_unlock(&inode_lock);
>  
> -	global_dirty_limits(&background_thresh, &dirty_thresh);
> -	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
> +	global_dirty_info(&dirty_info);
> +	bdi_thresh = bdi_dirty_limit(bdi, dirty_info.dirty_thresh);
>  
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  	seq_printf(m,
> @@ -99,9 +98,14 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  		   "state:            %8lx\n",
>  		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
>  		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
> -		   K(bdi_thresh), K(dirty_thresh),
> -		   K(background_thresh), nr_dirty, nr_io, nr_more_io,
> -		   !list_empty(&bdi->bdi_list), bdi->state);
> +		   K(bdi_thresh),
> +		   K(dirty_info.dirty_thresh),
> +		   K(dirty_info.background_thresh),

Get unnecessary nr_file_dirty, nr_writeback, nr_unstable_nfs.

> +		   nr_dirty,
> +		   nr_io,
> +		   nr_more_io,
> +		   !list_empty(&bdi->bdi_list),
> +		   bdi->state);
>  #undef K
>  
>  	return 0;
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 4408e54..00424b9 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -398,7 +398,7 @@ unsigned long determine_dirtyable_memory(void)
>  }
>  
>  /*
> - * global_dirty_limits - background-writeback and dirty-throttling thresholds
> + * global_dirty_info - return dirty thresholds and usage metrics
>   *
>   * Calculate the dirty thresholds based on sysctl parameters
>   * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
> @@ -406,7 +406,7 @@ unsigned long determine_dirtyable_memory(void)
>   * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
>   * real-time tasks.
>   */
> -void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> +void global_dirty_info(struct dirty_info *info)
>  {
>  	unsigned long background;
>  	unsigned long dirty;
> @@ -426,6 +426,10 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  	else
>  		background = (dirty_background_ratio * available_memory) / 100;
>  
> +	info->nr_file_dirty = global_page_state(NR_FILE_DIRTY);
> +	info->nr_writeback = global_page_state(NR_WRITEBACK);
> +	info->nr_unstable_nfs = global_page_state(NR_UNSTABLE_NFS);
> +
>  	if (background >= dirty)
>  		background = dirty / 2;
>  	tsk = current;
> @@ -433,8 +437,8 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  		background += background / 4;
>  		dirty += dirty / 4;
>  	}
> -	*pbackground = background;
> -	*pdirty = dirty;
> +	info->background_thresh = background;
> +	info->dirty_thresh = dirty;
>  }
>  
>  /*
> @@ -478,12 +482,9 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
>  static void balance_dirty_pages(struct address_space *mapping,
>  				unsigned long write_chunk)
>  {
> -	unsigned long nr_reclaimable;
> +	struct dirty_info sys_info;
>  	long bdi_nr_reclaimable;
> -	unsigned long nr_writeback;
>  	long bdi_nr_writeback;
> -	unsigned long background_thresh;
> -	unsigned long dirty_thresh;
>  	unsigned long bdi_thresh;
>  	unsigned long pages_written = 0;
>  	unsigned long pause = 1;
> @@ -498,22 +499,19 @@ static void balance_dirty_pages(struct address_space *mapping,
>  			.range_cyclic	= 1,
>  		};
>  
> -		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> -					global_page_state(NR_UNSTABLE_NFS);
> -		nr_writeback = global_page_state(NR_WRITEBACK);
> -
> -		global_dirty_limits(&background_thresh, &dirty_thresh);
> +		global_dirty_info(&sys_info);
>  
>  		/*
>  		 * Throttle it only when the background writeback cannot
>  		 * catch-up. This avoids (excessively) small writeouts
>  		 * when the bdi limits are ramping up.
>  		 */
> -		if (nr_reclaimable + nr_writeback <=
> -				(background_thresh + dirty_thresh) / 2)
> +		if (dirty_info_reclaimable(&sys_info) + sys_info.nr_writeback <=
> +				(sys_info.background_thresh +
> +				 sys_info.dirty_thresh) / 2)
>  			break;
>  
> -		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
> +		bdi_thresh = bdi_dirty_limit(bdi, sys_info.dirty_thresh);
>  		bdi_thresh = task_dirty_limit(current, bdi_thresh);
>  
>  		/*
> @@ -542,7 +540,8 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		 */
>  		dirty_exceeded =
>  			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
> -			|| (nr_reclaimable + nr_writeback > dirty_thresh);
> +			|| (dirty_info_reclaimable(&sys_info) +
> +			     sys_info.nr_writeback > sys_info.dirty_thresh);
>  
>  		if (!dirty_exceeded)
>  			break;
> @@ -595,7 +594,8 @@ static void balance_dirty_pages(struct address_space *mapping,
>  	 * background_thresh, to keep the amount of dirty memory low.
>  	 */
>  	if ((laptop_mode && pages_written) ||
> -	    (!laptop_mode && (nr_reclaimable > background_thresh)))
> +	    (!laptop_mode && (dirty_info_reclaimable(&sys_info) >
> +			      sys_info.background_thresh)))
>  		bdi_start_background_writeback(bdi);
>  }
>  
> @@ -655,21 +655,21 @@ EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
>  
>  void throttle_vm_writeout(gfp_t gfp_mask)
>  {
> -	unsigned long background_thresh;
> -	unsigned long dirty_thresh;
> +	struct dirty_info sys_info;
>  
>          for ( ; ; ) {
> -		global_dirty_limits(&background_thresh, &dirty_thresh);
> +		global_dirty_info(&sys_info);

Get unnecessary nr_file_dirty.

>  
>                  /*
>                   * Boost the allowable dirty threshold a bit for page
>                   * allocators so they don't get DoS'ed by heavy writers
>                   */
> -                dirty_thresh += dirty_thresh / 10;      /* wheeee... */
> +		sys_info.dirty_thresh +=
> +			sys_info.dirty_thresh / 10;      /* wheeee... */
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
> +		if (sys_info.nr_unstable_nfs +
> +		    sys_info.nr_writeback <= sys_info.dirty_thresh)
> +			break;
>                  congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/*
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 0c3b504..ec95924 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1044,6 +1044,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
>  {
>  	unsigned long *v;
>  	int i, stat_items_size;
> +	struct dirty_info dirty_info;
>  
>  	if (*pos >= ARRAY_SIZE(vmstat_text))
>  		return NULL;
> @@ -1062,8 +1063,9 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
>  		v[i] = global_page_state(i);
>  	v += NR_VM_ZONE_STAT_ITEMS;
>  
> -	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
> -			    v + NR_DIRTY_THRESHOLD);
> +	global_dirty_info(&dirty_info);
> +	v[NR_DIRTY_BG_THRESHOLD] = dirty_info.background_thresh;
> +	v[NR_DIRTY_THRESHOLD] = dirty_info.dirty_thresh;
>  	v += NR_VM_WRITEBACK_STAT_ITEMS;

Get unnecessary nr_file_dirty, nr_writeback, nr_unstable_nfs.

The code itself doesn't have a problem. but although it makes code simple, 
sometime it get unnecessary information in that context. The global_page_state never 
cheap operation and we have been tried to reduce overhead in page-writeback.
(16c4042f, e50e3720).

Fortunately this patch doesn't increase balance_dirty_pages's overhead and 
things affected by this patch are not fast-path. 
So I think it doesn't have a problem.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
