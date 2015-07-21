Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BEACC6B0038
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:47:38 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so128182298pdr.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:47:38 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ld2si12543466pab.233.2015.07.21.16.47.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:47:37 -0700 (PDT)
Received: by pacan13 with SMTP id an13so129246019pac.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:47:37 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:47:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/10] mm, page_alloc: Delete the zonelist_cache
In-Reply-To: <1437379219-9160-2-git-send-email-mgorman@suse.com>
Message-ID: <alpine.DEB.2.10.1507211640480.12650@chino.kir.corp.google.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com> <1437379219-9160-2-git-send-email-mgorman@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, 20 Jul 2015, Mel Gorman wrote:

> From: Mel Gorman <mgorman@suse.de>
> 
> The zonelist cache (zlc) was introduced to skip over zones that were
> recently known to be full. At the time the paths it bypassed were the
> cpuset checks, the watermark calculations and zone_reclaim. The situation
> today is different and the complexity of zlc is harder to justify.
> 
> 1) The cpuset checks are no-ops unless a cpuset is active and in general are
>    a lot cheaper.
> 
> 2) zone_reclaim is now disabled by default and I suspect that was a large
>    source of the cost that zlc wanted to avoid. When it is enabled, it's
>    known to be a major source of stalling when nodes fill up and it's
>    unwise to hit every other user with the overhead.
> 
> 3) Watermark checks are expensive to calculate for high-order
>    allocation requests. Later patches in this series will reduce the cost of
>    the watermark checking.
> 
> 4) The most important issue is that in the current implementation it
>    is possible for a failed THP allocation to mark a zone full for order-0
>    allocations and cause a fallback to remote nodes.
> 
> The last issue could be addressed with additional complexity but it's
> not clear that we need zlc at all so this patch deletes it. If stalls
> due to repeated zone_reclaim are ever reported as an issue then we should
> introduce deferring logic based on a timeout inside zone_reclaim itself
> and leave the page allocator fast paths alone.
> 
> Impact on page-allocator microbenchmarks is negligible as they don't hit
> the paths where the zlc comes into play. The impact was noticable in
> a workload called "stutter". One part uses a lot of anonymous memory,
> a second measures mmap latency and a third copies a large file. In an
> ideal world the latency application would not notice the mmap latency.
> On a 4-node machine the results of this patch are
> 
> 4-node machine stutter
>                              4.2.0-rc1             4.2.0-rc1
>                                vanilla           nozlc-v1r20
> Min         mmap     53.9902 (  0.00%)     49.3629 (  8.57%)
> 1st-qrtle   mmap     54.6776 (  0.00%)     54.1201 (  1.02%)
> 2nd-qrtle   mmap     54.9242 (  0.00%)     54.5961 (  0.60%)
> 3rd-qrtle   mmap     55.1817 (  0.00%)     54.9338 (  0.45%)
> Max-90%     mmap     55.3952 (  0.00%)     55.3929 (  0.00%)
> Max-93%     mmap     55.4766 (  0.00%)     57.5712 ( -3.78%)
> Max-95%     mmap     55.5522 (  0.00%)     57.8376 ( -4.11%)
> Max-99%     mmap     55.7938 (  0.00%)     63.6180 (-14.02%)
> Max         mmap   6344.0292 (  0.00%)     67.2477 ( 98.94%)
> Mean        mmap     57.3732 (  0.00%)     54.5680 (  4.89%)
> 
> Note the maximum stall latency which was 6 seconds and becomes 67ms with
> this patch applied. However, also note that it is not guaranteed this
> benchmark always hits pathelogical cases and the milage varies. There is
> a secondary impact with more direct reclaim because zones are now being
> considered instead of being skipped by zlc.
> 
>                                  4.1.0       4.1.0
>                                vanilla  nozlc-v1r4
> Swap Ins                           838         502
> Swap Outs                      1149395     2622895
> DMA32 allocs                  17839113    15863747
> Normal allocs                129045707   137847920
> Direct pages scanned           4070089    29046893
> Kswapd pages scanned          17147837    17140694
> Kswapd pages reclaimed        17146691    17139601
> Direct pages reclaimed         1888879     4886630
> Kswapd efficiency                  99%         99%
> Kswapd velocity              17523.721   17518.928
> Direct efficiency                  46%         16%
> Direct velocity               4159.306   29687.854
> Percentage direct scans            19%         62%
> Page writes by reclaim     1149395.000 2622895.000
> Page writes file                     0           0
> Page writes anon               1149395     2622895
> 
> The direct page scan and reclaim rates are noticable. It is possible
> this will not be a universal win on all workloads but cycling through
> zonelists waiting for zlc->last_full_zap to expire is not the right
> decision.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

I don't use a config that uses cpusets to restrict memory allocation 
anymore, but it'd be interesting to see the impact that the spinlock and 
cpuset hierarchy scan has for non-hardwalled allocations.

This removed the #define MAX_ZONELISTS 1 for UMA configs, which will cause 
build errors, but once that's fixed:

	Acked-by: David Rientjes <rientjes@google.com>

I'm glad to see this go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
