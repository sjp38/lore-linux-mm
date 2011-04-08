Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 57A3F8D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 16:47:25 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p38KY1ob006986
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 14:34:01 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p38KlHhN094964
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 14:47:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p38KlGMJ021989
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 14:47:16 -0600
Subject: Re: [PATCH 2/2] print vmalloc() state after allocation failures
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104081337470.12689@chino.kir.corp.google.com>
References: <20110408202253.6D6D231C@kernel>
	 <20110408202255.9EE67DC9@kernel>
	 <alpine.DEB.2.00.1104081337470.12689@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 08 Apr 2011 13:47:14 -0700
Message-ID: <1302295634.7286.1146.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri, 2011-04-08 at 13:39 -0700, David Rientjes wrote:
> On Fri, 8 Apr 2011, Dave Hansen wrote:
> > This patch will print out messages that look like this:
> > 
> > [   30.040774] bash: vmalloc failure allocating after 0 / 73728 bytes
> > 
> 
> Either the changelog or the patch is still wrong because the format of 
> this string is inconsistent.

Yeah, ya caught me. :)
> > diff -puN mm/vmalloc.c~vmalloc-warn mm/vmalloc.c
> > --- linux-2.6.git/mm/vmalloc.c~vmalloc-warn	2011-04-08 09:36:05.877020199 -0700
> > +++ linux-2.6.git-dave/mm/vmalloc.c	2011-04-08 09:38:00.373093593 -0700
> > @@ -1534,6 +1534,7 @@ static void *__vmalloc_node(unsigned lon
> >  static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
> >  				 pgprot_t prot, int node, void *caller)
> >  {
> > +	int order = 0;
> 
> Unnecessary, we can continue to hardcode the 0, vmalloc isn't going to use 
> higher order allocs (it's there to avoid such things!).

The only reason I did that was to keep the printk from looking like
this:

> > +	nopage_warning(gfp_mask, 0,  "vmalloc: allocation failure, "
> > +			"allocated %ld of %ld bytes\n",
> > +			(area->nr_pages*PAGE_SIZE), area->size);

The order is pretty darn obvious in the direct allocator calls, but I
liked having it named where it wasn't as obvious.

> >  	struct page **pages;
> >  	unsigned int nr_pages, array_size, i;
> >  	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
> > @@ -1560,11 +1561,12 @@ static void *__vmalloc_area_node(struct 
> >  
> >  	for (i = 0; i < area->nr_pages; i++) {
> >  		struct page *page;
> > +		gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;
> 
> I think it would be better to just do away with this as well and just 
> hardwire the __GFP_NOWARN directly into the two allocation calls.

I did it because hard-wiring it takes the alloc_pages_node() one over 80
columns.  I figured if I was going to add a line, I might as well keep
it pretty.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
