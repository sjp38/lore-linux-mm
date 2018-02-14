Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE4016B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 18:58:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y79so2078580wme.6
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:58:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i13si10792039wrh.130.2018.02.14.15.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 15:58:37 -0800 (PST)
Date: Wed, 14 Feb 2018 15:58:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/8] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-Id: <20180214155833.9f1563b87391f7ff79ca7ed0@linux-foundation.org>
In-Reply-To: <20180214211203.GF20627@bombadil.infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
	<20180214201154.10186-3-willy@infradead.org>
	<1518641152.3678.28.camel@perches.com>
	<20180214211203.GF20627@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joe Perches <joe@perches.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, 14 Feb 2018 13:12:03 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> On Wed, Feb 14, 2018 at 12:45:52PM -0800, Joe Perches wrote:
> > On Wed, 2018-02-14 at 12:11 -0800, Matthew Wilcox wrote:
> > > We have kvmalloc_array in order to safely allocate an array with a
> > > number of elements specified by userspace (avoiding arithmetic overflow
> > > leading to a buffer overrun).  But it's fairly common to have a header
> > > in front of that array (eg specifying the length of the array), so we
> > > need a helper function for that situation.
> > > 
> > > kvmalloc_ab_c() is the workhorse that does the calculation, but in spite
> > > of our best efforts to name the arguments, it's really hard to remember
> > > which order to put the arguments in.  kvzalloc_struct() eliminates that
> > > effort; you tell it about the struct you're allocating, and it puts the
> > > arguments in the right order for you (and checks that the arguments
> > > you've given are at least plausible).
> > > 
> > > For comparison between the three schemes:
> > > 
> > > 	sev = kvzalloc(sizeof(*sev) + sizeof(struct v4l2_kevent) * elems,
> > > 			GFP_KERNEL);
> > > 	sev = kvzalloc_ab_c(elems, sizeof(struct v4l2_kevent), sizeof(*sev),
> > > 			GFP_KERNEL);
> > > 	sev = kvzalloc_struct(sev, events, elems, GFP_KERNEL);
> > 
> > Perhaps kv[zm]alloc_buf_and_array is better naming.
> 
> I think that's actively misleading.  The programmer isn't allocating a
> buf, they're allocating a struct.  kvzalloc_hdr_arr was the earlier name,
> and that made some sense; they're allocating an array with a header.
> But nobody thinks about it like that; they're allocating a structure
> with a variably sized array at the end of it.
> 
> If C macros had decent introspection, I'd like it to be:
> 
> 	sev = kvzalloc_struct(elems, GFP_KERNEL);
> 
> and have the macro examine the structure pointed to by 'sev', check
> the last element was an array, calculate the size of the array element,
> and call kvzalloc_ab_c.  But we don't live in that world, so I have to
> get the programmer to tell me the structure and the name of the last
> element in it.

hm, bikeshedding fun.


struct foo {
	whatevs;
	struct bar[0];
}


	struct foo *a_foo;

	a_foo = kvzalloc_struct_buf(foo, bar, nr_bars);

and macro magic will insert the `struct' keyword.  This will help to
force a miscompile if inappropriate types are used for foo and bar.

Problem is, foo may be a union(?) and bar may be a scalar type.  So

	a_foo = kvzalloc_struct_buf(struct foo, struct bar, nr_bars);

or, of course.

	a_foo = kvzalloc_struct_buf(typeof(*a_foo), typeof(a_foo->bar[0]),
				    nr_bars);

or whatever.

The basic idea is to use the wrapper macros to force compile errors if
these things are misused.


Also,

> +/**
> + * kvmalloc_ab_c() - Allocate (a * b + c) bytes of memory.
> + * @n: Number of elements.
> + * @size: Size of each element (should be constant).
> + * @c: Size of header (should be constant).
> + * @gfp: Memory allocation flags.
> + *
> + * Use this function to allocate @n * @size + @c bytes of memory.  This
> + * function is safe to use when @n is controlled from userspace; it will
> + * return %NULL if the required amount of memory cannot be allocated.
> + * Use kvfree() to free the allocated memory.
> + *
> + * The kvzalloc_struct() function is easier to use as it has typechecking
> + * and you do not need to remember which of the arguments should be constants.
> + *
> + * Context: Process context.  May sleep; the @gfp flags should be based on
> + *	    %GFP_KERNEL.
> + * Return: A pointer to the allocated memory or %NULL.
> + */
> +static inline __must_check
> +void *kvmalloc_ab_c(size_t n, size_t size, size_t c, gfp_t gfp)
> +{
> +	if (size != 0 && n > (SIZE_MAX - c) / size)
> +		return NULL;
> +
> +	return kvmalloc(n * size + c, gfp);
> +}

Can we please avoid the single-char identifiers?

void *kvmalloc_ab_c(size_t n_elems, size_t elem_size, size_t header_size,
		    gfp_t gfp);

makes the code so much more readable.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
