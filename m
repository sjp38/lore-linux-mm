Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFC4C6B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 12:43:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so20736861wmi.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:43:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si1756408wrc.130.2017.02.06.09.43.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 09:43:11 -0800 (PST)
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
 <719282122.1183240.1486298780546@mail.yahoo.com>
 <20170206161715.sfz6lm3vmahlnxx6@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3a10b870-2dd6-74c2-75c8-92823e2ba4e1@suse.cz>
Date: Mon, 6 Feb 2017 18:43:08 +0100
MIME-Version: 1.0
In-Reply-To: <20170206161715.sfz6lm3vmahlnxx6@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/06/2017 05:17 PM, Mel Gorman wrote:

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
>> classzone is above the watermark.  This is specially important for
>> higher order allocations since balance_pgdat will typically reset
>> the order to zero relying on compaction to create the higher order
>> pages.  Without this patch, prepare_kswapd_sleep fails to wake up
>> kcompactd since the zone balance check fails.
>>
>> Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
>
> I don't recall specifically why I made that change but I've no objections
> to the patch so;
>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
>
> However, note that there is a slight risk that kswapd will sleep for a
> short interval early due to a very small zone such as ZONE_DMA. If this
> is a general problem then it'll manifest as less kswapd reclaim and more
> direct reclaim. If it turns out this is an issue then a revert will not
> be the right fix. Instead, all the checks for zone_balance will need to
> account for the only balanced zone being a tiny percentage of memory in
> the node.

Hopefully the lowmem reserves should take care of this in that case? They easily 
make a low zone inaccessible even when fully free. Unless the small zone is high 
one though, such as Normal zone on system with only 4GB memory, so most of it is 
in DMA32.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
