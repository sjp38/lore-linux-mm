From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: + prevent-kswapd-from-freeing-excessive-amounts-of-lowmem.patch added to -mm tree
Date: Thu, 13 Sep 2007 17:30:49 +1000
References: <200709132211.l8DMBh0n008399@imap1.linux-foundation.org>
In-Reply-To: <200709132211.l8DMBh0n008399@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709131730.49945.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Friday 14 September 2007 08:11, akpm@linux-foundation.org wrote:
> The patch titled
>      mm: prevent kswapd from freeing excessive amounts of lowmem
> has been added to the -mm tree.  Its filename is
>      prevent-kswapd-from-freeing-excessive-amounts-of-lowmem.patch
>
> *** Remember to use Documentation/SubmitChecklist when testing your code
> ***
>
> See http://www.zip.com.au/~akpm/linux/patches/stuff/added-to-mm.txt to find
> out what to do about this
>
> ------------------------------------------------------
> Subject: mm: prevent kswapd from freeing excessive amounts of lowmem
> From: Rik van Riel <riel@redhat.com>
>
> The current VM can get itself into trouble fairly easily on systems with a
> small ZONE_HIGHMEM, which is common on i686 computers with 1GB of memory.
>
> On one side, page_alloc() will allocate down to zone->pages_low, while on
> the other side, kswapd() and balance_pgdat() will try to free memory from
> every zone, until every zone has more free pages than zone->pages_high.
>
> Highmem can be filled up to zone->pages_low with page tables, ramfs,
> vmalloc allocations and other unswappable things quite easily and without
> many bad side effects, since we still have a huge ZONE_NORMAL to do future
> allocations from.
>
> However, as long as the number of free pages in the highmem zone is below
> zone->pages_high, kswapd will continue swapping things out from
> ZONE_NORMAL, too!
>
> Sami Farin managed to get his system into a stage where kswapd had freed
> about 700MB of low memory and was still "going strong".
>
> The attached patch will make kswapd stop paging out data from zones when
> there is more than enough memory free.  We do go above zone->pages_high in
> order to keep pressure between zones equal in normal circumstances, but the
> patch should prevent the kind of excesses that made Sami's computer totally
> unusable.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Yeah, suppose this is a fix. It is somewhat arbitrary. (what isn't, in
vmscan.c...).

Slightly less arbitrary would be to just stop scanning if the zone is
above the high watermark + the lower zone protection...

> ---
>
>  mm/vmscan.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletion(-)
>
> diff -puN
> mm/vmscan.c~prevent-kswapd-from-freeing-excessive-amounts-of-lowmem
> mm/vmscan.c ---
> a/mm/vmscan.c~prevent-kswapd-from-freeing-excessive-amounts-of-lowmem +++
> a/mm/vmscan.c
> @@ -1374,7 +1374,13 @@ loop_again:
>  			temp_priority[i] = priority;
>  			sc.nr_scanned = 0;
>  			note_zone_scanning_priority(zone, priority);
> -			nr_reclaimed += shrink_zone(priority, zone, &sc);
> +			/*
> +			 * We put equal pressure on every zone, unless one
> +			 * zone has way too many pages free already.
> +			 */
> +			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
> +						end_zone, 0))
> +				nr_reclaimed += shrink_zone(priority, zone, &sc);
>  			reclaim_state->reclaimed_slab = 0;
>  			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
>  						lru_pages);
> _
>
> Patches currently in -mm which might be from riel@redhat.com are
>
> vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-l
>ru.patch prevent-kswapd-from-freeing-excessive-amounts-of-lowmem.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
