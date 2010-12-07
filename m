Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF6F6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 04:49:28 -0500 (EST)
Date: Tue, 7 Dec 2010 09:49:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/5] mm: kswapd: Stop high-order balancing when any
	suitable zone is balanced
Message-ID: <20101207094905.GA5422@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie> <1291376734-30202-2-git-send-email-mel@csn.ul.ie> <AANLkTi=ZXBXS2m0WCTNWT1t6EFi=Vji5t-yQG=fTJQgs@mail.gmail.com> <20101206105558.GA21406@csn.ul.ie> <AANLkTimvmbvZ-9RcLsefTqbq1ktm6=-XD1N6z4JHBh=v@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimvmbvZ-9RcLsefTqbq1ktm6=-XD1N6z4JHBh=v@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 07, 2010 at 10:32:45AM +0900, Minchan Kim wrote:
> On Mon, Dec 6, 2010 at 7:55 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Mon, Dec 06, 2010 at 08:35:18AM +0900, Minchan Kim wrote:
> >> Hi Mel,
> >>
> >> On Fri, Dec 3, 2010 at 8:45 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> >> > When the allocator enters its slow path, kswapd is woken up to balance the
> >> > node. It continues working until all zones within the node are balanced. For
> >> > order-0 allocations, this makes perfect sense but for higher orders it can
> >> > have unintended side-effects. If the zone sizes are imbalanced, kswapd may
> >> > reclaim heavily within a smaller zone discarding an excessive number of
> >> > pages. The user-visible behaviour is that kswapd is awake and reclaiming
> >> > even though plenty of pages are free from a suitable zone.
> >> >
> >> > This patch alters the "balance" logic for high-order reclaim allowing kswapd
> >> > to stop if any suitable zone becomes balanced to reduce the number of pages
> >> > it reclaims from other zones. kswapd still tries to ensure that order-0
> >> > watermarks for all zones are met before sleeping.
> >> >
> >> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >>
> >> <snip>
> >>
> >> > -       if (!all_zones_ok) {
> >> > +       if (!(all_zones_ok || (order && any_zone_ok))) {
> >> >                cond_resched();
> >> >
> >> >                try_to_freeze();
> >> > @@ -2361,6 +2366,31 @@ out:
> >> >                goto loop_again;
> >> >        }
> >> >
> >> > +       /*
> >> > +        * If kswapd was reclaiming at a higher order, it has the option of
> >> > +        * sleeping without all zones being balanced. Before it does, it must
> >> > +        * ensure that the watermarks for order-0 on *all* zones are met and
> >> > +        * that the congestion flags are cleared
> >> > +        */
> >> > +       if (order) {
> >> > +               for (i = 0; i <= end_zone; i++) {
> >> > +                       struct zone *zone = pgdat->node_zones + i;
> >> > +
> >> > +                       if (!populated_zone(zone))
> >> > +                               continue;
> >> > +
> >> > +                       if (zone->all_unreclaimable && priority != DEF_PRIORITY)
> >> > +                               continue;
> >> > +
> >> > +                       zone_clear_flag(zone, ZONE_CONGESTED);
> >>
> >> Why clear ZONE_CONGESTED?
> >> If you have a cause, please, write down the comment.
> >>
> >
> > It's because kswapd is the only mechanism that clears the congestion
> > flag. If it's not cleared and kswapd goes to sleep, the flag could be
> > left set causing hard-to-diagnose stalls. I'll add a comment.
> 
> Seems good.
> 

Ok.

> >
> >> <snip>
> >>
> >> First impression on this patch is that it changes scanning behavior as
> >> well as reclaiming on high order reclaim.
> >
> > It does affect scanning behaviour for high-order reclaim. Specifically,
> > it may stop scanning once a zone is balanced within the node. Previously
> > it would continue scanning until all zones were balanced. Is this what
> > you are thinking of or something else?
> 
> Yes. I mean page aging of high zones.
> 

When high-order node balancing is finished (aging zones as before), a
check is made to ensure that all zones are balanced for order-0. If not,
kswapd stays awake continueing to age zones as before. Zones will not age
as aggressively now that high-order balancing finishes but as part of the
bug report is too many pages being freed by kswapd, this is a good thing.

> >
> >> I can't say old behavior is right but we can't say this behavior is
> >> right, too although this patch solves the problem. At least, we might
> >> need some data that shows this patch doesn't have a regression.
> >
> > How do you suggest it be tested and this data be gathered? I tested a number of
> > workloads that keep kswapd awake but found no differences of major significant
> > even though it was using high-order allocations. The  problem with identifying
> > small regressions for high-order allocations is that the state of the system
> > when lumpy reclaim starts is very important as it determines how much work
> > has to be done. I did not find major regressions in performance.
> >
> > For the tests I did run;
> >
> > fsmark showed nothing useful. iozone showed nothing useful either as it didn't
> > even wake kswapd. sysbench showed minor performance gains and losses but it
> > is not useful as it typically does not wake kswapd unless the database is
> > badly configured.
> >
> > I ran postmark because it was the closest benchmark to a mail simulator I
> > had access to. This sucks because it's no longer representative of a mail
> > server and is more like a crappy filesystem benchmark. To get it closer to a
> > real server, there was also a program running in the background that mapped
> > a large anonymous segment and scanned it in blocks.
> >
> > POSTMARK
> >            postmark-traceonly-v3r1-postmarkpostmark-kanyzone-v2r6-postmark
> >                traceonly-v3r1     kanyzone-v2r6
> > Transactions per second:                2.00 ( 0.00%)     2.00 ( 0.00%)
> > Data megabytes read per second:         8.14 ( 0.00%)     8.59 ( 5.24%)
> > Data megabytes written per second:     18.94 ( 0.00%)    19.98 ( 5.21%)
> > Files created alone per second:         4.00 ( 0.00%)     4.00 ( 0.00%)
> > Files create/transact per second:       1.00 ( 0.00%)     1.00 ( 0.00%)
> > Files deleted alone per second:        34.00 ( 0.00%)    30.00 (-13.33%)
> 
> Do you know the reason only file deletion has a big regression?
> 

I'm guessing bad luck because it's not stable. There is a large memory
consumer running in the background. If the timing of when it got swapped
out changed, it could have regressed. It's not very stable between runs.
Sometimes the files deleted is not affected at all but every time the
read/writes per second is higher and the total time to completion is lower.

> > Files delete/transact per second:       1.00 ( 0.00%)     1.00 ( 0.00%)
> >
> > MMTests Statistics: duration
> > User/Sys Time Running Test (seconds)         152.4    152.92
> > Total Elapsed Time (seconds)               5110.96   4847.22
> >
> > FTrace Reclaim Statistics: vmscan
> >            postmark-traceonly-v3r1-postmarkpostmark-kanyzone-v2r6-postmark
> >                traceonly-v3r1     kanyzone-v2r6
> > Direct reclaims                                  0          0
> > Direct reclaim pages scanned                     0          0
> > Direct reclaim pages reclaimed                   0          0
> > Direct reclaim write file async I/O              0          0
> > Direct reclaim write anon async I/O              0          0
> > Direct reclaim write file sync I/O               0          0
> > Direct reclaim write anon sync I/O               0          0
> > Wake kswapd requests                             0          0
> > Kswapd wakeups                                2177       2174
> > Kswapd pages scanned                      34690766   34691473
> 
> Perhaps, in your workload, any_zone is highest zone.
> If any_zone became low zone, kswapd pages scanned would have a big
> difference because old behavior try to balance all zones.

It'll still balance the zones for order-0, the size we care most about.

> Could we evaluate this situation? but I have no idea how we set up the
> situation. :(
> 

See the reset of the series. The main consequence of any_zone being a low
zone is that balancing can stop because ZONE_DMA is balanced even though it
is unusable for allocations. Patch 3 takes the classzone_idx into account
to identify when deciding if kswapd should go to sleep. The final patch in
the series replaces "any zone" with "at least 25% of the pages making up
the node must be balanced". The situation could be forced artifically by
preventing pages ever being allocated from ZONE_DMA but we wouldn't be able
to draw any sensible conclusion from it as patch 5 in the series handles it.
This is why I'm depending on Simon's reports to see if his corner case is fixed
while running other stress tests to see if anything else is noticeably worse.

> > Kswapd pages reclaimed                    34511965   34513478
> > Kswapd reclaim write file async I/O             32          0
> > Kswapd reclaim write anon async I/O           2357       2561
> > Kswapd reclaim write file sync I/O               0          0
> > Kswapd reclaim write anon sync I/O               0          0
> > Time stalled direct reclaim (seconds)         0.00       0.00
> > Time kswapd awake (seconds)                 632.10     683.34
> >
> > Total pages scanned                       34690766  34691473
> > Total pages reclaimed                     34511965  34513478
> > %age total pages scanned/reclaimed          99.48%    99.49%
> > %age total pages scanned/written             0.01%     0.01%
> > %age  file pages scanned/written             0.00%     0.00%
> > Percentage Time Spent Direct Reclaim         0.00%     0.00%
> > Percentage Time kswapd Awake                12.37%    14.10%
> 
> Is "kswapd Awake" correct?
> AFAIR, In your implementation, you seems to account kswapd time even
> though kswapd are schedule out.
> I mean, for example,
> 
> kswapd
> -> time stamp start
> -> balance_pgdat
> -> cond_resched(kswapd schedule out)
> -> app 1 start
> -> app 2 start
> -> kswapd schedule in
> -> time stamp end.
> 
> If it's right, kswapd awake doesn't have a big meaning.
> 

"Time kswapd awake" is the time between when

	Trace event mm_vmscan_kswapd_wake is recorded while kswapd is asleep
	Trave event mm_vmscan_kswapd_sleep is recorded just before kswapd calls
			schedule() to properly go to sleep.

It's possible to receive mm_vmscan_kswapd_wake multiple times while kswapd
is asleep but it is ignored.

If kswapd schedules out normally or is stalled on direct writeback, this
time is included in the above value. Maybe a better name for this is
"kswapd active".

> >
> > proc vmstat: Faults
> >            postmark-traceonly-v3r1-postmarkpostmark-kanyzone-v2r6-postmark
> >                traceonly-v3r1     kanyzone-v2r6
> > Major Faults                                  1979      1741
> > Minor Faults                              13660834  13587939
> > Page ins                                     89060     74704
> > Page outs                                    69800     58884
> > Swap ins                                      1193      1499
> > Swap outs                                     2403      2562
> >
> > Still, IO performance was improved (higher rates of read/write) and the test
> > completed significantly faster with this patch series applied.  kswapd was
> > awake for longer and reclaimed marginally more pages with more swap-ins and
> 
> Longer wake may be due to wrong gathering of time as I said.
> 

Possibly, but I don't think so. I'm more inclined to blame the
effectively random interaction between postmark and the memory consumer
running in the background.

> > swap-outs which is unfortunate but it's somewhat balanced by fewer faults
> > and fewer page-ins. Basically, in terms of reclaim the figures are so close
> > that it is within the performance variations lumpy reclaim has depending on
> > the exact state of the system when reclaim starts.
> 
> What I wanted to see is that when if zones above any_zone isn't aging
> how it affect system performance.

The only test I ran that would be affected is a streaming IO test but
it's only one aspect of memory reclaim behaviour (albeit it one that
people tend to complain about when it's broken)

> This patch is changing balancing mechanism of kswapd so I think the
> experiment is valuable.
> I don't want to make contributors to be tired by bad reviewer.
> What do you think about that?
> 

About all I can report on is the streaming IO benchmarks results which
looks like;

MICRO
                                         traceonly     kanyzone
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         24.23     23.93
Total Elapsed Time (seconds)                916.18    916.69

FTrace Reclaim Statistics: vmscan
                                          traceonly  kanyzone
Direct reclaims                               2437       2565 
Direct reclaim pages scanned               1688201    1801142 
Direct reclaim write file async I/O              0          0 
Direct reclaim write anon async I/O             14          0 
Direct reclaim write file sync I/O               0          0 
Direct reclaim write anon sync I/O               0          0 
Wake kswapd requests                       1333358    1417622 
Kswapd wakeups                                 107        116 
Kswapd pages scanned                      15801484   15706394 
Kswapd reclaim write file async I/O             44         24 
Kswapd reclaim write anon async I/O             25          0 
Kswapd reclaim write file sync I/O               0          0 
Kswapd reclaim write anon sync I/O               0          0 
Time stalled direct reclaim (seconds)         1.79       0.98 
Time kswapd awake (seconds)                 387.60     410.26 

Total pages scanned                       17489685  17507536
%age total pages scanned/reclaimed           0.00%     0.00%
%age total pages scanned/written             0.00%     0.00%
%age  file pages scanned/written             0.00%     0.00%
Percentage Time Spent Direct Reclaim         6.88%     3.93%
Percentage Time kswapd Awake                42.31%    44.75%

proc vmstat: Faults
            micro-traceonly-v3r1-micromicro-kanyzone-v3r1-micro
                traceonly-v3r1     kanyzone-v3r1
Major Faults                                  1943      1808
Minor Faults                              55488625  55441993
Page ins                                    134044    126640
Page outs                                    73884     69248
Swap ins                                      2322      1972
Swap outs                                     7291      6521

Total pages scanned differ by 0.1% which is not much. Time to completion
is more or less the same. Faults, paging activity and swap activity are
all slightly reduced.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
