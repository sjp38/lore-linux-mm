Message-ID: <000601c7e6ae$db887680$6501a8c0@earthlink.net>
Reply-To: "Mitchell Erblich" <erblichs@earthlink.net>
From: "Mitchell Erblich" <erblichs@earthlink.net>
Subject: Re: [RFC] : mm : / Patch / code : Suggestion :snip  kswapd &  get_page_from_freelist()  : No more no page failures.
Date: Fri, 24 Aug 2007 17:28:26 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Mitchell@kvack.org, Erblich@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mitchell Erblich <erblichs@earthlink.net>, Peter Zijlstra <peterz@infradead.org>, Peter@kvack.org, Zijlstra@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.orgAndrewmingo@elte.hulinux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

linux-mm@kvack.org
Sent: Friday, August 24, 2007 3:11 PM
Subject: Re: [RFC] : mm : / Patch / code : Suggestion :snip kswapd &
get_page_from_freelist() : No more no page failures.

Mailer added a HTML subpart and chopped the earlier email.... :^(


Peter Zijlstra wrote:
>
> On Thu, 2007-08-23 at 02:35 -0700, Mitchell Erblich wrote:
> > Group,
> >
> >     On the infrequent condition of failing to recieve a page from the
> >     freelists, one of the things you do is call
wakeup_kswapd()(exception of
> >     NUMA or GFP_THISNODE).
> >
> >     Asuming that wakeup_kswapd() does what we want, this call is
> >     such a high overhead call that you want to make sure that the
> >     call is infrequent.
>
> It just wakes up a thread, it doesn't actually wait for anything.
> So the function is actually rather cheap.
>
> >     My initial guess is that it REALLY needs to re-populate the
> >     freelists just before they/it is used up. However, the simple change
> >     is being suggested NOW.
>
> kswapd will only stop once it has reached the high watermarks
>
> >     Assuming that on avg that the order value will be used, you should
> >     increase the order to cover two allocs of that same level of order,
> >     thus the +1. If on the chance that later page_alloc() calls need
> >     fewer pages (smaller order) then the extra pages will be available
> >     for more page_allocs(). If later calls have larger orders, hopefully
> >     the latency between the calls is great enough that other parts of
> >     the system will respond to the low memory / on the freelist(s).
>
> by virtue of kswapd only stopping reclaim when it reaches the high
> watermark you already have that it will free more than one page (its
> started when we're below the low watermark, so it'll free at least
> high-min pages).
>
> Changing the order has quite a different impact, esp now that we have
> lumpy reclaim.
>
> >     Line 1265 within function __alloc_pages(), mm/page_alloc.c
> >
> > wakeup_kswapd(*z, order);
> >       to
> > wakeup_kswapd(*z, order + 1);
> >
> > In addition, isn't a call needed to determine that the
> > freelist(s) are almost empty, but are still returning a page?
>
> didn't we just do that by finding out that ALLOC_WMARK_LOW fails to
> return a page?
>
Peter Zijlstra, et al,

    This reply is long.. In summary the order only effects whether the
max_order is
    larger or smaller, and this makes sure that we are getting enough
memory.
    When I get to swapd, I will look whether I really think, IMO, that it
SHOULD quit
    before it reaches high mem as you seem to say above. IMO, cached memory
    is good. Freelists are good. No page returns from
get_page_from_freelist()
    are bad. And that doing something after a bad thing happens doesn't seem
    to be the right thing to do.

> didn't we just do that by finding out that ALLOC_WMARK_LOW fails to
> return a page?

    Yes, but I am talking about being premature in my checking while we
    still are returning pages. When we first start not returning a page,
things
    are starting to fail. Thus, this fairly KISS code is their to stop us
from
    getting to the no page part! It calls two modified functions renaming
them
    just a few lines above the current call to the wakeup_kswapd in what I
    term the pre-call sequence. And the code itself is shorter than all this
    explanation because it is a different way of thinking to a problem, IMO.

   Please realize that this is a prototype and
    is intended to be very close, but needs to be reviewed by multiple
people to
    identify whether the extra overhead in the fast path is worth the
tradeoff to
    wake up the swapd BEFORE free memory drops to the current point that it
    is NORMALLY awoken.

    I will assume that 2x low memory is more than ample time to wakeup
kswapd
    and allow is to clean any dirty pages, thus preventing any low memory
condition
    from occuring..

Group,

        Summary:

> > In addition, isn't a call needed to determine that the
> > freelist(s) are almost empty, but are still returning a page?

        These suggestions are founded to attempt to
        decrease the chance of dropping below low_memory
        by waking up kswapd before we run out of pages
        from the page freelist and/or effect MOST normal
        page allocations.

        The simplistic fix is to add a lightweight check prototyped/
        suggestion below that checks whether we are about to drop
        below the low watermark (free_pages  / 2 ). If we
        are within 2 * lowmem_reserve, then we should start up kswapd
        with the shortened wakeup_short_swapd() which removes the
        call to zone_watermark_ok(), because it was already done.
        So, the shorted zone_water_check() is done because we
        aren't in the middle of a allocation.

        thus, if we can start the kswapd() soon enough, the chance
        of going below the goto got_pg should be diminished and
        the chance of page failures should also decrease due to
        low memory. Also, GFP_ATOMIC type failures should also
        decrease.

NOTE:
    This code does not assume that the existing functions
    that I am leverging from are touched and does not modify any
    no page code flow, other than the 1 line suggested change
    in the first post by myself.


        Detail with code:
        ------------------
First,
        Order here is used to re-set kswapd_max_order if
        it is larger than the previous value, thus plus 1 to make
        sure that we get more than we need. See the 1 line change
        above from the initial post.

Second,
        simple: The below includes a nit to move an
        assignment below the return at #1 a the original
        fuunction and my modified function.

    Now the KISS part..


The SUGGESTED pre-call sequence within mm/page_alloc.c : _alloc_pages()

        /*existing */
        page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
                                 zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);

        if (page) (
            /* new */
            for (z = zonelist->zones; *z; z++) {
                zone = *z;
                if (!zone_water_check(zone, zone->pages_low)    /* #2 below
*/
                     wakeup_short_kswapd(*z);                   /* #3 below
*/
            }
            goto got_pg; /* existing */
        )


mm/vmscan.c : wakeup_kswapd()
1) Nit: code fragment.Move assignment.

        pgdat = zone->zone_pgdat;
        if (zone_watermark_ok(zone, zone->pages_low, 0, 0))
                return;
        if (pgdat->kswapd_max_order < order)

Shouldn't the assignment
        pgdat = zone->zone_pgdat;
be after the return.

2) mm/page_alloc.c : zone_watermark_ok()
Take a subset of this function as zone_water_check()
say
int zone_water_check(struct zone *z, int classzone_idx)
{
long free_pages = zone_page_state(z, NR_FREE_PAGES);
int ret = 1; /* likely : above low water */

if ((free_pages /  2 ) <= z->lowmem_reserve[classzone_idx])
/* which removes min */
   ret = 0;
return ret;
}

3) /*
 * shortened wakeup_kswapd()
 * we don't need to set a max_order
 * And we alredy did a simplified
 * zone_watermark_ok type check
 */
becomes
void wakeup_short_kswapd(struct zone *zone)
{
      pg_data_t *pgdat;

      if (!populated_zone(zone))
          return;

      if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
            return;

      pgdat = zone->zone_pgdat;
      if (!waitqueue_active(&pgdat->kswapd_wait))
             return;
       wake_up_interruptible(&pgdat->kswapd_wait);
 }

Mitchell Erblich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
