Date: Wed, 1 Aug 2007 22:33:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH] type safe allocator
In-Reply-To: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0708012223520.3265@schroedinger.engr.sgi.com>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Aug 2007, Miklos Szeredi wrote:

> I wonder why we don't have type safe object allocators a-la new() in
> C++ or g_new() in glib?
> 
>   fooptr = k_new(struct foo, GFP_KERNEL);
> 
> is nicer and more descriptive than
> 
>   fooptr = kmalloc(sizeof(*fooptr), GFP_KERNEL);
> 
> and more safe than
> 
>   fooptr = kmalloc(sizeof(struct foo), GFP_KERNEL);
> 
> And we have zillions of both variants.

Hmmm yes I think that would be good. However, please clean up the naming.
The variant on zeroing on zering get to be too much.

> + * k_new - allocate given type object
> + * @type: the type of the object to allocate
> + * @flags: the type of memory to allocate.
> + */
> +#define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))

kalloc?

> +
> + * k_new0 - allocate given type object, zero out allocated space
> + * @type: the type of the object to allocate
> + * @flags: the type of memory to allocate.
> + */
> +#define k_new0(type, flags) ((type *) kzalloc(sizeof(type), flags))

A new notation for zeroing! This is equivalent to

kalloc(type, flags | __GFP_ZERO)

maybe define new GFP_xxx instead?

> +/**
> + * k_new_array - allocate array of given type object
> + * @type: the type of the object to allocate
> + * @len: the length of the array
> + * @flags: the type of memory to allocate.
> + */
> +#define k_new_array(type, len, flags) \
> +	((type *) kmalloc(sizeof(type) * (len), flags))

We already have array initializations using kcalloc.

> +#define k_new0_array(type, len, flags) \
> +	((type *) kzalloc(sizeof(type) * (len), flags))

Same as before.


I do not see any _node variants?

How about the following minimal set


kmalloc(size, flags)		kalloc(struct, flags)
kmalloc_node(size, flags, node)	kalloc_node(struct, flags, node)


The array variants translate into kmalloc anyways and are used
in an inconsistent manner. Sometime this way sometimes the other. Leave 
them?

	kcalloc(n, size, flags) == kmalloc(size, flags)

Then kzalloc is equivalent to adding the __GFP_ZERO flag. Thus

	kzalloc(size, flags) == kmalloc(size, flags | __GFPZERO)

If you define a new flag like GFP_ZERO_ATOMIC and GFP_ZERO_KERNEL you 
could do

	kalloc(struct, GFP_ZERO_KERNEL)

instead of adding new variants?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
