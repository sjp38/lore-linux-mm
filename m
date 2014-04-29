Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 430AD6B0037
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 04:40:38 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so7490eek.3
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 01:40:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si26049876een.353.2014.04.29.01.40.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 01:40:36 -0700 (PDT)
Message-ID: <535F657D.3060809@suse.cz>
Date: Tue, 29 Apr 2014 10:40:29 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
References: <20140421124146.c8beacf0d58aafff2085a461@linux-foundation.org> <535590FC.10607@suse.cz> <20140421235319.GD7178@bbox> <53560D3F.2030002@suse.cz> <20140422065224.GE24292@bbox> <53566BEA.2060808@suse.cz> <20140423025806.GA11184@js1304-P5Q-DELUXE> <53576C08.2080003@suse.cz> <CAAmzW4OjKcrzXYNG6KN8acbOVfVtFmu-1COKpNQJrraBTmWGiA@mail.gmail.com> <5357CEB2.1070900@suse.cz> <20140425082941.GA11428@js1304-P5Q-DELUXE>
In-Reply-To: <20140425082941.GA11428@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 04/25/2014 10:29 AM, Joonsoo Kim wrote:
> On Wed, Apr 23, 2014 at 04:31:14PM +0200, Vlastimil Babka wrote:
>>>>>
>>>>> Hello,
>>>>>
>>>>> How about doing more clean-up at this time?
>>>>>
>>>>> What I did is that taking end_pfn out of the loop and consider zone
>>>>> boundary once. After then, we just subtract pageblock_nr_pages on
>>>>> every iteration. With this change, we can remove local variable, z_end_pfn.
>>>>> Another things I did are removing max() operation and un-needed
>>>>> assignment to isolate variable.
>>>>>
>>>>> Thanks.
>>>>>
>>>>> --------->8------------
>>>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>>>> index 1c992dc..95a506d 100644
>>>>> --- a/mm/compaction.c
>>>>> +++ b/mm/compaction.c
>>>>> @@ -671,10 +671,10 @@ static void isolate_freepages(struct zone *zone,
>>>>>                                struct compact_control *cc)
>>>>>   {
>>>>>        struct page *page;
>>>>> -     unsigned long pfn;           /* scanning cursor */
>>>>> +     unsigned long pfn;           /* start of scanning window */
>>>>> +     unsigned long end_pfn;       /* end of scanning window */
>>>>>        unsigned long low_pfn;       /* lowest pfn scanner is able to scan */
>>>>>        unsigned long next_free_pfn; /* start pfn for scaning at next round */
>>>>> -     unsigned long z_end_pfn;     /* zone's end pfn */
>>>>>        int nr_freepages = cc->nr_freepages;
>>>>>        struct list_head *freelist = &cc->freepages;
>>>>>
>>>>> @@ -688,15 +688,16 @@ static void isolate_freepages(struct zone *zone,
>>>>>         * is using.
>>>>>         */
>>>>>        pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
>>>>> -     low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>>>>
>>>>>        /*
>>>>> -      * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
>>>>> -      * isolated, the pfn < low_pfn check will kick in.
>>>>> +      * Take care when isolating in last pageblock of a zone which
>>>>> +      * ends in the middle of a pageblock.
>>>>>         */
>>>>> -     next_free_pfn = 0;
>>>>> +     end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn(zone));
>>>>> +     low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>>>>
>>>>> -     z_end_pfn = zone_end_pfn(zone);
>>>>> +     /* If no pages are isolated, the pfn < low_pfn check will kick in. */
>>>>> +     next_free_pfn = 0;
>>>>>
>>>>>        /*
>>>>>         * Isolate free pages until enough are available to migrate the
>>>>> @@ -704,9 +705,8 @@ static void isolate_freepages(struct zone *zone,
>>>>>         * and free page scanners meet or enough free pages are isolated.
>>>>>         */
>>>>>        for (; pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
>>>>> -                                     pfn -= pageblock_nr_pages) {
>>>>> +             pfn -= pageblock_nr_pages, end_pfn -= pageblock_nr_pages) {
>>>>
>>>> If zone_end_pfn was in the middle of a pageblock, then your end_pfn will
>>>> always be in the middle of a pageblock and you will not scan half of all
>>>> pageblocks.
>>>>
>>>
>>> Okay. I think a way to fix it.
>>> By assigning pfn(start of scanning window) to
>>> end_pfn(end of scanning window) for the next loop, we can solve the problem
>>> you mentioned. How about below?
>>>
>>> -             pfn -= pageblock_nr_pages, end_pfn -= pageblock_nr_pages) {
>>> +            end_pfn = pfn, pfn -= pageblock_nr_pages) {
>>
>> Hm that's perhaps a bit subtle but it would work.
>> Maybe better names for pfn and end_pfn would be block_start_pfn and
>> block_end_pfn. And in those comments, s/scanning window/current pageblock/.
>> And please don't move the low_pfn assignment like you did. The comment
>> above the original location explains it, the comment above the new
>> location doesn't. It's use in the loop is also related to 'pfn', not
>> 'end_pfn'.
>
> Okay.
> Following patch solves all your concerns.
> End result looks so nice to me. :)

Great, thanks!

> Thanks.
>
> --------->8----------------
>  From ae653cf8b9f8c7423cad73af38cde94eec564b50 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Fri, 25 Apr 2014 17:12:58 +0900
> Subject: [PATCH] mm-compaction-cleanup-isolate_freepages-fix3
>
> What I did here is taking end_pfn out of the loop and considering zone
> boundary once. After then, we can just set previous pfn to end_pfn on
> every iteration to move scanning window. With this change, we can remove
> local variable, z_end_pfn.
>
> Another things I did are removing max() operation and un-needed
> assignment to isolate variable.
>
> In addition, I change both the variable names, from pfn and
> end_pfn to block_start_pfn and block_end_pfn, respectively.
> They represent their meaning perfectly.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.de>

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1c992dc..ba80bea 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -671,10 +671,10 @@ static void isolate_freepages(struct zone *zone,
>   				struct compact_control *cc)
>   {
>   	struct page *page;
> -	unsigned long pfn;	     /* scanning cursor */
> +	unsigned long block_start_pfn;	/* start of current pageblock */
> +	unsigned long block_end_pfn;	/* end of current pageblock */
>   	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
>   	unsigned long next_free_pfn; /* start pfn for scaning at next round */
> -	unsigned long z_end_pfn;     /* zone's end pfn */
>   	int nr_freepages = cc->nr_freepages;
>   	struct list_head *freelist = &cc->freepages;
>
> @@ -682,31 +682,33 @@ static void isolate_freepages(struct zone *zone,
>   	 * Initialise the free scanner. The starting point is where we last
>   	 * successfully isolated from, zone-cached value, or the end of the
>   	 * zone when isolating for the first time. We need this aligned to
> -	 * the pageblock boundary, because we do pfn -= pageblock_nr_pages
> -	 * in the for loop.
> +	 * the pageblock boundary, because we do
> +	 * block_start_pfn -= pageblock_nr_pages in the for loop.
> +	 * For ending point, take care when isolating in last pageblock of a
> +	 * a zone which ends in the middle of a pageblock.
>   	 * The low boundary is the end of the pageblock the migration scanner
>   	 * is using.
>   	 */
> -	pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
> +	block_start_pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
> +	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
> +						zone_end_pfn(zone));
>   	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>
>   	/*
> -	 * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
> -	 * isolated, the pfn < low_pfn check will kick in.
> +	 * If no pages are isolated, the block_start_pfn < low_pfn check
> +	 * will kick in.
>   	 */
>   	next_free_pfn = 0;
>
> -	z_end_pfn = zone_end_pfn(zone);
> -
>   	/*
>   	 * Isolate free pages until enough are available to migrate the
>   	 * pages on cc->migratepages. We stop searching if the migrate
>   	 * and free page scanners meet or enough free pages are isolated.
>   	 */
> -	for (; pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
> -					pfn -= pageblock_nr_pages) {
> +	for (;block_start_pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
> +				block_end_pfn = block_start_pfn,
> +				block_start_pfn -= pageblock_nr_pages) {
>   		unsigned long isolated;
> -		unsigned long end_pfn;
>
>   		/*
>   		 * This can iterate a massively long zone without finding any
> @@ -715,7 +717,7 @@ static void isolate_freepages(struct zone *zone,
>   		 */
>   		cond_resched();
>
> -		if (!pfn_valid(pfn))
> +		if (!pfn_valid(block_start_pfn))
>   			continue;
>
>   		/*
> @@ -725,7 +727,7 @@ static void isolate_freepages(struct zone *zone,
>   		 * i.e. it's possible that all pages within a zones range of
>   		 * pages do not belong to a single zone.
>   		 */
> -		page = pfn_to_page(pfn);
> +		page = pfn_to_page(block_start_pfn);
>   		if (page_zone(page) != zone)
>   			continue;
>
> @@ -738,15 +740,8 @@ static void isolate_freepages(struct zone *zone,
>   			continue;
>
>   		/* Found a block suitable for isolating free pages from */
> -		isolated = 0;
> -
> -		/*
> -		 * Take care when isolating in last pageblock of a zone which
> -		 * ends in the middle of a pageblock.
> -		 */
> -		end_pfn = min(pfn + pageblock_nr_pages, z_end_pfn);
> -		isolated = isolate_freepages_block(cc, pfn, end_pfn,
> -						   freelist, false);
> +		isolated = isolate_freepages_block(cc, block_start_pfn,
> +					block_end_pfn, freelist, false);
>   		nr_freepages += isolated;
>
>   		/*
> @@ -754,9 +749,9 @@ static void isolate_freepages(struct zone *zone,
>   		 * looking for free pages, the search will restart here as
>   		 * page migration may have returned some pages to the allocator
>   		 */
> -		if (isolated) {
> +		if (isolated && next_free_pfn == 0) {
>   			cc->finished_update_free = true;
> -			next_free_pfn = max(next_free_pfn, pfn);
> +			next_free_pfn = block_start_pfn;
>   		}
>   	}
>
> @@ -767,7 +762,7 @@ static void isolate_freepages(struct zone *zone,
>   	 * If we crossed the migrate scanner, we want to keep it that way
>   	 * so that compact_finished() may detect this
>   	 */
> -	if (pfn < low_pfn)
> +	if (block_start_pfn < low_pfn)
>   		next_free_pfn = cc->migrate_pfn;
>
>   	cc->free_pfn = next_free_pfn;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
