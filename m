Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 66F44900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 05:48:31 -0400 (EDT)
Date: Thu, 18 Aug 2011 17:48:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: Per-block device
 bdi->dirty_writeback_interval and bdi->dirty_expire_interval.
Message-ID: <20110818094824.GA25752@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Mel Gorman <mel@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi Kautuk,

Add CC to fsdevel and Mel and KOSAKI.

When submitting patches you can find the relevant mailing list and
developers to CC with this command under the kernel source tree:

        scripts/get_maintainer.pl YOUR-PATCH-FILE

On Thu, Aug 11, 2011 at 05:50:56PM +0530, Kautuk Consul wrote:
> Hi,
> 
> Currently the /proc/sys/vm/dirty_writeback_centisecs and
> /proc/sys/vm/dirty_expire_centisecs values are
> global to the system.
> All the BDI flush-* threads are controlled by these central values.

Yes.

> However, the user/admin might want to set different writeback speeds
> for different block devices based on
> their page write-back performance.

How can the above two sysctl values impact "writeback speeds"?
In particular, what's the "speed" you mean?

> For example, the user might want to write-back pages in smaller
> intervals to a block device which has a
> faster known writeback speed.

That's not a complete rational. What does the user ultimately want by
setting a smaller interval? What would be the problems to the other
slow devices if the user does so by simply setting a small value
_globally_?

We need strong use cases for doing such user interface changes.
Would you detail the problem and the pains that can only (or best)
be addressed by this patch?

Thanks,
Fengguang

