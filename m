Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JBPRdK082976
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:25:29 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JBD84D123480
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:13:08 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JB9bBd025490
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:09:38 +1100
Message-ID: <45D9856D.1070902@in.ibm.com>
Date: Mon, 19 Feb 2007 16:39:33 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH][2/4] Add RSS accounting and control
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219065034.3626.2658.sendpatchset@balbir-laptop> <20070219005828.3b774d8f.akpm@linux-foundation.org> <45D97DF8.5080000@in.ibm.com> <20070219030141.42c65bc0.akpm@linux-foundation.org>
In-Reply-To: <20070219030141.42c65bc0.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 19 Feb 2007 16:07:44 +0530 Balbir Singh <balbir@in.ibm.com> wrote:
> 
>>>> +void memctlr_mm_free(struct mm_struct *mm)
>>>> +{
>>>> +	kfree(mm->counter);
>>>> +}
>>>> +
>>>> +static inline void memctlr_mm_assign_container_direct(struct mm_struct *mm,
>>>> +							struct container *cont)
>>>> +{
>>>> +	write_lock(&mm->container_lock);
>>>> +	mm->container = cont;
>>>> +	write_unlock(&mm->container_lock);
>>>> +}
>>> More weird locking here.
>>>
>> The container field of the mm_struct is protected by a read write spin lock.
> 
> That doesn't mean anything to me.
> 
> What would go wrong if the above locking was simply removed?  And how does
> the locking prevent that fault?
> 

Some pages could charged to the wrong container. Apart from that I do not
see anything going bad (I'll double check that).

> 
>>>> +void memctlr_mm_assign_container(struct mm_struct *mm, struct task_struct *p)
>>>> +{
>>>> +	struct container *cont = task_container(p, &memctlr_subsys);
>>>> +	struct memctlr *mem = memctlr_from_cont(cont);
>>>> +
>>>> +	BUG_ON(!mem);
>>>> +	write_lock(&mm->container_lock);
>>>> +	mm->container = cont;
>>>> +	write_unlock(&mm->container_lock);
>>>> +}
>>> And here.
>> Ditto.
> 
> ditto ;)
> 

:-)

>>>> +/*
>>>> + * Update the rss usage counters for the mm_struct and the container it belongs
>>>> + * to. We do not fail rss for pages shared during fork (see copy_one_pte()).
>>>> + */
>>>> +int memctlr_update_rss(struct mm_struct *mm, int count, bool check)
>>>> +{
>>>> +	int ret = 1;
>>>> +	struct container *cont;
>>>> +	long usage, limit;
>>>> +	struct memctlr *mem;
>>>> +
>>>> +	read_lock(&mm->container_lock);
>>>> +	cont = mm->container;
>>>> +	read_unlock(&mm->container_lock);
>>>> +
>>>> +	if (!cont)
>>>> +		goto done;
>>> And here.  I mean, if there was a reason for taking the lock around that
>>> read, then testing `cont' outside the lock just invalidated that reason.
>>>
>> We took a consistent snapshot of cont. It cannot change outside the lock,
>> we check the value outside. I am sure I missed something.
> 
> If it cannot change outside the lock then we don't need to take the lock!
> 

We took a snapshot that we thought was consistent. We check for the value
outside. I guess there is no harm, the worst thing that could happen
is wrong accounting during mm->container changes (when a task changes
container).

>> MEMCTLR_DONT_CHECK_LIMIT exists for the following reasons
>>
>> 1. Pages are shared during fork, fork() is not failed at that point
>>     since the pages are shared anyway, we allow the RSS limit to be
>>     exceeded.
>> 2. When ZERO_PAGE is added, we don't check for limits (zeromap_pte_range).
>> 3. On reducing RSS (passing -1 as the value)
> 
> OK, that might make a nice comment somewhere (if it's not already there).

Yes, thanks for keeping us humble and honest, I'll add it.

-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
