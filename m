Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1655F6B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 15:02:17 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id h9so8815634uac.3
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 12:02:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b128-v6sor3389094vkf.99.2018.04.30.12.02.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 12:02:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180429203023.GA11891@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org>
 <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
 <alpine.DEB.2.20.1803072212160.2814@hadrien> <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien> <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien> <20180313183220.GA21538@bombadil.infradead.org>
 <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com> <20180429203023.GA11891@bombadil.infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 30 Apr 2018 12:02:14 -0700
Message-ID: <CAGXu5j+N9tt4rxaUMxoZnE-ziqU_yu-jkt-cBZ=R8wmYq6XBTg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On Sun, Apr 29, 2018 at 1:30 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Sun, Apr 29, 2018 at 09:59:27AM -0700, Kees Cook wrote:
>> Did this ever happen?
>
> Not yet.  I brought it up at LSFMM, and I'll repost the patches soon.
>
>> I'd also like to see kmalloc_array_3d() or
>> something that takes three size arguments. We have a lot of this
>> pattern too:
>>
>> kmalloc(sizeof(foo) * A * B, gfp...)
>>
>> And we could turn that into:
>>
>> kmalloc_array_3d(sizeof(foo), A, B, gfp...)
>
> Are either of A or B constant?  Because if so, we could just use
> kmalloc_array.  If not, then kmalloc_array_3d becomes a little more
> expensive than kmalloc_array because we have to do a divide at runtime
> instead of compile-time.  that's still better than allocating too few
> bytes, of course.

Yeah, getting the order of the division is nice. Some thoughts below...

>
> I'm wondering how far down the abc + ab + ac + bc + d rabbit-hole we're
> going to end up going.  As far as we have to, I guess.

Well, the common patterns I've seen so far are:

a
ab
abc
a + bc
ab + cd

For any longer multiplications, I've only found[1]:

drivers/staging/rtl8188eu/os_dep/osdep_service.c:       void **a =
kzalloc(h * sizeof(void *) + h * w * size, GFP_KERNEL);


At the end of the day, though, I don't really like having all these
different names...

kmalloc(), kmalloc_array(), kmalloc_ab_c(), kmalloc_array_3d()

with their "matching" zeroing function:

kzalloc(), kcalloc(), kzalloc_ab_c(), kmalloc_array_3d(..., gfp | __GFP_ZERO)

For the multiplication cases, I wonder if we could just have:

kmalloc_multN(gfp, a, b, c, ...)
kzalloc_multN(gfp, a, b, c, ...)

and we can replace all kcalloc() users with kzalloc_mult2(), all
kmalloc_array() users with kmalloc_mult2(), the abc uses with
kmalloc_mult3().

That said, I *do* like kmalloc_struct() as it's a very common pattern...

Or maybe, just leave the pattern in the name? kmalloc_ab(),
kmalloc_abc(), kmalloc_ab_c(), kmalloc_ab_cd() ?

Getting the constant ordering right could be part of the macro
definition, maybe? i.e.:

static inline void *kmalloc_ab(size_t a, size_t b, gfp_t flags)
{
    if (__builtin_constant_p(a) && a != 0 && \
        b > SIZE_MAX / a)
            return NULL;
    else if (__builtin_constant_p(b) && b != 0 && \
               a > SIZE_MAX / b)
            return NULL;

    return kmalloc(a * b, flags);
}

(I just wish C had a sensible way to catch overflow...)

-Kees

[1] git grep -E 'alloc\([^,]+[^(]\*[^)][^,]+[^(]\*[^)][^,]+[^(]\*[^)][^,]+,'

-- 
Kees Cook
Pixel Security
