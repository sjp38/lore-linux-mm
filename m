Date: Thu, 2 Aug 2007 13:07:47 +0530 (IST)
From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [RFC PATCH] type safe allocator
In-Reply-To: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
Message-ID: <alpine.LFD.0.999.0708021302500.8258@enigma.security.iitk.ac.in>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Miklos,


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
> 
> Note, I'm not advocating mass replacement, but using this in new code,
> and gradually converting old ones whenever they need touching anyway.
> [...]
>  
> +/**
> + * k_new - allocate given type object
> + * @type: the type of the object to allocate
> + * @flags: the type of memory to allocate.
> + */
> +#define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))

What others already said, plus:

kmalloc()'ing sizeof(struct foo) is not always what we want in C either.

Several kernel structs have zero-length / variable-length array members
and space must be allocated for them only at alloc() time ... would be
impossible to make them work with this scheme.


Satyam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
