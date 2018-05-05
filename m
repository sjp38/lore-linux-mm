Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 919536B000C
	for <linux-mm@kvack.org>; Sat,  5 May 2018 00:25:00 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id k12-v6so18762869vke.15
        for <linux-mm@kvack.org>; Fri, 04 May 2018 21:25:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 184-v6sor8012374vkc.72.2018.05.04.21.24.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 21:24:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180505034646.GA20495@bombadil.infradead.org>
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
 <20180505034646.GA20495@bombadil.infradead.org>
From: Kees Cook <keescook@google.com>
Date: Fri, 4 May 2018 21:24:56 -0700
Message-ID: <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
Subject: Re: *alloc API changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Fri, May 4, 2018 at 8:46 PM, Matthew Wilcox <willy@infradead.org> wrote:
> and if you're counting f2fs_*alloc, there's a metric tonne of *alloc
> wrappers out there.

Yeah. *sob*

> That's a little revisionist ;-)  We had kmalloc before we had the slab
> allocator (kernel 1.2, I think?).  But I see your point, and that's
> certainly how it's implemented these days.

Okay, yes, that's true. I did think of that briefly. :)

> I got shot down for proposing adding
> #define malloc(x) kmalloc(x, GFP_KERNEL)
> on the grounds that driver writers will then use malloc in interrupt
> context.  So I think our base version has to be foo_alloc(size, gfp_t).

Okay, fair enough.

> Right, I was thinking:
>
> static inline size_t mul_ab(size_t a, size_t b)
> {
> #if COMPILER_SUPPORTS_OVERFLOW
>         unsigned long c;
>         if (__builtin_mul_overflow(a, b, &c))
>                 return SIZE_MAX;
>         return c;
> #else
>         if (b != 0 && a >= SIZE_MAX / b)
>                 return SIZE_MAX;
>         return a * b;
> #endif
> }

Rasmus, what do you think of a saturating version of your helpers?

The only fear I have with the saturating helpers is that we'll end up
using them in places that don't recognize SIZE_MAX. Like, say:

size = mul(a, b) + 1;

then *poof* size == 0. Now, I'd hope that code would use add(mul(a,
b), 1), but still... it makes me nervous.

> You don't need the size check here.  We have the size check buried deep in
> alloc_pages (look for MAX_ORDER), so kmalloc and then alloc_pages will try
> a bunch of paths all of which fail before returning NULL.

Good point. Though it does kind of creep me out to let a known-bad
size float around in the allocator until it decides to reject it. I
would think an early:

if (unlikely(size == SIZE_MAX))
    return NULL;

would have virtually no cycle count difference...

> I'd rather have a mul_ab(), mul_abc(), mul_ab_add_c(), etc. than nest
> calls to mult().

Agreed. I think having exactly those would cover almost everything,
and the two places where a 4-factor product is needed could just nest
them. (bikeshed: the very common mul_ab() should just be mul(), IMO.)

> Nono, Linus had the better proposal, struct_size(p, member, n).

Oh, yes! I totally missed that in the threads.

> Ooh, we could instantiate classes and ... yeah, no, not C++.  We *could*
> abuse the C preprocessor to autogenerate every variant, but I hate that
> because you can't grep for it.

Right, no. I think if we can ditch *calloc() and _array() by using
saturating helpers, we'll have the API in a much better form:

kmalloc(foo * bar, GFP_KERNEL);
into
kmalloc_array(foo, bar, GFP_KERNEL);
into
kmalloc(mul(foo, bar), GFP_KERNEL);

and

kmalloc(foo * bar, GFP_KERNEL | __GFP_ZERO);
into
kzalloc(foo * bar, GFP_KERNEL);
into
kcalloc(foo, bar, GFP_KERNEL);
into
kzalloc(mul(foo, bar), GFP_KERNEL);

and the fun

kzalloc(sizeof(*header) + count * sizeof(*header->element), GFP_KERNEL);
into
kzalloc(struct_size(header, element, count), GFP_KERNEL);

modulo all *alloc* families...

?

-Kees

-- 
Kees Cook
Pixel Security
