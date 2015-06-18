Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 251566B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:40:26 -0400 (EDT)
Received: by oiax193 with SMTP id x193so53433382oia.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 02:40:25 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id h144si4396131oib.126.2015.06.18.02.40.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 02:40:24 -0700 (PDT)
Message-ID: <55829149.60807@huawei.com>
Date: Thu, 18 Jun 2015 17:37:13 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
References: <55704A7E.5030507@huawei.com> <557FD5F8.10903@suse.cz> <557FDB9B.1090105@huawei.com> <557FF06A.3020000@suse.cz> <55821D85.3070208@huawei.com> <55825DF0.9090903@suse.cz>
In-Reply-To: <55825DF0.9090903@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/18 13:58, Vlastimil Babka wrote:

> On 18.6.2015 3:23, Xishi Qiu wrote:
>> On 2015/6/16 17:46, Vlastimil Babka wrote:
>>
>>> On 06/16/2015 10:17 AM, Xishi Qiu wrote:
>>>> On 2015/6/16 15:53, Vlastimil Babka wrote:
>>>>
>>>>> On 06/04/2015 02:54 PM, Xishi Qiu wrote:
>>>>>>
>>>>>> I think add a new migratetype is btter and easier than a new zone, so I use
>>>>>
>>>>> If the mirrored memory is in a single reasonably compact (no large holes) range
>>>>> (per NUMA node) and won't dynamically change its size, then zone might be a
>>>>> better option. For one thing, it will still allow distinguishing movable and
>>>>> unmovable allocations within the mirrored memory.
>>>>>
>>>>> We had enough fun with MIGRATE_CMA and all kinds of checks it added to allocator
>>>>> hot paths, and even CMA is now considering moving to a separate zone.
>>>>>
>>>>
>>>> Hi, how about the problem of this case:
>>>> e.g. node 0: 0-4G(dma and dma32)
>>>>      node 1: 4G-8G(normal), 8-12G(mirror), 12-16G(normal),
>>>> so more than one normal zone in a node? or normal zone just span the mirror zone?
>>>
>>> Normal zone can span the mirror zone just fine. However, it will result in zone
>>> scanners such as compaction to skip over the mirror zone inefficiently. Hmm...
> 
> On the other hand, it would skip just as inefficiently over MIGRATE_MIRROR
> pageblocks within a Normal zone. Since migrating pages between MIGRATE_MIRROR
> and other types pageblocks would violate what the allocations requested.
> 
> Having separate zone instead would allow compaction to run specifically on the
> zone and defragment movable allocations there (i.e. userspace pages if/when
> userspace requesting mirrored memory is supported).
> 
>>>
>>
>> Hi Vlastimil,
>>
>> If there are many mirror regions in one node, then it will be many holes in the
>> normal zone, is this fine?
> 
> Yeah, it doesn't matter how many holes there are.

So mirror zone and normal zone will span each other, right?

e.g. node 1: 4G-8G(normal), 8-12G(mirror), 12-16G(normal), 16-24G(mirror), 24-28G(normal) ...
normal: start=4G, size=28-4=24G,
mirror: start=8G, size=24-8=16G,

I think zone is defined according to the special address range, like 16M(DMA), 4G(DMA32),
and is it appropriate to add a new mirror zone with a volatile physical address?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
