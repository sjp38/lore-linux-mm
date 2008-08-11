Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <48A046F5.2000505@linux-foundation.org>
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro>
	 <48A046F5.2000505@linux-foundation.org>
Date: Mon, 11 Aug 2008 17:09:34 +0300
Message-Id: <1218463774.7813.291.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, mathieu.desnoyers@polymtl.ca, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-11 at 09:04 -0500, Christoph Lameter wrote:
> Eduard - Gabriel Munteanu wrote:
> 
> 
> 
> >  static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> >  {
> > +	void *ret;
> > +
> >  	if (__builtin_constant_p(size) &&
> >  		size <= PAGE_SIZE && !(flags & SLUB_DMA)) {
> >  			struct kmem_cache *s = kmalloc_slab(size);
> > @@ -239,7 +280,13 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> >  		if (!s)
> >  			return ZERO_SIZE_PTR;
> >  
> > -		return kmem_cache_alloc_node(s, flags, node);
> > +		ret = kmem_cache_alloc_node_notrace(s, flags, node);
> > +
> > +		kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
> > +					  _THIS_IP_, ret,
> > +					  size, s->size, flags, node);
> > +
> > +		return ret;
> 
> You could simplify the stuff in slub.h if you would fall back to the uninlined
> functions in the case that kmemtrace is enabled. IMHO adding additional inline
> code here does grow these function to a size where inlining is not useful anymore.

So, if CONFIG_KMEMTRACE is enabled, make the inlined version go away
completely? I'm okay with that though I wonder if that means we now take
a performance hit when CONFIG_KMEMTRACE is enabled but tracing is
disabled at run-time...

> > diff --git a/mm/slub.c b/mm/slub.c
> > index 315c392..940145f 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -23,6 +23,7 @@
> >  #include <linux/kallsyms.h>
> >  #include <linux/memory.h>
> >  #include <linux/math64.h>
> > +#include <linux/kmemtrace.h>
> >  
> >  /*
> >   * Lock order:
> > @@ -1652,18 +1653,47 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
> >  
> >  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
> >  {
> > -	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> > +	void *ret = slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> > +
> > +	kmemtrace_mark_alloc(KMEMTRACE_TYPE_CACHE, _RET_IP_, ret,
> > +			     s->objsize, s->size, gfpflags);
> > +
> > +	return ret;
> >  }
> 
> _RET_IP == __builtin_return_address(0) right? Put that into a local variable?
> At least we need consistent usage within one function. Maybe convert
> __builtin_return_address(0) to _RET_IP_ within slub?

I think we should just convert SLUB to use _RET_IP_ everywhere. Eduard,
care to make a patch and send it and rebase this on top of that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
