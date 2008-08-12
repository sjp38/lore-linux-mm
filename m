Received: by qb-out-1314.google.com with SMTP id e11so4527932qbc.4
        for <linux-mm@kvack.org>; Tue, 12 Aug 2008 08:28:38 -0700 (PDT)
Date: Tue, 12 Aug 2008 18:25:49 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080812152548.GA5973@localhost>
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro> <48A046F5.2000505@linux-foundation.org> <1218463774.7813.291.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1218463774.7813.291.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, mathieu.desnoyers@polymtl.ca, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Mon, Aug 11, 2008 at 05:09:34PM +0300, Pekka Enberg wrote:
> On Mon, 2008-08-11 at 09:04 -0500, Christoph Lameter wrote:
> > Eduard - Gabriel Munteanu wrote:
> > 
> > 
> > 
> > >  static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> > >  {
> > > +	void *ret;
> > > +
> > >  	if (__builtin_constant_p(size) &&
> > >  		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
> > >  			struct kmem_cache *s = kmalloc_slab(size);
> > > @@ -239,7 +280,13 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> > >  		if (!s)
> > >  			return ZERO_SIZE_PTR;
> > >  
> > > -		return kmem_cache_alloc_node(s, flags, node);
> > > +		ret = kmem_cache_alloc_node_notrace(s, flags, node);
> > > +
> > > +		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
> > > +					  _THIS_IP_, ret,
> > > +					  size, s->size, flags, node);
> > > +
> > > +		return ret;
> > 
> > You could simplify the stuff in slub.h if you would fall back to the uninlined
> > functions in the case that kmemtrace is enabled. IMHO adding additional inline
> > code here does grow these function to a size where inlining is not useful anymore.
> 
> So, if CONFIG_KMEMTRACE is enabled, make the inlined version go away
> completely? I'm okay with that though I wonder if that means we now take
> a performance hit when CONFIG_KMEMTRACE is enabled but tracing is
> disabled at run-time...

Oh, good. I'm also thinking to add a macro that expands to simple inline when
CONFIG_KMEMTRACE is disabled and to __always_inline otherwise.

> > > +	kmemtrace_mark_alloc(KMEMTRACE_TYPE_CACHE, _RET_IP_, ret,
> > > +			     s->objsize, s->size, gfpflags);
> > > +
> > > +	return ret;
> > >  }
> > 
> > _RET_IP == __builtin_return_address(0) right? Put that into a local variable?
> > At least we need consistent usage within one function. Maybe convert
> > __builtin_return_address(0) to _RET_IP_ within slub?
> 
> I think we should just convert SLUB to use _RET_IP_ everywhere. Eduard,
> care to make a patch and send it and rebase this on top of that?

Sure. Will get back soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
