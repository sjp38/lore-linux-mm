Message-ID: <46E30411.3070500@redhat.com>
Date: Sat, 08 Sep 2007 16:20:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] prevent kswapd from freeing excessive amounts of lowmem
References: <46DF3545.4050604@redhat.com> <20070907122437.GC3901@ucw.cz>
In-Reply-To: <20070907122437.GC3901@ucw.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linux kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, safari-kernel@safari.iki.fi
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
> Hi!
> 
>> The current VM can get itself into trouble fairly easily 
>> on systems
>> with a small ZONE_HIGHMEM, which is common on i686 
>> computers with
>> 1GB of memory.
>>
>> On one side, page_alloc() will allocate down to 
>> zone->pages_low,
>> while on the other side, kswapd() and balance_pgdat() 
>> will try
>> to free memory from every zone, until every zone has 
>> more free
>> pages than zone->pages_high.
>>
>> Highmem can be filled up to zone->pages_low with page 
>> tables,
>> ramfs, vmalloc allocations and other unswappable things 
>> quite
>> easily and without many bad side effects, since we still 
>> have
>> a huge ZONE_NORMAL to do future allocations from.
>>
>> However, as long as the number of free pages in the 
>> highmem
>> zone is below zone->pages_high, kswapd will continue 
>> swapping
>> things out from ZONE_NORMAL, too!
>>
>> Sami Farin managed to get his system into a stage where 
>> kswapd
>> had freed about 700MB of low memory and was still "going 
>> strong".
>>
>> The attached patch will make kswapd stop paging out data 
>> from
>> zones when there is more than enough memory free.  We do 
>> go above
>> zone->pages_high in order to keep pressure between zones 
>> equal
>> in normal circumstances, but the patch should prevent 
>> the kind
>> of excesses that made Sami's computer totally unusable.
>>
>> Please merge this into -mm.
>>
>> Signed-off-by: Rik van Riel <riel@redhat.com>
> 
>> --- linux-2.6.22.noarch/mm/vmscan.c.excessive	2007-09-05 12:19:49.000000000 -0400
>> +++ linux-2.6.22.noarch/mm/vmscan.c	2007-09-05 12:21:40.000000000 -0400
>> @@ -1371,7 +1371,13 @@ loop_again:
>>  			temp_priority[i] = priority;
>>  			sc.nr_scanned = 0;
>>  			note_zone_scanning_priority(zone, priority);
>> -			nr_reclaimed += shrink_zone(priority, zone, &sc);
>> +			/*
>> +			 * We put equal pressure on every zone, unless one
>> +			 * zone has way too many pages free already.
>> +			 */
> 
> That does not seem right. Having empty HIGHMEM and full LOWMEM would
> be very bad, right? We may stop freeing when there's enough LOWMEM
> free, but not if there's only HIGHMEM free.

Please read the code this patch applies to.

The check I add conditionalizes the individual
calls to shrink_zone(), so we do not call
shrink_zone() for a zone that has a ton of free
pages.  We still call shrink_zone() for the
other zones.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
