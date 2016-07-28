Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6C86B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 04:01:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so41956478pfx.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:01:44 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id zd7si11152464pab.115.2016.07.28.01.01.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jul 2016 01:01:43 -0700 (PDT)
Message-ID: <5799B948.6080308@huawei.com>
Date: Thu, 28 Jul 2016 15:50:32 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [Question]page allocation failure: order:2, mode:0x2000d1
References: <b3127e70-4fca-9e11-62e5-7a8f3da9d044@huawei.com> <5d0d3274-a893-8453-fb3d-87981dd38cfa@suse.cz> <578E2FBF.2080405@huawei.com> <2c8255c9-e449-d245-8554-0ed258d594ed@suse.cz> <7d9da183-38bf-96ef-a30c-db8b7dc9aafb@huawei.com> <20160720074723.GA11256@dhcp22.suse.cz>
In-Reply-To: <20160720074723.GA11256@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Vlastimil Babka <vbabka@suse.cz>, minchan@kernel.org, mgorman@suse.de, iamjoonsoo.kim@lge.com, mina86@mina86.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, cl@linux.com, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>

On 2016/7/20 15:47, Michal Hocko wrote:

> On Wed 20-07-16 09:33:30, Yisheng Xie wrote:
>>
>>
>> On 2016/7/19 22:14, Vlastimil Babka wrote:
>>> On 07/19/2016 03:48 PM, Xishi Qiu wrote:
> [...]
>>>> mode:0x2000d1 means it expects to alloc from zone_dma, (on arm64 zone_dma is 0-4G)
>>>
>>> Yes, but I don't see where the __GFP_DMA comes from. The backtrace
>>> suggests it's alloc_thread_info_node() which uses THREADINFO_GFP
>>> which is GFP_KERNEL | __GFP_NOTRACK. There shouldn't be __GFP_DMA,
>>> even on arm64. Are there some local modifications to the kernel
>>> source?
>>>
>>>> The page cache is very small(active_file:292kB inactive_file:240kB),
>>>> so did_some_progress may be zero, and will not retry, right?
>>>
>>> Could be, and then __alloc_pages_may_oom() has this:
>>>
>>>         /* The OOM killer does not needlessly kill tasks for lowmem */
>>>         if (ac->high_zoneidx < ZONE_NORMAL)
>>>                 goto out;
>>>
>>> So no oom and no faking progress for non-costly order that would
>>> result in retry, because of that mysterious __GFP_DMA...
>>
>> hi Vlastimil,
>> We do make change and add __GFP_DMA flag here for our platform driver's problem.
> 
> Why would you want to force thread_info to the DMA zone?
> 

Hi Michal,

Because of our platform driver's problem, so we change the code(add GFP_DMA) to let
it alloc from zone_dma. (on arm64 zone_dma is 0-4G)

Thanks,
Xishi Qiu

>> Another question is why it will do retry here, for it will goto out
>> with did_some_progress=0 ?
>>
>>              if (!did_some_progress)
>>                  goto nopage;
> 
> Do you mean:
>                 /*
>                  * If we fail to make progress by freeing individual
>                  * pages, but the allocation wants us to keep going,
>                  * start OOM killing tasks.
>                  */
>                 if (!did_some_progress) {
>                         page = __alloc_pages_may_oom(gfp_mask, order, ac,
>                                                         &did_some_progress);
>                         if (page)
>                                 goto got_pg;
>                         if (!did_some_progress)
>                                 goto nopage;
>                 }
> 
> If yes then this code simply tells that if even oom path didn't make any
> progress then we should fail. As DMA request doesn't invoke OOM killer
> because it is effectively a lowmem request (see above check pointed
> by Vlastimil) then the OOM path couldn't make any progress and we are
> failing. If invoked the OOM killer then we would consider this as a
> forward progress and retry the allocation request.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
