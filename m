Received: by an-out-0708.google.com with SMTP id d33so154632and
        for <linux-mm@kvack.org>; Thu, 02 Aug 2007 16:10:02 -0700 (PDT)
Message-ID: <9a8748490708021610k31a86c17y58fb631a36dfdb6a@mail.gmail.com>
Date: Fri, 3 Aug 2007 01:10:02 +0200
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] Fix two potential mem leaks in MPT Fusion (mpt_attach())
In-Reply-To: <20070802160406.5c5b5ff6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200708020155.33690.jesper.juhl@gmail.com>
	 <20070801172653.1fd44e99.akpm@linux-foundation.org>
	 <9a8748490708020120w4bbfe6d1n6f6986aec507316@mail.gmail.com>
	 <200708030053.45297.jesper.juhl@gmail.com>
	 <20070802160406.5c5b5ff6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@steeleye.com>, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On 03/08/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 3 Aug 2007 00:53:44 +0200
> Jesper Juhl <jesper.juhl@gmail.com> wrote:
>
> > On Thursday 02 August 2007 10:20:47 Jesper Juhl wrote:
> > > On 02/08/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > [snip]
> > > > y'know, we could have a debug option which will spit warnings if someone
> > > > does a !__GFP_WAIT allocation while !in_atomic() (only works if
> > > > CONFIG_PREEMPT).
> > > >
> > > > But please, make it depend on !CONFIG_AKPM.  I shudder to think about all
> > > > the stuff it would pick up.
> > > >
> > >
> > > I can try to cook up something like that tonight...
> > >
> >
> > Ok, so I did a quick hack and I'm drowning in dmesg WARN_ON() traces
> > with my usual config.
> >
> > This is what I added :
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 6c6d74f..e60dd9e 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -20,6 +20,7 @@
> >  #include <linux/mempolicy.h>
> >  #include <linux/ctype.h>
> >  #include <linux/kallsyms.h>
> > +#include <linux/hardirq.h>
> >
> >  /*
> >   * Lock order:
> > @@ -1568,6 +1569,10 @@ static void __always_inline *slab_alloc(struct kmem_cache *s,
> >
> >  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
> >  {
> > +#ifdef CONFIG_PREEMPT
> > +     WARN_ON( !in_atomic() && !(gfpflags & __GFP_WAIT) );
> > +#endif
> > +
> >       return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> >  }
> >  EXPORT_SYMBOL(kmem_cache_alloc);
> > @@ -2370,6 +2375,10 @@ void *__kmalloc(size_t size, gfp_t flags)
> >  {
> >       struct kmem_cache *s = get_slab(size, flags);
> >
> > +#ifdef CONFIG_PREEMPT
> > +     WARN_ON( !in_atomic() && !(flags & __GFP_WAIT) );
> > +#endif
> > +
> >       if (ZERO_OR_NULL_PTR(s))
> >               return s;
> >
> >
> >
> > And this is what I'm getting heaps of :
> >
> > ...
> > [  165.128607]  =======================
> > [  165.128609] WARNING: at mm/slub.c:1573 kmem_cache_alloc()
> > [  165.128611]  [<c010400a>] show_trace_log_lvl+0x1a/0x30
> > [  165.128614]  [<c0104cd2>] show_trace+0x12/0x20
> > [  165.128616]  [<c0104cf6>] dump_stack+0x16/0x20
> > [  165.128619]  [<c0175ad3>] kmem_cache_alloc+0xe3/0x110
> > [  165.128622]  [<c015b10e>] mempool_alloc_slab+0xe/0x10
> > [  165.128625]  [<c015b211>] mempool_alloc+0x31/0xf0
>
> I said you would.
>
Hehe, I know you did. I'm not complaining, simply stating facts
(confirming what you said actually).

> > So, where do we go from here?
>
> Where I said ;) Add a new __GFP_ flag which suppresses the warning, add
> that flag to known-to-be-OK callsites, such as mempool_alloc().
>
Ok, I'll try to play around with this some more, try to filter out
false positives and see what I'm left with (if anything - I'm pretty
limited hardware-wise, so I can only test a small subset of drivers,
archs etc) - I'll keep you informed, but expect a few days to pass
before I have any news...


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
