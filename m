Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A82046B002B
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 17:15:44 -0500 (EST)
Date: Fri, 30 Nov 2012 14:15:42 -0800
From: Zach Brown <zab@redhat.com>
Subject: Re: [patch] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
Message-ID: <20121130221542.GM18574@lenny.home.zabbo.net>
References: <x49boehtipu.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49boehtipu.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> +	ret = cpulist_parse(buf, newmask);
> +	if (!ret) {
> +		spin_lock(&bdi->wb_lock);
> +		task = wb->task;
> +		get_task_struct(task);
> +		spin_unlock(&bdi->wb_lock);
> +		if (task)
> +			ret = set_cpus_allowed_ptr(task, newmask);
> +		put_task_struct(task);

If that test for a non-null task is needed then surely the get and put
need to be similarly protected :).

> +		bdi->flusher_cpumask = kmalloc(sizeof(cpumask_t), GFP_KERNEL);
> +		if (!bdi->flusher_cpumask)
> +			return -ENOMEM;

The bare GFP_KERNEL raises an eyebrow.  Some bdi_init() callers like
blk_alloc_queue_node() look like they'll want to pass in a gfp_t for the
allocation.

And shouldn't this be freed in the error path of bdi_init()?

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
