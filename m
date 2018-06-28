Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25C8D6B026F
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 15:10:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o7-v6so2737586pgc.23
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:10:33 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id 196-v6si6638273pgg.588.2018.06.28.12.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 12:10:31 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
 <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
 <e54e298d-ef86-19a7-6f6b-07776f9a43e2@linux.alibaba.com>
 <20180627072432.GC32348@dhcp22.suse.cz>
 <a52f0585-ebec-d098-2775-f55bde3519a4@linux.alibaba.com>
 <20180628115101.GE32348@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2ecdb667-f4de-673d-6a5f-ee50df505d0c@linux.alibaba.com>
Date: Thu, 28 Jun 2018 12:10:10 -0700
MIME-Version: 1.0
In-Reply-To: <20180628115101.GE32348@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Nadav Amit <nadav.amit@gmail.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org



On 6/28/18 4:51 AM, Michal Hocko wrote:
> On Wed 27-06-18 10:23:39, Yang Shi wrote:
>>
>> On 6/27/18 12:24 AM, Michal Hocko wrote:
>>> On Tue 26-06-18 18:03:34, Yang Shi wrote:
>>>> On 6/26/18 12:43 AM, Peter Zijlstra wrote:
>>>>> On Mon, Jun 25, 2018 at 05:06:23PM -0700, Yang Shi wrote:
>>>>>> By looking this deeper, we may not be able to cover all the unmapping range
>>>>>> for VM_DEAD, for example, if the start addr is in the middle of a vma. We
>>>>>> can't set VM_DEAD to that vma since that would trigger SIGSEGV for still
>>>>>> mapped area.
>>>>>>
>>>>>> splitting can't be done with read mmap_sem held, so maybe just set VM_DEAD
>>>>>> to non-overlapped vmas. Access to overlapped vmas (first and last) will
>>>>>> still have undefined behavior.
>>>>> Acquire mmap_sem for writing, split, mark VM_DEAD, drop mmap_sem. Acquire
>>>>> mmap_sem for reading, madv_free drop mmap_sem. Acquire mmap_sem for
>>>>> writing, free everything left, drop mmap_sem.
>>>>>
>>>>> ?
>>>>>
>>>>> Sure, you acquire the lock 3 times, but both write instances should be
>>>>> 'short', and I suppose you can do a demote between 1 and 2 if you care.
>>>> Thanks, Peter. Yes, by looking the code and trying two different approaches,
>>>> it looks this approach is the most straight-forward one.
>>> Yes, you just have to be careful about the max vma count limit.
>> Yes, we should just need copy what do_munmap does as below:
>>
>> if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
>>  A A A  A A A  A A A  return -ENOMEM;
>>
>> If the mas map count limit has been reached, it will return failure before
>> zapping mappings.
> Yeah, but as soon as you drop the lock and retake it, somebody might
> have changed the adddress space and we might get inconsistency.
>
> So I am wondering whether we really need upgrade_read (to promote read
> to write lock) and do the
> 	down_write
> 	split & set up VM_DEAD
> 	downgrade_write
> 	unmap
> 	upgrade_read
> 	zap ptes
> 	up_write

I'm supposed address space changing just can be done by mmap, mremap, 
mprotect. If so, we may utilize the new VM_DEAD flag. If the VM_DEAD 
flag is set for the vma, just return failure since it is being unmapped.

Does it sounds reasonable?

Thanks,
Yang

>
> looks terrible, no question about that, but we won't drop the mmap sem
> at any time.
