Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 56DDD6B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 01:58:11 -0400 (EDT)
Received: by wgez8 with SMTP id z8so53958936wge.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 22:58:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb3si12193918wjc.44.2015.06.17.22.58.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 22:58:09 -0700 (PDT)
Message-ID: <55825DF0.9090903@suse.cz>
Date: Thu, 18 Jun 2015 07:58:08 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
References: <55704A7E.5030507@huawei.com> <557FD5F8.10903@suse.cz> <557FDB9B.1090105@huawei.com> <557FF06A.3020000@suse.cz> <55821D85.3070208@huawei.com>
In-Reply-To: <55821D85.3070208@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 18.6.2015 3:23, Xishi Qiu wrote:
> On 2015/6/16 17:46, Vlastimil Babka wrote:
> 
>> On 06/16/2015 10:17 AM, Xishi Qiu wrote:
>>> On 2015/6/16 15:53, Vlastimil Babka wrote:
>>>
>>>> On 06/04/2015 02:54 PM, Xishi Qiu wrote:
>>>>>
>>>>> I think add a new migratetype is btter and easier than a new zone, so I use
>>>>
>>>> If the mirrored memory is in a single reasonably compact (no large holes) range
>>>> (per NUMA node) and won't dynamically change its size, then zone might be a
>>>> better option. For one thing, it will still allow distinguishing movable and
>>>> unmovable allocations within the mirrored memory.
>>>>
>>>> We had enough fun with MIGRATE_CMA and all kinds of checks it added to allocator
>>>> hot paths, and even CMA is now considering moving to a separate zone.
>>>>
>>>
>>> Hi, how about the problem of this case:
>>> e.g. node 0: 0-4G(dma and dma32)
>>>      node 1: 4G-8G(normal), 8-12G(mirror), 12-16G(normal),
>>> so more than one normal zone in a node? or normal zone just span the mirror zone?
>>
>> Normal zone can span the mirror zone just fine. However, it will result in zone
>> scanners such as compaction to skip over the mirror zone inefficiently. Hmm...

On the other hand, it would skip just as inefficiently over MIGRATE_MIRROR
pageblocks within a Normal zone. Since migrating pages between MIGRATE_MIRROR
and other types pageblocks would violate what the allocations requested.

Having separate zone instead would allow compaction to run specifically on the
zone and defragment movable allocations there (i.e. userspace pages if/when
userspace requesting mirrored memory is supported).

>>
> 
> Hi Vlastimil,
> 
> If there are many mirror regions in one node, then it will be many holes in the
> normal zone, is this fine?

Yeah, it doesn't matter how many holes there are.

> Thanks,
> Xishi Qiu
> 
>>
>> .
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
