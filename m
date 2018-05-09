Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7150D6B0562
	for <linux-mm@kvack.org>; Wed,  9 May 2018 14:27:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u56-v6so23742389wrf.18
        for <linux-mm@kvack.org>; Wed, 09 May 2018 11:27:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y22-v6sor20314482edi.53.2018.05.09.11.27.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 11:27:25 -0700 (PDT)
Subject: Re: [PATCH 03/13] overflow.h: Add allocation size calculation helpers
References: <20180509004229.36341-1-keescook@chromium.org>
 <20180509004229.36341-4-keescook@chromium.org>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <b481bbb2-758f-dcd3-3e1a-8b3137081614@rasmusvillemoes.dk>
Date: Wed, 9 May 2018 20:27:22 +0200
MIME-Version: 1.0
In-Reply-To: <20180509004229.36341-4-keescook@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Matthew Wilcox <mawilcox@microsoft.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On 2018-05-09 02:42, Kees Cook wrote:
> In preparation for replacing unchecked overflows for memory allocations,
> this creates helpers for the 3 most common calculations:
> 
> array_size(a, b): 2-dimensional array
> array3_size(a, b, c): 2-dimensional array

yeah... complete confusion...

> +/**
> + * array_size() - Calculate size of 2-dimensional array.
> + *
> + * @a: dimension one
> + * @b: dimension two
> + *
> + * Calculates size of 2-dimensional array: @a * @b.
> + *
> + * Returns: number of bytes needed to represent the array or SIZE_MAX on
> + * overflow.
> + */
> +static inline __must_check size_t array_size(size_t a, size_t b)
> +{
> +	size_t bytes;
> +
> +	if (check_mul_overflow(a, b, &bytes))
> +		return SIZE_MAX;
> +
> +	return bytes;
> +}
> +
> +/**
> + * array3_size() - Calculate size of 3-dimensional array.
> + *

...IDGI. array_size is/will most often be used to calculate the size of
a one-dimensional array, count*elemsize, accessed as foo[i]. Won't a
three-factor product usually be dim1*dim2*elemsize, i.e. 2-dimensional,
accessed (because C is lame) as foo[i*dim2 + j]?

> +/**
> + * struct_size() - Calculate size of structure with trailing array.
> + * @p: Pointer to the structure.
> + * @member: Name of the array member.
> + * @n: Number of elements in the array.
> + *
> + * Calculates size of memory needed for structure @p followed by an
> + * array of @n @member elements.
> + *
> + * Return: number of bytes needed or SIZE_MAX on overflow.
> + */
> +#define struct_size(p, member, n)					\
> +	__ab_c_size(n,							\
> +		    sizeof(*(p)->member) + __must_be_array((p)->member),\
> +		    offsetof(typeof(*(p)), member))
> +
> +

struct s { int a; char b; char c[]; } has sizeof > offsetof(c), so for
small enough n, we end up allocating less than sizeof(struct s). And the
caller might reasonably do memset(s, 0, sizeof(*s)) to initialize all
members before c. In practice our allocators round up to a multiple of
8, so I don't think it's a big problem, but some sanitizer might
complain. But I do think you should make that addend sizeof() instead of
offsetof().

Rasmus
