Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B81BE6B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:17:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 2so2973171pft.4
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:17:03 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id b4si2968358pgq.427.2018.03.21.10.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 10:17:02 -0700 (PDT)
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
From: Yang Shi <yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321131449.GN23100@dhcp22.suse.cz>
 <8e0ded7b-4be4-fa25-f40c-d3116a6db4db@linux.alibaba.com>
Message-ID: <cf87ade4-5a5c-3919-0fc6-acc40e12659b@linux.alibaba.com>
Date: Wed, 21 Mar 2018 10:16:41 -0700
MIME-Version: 1.0
In-Reply-To: <8e0ded7b-4be4-fa25-f40c-d3116a6db4db@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/21/18 9:50 AM, Yang Shi wrote:
>
>
> On 3/21/18 6:14 AM, Michal Hocko wrote:
>> On Wed 21-03-18 05:31:19, Yang Shi wrote:
>>> When running some mmap/munmap scalability tests with large memory (i.e.
>>>> 300GB), the below hung task issue may happen occasionally.
>>> INFO: task ps:14018 blocked for more than 120 seconds.
>>>         Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>>   "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>>> message.
>>>   ps              D    0 14018      1 0x00000004
>>>    ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>>>    ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>>>    00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>>>   Call Trace:
>>>    [<ffffffff817154d0>] ? __schedule+0x250/0x730
>>>    [<ffffffff817159e6>] schedule+0x36/0x80
>>>    [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>>>    [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>>>    [<ffffffff81717db0>] down_read+0x20/0x40
>>>    [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>> Slightly off-topic:
>> Btw. this sucks as well. Do we really need to take mmap_sem here? Do any
>> of
>>     arg_start = mm->arg_start;
>>     arg_end = mm->arg_end;
>>     env_start = mm->env_start;
>>     env_end = mm->env_end;
>>
>> change after exec or while the pid is already visible in proc? If yes
>> maybe we can use a dedicated lock.

BTW, this is not the only place to acquire mmap_sem in 
proc_pid_cmdline_read(), it calls access_remote_vm() which need acquire 
mmap_sem too, so the mmap_sem scalability issue will be hit sooner or later.

Yang

>
> Actually, Alexey Dobriyan had the same comment when he reviewed my 
> very first patch (which changes down_read to down_read_killable at 
> that place).
>
> Those 4 values might be changed by prctl_set_mm() and 
> prctl_set_mm_map() concurrently. They used to use down_read() to 
> protect the change, but it looks not good enough to protect concurrent 
> writing. So, Mateusz Guzik's commit 
> ddf1d398e517e660207e2c807f76a90df543a217 ("prctl: take mmap sem for 
> writing to protect against others") change it to down_write().
>
> It seems mmap_sem can be replaced to a dedicated lock. How about 
> defining a rwlock in mm_struct to protect those data? I will come up 
> with a RFC patch for this.
>
> However, this dedicated lock just can work around this specific case. 
> I believe solving mmap_sem scalability issue aimed by the patch series 
> is still our consensus.
>
> Thanks,
> Yang
>
>
>
>
