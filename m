Message-ID: <4931721D.7010001@redhat.com>
Date: Sat, 29 Nov 2008 11:47:25 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
References: <20081128060803.73cd59bd@bree.surriel.com> <20081128231933.8daef193.akpm@linux-foundation.org>
In-Reply-To: <20081128231933.8daef193.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>> Index: linux-2.6.28-rc5/mm/vmscan.c
>> ===================================================================
>> --- linux-2.6.28-rc5.orig/mm/vmscan.c	2008-11-28 05:53:56.000000000 -0500
>> +++ linux-2.6.28-rc5/mm/vmscan.c	2008-11-28 06:05:29.000000000 -0500
>> @@ -1510,6 +1510,9 @@ static unsigned long shrink_zones(int pr
>>  			if (zone_is_all_unreclaimable(zone) &&
>>  						priority != DEF_PRIORITY)
>>  				continue;	/* Let kswapd poll it */
>> +			if (zone_watermark_ok(zone, sc->order,
>> +					4*zone->pages_high, high_zoneidx, 0))
>> +				continue;	/* Lots free already */
>>  			sc->all_unreclaimable = 0;
>>  		} else {
>>  			/*
> 
> We already tried this, or something very similar in effect, I think...

Yes, we have a check just like this in balance_pgdat().

It's been there forever with no ill effect.

> commit 26e4931632352e3c95a61edac22d12ebb72038fe
> Author: akpm <akpm>
> Date:   Sun Sep 8 19:21:55 2002 +0000
> 
>     [PATCH] refill the inactive list more quickly
>     
>     Fix a problem noticed by Ed Tomlinson: under shifting workloads the
>     shrink_zone() logic will refill the inactive load too slowly.
>     
>     Bale out of the zone scan when we've reclaimed enough pages.  Fixes a
>     rarely-occurring problem wherein refill_inactive_zone() ends up
>     shuffling 100,000 pages and generally goes silly.

This is not a bale out, this is a "skip zones that have way
too many free pages already".

Kswapd has been doing this for years already.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
