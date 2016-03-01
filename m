Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDA26B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 09:14:42 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so38860714wml.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 06:14:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d84si25735678wmc.17.2016.03.01.06.14.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 06:14:40 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-5-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D5A3CD.3050405@suse.cz>
Date: Tue, 1 Mar 2016 15:14:37 +0100
MIME-Version: 1.0
In-Reply-To: <1454938691-2197-5-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi Andrew,

here's updated changelog for the patch in mmotm

http://ozlabs.org/~akpm/mmots/broken-out/mm-kswapd-replace-kswapd-compaction-with-waking-up-kcompactd.patch

to reflect your earlier questions and my replies. I've named the result columns 
better, dropped stats that were not relevant, and included the ftrace-based times.

----8<----

Similarly to direct reclaim/compaction, kswapd attempts to combine reclaim and
compaction to attempt making memory allocation of given order available. The
details differ from direct reclaim e.g. in having high watermark as a goal.
The code involved in kswapd's reclaim/compaction decisions has evolved to be
quite complex. Testing reveals that it doesn't actually work in at least one
scenario, and closer inspection suggests that it could be greatly simplified
without compromising on the goal (make high-order page available) or efficiency
(don't reclaim too much). The simplification relieas of doing all compaction in
kcompactd, which is simply woken up when high watermarks are reached by
kswapd's reclaim.

The scenario where kswapd compaction doesn't work was found with mmtests test
stress-highalloc configured to attempt order-9 allocations without direct
reclaim, just waking up kswapd. There was no compaction attempt from kswapd
during the whole test. Some added instrumentation shows what happens:

- balance_pgdat() sets end_zone to Normal, as it's not balanced
- reclaim is attempted on DMA zone, which sets nr_attempted to 99, but it
   cannot reclaim anything, so sc.nr_reclaimed is 0
- for zones DMA32 and Normal, kswapd_shrink_zone uses testorder=0, so it
   merely checks if high watermarks were reached for base pages. This is true,
   so no reclaim is attempted. For DMA, testorder=0 wasn't used, as
   compaction_suitable() returned COMPACT_SKIPPED
- even though the pgdat_needs_compaction flag wasn't set to false, no
   compaction happens due to the condition sc.nr_reclaimed > nr_attempted
   being false (as 0 < 99)
- priority-- due to nr_reclaimed being 0, repeat until priority reaches 0
   pgdat_balanced() is false as only the small zone DMA appears balanced
   (curiously in that check, watermark appears OK and compaction_suitable()
   returns COMPACT_PARTIAL, because a lower classzone_idx is used there)

Now, even if it was decided that reclaim shouldn't be attempted on the DMA
zone, the scenario would be the same, as (sc.nr_reclaimed=0 > nr_attempted=0)
is also false. The condition really should use >= as the comment suggests.
Then there is a mismatch in the check for setting pgdat_needs_compaction to
false using low watermark, while the rest uses high watermark, and who knows
what other subtlety. Hopefully this demonstrates that this is unsustainable.

Luckily we can simplify this a lot. The reclaim/compaction decisions make
sense for direct reclaim scenario, but in kswapd, our primary goal is to reach
high watermark in order-0 pages. Afterwards we can attempt compaction just
once. Unlike direct reclaim, we don't reclaim extra pages (over the high
watermark), the current code already disallows it for good reasons.

After this patch, we simply wake up kcompactd to process the pgdat, after we
have either succeeded or failed to reach the high watermarks in kswapd, which
goes to sleep. We pass kswapd's order and classzone_idx, so kcompactd can apply
the same criteria to determine which zones are worth compacting. Note that we
use the classzone_idx from wakeup_kswapd(), not balanced_classzone_idx which
can include higher zones that kswapd tried to balance too, but didn't consider
them in pgdat_balanced().

Since kswapd now cannot create high-order pages itself, we need to adjust how
it determines the zones to be balanced. The key element here is adding a
"highorder" parameter to zone_balanced, which, when set to false, makes it
consider only order-0 watermark instead of the desired higher order (this was
done previously by kswapd_shrink_zone(), but not elsewhere).  This false is
passed for example in pgdat_balanced(). Importantly, wakeup_kswapd() uses true
to make sure kswapd and thus kcompactd are woken up for a high-order allocation
failure.

For testing, I used stress-highalloc configured to do order-9 allocations with
GFP_NOWAIT|__GFP_HIGH|__GFP_COMP, so they relied just on kswapd/kcompactd
reclaim/compaction (the interfering kernel builds in phases 1 and 2 work as
usual):

stress-highalloc
                        4.5-rc1+before          4.5-rc1+after
                             -nodirect              -nodirect
Success 1 Min          1.00 (  0.00%)        3.00 (-200.00%)
Success 1 Mean         1.40 (  0.00%)        4.00 (-185.71%)
Success 1 Max          2.00 (  0.00%)        6.00 (-200.00%)
Success 2 Min          1.00 (  0.00%)        3.00 (-200.00%)
Success 2 Mean         1.80 (  0.00%)        4.20 (-133.33%)
Success 2 Max          3.00 (  0.00%)        6.00 (-100.00%)
Success 3 Min         34.00 (  0.00%)       63.00 (-85.29%)
Success 3 Mean        41.80 (  0.00%)       64.60 (-54.55%)
Success 3 Max         53.00 (  0.00%)       67.00 (-26.42%)

