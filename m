Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 98AEA8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 08:16:17 -0500 (EST)
Subject: Re: too big min_free_kbytes
Date: Thu, 3 Feb 2011 13:15:49 +0000
From: Mel Gorman <mel@csn.ul.ie>
Message-ID: <20110203131549.GE11958@csn.ul.ie>
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110203025808.GJ5843@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>

On Thu, Feb 03, 2011 at 03:58:08AM +0100, Andrea Arcangeli wrote:
> On Thu, Jan 27, 2011 at 04:27:55PM +0100, Andrea Arcangeli wrote:
> > totally untested... I will test....
> 
> The below patch is fixing my problem and working fine for me... as
> expected it can't possibly lead to any D state, it's pretty much like
> setting min_free_kbytes lower, and it's not going to alter anything
> other than the levels of free memory kept by kswapd.
> 
> $ while :; do ps xa|grep [k]swapd; sleep 1; done
>   452 ?        R      1:20 [kswapd0]
>   452 ?        S      1:20 [kswapd0]
>   452 ?        S      1:20 [kswapd0]
>   452 ?        S      1:20 [kswapd0]
>   452 ?        S      1:20 [kswapd0]
>   452 ?        R      1:20 [kswapd0]
>   452 ?        R      1:20 [kswapd0]
>   452 ?        R      1:20 [kswapd0]
>   452 ?        R      1:20 [kswapd0]
>   452 ?        S      1:20 [kswapd0]
>   452 ?        R      1:20 [kswapd0]

I got a chance to test this today and I see similar results. I still do see
kswapd entering D state occasionally and I'm convinced it's because it's
calling congestion_wait() i.e. it's not real IO but it's being accounted
for as an IO-related wait. That said, it's mostly asleep (S) or running (R)
and free memory is at reasonable levels so it's a big improvement.

> $ vmstat 1
> procs -----------memory---------- ---swap-- -----io---- -system--
>   ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us
>   sy id wa
>  2  1   1784 111040 2393336 807924    0    0    63   992   56   70  1   1 96  2
>  0  1   1784 108928 2402556 801864    0    0 122624     0 1619 2150  0   5 80 16
>  0  1   1784 110664 2401244 801140    0    0 122496     0 1602 2081  0   3 81 16
>  0  1   1784 109796 2410184 792984    0    0 122752     0 1685 2149  0   4 80 16
>  0  1   1784 110416 2411856 791208    0    0 120448     4 1599 2075  0   4 81 16
>  1  0   1784 113516 2415344 785336    0    0 122496     0 1636 2125  0   4 81 15
> 
> I doubt we'll get any regression because of the below (see also my
> prev email in this thread), and I would only expect more cache and
> maybe better lru. Previously the free memory levels were stuck at
> ~700M now they're stuck at the right level for a 4G system with THP on
> (I'd still like to try to reduce the requirements only 1 hugepage for
> each migratetype in the set_min_free_kbytes to reduce the requirements
> to the minium, but only if possible..). But this saves 600M over 4G so
> it's the highest prio to address.
> 
> Comments welcome,

I think this is the best direction to take for the moment to close the obvious
bug. More thought is required on when exactly kswapd is going to sleep and
on what zones the allocator should be using but there is no quick answer that
will simply have other consequences. As much as I'd like to investigate this
further now, I'm in the process of changing jobs and expect to be heavily
disrupted for at least a month during the changeover. So, for this;

Reviewed-and-tested-by: Mel Gorman <mel@csn.ul.ie>

> Thanks!
> Andrea
> 
> > ====
> > Subject: vmscan: kswapd must not free more than high_wmark pages
> > 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > When the min_free_kbytes is set with `hugeadm
> > --set-recommended-min_free_kbytes" or with THP enabled (which runs the
> > equivalent of "hugeadm --set-recommended-min_free_kbytes" to activate
> > anti-frag at full effectiveness automatically at boot) the high wmark
> > of some zone is as high as ~88M. 88M free on a 4G system isn't
> > horrible, but 88M*8 = 704M free on a 4G system is definitely
> > unbearable. This only tends to be visible on 4G systems with tiny
> > over-4g zone where kswapd insists to reach the high wmark on the
> > over-4g zone but doing so it shrunk up to 704M from the normal zone by
> > mistake.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> > 
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index f5d90de..9e3c78e 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2407,7 +2407,7 @@ loop_again:
> >  			 * zone has way too many pages free already.
> >  			 */
> >  			if (!zone_watermark_ok_safe(zone, order,
> > -					8*high_wmark_pages(zone), end_zone, 0))
> > +					high_wmark_pages(zone), end_zone, 0))
> >  				shrink_zone(priority, zone, &sc);
> >  			reclaim_state->reclaimed_slab = 0;
> >  			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
> > 
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
