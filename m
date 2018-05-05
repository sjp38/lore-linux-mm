Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07ECA6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 23:46:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s17-v6so824884pgq.23
        for <linux-mm@kvack.org>; Fri, 04 May 2018 20:46:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a10si5080727pfn.256.2018.05.04.20.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 20:46:51 -0700 (PDT)
Date: Fri, 4 May 2018 20:46:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: *alloc API changes
Message-ID: <20180505034646.GA20495@bombadil.infradead.org>
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Fri, May 04, 2018 at 06:08:23PM -0700, Kees Cook wrote:
> The number of permutations for our various allocation function is
> rather huge. Currently, it is:
> 
> system or wrapper:
> kmem_cache_alloc, kmalloc, vmalloc, kvmalloc, devm_kmalloc,
> dma_alloc_coherent, pci_alloc_consistent, kmem_alloc, f2fs_kvalloc,
> and probably others I haven't found yet.

dma_pool_alloc, page_frag_alloc, gen_pool_alloc, __alloc_bootmem_node,
cma_alloc, quicklist_alloc (deprecated), mempool_alloc

and if you're counting f2fs_*alloc, there's a metric tonne of *alloc
wrappers out there.

> allocation method (not all available in all APIs):
> regular (kmalloc), zeroed (kzalloc), array (kmalloc_array), zeroed
> array (kcalloc)

... other initialiser (kmem_cache_alloc)

> I wonder if we might be able to rearrange our APIs for the general
> case and include a common "kitchen sink" API for the less common
> options. I.e. why do we have an entire set of _node() APIs, 2 sets for
> zeroing (kzalloc, kcalloc), etc.

I'd love it if we had a common pattern for these things.  A regular API
appeals to me (I blame those RISC people in my formative years).

> kmalloc()-family was meant to be a simplification of
> kmem_cache_alloc().

That's a little revisionist ;-)  We had kmalloc before we had the slab
allocator (kernel 1.2, I think?).  But I see your point, and that's
certainly how it's implemented these days.

> vmalloc() duplicated the kmalloc()-family, and
> kvmalloc() does too. Then we have "specialty" allocators (devm, dma,
> pci, f2fs, xfs's kmem) that have subsets and want to perform other
> actions around the base allocators or have their own entirely (e.g.
> dma).
> 
> Instead of all the variations, it seems like we just want a per-family
> alloc() and alloc_attrs(), where alloc_attrs() could handle the less
> common stuff (e.g. gfp, zero, node).
> 
> kmalloc(size, GFP_KERNEL)
> becomes a nice:
> kmalloc(size)

I got shot down for proposing adding
#define malloc(x) kmalloc(x, GFP_KERNEL)
on the grounds that driver writers will then use malloc in interrupt
context.  So I think our base version has to be foo_alloc(size, gfp_t).

> But this doesn't solve the multiplication overflow case at all, which
> is my real goal. Trying to incorporate some of the ideas from other
> threads, maybe we could have a multiplication helper that would
> saturate and the allocator would see that as a signal to return NULL?
> e.g.:
> 
> inline size_t mult(size_t a, size_t b)
> {
>     if (b != 0 && a >= SIZE_MAX / b)
>         return SIZE_MAX;
>     return a * b;
> }
> (really, this kind of helper should be based on Rasmus's helpers which
> do correct type handling)

Right, I was thinking:

static inline size_t mul_ab(size_t a, size_t b)
{
#if COMPILER_SUPPORTS_OVERFLOW
	unsigned long c;
	if (__builtin_mul_overflow(a, b, &c))
		return SIZE_MAX;
	return c;
#else
	if (b != 0 && a >= SIZE_MAX / b)
		return SIZE_MAX;
	return a * b;
#endif
}

> void *kmalloc(size_t size)
> {
>     if (size == SIZE_MAX)
>         return NULL;
>     kmalloc_attrs(size, GFP_KERNEL, ALLOC_NOZERO, NUMA_NO_NODE);
> }

You don't need the size check here.  We have the size check buried deep in
alloc_pages (look for MAX_ORDER), so kmalloc and then alloc_pages will try
a bunch of paths all of which fail before returning NULL.

> then we get:
> var = kmalloc(mult(num, sizeof(*var)));
> 
> we could drop the *calloc(), *zalloc(), and *_array(), leaving only
> *alloc() and *alloc_attrs() for all the allocator families.
> 
> I honestly can't tell if this is worse than doing all the family
> conversions to *calloc() and *_array() for the 1000ish instances of
> 2-factor products used for size arguments in the *alloc() functions.
> We could still nest them for the 3-factor ones?
> var = kmalloc(multi(row, mult(column, sizeof(*var))));
> 
> But now we're just pretending to be LISP.

I'd rather have a mul_ab(), mul_abc(), mul_ab_add_c(), etc. than nest
calls to mult().

> And really, I'd like to keep the nicer *alloc_struct() with all its
> type checking. But then do we do *zalloc_struct(),
> *alloc_struct_node(), etc, etc?

Nono, Linus had the better proposal, struct_size(p, member, n).

> Bleh. C sucks for this.

Ooh, we could instantiate classes and ... yeah, no, not C++.  We *could*
abuse the C preprocessor to autogenerate every variant, but I hate that
because you can't grep for it.

One of the problems with having the single-argument foo_alloc be a static
inline for foo_alloc_attrs is that you then have to marshall four arguments
for the call instead of just one.  I would have two exported symbols for
each variant.
