Message-ID: <47628BC0.7020506@rtr.ca>
Date: Fri, 14 Dec 2007 08:57:20 -0500
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
References: <476190BE.9010405@rtr.ca> <20071213200958.GK10104@kernel.dk> <20071213140207.111f94e2.akpm@linux-foundation.org> <1197584106.3154.55.camel@localhost.localdomain> <20071213142935.47ff19d9.akpm@linux-foundation.org> <4761B32A.3070201@rtr.ca> <4761BCB4.1060601@rtr.ca> <4761C8E4.2010900@rtr.ca> <4761CE88.9070406@rtr.ca> <20071213163726.3bb601fa.akpm@linux-foundation.org> <20071214115038.GB11046@csn.ul.ie>
In-Reply-To: <20071214115038.GB11046@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, James.Bottomley@HansenPartnership.com, jens.axboe@oracle.com, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On (13/12/07 16:37), Andrew Morton didst pronounce:
>> On Thu, 13 Dec 2007 19:30:00 -0500
>> Mark Lord <liml@rtr.ca> wrote:
>>
>>> Here's the commit that causes the regression:
>>>
>>> ...
>>>
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -760,7 +760,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>>>  		struct page *page = __rmqueue(zone, order, migratetype);
>>>  		if (unlikely(page == NULL))
>>>  			break;
>>> -		list_add_tail(&page->lru, list);
>>> +		list_add(&page->lru, list);
>> well that looks fishy.
>>
> 
> The reasoning behind the change was the first page encountered on the list
> by the caller would have a matching migratetype. I failed to take into
> account the physical ordering of pages returned. I'm setting up to run some
> performance benchmarks of the candidate fix merged into the -mm tree to see
> if the search shows up or not. I'm testing against 2.6.25-rc5 but it'll
> take a few hours to complete.
..

Thanks, Mel.  This is all with CONFIG_SLAB=y, by the way.

Note that it did appear to behave better with CONFIG_SLUB=y when I accidently
used that .config on my 4GB machine here.  Physical segments of 4-10 pages
happended much more common than with CONFIG_SLAB=y on my 3GB machine
Slightly "apples and oranges" there, I know, but at least both were x86-32.  :)

So I would expect CONFIG_SLAB to be well off with this patch under most (all?)
conditions, but dunno about CONFIG_SLUB.

Cheers




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
