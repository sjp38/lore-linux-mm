Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F2C906B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 12:39:17 -0400 (EDT)
Date: Mon, 12 Apr 2010 17:38:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] add alloc_pages_exact_node()
Message-ID: <20100412163855.GP25756@csn.ul.ie>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com> <1270900173-10695-2-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1270900173-10695-2-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 07:49:33PM +0800, Bob Liu wrote:
> Add alloc_pages_exact_node() to allocate pages from exact
> node.
> 

It feels a bit overkill to add a new API that adds one self-explanatory
flag. 

> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  arch/powerpc/platforms/cell/ras.c |    4 ++--
>  include/linux/gfp.h               |    7 +++++++
>  mm/mempolicy.c                    |    2 +-
>  mm/migrate.c                      |    3 +--
>  4 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
> index 6d32594..93a5afd 100644
> --- a/arch/powerpc/platforms/cell/ras.c
> +++ b/arch/powerpc/platforms/cell/ras.c
> @@ -123,8 +123,8 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
>  
>  	area->nid = nid;
>  	area->order = order;
> -	area->pages = alloc_pages_from_valid_node(area->nid,
> -			GFP_KERNEL | GFP_THISNODE, area->order);
> +	area->pages = alloc_pages_exact_node(area->nid, GFP_KERNEL,
> +				area->order);
>  

This behaves differently now. If this is a bug fix, it needs to be a
standalone patch. It's the same for other call sites. You are actually
changing behaviour and offhand, I don't know why.

>  	if (!area->pages) {
>  		printk(KERN_WARNING "%s: no page on node %d\n",
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index c94f2ed..70cf2ae 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -296,6 +296,13 @@ static inline struct page *alloc_pages_from_valid_node(int nid, gfp_t gfp_mask,
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
> +static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
> +						unsigned int order)
> +{
> +	return alloc_pages_from_valid_node(nid, gfp_mask | GFP_THISNODE,
> +			order);
> +}
> +
>  #ifdef CONFIG_NUMA
>  extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
>  
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 6838cd8..08f40a2 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -842,7 +842,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  
>  static struct page *new_node_page(struct page *page, unsigned long node, int **x)
>  {
> -	return alloc_pages_from_valid_node(node, GFP_HIGHUSER_MOVABLE, 0);
> +	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
>  }
>  
>  /*
> diff --git a/mm/migrate.c b/mm/migrate.c
> index a057a1a..17330c5 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -770,8 +770,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
>  
>  	*result = &pm->status;
>  
> -	return alloc_pages_from_valid_node(pm->node,
> -				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
> +	return alloc_pages_exact_node(pm->node, GFP_HIGHUSER_MOVABLE, 0);
>  }
>  
>  /*
> -- 
> 1.5.6.3
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
