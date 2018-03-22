Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E8A6F6B0026
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:42:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 69-v6so5673930plc.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:42:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n1si5167136pfa.94.2018.03.22.09.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 09:41:59 -0700 (PDT)
Date: Thu, 22 Mar 2018 09:41:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 6/8] page_frag_cache: Use a mask instead of offset
Message-ID: <20180322164157.GE28468@bombadil.infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
 <20180322153157.10447-7-willy@infradead.org>
 <CAKgT0UfcYLm3UZcq536cNOczVhR60qoFDHh_gcXqqyqdViuLzw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UfcYLm3UZcq536cNOczVhR60qoFDHh_gcXqqyqdViuLzw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, Mar 22, 2018 at 09:22:31AM -0700, Alexander Duyck wrote:
> On Thu, Mar 22, 2018 at 8:31 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > By combining 'va' and 'offset' into 'addr' and using a mask instead,
> > we can save a compare-and-branch in the fast-path of the allocator.
> > This removes 4 instructions on x86 (both 32 and 64 bit).
> 
> What is the point of renaming "va"? I'm seeing a lot of unneeded
> renaming in these patches that doesn't really seem needed and is just
> making things harder to review.

By renaming 'va', I made sure that I saw everywhere that 'va' was touched,
and reviewed it to be sure it was still correct with the new meaning.
The advantage of keeping that in the patch submission, rather than
renaming it back again, is that you can see everywhere that it's been
touched and verify that for yourself.

> > We can avoid storing the mask at all if we know that we're only allocating
> > a single page.  This shrinks page_frag_cache from 12 to 8 bytes on 32-bit
> > CONFIG_BASE_SMALL build.
> >
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> So I am not really a fan of CONFIG_BASE_SMALL in general, so
> advertising gains in size is just going back down the reducing size at
> the expense of performance train of thought.

There's no tradeoff for performance *in this patch* with
CONFIG_BASE_SMALL.  Indeed, being able to assume that the cache contains a
single PAGE_SIZE page reduces the number of instructions by two on x86-64
(and is neutral on x86-32).  IIRC it saves a register, so there's one fewer
'push' at the beginning of the function and one fewer 'pop' at the end.

I think the more compelling argument for conditioning the number of pages
allocated on CONFIG_BASE_SMALL is that a machine which needs to shrink
its data structures so badly isn't going to have 32k of memory available,
nor want to spend it on a networking allocation.  Eric's commit which
introduced NETDEV_FRAG_PAGE_MAX_ORDER back in 2012 (69b08f62e174) didn't
mention small machines as a consideration.

> Do we know for certain that a higher order page is always aligned to
> the size of the higher order page itself? That is one thing I have
> never been certain about. I know for example there are head and tail
> pages so I was never certain if it was possible to create a higher
> order page that is not aligned to to the size of the page itself.

It's intrinsic to the buddy allocator that pages are naturally aligned
to their order.  There's a lot of code in the kernel which relies on
it, including much of the mm (particularly THP).  I suppose one could
construct a non-aligned compound page, but it'd be really weird, and you'd
have to split it up manually before handing it back to the page allocator.
I don't see this ever changing.

> >  struct page_frag_cache {
> > -       void * va;
> > +       void *addr;
> >  #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
> > -       __u16 offset;
> > -       __u16 size;
> > -#else
> > -       __u32 offset;
> > +       unsigned int mask;
> 
> So this is just an akward layout. You now have essentially:
> #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
> #else
>     unsigned int mask;
> #endif

Huh?  There's a '-' in front of the '#else'.  It looks like this:

struct page_frag_cache {
        void *addr;
#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
        unsigned int mask;
#endif
        /* we maintain a pagecount bias, so that we dont dirty cache line
         * containing page->_refcount every time we allocate a fragment.
         */
        unsigned int            pagecnt_bias;
};

> > @@ -4364,27 +4361,24 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *pfc,
> >                                 PAGE_FRAG_CACHE_MAX_ORDER);PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
> >         if (page)
> >                 size = PAGE_FRAG_CACHE_MAX_SIZE;
> > -       pfc->size = size;
> > +       pfc->mask = size - 1;
> >  #endif
> >         if (unlikely(!page))
> >                 page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
> >         if (!page) {
> > -               pfc->va = NULL;
> > +               pfc->addr = NULL;
> >                 return NULL;
> >         }
> >
> > -       pfc->va = page_address(page);
> > -
> >         /* Using atomic_set() would break get_page_unless_zero() users. */
> >         page_ref_add(page, size - 1);
> 
> You could just use the pfc->mask here instead of size - 1 just to
> avoid having to do the subtraction more than once assuming the
> compiler doesn't optimize it.

Either way I'm assuming a compiler optimisation -- that it won't reload
from memory, or that it'll remember the subtraction.  I don't much care
which, and I'll happily use the page_frag_cache_mask() if that reads better
for you.
