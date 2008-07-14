Received: by ag-out-0708.google.com with SMTP id 22so8592086agd.8
        for <linux-mm@kvack.org>; Mon, 14 Jul 2008 11:38:47 -0700 (PDT)
Date: Mon, 14 Jul 2008 21:37:34 +0300
From: eduard.munteanu@linux360.ro
Subject: Re: [RESEND PATCH] kmemtrace: SLAB hooks.
Message-ID: <20080714183734.GB3960@localhost>
References: <487B7F99.4060004@linux-foundation.org> <1216057334-27239-1-git-send-email-eduard.munteanu@linux360.ro> <1216059588.6762.20.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1216059588.6762.20.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 14, 2008 at 09:19:48PM +0300, Pekka Enberg wrote:
> Hi Eduard-Gabriel,
> 
> On Mon, 2008-07-14 at 20:42 +0300, Eduard - Gabriel Munteanu wrote:
> > This adds hooks for the SLAB allocator, to allow tracing with
> > kmemtrace.
> > 
> > Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> > @@ -28,8 +29,20 @@ extern struct cache_sizes malloc_sizes[];
> >  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
> >  void *__kmalloc(size_t size, gfp_t flags);
> >  
> > +#ifdef CONFIG_KMEMTRACE
> > +extern void *__kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags);
> > +#else
> > +static inline void *__kmem_cache_alloc(struct kmem_cache *cachep,
> > +				       gfp_t flags)
> > +{
> > +	return kmem_cache_alloc(cachep, flags);
> > +}
> > +#endif
> > +
> 
> I'm okay with this approach but then you need to do
> s/__kmem_cache_alloc/kmem_cache_alloc_trace/ or similar. In the kernel,
> it's always the *upper* level function that doesn't have the
> underscores.

Hmm, doesn't really make sense:
1. This should be called kmem_cache_alloc_notrace, not *_trace.
__kmem_cache_alloc() _disables_ tracing.
2. __kmem_cache_alloc is not really upper level now, since it's called
only in kmalloc. So it's an internal function which is not supposed to
be used by other kernel code.

Are you sure I should do this?


	Eduard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
