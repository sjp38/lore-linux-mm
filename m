Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id B0DB2828EE
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 08:57:51 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id fz5so66751339obc.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 05:57:51 -0800 (PST)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id e8si8910771oek.62.2016.03.02.05.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 05:57:50 -0800 (PST)
Received: by mail-ob0-x22e.google.com with SMTP id rt7so26468960obb.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 05:57:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D6BACB.7060005@suse.cz>
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
	<1454938691-2197-5-git-send-email-vbabka@suse.cz>
	<20160302063322.GB32695@js1304-P5Q-DELUXE>
	<56D6BACB.7060005@suse.cz>
Date: Wed, 2 Mar 2016 22:57:50 +0900
Message-ID: <CAAmzW4PHAsMvifgV2FpS_FYE78_PzDtADvoBY67usc_9-D4Hjg@mail.gmail.com>
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

2016-03-02 19:04 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 03/02/2016 07:33 AM, Joonsoo Kim wrote:
>>>
>>>
>>>                                    4.5-rc1     4.5-rc1
>>>                                     3-test      4-test
>>> Minor Faults                    106940795   106582816
>>> Major Faults                          829         813
>>> Swap Ins                              482         311
>>> Swap Outs                            6278        5598
>>> Allocation stalls                     128         184
>>> DMA allocs                            145          32
>>> DMA32 allocs                     74646161    74843238
>>> Normal allocs                    26090955    25886668
>>> Movable allocs                          0           0
>>> Direct pages scanned                32938       31429
>>> Kswapd pages scanned              2183166     2185293
>>> Kswapd pages reclaimed            2152359     2134389
>>> Direct pages reclaimed              32735       31234
>>> Kswapd efficiency                     98%         97%
>>> Kswapd velocity                  1243.877    1228.666
>>> Direct efficiency                     99%         99%
>>> Direct velocity                    18.767      17.671
>>> Percentage direct scans                1%          1%
>>> Zone normal velocity              299.981     291.409
>>> Zone dma32 velocity               962.522     954.928
>>> Zone dma velocity                   0.142       0.000
>>> Page writes by reclaim           6278.800    5598.600
>>> Page writes file                        0           0
>>> Page writes anon                     6278        5598
>>> Page reclaim immediate                 93          96
>>> Sector Reads                      4357114     4307161
>>> Sector Writes                    11053628    11053091
>>> Page rescued immediate                  0           0
>>> Slabs scanned                     1592829     1555770
>>> Direct inode steals                  1557        2025
>>> Kswapd inode steals                 46056       45418
>>> Kswapd skipped wait                     0           0
>>> THP fault alloc                       579         614
>>> THP collapse alloc                    304         324
>>> THP splits                              0           0
>>> THP fault fallback                    793         730
>>> THP collapse fail                      11          14
>>> Compaction stalls                    1013         959
>>> Compaction success                     92          69
>>> Compaction failures                   920         890
>>> Page migrate success               238457      662054
>>> Page migrate failure                23021       32846
>>> Compaction pages isolated          504695     1370326
>>> Compaction migrate scanned         661390     7025772
>>> Compaction free scanned          13476658    73302642
>>> Compaction cost                       262         762
>>>
>>> After this patch we see improvements in allocation success rate
>>> (especially for
>>> phase 3) along with increased compaction activity. The compaction stalls
>>> (direct compaction) in the interfering kernel builds (probably THP's)
>>> also
>>> decreased somewhat to kcompactd activity, yet THP alloc successes
>>> improved a
>>> bit.
>>
>>
>> Why you did the test with THP? THP interferes result of main test so
>> it would be better not to enable it.
>
>
> Hmm I've always left it enabled. It makes for a more realistic interference
> and would also show unintended regressions in that closely related area.

But, it makes review hard because complex analysis is needed to
understand the result.

Following is the example.

"The compaction stalls
(direct compaction) in the interfering kernel builds (probably THP's) also
decreased somewhat to kcompactd activity, yet THP alloc successes improved a
bit."

So, why do we need this comment to understand effect of this patch? If you did
a test without THP, it would not be necessary.

>> And, this patch increased compaction activity (10 times for migrate
>> scanned)
>> may be due to resetting skip block information.
>
>
> Note that kswapd compaction activity was completely non-existent for reasons
> outlined in the changelog.
>> Isn't is better to disable it
>> for this patch to work as similar as possible that kswapd does and
>> re-enable it
>> on next patch? If something goes bad, it can simply be reverted.
>>
>> Look like it is even not mentioned in the description.
>
>
> Yeah skip block information is discussed in the next patch, which mentions
> that it's being reset and why. I think it makes more sense, as when kswapd

Yes, I know.
What I'd like to say here is that you need to care current_is_kswapd() in
this patch. This patch unintentionally change the back ground compaction thread
behaviour to restart compaction by every 64 trials because calling
curret_is_kswapd()
by kcompactd would return false and is treated as direct reclaim.
Result of patch 4
and patch 5 would be same.

Thanks.

> reclaims from low watermark to high, potentially many pageblocks have new
> free pages and the skip bits are obsolete. Next, kcompactd is separate
> thread, so it doesn't stall allocations (or kswapd reclaim) by its activity.
> Personally I hope that one day we can get rid of the skip bits completely.
> They can make the stats look apparently nicer, but I think their effect is
> nearly random.
>
>>> @@ -3066,8 +3071,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat,
>>> int order, long remaining,
>>>    */
>>>   static bool kswapd_shrink_zone(struct zone *zone,
>>>                                int classzone_idx,
>>> -                              struct scan_control *sc,
>>> -                              unsigned long *nr_attempted)
>>> +                              struct scan_control *sc)
>>>   {
>>>         int testorder = sc->order;
>>
>>
>> You can remove testorder completely.
>
>
> Hm right, thanks.
>
>>> -static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>>> -                                                       int
>>> *classzone_idx)
>>> +static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>>>   {
>>>         int i;
>>>         int end_zone = 0;       /* Inclusive.  0 = ZONE_DMA */
>>> @@ -3166,9 +3155,7 @@ static unsigned long balance_pgdat(pg_data_t
>>> *pgdat, int order,
>>>         count_vm_event(PAGEOUTRUN);
>>>
>>>         do {
>>> -               unsigned long nr_attempted = 0;
>>>                 bool raise_priority = true;
>>> -               bool pgdat_needs_compaction = (order > 0);
>>>
>>>                 sc.nr_reclaimed = 0;
>>>
>>> @@ -3203,7 +3190,7 @@ static unsigned long balance_pgdat(pg_data_t
>>> *pgdat, int order,
>>>                                 break;
>>>                         }
>>>
>>> -                       if (!zone_balanced(zone, order, 0, 0)) {
>>> +                       if (!zone_balanced(zone, order, true, 0, 0)) {
>>
>>
>> Should we use highorder = true? We eventually skip to reclaim in the
>> kswapd_shrink_zone() when zone_balanced(,,false,,) is true.
>
>
> Hmm right. I probably thought that the value of end_zone ->
> balanced_classzone_idx would be important when waking kcompactd, but it's
> not used, so it's causing just some wasted CPU cycles.
>
> Thanks for the reviews!
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