User                          3166.67       3088.82
System                        1153.37       1142.01
Elapsed                       1768.53       1780.91

                            4.5-rc1+before  4.5-rc1+after
                                 -nodirect   -nodirect
Direct pages scanned                32938       31429
Kswapd pages scanned              2183166     2185293
Kswapd pages reclaimed            2152359     2134389
Direct pages reclaimed              32735       31234
Percentage direct scans                1%          1%
THP fault alloc                       579         614
THP collapse alloc                    304         324
THP splits                              0           0
THP fault fallback                    793         730
THP collapse fail                      11          14
Compaction stalls                    1013         959
Compaction success                     92          69
Compaction failures                   920         890
Page migrate success               238457      662054
Page migrate failure                23021       32846
Compaction pages isolated          504695     1370326
Compaction migrate scanned         661390     7025772
Compaction free scanned          13476658    73302642
Compaction cost                       262         762

After this patch we see improvements in allocation success rate (especially for
phase 3) along with increased compaction activity. The compaction stalls
(direct compaction) in the interfering kernel builds (probably THP's) also
decreased somewhat thanks to kcompactd activity, yet THP alloc successes
improved a bit.

Note that elapsed and user time isn't so useful for this benchmark, because of
the background interference being unpredictable. It's just to quickly spot some
major unexpected differences. System time is somewhat more useful and that
didn't increase.

Also (after adjusting mmtests' ftrace monitor):

Time kswapd awake               2547781     2269241
Time kcompactd awake                  0      119253
Time direct compacting           939937      557649
Time kswapd compacting                0           0
Time kcompactd compacting             0      119099

The decrease of overal time spent compacting appears to not match the increased
compaction stats. I suspect the tasks get rescheduled and since the ftrace
monitor doesn't see that, the reported time is wall time, not CPU time. But
arguably direct compactors care about overall latency anyway, whether busy
compacting or waiting for CPU doesn't matter. And that latency seems to almost
halved.

It's also interesting how much time kswapd spent awake just going through all
the priorities and failing to even try compacting, over and over.

We can also configure stress-highalloc to perform both direct
reclaim/compaction and wakeup kswapd/kcompactd, by using
GFP_KERNEL|__GFP_HIGH|__GFP_COMP:

stress-highalloc
                        4.5-rc1+before         4.5-rc1+after
                               -direct               -direct
Success 1 Min          4.00 (  0.00%)        6.00 (-50.00%)
Success 1 Mean         8.00 (  0.00%)        8.40 ( -5.00%)
Success 1 Max         12.00 (  0.00%)       13.00 ( -8.33%)
Success 2 Min          4.00 (  0.00%)        6.00 (-50.00%)
Success 2 Mean         8.20 (  0.00%)        8.60 ( -4.88%)
Success 2 Max         13.00 (  0.00%)       12.00 (  7.69%)
Success 3 Min         75.00 (  0.00%)       75.00 (  0.00%)
Success 3 Mean        75.60 (  0.00%)       75.60 (  0.00%)
Success 3 Max         77.00 (  0.00%)       76.00 (  1.30%)

User                          3344.73       3258.62
System                        1194.24       1177.92
Elapsed                       1838.04       1837.02

                            4.5-rc1+before  4.5-rc1+after
                                   -direct     -direct
Direct pages scanned               125146      108854
Kswapd pages scanned              2119757     2131589
Kswapd pages reclaimed            2073183     2090937
Direct pages reclaimed             124909      108699
Percentage direct scans                5%          4%
THP fault alloc                       599         567
THP collapse alloc                    323         326
THP splits                              0           0
THP fault fallback                    806         805
THP collapse fail                      17          18
Compaction stalls                    2457        2070
Compaction success                    906         527
Compaction failures                  1551        1543
Page migrate success              2031423     2423657
Page migrate failure                32845       28790
Compaction pages isolated         4129761     4916017
Compaction migrate scanned       11996712    19370264
Compaction free scanned         214970969   360662356
Compaction cost                      2271        2745

In this scenario, this patch doesn't change the overal success rate as direct
compaction already tries all it can. There's however significant reduction in
direct compaction stalls (that is, the number of allocations that went into
direct compaction).  The number of successes (i.e. direct compaction stalls
that ended up with successful allocation) is reduced by the same number. This
means the offload to kcompactd is working as expected, and direct compaction is
reduced either due to detecting contention, or compaction deferred by
kcompactd. In the previous version of this patchset there was some apparent
reduction of success rate, but the changes in this version (such as using sync
compaction only), new baseline kernel, and/or averaging results from 5
executions (my bet), made this go away.

Ftrace-based stats seem to roughly agree:

Time kswapd awake               2532984     2326824
Time kcompactd awake                  0      257916
Time direct compacting           864839      735130
Time kswapd compacting                0           0
Time kcompactd compacting             0      257585

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
