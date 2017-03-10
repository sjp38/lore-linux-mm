Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BCC32808A9
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 04:06:36 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c143so2128192wmd.1
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 01:06:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h26si12056760wrb.231.2017.03.10.01.06.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 01:06:35 -0800 (PST)
Subject: Re: [PATCH 2/3] mm, vmscan: Only clear pgdat
 congested/dirty/writeback state when balanced
References: <20170309075657.25121-1-mgorman@techsingularity.net>
 <20170309075657.25121-3-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <49662531-a35a-3c2a-b04c-af04188d0b42@suse.cz>
Date: Fri, 10 Mar 2017 10:06:34 +0100
MIME-Version: 1.0
In-Reply-To: <20170309075657.25121-3-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 03/09/2017 08:56 AM, Mel Gorman wrote:
> A pgdat tracks if recent reclaim encountered too many dirty, writeback
> or congested pages. The flags control whether kswapd writes pages back
> from reclaim context, tags pages for immediate reclaim when IO completes,
> whether processes block on wait_iff_congested and whether kswapd blocks
> when too many pages marked for immediate reclaim are encountered.
> 
> The state is cleared in a check function with side-effects. With the patch
> "mm, vmscan: fix zone balance check in prepare_kswapd_sleep", the timing
> of when the bits get cleared changed. Due to the way the check works,
> it'll clear the bits if ZONE_DMA is balanced for a GFP_DMA allocation
> because it does not account for lowmem reserves properly.
> 
> For the simoop workload, kswapd is not stalling when it should due to
> the premature clearing, writing pages from reclaim context like crazy and
> generally being unhelpful.
> 
> This patch resets the pgdat bits related to page reclaim only when kswapd
> is going to sleep. The comparison with simoop is then
> 
>                                          4.11.0-rc1            4.11.0-rc1            4.11.0-rc1
>                                             vanilla           fixcheck-v2              clear-v2
> Amean    p50-Read             21670074.18 (  0.00%) 20464344.18 (  5.56%) 19786774.76 (  8.69%)
> Amean    p95-Read             25456267.64 (  0.00%) 25721423.64 ( -1.04%) 24101956.27 (  5.32%)
> Amean    p99-Read             29369064.73 (  0.00%) 30174230.76 ( -2.74%) 27691872.71 (  5.71%)
> Amean    p50-Write                1390.30 (  0.00%)     1395.28 ( -0.36%)     1011.91 ( 27.22%)
> Amean    p95-Write              412901.57 (  0.00%)    37737.74 ( 90.86%)    34874.98 ( 91.55%)
> Amean    p99-Write             6668722.09 (  0.00%)   666489.04 ( 90.01%)   575449.60 ( 91.37%)
> Amean    p50-Allocation          78714.31 (  0.00%)    86286.22 ( -9.62%)    84246.26 ( -7.03%)
> Amean    p95-Allocation         175533.51 (  0.00%)   351812.27 (-100.42%)   400058.43 (-127.91%)
> Amean    p99-Allocation         247003.02 (  0.00%)  6291171.56 (-2447.00%) 10905600.00 (-4315.17%)
> 
> Read latency is improved, write latency is mostly improved but allocation
> latency is regressed.  kswapd is still reclaiming inefficiently,
> pages are being written back from writeback context and a host of other
> issues. However, given the change, it needed to be spelled out why the
> side-effect was moved.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
