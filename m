Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BFE56B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 12:20:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f19so2874758pfn.6
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:20:48 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 31-v6si3573938plz.467.2018.04.12.09.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 09:20:46 -0700 (PDT)
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180410090917.GZ21835@dhcp22.suse.cz> <20180410094047.GB2041@uranus.lan>
 <20180410104215.GB21835@dhcp22.suse.cz> <20180410110242.GC2041@uranus.lan>
 <20180410111001.GD21835@dhcp22.suse.cz> <20180410122804.GD2041@uranus.lan>
 <097488c7-ab18-367b-c435-7c26d149c619@linux.alibaba.com>
 <8c19f1fb-7baf-fef3-032d-4e93cfc63932@linux.alibaba.com>
 <20180412121801.GE23400@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <49c17035-1b8c-5fa3-9944-33467589d1f1@linux.alibaba.com>
Date: Thu, 12 Apr 2018 09:20:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180412121801.GE23400@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/12/18 5:18 AM, Michal Hocko wrote:
> On Tue 10-04-18 11:28:13, Yang Shi wrote:
>>
>> On 4/10/18 9:21 AM, Yang Shi wrote:
>>>
>>> On 4/10/18 5:28 AM, Cyrill Gorcunov wrote:
>>>> On Tue, Apr 10, 2018 at 01:10:01PM +0200, Michal Hocko wrote:
>>>>>> Because do_brk does vma manipulations, for this reason it's
>>>>>> running under down_write_killable(&mm->mmap_sem). Or you
>>>>>> mean something else?
>>>>> Yes, all we need the new lock for is to get a consistent view on brk
>>>>> values. I am simply asking whether there is something fundamentally
>>>>> wrong by doing the update inside the new lock while keeping the
>>>>> original
>>>>> mmap_sem locking in the brk path. That would allow us to drop the
>>>>> mmap_sem lock in the proc path when looking at brk values.
>>>> Michal gimme some time. I guessA  we might do so, but I need some
>>>> spare time to take more precise look into the code, hopefully today
>>>> evening. Also I've a suspicion that we've wracked check_data_rlimit
>>>> with this new lock in prctl. Need to verify it again.
>>> I see you guys points. We might be able to move the drop of mmap_sem
>>> before setting mm->brk in sys_brk since mmap_sem should be used to
>>> protect vma manipulation only, then protect the value modify with the
>>> new arg_lock. Then we can eliminate mmap_sem stuff in prctl path, and it
>>> also prevents from wrecking check_data_rlimit.
>>>
>>> At the first glance, it looks feasible to me. Will look into deeper
>>> later.
>> A further look told me this might be *not* feasible.
>>
>> It looks the new lock will not break check_data_rlimit since in my patch
>> both start_brk and brk is protected by mmap_sem. The code flow might look
>> like below:
>>
>> CPU AA A A A A A A A A A A A A A A A A A A A A A A A A A A A  CPU B
>> --------A A A A A A A A A A A A A A A A A A A A A A  --------
>> prctlA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  sys_brk
>>  A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  down_write
>> check_data_rlimitA A A A A A A A A A  check_data_rlimit (need mm->start_brk)
>>  A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  set brk
>> down_writeA A A A A A A A A A A A A A A A A A A  up_write
>> set start_brk
>> set brk
>> up_write
>>
>>
>> If CPU A gets the mmap_sem first, it will set start_brk and brk, then CPU B
>> will check with the new start_brk. And, prctl doesn't care if sys_brk is run
>> before it since it gets the new start_brk and brk from parameter.
>>
>> If we protect start_brk and brk with the new lock, sys_brk might get old
>> start_brk, then sys_brk might break rlimit check silently, is that right?
>>
>> So, it looks using new lock in prctl and keeping mmap_sem in brk path has
>> race condition.
> OK, I've admittedly didn't give it too much time to think about. Maybe
> we do something clever to remove the race but can we start at least by
> reducing the write lock to read on prctl side and use the dedicated
> spinlock for updating values? That should close the above race AFAICS
> and the read lock would be much more friendly to other VM operations.

Yes, is sounds feasible. We just need care about prctl is run before 
sys_brk. So, you mean:

down_read
spin_lock
update all the values
spin_unlock
up_read


>
