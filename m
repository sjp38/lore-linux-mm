Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFC36B0388
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 07:30:42 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id s41so84570614ioi.5
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 04:30:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p197si12391430wmg.0.2017.02.20.04.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 04:30:40 -0800 (PST)
Subject: Re: [PATCH v2 00/10] try to reduce fragmenting fallbacks
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170213110701.vb4e6zrwhwliwm7k@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <19bcb38a-5dde-24d5-cf1d-50683d5ef4d9@suse.cz>
Date: Mon, 20 Feb 2017 13:30:33 +0100
MIME-Version: 1.0
In-Reply-To: <20170213110701.vb4e6zrwhwliwm7k@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/13/2017 12:07 PM, Mel Gorman wrote:
> On Fri, Feb 10, 2017 at 06:23:33PM +0100, Vlastimil Babka wrote:
> 
> By and large, I like the series, particularly patches 7 and 8. I cannot
> make up my mind about the RFC patches 9 and 10 yet. Conceptually they
> seem sound but they are much more far reaching than the rest of the
> series.
> 
> It would be nice if patches 1-8 could be treated in isolation with data
> on the number of extfrag events triggered, time spent in compaction and
> the success rate. Patches 9 and 10 are tricy enough that they would need
> data per patch where as patches 1-8 should be ok with data gathered for
> the whole series.
 
Ok let's try again with a fresh subthread after fixing automation and
postprocessing...

I've got the results with mmtests stress-highalloc modified to do
GFP_KERNEL order-4 allocations, on 4.9 with "mm, vmscan: fix zone
balance check in prepare_kswapd_sleep" (without that, kcompactd indeed
wasn't woken up) on UMA machine with 4GB memory. There were 5 repeats of
each run, as the extfrag stats are quite volatile (note the stats below
are sums, not averages, as it was less perl hacking for me).

Success rate are the same, already high due to the low alllocation order used.

                                   patch 1     patch 2     patch 3     patch 4     patch 7     patch 8     patch 9    patch 10
Compaction stalls                    22449       24680       24846       19765       22059       17480       29499       58284
Compaction success                   12971       14836       14608       10475       11632        8757       16697       12544
Compaction failures                   9477        9843       10238        9290       10426        8722       12801       45739
Page migrate success               3109022     3370438     3312164     1695105     1608435     2111379     2445824     3288822
Page migrate failure                911588     1149065     1028264     1112675     1077251     1026367     1014035      398158
Compaction pages isolated          7242983     8015530     7782467     4629063     4402787     5377665     6062703     7180216
Compaction migrate scanned       980838938   987367943   957690188   917647238   947155598  1018922197  1041367620   209082744
Compaction free scanned          557926893   598946443   602236894   594024490   541169699   763651731   827822984   396678647
Compaction cost                      10243       10578       10304        8286        8398        9440        9957        5019

Compaction stats are mostly within noise until patch 4, which decreases the
number of compactions, and migrations. Part of that could be due to more
pageblocks marked as unmovable, and async compaction skipping those. This
changes a bit with patch 7, but not so much. Patch 8 increases free scanner
stats and migrations, which comes from the changed termination criteria.
Interestingly number of compactions decreases - probably the fully compacted
pageblock satisfies multiple subsequent allocations, so it amortizes.
Patch 9 increases compaction attempts as we force them before fallbacks. Success
vs failure rate increases, so it might be worth it.
Patch 10 looks quite bad for compaction - lots of attempt and failures, but
scanner stats went down. I probably need to check if the new migratetype is
considered as suitable for compaction optimally.

Next comes the extfrag tracepoint, where "fragmenting" means that an allocation
had to fallback to a pageblock of another migratetype which wasn't fully free
(which is almost all of the fallbacks). I have locally added another tracepoint
for "Page steal" into steal_suitable_fallback() which triggers in situations
where we are allowed to do move_freepages_block(). If we decide to also do
set_pageblock_migratetype(), it's "Pages steal with pageblock" with break down
for which allocation migratetype we are stealing and from which fallback
migratetype. The last part "due to counting" comes from patch 4 and counts the
events where the counting of movable pages allowed us to change pageblock's
migratetype, while the number of free pages alone wouldn't be enough to cross
the threshold.

                                                     patch 1     patch 2     patch 3     patch 4     patch 7     patch 8     patch 9    patch 10
