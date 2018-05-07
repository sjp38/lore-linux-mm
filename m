Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65D696B0266
	for <linux-mm@kvack.org>; Mon,  7 May 2018 17:41:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so20015571wrg.11
        for <linux-mm@kvack.org>; Mon, 07 May 2018 14:41:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r56-v6sor16621724edr.30.2018.05.07.14.41.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 14:41:14 -0700 (PDT)
Subject: Re: *alloc API changes
References: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
 <20180505034646.GA20495@bombadil.infradead.org>
 <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <ee9322c7-801b-c88c-d78c-32d38dac32c1@rasmusvillemoes.dk>
Date: Mon, 7 May 2018 23:41:13 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLbbts6Do5JtX8+fij0m=wEZ30W+k9PQAZ_ddOnpuPHZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>, Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018-05-05 06:24, Kees Cook wrote:
> 
>> Right, I was thinking:
>>
>> static inline size_t mul_ab(size_t a, size_t b)
>> {
>> #if COMPILER_SUPPORTS_OVERFLOW
>>         unsigned long c;
>>         if (__builtin_mul_overflow(a, b, &c))
>>                 return SIZE_MAX;
>>         return c;
>> #else
>>         if (b != 0 && a >= SIZE_MAX / b)
>>                 return SIZE_MAX;
>>         return a * b;
>> #endif
>> }
> 
> Rasmus, what do you think of a saturating version of your helpers?

They'd be trivial to implement (using the __type_max that I had to
introduce anyway), and I'd prefer they'd have sat_ in their name - not
just smult, s would more likely be interpreted as "signed". On that
note, I'd want to enforce the sat_ ones are only used for unsigned
types, because there's no sane value to saturate to for signed operands.

But I don't think we should do the allocation-overflow in terms of
saturate-and-rely-on-allocator-rejecting it. I suppose we'll still have
the computation done in a static inline (to let the compiler see if one
or both operands are constants, and generate code accordingly). If we do

static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
{
        size_t p;
        p = sat_mul(n, size);
        return __kmalloc(p, flags);
}

with sat_mul being implemented in terms of __builtin_mul_overflow(), gcc
will probably waste a temp register on loading SIZE_MAX (or whatever
sentinel we use), and do a pipeline-stalling cmov to the register used
to pass p.

If instead we do

static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
{
        size_t p;
        if (check_mul_overflow(n, size, &p))
            return NULL;
        return __kmalloc(p, flags);
}

we'd not get any extra code in the caller (that is, just a "mul" and
"jo", instead of a load-immediate, mul, cmov), because gcc should be
smart enough to combine the "return NULL" with the test for NULL which
the caller code has, and thus make the jump go directly to the error
handling (that error handling is likely itself a jump, but the "jo" will
just get redirected to the target of that one).

Also, I'd hate to have sat_mul not really saturating to type_max(t), but
some large-enough-that-all-underlying-allocators-reject-it.

> The only fear I have with the saturating helpers is that we'll end up
> using them in places that don't recognize SIZE_MAX. Like, say:
> 
> size = mul(a, b) + 1;
> 
> then *poof* size == 0. Now, I'd hope that code would use add(mul(a,
> b), 1), but still... it makes me nervous.
> 
>> You don't need the size check here.  We have the size check buried deep in
>> alloc_pages (look for MAX_ORDER), so kmalloc and then alloc_pages will try
>> a bunch of paths all of which fail before returning NULL.
> 
> Good point. Though it does kind of creep me out to let a known-bad
> size float around in the allocator until it decides to reject it. I
> would think an early:
> 
> if (unlikely(size == SIZE_MAX))
>     return NULL;
> 
> would have virtually no cycle count difference...

All allocators still need to reject insane sizes, since those can happen
without coming from a multiplication. So sure, some early size >
MAX_SANE_SIZE check in the out-of-line functions should be rather cheap,
and they most likely already exist in some form. But we don't _have_ to
go out of our way to make the multiplication overflow handling depend on
those.

> 
> Right, no. I think if we can ditch *calloc() and _array() by using
> saturating helpers, we'll have the API in a much better form:
> 
> kmalloc(foo * bar, GFP_KERNEL);
> into
> kmalloc_array(foo, bar, GFP_KERNEL);
> into
> kmalloc(mul(foo, bar), GFP_KERNEL);

Urgh. Do you want to get completely rid of kmalloc_array() and move the
mul() into the call-sites? That obviously necessitates mul returning a
big-enough sentinel. I'd hate that. Not just because of the code-gen,
but also because of the problem with giving mul() sane semantics that
still make it immune to the extra arithmetic that will inevitably be
done. There's also the problem with foo and bar having different,
possibly signed, types - how should mul() handle those? A nice benefit
from having the static inline wrappers taking size_t is that a negative
value gets converted to a huge positive value, and then the whole thing
overflows. Sure, you can build that into mul() (maybe make that itself a
static inline), but then it doesn't really deserve that generic name
anymore.

> and
> 
> kmalloc(foo * bar, GFP_KERNEL | __GFP_ZERO);
> into
> kzalloc(foo * bar, GFP_KERNEL);
> into
> kcalloc(foo, bar, GFP_KERNEL);
> into
> kzalloc(mul(foo, bar), GFP_KERNEL);

Yeah, part of the API mess is just copied from C (malloc vs calloc). We
could make it a bit less messy by calling it kzalloc_array, but we have
1700 callers of kcalloc(), so...

Rasmus
