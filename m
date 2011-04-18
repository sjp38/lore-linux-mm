Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E599D900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:25:36 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3IKPXMP029106
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:25:33 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by kpbe15.cbf.corp.google.com with ESMTP id p3IKPVH7009221
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:25:31 -0700
Received: by pzk30 with SMTP id 30so3732862pzk.17
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:25:26 -0700 (PDT)
Date: Mon, 18 Apr 2011 13:25:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303139455.9615.2533.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel> <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com> <1303139455.9615.2533.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 18 Apr 2011, Dave Hansen wrote:

> > > +void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
> > > +{
> > > +	va_list args;
> > > +	unsigned int filter = SHOW_MEM_FILTER_NODES;
> > > +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > > +
> > 
> > "wait" is unnecessary.  You didn't do "const gfp_t nowarn = gfp_mask & 
> > __GFP_NOWARN;" for the same reason.
> 
> This line is just a copy from the __alloc_pages_slowpath() one.  I guess
> we only use it once, so I've got no problem killing it.
> 
> > > +	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
> > > +		return;
> > > +
> > > +	/*
> > > +	 * This documents exceptions given to allocations in certain
> > > +	 * contexts that are allowed to allocate outside current's set
> > > +	 * of allowed nodes.
> > > +	 */
> > > +	if (!(gfp_mask & __GFP_NOMEMALLOC))
> > > +		if (test_thread_flag(TIF_MEMDIE) ||
> > > +		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
> > > +			filter &= ~SHOW_MEM_FILTER_NODES;
> > > +	if (in_interrupt() || !wait)
> > > +		filter &= ~SHOW_MEM_FILTER_NODES;
> > > +
> > > +	if (fmt) {
> > > +		printk(KERN_WARNING);
> > > +		va_start(args, fmt);
> > > +		vprintk(fmt, args);
> > > +		va_end(args);
> > > +	}
> > > +
> > > +	printk(KERN_WARNING "%s: page allocation failure: order:%d, mode:0x%x\n",
> > > +			current->comm, order, gfp_mask);
> > 
> > pr_warning()?
> 
> OK, I'll change it back.
> 
> > current->comm should always be printed with get_task_comm() to avoid 
> > racing with /proc/pid/comm.  Since this function can be called potentially 
> > deep in the stack, you may need to serialize this with a 
> > statically-allocated buffer.
> 
> This code was already in page_alloc.c.  I'm simply breaking it out here
> trying to keep the changes down to what is needed minimally to move the
> code.  Correcting this preexisting problem sounds like a great follow-on
> patch.
> 

It shouldn't be a follow-on patch since you're introducing a new feature 
here (vmalloc allocation failure warnings) and what I'm identifying is a 
race in the access to current->comm.  A bug fix for a race should always 
preceed a feature that touches the same code.

There's two options to fixing the race:

 - provide a statically-allocated buffer to use for get_task_comm() and 
   copy current->comm over before printing it, or

 - take task_lock(current) to protect against /proc/pid/comm.

The latter probably isn't safe because we could potentially already be 
holding task_lock(current) during a GFP_ATOMIC page allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
