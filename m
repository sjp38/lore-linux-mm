Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 844B66B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 17:48:29 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id u57so5692027wes.8
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 14:48:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw3si11371161wjb.23.2014.03.07.14.48.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 14:48:28 -0800 (PST)
Message-ID: <531A4CBB.4070208@suse.cz>
Date: Fri, 07 Mar 2014 23:48:27 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv2] mm/compaction: Break out of loop on !PageBuddy in isolate_freepages_block
References: <1394130092-25440-1-git-send-email-lauraa@codeaurora.org> <20140306163349.d1f25dac8bc97f0cf89a82b5@linux-foundation.org>
In-Reply-To: <20140306163349.d1f25dac8bc97f0cf89a82b5@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <lauraa@codeaurora.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 7.3.2014 1:33, Andrew Morton wrote:
> On Thu,  6 Mar 2014 10:21:32 -0800 Laura Abbott <lauraa@codeaurora.org> wrote:
>
>> We received several reports of bad page state when freeing CMA pages
>> previously allocated with alloc_contig_range:
>>
>> <1>[ 1258.084111] BUG: Bad page state in process Binder_A  pfn:63202
>> <1>[ 1258.089763] page:d21130b0 count:0 mapcount:1 mapping:  (null) index:0x7dfbf
>> <1>[ 1258.096109] page flags: 0x40080068(uptodate|lru|active|swapbacked)
>>
>> Based on the page state, it looks like the page was still in use. The page
>> flags do not make sense for the use case though. Further debugging showed
>> that despite alloc_contig_range returning success, at least one page in the
>> range still remained in the buddy allocator.
>>
>> There is an issue with isolate_freepages_block. In strict mode (which CMA
>> uses), if any pages in the range cannot be isolated,
>> isolate_freepages_block should return failure 0. The current check keeps
>> track of the total number of isolated pages and compares against the size
>> of the range:
>>
>>          if (strict && nr_strict_required > total_isolated)
>>                  total_isolated = 0;
>>
>> After taking the zone lock, if one of the pages in the range is not
>> in the buddy allocator, we continue through the loop and do not
>> increment total_isolated. If in the last iteration of the loop we isolate
>> more than one page (e.g. last page needed is a higher order page), the
>> check for total_isolated may pass and we fail to detect that a page was
>> skipped. The fix is to bail out if the loop immediately if we are in
>> strict mode. There's no benfit to continuing anyway since we need all
>> pages to be isolated. Additionally, drop the error checking based on
>> nr_strict_required and just check the pfn ranges. This matches with
>> what isolate_freepages_range does.
>>
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -242,7 +242,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>   {
>>   	int nr_scanned = 0, total_isolated = 0;
>>   	struct page *cursor, *valid_page = NULL;
>> -	unsigned long nr_strict_required = end_pfn - blockpfn;
>>   	unsigned long flags;
>>   	bool locked = false;
>>   	bool checked_pageblock = false;
>> @@ -256,11 +255,12 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>   
>>   		nr_scanned++;
>>   		if (!pfn_valid_within(blockpfn))
>> -			continue;
>> +			goto isolate_fail;
>> +
>>   		if (!valid_page)
>>   			valid_page = page;
>>   		if (!PageBuddy(page))
>> -			continue;
>> +			goto isolate_fail;
>>   
>>   		/*
>>   		 * The zone lock must be held to isolate freepages.
>> @@ -289,12 +289,10 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>   
>>   		/* Recheck this is a buddy page under lock */
>>   		if (!PageBuddy(page))
>> -			continue;
>> +			goto isolate_fail;
>>   
>>   		/* Found a free page, break it into order-0 pages */
>>   		isolated = split_free_page(page);
>> -		if (!isolated && strict)
>> -			break;
>>   		total_isolated += isolated;
>>   		for (i = 0; i < isolated; i++) {
>>   			list_add(&page->lru, freelist);
>> @@ -305,7 +303,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>   		if (isolated) {
>>   			blockpfn += isolated - 1;
>>   			cursor += isolated - 1;
>> +			continue;
>>   		}
> We can make the code a little more efficient and (I think) clearer by
> moving that `if (isolated)' test.
>
>> +
>> +isolate_fail:
>> +		if (strict)
>> +			break;
>> +		else
>> +			continue;
>> +
> And I don't think this `continue' has any benefit.

Oops, missed that in my suggestion.

>
> --- a/mm/compaction.c~mm-compaction-break-out-of-loop-on-pagebuddy-in-isolate_freepages_block-fix
> +++ a/mm/compaction.c
> @@ -293,14 +293,14 @@ static unsigned long isolate_freepages_b
>   
>   		/* Found a free page, break it into order-0 pages */
>   		isolated = split_free_page(page);
> -		total_isolated += isolated;
> -		for (i = 0; i < isolated; i++) {
> -			list_add(&page->lru, freelist);
> -			page++;
> -		}
> -
> -		/* If a page was split, advance to the end of it */
>   		if (isolated) {
> +			total_isolated += isolated;
> +			for (i = 0; i < isolated; i++) {
> +				list_add(&page->lru, freelist);
> +				page++;
> +			}
> +
> +			/* If a page was split, advance to the end of it */
>   			blockpfn += isolated - 1;
>   			cursor += isolated - 1;
>   			continue;
> @@ -309,9 +309,6 @@ static unsigned long isolate_freepages_b
>   isolate_fail:
>   		if (strict)
>   			break;
> -		else
> -			continue;
> -
>   	}
>   
>   	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
>
>
> Problem is, I can't be bothered testing this.
>

I don't think it's necessary, or that the better efficiency would show :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
