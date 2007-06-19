Message-ID: <46777EBA.7080707@sgi.com>
Date: Tue, 19 Jun 2007 08:59:06 +0200
From: Jes Sorensen <jes@sgi.com>
MIME-Version: 1.0
Subject: Re: [patch 08/10] Uncached allocator: Handle memoryless nodes
References: <20070618191956.411091458@sgi.com> <20070618192545.999967493@sgi.com>
In-Reply-To: <20070618192545.999967493@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

clameter@sgi.com wrote:
> The checks for node_online in the uncached allocator are made to make sure
> that memory is available on these nodes. Thus switch all the checks to use
> the node_memory and for_each_memory_node functions.
> 
> Cc: jes@sgi.com
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Seems fair to me:

Acked-by: Jes Sorensen <jes@sgi.com>


> Index: linux-2.6.22-rc4-mm2/arch/ia64/kernel/uncached.c
> ===================================================================
> --- linux-2.6.22-rc4-mm2.orig/arch/ia64/kernel/uncached.c	2007-06-13 23:29:58.000000000 -0700
> +++ linux-2.6.22-rc4-mm2/arch/ia64/kernel/uncached.c	2007-06-13 23:32:35.000000000 -0700
> @@ -196,7 +196,7 @@ unsigned long uncached_alloc_page(int st
>  	nid = starting_nid;
>  
>  	do {
> -		if (!node_online(nid))
> +		if (!node_memory(nid))
>  			continue;
>  		uc_pool = &uncached_pools[nid];
>  		if (uc_pool->pool == NULL)
> @@ -268,7 +268,7 @@ static int __init uncached_init(void)
>  {
>  	int nid;
>  
> -	for_each_online_node(nid) {
> +	for_each_memory_node(nid) {
>  		uncached_pools[nid].pool = gen_pool_create(PAGE_SHIFT, nid);
>  		mutex_init(&uncached_pools[nid].add_chunk_mutex);
>  	}
> Index: linux-2.6.22-rc4-mm2/drivers/char/mspec.c
> ===================================================================
> --- linux-2.6.22-rc4-mm2.orig/drivers/char/mspec.c	2007-06-13 23:28:15.000000000 -0700
> +++ linux-2.6.22-rc4-mm2/drivers/char/mspec.c	2007-06-13 23:29:35.000000000 -0700
> @@ -353,7 +353,7 @@ mspec_init(void)
>  		is_sn2 = 1;
>  		if (is_shub2()) {
>  			ret = -ENOMEM;
> -			for_each_online_node(nid) {
> +			for_each_memory_node(nid) {
>  				int actual_nid;
>  				int nasid;
>  				unsigned long phys;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
