Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EA3F76B0087
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:21:47 -0500 (EST)
Date: Wed, 24 Nov 2010 22:21:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
Message-ID: <20101124142142.GA14123@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042850.002299964@intel.com>
 <1290596732.2072.450.camel@laptop>
 <20101124121046.GA8333@localhost>
 <1290603047.2072.465.camel@laptop>
 <20101124131437.GE10413@localhost>
 <20101124132012.GA12117@localhost>
 <1290606129.2072.467.camel@laptop>
 <20101124134641.GA12987@localhost>
 <1290607953.2072.472.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290607953.2072.472.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 10:12:33PM +0800, Peter Zijlstra wrote:
> On Wed, 2010-11-24 at 21:46 +0800, Wu Fengguang wrote:
> > On Wed, Nov 24, 2010 at 09:42:09PM +0800, Peter Zijlstra wrote:
> > > On Wed, 2010-11-24 at 21:20 +0800, Wu Fengguang wrote:
> > > > >         (jiffies - bdi->write_bandwidth_update_time < elapsed)
> > > > 
> > > > this will be true if someone else has _done_ overlapped estimation,
> > > > otherwise it will equal:
> > > > 
> > > >         jiffies - bdi->write_bandwidth_update_time == elapsed
> > > > 
> > > > Sorry the comment needs updating. 
> > > 
> > > Right, but its racy as hell..
> > 
> > Yeah, for N concurrent dirtiers, plus the background flusher, only
> > one is able to update write_bandwidth[_update_time]..
> 
> Wrong, nr_cpus are, they could all observe the old value before seeing
> the update of the variable.

Yes, that's what I meant to do it "per-cpu" in the previous email.

> Why not something like the below, which keeps the stamps per bdi and
> serializes on a lock (trylock, you only need a single updater at any one
> time anyway):

Hmm, but why not avoid locking at all?  With per-cpu bandwidth vars,
each CPU will see slightly different bandwidth, but that should be
close enough and not a big problem.

> probably got the math wrong, but the idea should be clear, you can even
> add an explicit bdi_update_bandwidth_stamps() function which resets the
> stamps to the current situation in order to skip periods of low
> throughput (that would need to do spin_lock).
> 
> ---
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 4ce34fa..de690c3 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -40,6 +40,7 @@ typedef int (congested_fn)(void *, int);
>  enum bdi_stat_item {
>  	BDI_RECLAIMABLE,
>  	BDI_WRITEBACK,
> +	BDI_WRITTEN,
>  	NR_BDI_STAT_ITEMS
>  };
>  
> @@ -88,6 +89,11 @@ struct backing_dev_info {
>  
>  	struct timer_list laptop_mode_wb_timer;
>  
> +	spinlock_t bw_lock;
> +	unsigned long bw_time_stamp;
> +	unsigned long bw_write_stamp;
> +	int write_bandwidth;
> +
>  #ifdef CONFIG_DEBUG_FS
>  	struct dentry *debug_dir;
>  	struct dentry *debug_stats;
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 027100d..a934fe9 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -661,6 +661,11 @@ int bdi_init(struct backing_dev_info *bdi)
>  	bdi->dirty_exceeded = 0;
>  	err = prop_local_init_percpu(&bdi->completions);
>  
> +	spin_lock_init(&bdi->bw_lock);
> +	bdi->bw_time_stamp = jiffies;
> +	bdi->bw_write_stamp = 0;
> +	bdi->write_bandwidth = 100 << (20 - PAGE_SHIFT); /* 100 MB/s */
> +
>  	if (err) {
>  err:
>  		while (i--)
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index b840afa..f3f5c24 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -219,6 +219,7 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
>   */
>  static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
>  {
> +	__inc_bdi_state(bdi, BDI_WRITTEN);
>  	__prop_inc_percpu_max(&vm_completions, &bdi->completions,
>  			      bdi->max_prop_frac);
>  }
> @@ -238,6 +239,35 @@ void task_dirty_inc(struct task_struct *tsk)
>  	prop_inc_single(&vm_dirties, &tsk->dirties);
>  }
>  
> +void bdi_update_write_bandwidth(struct backing_dev_info *bdi)
> +{
> +	unsigned long time_now, write_now;
> +	long time_delta, write_delta;
> +	long bw;
> +
> +	if (!spin_try_lock(&bdi->bw_lock))
> +		return;

spin_try_lock is good, however is still global state and risks
cacheline bouncing..

> +	write_now = bdi_stat(bdi, BDI_WRITTEN);
> +	time_now = jiffies;
> +
> +	write_delta = write_now - bdi->bw_write_stamp;
> +	time_delta = time_now - bdi->bw_time_stamp;
> +
> +	/* rate-limit, only update once every 100ms */
> +	if (time_delta < HZ/10 || !write_delta)
> +		goto unlock;
> +
> +	bdi->bw_write_stamp = write_now;
> +	bdi->bw_time_stamp = time_now;
> +
> +	bw = write_delta * HZ / time_delta;
> +	bdi->write_bandwidth = (bdi->write_bandwidth + bw + 3) / 4;
> +
> +unlock:
> +	spin_unlock(&bdi->bw_lock);
> +}
> +
>  /*
>   * Obtain an accurate fraction of the BDI's portion.
>   */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