Page alloc extfrag event                            10155066     8522968    10164959    15622080    13727068    13140319     6584820     2030419
Extfrag fragmenting                                 10149231     8517025    10159040    15616925    13721391    13134792     6579315     2024038
Extfrag fragmenting for unmovable                     159504      168500      184177       97835       70625       56948       50413      166200
Extfrag fragmenting unmovable placed with movable     153613      163549      172693       91740       64099       50917       44845       20256
Extfrag fragmenting unmovable placed with reclaim.      5891        4951       11484        6095        6526        6031        5568       26540
Extfrag fragmenting for reclaimable                     4738        4829        6345        4822        5640        5378        4213        6599
Extfrag fragmenting reclaimable placed with movable     1836        1902        1851        1579        1739        1760        1918         965
Extfrag fragmenting reclaimable placed with unmov.      2902        2927        4494        3243        3901        3618        2295        3867
Extfrag fragmenting for movable                      9984989     8343696     9968518    15514268    13645126    13072466     6524689     1851239
Pages steal                                           179954      192291      210880      123254       94545       81486       72717     2024038
Pages steal with pageblock                             22153       18943       20154       33562       29969       33444       32871     1572912
Pages steal with pageblock for unmovable               14350       12858       13256       20660       19003       20852       20265       21010
Pages steal with pageblock for unmovable from mov.     12812       11402       11683       19072       17467       19298       18791        5271
Pages steal with pageblock for unmovable from recl.     1538        1456        1573        1588        1536        1554        1474        1421
Pages steal with pageblock for movable                  7114        5489        5965       11787       10012       11493       11586     1550723
Pages steal with pageblock for movable from unmov.      6885        5291        5541       11179        9525       10885       10874       29787
Pages steal with pageblock for movable from recl.        229         198         424         608         487         608         712        1190
Pages steal with pageblock for reclaimable               689         596         933        1115         954        1099        1020        1179
Pages steal with pageblock for reclaimable from unmov.   273         219         537         658         547         667         584         629
Pages steal with pageblock for reclaimable from mov.     416         377         396         457         407         432         436         324
Pages steal with pageblock due to counting                                                 11834       10075        7530        6927     1381357
... for unmovable                                                                           8993        7381        4616        3863         344
... for movable                                                                             2792        2653        2851        2972     1380981
... for reclaimable                                                                           49          41          63          92          32


What we can see is that "Extfrag fragmenting for unmovable" and "... placed with
movable" drops with almost each patch, which is good as we are polluting less
movable pageblocks with unmovable pages.
The most significant change is patch 4 with movable page counting. On the other
hand it increases "Extfrag fragmenting for movable" by 50%. "Pages steal" drops
though, so these movable allocation fallbacks find only small free pages and are
not allowed to steal whole pageblocks back. "Pages steal with pageblock" raises,
because the patch increases the chances of pageblock migratetype changes to
happen. This affects all migratetypes.
The summary is that patch 4 is not a clear win wrt these stats, but I believe
that the tradeoff it makes is a good one. There's less pollution of movable
pageblocks by unmovable allocations. There's less stealing between pageblock,
and those that remain have higher chance of changing migratetype also the
pageblock itself, so it should more faithfully reflect the migratetype of the
pages within the pageblock. The increase of movable allocations falling back to
unmovable pageblock might look dramatic, but those allocations can be migrated
by compaction when needed, and other patches in the series (7-9) improve that
aspect.
Patches 7 and 8 continue the trend of reduced unmovable fallbacks and also
reduce the impact on movable fallbacks from patch 4.
Same for patch 9, which also reduces the movable fallbacks to half. It's not
completely clear to me why. Perhaps the more aggressive compaction of unmovable
blocks results in unmovable allocations (such as those GFP_KERNEL ones from the
workload) fitting within less blocks, and thus reclaim has higher changes of
freeing the LRU pages within movable blocks, and new movable allocations don't
have to fallback that much.
Patch 10 kills all the improvements to "Pages steal with pageblock" so I'll have
to investigate.

To sum up, patches 1-8 look OK to me. Patch 9 looks also very promising, but
there's danger of increased allocation latencies due to the forced compaction.
Patch 10 has either implementation bugs or there's some unforeseen consequence
of its design.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
