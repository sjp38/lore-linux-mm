Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0BEA6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 05:31:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so45689698pfg.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 02:31:45 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v88si11603027pfj.110.2016.07.28.02.31.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jul 2016 02:31:45 -0700 (PDT)
Message-ID: <5799C612.1050502@huawei.com>
Date: Thu, 28 Jul 2016 16:45:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] can we use vmalloc to alloc thread stack if compaction
 failed
References: <5799AF6A.2070507@huawei.com> <20160728072028.GC31860@dhcp22.suse.cz> <5799B741.8090506@huawei.com> <20160728075856.GE31860@dhcp22.suse.cz>
In-Reply-To: <20160728075856.GE31860@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Yisheng Xie <xieyisheng1@huawei.com>

On 2016/7/28 15:58, Michal Hocko wrote:

> On Thu 28-07-16 15:41:53, Xishi Qiu wrote:
>> On 2016/7/28 15:20, Michal Hocko wrote:
>>
>>> On Thu 28-07-16 15:08:26, Xishi Qiu wrote:
>>>> Usually THREAD_SIZE_ORDER is 2, it means we need to alloc 16kb continuous
>>>> physical memory during fork a new process.
>>>>
>>>> If the system's memory is very small, especially the smart phone, maybe there
>>>> is only 1G memory. So the free memory is very small and compaction is not
>>>> always success in slowpath(__alloc_pages_slowpath), then alloc thread stack
>>>> may be failed for memory fragment.
>>>
>>> Well, with the current implementation of the page allocator those
>>> requests will not fail in most cases. The oom killer would be invoked in
>>> order to free up some memory.
>>>
>>
>> Hi Michal,
>>
>> Yes, it success in most cases, but I did have seen this problem in some
>> stress-test.
>>
>> DMA free:470628kB, but alloc 2 order block failed during fork a new process.
>> There are so many memory fragments and the large block may be soon taken by
>> others after compact because of stress-test.
>>
>> --- dmesg messages ---
>> 07-13 08:41:51.341 <4>[309805.658142s][pid:1361,cpu5,sManagerService]sManagerService: page allocation failure: order:2, mode:0x2000d1
> 
> Yes but this is __GFP_DMA allocation. I guess you have already reported
> this failure and you've been told that this is quite unexpected for the
> kernel stack allocation. It is your out-of-tree patch which just makes
> things worse because DMA restricted allocations are considered "lowmem"
> and so they do not invoke OOM killer and do not retry like regular
> GFP_KERNEL allocations.

Hi Michal,

Yes, we add GFP_DMA, but I don't think this is the key for the problem.

If we do oom-killer, maybe we will get a large block later, but there
is enough free memory before oom(although most of them are fragments).

I wonder if we can alloc success without kill any process in this situation.
Maybe use vmalloc is a good way, but I don't know the influence.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
