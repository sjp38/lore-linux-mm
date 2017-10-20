Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 426236B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 03:25:54 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j126so10344317oib.9
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 00:25:54 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id u128si162274oib.144.2017.10.20.00.25.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 00:25:53 -0700 (PDT)
Message-ID: <59E9A426.5070009@huawei.com>
Date: Fri, 20 Oct 2017 15:22:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz> <20171013120013.698-1-mhocko@kernel.org> <20171019025111.GA3852@js1304-P5Q-DELUXE> <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz> <20171019073355.GA4486@js1304-P5Q-DELUXE> <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz> <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz> <20171020021329.GB10438@js1304-P5Q-DELUXE>
In-Reply-To: <20171020021329.GB10438@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 2017/10/20 10:13, Joonsoo Kim wrote:

> On Thu, Oct 19, 2017 at 02:21:18PM +0200, Michal Hocko wrote:
>> On Thu 19-10-17 10:20:41, Michal Hocko wrote:
>>> On Thu 19-10-17 16:33:56, Joonsoo Kim wrote:
>>>> On Thu, Oct 19, 2017 at 09:15:03AM +0200, Michal Hocko wrote:
>>>>> On Thu 19-10-17 11:51:11, Joonsoo Kim wrote:
>>> [...]
>>>>>> Hello,
>>>>>>
>>>>>> This patch will break the CMA user. As you mentioned, CMA allocation
>>>>>> itself isn't migrateable. So, after a single page is allocated through
>>>>>> CMA allocation, has_unmovable_pages() will return true for this
>>>>>> pageblock. Then, futher CMA allocation request to this pageblock will
>>>>>> fail because it requires isolating the pageblock.
>>>>>
>>>>> Hmm, does this mean that the CMA allocation path depends on
>>>>> has_unmovable_pages to return false here even though the memory is not
>>>>> movable? This sounds really strange to me and kind of abuse of this
>>>>
>>>> Your understanding is correct. Perhaps, abuse or wrong function name.
>>>>
>>>>> function. Which path is that? Can we do the migrate type test theres?
>>>>
>>>> alloc_contig_range() -> start_isolate_page_range() ->
>>>> set_migratetype_isolate() -> has_unmovable_pages()
>>>
>>> I see. It seems that the CMA and memory hotplug have a very different
>>> view on what should happen during isolation.
>>>  
>>>> We can add one argument, 'XXX' to set_migratetype_isolate() and change
>>>> it to check migrate type rather than has_unmovable_pages() if 'XXX' is
>>>> specified.
>>>
>>> Can we use the migratetype argument and do the special thing for
>>> MIGRATE_CMA? Like the following diff?
>>
>> And with the full changelog.
>> ---
>> >From 8cbd811d741f5dd93d1b21bb3ef94482a4d0bd32 Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.com>
>> Date: Thu, 19 Oct 2017 14:14:02 +0200
>> Subject: [PATCH] mm: distinguish CMA and MOVABLE isolation in
>>  has_unmovable_pages
>>
>> Joonsoo has noticed that "mm: drop migrate type checks from
>> has_unmovable_pages" would break CMA allocator because it relies on
>> has_unmovable_pages returning false even for CMA pageblocks which in
>> fact don't have to be movable:
>> alloc_contig_range
>>   start_isolate_page_range
>>     set_migratetype_isolate
>>       has_unmovable_pages
>>
>> This is a result of the code sharing between CMA and memory hotplug
>> while each one has a different idea of what has_unmovable_pages should
>> return. This is unfortunate but fixing it properly would require a lot
>> of code duplication.
>>
>> Fix the issue by introducing the requested migrate type argument
>> and special case MIGRATE_CMA case where CMA page blocks are handled
>> properly. This will work for memory hotplug because it requires
>> MIGRATE_MOVABLE.
> 
> Unfortunately, alloc_contig_range() can be called with
> MIGRATE_MOVABLE so this patch cannot perfectly fix the problem.
> 
> I did a more thinking and found that it's strange to check if there is
> unmovable page in the pageblock during the set_migratetype_isolate().
> set_migratetype_isolate() should be just for setting the migratetype
> of the pageblock. Checking other things should be done by another
> place, for example, before calling the start_isolate_page_range() in
> __offline_pages().
> 
> Thanks.
> 

Hi Joonsoo,

How about add a flag to skip or not has_unmovable_pages() in set_migratetype_isolate()?
Something like the skip_hwpoisoned_pages.

Thanks,
Xishi Qiu

> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
