Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1AA6B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 09:44:25 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so38645853wml.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 06:44:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uv9si37662842wjc.29.2016.03.01.06.44.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 06:44:24 -0800 (PST)
Subject: Re: [PATCH v2 5/5] mm, compaction: adapt isolation_suitable flushing
 to kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-6-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D5AAC5.9050207@suse.cz>
Date: Tue, 1 Mar 2016 15:44:21 +0100
MIME-Version: 1.0
In-Reply-To: <1454938691-2197-6-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

For consistency with previous patch's updated changelog, here's similar update 
for this one:
http://ozlabs.org/~akpm/mmots/broken-out/mm-compaction-adapt-isolation_suitable-flushing-to-kcompactd.patch

----8<----

Compaction maintains a pageblock_skip bitmap to record pageblocks where
isolation recently failed. This bitmap can be reset by three ways:

1) direct compaction is restarting after going through the full deferred cycle

2) kswapd goes to sleep, and some other direct compaction has previously
    finished scanning the whole zone and set zone->compact_blockskip_flush.
    Note that a successful direct compaction clears this flag.

3) compaction was invoked manually via trigger in /proc

The case 2) is somewhat fuzzy to begin with, but after introducing kcompactd we
should update it. The check for direct compaction in 1), and to set the flush
flag in 2) use current_is_kswapd(), which doesn't work for kcompactd. Thus,
this patch adds bool direct_compaction to compact_control to use in 2). For
the case 1) we remove the check completely - unlike the former kswapd
compaction, kcompactd does use the deferred compaction functionality, so
flushing tied to restarting from deferred compaction makes sense here.

Note that when kswapd goes to sleep, kcompactd is woken up, so it will see the
flushed pageblock_skip bits. This is different from when the former kswapd
compaction observed the bits and I believe it makes more sense. Kcompactd can
afford to be more thorough than a direct compaction trying to limit allocation
latency, or kswapd whose primary goal is to reclaim.

To sum up, after this patch, the pageblock_skip flushing makes intuitively
more sense for kcompactd. Practially, the differences are minimal.
Stress-highalloc With order-9 allocations without direct reclaim/compaction:

stress-highalloc
                        4.5-rc1+before         4.5-rc1+after
                             -nodirect             -nodirect
Success 1 Min          3.00 (  0.00%)        5.00 (-66.67%)
Success 1 Mean         4.00 (  0.00%)        6.20 (-55.00%)
Success 1 Max          6.00 (  0.00%)        7.00 (-16.67%)
Success 2 Min          3.00 (  0.00%)        5.00 (-66.67%)
Success 2 Mean         4.20 (  0.00%)        6.40 (-52.38%)
Success 2 Max          6.00 (  0.00%)        7.00 (-16.67%)
Success 3 Min         63.00 (  0.00%)       62.00 (  1.59%)
Success 3 Mean        64.60 (  0.00%)       63.80 (  1.24%)
Success 3 Max         67.00 (  0.00%)       65.00 (  2.99%)

User                          3088.82       3181.09
System                        1142.01       1158.25
Elapsed                       1780.91       1799.37

                            4.5-rc1+before  4.5-rc1+after
                                 -nodirect   -nodirect
Direct pages scanned                31429       32797
Kswapd pages scanned              2185293     2202613
Kswapd pages reclaimed            2134389     2143524
Direct pages reclaimed              31234       32545
Percentage direct scans                1%          1%
THP fault alloc                       614         612
THP collapse alloc                    324         316
THP splits                              0           0
THP fault fallback                    730         778
THP collapse fail                      14          16
Compaction stalls                     959        1007
Compaction success                     69          67
Compaction failures                   890         939
Page migrate success               662054      721374
Page migrate failure                32846       23469
Compaction pages isolated         1370326     1479924
Compaction migrate scanned        7025772     8812554
Compaction free scanned          73302642    84327916
Compaction cost                       762         838

With direct reclaim/compaction:

stress-highalloc
                        4.5-rc1+before         4.5-rc1+after
                               -direct               -direct
Success 1 Min          6.00 (  0.00%)        9.00 (-50.00%)
Success 1 Mean         8.40 (  0.00%)       10.00 (-19.05%)
Success 1 Max         13.00 (  0.00%)       11.00 ( 15.38%)
Success 2 Min          6.00 (  0.00%)        9.00 (-50.00%)
Success 2 Mean         8.60 (  0.00%)       10.00 (-16.28%)
Success 2 Max         12.00 (  0.00%)       11.00 (  8.33%)
Success 3 Min         75.00 (  0.00%)       74.00 (  1.33%)
Success 3 Mean        75.60 (  0.00%)       75.20 (  0.53%)
Success 3 Max         76.00 (  0.00%)       76.00 (  0.00%)

User                          3258.62       3246.04
System                        1177.92       1172.29
Elapsed                       1837.02       1836.76

                            4.5-rc1+before  4.5-rc1+after
                                   -direct     -direct
Direct pages scanned               108854      120966
Kswapd pages scanned              2131589     2135012
Kswapd pages reclaimed            2090937     2108388
Direct pages reclaimed             108699      120577
Percentage direct scans                4%          5%
THP fault alloc                       567         652
THP collapse alloc                    326         354
THP splits                              0           0
THP fault fallback                    805         793
THP collapse fail                      18          16
Compaction stalls                    2070        2025
Compaction success                    527         518
Compaction failures                  1543        1507
Page migrate success              2423657     2360608
Page migrate failure                28790       40852
Compaction pages isolated         4916017     4802025
Compaction migrate scanned       19370264    21750613
Compaction free scanned         360662356   344372001
Compaction cost                      2745        2694

Singed-off-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
