Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0C11B828F4
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 05:53:50 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id c200so54517830wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 02:53:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6si22345422wmh.51.2016.02.09.02.53.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 02:53:48 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-5-git-send-email-vbabka@suse.cz>
 <20160208145841.c356612c210c95b02863584f@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56B9C539.5010506@suse.cz>
Date: Tue, 9 Feb 2016 11:53:45 +0100
MIME-Version: 1.0
In-Reply-To: <20160208145841.c356612c210c95b02863584f@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On 02/08/2016 11:58 PM, Andrew Morton wrote:
>>
>> For testing, I used stress-highalloc configured to do order-9 allocations with
>> GFP_NOWAIT|__GFP_HIGH|__GFP_COMP, so they relied just on kswapd/kcompactd
>> reclaim/compaction (the interfering kernel builds in phases 1 and 2 work as
>> usual):
>>
>> stress-highalloc
>>                               4.5-rc1               4.5-rc1
>>                                3-test                4-test
> 
> What are "3-test" and "4-test"?  I'm assuming (hoping) they mean
> "before and after this patchset", but the nomenclature is odd.

3 and 4 is the number of patch in series. "test" is the config's name
which I should have rewritten to "nodirect" or someting.

>> Success 1 Min          1.00 (  0.00%)        3.00 (-200.00%)
>> Success 1 Mean         1.40 (  0.00%)        4.00 (-185.71%)
>> Success 1 Max          2.00 (  0.00%)        6.00 (-200.00%)
>> Success 2 Min          1.00 (  0.00%)        3.00 (-200.00%)
>> Success 2 Mean         1.80 (  0.00%)        4.20 (-133.33%)
>> Success 2 Max          3.00 (  0.00%)        6.00 (-100.00%)
>> Success 3 Min         34.00 (  0.00%)       63.00 (-85.29%)
>> Success 3 Mean        41.80 (  0.00%)       64.60 (-54.55%)
>> Success 3 Max         53.00 (  0.00%)       67.00 (-26.42%)
>>
>>              4.5-rc1     4.5-rc1
>>               3-test      4-test
>> User         3166.67     3088.82
>> System       1153.37     1142.01
>> Elapsed      1768.53     1780.91
>>
>>                                   4.5-rc1     4.5-rc1
>>                                    3-test      4-test
>> Minor Faults                    106940795   106582816
>> Major Faults                          829         813
>> Swap Ins                              482         311
>> Swap Outs                            6278        5598
>> Allocation stalls                     128         184
>> DMA allocs                            145          32
>> DMA32 allocs                     74646161    74843238
>> Normal allocs                    26090955    25886668
>> Movable allocs                          0           0
>> Direct pages scanned                32938       31429
>> Kswapd pages scanned              2183166     2185293
>> Kswapd pages reclaimed            2152359     2134389
>> Direct pages reclaimed              32735       31234
>> Kswapd efficiency                     98%         97%
>> Kswapd velocity                  1243.877    1228.666
>> Direct efficiency                     99%         99%
>> Direct velocity                    18.767      17.671
> 
> What do "efficiency" and "velocity" refer to here?

Velocity is scanned pages per second, efficiency is the ratio of
reclaimed pages to scanned pages.

