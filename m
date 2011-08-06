Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BB9B16B00EE
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 10:35:37 -0400 (EDT)
Date: Sat, 6 Aug 2011 16:35:31 +0200
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110806143531.GA1512@thinkpad>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110806094527.002914580@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Aug 06, 2011 at 04:44:51PM +0800, Wu Fengguang wrote:
> Add two fields to task_struct.
> 
> 1) account dirtied pages in the individual tasks, for accuracy
> 2) per-task balance_dirty_pages() call intervals, for flexibility
> 
> The balance_dirty_pages() call interval (ie. nr_dirtied_pause) will
> scale near-sqrt to the safety gap between dirty pages and threshold.
> 
> XXX: The main problem of per-task nr_dirtied is, if 10k tasks start
> dirtying pages at exactly the same time, each task will be assigned a
> large initial nr_dirtied_pause, so that the dirty threshold will be
> exceeded long before each task reached its nr_dirtied_pause and hence
> call balance_dirty_pages().
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

A minor nitpick below.

Reviewed-by: Andrea Righi <andrea@betterlinux.com>

> ---
>  include/linux/sched.h |    7 ++
>  mm/memory_hotplug.c   |    3 -
>  mm/page-writeback.c   |  106 +++++++++-------------------------------
>  3 files changed, 32 insertions(+), 84 deletions(-)
> 
> --- linux-next.orig/include/linux/sched.h	2011-08-05 15:36:23.000000000 +0800
> +++ linux-next/include/linux/sched.h	2011-08-05 15:39:52.000000000 +0800
> @@ -1525,6 +1525,13 @@ struct task_struct {
>  	int make_it_fail;
>  #endif
>  	struct prop_local_single dirties;
> +	/*
> +	 * when (nr_dirtied >= nr_dirtied_pause), it's time to call
> +	 * balance_dirty_pages() for some dirty throttling pause
> +	 */
> +	int nr_dirtied;
> +	int nr_dirtied_pause;
> +
>  #ifdef CONFIG_LATENCYTOP
>  	int latency_record_count;
>  	struct latency_record latency_record[LT_SAVECOUNT];
> --- linux-next.orig/mm/page-writeback.c	2011-08-05 15:39:48.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-08-05 15:39:52.000000000 +0800
> @@ -48,26 +48,6 @@
>  
>  #define BANDWIDTH_CALC_SHIFT	10
>  
> -/*
> - * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
> - * will look to see if it needs to force writeback or throttling.
> - */
> -static long ratelimit_pages = 32;
> -
> -/*
> - * When balance_dirty_pages decides that the caller needs to perform some
> - * non-background writeback, this is how many pages it will attempt to write.
> - * It should be somewhat larger than dirtied pages to ensure that reasonably
> - * large amounts of I/O are submitted.
> - */
> -static inline long sync_writeback_pages(unsigned long dirtied)
> -{
> -	if (dirtied < ratelimit_pages)
> -		dirtied = ratelimit_pages;
> -
> -	return dirtied + dirtied / 2;
> -}
> -
>  /* The following parameters are exported via /proc/sys/vm */
>  
>  /*
> @@ -868,6 +848,23 @@ static void bdi_update_bandwidth(struct 
>  }
>  
>  /*
> + * After a task dirtied this many pages, balance_dirty_pages_ratelimited_nr()
> + * will look to see if it needs to start dirty throttling.
> + *
> + * If ratelimit_pages is too low then big NUMA machines will call the expensive
> + * global_page_state() too often. So scale it near-sqrt to the safety margin
> + * (the number of pages we may dirty without exceeding the dirty limits).
> + */
> +static unsigned long ratelimit_pages(unsigned long dirty,
> +				     unsigned long thresh)
> +{
> +	if (thresh > dirty)
> +		return 1UL << (ilog2(thresh - dirty) >> 1);
> +
> +	return 1;
> +}
> +
> +/*
>   * balance_dirty_pages() must be called by processes which are generating dirty
>   * data.  It looks at the number of dirty pages in the machine and will force
>   * the caller to perform writeback if the system is over `vm_dirty_ratio'.

I think we should also fix the comment of balance_dirty_pages(), now
that it's IO-less for the caller. Maybe something like:

/*
 * balance_dirty_pages() must be called by processes which are generating dirty
 * data.  It looks at the number of dirty pages in the machine and will force
 * the caller to wait once crossing the dirty threshold. If we're over
 * `background_thresh' then the writeback threads are woken to perform some
 * writeout.
 */

> @@ -1008,6 +1005,9 @@ static void balance_dirty_pages(struct a
>  	if (clear_dirty_exceeded && bdi->dirty_exceeded)
>  		bdi->dirty_exceeded = 0;
>  
> +	current->nr_dirtied = 0;
> +	current->nr_dirtied_pause = ratelimit_pages(nr_dirty, dirty_thresh);
> +
>  	if (writeback_in_progress(bdi))
>  		return;
>  
> @@ -1034,8 +1034,6 @@ void set_page_dirty_balance(struct page 
>  	}
>  }
>  
> -static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
> -
>  /**
>   * balance_dirty_pages_ratelimited_nr - balance dirty memory state
>   * @mapping: address_space which was dirtied
> @@ -1055,30 +1053,17 @@ void balance_dirty_pages_ratelimited_nr(
>  {
>  	struct backing_dev_info *bdi = mapping->backing_dev_info;
>  	unsigned long ratelimit;
> -	unsigned long *p;
>  
>  	if (!bdi_cap_account_dirty(bdi))
>  		return;
>  
> -	ratelimit = ratelimit_pages;
> -	if (mapping->backing_dev_info->dirty_exceeded)
> +	ratelimit = current->nr_dirtied_pause;
> +	if (bdi->dirty_exceeded)
>  		ratelimit = 8;
>  
> -	/*
> -	 * Check the rate limiting. Also, we do not want to throttle real-time
> -	 * tasks in balance_dirty_pages(). Period.
> -	 */
> -	preempt_disable();
> -	p =  &__get_cpu_var(bdp_ratelimits);
> -	*p += nr_pages_dirtied;
> -	if (unlikely(*p >= ratelimit)) {
> -		ratelimit = sync_writeback_pages(*p);
> -		*p = 0;
> -		preempt_enable();
> -		balance_dirty_pages(mapping, ratelimit);
> -		return;
> -	}
> -	preempt_enable();
> +	current->nr_dirtied += nr_pages_dirtied;
> +	if (unlikely(current->nr_dirtied >= ratelimit))
> +		balance_dirty_pages(mapping, current->nr_dirtied);
>  }
>  EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
>  
> @@ -1166,44 +1151,6 @@ void laptop_sync_completion(void)
>  #endif
>  
>  /*
> - * If ratelimit_pages is too high then we can get into dirty-data overload
> - * if a large number of processes all perform writes at the same time.
> - * If it is too low then SMP machines will call the (expensive)
> - * get_writeback_state too often.
> - *
> - * Here we set ratelimit_pages to a level which ensures that when all CPUs are
> - * dirtying in parallel, we cannot go more than 3% (1/32) over the dirty memory
> - * thresholds before writeback cuts in.
> - *
> - * But the limit should not be set too high.  Because it also controls the
> - * amount of memory which the balance_dirty_pages() caller has to write back.
> - * If this is too large then the caller will block on the IO queue all the
> - * time.  So limit it to four megabytes - the balance_dirty_pages() caller
> - * will write six megabyte chunks, max.
> - */
> -
> -void writeback_set_ratelimit(void)
> -{
> -	ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
> -	if (ratelimit_pages < 16)
> -		ratelimit_pages = 16;
> -	if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
> -		ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
> -}
> -
> -static int __cpuinit
> -ratelimit_handler(struct notifier_block *self, unsigned long u, void *v)
> -{
> -	writeback_set_ratelimit();
> -	return NOTIFY_DONE;
> -}
> -
> -static struct notifier_block __cpuinitdata ratelimit_nb = {
> -	.notifier_call	= ratelimit_handler,
> -	.next		= NULL,
> -};
> -
> -/*
>   * Called early on to tune the page writeback dirty limits.
>   *
>   * We used to scale dirty pages according to how total memory
> @@ -1225,9 +1172,6 @@ void __init page_writeback_init(void)
>  {
>  	int shift;
>  
> -	writeback_set_ratelimit();
> -	register_cpu_notifier(&ratelimit_nb);
> -
>  	shift = calc_period_shift();
>  	prop_descriptor_init(&vm_completions, shift);
>  	prop_descriptor_init(&vm_dirties, shift);
> --- linux-next.orig/mm/memory_hotplug.c	2011-08-05 15:36:23.000000000 +0800
> +++ linux-next/mm/memory_hotplug.c	2011-08-05 15:39:52.000000000 +0800
> @@ -527,8 +527,6 @@ int __ref online_pages(unsigned long pfn
>  
>  	vm_total_pages = nr_free_pagecache_pages();
>  
> -	writeback_set_ratelimit();
> -
>  	if (onlined_pages)
>  		memory_notify(MEM_ONLINE, &arg);
>  	unlock_memory_hotplug();
> @@ -970,7 +968,6 @@ repeat:
>  	}
>  
>  	vm_total_pages = nr_free_pagecache_pages();
> -	writeback_set_ratelimit();
>  
>  	memory_notify(MEM_OFFLINE, &arg);
>  	unlock_memory_hotplug();
> 

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
