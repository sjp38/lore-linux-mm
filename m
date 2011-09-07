Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AD4166B016C
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 23:00:49 -0400 (EDT)
Subject: Re: [rfc ] slub: unfreeze full page if it's in node partial
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1315364172.31737.174.camel@debian>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>  <1315362396.31737.151.camel@debian>
	 <1315364172.31737.174.camel@debian>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Sep 2011 11:06:31 +0800
Message-ID: <1315364791.31737.179.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>

Forget to point, It also base on per cpu partial patches. 

On Wed, 2011-09-07 at 10:56 +0800, Alex,Shi wrote:
> In the per cpu partial slub, we may add a full page into node partial
> list. like the following scenario:
> 
>         cpu1                                    cpu2 
>     in unfreeze_partials                   in __slab_alloc
>         ...
>    add_partial(n, page, 1);
>                                         alloced from cpu partial, and 
>                                         set frozen = 1.
>    second cmpxchg_double_slab()
>    set frozen = 0
> 
> 
> At that time, maybe we'd better to unfreeze it in acquire_slab(). That
> let it in 'full list' mode, frozen=0 and freelist = NULL, same as we did
> in __slab_alloc()
> 
> 
> Signed-off-by: Alex Shi <alex.shi@intel.com>
> ---
>  mm/slub.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 6fca71c..7846951 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1579,7 +1579,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
>  			new.inuse = page->objects;
>  
>  		VM_BUG_ON(new.frozen);
> -		new.frozen = 1;
> +		new.frozen = freelist != NULL;
>  
>  	} while (!__cmpxchg_double_slab(s, page,
>  			freelist, counters,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
