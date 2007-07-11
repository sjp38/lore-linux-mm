Message-ID: <469496D8.6040802@sgi.com>
Date: Wed, 11 Jul 2007 10:37:44 +0200
From: Jes Sorensen <jes@sgi.com>
MIME-Version: 1.0
Subject: Re: [patch 08/12] Uncached allocator: Handle memoryless nodes
References: <20070710215339.110895755@sgi.com> <20070710215455.870757833@sgi.com>
In-Reply-To: <20070710215455.870757833@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> The checks for node_online in the uncached allocator are made to make sure
> that memory is available on these nodes. Thus switch all the checks to use
> the node_memory and for_each_memory_node functions.
> 
> Cc: jes@sgi.com
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

I'm fine with this:

Signed-off-by: Jes Sorensen <jes@sgi.com>

Jes


> ---
>  arch/ia64/kernel/uncached.c |    4 ++--
>  drivers/char/mspec.c        |    2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.22-rc6-mm1/arch/ia64/kernel/uncached.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/arch/ia64/kernel/uncached.c	2007-06-24 16:21:48.000000000 -0700
> +++ linux-2.6.22-rc6-mm1/arch/ia64/kernel/uncached.c	2007-07-09 22:24:42.000000000 -0700
> @@ -196,7 +196,7 @@ unsigned long uncached_alloc_page(int st
>  	nid = starting_nid;
>  
>  	do {
> -		if (!node_online(nid))
> +		if (!node_state(nid, N_MEMORY))
>  			continue;
>  		uc_pool = &uncached_pools[nid];
>  		if (uc_pool->pool == NULL)
> @@ -268,7 +268,7 @@ static int __init uncached_init(void)
>  {
>  	int nid;
>  
> -	for_each_online_node(nid) {
> +	for_each_node_state(nid, N_ONLINE) {
>  		uncached_pools[nid].pool = gen_pool_create(PAGE_SHIFT, nid);
>  		mutex_init(&uncached_pools[nid].add_chunk_mutex);
>  	}
> Index: linux-2.6.22-rc6-mm1/drivers/char/mspec.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/drivers/char/mspec.c	2007-07-03 17:19:24.000000000 -0700
> +++ linux-2.6.22-rc6-mm1/drivers/char/mspec.c	2007-07-09 22:24:42.000000000 -0700
> @@ -353,7 +353,7 @@ mspec_init(void)
>  		is_sn2 = 1;
>  		if (is_shub2()) {
>  			ret = -ENOMEM;
> -			for_each_online_node(nid) {
> +			for_each_node_state(nid, N_ONLINE) {
>  				int actual_nid;
>  				int nasid;
>  				unsigned long phys;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
