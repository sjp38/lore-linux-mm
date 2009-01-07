Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C08A86B00EB
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 01:55:21 -0500 (EST)
Date: Wed, 7 Jan 2009 07:55:17 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Remove needless lock and list in vmap
Message-ID: <20090107065517.GB21629@wotan.suse.de>
References: <20090107054713.GA1416@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090107054713.GA1416@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 07, 2009 at 02:47:13PM +0900, MinChan Kim wrote:
> Anyone don't use vmap's dirty_list.
> I am not sure this is thing Nick's future work on purpose.
> If it is a dummy, we can remove dirty list and related codes
> to handle list and locking.
> 
> Also, In free_vmap_block, we don't have to check empty free_list.
> That's becuase before calling free_vmap_block, vb_free always checks
> empty of vb->free_list.
> 
> Now except vb_free, Anywhere don't call free_vmap_block.
> so, we can remove that check and locking.
> 
> If it is nick's intention to work in future, please, ignore this patch. 

It was going to be an attempt to optimise flushing a bit, but I never
finished writing the code. Either way, it doesn't belong upstream until
time as it is needed, so your patch is good.

Can you just put a BUG_ON(!list_empty(&vb->free_list)); in free_vmap_block?
Then add Acked-by: Nick Piggin <npiggin@suse.de>

Thanks,
Nick

> 
> Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
> ---
>  mm/vmalloc.c |   19 ++-----------------
>  1 files changed, 2 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 1ddb77b..1f79883 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -629,10 +629,7 @@ struct vmap_block {
>  	DECLARE_BITMAP(alloc_map, VMAP_BBMAP_BITS);
>  	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
>  	union {
> -		struct {
> -			struct list_head free_list;
> -			struct list_head dirty_list;
> -		};
> +		struct list_head free_list;
>  		struct rcu_head rcu_head;
>  	};
>  };
> @@ -699,7 +696,6 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
>  	bitmap_zero(vb->alloc_map, VMAP_BBMAP_BITS);
>  	bitmap_zero(vb->dirty_map, VMAP_BBMAP_BITS);
>  	INIT_LIST_HEAD(&vb->free_list);
> -	INIT_LIST_HEAD(&vb->dirty_list);
>  
>  	vb_idx = addr_to_vb_idx(va->va_start);
>  	spin_lock(&vmap_block_tree_lock);
> @@ -730,13 +726,6 @@ static void free_vmap_block(struct vmap_block *vb)
>  	struct vmap_block *tmp;
>  	unsigned long vb_idx;
>  
> -	spin_lock(&vb->vbq->lock);
> -	if (!list_empty(&vb->free_list))
> -		list_del(&vb->free_list);
> -	if (!list_empty(&vb->dirty_list))
> -		list_del(&vb->dirty_list);
> -	spin_unlock(&vb->vbq->lock);
> -
>  	vb_idx = addr_to_vb_idx(vb->va->va_start);
>  	spin_lock(&vmap_block_tree_lock);
>  	tmp = radix_tree_delete(&vmap_block_tree, vb_idx);
> @@ -820,11 +809,7 @@ static void vb_free(const void *addr, unsigned long size)
>  
>  	spin_lock(&vb->lock);
>  	bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order);
> -	if (!vb->dirty) {
> -		spin_lock(&vb->vbq->lock);
> -		list_add(&vb->dirty_list, &vb->vbq->dirty);
> -		spin_unlock(&vb->vbq->lock);
> -	}
> +
>  	vb->dirty += 1UL << order;
>  	if (vb->dirty == VMAP_BBMAP_BITS) {
>  		BUG_ON(vb->free || !list_empty(&vb->free_list));
> -- 
> 1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
