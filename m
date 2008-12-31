Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BE9C36B009D
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 07:24:24 -0500 (EST)
Received: by ewy3 with SMTP id 3so5634289ewy.14
        for <linux-mm@kvack.org>; Wed, 31 Dec 2008 04:24:21 -0800 (PST)
Message-ID: <cb94e63d0812310424t7f8c63a9k49deaeb0565836ae@mail.gmail.com>
Date: Wed, 31 Dec 2008 14:24:21 +0200
From: "wassim dagash" <wassim.dagash@gmail.com>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order allocation
In-Reply-To: <20081231120554.GC20534@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081230185919.GA17725@csn.ul.ie>
	 <2f11576a0812302054rd26d8bcw6a113b3abefe8965@mail.gmail.com>
	 <cb94e63d0812310059s263a0a75x12905a20526dafaf@mail.gmail.com>
	 <20081231120554.GC20534@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 31, 2008 at 2:05 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, Dec 31, 2008 at 10:59:58AM +0200, wassim dagash wrote:
>> Hi ,
>> Thank you all for reviewing.
>> Why don't we implement a solution where the order is defined per zone?
>
> kswapd is scanning trying to balance the whole system, not just one of
> the zones. You don't know which of the zones would be the best to
> rebalance and glancing through your path, the zone that would be
> balanced is the last zone in the zonelist. i.e. kswapd will try to
> rebalance the least-preferred zone to be used by the calling process.
>

You are right, but what is meant by 'order per zone' is that we will
balance all zones to kswapd_max_order which is the highest order from
which allocation was done on that zone.
What I tried to re-balance is the zone for which the allocation was
made, the other zones are fallback to that allocation ( correct me if
I'm wrong). As I understood from documentation, the first zone on the
list is the zone for which the allocation was made.

>> I implemented such a solution for my kernel (2.6.18) and tested it, it
>> worked fine for me. Attached a patch with a solution for 2.6.28
>> (compile tested only).
>>
>
> One big one;
>
> zone_watermark_ok() now always calculates order based on
> zone->kswapd_max_order. This means that a process that wants an order-0 page
> may check watermarks at order-10 because some other process overwrote the
> zone value. That is unfair.
>

This can be fixed by differing re-balance and allocation.

> One less obvious one;
>
> You add a field that is written often beside a field that is read-mostly
> in struct zone. This results in poorer cache behaviour. It's easily
> fixed though.
>

Sorry, but I'm very new to kernel programming, I read your book (and
other books) in order to figure out why KSWAPD loops in an endless
loop :)

I just wanted to understand why 'kswapd_max_order' was implemented
'per node' and not 'per zone' ? Is there a reason?

Thanks,

