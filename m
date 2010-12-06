Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 541DE6B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 05:56:20 -0500 (EST)
Date: Mon, 6 Dec 2010 10:55:58 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/5] mm: kswapd: Stop high-order balancing when any
	suitable zone is balanced
Message-ID: <20101206105558.GA21406@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie> <1291376734-30202-2-git-send-email-mel@csn.ul.ie> <AANLkTi=ZXBXS2m0WCTNWT1t6EFi=Vji5t-yQG=fTJQgs@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=ZXBXS2m0WCTNWT1t6EFi=Vji5t-yQG=fTJQgs@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 06, 2010 at 08:35:18AM +0900, Minchan Kim wrote:
> Hi Mel,
> 
> On Fri, Dec 3, 2010 at 8:45 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > When the allocator enters its slow path, kswapd is woken up to balance the
> > node. It continues working until all zones within the node are balanced. For
> > order-0 allocations, this makes perfect sense but for higher orders it can
> > have unintended side-effects. If the zone sizes are imbalanced, kswapd may
> > reclaim heavily within a smaller zone discarding an excessive number of
> > pages. The user-visible behaviour is that kswapd is awake and reclaiming
> > even though plenty of pages are free from a suitable zone.
> >
> > This patch alters the "balance" logic for high-order reclaim allowing kswapd
> > to stop if any suitable zone becomes balanced to reduce the number of pages
> > it reclaims from other zones. kswapd still tries to ensure that order-0
> > watermarks for all zones are met before sleeping.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> <snip>
> 
> > -       if (!all_zones_ok) {
> > +       if (!(all_zones_ok || (order && any_zone_ok))) {
> >                cond_resched();
> >
> >                try_to_freeze();
> > @@ -2361,6 +2366,31 @@ out:
> >                goto loop_again;
> >        }
> >
> > +       /*
> > +        * If kswapd was reclaiming at a higher order, it has the option of
> > +        * sleeping without all zones being balanced. Before it does, it must
> > +        * ensure that the watermarks for order-0 on *all* zones are met and
> > +        * that the congestion flags are cleared
> > +        */
> > +       if (order) {
> > +               for (i = 0; i <= end_zone; i++) {
> > +                       struct zone *zone = pgdat->node_zones + i;
> > +
> > +                       if (!populated_zone(zone))
> > +                               continue;
> > +
> > +                       if (zone->all_unreclaimable && priority != DEF_PRIORITY)
> > +                               continue;
> > +
> > +                       zone_clear_flag(zone, ZONE_CONGESTED);
> 
> Why clear ZONE_CONGESTED?
> If you have a cause, please, write down the comment.
> 

It's because kswapd is the only mechanism that clears the congestion
flag. If it's not cleared and kswapd goes to sleep, the flag could be
left set causing hard-to-diagnose stalls. I'll add a comment.

> <snip>
> 
> First impression on this patch is that it changes scanning behavior as
> well as reclaiming on high order reclaim.

It does affect scanning behaviour for high-order reclaim. Specifically,
it may stop scanning once a zone is balanced within the node. Previously
it would continue scanning until all zones were balanced. Is this what
you are thinking of or something else?

> I can't say old behavior is right but we can't say this behavior is
> right, too although this patch solves the problem. At least, we might
> need some data that shows this patch doesn't have a regression.

How do you suggest it be tested and this data be gathered? I tested a number of
workloads that keep kswapd awake but found no differences of major significant
even though it was using high-order allocations. The  problem with identifying
small regressions for high-order allocations is that the state of the system
when lumpy reclaim starts is very important as it determines how much work
has to be done. I did not find major regressions in performance.

For the tests I did run;

fsmark showed nothing useful. iozone showed nothing useful either as it didn't
even wake kswapd. sysbench showed minor performance gains and losses but it
is not useful as it typically does not wake kswapd unless the database is
badly configured.

I ran postmark because it was the closest benchmark to a mail simulator I
had access to. This sucks because it's no longer representative of a mail
server and is more like a crappy filesystem benchmark. To get it closer to a
real server, there was also a program running in the background that mapped
a large anonymous segment and scanned it in blocks.

POSTMARK
            postmark-traceonly-v3r1-postmarkpostmark-kanyzone-v2r6-postmark
                traceonly-v3r1     kanyzone-v2r6
Transactions per second:                2.00 ( 0.00%)     2.00 ( 0.00%)
Data megabytes read per second:         8.14 ( 0.00%)     8.59 ( 5.24%)
Data megabytes written per second:     18.94 ( 0.00%)    19.98 ( 5.21%)
Files created alone per second:         4.00 ( 0.00%)     4.00 ( 0.00%)
Files create/transact per second:       1.00 ( 0.00%)     1.00 ( 0.00%)
Files deleted alone per second:        34.00 ( 0.00%)    30.00 (-13.33%)
Files delete/transact per second:       1.00 ( 0.00%)     1.00 ( 0.00%)

MMTests Statistics: duration
User/Sys Time Running Test (seconds)         152.4    152.92
Total Elapsed Time (seconds)               5110.96   4847.22

FTrace Reclaim Statistics: vmscan
            postmark-traceonly-v3r1-postmarkpostmark-kanyzone-v2r6-postmark
                traceonly-v3r1     kanyzone-v2r6
Direct reclaims                                  0          0 
Direct reclaim pages scanned                     0          0 
Direct reclaim pages reclaimed                   0          0 
Direct reclaim write file async I/O              0          0 
Direct reclaim write anon async I/O              0          0 
Direct reclaim write file sync I/O               0          0 
Direct reclaim write anon sync I/O               0          0 
Wake kswapd requests                             0          0 
Kswapd wakeups                                2177       2174 
Kswapd pages scanned                      34690766   34691473 
Kswapd pages reclaimed                    34511965   34513478 
Kswapd reclaim write file async I/O             32          0 
Kswapd reclaim write anon async I/O           2357       2561 
Kswapd reclaim write file sync I/O               0          0 
Kswapd reclaim write anon sync I/O               0          0 
Time stalled direct reclaim (seconds)         0.00       0.00 
Time kswapd awake (seconds)                 632.10     683.34 

Total pages scanned                       34690766  34691473
Total pages reclaimed                     34511965  34513478
%age total pages scanned/reclaimed          99.48%    99.49%
%age total pages scanned/written             0.01%     0.01%
%age  file pages scanned/written             0.00%     0.00%
Percentage Time Spent Direct Reclaim         0.00%     0.00%
Percentage Time kswapd Awake                12.37%    14.10%

proc vmstat: Faults
            postmark-traceonly-v3r1-postmarkpostmark-kanyzone-v2r6-postmark
                traceonly-v3r1     kanyzone-v2r6
Major Faults                                  1979      1741
Minor Faults                              13660834  13587939
Page ins                                     89060     74704
Page outs                                    69800     58884
Swap ins                                      1193      1499
Swap outs                                     2403      2562

Still, IO performance was improved (higher rates of read/write) and the test
completed significantly faster with this patch series applied.  kswapd was
awake for longer and reclaimed marginally more pages with more swap-ins and
swap-outs which is unfortunate but it's somewhat balanced by fewer faults
and fewer page-ins. Basically, in terms of reclaim the figures are so close
that it is within the performance variations lumpy reclaim has depending on
the exact state of the system when reclaim starts.

> It's
> not easy but I believe you can do very well as like having done until
> now. I didn't see whole series so I might miss something.
> 

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