> 
>> Percentage direct scans                1%          1%
>> Zone normal velocity              299.981     291.409
>> Zone dma32 velocity               962.522     954.928
>> Zone dma velocity                   0.142       0.000
>> Page writes by reclaim           6278.800    5598.600
>> Page writes file                        0           0
>> Page writes anon                     6278        5598
>> Page reclaim immediate                 93          96
>> Sector Reads                      4357114     4307161
>> Sector Writes                    11053628    11053091
>> Page rescued immediate                  0           0
>> Slabs scanned                     1592829     1555770
>> Direct inode steals                  1557        2025
>> Kswapd inode steals                 46056       45418
>> Kswapd skipped wait                     0           0
>> THP fault alloc                       579         614
>> THP collapse alloc                    304         324
>> THP splits                              0           0
>> THP fault fallback                    793         730
>> THP collapse fail                      11          14
>> Compaction stalls                    1013         959
>> Compaction success                     92          69
>> Compaction failures                   920         890
>> Page migrate success               238457      662054
>> Page migrate failure                23021       32846
>> Compaction pages isolated          504695     1370326
>> Compaction migrate scanned         661390     7025772
>> Compaction free scanned          13476658    73302642
>> Compaction cost                       262         762
>>
>> After this patch we see improvements in allocation success rate (especially for
>> phase 3) along with increased compaction activity. The compaction stalls
>> (direct compaction) in the interfering kernel builds (probably THP's) also
>> decreased somewhat to kcompactd activity, yet THP alloc successes improved a
>> bit.
>>
>> We can also configure stress-highalloc to perform both direct
>> reclaim/compaction and wakeup kswapd/kcompactd, by using
>> GFP_KERNEL|__GFP_HIGH|__GFP_COMP:
>>
>> stress-highalloc
>>                               4.5-rc1               4.5-rc1
>>                               3-test2               4-test2
>> Success 1 Min          4.00 (  0.00%)        6.00 (-50.00%)
>> Success 1 Mean         8.00 (  0.00%)        8.40 ( -5.00%)
>> Success 1 Max         12.00 (  0.00%)       13.00 ( -8.33%)
>> Success 2 Min          4.00 (  0.00%)        6.00 (-50.00%)
>> Success 2 Mean         8.20 (  0.00%)        8.60 ( -4.88%)
>> Success 2 Max         13.00 (  0.00%)       12.00 (  7.69%)
>> Success 3 Min         75.00 (  0.00%)       75.00 (  0.00%)
>> Success 3 Mean        75.60 (  0.00%)       75.60 (  0.00%)
>> Success 3 Max         77.00 (  0.00%)       76.00 (  1.30%)
>>
>>              4.5-rc1     4.5-rc1
>>              3-test2     4-test2
>> User         3344.73     3258.62
>> System       1194.24     1177.92
>> Elapsed      1838.04     1837.02
> 
> Elapsed time increased in both test runs.

Yeah, elapsed and user isn't so useful for this benchmark, because of
the background interference being unpredictable. It's just to quickly
spot some major unexpected differences. System time is somewhat more
useful and that didn't increase.

> But you later say "There's
> however significant reduction in direct compaction stalls, made
> entirely of the successful stalls".  This seems inconsistent - less
> stalls should mean less time stuck in D state.

In /proc/vmstat terms, compact_stall is when the allocating process goes
to direct compaction, so it doesn't necessarily mean D states.

I've replied to the original patch with some more detailed time data
based on tracepoints, which shows that (wall) time spent in direct
compaction did indeed decrease.

[...]

>> Here, this patch doesn't change the success rate as direct compaction already
>> tries what it can. There's however significant reduction in direct compaction
>> stalls, made entirely of the successful stalls. This means the offload to
>> kcompactd is working as expected, and direct compaction is reduced either due
>> to detecting contention, or compaction deferred by kcompactd. In the previous
>> version of this patchset there was some apparent reduction of success rate,
>> but the changes in this version (such as using sync compaction only), new
>> baseline kernel, and/or averaging results from 5 executions (my bet), made this
>> go away.
>>
> 
> A general thought: are we being as nice as possible to small systems in
> this patchset?  Does a small single-node machine which doesn't even use
> hugepages really need the additional overhead and bloat which we're
> adding?  A system which either doesn't use networking at all or uses
> NICs which never request more than an order-1 page?

Hmm, aren't even kernel stacks larger than order-1 nowadays? Maybe not
on some 32bit arm...

> Maybe the answer there is "turn off compaction".  If so, I wonder if
> we've done all we can to tell the builders of such systems that this is
> what we think they should do.

Frankly, I wouldn't recommend that to anyone, since lumpy reclaim is
gone. But I admit I've never built such system. I hope that kcompactd
doesn't add that much bloat compared to the rest of compaction
infrastructure, it's one thread and some extra variables in struct zone,
which come in fixed low numbers.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
