Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D0C976B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 15:33:42 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p44JXdns011843
	for <linux-mm@kvack.org>; Wed, 4 May 2011 12:33:39 -0700
Received: from pvc12 (pvc12.prod.google.com [10.241.209.140])
	by wpaz13.hot.corp.google.com with ESMTP id p44JXbOm001917
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 12:33:37 -0700
Received: by pvc12 with SMTP id 12so908511pvc.0
        for <linux-mm@kvack.org>; Wed, 04 May 2011 12:33:37 -0700 (PDT)
Date: Wed, 4 May 2011 12:33:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: fail GFP_DMA allocations when ZONE_DMA is not
 configured
In-Reply-To: <20110414145458.f9bb7744.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1105041219130.22426@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104141443260.13286@chino.kir.corp.google.com> <20110414145458.f9bb7744.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, David Woodhouse <David.Woodhouse@intel.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011, Andrew Morton wrote:

> > The page allocator will improperly return a page from ZONE_NORMAL even 
> > when __GFP_DMA is passed if CONFIG_ZONE_DMA is disabled.  The caller 
> > expects DMA memory, perhaps for ISA devices with 16-bit address 
> > registers, and may get higher memory resulting in undefined behavior.
> > 
> > This patch causes the page allocator to return NULL in such circumstances 
> > with a warning emitted to the kernel log on the first occurrence.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/page_alloc.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2225,6 +2225,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  
> >  	if (should_fail_alloc_page(gfp_mask, order))
> >  		return NULL;
> > +#ifndef CONFIG_ZONE_DMA
> > +	if (WARN_ON_ONCE(gfp_mask & __GFP_DMA))
> > +		return NULL;
> > +#endif
> 
> Worried.  We have a large number of drivers which use GFP_DMA and I bet
> some of them didn't really need to set it, and can use DMA32 memory. 
> They will now break.
> 

They were already broken for CONFIG_ZONE_DMA=n since passing __GFP_DMA 
never guaranteed the memory came from ZONE_DMA32 (and would return 
ZONE_NORMAL memory even if CONFIG_ZONE_DMA32=n).

> What is drivers/pci/intel-iommu.c doing with GFP_DMA btw?
> 

Looks like if no identity mapping is needed for that device (using a 
non-identity mapping instead), then there is no lowmem restriction on its 
allocation; otherwise, we use lowmem is used when the device's mask 
specifically requires it.

Adding Alex and David to the cc.

> How commonly are people disabling ZONE_DMA?
> 

Probably not that much, it's usually def_bool y everywhere and just 
implicitly on.  I'm changing that for x86 on a CONFIG_EXPERT kernel so 
that we can avoid a ZONE_DMA entirely; that prevents reserving memory we 
don't need with the lowmem reserve by default, we can eliminate the DMA 
slab caches, etc.  Google has been running with CONFIG_ZONE_DMA=n for a 
couple years because we simply don't need it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
