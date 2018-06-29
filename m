Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4877C6B0269
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 12:50:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y26-v6so4758787pfn.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:50:20 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id m62-v6si10579806pfb.127.2018.06.29.09.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 09:50:19 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
 <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
 <e54e298d-ef86-19a7-6f6b-07776f9a43e2@linux.alibaba.com>
 <20180627072432.GC32348@dhcp22.suse.cz>
 <a52f0585-ebec-d098-2775-f55bde3519a4@linux.alibaba.com>
 <20180628115101.GE32348@dhcp22.suse.cz>
 <2ecdb667-f4de-673d-6a5f-ee50df505d0c@linux.alibaba.com>
 <b7b8ed15-183b-9afe-8e72-d2751672e24a@linux.alibaba.com>
 <20180629113954.GB5963@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7827f941-aeb3-a44a-0711-bfc15ec1d912@linux.alibaba.com>
Date: Fri, 29 Jun 2018 09:50:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180629113954.GB5963@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Nadav Amit <nadav.amit@gmail.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org



On 6/29/18 4:39 AM, Michal Hocko wrote:
> On Thu 28-06-18 17:59:25, Yang Shi wrote:
>>
>> On 6/28/18 12:10 PM, Yang Shi wrote:
>>>
>>> On 6/28/18 4:51 AM, Michal Hocko wrote:
>>>> On Wed 27-06-18 10:23:39, Yang Shi wrote:
>>>>> On 6/27/18 12:24 AM, Michal Hocko wrote:
>>>>>> On Tue 26-06-18 18:03:34, Yang Shi wrote:
>>>>>>> On 6/26/18 12:43 AM, Peter Zijlstra wrote:
>>>>>>>> On Mon, Jun 25, 2018 at 05:06:23PM -0700, Yang Shi wrote:
>>>>>>>>> By looking this deeper, we may not be able to
>>>>>>>>> cover all the unmapping range
>>>>>>>>> for VM_DEAD, for example, if the start addr is
>>>>>>>>> in the middle of a vma. We
>>>>>>>>> can't set VM_DEAD to that vma since that would
>>>>>>>>> trigger SIGSEGV for still
>>>>>>>>> mapped area.
>>>>>>>>>
>>>>>>>>> splitting can't be done with read mmap_sem held,
>>>>>>>>> so maybe just set VM_DEAD
>>>>>>>>> to non-overlapped vmas. Access to overlapped
>>>>>>>>> vmas (first and last) will
>>>>>>>>> still have undefined behavior.
>>>>>>>> Acquire mmap_sem for writing, split, mark VM_DEAD,
>>>>>>>> drop mmap_sem. Acquire
>>>>>>>> mmap_sem for reading, madv_free drop mmap_sem. Acquire mmap_sem for
>>>>>>>> writing, free everything left, drop mmap_sem.
>>>>>>>>
>>>>>>>> ?
>>>>>>>>
>>>>>>>> Sure, you acquire the lock 3 times, but both write
>>>>>>>> instances should be
>>>>>>>> 'short', and I suppose you can do a demote between 1
>>>>>>>> and 2 if you care.
>>>>>>> Thanks, Peter. Yes, by looking the code and trying two
>>>>>>> different approaches,
>>>>>>> it looks this approach is the most straight-forward one.
>>>>>> Yes, you just have to be careful about the max vma count limit.
>>>>> Yes, we should just need copy what do_munmap does as below:
>>>>>
>>>>> if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
>>>>>  A A A A  A A A  A A A  return -ENOMEM;
>>>>>
>>>>> If the mas map count limit has been reached, it will return
>>>>> failure before
>>>>> zapping mappings.
>>>> Yeah, but as soon as you drop the lock and retake it, somebody might
>>>> have changed the adddress space and we might get inconsistency.
>>>>
>>>> So I am wondering whether we really need upgrade_read (to promote read
>>>> to write lock) and do the
>>>>  A A A A down_write
>>>>  A A A A split & set up VM_DEAD
>>>>  A A A A downgrade_write
>>>>  A A A A unmap
>>>>  A A A A upgrade_read
>>>>  A A A A zap ptes
>>>>  A A A A up_write
>> Promoting to write lock may be a trouble. There might be other users in the
>> critical section with read lock, we have to wait them to finish.
> Yes. Is that a problem though?

Not a problem, but just not sure how complicated it would be. 
Considering all the lock debug/lockdep stuff.

And, the behavior smells like rcu.

>   
>>> I'm supposed address space changing just can be done by mmap, mremap,
>>> mprotect. If so, we may utilize the new VM_DEAD flag. If the VM_DEAD
>>> flag is set for the vma, just return failure since it is being unmapped.
>>>
>>> Does it sounds reasonable?
>> It looks we just need care about MAP_FIXED (mmap) and MREMAP_FIXED (mremap),
>> right?
>>
>> How about letting them return -EBUSY or -EAGAIN to notify the application?
> Well, non of those is documented to return EBUSY and EAGAIN already has
> a meaning for locked memory.
>
>> This changes the behavior a little bit, MAP_FIXED and mremap may fail if
>> they fail the race with munmap (if the mapping is larger than 1GB). I'm not
>> sure if any multi-threaded application uses MAP_FIXED and MREMAP_FIXED very
>> heavily which may run into the race condition. I guess it should be rare to
>> meet all the conditions to trigger the race.
>>
>> The programmer should be very cautious about MAP_FIXED.MREMAP_FIXED since
>> they may corrupt its own address space as the man page noted.
> Well, I suspect you are overcomplicating this a bit. This should be
> really straightforward thing - well except for VM_DEAD which is quite
> tricky already. We should rather not spread this trickyness outside of
> the #PF path. And I would even try hard to start that part simple to see
> whether it actually matters. Relying on races between threads without
> any locking is quite questionable already. Nobody has pointed to a sane
> usecase so far.

I agree to keep it as simple as possible then see if it matters or not. 
So, in v3 I will just touch the page fault path.
