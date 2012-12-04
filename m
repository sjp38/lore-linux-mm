Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 6AD2C6B002B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 21:34:09 -0500 (EST)
Date: Tue, 4 Dec 2012 13:34:05 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
Message-ID: <20121204023405.GE32450@dastard>
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zach Brown <zab@redhat.com>

On Mon, Dec 03, 2012 at 01:53:39PM -0500, Jeff Moyer wrote:
> Hi,
> 
> In realtime environments, it may be desirable to keep the per-bdi
> flusher threads from running on certain cpus.  This patch adds a
> cpu_list file to /sys/class/bdi/* to enable this.  The default is to tie
> the flusher threads to the same numa node as the backing device (though
> I could be convinced to make it a mask of all cpus to avoid a change in
> behaviour).

The default seems reasonable to me.

> Comments, as always, are appreciated.
.....

> +static ssize_t cpu_list_store(struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t count)
> +{
> +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> +	struct bdi_writeback *wb = &bdi->wb;
> +	cpumask_var_t newmask;
> +	ssize_t ret;
> +	struct task_struct *task;
> +
> +	if (!alloc_cpumask_var(&newmask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	ret = cpulist_parse(buf, newmask);
> +	if (!ret) {
> +		spin_lock(&bdi->wb_lock);
> +		task = wb->task;
> +		if (task)
> +			get_task_struct(task);
> +		spin_unlock(&bdi->wb_lock);
> +		if (task) {
> +			ret = set_cpus_allowed_ptr(task, newmask);
> +			put_task_struct(task);
> +		}

Why is this set here outside the bdi->flusher_cpumask_mutex?

Also, I'd prefer it named "..._lock" as that is the normal
convention for such variables. You can tell the type of lock from
the declaration or the use...

....

> @@ -437,6 +488,14 @@ static int bdi_forker_thread(void *ptr)
>  				spin_lock_bh(&bdi->wb_lock);
>  				bdi->wb.task = task;
>  				spin_unlock_bh(&bdi->wb_lock);
> +				mutex_lock(&bdi->flusher_cpumask_mutex);
> +				ret = set_cpus_allowed_ptr(task,
> +							bdi->flusher_cpumask);
> +				mutex_unlock(&bdi->flusher_cpumask_mutex);

As it is set under the lock here....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
