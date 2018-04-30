Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 382046B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:16:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l85so6781271pfb.18
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 13:16:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z190-v6si1998856pgb.108.2018.04.30.13.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 13:16:13 -0700 (PDT)
Date: Mon, 30 Apr 2018 13:16:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180430201607.GA7041@bombadil.infradead.org>
References: <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
 <alpine.DEB.2.20.1803072212160.2814@hadrien>
 <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien>
 <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien>
 <20180313183220.GA21538@bombadil.infradead.org>
 <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com>
 <20180429203023.GA11891@bombadil.infradead.org>
 <CAGXu5j+N9tt4rxaUMxoZnE-ziqU_yu-jkt-cBZ=R8wmYq6XBTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+N9tt4rxaUMxoZnE-ziqU_yu-jkt-cBZ=R8wmYq6XBTg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On Mon, Apr 30, 2018 at 12:02:14PM -0700, Kees Cook wrote:
> On Sun, Apr 29, 2018 at 1:30 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Sun, Apr 29, 2018 at 09:59:27AM -0700, Kees Cook wrote:
> >> Did this ever happen?
> >
> > Not yet.  I brought it up at LSFMM, and I'll repost the patches soon.
> >
> >> I'd also like to see kmalloc_array_3d() or
> >> something that takes three size arguments. We have a lot of this
> >> pattern too:
> >>
> >> kmalloc(sizeof(foo) * A * B, gfp...)
> >>
> >> And we could turn that into:
> >>
> >> kmalloc_array_3d(sizeof(foo), A, B, gfp...)
> >
> > Are either of A or B constant?  Because if so, we could just use
> > kmalloc_array.  If not, then kmalloc_array_3d becomes a little more
> > expensive than kmalloc_array because we have to do a divide at runtime
> > instead of compile-time.  that's still better than allocating too few
> > bytes, of course.
> 
> Yeah, getting the order of the division is nice. Some thoughts below...
> 
> >
> > I'm wondering how far down the abc + ab + ac + bc + d rabbit-hole we're
> > going to end up going.  As far as we have to, I guess.
> 
> Well, the common patterns I've seen so far are:
> 
> a
> ab
> abc
> a + bc
> ab + cd
> 
> For any longer multiplications, I've only found[1]:
> 
> drivers/staging/rtl8188eu/os_dep/osdep_service.c:       void **a =
> kzalloc(h * sizeof(void *) + h * w * size, GFP_KERNEL);

That's pretty good, although it's just an atrocious vendor driver and
it turns out all of those things are constants, and it'd be far better
off with just declaring an array.  I bet they used to declare one on
the stack ...

> At the end of the day, though, I don't really like having all these
> different names...
> 
> kmalloc(), kmalloc_array(), kmalloc_ab_c(), kmalloc_array_3d()
> 
> with their "matching" zeroing function:
> 
> kzalloc(), kcalloc(), kzalloc_ab_c(), kmalloc_array_3d(..., gfp | __GFP_ZERO)

Yes, it's not very regular.

> For the multiplication cases, I wonder if we could just have:
> 
> kmalloc_multN(gfp, a, b, c, ...)
> kzalloc_multN(gfp, a, b, c, ...)
> 
> and we can replace all kcalloc() users with kzalloc_mult2(), all
> kmalloc_array() users with kmalloc_mult2(), the abc uses with
> kmalloc_mult3().

I'm reluctant to do away with kcalloc() as it has the obvious heritage
from user-space calloc() with the addition of GFP flags.

> That said, I *do* like kmalloc_struct() as it's a very common pattern...

Thanks!  And way harder to misuse than kmalloc_ab_c().

> Or maybe, just leave the pattern in the name? kmalloc_ab(),
> kmalloc_abc(), kmalloc_ab_c(), kmalloc_ab_cd() ?
> 
> Getting the constant ordering right could be part of the macro
> definition, maybe? i.e.:
> 
> static inline void *kmalloc_ab(size_t a, size_t b, gfp_t flags)
> {
>     if (__builtin_constant_p(a) && a != 0 && \
>         b > SIZE_MAX / a)
>             return NULL;
>     else if (__builtin_constant_p(b) && b != 0 && \
>                a > SIZE_MAX / b)
>             return NULL;
> 
>     return kmalloc(a * b, flags);
> }

Ooh, if neither a nor b is constant, it just didn't do a check ;-(  This
stuff is hard.

> (I just wish C had a sensible way to catch overflow...)

Every CPU I ever worked with had an "overflow" bit ... do we have a
friend on the C standards ctte who might figure out a way to let us
write code that checks it?

> -Kees
> 
> [1] git grep -E 'alloc\([^,]+[^(]\*[^)][^,]+[^(]\*[^)][^,]+[^(]\*[^)][^,]+,'

I'm impressed, but it's not going to catch

	veryLongPointerNameThatsMeaningfulToMe = kmalloc(initialSize +
		numberOfEntries * entrySize + someOtherThing * yourMum,
		GFP_KERNEL);
