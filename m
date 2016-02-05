Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id F30234403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 05:33:12 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so41963022wme.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 02:33:12 -0800 (PST)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id cf10si23401435wjc.167.2016.02.05.02.33.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 02:33:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 4A1AE99698
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 10:33:11 +0000 (UTC)
Date: Fri, 5 Feb 2016 10:33:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/slab: re-implement pfmemalloc support
Message-ID: <20160205103248.GA5210@techsingularity.net>
References: <1454571612-9486-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1454571612-9486-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Feb 04, 2016 at 04:40:12PM +0900, Joonsoo Kim wrote:
> Current implementation of pfmemalloc handling in SLAB has some problems.
> 
> 1) pfmemalloc_active is set to true when there is just one or more
> pfmemalloc slabs in the system, but it is cleared when there is
> no pfmemalloc slab in one arbitrary kmem_cache. So, pfmemalloc_active
> could be wrongly cleared.
> 

Ok.

> 2) Search to partial and free list doesn't happen when non-pfmemalloc
> object are not found in cpu cache. Instead, allocating new slab happens
> and it is not optimal.
> 

It was intended to be conservative on the use of slabs that are
potentially pfmemalloc.

> 3) Even after sk_memalloc_socks() is disabled, cpu cache would keep
> pfmemalloc objects tagged with SLAB_OBJ_PFMEMALLOC. It isn't cleared if
> sk_memalloc_socks() is disabled so it could cause problem.
> 

Ok.

> 4) If cpu cache is filled with pfmemalloc objects, it would cause slow
> down non-pfmemalloc allocation.
> 

It may slow down non-pfmemalloc allocations but the alternative is
potentially livelocking the system if it cannot allocate the memory it
needs to swap over the network. It was expected that a system that really
wants to swap over the network is not going to be worried about slowdowns
when it happens.

> To me, current pointer tagging approach looks complex and fragile
> so this patch re-implement whole thing instead of fixing problems
> one by one.
> 
> Design principle for new implementation is that
> 
> 1) Don't disrupt non-pfmemalloc allocation in fast path even if
> sk_memalloc_socks() is enabled. It's more likely case than pfmemalloc
> allocation.
> 
> 2) Ensure that pfmemalloc slab is used only for pfmemalloc allocation.
> 
> 3) Don't consider performance of pfmemalloc allocation in memory
> deficiency state.
> 
> As a result, all pfmemalloc alloc/free in memory tight state will
> be handled in slow-path. If there is non-pfmemalloc free object,
> it will be returned first even for pfmemalloc user in fast-path so that
> performance of pfmemalloc user isn't affected in normal case and
> pfmemalloc objects will be kept as long as possible.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Just out of curiousity, is there any measurable impact to this patch? It
seems that it only has an impact when swap over network is used.

> ---
>  mm/slab.c | 285 ++++++++++++++++++++++++++------------------------------------
>  1 file changed, 118 insertions(+), 167 deletions(-)
> 
> Hello, Mel.
> 
> May I ask you to review the patch and test it on your swap over nbd setup
> in order to check that it has no regression? For me, it's not easy
> to setup this environment.
> 

Unfortunately I do not have that setup available at this time as the
machine that co-ordinated it has died. It's on my todo list to setup a
replacement for it but it will take time.

As a general approach, I like what you did. The pfmemalloc slabs may be
slower to manage but that is not a concern because someone concerned with
the performance of swap over network needs their head examined.  However,
it needs testing because I think there is at least one leak in there.

> <SNIP>
>
> @@ -2820,7 +2695,46 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
>  		list_add(&page->lru, &n->slabs_partial);
>  }
>  
> -static struct page *get_first_slab(struct kmem_cache_node *n)
> +/* Try to find non-pfmemalloc slab if needed */
> +static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
> +					struct page *page, bool pfmemalloc)
> +{
> +	if (!page)
> +		return NULL;
> +
> +	if (pfmemalloc)
> +		return page;
> +
> +	if (!PageSlabPfmemalloc(page))
> +		return page;
> +
> +	/* No need to keep pfmemalloc slab if we have enough free objects */
> +	if (n->free_objects > n->free_limit) {
> +		ClearPageSlabPfmemalloc(page);
> +		return page;
> +	}
> +

This seems a bit arbitrary. It's not known in advance how much memory
will be needed by the network but if PageSlabPfmemalloc is set, then at
least that much was needed in the past. I don't see what the
relationship is betwewen n->free_limit and the memory requirements for
swapping over a network.

> +	/* Move pfmemalloc slab to the end of list to speed up next search */
> +	list_del(&page->lru);
> +	if (!page->active)
> +		list_add_tail(&page->lru, &n->slabs_free);
> +	else
> +		list_add_tail(&page->lru, &n->slabs_partial);
> +

Potentially this is a premature optimisation. We really don't care about
the performance of swap over network as long as it works.

> -static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
> -							bool force_refill)
> +static noinline void *cache_alloc_pfmemalloc(struct kmem_cache *cachep,
> +				struct kmem_cache_node *n, gfp_t flags)
> +{
> +	struct page *page;
> +	void *obj;
> +	void *list = NULL;
> +
> +	if (!gfp_pfmemalloc_allowed(flags))
> +		return NULL;
> +
> +	/* Racy check if there is free objects */
> +	if (!n->free_objects)
> +		return NULL;
> +

Yes, it's racy. Just take the lock and check it. Sure there may be
contention but being slow is ok in this particular case.

> @@ -3407,7 +3353,12 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>  		cache_flusharray(cachep, ac);
>  	}
>  
> -	ac_put_obj(cachep, ac, objp);
> +	if (sk_memalloc_socks()) {
> +		cache_free_pfmemalloc(cachep, objp);
> +		return;
> +	}
> +
> +	ac->entry[ac->avail++] = objp;

cache_free_pfmemalloc() only handles PageSlabPfmemalloc() pages so it
appears this thing is leaking objects on !PageSlabPfmemalloc pages.
Either cache_free_pfmemalloc needs update ac->entry or it needs to
return bool to indicate whether __cache_free needs to handle it.

I'll look into setting up some sort of test rig in case a v2 comes
along.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