> This patch creates 3 new counters (in centisecs) for all the BDI
> threads that were controlled centrally by these
> 2 counters:
> i)   /sys/block/<block_dev>/bdi/dirty_writeback_interval,
> ii)  /sys/block/<block_dev>/bdi/dirty_expire_interval,
> iii) /proc/sys/vm/sync_supers_centisecs.
> 
> Although these new counters can be tuned individually, I have taken
> care that they be centrally reset by changes
> to the /proc/sys/vm/dirty_expire_centisecs and
> /proc/sys/vm/dirty_writeback_centisecs so that the earlier
> functionality is not broken by distributions using these central values.
> After resetting all values centrally, these values can be tuned
> individually without altering the central values.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
> ---
> 
> diff -uprN a/fs/fs-writeback.c b/fs/fs-writeback.c
> --- a/fs/fs-writeback.c	2011-08-05 10:29:21.000000000 +0530
> +++ b/fs/fs-writeback.c	2011-08-09 09:15:37.093041675 +0530
> @@ -638,8 +638,8 @@ static inline bool over_bground_thresh(v
>   * just walks the superblock inode list, writing back any inodes which are
>   * older than a specific point in time.
>   *
> - * Try to run once per dirty_writeback_interval.  But if a writeback event
> - * takes longer than a dirty_writeback_interval interval, then leave a
> + * Try to run once per bdi->dirty_writeback_interval.  But if a writeback event
> + * takes longer than a bdi->dirty_writeback_interval interval, then leave a
>   * one-second gap.
>   *
>   * older_than_this takes precedence over nr_to_write.  So we'll only write back
> @@ -663,7 +663,7 @@ static long wb_writeback(struct bdi_writ
>  	if (wbc.for_kupdate) {
>  		wbc.older_than_this = &oldest_jif;
>  		oldest_jif = jiffies -
> -				msecs_to_jiffies(dirty_expire_interval * 10);
> +				msecs_to_jiffies(wb->bdi->dirty_expire_interval * 10);
>  	}
>  	if (!wbc.range_cyclic) {
>  		wbc.range_start = 0;
> @@ -811,15 +811,16 @@ static long wb_check_old_data_flush(stru
>  {
>  	unsigned long expired;
>  	long nr_pages;
> +	struct backing_dev_info *bdi = wb->bdi;
> 
>  	/*
>  	 * When set to zero, disable periodic writeback
>  	 */
> -	if (!dirty_writeback_interval)
> +	if (!bdi->dirty_writeback_interval)
>  		return 0;
> 
>  	expired = wb->last_old_flush +
> -			msecs_to_jiffies(dirty_writeback_interval * 10);
> +			msecs_to_jiffies(bdi->dirty_writeback_interval * 10);
>  	if (time_before(jiffies, expired))
>  		return 0;
> 
> @@ -923,8 +924,8 @@ int bdi_writeback_thread(void *data)
>  			continue;
>  		}
> 
> -		if (wb_has_dirty_io(wb) && dirty_writeback_interval)
> -			schedule_timeout(msecs_to_jiffies(dirty_writeback_interval * 10));
> +		if (wb_has_dirty_io(wb) && bdi->dirty_writeback_interval)
> +			schedule_timeout(msecs_to_jiffies(bdi->dirty_writeback_interval * 10));
>  		else {
>  			/*
>  			 * We have nothing to do, so can go sleep without any
> diff -uprN a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> --- a/include/linux/backing-dev.h	2011-08-05 10:29:21.000000000 +0530
> +++ b/include/linux/backing-dev.h	2011-08-09 09:15:37.094041619 +0530
> @@ -76,6 +76,8 @@ struct backing_dev_info {
> 
>  	unsigned int min_ratio;
>  	unsigned int max_ratio, max_prop_frac;
> +	unsigned int dirty_writeback_interval;
> +	unsigned int dirty_expire_interval;
> 
>  	struct bdi_writeback wb;  /* default writeback info for this bdi */
>  	spinlock_t wb_lock;	  /* protects work_list */
> @@ -333,4 +335,5 @@ static inline int bdi_sched_wait(void *w
>  	return 0;
>  }
> 
> +extern unsigned int shortest_dirty_writeback_interval;
>  #endif		/* _LINUX_BACKING_DEV_H */
> diff -uprN a/include/linux/writeback.h b/include/linux/writeback.h
> --- a/include/linux/writeback.h	2011-08-05 10:29:21.000000000 +0530
> +++ b/include/linux/writeback.h	2011-08-09 10:09:23.581268260 +0530
> @@ -100,6 +100,7 @@ extern unsigned long dirty_background_by
>  extern int vm_dirty_ratio;
>  extern unsigned long vm_dirty_bytes;
>  extern unsigned int dirty_writeback_interval;
> +extern unsigned int sync_supers_interval;
>  extern unsigned int dirty_expire_interval;
>  extern int vm_highmem_is_dirtyable;
>  extern int block_dump;
> @@ -123,6 +124,10 @@ extern int dirty_bytes_handler(struct ct
>  struct ctl_table;
>  int dirty_writeback_centisecs_handler(struct ctl_table *, int,
>  				      void __user *, size_t *, loff_t *);
> +int sync_supers_centisecs_handler(struct ctl_table *, int,
> +				      void __user *, size_t *, loff_t *);
> +int dirty_expire_centisecs_handler(struct ctl_table *, int,
> +				      void __user *, size_t *, loff_t *);
> 
>  void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
>  unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
> diff -uprN a/kernel/sysctl.c b/kernel/sysctl.c
> --- a/kernel/sysctl.c	2011-08-05 10:29:21.000000000 +0530
> +++ b/kernel/sysctl.c	2011-08-09 12:39:43.453087554 +0530
> @@ -1076,12 +1076,19 @@ static struct ctl_table vm_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= dirty_writeback_centisecs_handler,
>  	},
> +    {
> +        .procname   = "sync_supers_centisecs",
> +        .data       = &sync_supers_interval,
> +        .maxlen     = sizeof(sync_supers_interval),
> +        .mode       = 0644,
> +        .proc_handler   = sync_supers_centisecs_handler,
> +    },
>  	{
>  		.procname	= "dirty_expire_centisecs",
>  		.data		= &dirty_expire_interval,
>  		.maxlen		= sizeof(dirty_expire_interval),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec_minmax,
> +		.proc_handler	= dirty_expire_centisecs_handler,
>  		.extra1		= &zero,
>  	},
>  	{
> diff -uprN a/mm/backing-dev.c b/mm/backing-dev.c
> --- a/mm/backing-dev.c	2011-08-05 10:29:21.000000000 +0530
> +++ b/mm/backing-dev.c	2011-08-09 12:08:06.287079027 +0530
> @@ -39,6 +39,10 @@ DEFINE_SPINLOCK(bdi_lock);
>  LIST_HEAD(bdi_list);
>  LIST_HEAD(bdi_pending_list);
> 
> +/* Same value as the dirty_writeback_interval as this is what our
> + * initial shortest_dirty_writeback_interval. */
> +unsigned int shortest_dirty_writeback_interval = 5 * 100;
> +
>  static struct task_struct *sync_supers_tsk;
>  static struct timer_list sync_supers_timer;
> 
> @@ -204,12 +208,50 @@ static ssize_t max_ratio_store(struct de
>  }
>  BDI_SHOW(max_ratio, bdi->max_ratio)
> 
> +static ssize_t dirty_writeback_interval_store(struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t count)
> +{
> +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> +	char *end;
> +	unsigned int interval;
> +	ssize_t ret = -EINVAL;
> +
> +	interval = simple_strtoul(buf, &end, 10);
> +	if (*buf && (end[0] == '\0' || (end[0] == '\n' && end[1] == '\0'))) {
> +		bdi->dirty_writeback_interval = interval;
> +		shortest_dirty_writeback_interval =
> +						min(shortest_dirty_writeback_interval,interval);
> +		ret = count;
> +	}
> +	return ret;
> +}
> +BDI_SHOW(dirty_writeback_interval, bdi->dirty_writeback_interval)
> +
> +static ssize_t dirty_expire_interval_store (struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t count)
> +{
> +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> +	char *end;
> +	unsigned int interval;
> +	ssize_t ret = -EINVAL;
> +
> +	interval = simple_strtoul(buf, &end, 10);
> +	if (*buf && (end[0] == '\0' || (end[0] == '\n' && end[1] == '\0'))) {
> +		bdi->dirty_expire_interval = interval;
> +		ret = count;
> +	}
> +	return ret;
> +}
> +BDI_SHOW(dirty_expire_interval, bdi->dirty_expire_interval)
> +
>  #define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
> 
>  static struct device_attribute bdi_dev_attrs[] = {
>  	__ATTR_RW(read_ahead_kb),
>  	__ATTR_RW(min_ratio),
>  	__ATTR_RW(max_ratio),
> +	__ATTR_RW(dirty_writeback_interval),
> +	__ATTR_RW(dirty_expire_interval),
>  	__ATTR_NULL,
>  };
> 
> @@ -291,7 +333,7 @@ void bdi_arm_supers_timer(void)
>  	if (!dirty_writeback_interval)
>  		return;
> 
> -	next = msecs_to_jiffies(dirty_writeback_interval * 10) + jiffies;
> +	next = msecs_to_jiffies(sync_supers_interval* 10) + jiffies;
>  	mod_timer(&sync_supers_timer, round_jiffies_up(next));
>  }
> 
> @@ -336,7 +378,7 @@ void bdi_wakeup_thread_delayed(struct ba
>  {
>  	unsigned long timeout;
> 
> -	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
> +	timeout = msecs_to_jiffies(bdi->dirty_writeback_interval * 10);
>  	mod_timer(&bdi->wb.wakeup_timer, jiffies + timeout);
>  }
> 
> @@ -348,7 +390,19 @@ static unsigned long bdi_longest_inactiv
>  {
>  	unsigned long interval;
> 
> -	interval = msecs_to_jiffies(dirty_writeback_interval * 10);
> +	interval = msecs_to_jiffies(shortest_dirty_writeback_interval * 10);
> +	return max(5UL * 60 * HZ, interval);
> +}
> +
> +/*
> + * Calculate the longest interval (jiffies) this bdi thread is allowed to be
> + * inactive.
> + */
> +static unsigned long bdi_longest_inactive_this(struct backing_dev_info *bdi)
> +{
> +	unsigned long interval;
> +
> +	interval = msecs_to_jiffies(bdi->dirty_writeback_interval * 10);
>  	return max(5UL * 60 * HZ, interval);
>  }
> 
> @@ -422,7 +476,7 @@ static int bdi_forker_thread(void *ptr)
>  			 */
>  			if (bdi->wb.task && !have_dirty_io &&
>  			    time_after(jiffies, bdi->wb.last_active +
> -						bdi_longest_inactive())) {
> +						bdi_longest_inactive_this(bdi))) {
>  				task = bdi->wb.task;
>  				bdi->wb.task = NULL;
>  				spin_unlock(&bdi->wb_lock);
> @@ -469,7 +523,7 @@ static int bdi_forker_thread(void *ptr)
>  			break;
> 
>  		case NO_ACTION:
> -			if (!wb_has_dirty_io(me) || !dirty_writeback_interval)
> +			if (!wb_has_dirty_io(me) || !me->bdi->dirty_writeback_interval)
>  				/*
>  				 * There are no dirty data. The only thing we
>  				 * should now care about is checking for
> @@ -479,7 +533,7 @@ static int bdi_forker_thread(void *ptr)
>  				 */
>  				schedule_timeout(bdi_longest_inactive());
>  			else
> -				schedule_timeout(msecs_to_jiffies(dirty_writeback_interval * 10));
> +				schedule_timeout(msecs_to_jiffies(me->bdi->dirty_writeback_interval * 10));
>  			try_to_freeze();
>  			/* Back to the main loop */
>  			continue;
> @@ -641,6 +695,8 @@ int bdi_init(struct backing_dev_info *bd
>  	bdi->min_ratio = 0;
>  	bdi->max_ratio = 100;
>  	bdi->max_prop_frac = PROP_FRAC_BASE;
> +	bdi->dirty_writeback_interval = dirty_writeback_interval;
> +	bdi->dirty_expire_interval = dirty_expire_interval;
>  	spin_lock_init(&bdi->wb_lock);
>  	INIT_LIST_HEAD(&bdi->bdi_list);
>  	INIT_LIST_HEAD(&bdi->work_list);
> diff -uprN a/mm/page-writeback.c b/mm/page-writeback.c
> --- a/mm/page-writeback.c	2011-08-05 10:29:21.000000000 +0530
> +++ b/mm/page-writeback.c	2011-08-09 13:09:37.985919961 +0530
> @@ -92,6 +92,11 @@ unsigned long vm_dirty_bytes;
>  unsigned int dirty_writeback_interval = 5 * 100; /* centiseconds */
> 
>  /*
> + * The interval between sync_supers thread writebacks
> + */
> +unsigned int sync_supers_interval = 5 * 100; /* centiseconds */
> +
> +/*
>   * The longest time for which data is allowed to remain dirty
>   */
>  unsigned int dirty_expire_interval = 30 * 100; /* centiseconds */
> @@ -686,8 +691,60 @@ void throttle_vm_writeout(gfp_t gfp_mask
>  int dirty_writeback_centisecs_handler(ctl_table *table, int write,
>  	void __user *buffer, size_t *length, loff_t *ppos)
>  {
> +	struct backing_dev_info *bdi;
> +
> +	proc_dointvec(table, write, buffer, length, ppos);
> +
> +	if (write) {
> +		/* Traverse all the BDIs registered to the BDI list and reset their
> +		 * bdi->dirty_writeback_interval to this value. */
> +	    spin_lock_bh(&bdi_lock);
> +		list_for_each_entry(bdi, &bdi_list, bdi_list)
> +			bdi->dirty_writeback_interval = dirty_writeback_interval;
> +	    spin_unlock_bh(&bdi_lock);
> +
> +		sync_supers_interval =
> +			shortest_dirty_writeback_interval = dirty_writeback_interval;
> +
> +	}
> +
> +	bdi_arm_supers_timer();
> +
> +	return 0;
> +}
> +
> +/*
> + * sysctl handler for /proc/sys/vm/sync_supers_centisecs
> + */
> +int sync_supers_centisecs_handler(ctl_table *table, int write,
> +	void __user *buffer, size_t *length, loff_t *ppos)
> +{
>  	proc_dointvec(table, write, buffer, length, ppos);
> +
>  	bdi_arm_supers_timer();
> +
> +	return 0;
> +}
> +
> +/*
> + * sysctl handler for /proc/sys/vm/dirty_expire_centisecs
> + */
> +int dirty_expire_centisecs_handler(ctl_table *table, int write,
> +	void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	struct backing_dev_info *bdi;
> +
> +	proc_dointvec_minmax(table, write, buffer, length, ppos);
> +
> +	if (write) {
> +		/* Traverse all the BDIs registered to the BDI list and reset their
> +		 * bdi->dirty_expire_interval to this value. */
> +	    spin_lock_bh(&bdi_lock);
> +		list_for_each_entry(bdi, &bdi_list, bdi_list)
> +			bdi->dirty_expire_interval = dirty_expire_interval;
> +	    spin_unlock_bh(&bdi_lock);
> +	}
> +
>  	return 0;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
