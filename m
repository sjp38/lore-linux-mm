Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 028786B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 04:34:43 -0400 (EDT)
Date: Fri, 10 Aug 2012 09:34:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] mm: vmscan: Scale number of pages reclaimed by
 reclaim/compaction based on failures
Message-ID: <20120810083438.GM12690@suse.de>
References: <1344342677-5845-3-git-send-email-mgorman@suse.de>
 <20120808014824.GB4247@bbox>
 <20120808075526.GI29814@suse.de>
 <20120808082738.GF4247@bbox>
 <20120808085112.GJ29814@suse.de>
 <20120808235127.GA17835@bbox>
 <20120809074949.GA12690@suse.de>
 <20120809082715.GA19802@bbox>
 <20120809092035.GD12690@suse.de>
 <20120809232733.GD21033@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120809232733.GD21033@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 10, 2012 at 08:27:33AM +0900, Minchan Kim wrote:
> > <SNIP>
> >
> > The intention is that an allocation can fail but each subsequent attempt will
> > try harder until there is success. Each allocation request does a portion
> > of the necessary work to spread the cost between multiple requests. Take
> > THP for example where there is a constant request for THP allocations
> > for whatever reason (heavy fork workload, large buffer allocation being
> > populated etc.). Some of those allocations fail but if they do, future
> > THP requests will reclaim more pages. When compaction resumes again, it
> > will be more likely to succeed and compact_defer_shift gets reset. In the
> > specific case of THP there will be allocations that fail but khugepaged
> > will promote them later if the process is long-lived.
> 
> You assume high-order allocation are *constant* and I guess your test enviroment
> is optimal for it.

Ok, my example stated they were constant because it was the easiest to
illustrate but it does not necessarily have to be the case. The high-order
allocation requests can be separated by any length of time with a read or
write stream running in the background applying a small amount of memory
pressure and the same scenario applies.

> I agree your patch if we can make sure such high-order
> allocation are always constant. But, is it true? Otherwise, your patch could reclaim
> too many pages unnecessary and it could reduce system performance by eviction

The "too many pages unnecessarily" is unlikely. For compact_defer_shift to be
elevated there has to have been recent failures by try_to_compact_pages(). If
compact_defer_shift is elevated and a large process exited then
try_to_compact_pages() may succeed and reset compact_defer_shift without
calling direct reclaim and entering this path at all.

> of page cache and swap out of workingset part. That's a concern to me.
> In summary, I think your patch is rather agressive so how about this?
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 66e4310..0cb2593 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1708,6 +1708,7 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
>  {
>         unsigned long pages_for_compaction;
>         unsigned long inactive_lru_pages;
> +       struct zone *zone;
> 
>         /* If not in reclaim/compaction mode, stop */
>         if (!in_reclaim_compaction(sc))
> @@ -1741,6 +1742,15 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
>          * inactive lists are large enough, continue reclaiming
>          */
>         pages_for_compaction = (2UL << sc->order);
> +
> +       /*
> +        * If compaction is deferred for this order then scale the number of
> +        * pages reclaimed based on the number of consecutive allocation
> +        * failures
> +        */
> +       zone = lruvec_zone(lruvec);
> +       if (zone->compact_order_failed <= sc->order) {
> +               if (zone->compact_defer_shift)
> +                       /*
> +                        * We can't make sure deferred requests will come again
> +                        * The probability is 50:50.
> +                        */
> +                       pages_for_compaction <<= (zone->compact_defer_shift - 1);

This patch is not doing anything radically different to my own patch.
compact_defer_shift == 0 if allocations succeeded recently using
reclaim/compaction at its normal level. Functionally the only difference
is that you delay when more pages get reclaim by one failure.

Was that what you intended? If so, it's not clear why you think this patch
is better or how you concluded that the probability of another failure was
"50:50".

>         }
>         inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
>         if (nr_swap_pages > 0)
>                 inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
