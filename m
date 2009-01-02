Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D8176B00AF
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 04:55:50 -0500 (EST)
Received: by yw-out-1718.google.com with SMTP id 5so1813149ywm.26
        for <linux-mm@kvack.org>; Fri, 02 Jan 2009 01:55:48 -0800 (PST)
Message-ID: <28c262360901020155l3a9260b5h3c79d4b23a213825@mail.gmail.com>
Date: Fri, 2 Jan 2009 18:55:48 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order allocation take2
In-Reply-To: <20090101021240.A057.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081231115332.GB20534@csn.ul.ie>
	 <20081231215934.1296.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090101021240.A057.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi, kosaki-san.

I read the previous threads now. It's rather late :(.

I think it's rather awkward that sudden big change of order from 10 to 0.

This problem causes zone_water_mark's fail.
It mean now this zone's proportional free page per order size is not good.
Although order-0 page is very important, Shouldn't we consider other
order allocations ?

So I want to balance zone's proportional free page.
How about following ?

if (nr_reclaimed < SWAP_CLUSTER_MAX) {
   if (order != 0) {
     order -=1;
     sc.order -=1;
   }
}

It prevents infinite loop and do best effort to make zone's
proportional free page per order size good.

It's just my opinion within my knowledge.
If it have a problem, pz, explain me :)


On Thu, Jan 1, 2009 at 11:52 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> >                 /*
>> >                  * Fragmentation may mean that the system cannot be
>> >                  * rebalanced for high-order allocations in all zones.
>> >                  * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
>> >                  * it means the zones have been fully scanned and are still
>> >                  * not balanced. For high-order allocations, there is
>> >                  * little point trying all over again as kswapd may
>> >                  * infinite loop.
>> >                  *
>> >                  * Instead, recheck all watermarks at order-0 as they
>> >                  * are the most important. If watermarks are ok, kswapd will go
>> >                  * back to sleep. High-order users can still direct reclaim
>> >                  * if they wish.
>> >                  */
>> >
>> > ?
>>
>> Excellent. I strongly like this and I hope merge it to my patch.
>> I'll resend new patch.
>
> Done.
>
>
>
> ==
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation
>
> Wassim Dagash reported following kswapd infinite loop problem.
>
>  kswapd runs in some infinite loop trying to swap until order 10 of zone
>  highmem is OK.... kswapd will continue to try to balance order 10 of zone
>  highmem forever (or until someone release a very large chunk of highmem).
>
> For non order-0 allocations, the system may never be balanced due to
> fragmentation but kswapd should not infinitely loop as a result.
>
> Instead, recheck all watermarks at order-0 as they are the most important.
> If watermarks are ok, kswapd will go back to sleep.
>
>
> Reported-by: wassim dagash <wassim.dagash@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Nick Piggin <npiggin@suse.de>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>,
> ---
>  mm/vmscan.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
>
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c       2008-12-25 08:26:37.000000000 +0900
> +++ b/mm/vmscan.c       2009-01-01 01:56:02.000000000 +0900
> @@ -1872,6 +1872,23 @@ out:
>
>                try_to_freeze();
>
> +               /*
> +                * Fragmentation may mean that the system cannot be
> +                * rebalanced for high-order allocations in all zones.
> +                * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
> +                * it means the zones have been fully scanned and are still
> +                * not balanced. For high-order allocations, there is
> +                * little point trying all over again as kswapd may
> +                * infinite loop.
> +                *
> +                * Instead, recheck all watermarks at order-0 as they
> +                * are the most important. If watermarks are ok, kswapd will go
> +                * back to sleep. High-order users can still direct reclaim
> +                * if they wish.
> +                */
> +               if (nr_reclaimed < SWAP_CLUSTER_MAX)
> +                       order = sc.order = 0;
> +
>                goto loop_again;
>        }
>
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
