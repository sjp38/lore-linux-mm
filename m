Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C82268D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 16:43:39 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p38KNfXe021981
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 16:23:41 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id CC2116E803C
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 16:43:37 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p38KhbFs2723918
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 16:43:37 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p38KhaKS020778
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 16:43:37 -0400
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104081333260.12689@chino.kir.corp.google.com>
References: <20110408202253.6D6D231C@kernel>
	 <alpine.DEB.2.00.1104081333260.12689@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 08 Apr 2011 13:43:33 -0700
Message-ID: <1302295413.7286.1133.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri, 2011-04-08 at 13:37 -0700, David Rientjes wrote:
> > +static DEFINE_RATELIMIT_STATE(nopage_rs,
> > +		DEFAULT_RATELIMIT_INTERVAL,
> > +		DEFAULT_RATELIMIT_BURST);
> > +
> > +void nopage_warning(gfp_t gfp_mask, int order, const char *fmt, ...)
> 
> I suggest a different name for this, something like warn_alloc_failure() 
> or such.

That works for me.

> I guess this isn't general enough where it could be used in the oom killer 
> as well?

Nope, don't think so.  I took a look at it, but it isn't horribly close
to this.

> > +{
> > +	va_list args;
> > +	int r;
> > +	unsigned int filter = SHOW_MEM_FILTER_NODES;
> > +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > +
> > +	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
> > +		return;
> > +
> > +	/*
> > +	 * This documents exceptions given to allocations in certain
> > +	 * contexts that are allowed to allocate outside current's set
> > +	 * of allowed nodes.
> > +	 */
> > +	if (!(gfp_mask & __GFP_NOMEMALLOC))
> > +		if (test_thread_flag(TIF_MEMDIE) ||
> > +		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
> > +			filter &= ~SHOW_MEM_FILTER_NODES;
> > +	if (in_interrupt() || !wait)
> > +		filter &= ~SHOW_MEM_FILTER_NODES;
> > +
> > +	if (fmt) {
> > +		printk(KERN_WARNING);
> > +		va_start(args, fmt);
> > +		r = vprintk(fmt, args);
> > +		va_end(args);
> > +	}
> > +
> > +	printk(KERN_WARNING);
> > +	printk("%s: page allocation failure: order:%d, mode:0x%x\n",
> > +			current->comm, order, gfp_mask);
> 
> This shouldn't be here, it should have been printed already.

The "page allocation failure" might have been, if it was specified (it
isn't from the allocator), but order and mode haven't been.  My thought
here is that _all_ allocator failures will want to output mode and gfp,
so it might as well be common code instead of making everybody specify
it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
