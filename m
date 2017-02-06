Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6374E6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 11:17:17 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id i10so1312234wrb.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 08:17:17 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id a17si8616459wma.129.2017.02.06.08.17.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 08:17:16 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 9482A98B6C
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 16:17:15 +0000 (UTC)
Date: Mon, 6 Feb 2017 16:17:15 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
Message-ID: <20170206161715.sfz6lm3vmahlnxx6@techsingularity.net>
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
 <719282122.1183240.1486298780546@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <719282122.1183240.1486298780546@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Feb 05, 2017 at 12:46:20PM +0000, Shantanu Goel wrote:
> 
> On 4.9.7 kswapd is failing to wake up kcompactd due to a mismatch in the zone balance check between balance_pgdat() and prepare_kswapd_sleep().  balance_pgdat() returns as soon as a single zone satisfies the allocation but prepare_kswapd_sleep() requires all zones to do the same.  This causes prepare_kswapd_sleep() to never succeed except in the order == 0 case and consequently, wakeup_kcompactd() is never called.  On my machine prior to apply this patch, the state of compaction from /proc/vmstat looked this way after a day and a half of uptime:
> 
> compact_migrate_scanned 240496
> compact_free_scanned 76238632
> compact_isolated 123472
> compact_stall 1791
> compact_fail 29
> compact_success 1762
> compact_daemon_wake 0
> 
> 
> After applying the patch and about 10 hours of uptime the state looks like this:
> 
> compact_migrate_scanned 59927299
> compact_free_scanned 2021075136
> compact_isolated 640926
> compact_stall 4
> compact_fail 2
> compact_success 2
> compact_daemon_wake 5160
> 

This should be in the changelog of the patch itself and the patch should
be inline instead of being an attachment.

> 
> Thanks,
> Shantanu

> From 46f2e4b02ac263bf50d69cdab3bcbd7bcdea7415 Mon Sep 17 00:00:00 2001
> From: Shantanu Goel <sgoel01@yahoo.com>
> Date: Sat, 4 Feb 2017 19:07:53 -0500
> Subject: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
> 
> The check in prepare_kswapd_sleep needs to match the one in balance_pgdat
> since the latter will return as soon as any one of the zones in the
> classzone is above the watermark.  This is specially important for
> higher order allocations since balance_pgdat will typically reset
> the order to zero relying on compaction to create the higher order
> pages.  Without this patch, prepare_kswapd_sleep fails to wake up
> kcompactd since the zone balance check fails.
> 
> Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>

I don't recall specifically why I made that change but I've no objections
to the patch so;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

However, note that there is a slight risk that kswapd will sleep for a
short interval early due to a very small zone such as ZONE_DMA. If this
is a general problem then it'll manifest as less kswapd reclaim and more
direct reclaim. If it turns out this is an issue then a revert will not
be the right fix. Instead, all the checks for zone_balance will need to
account for the only balanced zone being a tiny percentage of memory in
the node.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
