Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B83526B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 18:43:45 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 1/6] mm: Introduce __GFP_NO_OOM_KILL
Date: Tue, 12 May 2009 00:14:23 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905101550.09671.rjw@sisk.pl> <alpine.DEB.2.00.0905111312140.27577@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0905111312140.27577@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905120014.24751.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, pm list <linux-pm@lists.linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 11 May 2009, David Rientjes wrote:
> On Sun, 10 May 2009, Rafael J. Wysocki wrote:
> 
> > Index: linux-2.6/mm/page_alloc.c
> > ===================================================================
> > --- linux-2.6.orig/mm/page_alloc.c
> > +++ linux-2.6/mm/page_alloc.c
> > @@ -1619,8 +1619,12 @@ nofail_alloc:
> >  			goto got_pg;
> >  		}
> >  
> > -		/* The OOM killer will not help higher order allocs so fail */
> > -		if (order > PAGE_ALLOC_COSTLY_ORDER) {
> > +		/*
> > +		 * The OOM killer will not help higher order allocs so fail.
> > +		 * Also fail if the caller doesn't want the OOM killer to run.
> > +		 */
> > +		if (order > PAGE_ALLOC_COSTLY_ORDER
> > +				|| (gfp_mask & __GFP_NO_OOM_KILL)) {
> >  			clear_zonelist_oom(zonelist, gfp_mask);
> >  			goto nopage;
> >  		}
> > Index: linux-2.6/include/linux/gfp.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/gfp.h
> > +++ linux-2.6/include/linux/gfp.h
> > @@ -51,8 +51,9 @@ struct vm_area_struct;
> >  #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
> >  #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
> >  #define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
> > +#define __GFP_NO_OOM_KILL ((__force gfp_t)0x200000u)  /* Don't invoke out_of_memory() */
> >  
> > -#define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
> > +#define __GFP_BITS_SHIFT 22	/* Number of __GFP_FOO bits */
> >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> >  
> >  /* This equals 0, but use constants in case they ever change */
> > 
> 
> Nack, unnecessary in mmotm and my patch series from 
> http://lkml.org/lkml/2009/5/10/118.

Andrew, what's your opinion, please?

I can wait with these patches until the dust settles in the mm land.

David, which patch in your series causes this to be unnecessary?

Best,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
