Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 62A336B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 09:18:46 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so15978526wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 06:18:45 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id o7si8438163wjq.49.2015.08.20.06.18.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 06:18:45 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so36067855wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 06:18:44 -0700 (PDT)
Date: Thu, 20 Aug 2015 15:18:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 01/10] mm, page_alloc: Delete the zonelist_cache
Message-ID: <20150820131842.GH20110@dhcp22.suse.cz>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439376335-17895-2-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 12-08-15 11:45:26, Mel Gorman wrote:
[...]
> 4-node machine stutter
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

Do you have data for other leads? Because the reclaim counters look
quite discouraging to be honest.

>                                  4.1.0       4.1.0
>                                vanilla  nozlc-v1r4
> Swap Ins                           838         502
> Swap Outs                      1149395     2622895

Twice as much swapouts is a lot.

> DMA32 allocs                  17839113    15863747
> Normal allocs                129045707   137847920
> Direct pages scanned           4070089    29046893

7x more scanns by direct reclaim also sounds bad.

> Kswapd pages scanned          17147837    17140694

while kswapd is doing the same amount of work so we are moving
considerable amount of reclaim activity into the direct reclaim

> Kswapd pages reclaimed        17146691    17139601
> Direct pages reclaimed         1888879     4886630
> Kswapd efficiency                  99%         99%
> Kswapd velocity              17523.721   17518.928
> Direct efficiency                  46%         16%

which is just a wasted effort because the efficiency is really poor.
Is this the effect of hammering a single zone which would be skipped
otherwise while the allocation would succed from another zone?

The latencies were not very much higher to match these numbers though.
Is it possible that other parts of the benchmark suffered? The benchmark
has measured only mmap part AFAIU.

> Direct velocity               4159.306   29687.854
> Percentage direct scans            19%         62%
> Page writes by reclaim     1149395.000 2622895.000
> Page writes file                     0           0
> Page writes anon               1149395     2622895
> 
> The direct page scan and reclaim rates are noticeable. It is possible
> this will not be a universal win on all workloads but cycling through
> zonelists waiting for zlc->last_full_zap to expire is not the right
> decision.

As much as I would like to see zlc go it seems that it won't be that
easy without regressing some loads. Or the numbers
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
