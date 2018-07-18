Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 641196B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 17:21:26 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k204-v6so130404ite.1
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:21:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k22-v6si2895313ioj.97.2018.07.18.14.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 14:21:24 -0700 (PDT)
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
 <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
Date: Thu, 19 Jul 2018 06:21:03 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Sigh...

Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

because David is not aware what is wrong.

On 2018/07/19 5:22, David Rientjes wrote:
> On Wed, 18 Jul 2018, Tetsuo Handa wrote:
> 
>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>> --- a/mm/mmap.c
>>> +++ b/mm/mmap.c
>>> @@ -3059,25 +3059,28 @@ void exit_mmap(struct mm_struct *mm)
>>>  	if (unlikely(mm_is_oom_victim(mm))) {
>>>  		/*
>>>  		 * Manually reap the mm to free as much memory as possible.
>>> -		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
>>> -		 * this mm from further consideration.  Taking mm->mmap_sem for
>>> -		 * write after setting MMF_OOM_SKIP will guarantee that the oom
>>> -		 * reaper will not run on this mm again after mmap_sem is
>>> -		 * dropped.
>>> -		 *
>>>  		 * Nothing can be holding mm->mmap_sem here and the above call
>>>  		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
>>>  		 * __oom_reap_task_mm() will not block.
>>> -		 *
>>> -		 * This needs to be done before calling munlock_vma_pages_all(),
>>> -		 * which clears VM_LOCKED, otherwise the oom reaper cannot
>>> -		 * reliably test it.
>>>  		 */
>>>  		mutex_lock(&oom_lock);
>>>  		__oom_reap_task_mm(mm);
>>>  		mutex_unlock(&oom_lock);
>>>  
>>> -		set_bit(MMF_OOM_SKIP, &mm->flags);
>>> +		/*
>>> +		 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
>>> +		 * This needs to be done before calling munlock_vma_pages_all(),
>>> +		 * which clears VM_LOCKED, otherwise the oom reaper cannot
>>> +		 * reliably test for it.  If the oom reaper races with
>>> +		 * munlock_vma_pages_all(), this can result in a kernel oops if
>>> +		 * a pmd is zapped, for example, after follow_page_mask() has
>>> +		 * checked pmd_none().
>>> +		 *
>>> +		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
>>> +		 * guarantee that the oom reaper will not run on this mm again
>>> +		 * after mmap_sem is dropped.
>>> +		 */
>>> +		set_bit(MMF_UNSTABLE, &mm->flags);
>>
>> Since MMF_UNSTABLE is set by __oom_reap_task_mm() from exit_mmap() before start reaping
>> (because the purpose of MMF_UNSTABLE is to "tell all users of get_user/copy_from_user
>> etc... that the content is no longer stable"), it cannot be used for a flag for indicating
>> that the OOM reaper can't work on the mm anymore.
>>
> 
> Why?  It should be able to be set by exit_mmap() since nothing else should 
> be accessing this mm in the first place.  There is no reason to wait for 
> the oom reaper and the following down_write();up_write(); cycle will 
> guarantee it is not operating on the mm before munlocking.
> 

It does not make sense to call set_bit(MMF_UNSTABLE, &mm->flags) again after returning from
__oom_reap_task_mm() because MMF_UNSTABLE is _aready_ set in the beginning of __oom_reap_task_mm().

void __oom_reap_task_mm(struct mm_struct *mm)
{
        struct vm_area_struct *vma;

        /*
         * Tell all users of get_user/copy_from_user etc... that the content
         * is no longer stable. No barriers really needed because unmapping
         * should imply barriers already and the reader would hit a page fault
         * if it stumbled over a reaped memory. If MMF_UNSTABLE is already set,
         * reaping as already occurred so nothing left to do.
         */
        if (test_and_set_bit(MMF_UNSTABLE, &mm->flags))
                return;
(...snipped...)
}

void exit_mmap(struct mm_struct *mm)
{
        struct mmu_gather tlb;
        struct vm_area_struct *vma;
        unsigned long nr_accounted = 0;

        /* mm's last user has gone, and its about to be pulled down */
        mmu_notifier_release(mm);

        if (unlikely(mm_is_oom_victim(mm))) {
                /*
                 * Manually reap the mm to free as much memory as possible.
                 * Nothing can be holding mm->mmap_sem here and the above call
                 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
                 * __oom_reap_task_mm() will not block.
                 */
                __oom_reap_task_mm(mm);

                /*
                 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
                 * This needs to be done before calling munlock_vma_pages_all(),
                 * which clears VM_LOCKED, otherwise the oom reaper cannot
                 * reliably test for it.  If the oom reaper races with
                 * munlock_vma_pages_all(), this can result in a kernel oops if
                 * a pmd is zapped, for example, after follow_page_mask() has
                 * checked pmd_none().
                 *
                 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
                 * guarantee that the oom reaper will not run on this mm again
                 * after mmap_sem is dropped.
                 */
                set_bit(MMF_UNSTABLE, &mm->flags);
                down_write(&mm->mmap_sem);
                up_write(&mm->mmap_sem);
        }
(...snipped...)
}

>> If the oom_lock serialization is removed, the OOM reaper will give up after (by default)
>> 1 second even if current thread is immediately after set_bit(MMF_UNSTABLE, &mm->flags) from
>> __oom_reap_task_mm() from exit_mmap(). Thus, this patch and the other patch which removes
>> oom_lock serialization should be dropped.
>>
> 
> No, it shouldn't, lol.  The oom reaper may give up because we have entered 
> __oom_reap_task_mm() by way of exit_mmap(), there's no other purpose for 
> it acting on the mm.  This is very different from giving up by setting 
> MMF_OOM_SKIP, which it will wait for oom_free_timeout_ms to do unless the 
> thread can make forward progress here in exit_mmap().

Let's call "A" as a thread doing exit_mmap(), and "B" as the OOM reaper kernel thread.

(1) "A" finds that unlikely(mm_is_oom_victim(mm)) == true.
(2) "B" finds that test_bit(MMF_OOM_SKIP, &mm->flags) in oom_reap_task() is false.
(3) "B" finds that !test_bit(MMF_UNSTABLE, &mm->flags) in oom_reap_task() is true.
(4) "B" enters into oom_reap_task_mm(tsk, mm).
(5) "B" finds that !down_read_trylock(&mm->mmap_sem) is false.
(6) "B" finds that mm_has_blockable_invalidate_notifiers(mm) is false.
(7) "B" finds that test_bit(MMF_UNSTABLE, &mm->flags) is false.
(8) "B" enters into __oom_reap_task_mm(mm).
(9) "A" finds that test_and_set_bit(MMF_UNSTABLE, &mm->flags) is false.
(10) "A" is preempted by somebody else.
(11) "B" finds that test_and_set_bit(MMF_UNSTABLE, &mm->flags) is true.
(12) "B" leaves __oom_reap_task_mm(mm).
(13) "B" leaves oom_reap_task_mm().
(14) "B" finds that time_after_eq(jiffies, mm->oom_free_expire) became true.
(15) "B" finds that !test_bit(MMF_OOM_SKIP, &mm->flags) is true.
(16) "B" calls set_bit(MMF_OOM_SKIP, &mm->flags).
(17) "B" finds that test_bit(MMF_OOM_SKIP, &mm->flags) is true.
(18) select_bad_process() finds that MMF_OOM_SKIP is already set.
(19) out_of_memory() kills a new OOM victim.
(20) "A" resumes execution and start reclaiming memory.

because oom_lock serialization was already removed.

> 
>>>  		down_write(&mm->mmap_sem);
>>>  		up_write(&mm->mmap_sem);
>>>  	}
>>
>>> @@ -637,25 +649,57 @@ static int oom_reaper(void *unused)
>>>  	return 0;
>>>  }
>>>  
>>> +/*
>>> + * Millisecs to wait for an oom mm to free memory before selecting another
>>> + * victim.
>>> + */
>>> +static u64 oom_free_timeout_ms = 1000;
>>>  static void wake_oom_reaper(struct task_struct *tsk)
>>>  {
>>> -	/* tsk is already queued? */
>>> -	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
>>> +	/*
>>> +	 * Set the reap timeout; if it's already set, the mm is enqueued and
>>> +	 * this tsk can be ignored.
>>> +	 */
>>> +	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL,
>>> +			jiffies + msecs_to_jiffies(oom_free_timeout_ms)))
>>>  		return;
>>
>> "expire" must not be 0 in order to avoid double list_add(). See
>> https://lore.kernel.org/lkml/201807130620.w6D6KiAJ093010@www262.sakura.ne.jp/T/#u .
>>
> 
> We should not allow oom_free_timeout_ms to be 0 for sure, I assume 1000 is 
> the sane minimum since we need to allow time for some memory freeing and 
> this will not be radically different from what existed before the patch 
> for the various backoffs.  Or maybe you meant something else for "expire" 
> here?
> 

I'm saying that jiffies + msecs_to_jiffies(oom_free_timeout_ms) == 0 will make
tsk->signal->oom_mm->oom_free_expire == 0 and the list will be corrupted by
allowing cmpxchg(&tsk->signal->oom_mm->oom_free_expire) to become true for twice.
