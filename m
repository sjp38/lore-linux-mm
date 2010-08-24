Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9B960080F
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 00:36:51 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o7O4aknt031500
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:36:47 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by wpaz13.hot.corp.google.com with ESMTP id o7O4ajhU011633
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:36:45 -0700
Received: by pvh1 with SMTP id 1so3211003pvh.23
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:36:44 -0700 (PDT)
Date: Mon, 23 Aug 2010 21:36:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] slob: fix gfp flags for order-0 page allocations
In-Reply-To: <1282623994.10679.921.camel@calx>
Message-ID: <alpine.DEB.2.00.1008232134480.25742@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com> <1282623994.10679.921.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Matt Mackall wrote:

> > kmalloc_node() may allocate higher order slob pages, but the __GFP_COMP
> > bit is only passed to the page allocator and not represented in the
> > tracepoint event.  The bit should be passed to trace_kmalloc_node() as
> > well.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> >  		unsigned int order = get_order(size);
> >  
> > -		ret = slob_new_pages(gfp | __GFP_COMP, get_order(size), node);
> > +		if (likely(order))
> > +			gfp |= __GFP_COMP;
> 
> Why is it likely? I would hope that the majority of page allocations are
> in fact order 0.
> 

This code only executes when size >= PAGE_SIZE + align, so I would assume 
that the vast majority of times this is actually higher order allocs 
(which is probably why __GFP_COMP was implicitly added to the gfpmask in 
the first place).  Is there evidence to show otherwise?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
