Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACA916B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 06:51:56 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so17895699wjy.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 03:51:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h26si620307wrb.231.2017.02.06.03.51.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 03:51:55 -0800 (PST)
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
 <719282122.1183240.1486298780546@mail.yahoo.com>
 <20170206083128.GC3085@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2f0f6c5e-4b55-24f0-2452-e958da1796f7@suse.cz>
Date: Mon, 6 Feb 2017 12:51:35 +0100
MIME-Version: 1.0
In-Reply-To: <20170206083128.GC3085@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On 02/06/2017 09:31 AM, Michal Hocko wrote:
> [CC Vlastimil]

Hmm, we should rather add Mel as this is due to his patches.

> On Sun 05-02-17 12:46:20, Shantanu Goel wrote:
>> Hi,
>>
>> On 4.9.7 kswapd is failing to wake up kcompactd due to a mismatch in the zone balance check between balance_pgdat() and prepare_kswapd_sleep().  balance_pgdat() returns as soon as a single zone satisfies the allocation but prepare_kswapd_sleep() requires all zones to do the same.  This causes prepare_kswapd_sleep() to never succeed except in the order == 0 case and consequently, wakeup_kcompactd() is never called.  On my machine prior to apply this patch, the state of compaction from /proc/vmstat looked this way after a day and a half of uptime:
>>
>> compact_migrate_scanned 240496
>> compact_free_scanned 76238632
>> compact_isolated 123472
>> compact_stall 1791
>> compact_fail 29
>> compact_success 1762
>> compact_daemon_wake 0
>>
>>
>> After applying the patch and about 10 hours of uptime the state looks like this:
>>
>> compact_migrate_scanned 59927299
>> compact_free_scanned 2021075136
>> compact_isolated 640926
>> compact_stall 4
>> compact_fail 2
>> compact_success 2
>> compact_daemon_wake 5160
>>
>>
>> Thanks,
>> Shantanu
> 
>> From 46f2e4b02ac263bf50d69cdab3bcbd7bcdea7415 Mon Sep 17 00:00:00 2001
>> From: Shantanu Goel <sgoel01@yahoo.com>
>> Date: Sat, 4 Feb 2017 19:07:53 -0500
>> Subject: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
>>
>> The check in prepare_kswapd_sleep needs to match the one in balance_pgdat
>> since the latter will return as soon as any one of the zones in the
>> classzone is above the watermark.

This seems to be since commit 86c79f6b5426ce ("mm: vmscan: do not
reclaim from kswapd if there is any eligible zone")

>  This is specially important for
>> higher order allocations since balance_pgdat will typically reset
>> the order to zero relying on compaction to create the higher order
>> pages.  Without this patch, prepare_kswapd_sleep fails to wake up
>> kcompactd since the zone balance check fails.
>>
>> Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
>> ---
>>  mm/vmscan.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 7682469..11899ff 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3142,11 +3142,11 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>>  		if (!managed_zone(zone))
>>  			continue;
>>  
>> -		if (!zone_balanced(zone, order, classzone_idx))
>> -			return false;
>> +		if (zone_balanced(zone, order, classzone_idx))
>> +			return true;
>>  	}
>>  
>> -	return true;
>> +	return false;

Looks like this restores the logic that was changed by 38087d9b03609
("mm, vmscan: simplify the logic deciding whether kswapd sleeps").
Probably from the same node reclaim series than the commit above.
I'm not sure if this part of commit 38087d9b03609 was intentional
though, as changelog doesn't mention it, and it wasn't there until the
last, v9, posting. In that light the fix looks like the right thing to
do, but maybe Mel can remember what was behind this...

>>  }
>>  
>>  /*
>> -- 
>> 2.7.4
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
