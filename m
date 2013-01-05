Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9E4726B005D
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 06:46:32 -0500 (EST)
Received: by mail-ia0-f175.google.com with SMTP id z3so14647535iad.34
        for <linux-mm@kvack.org>; Sat, 05 Jan 2013 03:46:32 -0800 (PST)
Message-ID: <1357386394.9001.0.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH v2] fadvise: perform WILLNEED readahead asynchronously
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sat, 05 Jan 2013 05:46:34 -0600
In-Reply-To: <20121225022251.GA25992@dcvr.yhbt.net>
References: <20121225022251.GA25992@dcvr.yhbt.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Dave Chinner <david@fromorbit.com>, Zheng Liu <gnehzuil.liu@gmail.com>

On Tue, 2012-12-25 at 02:22 +0000, Eric Wong wrote:

Please add changelog.

> Using fadvise with POSIX_FADV_WILLNEED can be very slow and cause
> user-visible latency.  This hurts interactivity and encourages
> userspace to resort to background threads for readahead (or avoid
> POSIX_FADV_WILLNEED entirely).
> 
> "strace -T" timing on an uncached, one gigabyte file:
> 
>  Before: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <2.484832>
>   After: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <0.000061>
> 
> For a smaller 9.8M request, there is still a significant improvement:
> 
>  Before: fadvise64(3, 0, 10223108, POSIX_FADV_WILLNEED) = 0 <0.005399>
>   After: fadvise64(3, 0, 10223108, POSIX_FADV_WILLNEED) = 0 <0.000059>
> 
> Even with a small 1M request, there is an improvement:
> 
>  Before: fadvise64(3, 0, 1048576, POSIX_FADV_WILLNEED) = 0 <0.000474>
>   After: fadvise64(3, 0, 1048576, POSIX_FADV_WILLNEED) = 0 <0.000063>
> 
> While userspace can mimic the effect of this commit by using a
> background thread to perform readahead(), this allows for simpler
> userspace code.
> 
> To mitigate denial-of-service attacks, inflight (but incomplete)
> readahead requests are accounted for when new readahead requests arrive.
> New readahead requests may be reduced or ignored if there are too many
> inflight readahead pages in the workqueue.
> 
> IO priority is also taken into account for workqueue readahead.
> Normal and idle priority tasks share a concurrency-limited workqueue to
> prevent excessive readahead requests from taking place simultaneously.
> This normal workqueue is concurrency-limited to one task per-CPU
> (like AIO).
> 
> Real-time I/O tasks get their own high-priority workqueue independent
> of the normal workqueue.
> 
> The impact of idle tasks is also reduced and they are more likely to
> have advisory readahead requests ignored/dropped when read congestion
> occurs.
> 
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Zheng Liu <gnehzuil.liu@gmail.com>
> Signed-off-by: Eric Wong <normalperson@yhbt.net>
> ---
>   I have not tested on NUMA (since I've no access to NUMA hardware)
>   and do not know how the use of the workqueue affects RA performance.
>   I'm only using WQ_UNBOUND on non-NUMA, though.
> 
>   I'm halfway tempted to make DONTNEED use a workqueue, too.
>   Having perceptible latency on advisory syscalls is unpleasant and
>   keeping the latency makes little sense if we can hide it.
> 
>  include/linux/mm.h |   3 +
>  mm/fadvise.c       |  10 +--
>  mm/readahead.c     | 217 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 224 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6320407..90b361c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1536,6 +1536,9 @@ void task_dirty_inc(struct task_struct *tsk);
>  #define VM_MAX_READAHEAD	128	/* kbytes */
>  #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
>  
> +void wq_page_cache_readahead(struct address_space *mapping, struct file *filp,
> +			pgoff_t offset, unsigned long nr_to_read);
> +
>  int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  			pgoff_t offset, unsigned long nr_to_read);
>  
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index a47f0f5..cf3bd4c 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -102,12 +102,10 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>  		if (!nrpages)
>  			nrpages = ~0UL;
>  
> -		/*
> -		 * Ignore return value because fadvise() shall return
> -		 * success even if filesystem can't retrieve a hint,
> -		 */
> -		force_page_cache_readahead(mapping, f.file, start_index,
> -					   nrpages);
> +		get_file(f.file); /* fput() is called by workqueue */
> +
> +		/* queue up the request, don't care if it fails */
> +		wq_page_cache_readahead(mapping, f.file, start_index, nrpages);
>  		break;
>  	case POSIX_FADV_NOREUSE:
>  		break;
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 7963f23..f9e0705 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -19,6 +19,45 @@
>  #include <linux/pagemap.h>
>  #include <linux/syscalls.h>
>  #include <linux/file.h>
> +#include <linux/workqueue.h>
> +#include <linux/ioprio.h>
> +
> +static struct workqueue_struct *ra_be __read_mostly;
> +static struct workqueue_struct *ra_rt __read_mostly;
> +static unsigned long ra_nr_queued;
> +static DEFINE_SPINLOCK(ra_nr_queued_lock);
> +
> +struct wq_ra_req {
> +	struct work_struct work;
> +	struct address_space *mapping;
> +	struct file *file;
> +	pgoff_t offset;
> +	unsigned long nr_to_read;
> +	int ioprio;
> +};
> +
> +static void wq_ra_enqueue(struct wq_ra_req *);
> +
> +/* keep NUMA readahead on the same CPU for now... */
> +#ifdef CONFIG_NUMA
> +#  define RA_WQ_FLAGS 0
> +#else
> +#  define RA_WQ_FLAGS WQ_UNBOUND
> +#endif
> +
> +static int __init init_readahead(void)
> +{
> +	/* let tasks with real-time priorities run freely */
> +	ra_rt = alloc_workqueue("readahead_rt", RA_WQ_FLAGS|WQ_HIGHPRI, 0);
> +
> +	/* limit async concurrency of normal and idle readahead */
> +	ra_be = alloc_workqueue("readahead_be", RA_WQ_FLAGS, 1);
> +
> +	BUG_ON(!ra_be || !ra_rt);
> +	return 0;
> +}
> +
> +early_initcall(init_readahead);
>  
>  /*
>   * Initialise a struct file's readahead state.  Assumes that the caller has
> @@ -205,6 +244,183 @@ out:
>  }
>  
>  /*
> + * if nr_to_read is too large, adjusts nr_to_read to the maximum sane value.
> + * atomically increments ra_nr_queued by nr_to_read if possible
> + * returns the number of pages queued (zero is possible)
> + */
> +static unsigned long ra_queue_begin(struct address_space *mapping,
> +				unsigned long nr_to_read)
> +{
> +	unsigned long flags;
> +	unsigned long nr_isize, max;
> +	loff_t isize;
> +
> +	/* do not attempt readahead pages beyond current inode size */
> +	isize = i_size_read(mapping->host);
> +	if (isize == 0)
> +		return 0;
> +	nr_isize = (isize >> PAGE_CACHE_SHIFT) + 1;
> +	nr_to_read = min(nr_to_read, nr_isize);
> +
> +	/* check if we can do readahead at all */
> +	max = max_sane_readahead(~0UL);
> +	nr_to_read = min(nr_to_read, max);
> +	if (nr_to_read == 0)
> +		return 0;
> +
> +	/* check if we queued up too much readahead */
> +	spin_lock_irqsave(&ra_nr_queued_lock, flags);
> +
> +	if (ra_nr_queued >= max) {
> +		/* too much queued, do not queue more */
> +		nr_to_read = 0;
> +	} else {
> +		/* trim to reflect maximum amount possible */
> +		if ((nr_to_read + ra_nr_queued) > max)
> +			nr_to_read = max - ra_nr_queued;
> +
> +		ra_nr_queued += nr_to_read;
> +	}
> +
> +	spin_unlock_irqrestore(&ra_nr_queued_lock, flags);
> +
> +	return nr_to_read;
> +}
> +
> +/*
> + * atomically decrements ra_nr_queued by nr_pages when a part of the
> + * readahead request is done (or aborted)
> + */
> +static void ra_queue_complete(unsigned long nr_pages)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&ra_nr_queued_lock, flags);
> +	ra_nr_queued -= nr_pages;
> +	spin_unlock_irqrestore(&ra_nr_queued_lock, flags);
> +}
> +
> +/*
> + * Read a chunk of the read-ahead request, this will re-enqueue work.
> + * Use 2 megabyte units per chunk to avoid pinning too much memory at once.
> + */
> +static void wq_ra_req_fn(struct work_struct *work)
> +{
> +	unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
> +	struct wq_ra_req *req = container_of(work, struct wq_ra_req, work);
> +	int ret;
> +	int old_prio, tmp_prio;
> +	struct task_struct *p = current;
> +
> +	/* limit the impact of idle tasks */
> +	if (IOPRIO_PRIO_CLASS(req->ioprio) == IOPRIO_CLASS_IDLE) {
> +		/* drop requests for idle tasks if there is congestion */
> +		if (bdi_read_congested(req->mapping->backing_dev_info))
> +			goto done;
> +
> +		/* smaller chunk size gives priority to others */
> +		this_chunk /= 8;
> +
> +		/*
> +		 * setting IOPRIO_CLASS_IDLE may stall everything else,
> +		 * use best-effort instead
> +		 */
> +		tmp_prio = IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 7);
> +	} else {
> +		tmp_prio = req->ioprio;
> +	}
> +
> +	if (this_chunk > req->nr_to_read)
> +		this_chunk = req->nr_to_read;
> +
> +	/* stop the async readahead if we cannot proceed */
> +	this_chunk = max_sane_readahead(this_chunk);
> +	if (this_chunk == 0)
> +		goto done;
> +
> +	/* temporarily change our IO prio to that of the originating task */
> +	old_prio = IOPRIO_PRIO_VALUE(task_nice_ioclass(p), task_nice_ioprio(p));
> +	set_task_ioprio(p, tmp_prio);
> +	ret = __do_page_cache_readahead(req->mapping, req->file,
> +					req->offset, this_chunk, 0);
> +	set_task_ioprio(p, old_prio);
> +
> +	/* requeue if readahead was successful and there is more to queue */
> +	if (ret >= 0 && req->nr_to_read > this_chunk) {
> +		req->offset += this_chunk;
> +		req->nr_to_read -= this_chunk;
> +		ra_queue_complete(this_chunk);
> +
> +		/* keep going, but yield to other requests */
> +		wq_ra_enqueue(req);
> +	} else {
> +done:
> +		ra_queue_complete(req->nr_to_read);
> +		fput(req->file);
> +		kfree(req);
> +	}
> +}
> +
> +static void wq_ra_enqueue(struct wq_ra_req *req)
> +{
> +	INIT_WORK(&req->work, wq_ra_req_fn);
> +
> +	if (IOPRIO_PRIO_CLASS(req->ioprio) == IOPRIO_CLASS_RT)
> +		queue_work(ra_rt, &req->work);
> +	else
> +		queue_work(ra_be, &req->work);
> +}
> +
> +/*
> + * Fire-and-forget readahead using a workqueue, this allocates pages
> + * inside a workqueue and returns as soon as possible.
> + */
> +void wq_page_cache_readahead(struct address_space *mapping, struct file *filp,
> +		pgoff_t offset, unsigned long nr_to_read)
> +{
> +	struct wq_ra_req *req;
> +	int ioprio;
> +	struct task_struct *p;
> +
> +	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
> +		goto skip_ra;
> +
> +	nr_to_read = ra_queue_begin(mapping, nr_to_read);
> +	if (!nr_to_read)
> +		goto skip_ra;
> +
> +	p = current;
> +	if (p->io_context)
> +		ioprio = p->io_context->ioprio;
> +	else
> +		ioprio = IOPRIO_PRIO_VALUE(task_nice_ioclass(p),
> +						task_nice_ioprio(p));
> +
> +	/* drop requests for idle tasks if there is congestion */
> +	if (IOPRIO_PRIO_CLASS(ioprio) == IOPRIO_CLASS_IDLE
> +	    && bdi_read_congested(mapping->backing_dev_info))
> +		goto skip_ra_done;
> +
> +	req = kzalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req)
> +		goto skip_ra_done;
> +
> +	/* offload to a workqueue and return to caller ASAP */
> +	req->mapping = mapping;
> +	req->file = filp;
> +	req->offset = offset;
> +	req->nr_to_read = nr_to_read;
> +	req->ioprio = ioprio;
> +	wq_ra_enqueue(req);
> +
> +	return;
> +skip_ra_done:
> +	ra_queue_complete(nr_to_read);
> +skip_ra:
> +	fput(filp);
> +}
> +
> +/*
>   * Chunk the readahead into 2 megabyte units, so that we don't pin too much
>   * memory at once.
>   */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
