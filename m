Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A05886B0062
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 10:49:28 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [patch] bdi: add a user-tunable cpu_list for the bdi flusher threads
References: <x49boehtipu.fsf@segfault.boston.devel.redhat.com>
	<20121130221542.GM18574@lenny.home.zabbo.net>
Date: Mon, 03 Dec 2012 10:49:25 -0500
In-Reply-To: <20121130221542.GM18574@lenny.home.zabbo.net> (Zach Brown's
	message of "Fri, 30 Nov 2012 14:15:42 -0800")
Message-ID: <x49zk1vnnju.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Zach Brown <zab@redhat.com> writes:

>> +	ret = cpulist_parse(buf, newmask);
>> +	if (!ret) {
>> +		spin_lock(&bdi->wb_lock);
>> +		task = wb->task;
>> +		get_task_struct(task);
>> +		spin_unlock(&bdi->wb_lock);
>> +		if (task)
>> +			ret = set_cpus_allowed_ptr(task, newmask);
>> +		put_task_struct(task);
>
> If that test for a non-null task is needed then surely the get and put
> need to be similarly protected :).

How embarrassing.

>> +		bdi->flusher_cpumask = kmalloc(sizeof(cpumask_t), GFP_KERNEL);
>> +		if (!bdi->flusher_cpumask)
>> +			return -ENOMEM;
>
> The bare GFP_KERNEL raises an eyebrow.  Some bdi_init() callers like
> blk_alloc_queue_node() look like they'll want to pass in a gfp_t for the
> allocation.

I'd be surprised if that was necessary, seeing how every single caller
of blk_alloc_queue_node passes in GFP_KERNEL.  I'll make the change,
though, there aren't too many callers of bdi_init out there.

> And shouldn't this be freed in the error path of bdi_init()?

Yes.  ;-)

Thanks!
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
