Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 995C46B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:55:47 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so81402314wib.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 02:55:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h5si14379243wiy.49.2015.06.18.02.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 02:55:46 -0700 (PDT)
Message-ID: <5582959E.4080402@suse.cz>
Date: Thu, 18 Jun 2015 11:55:42 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
References: <55704A7E.5030507@huawei.com> <557FD5F8.10903@suse.cz> <557FDB9B.1090105@huawei.com> <557FF06A.3020000@suse.cz> <55821D85.3070208@huawei.com> <55825DF0.9090903@suse.cz> <55829149.60807@huawei.com>
In-Reply-To: <55829149.60807@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/18/2015 11:37 AM, Xishi Qiu wrote:
> On 2015/6/18 13:58, Vlastimil Babka wrote:
>
>> On 18.6.2015 3:23, Xishi Qiu wrote:
>>> On 2015/6/16 17:46, Vlastimil Babka wrote:
>>>
>>
>> On the other hand, it would skip just as inefficiently over MIGRATE_MIRROR
>> pageblocks within a Normal zone. Since migrating pages between MIGRATE_MIRROR
>> and other types pageblocks would violate what the allocations requested.
>>
>> Having separate zone instead would allow compaction to run specifically on the
>> zone and defragment movable allocations there (i.e. userspace pages if/when
>> userspace requesting mirrored memory is supported).
>>
>>>>
>>>
>>> Hi Vlastimil,
>>>
>>> If there are many mirror regions in one node, then it will be many holes in the
>>> normal zone, is this fine?
>>
>> Yeah, it doesn't matter how many holes there are.
>
> So mirror zone and normal zone will span each other, right?
>
> e.g. node 1: 4G-8G(normal), 8-12G(mirror), 12-16G(normal), 16-24G(mirror), 24-28G(normal) ...
> normal: start=4G, size=28-4=24G,
> mirror: start=8G, size=24-8=16G,

Yes, that works. It's somewhat unfortunate wrt performance that the 
hardware does it like this though.

> I think zone is defined according to the special address range, like 16M(DMA), 4G(DMA32),

Traditionally yes. But then there is ZONE_MOVABLE, this year's LSF/MM we 
discussed (and didn't outright deny) ZONE_CMA...
I'm not saying others will favour the new zone approach though, it's 
just my opinion that it might be a better option than a new migratetype.

> and is it appropriate to add a new mirror zone with a volatile physical address?

By "volatile" you mean what, that the example above would change 
dynamically? That would be rather challenging...

> Thanks,
> Xishi Qiu
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
