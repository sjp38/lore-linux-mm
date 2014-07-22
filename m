Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC1B6B0037
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 06:06:53 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so71885wiv.13
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 03:06:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si26460626wib.78.2014.07.22.03.06.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 03:06:44 -0700 (PDT)
Message-ID: <53CE37A6.2060000@suse.cz>
Date: Tue, 22 Jul 2014 12:06:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com> <53C8FAA6.9050908@oracle.com> <alpine.LSU.2.11.1407191628450.24073@eggly.anvils> <53CDD961.1080006@oracle.com> <alpine.LSU.2.11.1407220049140.1980@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407220049140.1980@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>

On 07/22/2014 10:07 AM, Hugh Dickins wrote:
> On Mon, 21 Jul 2014, Sasha Levin wrote:
>> On 07/19/2014 07:44 PM, Hugh Dickins wrote:
>>>> Otherwise, I've been unable to reproduce the shmem_fallocate hang.
>>> Great.  Andrew, I think we can say that it's now safe to send
>>> 1/2 shmem: fix faulting into a hole, not taking i_mutex
>>> 2/2 shmem: fix splicing from a hole while it's punched
>>> on to Linus whenever suits you.
>>>
>>> (You have some other patches in the mainline-later section of the
>>> mmotm/series file: they're okay too, but not in doubt as these two were.)
>>
>> I think we may need to hold off on sending them...
>>
>> It seems that this code in shmem_fault():
>>
>> 	/*
>> 	 * shmem_falloc_waitq points into the shmem_fallocate()
>> 	 * stack of the hole-punching task: shmem_falloc_waitq
>> 	 * is usually invalid by the time we reach here, but
>> 	 * finish_wait() does not dereference it in that case;
>> 	 * though i_lock needed lest racing with wake_up_all().
>> 	 */
>> 	spin_lock(&inode->i_lock);
>> 	finish_wait(shmem_falloc_waitq, &shmem_fault_wait);
>> 	spin_unlock(&inode->i_lock);
>>
>> Is problematic. I'm not sure what changed, but it seems to be causing everything
>> from NULL ptr derefs:
>>
>> [  169.922536] BUG: unable to handle kernel NULL pointer dereference at 0000000000000631
>>
>> To memory corruptions:
>>
>> [ 1031.264226] BUG: spinlock bad magic on CPU#1, trinity-c99/25740
>>
>> And hangs:
>>
>> [  212.010020] INFO: rcu_preempt detected stalls on CPUs/tasks:
>
> Ugh.
>
> I'm so tired of this, I'm flailing around here, and could use some help.
>
> But there is one easy change which might do it: please would you try
> changing the TASK_KILLABLE a few lines above to TASK_UNINTERRUPTIBLE.

Hello,

I have discussed it with Michal Hocko, as he was recently fighting with 
wait queues, and indeed he found a possible race quickly. And yes, it's 
related to the TASK_KILLABLE state.

The problem would manifest when the waiting faulting task is woken by a 
signal (thanks to the TASK_KILLABLE), which will change its state to 
TASK_WAKING. Later it might become TASK_RUNNING again.
Either value means that a wake_up_all() from the punching task will skip 
the faulter's shmem_fault_wait when clearing up the wait queue (see the 
p->state & state check in try_to_wake_up()).

Then in the faulter's finish_wait(), &wait->task_list will not be empty, 
so it will try to access the wait queue, which might be already already 
gone from the puncher's stack...

So if this is true, the change to TASK_UNINTERRUPTIBLE will avoid the 
problem, but it would be nicer to keep the KILLABLE state.
I think it could be done by testing if the wait queue still exists and 
is the same, before attempting finish wait. If it doesn't exist, that 
means the faulter can skip finish_wait altogether because it must be 
already TASK_RUNNING.

shmem_falloc = inode->i_private;
if (shmem_falloc && shmem_falloc->waitq == shmem_falloc_waitq)
	finish_wait(shmem_falloc_waitq, &shmem_fault_wait);

It might still be theoretically possible that although it has the same 
address, it's not the same wait queue, but that doesn't hurt 
correctness. I might be uselessly locking some other waitq's lock, but 
the inode->i_lock still protects me from other faulters that are in the 
same situation. The puncher is already gone.

However it's quite ugly and if there is some wait queue debugging mode 
(I hadn't checked) that e.g. checks if wait queues and wait objects are 
empty before destruction, it wouldn't like this at all...


> I noticed when deciding on the i_lock'ing there, that a lot of the
> difficulty in races between the two ends, came from allowing KILLABLE
> at the faulting end.  Which was a nice courtesy, but one I'll gladly
> give up on now, if it is responsible for these troubles.
>
> Please give it a try, I don't know what else to suggest.  And I've
> no idea why the problem should emerge only now.  If this change
> does appear to fix it, please go back and forth with and without,
> to gather confidence that the problem is still reproducible without
> the fix.  If fix it turns out to be - touch wood.
>
> Thanks,
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
