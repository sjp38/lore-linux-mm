Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 882E66B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 11:19:42 -0400 (EDT)
Subject: Re: [patch] slob: fix gfp flags for order-0 page allocations
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.2.00.1008232134480.25742@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>
	 <1282623994.10679.921.camel@calx>
	 <alpine.DEB.2.00.1008232134480.25742@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 Aug 2010 10:20:41 -0500
Message-ID: <1282663241.10679.958.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-08-23 at 21:36 -0700, David Rientjes wrote:
> On Mon, 23 Aug 2010, Matt Mackall wrote:
> 
> > > kmalloc_node() may allocate higher order slob pages, but the __GFP_COMP
> > > bit is only passed to the page allocator and not represented in the
> > > tracepoint event.  The bit should be passed to trace_kmalloc_node() as
> > > well.
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > >  		unsigned int order = get_order(size);
> > >  
> > > -		ret = slob_new_pages(gfp | __GFP_COMP, get_order(size), node);
> > > +		if (likely(order))
> > > +			gfp |= __GFP_COMP;
> > 
> > Why is it likely? I would hope that the majority of page allocations are
> > in fact order 0.
> > 
> 
> This code only executes when size >= PAGE_SIZE + align, so I would assume 
> that the vast majority of times this is actually higher order allocs 
> (which is probably why __GFP_COMP was implicitly added to the gfpmask in 
> the first place).  Is there evidence to show otherwise?

(peeks at code)

Ok, that + should be a -. But yes, you're right, the bucket around an
order-0 allocation is quite small.

Acked-by: Matt Mackall <mpm@selenic.com>


By the way, has anyone seen anything like this leak reported?

/proc/slabinfo:

kmalloc-32        1113344 1113344     32  128    1 : tunables    0    0
0 : slabdata   8698   8698      0

That's /proc/slabinfo on my laptop with SLUB. It looks like my last
reboot popped me back to 2.6.33 so it may also be old news, but I
couldn't spot any reports with Google.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
