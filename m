Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id C81376B002C
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 06:29:14 -0500 (EST)
Received: by bkbzs2 with SMTP id zs2so6042282bkb.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 03:29:12 -0800 (PST)
Message-ID: <4F2FB986.8040809@openvz.org>
Date: Mon, 06 Feb 2012 15:29:10 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC V1] mm: convert rcu_read_lock() to srcu_read_lock(),
 thus allowing to sleep in callbacks
References: <y> <4f2eae5e.e951b40a.3aa3.5ddc@mx.google.com> <4F2EE64F.6010900@openvz.org> <4F2F9926.3000708@mellanox.com>
In-Reply-To: <4F2F9926.3000708@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sagig <sagig@mellanox.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, "gleb@redhat.com" <gleb@redhat.com>, Oren Duer <oren@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

sagig wrote:
> On 2/5/2012 10:27 PM, Konstantin Khlebnikov wrote:
>> sagig@mellanox.com wrote:
>>> Now that anon_vma lock and i_mmap_mutex are both sleepable mutex, it
>>> is possible to schedule inside invalidation callbacks
>>> (such as invalidate_page, invalidate_range_start/end and change_pte) .
>>> This is essential for a scheduling HW sync in RDMA drivers which
>>> apply on demand paging methods.
>>>
>>> Signed-off-by: sagi grimberg<sagig@mellanox.co.il>
>>
>> Ok, this is better, but it still does not work =)
>> Nobody synchronize with this srcu. There at least two candidates:
>> mmu_notifier_release() and mmu_notifier_unregister().
>> They call synchronize_rcu(), you must replace it with synchronize_srcu().
>>
>
> Yes, I understand - will fix.
>
>>> ---
>>>    changes from V0:
>>>    1. srcu_struct should be shared and not allocated in each callback
>>> - removed from callbacks
>>>    2. added srcu_struct under mmu_notifier_mm
>>>    3. init_srcu_struct when creating mmu_notifier_mm
>>>    4. srcu_cleanup when destroying mmu_notifier_mm
>>>
>>
>>> @@ -204,6 +208,8 @@ static int do_mmu_notifier_register(struct
>>> mmu_notifier *mn,
>>>
>>>        if (!mm_has_notifiers(mm)) {
>>>            INIT_HLIST_HEAD(&mmu_notifier_mm->list);
>>> +        if (init_srcu_struct(&mmu_notifier_mm->srcu))
>>> +            goto out_cleanup;
>>
>> move it upper, out of mm->mmap_sem lock. and fix error path.
>>
>
> Yes, I see that init_srcu_struct is using GFP_KERNEL allocations.
> But what if do_mmu_notifier_register was called from
> __mmu_notifier_register (where mmap_sem is held)? won't I end up with
> the same violation?

In this case, it is not strictly necessary, but allocation outside of locks
is usually better than under lock.

>
> Another question,
> Just to understand - I should move only the init_srcu_struct() call out
> of mmap_sem (will require checking !mm_has_notifiers(mm) twice)? or the
> entire mmu_notifier_mm initialization?

this code should do this steps:
* allocate new struct mmu_notifiler_mm with all sub-structures, like srcu.
* take locks
* try to install new mmu-notifier
* install our notifier into mmu-notifier
* release locks
* free new mmu-notifier and all sub-structures if it unused

This is very commonly used pattern, sometimes it has fast-paths, sometimes not.
Looks like in this case, there are usually only one notifier per-mm,
so newly allocated mmu-notifier unlikely to be released.

>
>>
>>>            spin_lock_init(&mmu_notifier_mm->lock);
>>>            mm->mmu_notifier_mm = mmu_notifier_mm;
>>>            mmu_notifier_mm = NULL;
>>> @@ -266,6 +272,7 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_register);
>>>    void __mmu_notifier_mm_destroy(struct mm_struct *mm)
>>>    {
>>>        BUG_ON(!hlist_empty(&mm->mmu_notifier_mm->list));
>>> +    cleanup_srcu_struct(&mm->mmu_notifier_mm->srcu);
>>>        kfree(mm->mmu_notifier_mm);
>>>        mm->mmu_notifier_mm = LIST_POISON1; /* debug */
>>>    }
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
