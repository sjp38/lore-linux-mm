Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2056B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 18:29:42 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id l81-v6so8055685vkd.18
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 15:29:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 132-v6sor3539785vkb.205.2018.04.30.15.29.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 15:29:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180430201607.GA7041@bombadil.infradead.org>
References: <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
 <alpine.DEB.2.20.1803072212160.2814@hadrien> <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien> <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien> <20180313183220.GA21538@bombadil.infradead.org>
 <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com>
 <20180429203023.GA11891@bombadil.infradead.org> <CAGXu5j+N9tt4rxaUMxoZnE-ziqU_yu-jkt-cBZ=R8wmYq6XBTg@mail.gmail.com>
 <20180430201607.GA7041@bombadil.infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 30 Apr 2018 15:29:39 -0700
Message-ID: <CAGXu5jKAWm5Hr7ixbJuAUBNDxeO1i1sExFJmWDKd2SaxbTF1Ow@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On Mon, Apr 30, 2018 at 1:16 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Mon, Apr 30, 2018 at 12:02:14PM -0700, Kees Cook wrote:
>> For any longer multiplications, I've only found[1]:
>>
>> drivers/staging/rtl8188eu/os_dep/osdep_service.c:       void **a =
>> kzalloc(h * sizeof(void *) + h * w * size, GFP_KERNEL);
>
> That's pretty good, although it's just an atrocious vendor driver and
> it turns out all of those things are constants, and it'd be far better
> off with just declaring an array.  I bet they used to declare one on
> the stack ...

Yeah, it was just a quick hack to look for stuff.

>
>> At the end of the day, though, I don't really like having all these
>> different names...
>>
>> kmalloc(), kmalloc_array(), kmalloc_ab_c(), kmalloc_array_3d()
>>
>> with their "matching" zeroing function:
>>
>> kzalloc(), kcalloc(), kzalloc_ab_c(), kmalloc_array_3d(..., gfp | __GFP_ZERO)
>
> Yes, it's not very regular.
>
>> For the multiplication cases, I wonder if we could just have:
>>
>> kmalloc_multN(gfp, a, b, c, ...)
>> kzalloc_multN(gfp, a, b, c, ...)
>>
>> and we can replace all kcalloc() users with kzalloc_mult2(), all
>> kmalloc_array() users with kmalloc_mult2(), the abc uses with
>> kmalloc_mult3().
>
> I'm reluctant to do away with kcalloc() as it has the obvious heritage
> from user-space calloc() with the addition of GFP flags.

But it encourages misuse with calloc(N * M, gfp) ... if we removed
calloc and kept k[mz]alloc_something(gfp, a, b, c...) I think we'd
have better adoption.

>> That said, I *do* like kmalloc_struct() as it's a very common pattern...
>
> Thanks!  And way harder to misuse than kmalloc_ab_c().

Yes, quite so. It's really why I went with kmalloc_array_3d(), but now
I'm thinking better of it...

>> Or maybe, just leave the pattern in the name? kmalloc_ab(),
>> kmalloc_abc(), kmalloc_ab_c(), kmalloc_ab_cd() ?
>>
>> Getting the constant ordering right could be part of the macro
>> definition, maybe? i.e.:
>>
>> static inline void *kmalloc_ab(size_t a, size_t b, gfp_t flags)
>> {
>>     if (__builtin_constant_p(a) && a != 0 && \
>>         b > SIZE_MAX / a)
>>             return NULL;
>>     else if (__builtin_constant_p(b) && b != 0 && \
>>                a > SIZE_MAX / b)
>>             return NULL;
>>
>>     return kmalloc(a * b, flags);
>> }
>
> Ooh, if neither a nor b is constant, it just didn't do a check ;-(  This
> stuff is hard.

Yup, quite true. Obviously not the final form. ;) I meant to
illustrate that we could do compile-time tricks to reorder the
division in an efficient manner.

>> (I just wish C had a sensible way to catch overflow...)
>
> Every CPU I ever worked with had an "overflow" bit ... do we have a
> friend on the C standards ctte who might figure out a way to let us
> write code that checks it?

On the CPU it's not retained across multiple calculations. And the
type matters too. This came up recently in a separate thread too:
http://openwall.com/lists/kernel-hardening/2018/03/26/4

>> [1] git grep -E 'alloc\([^,]+[^(]\*[^)][^,]+[^(]\*[^)][^,]+[^(]\*[^)][^,]+,'
>
> I'm impressed, but it's not going to catch
>
>         veryLongPointerNameThatsMeaningfulToMe = kmalloc(initialSize +
>                 numberOfEntries * entrySize + someOtherThing * yourMum,
>                 GFP_KERNEL);

Right, it wasn't meant to be exhaustive. I just included it in case
anyone wanted to go grepping around for themselves.

-Kees

-- 
Kees Cook
Pixel Security
