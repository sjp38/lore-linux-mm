Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 545936B00AD
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 02:26:05 -0500 (EST)
Message-ID: <4B95F802.9020308@cn.fujitsu.com>
Date: Tue, 09 Mar 2010 15:25:54 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
References: <4B94CD2D.8070401@cn.fujitsu.com> <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-9 5:46, David Rientjes wrote:
[snip]
>> Considering the change of task->mems_allowed is not frequent, so in this patch,
>> I use two variables as a tag to indicate whether task->mems_allowed need be
>> update or not. And before setting the tag, cpuset caches the new mask of every
>> task at its task_struct.
>>
> 
> So what exactly is the benefit of 58568d2 from last June that caused this 
> issue to begin with?  It seems like this entire patchset is a revert of 
> that commit.  So why shouldn't we just revert that one commit and then add 
> the locking and updating necessary for configs where
> MAX_NUMNODES > BITS_PER_LONG on top?

I worried about the consistency of task->mempolicy with task->mems_allowed for
configs where MAX_NUMNODES <= BITS_PER_LONG. 

The problem that I worried is fowllowing:
When the kernel allocator allocates pages for tasks, it will access task->mempolicy
first and get the allowed node, then check whether that node is allowed by
task->mems_allowed.

But, Without this patch, ->mempolicy and ->mems_allowed is not updated at the same
time. the kernel allocator may access the inconsistent information of ->mempolicy
and ->mems_allowed, sush as the allocator gets the allowed node from old mempolicy,
but checks whether that node is allowed by new mems_allowed which does't intersect
old mempolicy.

So I made this patchset.

>> +/**
>> + * cpuset_update_task_mems_allowed - update task memory placement
>> + *
>> + * If the current task's mems_allowed_for_update and mempolicy_for_update are
>> + * changed by cpuset behind our backs, update current->mems_allowed,
>> + * mems_generation and task NUMA mempolicy to the new value.
>> + *
>> + * Call WITHOUT mems_lock held.
>> + * 
>> + * This routine is needed to update the pre-task mems_allowed and mempolicy
>> + * within the tasks context, when it is trying to allocate memory.
>> + */
>> +static __always_inline void cpuset_update_task_mems_allowed(void)
>> +{
>> +	struct task_struct *tsk = current;
>> +	unsigned long flags;
>> +
>> +	if (unlikely(tsk->mems_generation != tsk->mems_generation_for_update)) {
>> +		task_mems_lock_irqsave(tsk, flags);
>> +		tsk->mems_allowed = tsk->mems_allowed_for_update;
>> +		tsk->mems_generation = tsk->mems_generation_for_update;
>> +		task_mems_unlock_irqrestore(tsk, flags);
> 
> By this synchronization, you're guaranteeing that no other kernel code 
> ever reads tsk->mems_allowed when tsk != current?  Otherwise, you're 
> simply protecting the store to tsk->mems_allowed here and not serializing 
> on the loads that can return empty nodemasks.

I guarantee that no other kernel code changes tsk->mems_allowed when tsk != current.
so every task can  be safe to read tsk->mems_allowed without lock.

I will use mems_lock to protect it when other task reads. 

>> +	/* Protection of ->mems_allowed_for_update */
>> +	spinlock_t mems_lock;
>> +	/*
>> +	 * This variable(mems_allowed_for_update) are just used for caching
>> +	 * memory placement information.
>> +	 *
>> +	 * ->mems_allowed are used by the kernel allocator.
>> +	 */
>> +	nodemask_t mems_allowed_for_update;	/* Protected by mems_lock */
> 
> Another nodemask_t in struct task_struct for this?  And for all configs, 
> including those that can do atomic updates to mems_allowed?

Yes, for all configs.

> 
>> +
>> +	/*
>> +	 * Increment this integer everytime ->mems_allowed_for_update is
>> +	 * changed by cpuset. Task can compare this number with mems_generation,
>> +	 * and if they are not the same, mems_allowed_for_update is changed and
>> +	 * ->mems_allowed must be updated. In this way, tasks can avoid having
>> +	 * to lock and reload mems_allowed_for_update unless it is changed.
>> +	 */
>> +	int mems_generation_for_update;
>> +	/*
>> +	 * After updating mems_allowed, set mems_generation to
>> +	 * mems_generation_for_update.
>> +	 */
>> +	int mems_generation;
> 
> I don't see why you need two mems_generation numbers, one should belong in 
> the task's cpuset.  Then you can compare tsk->mems_generation to 
> task_cs(tsk)->mems_generation at cpuset_update_task_memory_state() if you 
> set tsk->mems_generation = task_cs(tsk)->mems_generation on 
> cpuset_attach() or update_nodemask().

In this way, we must use rcu_read_lock() to protect task's cs, and the performance
will slowdown though rcu read lock's spending is very small.

Thanks!
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
