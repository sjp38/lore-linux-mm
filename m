Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <200810081522.31739.nickpiggin@yahoo.com.au>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <84144f020810071031n39c27966ubfafd86e5542ea75@mail.gmail.com>
	 <1223420896.13453.427.camel@calx>
	 <200810081522.31739.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 07 Oct 2008 23:46:30 -0500
Message-Id: <1223441190.13453.459.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-08 at 15:22 +1100, Nick Piggin wrote:
> On Wednesday 08 October 2008 10:08, Matt Mackall wrote:
> > On Tue, 2008-10-07 at 20:31 +0300, Pekka Enberg wrote:
> > > Hi Matt,
> > >
> > > On Tue, Oct 7, 2008 at 8:13 PM, Matt Mackall <mpm@selenic.com> wrote:
> > > >> > @@ -515,7 +515,7 @@
> > > >> >
> > > >> >        sp = (struct slob_page *)virt_to_page(block);
> > > >> >        if (slob_page(sp))
> > > >> > -               return ((slob_t *)block - 1)->units + SLOB_UNIT;
> > > >> > +               return (((slob_t *)block - 1)->units - 1) *
> > > >> > SLOB_UNIT;
> > > >>
> > > >> Hmm. I don't understand why we do the "minus one" thing here. Aren't
> > > >> we underestimating the size now?
> > > >
> > > > The first -1 takes us to the object header in front of the object
> > > > pointer. The second -1 subtracts out the size of the header.
> > > >
> > > > But it's entirely possible I'm off by one, so I'll double-check. Nick?
> > >
> > > Yeah, I was referring to the second subtraction. Looking at
> > > slob_page_alloc(), for example, we compare the return value of
> > > slob_units() to SLOB_UNITS(size), so I don't think we count the header
> > > in ->units. I mean, we ought to be seeing the subtraction elsewhere in
> > > the code as well, no?
> >
> > Ok, I've looked a bit closer at it and I think we need a different fix.
> >
> > The underlying allocator, slob_alloc, takes a size in bytes and returns
> > an object of that size, with the first word containing the number of
> > slob_t units.
> >
> > kmalloc calls slob_alloc after adding on some space for header and
> > architecture padding. This space is not necessarily 1 slob unit:
> >
> >         unsigned int *m;
> >         int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> > ...
> >                 m = slob_alloc(size + align, gfp, align, node);
> >                 *m = size;
> >  	        return (void *)m + align;
> >
> > Note that we overwrite the header with our own size -in bytes-.
> > kfree does the reverse:
> 
> Right.
> 
> >                 int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> > 		unsigned int *m = (unsigned int *)(block - align);
> >                 slob_free(m, *m + align);
> >
> > That second line is locating the kmalloc header. All looks good.
> >
> > The MINALIGN business was introduced by Nick with:
> >
> >  slob: improved alignment handling
> >
> > but seems to have missed ksize, which should now be doing the following
> > to match:
> >
> > diff -r 5e32b09a1b2b mm/slob.c
> > --- a/mm/slob.c	Fri Oct 03 14:04:43 2008 -0500
> > +++ b/mm/slob.c	Tue Oct 07 18:05:15 2008 -0500
> > @@ -514,9 +514,11 @@
> >  		return 0;
> >
> >  	sp = (struct slob_page *)virt_to_page(block);
> > -	if (slob_page(sp))
> > -		return ((slob_t *)block - 1)->units + SLOB_UNIT;
> > -	else
> > +	if (slob_page(sp)) {
> > +		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> > +		unsigned int *m = (unsigned int *)(block - align);
> > +		return SLOB_UNITS(*m); /* round up */
> > +	} else
> >  		return sp->page.private;
> >  }
> 
> Yes, I came up with nearly the same patch before reading this
> 
> --- linux-2.6/mm/slob.c 2008-10-08 14:43:17.000000000 +1100
> +++ suth/mm/slob.c      2008-10-08 15:11:06.000000000 +1100
> @@ -514,9 +514,11 @@ size_t ksize(const void *block)
>                 return 0;
> 
>         sp = (struct slob_page *)virt_to_page(block);
> -       if (slob_page(sp))
> -               return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;
> -       else
> +       if (slob_page(sp)) {
> +               int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> +               unsigned int *m = (unsigned int *)(block - align);
> +               return *m + align;
> +       } else
>                 return sp->page.private;
>  }
> 
> However, mine is lifted directly from kfree, wheras you do something a
> bit different. Hmm, ksize arguably could be used to find the underlying
> allocated slab size in order to use a little bit more than we'd asked
> for. So probably we should really just `return *m` (don't round up or
> add any padding).

Huh? ksize should report how much space is available in the buffer. If
we request 33 bytes from SLUB and it gives us 64, ksize reports 64. If
we request 33 bytes from SLOB and it gives us 34, we should report 34.

> > That leaves the question of why this morning's patch worked at all,
> > given that it was based on how SLOB worked before Nick's patch. But I
> > haven't finished working through that. Peter, can I get you to test the
> > above?
> 
> I didn't have ksize in my slob user test harness, but added a couple of
> tests in there, and indeed ksize was returning complete garbage both
> before and after the latest patch to slob. I'd say it was simply luck.

I was going to dig your harness up this morning and realized it was on
my dead laptop. Send me another copy?

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