>> On Wed, Dec 31, 2008 at 6:54 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Hi
>> >
>> > thank you for reviewing.
>> >
>> >>> ==
>> >>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >>> Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation
>> >>>
>> >>> Wassim Dagash reported following kswapd infinite loop problem.
>> >>>
>> >>>   kswapd runs in some infinite loop trying to swap until order 10 of zone
>> >>>   highmem is OK, While zone higmem (as I understand) has nothing to do
>> >>>   with contiguous memory (cause there is no 1-1 mapping) which means
>> >>>   kswapd will continue to try to balance order 10 of zone highmem
>> >>>   forever (or until someone release a very large chunk of highmem).
>> >>>
>> >>> He proposed remove contenious checking on highmem at all.
>> >>> However hugepage on highmem need contenious highmem page.
>> >>>
>> >>
>> >> I'm lacking the original problem report, but contiguous order-10 pages are
>> >> indeed required for hugepages in highmem and reclaiming for them should not
>> >> be totally disabled at any point. While no 1-1 mapping exists for the kernel,
>> >> contiguity is still required.
>> >
>> > correct.
>> > but that's ok.
>> >
>> > my patch only change corner case bahavior and only disable high-order
>> > when priority==0. typical hugepage reclaim don't need and don't reach
>> > priority==0.
>> >
>> > and sorry. I agree with my "2nd loop"  word of the patch comment is a
>> > bit misleading.
>> >
>> >
>> >> kswapd gets a sc.order when it is known there is a process trying to get
>> >> high-order pages so it can reclaim at that order in an attempt to prevent
>> >> future direct reclaim at a high-order. Your patch does not appear to depend on
>> >> GFP_KERNEL at all so I found the comment misleading. Furthermore, asking it to
>> >> loop again at order-0 means it may scan and reclaim more memory unnecessarily
>> >> seeing as all_zones_ok was calculated based on a high-order value, not order-0.
>> >
>> > Yup. my patch doesn't depend on GFP_KERNEL.
>> >
>> > but, Why order-0 means it may scan more memory unnecessary?
>> > all_zones_ok() is calculated by zone_watermark_ok() and zone_watermark_ok()
>> > depend on order argument. and my patch set order variable to 0 too.
>> >
>> >
>> >> While constantly looping trying to balance for high-orders is indeed bad,
>> >> I'm unconvinced this is the correct change. As we have already gone through
>> >> a priorities and scanned everything at the high-order, would it not make
>> >> more sense to do just give up with something like the following?
>> >>
>> >>       /*
>> >>        * If zones are still not balanced, loop again and continue attempting
>> >>        * to rebalance the system. For high-order allocations, fragmentation
>> >>        * can prevent the zones being rebalanced no matter how hard kswapd
>> >>        * works, particularly on systems with little or no swap. For costly
>> >>        * orders, just give up and assume interested processes will either
>> >>        * direct reclaim or wake up kswapd as necessary.
>> >>        */
>> >>        if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
>> >>                cond_resched();
>> >>
>> >>                try_to_freeze();
>> >>
>> >>                goto loop_again;
>> >>        }
>> >>
>> >> I used PAGE_ALLOC_COSTLY_ORDER instead of sc.order == 0 because we are
>> >> expected to support allocations up to that order in a fairly reliable fashion.
>> >
>> > my comment is bellow.
>> >
>> >
>> >> =============
>> >> From: Mel Gorman <mel@csn.ul.ie>
>> >> Subject: [PATCH] mm: stop kswapd's infinite loop at high order allocation
>> >>
>> >>  kswapd runs in some infinite loop trying to swap until order 10 of zone
>> >>  highmem is OK.... kswapd will continue to try to balance order 10 of zone
>> >>  highmem forever (or until someone release a very large chunk of highmem).
>> >>
>> >> For costly high-order allocations, the system may never be balanced due to
>> >> fragmentation but kswapd should not infinitely loop as a result. The
>> >> following patch lets kswapd stop reclaiming in the event it cannot
>> >> balance zones and the order is high-order.
>> >>
>> >> Reported-by: wassim dagash <wassim.dagash@gmail.com>
>> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> >>
>> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> index 62e7f62..03ed9a0 100644
>> >> --- a/mm/vmscan.c
>> >> +++ b/mm/vmscan.c
>> >> @@ -1867,7 +1867,16 @@ out:
>> >>
>> >>                zone->prev_priority = temp_priority[i];
>> >>        }
>> >> -       if (!all_zones_ok) {
>> >> +
>> >> +       /*
>> >> +        * If zones are still not balanced, loop again and continue attempting
>> >> +        * to rebalance the system. For high-order allocations, fragmentation
>> >> +        * can prevent the zones being rebalanced no matter how hard kswapd
>> >> +        * works, particularly on systems with little or no swap. For costly
>> >> +        * orders, just give up and assume interested processes will either
>> >> +        * direct reclaim or wake up kswapd as necessary.
>> >> +        */
>> >> +       if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
>> >>                cond_resched();
>> >>
>> >>                try_to_freeze();
>> >
>> > this patch seems no good.
>> > kswapd come this point every SWAP_CLUSTER_MAX reclaimed because to avoid
>> > unnecessary priority variable decreasing.
>> > then "nr_reclaimed >= SWAP_CLUSTER_MAX" indicate kswapd need reclaim more.
>> >
>> > kswapd purpose is "reclaim until pages_high", not reclaim
>> > SWAP_CLUSTER_MAX pages.
>> >
>> > if your patch applied and kswapd start to reclaim for hugepage, kswapd
>> > exit balance_pgdat() function after to reclaim only 32 pages
>> > (SWAP_CLUSTER_MAX).
>> >
>> > In the other hand, "nr_reclaimed < SWAP_CLUSTER_MAX" mean kswapd can't
>> > reclaim enough
>> > page although priority == 0.
>> > in this case, retry is worthless.
>> >
>> > sorting out again.
>> > "goto loop_again" reaching happend by two case.
>> >
>> > 1. kswapd reclaimed SWAP_CLUSTER_MAX pages.
>> >    at that time, kswapd reset priority variable to prevent
>> > unnecessary priority decreasing.
>> >    I don't hope this behavior change.
>> > 2. kswapd scanned until priority==0.
>> >    this case is debatable. my patch reset any order to 0. but
>> > following code is also considerable to me. (sorry for tab corrupted,
>> > current my mail environment is very poor)
>> >
>> >
>> > code-A:
>> >       if (!all_zones_ok) {
>> >              if ((nr_reclaimed >= SWAP_CLUSTER_MAX) ||
>> >                 (sc.order <= PAGE_ALLOC_COSTLY_ORDER)) {
>> >                          cond_resched();
>> >                           try_to_freeze();
>> >                           goto loop_again;
>> >                }
>> >       }
>> >
>> > or
>> >
>> > code-B:
>> >       if (!all_zones_ok) {
>> >              cond_resched();
>> >               try_to_freeze();
>> >
>> >              if (nr_reclaimed >= SWAP_CLUSTER_MAX)
>> >                           goto loop_again;
>> >
>> >              if (sc.order <= PAGE_ALLOC_COSTLY_ORDER)) {
>> >                           order = sc.order = 0;
>> >                           goto loop_again;
>> >              }
>> >       }
>> >
>> >
>> > However, I still like my original proposal because ..
>> >  - code-A forget to order-1 (for stack) allocation also can cause
>> > infinite loop.
>> >  - code-B doesn't simpler than my original proposal.
>> >
>> > What do you think it?
>> >
>>
>>
>>
>> --
>> too much is never enough!!!!!
>
>
>
> --
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
>



-- 
too much is never enough!!!!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
