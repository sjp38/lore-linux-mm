Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AD9956B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 06:17:39 -0400 (EDT)
Date: Fri, 22 May 2009 19:47:33 +0930
From: Ron <ron@debian.org>
Subject: Re: [PATCH] slab: add missing guard for kernel_map_pages() use
Message-ID: <20090522101733.GA12967@homer.shelbyville.oz>
References: <20090521192822.GB4448@homer.shelbyville.oz> <1242979372.13681.1.camel@penberg-laptop> <20090522085040.GC4448@homer.shelbyville.oz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090522085040.GC4448@homer.shelbyville.oz>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, akinobu.mita@gmail.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 22, 2009 at 06:20:40PM +0930, Ron wrote:
> 
> All other uses of kernel_map_pages() are explicitly excluded without
> CONFIG_DEBUG_PAGEALLOC, this one should be too.
> 
> Signed-off-by: Ron Lee <ron@debian.org>
> 
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 9a90b00..b5e5b27 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2674,10 +2683,12 @@ static void cache_init_objs(struct kmem_cache *cachep,
>  				slab_error(cachep, "constructor overwrote the"
>  					   " start of an object");
>  		}
> +#ifdef CONFIG_DEBUG_PAGEALLOC
>  		if ((cachep->buffer_size % PAGE_SIZE) == 0 &&
>  			    OFF_SLAB(cachep) && cachep->flags & SLAB_POISON)
>  			kernel_map_pages(virt_to_page(objp),
>  					 cachep->buffer_size / PAGE_SIZE, 0);
> +#endif
>  #else
>  		if (cachep->ctor)
>  			cachep->ctor(objp);

Actually, no.  I'm wrong on this one.  The compiler will already take that
one away because kernel_map_pages() is an empty function in that case.

It's subtle, but this extra guard actually adds nothing (unless you consider
more #ifdefs to be 'clarifying');

Sorry for the extra noise,
Ron


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
