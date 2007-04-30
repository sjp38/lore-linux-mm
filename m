Date: Mon, 30 Apr 2007 12:08:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/4] Add __GFP_TEMPORARY to identify allocations that
 are short-lived
In-Reply-To: <20070430185644.7142.89206.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0704301202490.7258@schroedinger.engr.sgi.com>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
 <20070430185644.7142.89206.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Mel Gorman wrote:

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/drivers/block/acsi_slm.c linux-2.6.21-rc7-mm2-003_temporary/drivers/block/acsi_slm.c
> --- linux-2.6.21-rc7-mm2-002_account_reclaimable/drivers/block/acsi_slm.c	2007-04-27 22:04:30.000000000 +0100
> +++ linux-2.6.21-rc7-mm2-003_temporary/drivers/block/acsi_slm.c	2007-04-30 16:10:55.000000000 +0100
> @@ -367,7 +367,7 @@ static ssize_t slm_read( struct file *fi
>  	int length;
>  	int end;
>  
> -	if (!(page = __get_free_page( GFP_KERNEL )))
> +	if (!(page = __get_free_page( GFP_TEMPORARY)))

White space damage.

>  		return( -ENOMEM );
>  	
>  	length = slm_getstats( (char *)page, iminor(node) );
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/journal.c linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/journal.c
> --- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/journal.c	2007-04-27 22:04:33.000000000 +0100
> +++ linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/journal.c	2007-04-30 16:38:41.000000000 +0100
> @@ -1739,8 +1739,7 @@ static struct journal_head *journal_allo
>  #ifdef CONFIG_JBD_DEBUG
>  	atomic_inc(&nr_journal_heads);
>  #endif
> -	ret = kmem_cache_alloc(journal_head_cache,
> -			set_migrateflags(GFP_NOFS, __GFP_RECLAIMABLE));
> +	ret = kmem_cache_alloc(journal_head_cache, GFP_NOFS);
>  	if (ret == 0) {

This chunk belongs into the earlier patch.

> @@ -1750,8 +1749,7 @@ static struct journal_head *journal_allo
>  		}
>  		while (ret == 0) {
>  			yield();
> -			ret = kmem_cache_alloc(journal_head_cache,
> -					GFP_NOFS|__GFP_RECLAIMABLE);
> +			ret = kmem_cache_alloc(journal_head_cache, GFP_NOFS);
>  		}
>  	}

Ditto

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/gfp.h linux-2.6.21-rc7-mm2-003_temporary/include/linux/gfp.h
> --- linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/gfp.h	2007-04-27 22:04:33.000000000 +0100
> +++ linux-2.6.21-rc7-mm2-003_temporary/include/linux/gfp.h	2007-04-30 16:10:55.000000000 +0100
> @@ -50,6 +50,7 @@ struct vm_area_struct;
>  #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
>  #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
>  #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
> +#define __GFP_TEMPORARY   ((__force gfp_t)0x80000u) /* Page is short-lived */
>  #define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */

Aliases a __GFP flag. We do not do that. Is there really a need to use 
__GFP_TEMPORARY outside of the allocators? Just use __GFP_RECLAIMALBE?

> @@ -72,6 +73,7 @@ struct vm_area_struct;
>  #define GFP_NOIO	(__GFP_WAIT)
>  #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
>  #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
> +#define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_TEMPORARY)

s/__GFP_TEMPORARY/__GFP_RECLAIMABLE/ ?

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/net/core/skbuff.c linux-2.6.21-rc7-mm2-003_temporary/net/core/skbuff.c
> --- linux-2.6.21-rc7-mm2-002_account_reclaimable/net/core/skbuff.c	2007-04-27 22:04:34.000000000 +0100
> +++ linux-2.6.21-rc7-mm2-003_temporary/net/core/skbuff.c	2007-04-30 16:10:55.000000000 +0100
> @@ -152,7 +152,7 @@ struct sk_buff *__alloc_skb(unsigned int
>  	u8 *data;
>  
>  	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
> -	gfp_mask = set_migrateflags(gfp_mask, __GFP_RECLAIMABLE);
> +	gfp_mask = set_migrateflags(gfp_mask, __GFP_TEMPORARY);
>  
>  	/* Get the HEAD */
>  	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);

Why is the gfp_mask set to __GFP_TEMPORARY here? The slab parameters are 
set during slab creation. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
