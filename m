Message-ID: <44D87CE4.7050408@shadowen.org>
Date: Tue, 08 Aug 2006 13:00:36 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: mempolicies: fix policy_zone check
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> There is a check in zonelist_policy that compares pieces of the bitmap 
> obtained from a gfp mask via GFP_ZONETYPES with a zone number in function
> zonelist_policy().
> 
> The bitmap is an ORed mask of __GFP_DMA, __GFP_DMA32 and __GFP_HIGHMEM.
> The policy_zone is a zone number with the possible values of ZONE_DMA,
> ZONE_DMA32, ZONE_HIGHMEM and ZONE_NORMAL. These are two different domains 
> of values.
> 
> For some reason seemed to work before the zone reduction patchset (It 
> definitely works on SGI boxes since we just have one zone and the check 
> cannot fail).
> 
> With the zone reduction patchset this check definitely fails on systems 
> with two zones if the system actually has memory in both zones.
> 
> This is because ZONE_NORMAL is selected using no __GFP flag at
> all and thus gfp_zone(gfpmask) == 0. ZONE_DMA is selected when __GFP_DMA 
> is set. __GFP_DMA is 0x01.  So gfp_zone(gfpmask) == 1.
> 
> policy_zone is set to ZONE_NORMAL (==1) if ZONE_NORMAL and ZONE_DMA are
> populated.
> 
> For ZONE_NORMAL gfp_zone(<no _GFP_DMA>) yields 0 which is < 
> policy_zone(ZONE_NORMAL) and so policy is not applied to regular memory 
> allocations!
> 
> Instead gfp_zone(__GFP_DMA) == 1 which results in policy being applied
> to DMA allocations!
> 
> What we realy want in that place is to establish the highest allowable
> zone for a given gfp_mask. If the highest zone is higher or equal to the
> policy_zone then memory policies need to be applied. We have such
> a highest_zone() function in page_alloc.c.
> 
> So move the highest_zone() function from mm/page_alloc.c into
> include/linux/gfp.h.  On the way we simplify the function and use the new
> zone_type that was also introduced with the zone reduction patchset plus we
> also specify the right type for the gfp flags parameter.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> 
> Index: test/mm/mempolicy.c
> ===================================================================
> --- test.orig/mm/mempolicy.c	2006-07-15 14:53:08.000000000 -0700
> +++ test/mm/mempolicy.c	2006-08-04 12:31:17.000000000 -0700
> @@ -1096,7 +1096,7 @@
>  	case MPOL_BIND:
>  		/* Lower zones don't get a policy applied */
>  		/* Careful: current->mems_allowed might have moved */
> -		if (gfp_zone(gfp) >= policy_zone)
> +		if (highest_zone(gfp) >= policy_zone)
>  			if (cpuset_zonelist_valid_mems_allowed(policy->v.zonelist))
>  				return policy->v.zonelist;
>  		/*FALL THROUGH*/
> Index: test/include/linux/gfp.h
> ===================================================================
> --- test.orig/include/linux/gfp.h	2006-08-04 12:16:03.000000000 -0700
> +++ test/include/linux/gfp.h	2006-08-04 12:31:14.000000000 -0700
> @@ -85,6 +85,21 @@
>  	return zone;
>  }
>  
> +static inline enum zone_type highest_zone(gfp_t flags)
> +{
> +	if (flags & __GFP_DMA)
> +		return ZONE_DMA;
> +#ifdef CONFIG_ZONE_DMA32
> +	if (flags & __GFP_DMA32)
> +		return ZONE_DMA32;
> +#endif
> +#ifdef CONFIG_HIGHMEM
> +	if (flags & __GFP_HIGHMEM)
> +		return ZONE_HIGHMEM;
> +#endif
> +	return ZONE_NORMAL;
> +}
> +

The name of the function is very missleading.  What it actually does is 
convert a gfp mask into a zone number.  It is currently not legal to 
specify more than one zone specifier so we don't have multiple to select 
the 'highest' from.

Either way even if we had more than one specified neither of these 
routines would return the highest as the order of the checks is incorrect.

Perhaps now is the time to change its name to something more 
appropriate: gfp_to_zone_num or something?

-apw

>  /*
>   * There is only one page-allocator function, and two main namespaces to
>   * it. The alloc_page*() variants return 'struct page *' and as such
> Index: test/mm/page_alloc.c
> ===================================================================
> --- test.orig/mm/page_alloc.c	2006-08-04 12:16:13.000000000 -0700
> +++ test/mm/page_alloc.c	2006-08-04 12:55:21.000000000 -0700
> @@ -1466,22 +1466,6 @@
>  	return nr_zones;
>  }
>  
> -static inline int highest_zone(int zone_bits)
> -{
> -	int res = ZONE_NORMAL;
> -#ifdef CONFIG_HIGHMEM
> -	if (zone_bits & (__force int)__GFP_HIGHMEM)
> -		res = ZONE_HIGHMEM;
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	if (zone_bits & (__force int)__GFP_DMA32)
> -		res = ZONE_DMA32;
> -#endif
> -	if (zone_bits & (__force int)__GFP_DMA)
> -		res = ZONE_DMA;
> -	return res;
> -}
> -
>  #ifdef CONFIG_NUMA
>  #define MAX_NODE_LOAD (num_online_nodes())
>  static int __meminitdata node_load[MAX_NUMNODES];
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
