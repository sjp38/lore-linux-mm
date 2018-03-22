Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB35C6B000E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:06:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n15so4834320pff.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:06:23 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id z1-v6si1444433plb.101.2018.03.22.09.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 09:06:22 -0700 (PDT)
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321131449.GN23100@dhcp22.suse.cz>
 <8e0ded7b-4be4-fa25-f40c-d3116a6db4db@linux.alibaba.com>
 <cf87ade4-5a5c-3919-0fc6-acc40e12659b@linux.alibaba.com>
 <20180321212355.GR23100@dhcp22.suse.cz>
 <952dcae2-a73e-0726-3cc5-9b6a63b417b7@linux.alibaba.com>
 <20180322091008.GZ23100@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <8b4407dd-78f6-2f6f-3f45-ddb8a2d805c8@linux.alibaba.com>
Date: Thu, 22 Mar 2018 09:06:14 -0700
MIME-Version: 1.0
In-Reply-To: <20180322091008.GZ23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/22/18 2:10 AM, Michal Hocko wrote:
> On Wed 21-03-18 15:36:12, Yang Shi wrote:
>>
>> On 3/21/18 2:23 PM, Michal Hocko wrote:
>>> On Wed 21-03-18 10:16:41, Yang Shi wrote:
>>>> On 3/21/18 9:50 AM, Yang Shi wrote:
>>>>> On 3/21/18 6:14 AM, Michal Hocko wrote:
>>>>>> On Wed 21-03-18 05:31:19, Yang Shi wrote:
>>>>>>> When running some mmap/munmap scalability tests with large memory (i.e.
>>>>>>>> 300GB), the below hung task issue may happen occasionally.
>>>>>>> INFO: task ps:14018 blocked for more than 120 seconds.
>>>>>>>           Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>>>>>>     "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>>>>>>> message.
>>>>>>>     ps              D    0 14018      1 0x00000004
>>>>>>>      ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>>>>>>>      ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>>>>>>>      00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>>>>>>>     Call Trace:
>>>>>>>      [<ffffffff817154d0>] ? __schedule+0x250/0x730
>>>>>>>      [<ffffffff817159e6>] schedule+0x36/0x80
>>>>>>>      [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>>>>>>>      [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>>>>>>>      [<ffffffff81717db0>] down_read+0x20/0x40
>>>>>>>      [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>>>>>> Slightly off-topic:
>>>>>> Btw. this sucks as well. Do we really need to take mmap_sem here? Do any
>>>>>> of
>>>>>>       arg_start = mm->arg_start;
>>>>>>       arg_end = mm->arg_end;
>>>>>>       env_start = mm->env_start;
>>>>>>       env_end = mm->env_end;
>>>>>>
>>>>>> change after exec or while the pid is already visible in proc? If yes
>>>>>> maybe we can use a dedicated lock.
>>>> BTW, this is not the only place to acquire mmap_sem in
>>>> proc_pid_cmdline_read(), it calls access_remote_vm() which need acquire
>>>> mmap_sem too, so the mmap_sem scalability issue will be hit sooner or later.
>>> Ohh, absolutely. mmap_sem is unfortunatelly abused and it would be great
>>> to remove that. munmap should perform much better. How to do that safely
>> Yes, agree. We are on the same page.
>>
>>> is a different question. I am not yet convinced that tearing down a vma
>>> in batches is safe. The vast majority of time is spent on tearing down
>> You can try my patches. I did full LTP test and running multiple kernel
>> build in parallel. It survives.
> Which doesn't really mean anything. Those tests are likely to not hit
> corner cases where an application silently depends on the mmap locking
> and unmap atomicity.

They definitely can't cover all corner cases. But, they do give us 
somehow confidence that the most part works. The mmap stress tests in 
LTP did discover some race conditions when I tried different approaches.

>   
>>> pages and that is quite easy to move out of the write lock. That would
>>> be an improvement already and it should be risk safe. If even that is
>>> not sufficient then using range locking should help a lot. There
>>> shouldn't be really any other address space operations within the range
>>> most of the time so this would be basically non-contended access.
>> It might depend on how the range is defined. Too big range may lead to
>> surprisingly more contention, but too small range may bring in too much
>> lock/unlock operations.
> The full vma will have to be range locked. So there is nothing small or large.

It sounds not helpful to a single large vma case since just one range 
lock for the vma, it sounds equal to mmap_sem.

Yang
