Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2FE46B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 14:28:33 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 61-v6so10093898plz.20
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:28:33 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id bi1-v6si120296plb.609.2018.04.10.11.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 11:28:32 -0700 (PDT)
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
From: Yang Shi <yang.shi@linux.alibaba.com>
References: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180410090917.GZ21835@dhcp22.suse.cz> <20180410094047.GB2041@uranus.lan>
 <20180410104215.GB21835@dhcp22.suse.cz> <20180410110242.GC2041@uranus.lan>
 <20180410111001.GD21835@dhcp22.suse.cz> <20180410122804.GD2041@uranus.lan>
 <097488c7-ab18-367b-c435-7c26d149c619@linux.alibaba.com>
Message-ID: <8c19f1fb-7baf-fef3-032d-4e93cfc63932@linux.alibaba.com>
Date: Tue, 10 Apr 2018 11:28:13 -0700
MIME-Version: 1.0
In-Reply-To: <097488c7-ab18-367b-c435-7c26d149c619@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/10/18 9:21 AM, Yang Shi wrote:
>
>
> On 4/10/18 5:28 AM, Cyrill Gorcunov wrote:
>> On Tue, Apr 10, 2018 at 01:10:01PM +0200, Michal Hocko wrote:
>>>> Because do_brk does vma manipulations, for this reason it's
>>>> running under down_write_killable(&mm->mmap_sem). Or you
>>>> mean something else?
>>> Yes, all we need the new lock for is to get a consistent view on brk
>>> values. I am simply asking whether there is something fundamentally
>>> wrong by doing the update inside the new lock while keeping the 
>>> original
>>> mmap_sem locking in the brk path. That would allow us to drop the
>>> mmap_sem lock in the proc path when looking at brk values.
>> Michal gimme some time. I guessA  we might do so, but I need some
>> spare time to take more precise look into the code, hopefully today
>> evening. Also I've a suspicion that we've wracked check_data_rlimit
>> with this new lock in prctl. Need to verify it again.
>
> I see you guys points. We might be able to move the drop of mmap_sem 
> before setting mm->brk in sys_brk since mmap_sem should be used to 
> protect vma manipulation only, then protect the value modify with the 
> new arg_lock. Then we can eliminate mmap_sem stuff in prctl path, and 
> it also prevents from wrecking check_data_rlimit.
>
> At the first glance, it looks feasible to me. Will look into deeper 
> later.

A further look told me this might be *not* feasible.

It looks the new lock will not break check_data_rlimit since in my patch 
both start_brk and brk is protected by mmap_sem. The code flow might 
look like below:

CPU AA A A A A A A A A A A A A A A A A A A A A A A A A A A A  CPU B
--------A A A A A A A A A A A A A A A A A A A A A A  --------
prctlA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  sys_brk
 A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  down_write
check_data_rlimitA A A A A A A A A A  check_data_rlimit (need mm->start_brk)
 A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  set brk
down_writeA A A A A A A A A A A A A A A A A A A  up_write
set start_brk
set brk
up_write


If CPU A gets the mmap_sem first, it will set start_brk and brk, then 
CPU B will check with the new start_brk. And, prctl doesn't care if 
sys_brk is run before it since it gets the new start_brk and brk from 
parameter.

If we protect start_brk and brk with the new lock, sys_brk might get old 
start_brk, then sys_brk might break rlimit check silently, is that right?

So, it looks using new lock in prctl and keeping mmap_sem in brk path 
has race condition.

Thanks,
Yang

>
> Thanks,
> Yang
>
>
