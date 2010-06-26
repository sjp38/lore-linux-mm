Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EF3666B01B6
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 19:34:15 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o5QNYEsQ018405
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:34:14 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by kpbe17.cbf.corp.google.com with ESMTP id o5QNYDqw022647
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:34:13 -0700
Received: by pzk37 with SMTP id 37so594071pzk.39
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:34:13 -0700 (PDT)
Date: Sat, 26 Jun 2010 16:34:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 07/16] slub: discard_slab_unlock
In-Reply-To: <20100625212105.203196516@quilx.com>
Message-ID: <alpine.DEB.2.00.1006261632080.27174@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212105.203196516@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, Christoph Lameter wrote:

> The sequence of unlocking a slab and freeing occurs multiple times.
> Put the common into a single function.
> 

Did you want to respond to the comments I made about this patch at 
http://marc.info/?l=linux-mm&m=127689747432061 ?  Specifically, how it 
makes seeing if there are unmatched slab_lock() -> slab_unlock() pairs 
more difficult.

> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/slub.c |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-06-01 08:58:50.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-06-01 08:58:54.000000000 -0500
> @@ -1260,6 +1260,13 @@ static __always_inline int slab_trylock(
>  	return rc;
>  }
>  
> +static void discard_slab_unlock(struct kmem_cache *s,
> +	struct page *page)
> +{
> +	slab_unlock(page);
> +	discard_slab(s, page);
> +}
> +
>  /*
>   * Management of partially allocated slabs
>   */
> @@ -1437,9 +1444,8 @@ static void unfreeze_slab(struct kmem_ca
>  			add_partial(n, page, 1);
>  			slab_unlock(page);
>  		} else {
> -			slab_unlock(page);
>  			stat(s, FREE_SLAB);
> -			discard_slab(s, page);
> +			discard_slab_unlock(s, page);
>  		}
>  	}
>  }
> @@ -1822,9 +1828,8 @@ slab_empty:
>  		remove_partial(s, page);
>  		stat(s, FREE_REMOVE_PARTIAL);
>  	}
> -	slab_unlock(page);
>  	stat(s, FREE_SLAB);
> -	discard_slab(s, page);
> +	discard_slab_unlock(s, page);
>  	return;
>  
>  debug:
> @@ -2893,8 +2898,7 @@ int kmem_cache_shrink(struct kmem_cache 
>  				 */
>  				list_del(&page->lru);
>  				n->nr_partial--;
> -				slab_unlock(page);
> -				discard_slab(s, page);
> +				discard_slab_unlock(s, page);
>  			} else {
>  				list_move(&page->lru,
>  				slabs_by_inuse + page->inuse);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
