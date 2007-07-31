Date: Mon, 30 Jul 2007 18:53:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730185320.8bbfc0ac.akpm@linux-foundation.org>
In-Reply-To: <20070731013649.GB32468@localdomain>
References: <20070727232753.GA10311@localdomain>
	<20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	<20070731000138.GA32468@localdomain>
	<20070730172007.ddf7bdee.akpm@linux-foundation.org>
	<20070731013649.GB32468@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007 18:36:49 -0700 Ravikiran G Thirumalai <kiran@scalex86.org> wrote:

> On Mon, Jul 30, 2007 at 05:20:07PM -0700, Andrew Morton wrote:
> >On Mon, 30 Jul 2007 17:01:38 -0700
> >Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> >
> >> >The (cheesy) way in which reclaim currently handles this sort of thing is
> >> >to scan like mad, then to eventually set zone->all_unreclaimable.  Once
> >> >that has been set, the kernel will reduce the amount of scanning effort it
> >> >puts into that zone by a very large amount.  If the zone later comes back
> >> >to life, all_unreclaimable gets cleared and things proceed as normal.
> >> 
> >> I see.  But this obviously does not work in this case.  I have noticed the
> >> process getting into 'system' and staying there for hours.  I have never
> >> noticed the app complete.  Perhaps because I did not wait long enough.
> >> So do you think a more aggressive auto setting/unsetting of 'all_unreclaimable'
> >> is a better approach?
> >
> >The problem is that __zone_reclaim() doesn't use all_unreclaimable at all.
> >You'll note that all the other callers of shrink_zone() do take avoiding
> >action if the zone is in all_unreclaimable state, but __zone_reclaim() forgot
> >to.
> 
> Ummm... zone_reclaim does look at all_unreclaimable:

oh crap then we don't know what's going on.  At least, I don't.

> int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> ...
> ...
>         /*
>          * Avoid concurrent zone reclaims, do not reclaim in a zone that
>          * does
>          * not have reclaimable pages and if we should not delay the
>          * allocation
>          * then do not scan.
>          */
>         if (!(gfp_mask & __GFP_WAIT) ||
>                 zone->all_unreclaimable ||
>                 atomic_read(&zone->reclaim_in_progress) > 0 ||
>                 (current->flags & PF_MEMALLOC))
>                         return 0;
> 
> I guess it is not being set correctly for unreclaimable (pseudo fs) pages.

It doesn't care what type of page we're looking at.

umm, OK, perhaps the problem is that all_unreclaimable isn't getting set,
rather than that we aren't testing it.

Note that shrink_zones() and balance_pgdat() will set all_unreclaimable if
things get screwed up, but afaict zone_reclaim() doesn't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
