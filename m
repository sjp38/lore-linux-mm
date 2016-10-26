Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65A3D6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:10:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a195so9721381oib.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 23:10:34 -0700 (PDT)
Received: from szxga01-in.huawei.com ([58.251.152.64])
        by mx.google.com with ESMTPS id o10si563232oih.127.2016.10.25.23.10.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 23:10:33 -0700 (PDT)
Message-ID: <5810487A.6060206@huawei.com>
Date: Wed, 26 Oct 2016 14:08:58 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/5] mm/page_alloc: always add freeing page at the
 tail of the buddy list
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com> <1476346102-26928-2-git-send-email-iamjoonsoo.kim@lge.com> <58049832.6000007@huawei.com> <20161026043740.GB2901@js1304-P5Q-DELUXE> <5810442D.2090903@huawei.com> <20161026055929.GD2901@js1304-P5Q-DELUXE>
In-Reply-To: <20161026055929.GD2901@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/10/26 13:59, Joonsoo Kim wrote:

> On Wed, Oct 26, 2016 at 01:50:37PM +0800, Xishi Qiu wrote:
>> On 2016/10/26 12:37, Joonsoo Kim wrote:
>>
>>> On Mon, Oct 17, 2016 at 05:21:54PM +0800, Xishi Qiu wrote:
>>>> On 2016/10/13 16:08, js1304@gmail.com wrote:
>>>>
>>>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>>>
>>>>> Currently, freeing page can stay longer in the buddy list if next higher
>>>>> order page is in the buddy list in order to help coalescence. However,
>>>>> it doesn't work for the simplest sequential free case. For example, think
>>>>> about the situation that 8 consecutive pages are freed in sequential
>>>>> order.
>>>>>
>>>>> page 0: attached at the head of order 0 list
>>>>> page 1: merged with page 0, attached at the head of order 1 list
>>>>> page 2: attached at the tail of order 0 list
>>>>> page 3: merged with page 2 and then merged with page 0, attached at
>>>>>  the head of order 2 list
>>>>> page 4: attached at the head of order 0 list
>>>>> page 5: merged with page 4, attached at the tail of order 1 list
>>>>> page 6: attached at the tail of order 0 list
>>>>> page 7: merged with page 6 and then merged with page 4. Lastly, merged
>>>>>  with page 0 and we get order 3 freepage.
>>>>>
>>>>> With excluding page 0 case, there are three cases that freeing page is
>>>>> attached at the head of buddy list in this example and if just one
>>>>> corresponding ordered allocation request comes at that moment, this page
>>>>> in being a high order page will be allocated and we would fail to make
>>>>> order-3 freepage.
>>>>>
>>>>> Allocation usually happens in sequential order and free also does. So, it
>>>>> would be important to detect such a situation and to give some chance
>>>>> to be coalesced.
>>>>>
>>>>> I think that simple and effective heuristic about this case is just
>>>>> attaching freeing page at the tail of the buddy list unconditionally.
>>>>> If freeing isn't merged during one rotation, it would be actual
>>>>> fragmentation and we don't need to care about it for coalescence.
>>>>>
>>>>
>>>> Hi Joonsoo,
>>>>
>>>> I find another two places to reduce fragmentation.
>>>>
>>>> 1)
>>>> __rmqueue_fallback
>>>> 	steal_suitable_fallback
>>>> 		move_freepages_block
>>>> 			move_freepages
>>>> 				list_move
>>>> If we steal some free pages, we will add these page at the head of start_migratetype list,
>>>> this will cause more fixed migratetype, because this pages will be allocated more easily.
>>>> So how about use list_move_tail instead of list_move?
>>>
>>> Yeah... I don't think deeply but, at a glance, it would be helpful.
>>>
>>>>
>>>> 2)
>>>> __rmqueue_fallback
>>>> 	expand
>>>> 		list_add
>>>> How about use list_add_tail instead of list_add? If add the tail, then the rest of pages
>>>> will be hard to be allocated and we can merge them again as soon as the page freed.
>>>
>>> I guess that it has no effect. When we do __rmqueue_fallback() and
>>> expand(), we don't have any freepage on this or more order. So,
>>> list_add or list_add_tail will show the same result.
>>>
>>
>> Hi Joonsoo,
>>
>> Usually this list is empty, but in the following case, the list is not empty.
>>
>> __rmqueue_fallback
>> 	steal_suitable_fallback
>> 		move_freepages_block  // move to the list of start_migratetype
>> 	expand  // split the largest order first
>> 		list_add  // add to the list of start_migratetype
> 
> In this case, stealed freepage on steal_suitable_fallback() and
> splitted freepage would come from the same pageblock. So, it doen't
> matter to use whatever list_add* function.
> 

Yes, they are from the same pageblock, stealed freepage will move to the
start_migratetype, and expand will move to the same migratetype too,
but the list may be not empty because of the stealed freepage.
So when we split the largest order, add to the tail will be allocated
less easily, right?

Thanks,
Xishi Qiu

> Thanks.
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
