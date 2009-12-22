Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7A460044A
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 21:51:27 -0500 (EST)
Date: Tue, 22 Dec 2009 02:51:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: fix 2.6.32 slowdown in heavy swapping
Message-ID: <20091222025114.GF23345@csn.ul.ie>
References: <Pine.LNX.4.64.0912212214420.10033@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0912212214420.10033@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 21, 2009 at 10:23:47PM +0000, Hugh Dickins wrote:
> Hi Mel,
> 
> Sorry to spring this upon you, when you've already mentioned that
> you'll be offline shortly - maybe I'm too late, please don't let it
> spoil your break, feel free not to respond for a couple of weeks.
> 

Ironically, due to bad weather I'm still online to some extent. Assuming it's
clearer tomorrow, I'll reach my intended destination which has little in
the wya of interest access and I'll be a lot quieter.

> I've sat quite a while on this, bisecting and trying to narrow
> it down and experimenting with different fixes; but I've failed
> to reproduce it with anything simpler than my kernel builds on
> tmpfs loop swapping tests, and it's only obvious on the PowerPC G5.
> 
> The problem is that those swapping builds run about 20% slower in
> 2.6.32 than 2.6.31 (and look as if they run increasingly slowly,
> though I'm not certain of that); and surprisingly it bisected
> down to your commit 5f8dcc21211a3d4e3a7a5ca366b469fb88117f61
> page-allocator: split per-cpu list into one-list-per-migrate-type
> 
> It then took me a long while to insert the vital printk which
> revealed the now obvious problem: MIGRATE_RESERVE pages are being
> put on the MIGRATE_MOVABLE list, then freed as MIGRATE_MOVABLE.
> Which I assume gradually depletes the intended reserve?
> 

MIGRATE_RESERVE is a small number of pageblocks at the beginning of the
zone but if min_free_kbytes is a value lower than the pageblock size, it's
perfectly possible for pages from these blocks to be allocated. Pages in
reserve blocks are added to the movable PCP lists, that's true.  In itself,
that is not a problem. The intention of leaving them on the PCP list was to
avoid taking the zone lock too quickly. If they are to be used, it was
best to use them for GFP_MOVABLE as they could be moved or direct
reclaimed necessary relatively easily.

So the reserve doesn't get depleted as such, it's still min_free_kbytes. The
reason RESERVE blocks are avoided is to have min_free_kbytes free as
contiguous pages where possible. Users of short-lived high-order atomic
allocations depend on this behaviour and commit 5f8dcc2 broke that by freeing
to MIGRATE_MOVABLE instead of MIGRATE_RESERVE in the buddy lists. It might
explain why high-order allocations failed more on 2.6.32 than they did on
2.6.31 before it got fixed up in fact.

What is less obvious to me is why it changes timing so much in swap-based
loads. A possible explanation is that order-1 allocations are being depended
on in your workload but if they are relatively short-lived, they are getting
successfully allocated out of MIGRATE_RESERVE. Without your patch, it's
possible that kswapd and direct reclaim are having to do a lot more
work.

> The simplest, straight bugfix, patch is the one below: rely on
> page_private instead of migratetype when freeing.  But three plausible
> alternatives have occurred to me, and each has its own advantages.
> All four bring the timing back to around what it used to be.
> 
> Whereas this patch below uses the migratetype in page_private(page),
> the other three remove that as now redundant.  In the second version
> free_hot_cold_page() does immediate free_one_page() of MIGRATE_RESERVEs
> just like MIGRATE_ISOLATEs, so they never get on the MIGRATE_MOVABLE list.
> 

This was my first approach but I was concerned that if the MIGRATE_RESERVE
blocks were being used heavily due to a low-memory situation then the zone
lock would get too heavily contended, the buddy free paths would be used
too aggressively and overall performance would be hurt.

> In the third and fourth versions I've raised MIGRATE_PCPTYPES to 4,
> so there's a list of MIGRATE_RESERVEs: in the third, buffered_rmqueue()
> supplies pages from there if rmqueue_bulk() left list empty (that seems
> closest to 2.6.31 behaviour); the same in the fourth, except only when
> trying for MIGRATE_MOVABLE pages (that seems closer to your intention).
> 

The fourth would be preferred as it's closer to the intention - use the
MIGRATE_RESERVE pages if you have to, but preferably have movable pages
in there.

> In my peculiar testing (on two machines: though the slowdown was much
> less noticeable on Dell P4 x86_64, these fixes do show improvements),
> fix 2 appears slightly the fastest,

I suspect it would cause problems with more CPUs due to zone lock
contention.

> and fix 3 the one with least
> variance.  But take that with a handful of salt, the likelihood
> is that further tests on other machines would show differently.
> 
> Mel, do you have a feeling for which fix is the _right_ fix?
> 

I'm afraid I can't recheck this as I don't have sources available right now
but adding the MIGRATE_RESERVE list *may* have pushed struct per_cpu_pages into
another cache line. This can be checked with pahole. If the cache usage is the
same due to wriggle room in the struct's padding, then option 4 is preferred as
I would expect it to be better for keeping MIGRATE_RESERVE free and contiguous.

If the cache usage is heavier as a result of adding the extra list, then
the patch you have below is the best option.

> I don't, and I'd rather hold back from signing off a patch, until
> we have your judgement.  But here is the first version of the fix,
> in case anyone else has noticed a slowdown in heavy swapping and
> wants to try it.
> 

Thanks a lot for tracking this down.

> Thanks,
> Hugh
> 
> ---
> 
>  mm/page_alloc.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> --- 2.6.33-rc1/mm/page_alloc.c	2009-12-18 11:42:54.000000000 +0000
> +++ linux/mm/page_alloc.c	2009-12-20 19:10:50.000000000 +0000
> @@ -555,8 +555,9 @@ static void free_pcppages_bulk(struct zo
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> -			__free_one_page(page, zone, 0, migratetype);
> -			trace_mm_page_pcpu_drain(page, 0, migratetype);
> +			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> +			__free_one_page(page, zone, 0, page_private(page));
> +			trace_mm_page_pcpu_drain(page, 0, page_private(page));
>  		} while (--count && --batch_free && !list_empty(list));
>  	}
>  	spin_unlock(&zone->lock);
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
