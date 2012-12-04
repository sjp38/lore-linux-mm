Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6FE1B6B006C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 15:23:16 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher threads
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
	<50BE5988.3050501@fusionio.com>
Date: Tue, 04 Dec 2012 15:23:13 -0500
In-Reply-To: <50BE5988.3050501@fusionio.com> (Jens Axboe's message of "Tue, 4
	Dec 2012 21:14:00 +0100")
Message-ID: <x498v9dpnwu.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>

Jens Axboe <jaxboe@fusionio.com> writes:

> On 2012-12-03 19:53, Jeff Moyer wrote:
>> Hi,
>> 
>> In realtime environments, it may be desirable to keep the per-bdi
>> flusher threads from running on certain cpus.  This patch adds a
>> cpu_list file to /sys/class/bdi/* to enable this.  The default is to tie
>> the flusher threads to the same numa node as the backing device (though
>> I could be convinced to make it a mask of all cpus to avoid a change in
>> behaviour).
>
> Looks sane, and I think defaulting to the home node is a sane default.
> One comment:
>
>> +	ret = cpulist_parse(buf, newmask);
>> +	if (!ret) {
>> +		spin_lock(&bdi->wb_lock);
>> +		task = wb->task;
>> +		if (task)
>> +			get_task_struct(task);
>> +		spin_unlock(&bdi->wb_lock);
>
> bdi->wb_lock needs to be bh safe. The above should have caused lockdep
> warnings for you.

No lockdep complaints.  I'll double check that's enabled (but I usually
have it enabled...).

>> @@ -437,6 +488,14 @@ static int bdi_forker_thread(void *ptr)
>>  				spin_lock_bh(&bdi->wb_lock);
>>  				bdi->wb.task = task;
>>  				spin_unlock_bh(&bdi->wb_lock);
>> +				mutex_lock(&bdi->flusher_cpumask_mutex);
>> +				ret = set_cpus_allowed_ptr(task,
>> +							bdi->flusher_cpumask);
>> +				mutex_unlock(&bdi->flusher_cpumask_mutex);
>
> It'd be very useful if we had a kthread_create_cpu_on_cpumask() instead
> of a _node() variant, since the latter could easily be implemented on
> top of the former. But not really a show stopper for the patch...

Hmm, if it isn't too scary, I might give this a try.

Thanks!
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
