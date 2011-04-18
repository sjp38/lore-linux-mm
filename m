Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D3B87900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:11:15 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3IEtPll029407
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:55:25 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3IFB1Ia076064
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:11:02 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3IFAxeC007910
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:11:00 -0600
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel>
	 <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 18 Apr 2011 08:10:55 -0700
Message-ID: <1303139455.9615.2533.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 2011-04-16 at 17:02 -0700, David Rientjes wrote:
> > +void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
> > +{
> > +	va_list args;
> > +	unsigned int filter = SHOW_MEM_FILTER_NODES;
> > +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > +
> 
> "wait" is unnecessary.  You didn't do "const gfp_t nowarn = gfp_mask & 
> __GFP_NOWARN;" for the same reason.

This line is just a copy from the __alloc_pages_slowpath() one.  I guess
we only use it once, so I've got no problem killing it.

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
> > +		vprintk(fmt, args);
> > +		va_end(args);
> > +	}
> > +
> > +	printk(KERN_WARNING "%s: page allocation failure: order:%d, mode:0x%x\n",
> > +			current->comm, order, gfp_mask);
> 
> pr_warning()?

OK, I'll change it back.

> current->comm should always be printed with get_task_comm() to avoid 
> racing with /proc/pid/comm.  Since this function can be called potentially 
> deep in the stack, you may need to serialize this with a 
> statically-allocated buffer.

This code was already in page_alloc.c.  I'm simply breaking it out here
trying to keep the changes down to what is needed minimally to move the
code.  Correcting this preexisting problem sounds like a great follow-on
patch.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
