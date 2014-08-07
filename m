Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id A6DE26B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 09:35:30 -0400 (EDT)
Received: by mail-oi0-f47.google.com with SMTP id x69so2642245oia.6
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 06:35:30 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id de12si7323504oeb.14.2014.08.07.06.35.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 06:35:30 -0700 (PDT)
Received: by mail-ob0-f177.google.com with SMTP id wp18so2831328obc.22
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 06:35:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53E37953.4000506@suse.cz>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1407309517-3270-9-git-send-email-iamjoonsoo.kim@lge.com>
	<53E245D4.9080506@suse.cz>
	<20140807081945.GA2427@js1304-P5Q-DELUXE>
	<53E33E6D.1080002@suse.cz>
	<CAAmzW4MoARz7Mp_Y1PUEQEJnMouKighgUOHaQH63B+6eKiA9nw@mail.gmail.com>
	<53E37953.4000506@suse.cz>
Date: Thu, 7 Aug 2014 22:35:29 +0900
Message-ID: <CAAmzW4Mk+adD3WtK4q82w+MaunBdfENK7XQP+qOyPJ1yoeBYbQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/8] mm/isolation: change pageblock isolation logic to
 fix freepage counting bugs
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2014-08-07 22:04 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 08/07/2014 02:26 PM, Joonsoo Kim wrote:
>>
>> 2014-08-07 17:53 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>>>
>>> Ah, right. I thought that everything going to pcp lists would be through
>>>
>>> freeing which would already observe the isolate migratetype and skip
>>> pcplist. I forgot about the direct filling of pcplists from buddy list.
>>> You're right that we don't want extra hooks there.
>>>
>>> Still, couldn't this be solved in a simpler way via another pcplist drain
>>> after the pages are moved from normal to isolate buddy list? Should be
>>> even
>>> faster because instead of disable - drain - enable (5 all-cpu kicks,
>>> since
>>> each pageset_update does 2 kicks) you have drain - drain (2 kicks). While
>>> it's true that pageset_update is single-zone operation, I guess we would
>>> easily benefit from having a single-zone drain operation as well.
>>
>>
>> I hope so, but, it's not possible. Consider following situation.
>>
>> Page A: on pcplist of CPU2 and it is on isolate pageblock.
>>
>> CPU 1                   CPU 2
>> drain pcplist
>> wait IPI finished     move A to normal buddy list
>> finish IPI
>>                              A is moved to pcplist by allocation request
>>
>> move doesn't catch A,
>> because it is on pcplist.
>>
>> drain pcplist
>> wait IPI finished     move A to normal buddy list
>> finish IPI
>>                              A is moved to pcplist by allocation request
>>
>> repeat!!
>>
>> It could happen infinitely, though, low possibility.
>
>
> Hm I see. Not a correctness issue, but still a failure to isolate. Probably
> not impossible with enough CPU's and considering the fact that after
> pcplists are drained, the next allocation request will try to refill them.
> And during the drain, the pages are added to the beginning of the free_list
> AFAICS, so they will be in the first refill batch.

I think that it is correctness issue. When page A is moved to normal buddy
list, merge could happen and freepage counting would be incorrect.

> OK, another attempt for alternative solution proposal :) It's not that I
> would think disabling pcp would be so bad, just want to be sure there is no
> better alternative.

Yeah, welcome any comment. :)

> What if the drain operation had a flag telling it to recheck pageblock
> migratetype and don't assume it's on the correct pcplist. Then the problem
> would go away I think? Would it be possible to do without affecting the
> normal drain-pcplist-when-full path? So that the cost is only applied to
> isolation, but lower cost than pcplist disabling.
>
> Actually I look that free_pcppages_bulk() doesn't consider migratetype of
> the pcplist, but uses get_freepage_migratetype(page). So the pcplist drain
> could first scan the pcplists and rewrite the freepage_migratetype according
> to pageblock_migratetype. Then the free_pcppages_bulk() operation would be
> unchanged for normal operation.
>
> Or is this too clumsy? We could be also smart and have an alternative to
> free_pcppages_bulk() which would omit the round-robin stuff (not needed for
> this kind of drain), and have a pfn range to limit its operation to pages
> that we are isolating.
> Hm I guess with this approach some pages might still escape us if they were
> moving between normal buddy list and pcplist through rmqueue_bulk() and
> free_pcppages_bulk() (and not through our drain) at the wrong moments, but I
> guess that would require a really specific workload (alternating between
> burst of allocations and deallocations) and consistently unlucky timing.
>

Yes, it has similar problem as I mentioned above.

Page A: on pcplist of CPU2 and it is on isolate pageblock.

CPU 1                   CPU 2
                            A is on normal buddy list
drain pcplist
wait IPI finished
finish IPI
                             A is moved to pcplist by allocation request
move doesn't catch A,
because it is on pcplist.
                            move A to normal buddy list by free request

drain pcplist
wait IPI finished
finish IPI
                             A is moved to pcplist by allocation request
move doesn't catch A,
because it is on pcplist.
                            move A to normal buddy list by free request

repeat!!

Although it is really corner case, I would like to choose error-free
approach something like pcplist disable. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
