Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 695436B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 04:07:34 -0400 (EDT)
Date: Thu, 4 Aug 2011 10:07:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] sparse: using kzalloc to clean up code
Message-ID: <20110804080729.GG31039@tiehlicka.suse.cz>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu 04-08-11 11:09:49, Bob Liu wrote:
> This patch using kzalloc to clean up sparse_index_alloc() and
> __GFP_ZERO to clean up __kmalloc_section_memmap().
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

looks good.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/sparse.c |   24 +++++++-----------------
>  1 files changed, 7 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 858e1df..9596635 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -65,15 +65,12 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>  
>  	if (slab_is_available()) {
>  		if (node_state(nid, N_HIGH_MEMORY))
> -			section = kmalloc_node(array_size, GFP_KERNEL, nid);
> +			section = kzalloc_node(array_size, GFP_KERNEL, nid);
>  		else
> -			section = kmalloc(array_size, GFP_KERNEL);
> +			section = kzalloc(array_size, GFP_KERNEL);
>  	} else
>  		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
>  
> -	if (section)
> -		memset(section, 0, array_size);
> -
>  	return section;
>  }
>  
> @@ -636,19 +633,12 @@ static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
>  	struct page *page, *ret;
>  	unsigned long memmap_size = sizeof(struct page) * nr_pages;
>  
> -	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
> +	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN|__GFP_ZERO,
> +					get_order(memmap_size));
>  	if (page)
> -		goto got_map_page;
> -
> -	ret = vmalloc(memmap_size);
> -	if (ret)
> -		goto got_map_ptr;
> -
> -	return NULL;
> -got_map_page:
> -	ret = (struct page *)pfn_to_kaddr(page_to_pfn(page));
> -got_map_ptr:
> -	memset(ret, 0, memmap_size);
> +		ret = (struct page *)pfn_to_kaddr(page_to_pfn(page));
> +	else
> +		ret = vzalloc(memmap_size);
>  
>  	return ret;
>  }
> -- 
> 1.6.3.3
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
