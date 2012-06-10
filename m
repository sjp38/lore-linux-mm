Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 9D2586B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 16:52:55 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5548929dak.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 13:52:54 -0700 (PDT)
Date: Sun, 10 Jun 2012 13:52:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/buddy: fix default NUMA nodes
In-Reply-To: <1339254687-13447-1-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1206101350540.25986@chino.kir.corp.google.com>
References: <1339254687-13447-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org

On Sun, 10 Jun 2012, Gavin Shan wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7892f84..dda83c5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2474,6 +2474,7 @@ struct page *
>  __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  			struct zonelist *zonelist, nodemask_t *nodemask)
>  {
> +	nodemask_t *preferred_nodemask = nodemask ? : &cpuset_current_mems_allowed;
>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>  	struct zone *preferred_zone;
>  	struct page *page = NULL;
> @@ -2501,19 +2502,18 @@ retry_cpuset:
>  	cpuset_mems_cookie = get_mems_allowed();
>  
>  	/* The preferred zone is used for statistics later */
> -	first_zones_zonelist(zonelist, high_zoneidx,
> -				nodemask ? : &cpuset_current_mems_allowed,
> +	first_zones_zonelist(zonelist, high_zoneidx, preferred_nodemask,
>  				&preferred_zone);
>  	if (!preferred_zone)
>  		goto out;
>  
>  	/* First allocation attempt */
> -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> -			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
> +	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, preferred_nodemask,
> +			order, zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
>  			preferred_zone, migratetype);
>  	if (unlikely(!page))
> -		page = __alloc_pages_slowpath(gfp_mask, order,
> -				zonelist, high_zoneidx, nodemask,
> +		page = __alloc_pages_slowpath(gfp_mask, order, zonelist,
> +				high_zoneidx, preferred_nodemask,
>  				preferred_zone, migratetype);
>  
>  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);

Nack, this is wrong.  The nodemask passed to first_zones_zonelist() is 
only for statistics and is correct as written.  The nodemask passed to 
get_page_from_freelist() constrains the iteration to only those nodes 
which would be done over cpuset_current_mems_allowed with your patch if a 
NULL nodemask is passed into the page allocator (meaning it has a default 
mempolicy).  Allocations on non-cpuset nodes are allowed in some 
contexts, see cpuset_zone_allowed_softwall(), so this would cause a 
regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
