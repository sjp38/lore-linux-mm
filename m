Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id C2A8A6B0038
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 09:30:34 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id z12so8002110lbi.37
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 06:30:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lm5si22926568lac.7.2014.09.24.06.30.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 06:30:31 -0700 (PDT)
Message-ID: <5422C772.3080700@suse.cz>
Date: Wed, 24 Sep 2014 15:30:26 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 1/4] mm/page_alloc: fix incorrect isolation behavior
 by rechecking migratetype
References: <1409040498-10148-1-git-send-email-iamjoonsoo.kim@lge.com> <1409040498-10148-2-git-send-email-iamjoonsoo.kim@lge.com> <540D6961.8060209@suse.cz> <20140915023106.GD2676@js1304-P5Q-DELUXE>
In-Reply-To: <20140915023106.GD2676@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/15/2014 04:31 AM, Joonsoo Kim wrote:
> On Mon, Sep 08, 2014 at 10:31:29AM +0200, Vlastimil Babka wrote:
>> On 08/26/2014 10:08 AM, Joonsoo Kim wrote:
>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index f86023b..51e0d13 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -740,9 +740,15 @@ static void free_one_page(struct zone *zone,
>>>   	if (nr_scanned)
>>>   		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>>>
>>> +	if (unlikely(has_isolate_pageblock(zone))) {
>>> +		migratetype = get_pfnblock_migratetype(page, pfn);
>>> +		if (is_migrate_isolate(migratetype))
>>> +			goto skip_counting;
>>> +	}
>>> +	__mod_zone_freepage_state(zone, 1 << order, migratetype);
>>> +
>>> +skip_counting:
>>
>> Here, wouldn't a simple 'else __mod_zone_freepage_state...' look
>> better than goto + label? (same for the following 2 patches). Or
>> does that generate worse code?
>
> To remove goto label, we need two __mod_zone_freepage_state() like
> as below. On my system, it doesn't generate worse code, but, I am not
> sure that this is true if more logic would be added. I think that
> goto + label is better.

Oh right, I missed that. It's a bit subtle, but I don't see a nicer 
solution right now.

> +	if (unlikely(has_isolate_pageblock(zone))) {
> +		migratetype = get_pfnblock_migratetype(page, pfn);
> +               if (!is_migrate_isolate(migratetype))
> +                       __mod_zone_freepage_state(zone, 1 << order, migratetype);
> +       } else {
> +               __mod_zone_freepage_state(zone, 1 << order, migratetype);
>          }
>

Yeah that would be uglier I guess.

> Anyway, What do you think which one is better, either v2 or v3? Still, v3? :)

Yeah v3 is much better than v1 was, and better for backporting than v2. 
The changelogs also look quite clear. The overhead shouldn't be bad with 
the per-zone flag guarding get_pfnblock_migratetype.

I'm just not sure about patch 4 and potentially leaving unmerged budies 
behind. How would it look if instead we made sure isolation works on 
whole MAX_ORDER blocks instead?

Vlastimil

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
