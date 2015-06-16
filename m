Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id D8AA56B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 04:20:46 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so8946016igb.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:20:46 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v6si10136922igk.51.2015.06.16.01.20.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 01:20:46 -0700 (PDT)
Message-ID: <557FDB9B.1090105@huawei.com>
Date: Tue, 16 Jun 2015 16:17:31 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
References: <55704A7E.5030507@huawei.com> <557FD5F8.10903@suse.cz>
In-Reply-To: <557FD5F8.10903@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/16 15:53, Vlastimil Babka wrote:

> On 06/04/2015 02:54 PM, Xishi Qiu wrote:
>> Intel Xeon processor E7 v3 product family-based platforms introduces support
>> for partial memory mirroring called as 'Address Range Mirroring'. This feature
>> allows BIOS to specify a subset of total available memory to be mirrored (and
>> optionally also specify whether to mirror the range 0-4 GB). This capability
>> allows user to make an appropriate tradeoff between non-mirrored memory range
>> and mirrored memory range thus optimizing total available memory and still
>> achieving highly reliable memory range for mission critical workloads and/or
>> kernel space.
>>
>> Tony has already send a patchset to supprot this feature at boot time.
>> https://lkml.org/lkml/2015/5/8/521
>>
>> This patchset can support the feature after boot time. It introduces mirror_info
>> to save the mirrored memory range. Then use __GFP_MIRROR to allocate mirrored 
>> pages. 
>>
>> I think add a new migratetype is btter and easier than a new zone, so I use
> 
> If the mirrored memory is in a single reasonably compact (no large holes) range
> (per NUMA node) and won't dynamically change its size, then zone might be a
> better option. For one thing, it will still allow distinguishing movable and
> unmovable allocations within the mirrored memory.
> 
> We had enough fun with MIGRATE_CMA and all kinds of checks it added to allocator
> hot paths, and even CMA is now considering moving to a separate zone.
> 

Hi, how about the problem of this case:
e.g. node 0: 0-4G(dma and dma32)
     node 1: 4G-8G(normal), 8-12G(mirror), 12-16G(normal),
so more than one normal zone in a node? or normal zone just span the mirror zone?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
