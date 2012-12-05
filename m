Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 963066B006C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 02:43:51 -0500 (EST)
Message-ID: <50BEFB2D.2000008@fusionio.com>
Date: Wed, 5 Dec 2012 08:43:41 +0100
From: Jens Axboe <jaxboe@fusionio.com>
MIME-Version: 1.0
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com> <50BE5988.3050501@fusionio.com> <x498v9dpnwu.fsf@segfault.boston.devel.redhat.com> <50BE5C99.6070703@fusionio.com> <x494nk1pi7h.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x494nk1pi7h.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>, "tj@kernel.org" <tj@kernel.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo <mingo@redhat.com>

On 2012-12-04 23:26, Jeff Moyer wrote:
> Jens Axboe <jaxboe@fusionio.com> writes:
> 
>>>>> @@ -437,6 +488,14 @@ static int bdi_forker_thread(void *ptr)
>>>>>  				spin_lock_bh(&bdi->wb_lock);
>>>>>  				bdi->wb.task = task;
>>>>>  				spin_unlock_bh(&bdi->wb_lock);
>>>>> +				mutex_lock(&bdi->flusher_cpumask_mutex);
>>>>> +				ret = set_cpus_allowed_ptr(task,
>>>>> +							bdi->flusher_cpumask);
>>>>> +				mutex_unlock(&bdi->flusher_cpumask_mutex);
>>>>
>>>> It'd be very useful if we had a kthread_create_cpu_on_cpumask() instead
>>>> of a _node() variant, since the latter could easily be implemented on
>>>> top of the former. But not really a show stopper for the patch...
>>>
>>> Hmm, if it isn't too scary, I might give this a try.
>>
>> Should not be, pretty much just removing the node part of the create
>> struct passed in and making it a cpumask. And for the on_node() case,
>> cpumask_of_ndoe() will do the trick.
> 
> I think it's a bit more involved than that.  If you look at
> kthread_create_on_node, the node portion only applies to where the
> memory comes from, it says nothing of scheduling.  To whit:
> 
>                 /*                                                              
>                  * root may have changed our (kthreadd's) priority or CPU mask.
>                  * The kernel thread should not inherit these properties.       
>                  */
>                 sched_setscheduler_nocheck(create.result, SCHED_NORMAL, &param);
>                 set_cpus_allowed_ptr(create.result, cpu_all_mask);
> 
> So, if I were to make the change you suggested, I would be modifying the
> existing behaviour.  The way things stand, I think
> kthread_create_on_node violates the principal of least surprise.  ;-)  I
> would prefer a variant that affected scheduling behaviour as well as
> memory placement.  Tejun, Peter, Ingo, what are your opinions?

Huh you are right, I completely missed that set_cpus_allowed_ptr() uses
cpu_all_mask and not mask_of_node(node). Doesn't make a lot of sense to
me... And yes, in any case, it definitely is a bad API, not very
logical.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
