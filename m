Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9FA786B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 15:14:05 -0500 (EST)
Message-ID: <50BE5988.3050501@fusionio.com>
Date: Tue, 4 Dec 2012 21:14:00 +0100
From: Jens Axboe <jaxboe@fusionio.com>
MIME-Version: 1.0
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>

On 2012-12-03 19:53, Jeff Moyer wrote:
> Hi,
> 
> In realtime environments, it may be desirable to keep the per-bdi
> flusher threads from running on certain cpus.  This patch adds a
> cpu_list file to /sys/class/bdi/* to enable this.  The default is to tie
> the flusher threads to the same numa node as the backing device (though
> I could be convinced to make it a mask of all cpus to avoid a change in
> behaviour).

Looks sane, and I think defaulting to the home node is a sane default.
One comment:

> +	ret = cpulist_parse(buf, newmask);
> +	if (!ret) {
> +		spin_lock(&bdi->wb_lock);
> +		task = wb->task;
> +		if (task)
> +			get_task_struct(task);
> +		spin_unlock(&bdi->wb_lock);

bdi->wb_lock needs to be bh safe. The above should have caused lockdep
warnings for you.

> +		if (task) {
> +			ret = set_cpus_allowed_ptr(task, newmask);
> +			put_task_struct(task);
> +		}
> +		if (ret == 0) {
> +			mutex_lock(&bdi->flusher_cpumask_mutex);
> +			cpumask_copy(bdi->flusher_cpumask, newmask);
> +			mutex_unlock(&bdi->flusher_cpumask_mutex);
> +			ret = count;
> +		}
> +	}

> @@ -437,6 +488,14 @@ static int bdi_forker_thread(void *ptr)
>  				spin_lock_bh(&bdi->wb_lock);
>  				bdi->wb.task = task;
>  				spin_unlock_bh(&bdi->wb_lock);
> +				mutex_lock(&bdi->flusher_cpumask_mutex);
> +				ret = set_cpus_allowed_ptr(task,
> +							bdi->flusher_cpumask);
> +				mutex_unlock(&bdi->flusher_cpumask_mutex);

It'd be very useful if we had a kthread_create_cpu_on_cpumask() instead
of a _node() variant, since the latter could easily be implemented on
top of the former. But not really a show stopper for the patch...

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
