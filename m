Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 70C726B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 05:42:29 -0500 (EST)
Date: Tue, 15 Nov 2011 10:42:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111115104223.GC27150@suse.de>
References: <20111114140421.GA27150@suse.de>
 <20111114150326.0ee60107.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111114150326.0ee60107.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 14, 2011 at 03:03:26PM -0800, Andrew Morton wrote:
> > <SNIP>
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9dd443d..5402897 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -127,6 +127,20 @@ void pm_restrict_gfp_mask(void)
> >  	saved_gfp_mask = gfp_allowed_mask;
> >  	gfp_allowed_mask &= ~GFP_IOFS;
> >  }
> > +
> > +static bool pm_suspending(void)
> > +{
> > +	if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
> > +		return false;
> > +	return true;
> > +}
> 
> This doesn't seem a terribly reliable way of detecting that PM has
> disabled the storage devices (which is what we really want to know
> here: kswapd got crippled).
> 

It only works because PM is the only caller that alters
gfp_allowed_mask at runtime after early boot completes. We also check
if suspend is in progress in mm/swapfile.c#try_to_free_swap() using
the gfp_allowed_mask.

> I guess it's safe for now, because PM is the only caller who alters
> gfp_allowed_mask (I assume). 

You assume correctly.

> But an explicit storage_is_unavaliable
> global which is set and cleared at exactly the correct time is clearer,
> more direct and future-safer, no?
> 

It feels overkill to allocate more global storage for it when
gfp_allowed_mask is already there but I could rename pm_suspending() to
pm_disabled_storage(), make try_to_free_swap() use the same helper but
leave the implementation the same. This would clarify the situation.

> > +#else
> > +
> > +static bool pm_suspending(void)
> > +{
> > +	return false;
> > +}
> >  #endif /* CONFIG_PM_SLEEP */
> >  
> >  #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
> > @@ -2214,6 +2228,14 @@ rebalance:
> >  
> >  			goto restart;
> >  		}
> > +
> > +		/*
> > +		 * Suspend converts GFP_KERNEL to __GFP_WAIT which can
> > +		 * prevent reclaim making forward progress without
> > +		 * invoking OOM. Bail if we are suspending
> > +		 */
> > +		if (pm_suspending())
> > +			goto nopage;
> 
> The comment doesn't tell the whole story: it's important that kswapd
> writeout was disabled?
> 

Writeout is disabled for flushers as well but your comment covers both
and clarifies the situation. Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
