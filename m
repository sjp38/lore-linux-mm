Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E163E6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 19:16:48 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j13so94242664iod.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 16:16:48 -0800 (PST)
Received: from nm25-vm6.bullet.mail.ne1.yahoo.com (nm25-vm6.bullet.mail.ne1.yahoo.com. [98.138.91.118])
        by mx.google.com with ESMTPS id e3si5784852ith.24.2017.02.06.16.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 16:16:47 -0800 (PST)
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
 <719282122.1183240.1486298780546@mail.yahoo.com>
 <20170206161715.sfz6lm3vmahlnxx6@techsingularity.net>
From: Shantanu Goel <sgoel01@yahoo.com>
Message-ID: <68644e18-ed8d-0559-4ac2-fb3162f6ba67@yahoo.com>
Date: Mon, 6 Feb 2017 19:16:46 -0500
MIME-Version: 1.0
In-Reply-To: <20170206161715.sfz6lm3vmahlnxx6@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

On 02/06/2017 11:17 AM, Mel Gorman wrote:

> On Sun, Feb 05, 2017 at 12:46:20PM +0000, Shantanu Goel wrote:
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
> This should be in the changelog of the patch itself and the patch should
> be inline instead of being an attachment.

Will do and resubmit in a separate email.

>> Thanks,
>> Shantanu
>>  From 46f2e4b02ac263bf50d69cdab3bcbd7bcdea7415 Mon Sep 17 00:00:00 2001
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
>

I see your point.  Perhaps we can introduce a constraint that
ensures the balanced zones constitute say 1/4 or 1/2 of
memory in the classzone?  I believe there used to be such
a constraint at one time for higher order allocations.


Thanks,
Shantanu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
