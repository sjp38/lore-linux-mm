Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id F193E6B0565
	for <linux-mm@kvack.org>; Wed,  9 May 2018 14:49:35 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id a25so13120193uak.7
        for <linux-mm@kvack.org>; Wed, 09 May 2018 11:49:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a24sor10637254uah.14.2018.05.09.11.49.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 11:49:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b481bbb2-758f-dcd3-3e1a-8b3137081614@rasmusvillemoes.dk>
References: <20180509004229.36341-1-keescook@chromium.org> <20180509004229.36341-4-keescook@chromium.org>
 <b481bbb2-758f-dcd3-3e1a-8b3137081614@rasmusvillemoes.dk>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 9 May 2018 11:49:33 -0700
Message-ID: <CAGXu5jJFdDOJAxN+zsRmCMRRQd=rLR6Qpo8pbeBtUmsM32Gh+Q@mail.gmail.com>
Subject: Re: [PATCH 03/13] overflow.h: Add allocation size calculation helpers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, May 9, 2018 at 11:27 AM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> On 2018-05-09 02:42, Kees Cook wrote:
>> In preparation for replacing unchecked overflows for memory allocations,
>> this creates helpers for the 3 most common calculations:
>>
>> array_size(a, b): 2-dimensional array
>> array3_size(a, b, c): 2-dimensional array
>
> yeah... complete confusion...
>
>> +/**
>> + * array_size() - Calculate size of 2-dimensional array.
>> + *
>> + * @a: dimension one
>> + * @b: dimension two
>> + *
>> + * Calculates size of 2-dimensional array: @a * @b.
>> + *
>> + * Returns: number of bytes needed to represent the array or SIZE_MAX on
>> + * overflow.
>> + */
>> +static inline __must_check size_t array_size(size_t a, size_t b)
>> +{
>> +     size_t bytes;
>> +
>> +     if (check_mul_overflow(a, b, &bytes))
>> +             return SIZE_MAX;
>> +
>> +     return bytes;
>> +}
>> +
>> +/**
>> + * array3_size() - Calculate size of 3-dimensional array.
>> + *
>
> ...IDGI. array_size is/will most often be used to calculate the size of
> a one-dimensional array, count*elemsize, accessed as foo[i]. Won't a
> three-factor product usually be dim1*dim2*elemsize, i.e. 2-dimensional,
> accessed (because C is lame) as foo[i*dim2 + j]?

I was thinking of byte addressing, not object addressing. I can
rewrite this to be less confusing.

>> +/**
>> + * struct_size() - Calculate size of structure with trailing array.
>> + * @p: Pointer to the structure.
>> + * @member: Name of the array member.
>> + * @n: Number of elements in the array.
>> + *
>> + * Calculates size of memory needed for structure @p followed by an
>> + * array of @n @member elements.
>> + *
>> + * Return: number of bytes needed or SIZE_MAX on overflow.
>> + */
>> +#define struct_size(p, member, n)                                    \
>> +     __ab_c_size(n,                                                  \
>> +                 sizeof(*(p)->member) + __must_be_array((p)->member),\
>> +                 offsetof(typeof(*(p)), member))
>> +
>> +
>
> struct s { int a; char b; char c[]; } has sizeof > offsetof(c), so for
> small enough n, we end up allocating less than sizeof(struct s). And the
> caller might reasonably do memset(s, 0, sizeof(*s)) to initialize all
> members before c. In practice our allocators round up to a multiple of
> 8, so I don't think it's a big problem, but some sanitizer might
> complain. But I do think you should make that addend sizeof() instead of
> offsetof().

Erg. Yeah, I think we'd best "round up". Besides the "< sizeof()" vs
memset() case you mention, another pattern I've seen is doing stuff
like:

array = (array_type *)(thing + 1);

So if padding somehow caused us to under-allocate, we'll get it wrong there too.

I'll change this to be strictly sizeof(*(p)).

(Though it might be nice to enforce that "member" is at the end of the
structure, though, otherwise this could be misused for struct s { int
a; char c[2]; char b[]; } ... )

-Kees

-- 
Kees Cook
Pixel Security
