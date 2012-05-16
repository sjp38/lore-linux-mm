Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8B2226B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 04:01:58 -0400 (EDT)
Message-ID: <4FB35E7F.8030303@parallels.com>
Date: Wed, 16 May 2012 11:59:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 3/9] Extract common fields from struct
 kmem_cache
References: <20120514201544.334122849@linux.com> <20120514201610.559075441@linux.com>
In-Reply-To: <20120514201610.559075441@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/15/2012 12:15 AM, Christoph Lameter wrote:
> Define "COMMON" to include definitions for fields used in all
> slab allocators. After that it will be possible to share code that
> only operates on those fields of kmem_cache.
>
> The patch basically takes the slob definition of kmem cache and
> uses the field namees for the other allocators.
>
> The slob definition of kmem_cache is moved from slob.c to slob_def.h
> so that the location of the kmem_cache definition is the same for
> all allocators.
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> ---
>   include/linux/slab.h     |   11 +++++++++++
>   include/linux/slab_def.h |    8 ++------
>   include/linux/slub_def.h |   11 ++++-------
>   mm/slab.c                |   30 +++++++++++++++---------------
>   mm/slob.c                |    7 -------
>   5 files changed, 32 insertions(+), 35 deletions(-)
>
> Index: linux-2.6/include/linux/slab.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slab.h	2012-05-11 08:34:30.272522792 -0500
> +++ linux-2.6/include/linux/slab.h	2012-05-11 09:36:35.292445608 -0500
> @@ -93,6 +93,17 @@
>   				(unsigned long)ZERO_SIZE_PTR)
>
>   /*
> + * Common fields provided in kmem_cache by all slab allocators
> + */
> +#define SLAB_COMMON \
> +	unsigned int size, align;					\
> +	unsigned long flags;						\
> +	const char *name;						\
> +	int refcount;							\
> +	void (*ctor)(void *);						\
> +	struct list_head list;
> +
> +/*
>    * struct kmem_cache related prototypes

Isn't it better to define struct kmem_cache here, and then put the 
non-common fields under proper ifdefs ?

I myself prefer that style, but style aside, we should aim for what you
call SLAB_COMMON to encompass as many fields as we can, so the others 
will be kept to a minimum... It makes more sense, by looking from that 
angle.

> Index: linux-2.6/mm/slob.c
> ===================================================================
> --- linux-2.6.orig/mm/slob.c	2012-05-11 08:34:31.792522763 -0500
> +++ linux-2.6/mm/slob.c	2012-05-11 09:42:52.032437799 -0500
> @@ -538,13 +538,6 @@ size_t ksize(const void *block)
>   }
>   EXPORT_SYMBOL(ksize);
>
> -struct kmem_cache {
> -	unsigned int size, align;
> -	unsigned long flags;
> -	const char *name;
> -	void (*ctor)(void *);
> -};
> -

Who defines struct kmem_cache for the slob now ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
