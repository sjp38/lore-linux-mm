Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2546B0008
	for <linux-mm@kvack.org>; Mon,  7 May 2018 18:56:27 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 65so9578386uaq.20
        for <linux-mm@kvack.org>; Mon, 07 May 2018 15:56:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 14sor9891053uaq.36.2018.05.07.15.56.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 15:56:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ee9322c7-801b-c88c-d78c-32d38dac32c1@rasmusvillemoes.dk>
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
 <20180505034646.GA20495@bombadil.infradead.org> <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
 <ee9322c7-801b-c88c-d78c-32d38dac32c1@rasmusvillemoes.dk>
From: Kees Cook <keescook@google.com>
Date: Mon, 7 May 2018 15:56:25 -0700
Message-ID: <CAGXu5jKvKqKNgATDrNEGsh3yWpeOTSv_TZUB=WHeJ75vKpE=fg@mail.gmail.com>
Subject: Re: *alloc API changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 7, 2018 at 2:41 PM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> If instead we do
>
> static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
> {
>         size_t p;
>         if (check_mul_overflow(n, size, &p))
>             return NULL;
>         return __kmalloc(p, flags);
> }
>
> we'd not get any extra code in the caller (that is, just a "mul" and
> "jo", instead of a load-immediate, mul, cmov), because gcc should be
> smart enough to combine the "return NULL" with the test for NULL which
> the caller code has, and thus make the jump go directly to the error
> handling (that error handling is likely itself a jump, but the "jo" will
> just get redirected to the target of that one).
>
> Also, I'd hate to have sat_mul not really saturating to type_max(t), but
> some large-enough-that-all-underlying-allocators-reject-it.

Yeah, this continues to worry me too.

> All allocators still need to reject insane sizes, since those can happen
> without coming from a multiplication. So sure, some early size >
> MAX_SANE_SIZE check in the out-of-line functions should be rather cheap,
> and they most likely already exist in some form. But we don't _have_ to
> go out of our way to make the multiplication overflow handling depend on
> those.
>
>>
>> Right, no. I think if we can ditch *calloc() and _array() by using
>> saturating helpers, we'll have the API in a much better form:
>>
>> kmalloc(foo * bar, GFP_KERNEL);
>> into
>> kmalloc_array(foo, bar, GFP_KERNEL);
>> into
>> kmalloc(mul(foo, bar), GFP_KERNEL);
>
> Urgh. Do you want to get completely rid of kmalloc_array() and move the
> mul() into the call-sites? That obviously necessitates mul returning a
> big-enough sentinel. I'd hate that. Not just because of the code-gen,
> but also because of the problem with giving mul() sane semantics that
> still make it immune to the extra arithmetic that will inevitably be
> done. There's also the problem with foo and bar having different,
> possibly signed, types - how should mul() handle those? A nice benefit
> from having the static inline wrappers taking size_t is that a negative
> value gets converted to a huge positive value, and then the whole thing
> overflows. Sure, you can build that into mul() (maybe make that itself a
> static inline), but then it doesn't really deserve that generic name
> anymore.

If the struct_size(), array_size(), and array3_size() all take size_t,
then I think we gain the same protection, yes? i.e. they are built out
of your overflow checking routines. Even though I'm nervous about
SIZE_MAX wrapping on other uses, I do agree that doing early rejection
in the allocators makes a lot more sense. I think we can have bot the
SIZE_MAX early-abort of "something went very wrong", and the internal
"I refuse to store that much" that is per-allocator-tuned.

>> kmalloc(foo * bar, GFP_KERNEL | __GFP_ZERO);
>> into
>> kzalloc(foo * bar, GFP_KERNEL);
>> into
>> kcalloc(foo, bar, GFP_KERNEL);
>> into
>> kzalloc(mul(foo, bar), GFP_KERNEL);
>
> Yeah, part of the API mess is just copied from C (malloc vs calloc). We
> could make it a bit less messy by calling it kzalloc_array, but we have
> 1700 callers of kcalloc(), so...

Coccinelle can fix those callers. ;) But we need to make sure we're
still generating sane machine code before we do that...

-Kees

-- 
Kees Cook
Pixel Security
