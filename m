Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0B46B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 16:38:34 -0500 (EST)
Date: Tue, 27 Jan 2009 13:37:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kmalloc: Return NULL instead of link failure
Message-Id: <20090127133723.46eb7035.akpm@linux-foundation.org>
In-Reply-To: <4975F376.4010506@suse.com>
References: <4975F376.4010506@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeff Mahoney <jeffm@suse.com>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jan 2009 10:53:26 -0500
Jeff Mahoney <jeffm@suse.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
>  The SLAB kmalloc with a constant value isn't consistent with the other
>  implementations because it bails out with __you_cannot_kmalloc_that_much
>  rather than returning NULL and properly allowing the caller to fall back
>  to vmalloc or take other action. This doesn't happen with a non-constant
>  value or with SLOB or SLUB.
> 
>  Starting with 2.6.28, I've been seeing build failures on s390x. This is
>  due to init_section_page_cgroup trying to allocate 2.5MB when the max
>  size for a kmalloc on s390x is 2MB.
> 
>  It's failing because the value is constant. The workarounds at the call
>  size are ugly and the caller shouldn't have to change behavior depending
>  on what the backend of the API is.
> 
>  So, this patch eliminates the link failure and returns NULL like the
>  other implementations.
> 

OK by me, is that's what the other sl[abcd...xyz]b.c implementations
do.

That __you_cannot_kmalloc_that_much() thing has frequently been a PITA
anyway - some gcc versions flub the constant_p() test and end up
referencing __you_cannot_kmalloc_that_much() when the callsite was
passing a variable `size' arg.

> - ---
>  include/linux/slab_def.h |   10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
> 
> - --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -43,10 +43,7 @@ static inline void *kmalloc(size_t size,
>  			i++;
>  #include <linux/kmalloc_sizes.h>
>  #undef CACHE
> - -		{
> - -			extern void __you_cannot_kmalloc_that_much(void);
> - -			__you_cannot_kmalloc_that_much();
> - -		}
> +		return NULL;
>  found:
>  #ifdef CONFIG_ZONE_DMA
>  		if (flags & GFP_DMA)
> @@ -77,10 +74,7 @@ static inline void *kmalloc_node(size_t
>  			i++;
>  #include <linux/kmalloc_sizes.h>
>  #undef CACHE
> - -		{
> - -			extern void __you_cannot_kmalloc_that_much(void);
> - -			__you_cannot_kmalloc_that_much();
> - -		}
> +		return NULL;
>  found:
>  #ifdef CONFIG_ZONE_DMA
>  		if (flags & GFP_DMA)
> 

Strange patch format, but it applied.

I'll punt this patch in the Pekka direction.

Do you think we should include it in 2.6.28.x?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
