Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC5E6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 07:29:00 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so104708lbg.32
        for <linux-mm@kvack.org>; Thu, 29 May 2014 04:29:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a6si607782laf.37.2014.05.29.04.28.57
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 04:28:58 -0700 (PDT)
Date: Thu, 29 May 2014 14:29:05 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 4/4] virtio_ring: unify direct/indirect code paths.
Message-ID: <20140529112905.GD30210@redhat.com>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
 <1401348405-18614-5-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401348405-18614-5-git-send-email-rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 04:56:45PM +0930, Rusty Russell wrote:
> virtqueue_add() populates the virtqueue descriptor table from the sgs
> given.  If it uses an indirect descriptor table, then it puts a single
> descriptor in the descriptor table pointing to the kmalloc'ed indirect
> table where the sg is populated.
> 
> Previously vring_add_indirect() did the allocation and the simple
> linear layout.  We replace that with alloc_indirect() which allocates
> the indirect table then chains it like the normal descriptor table so
> we can reuse the core logic.
> 
> Before:
> 	gcc 4.8.2: virtio_blk: stack used = 392
> 	gcc 4.6.4: virtio_blk: stack used = 480
> 
> After:
> 	gcc 4.8.2: virtio_blk: stack used = 408
> 	gcc 4.6.4: virtio_blk: stack used = 432
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/virtio/virtio_ring.c | 120 ++++++++++++++++---------------------------
>  1 file changed, 45 insertions(+), 75 deletions(-)

It's nice that we have less code now but it's data path -
are you sure it's worth the performance cost?

> 
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index 5d29cd85d6cf..3adf5978b92b 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -107,18 +107,10 @@ struct vring_virtqueue
>  
>  #define to_vvq(_vq) container_of(_vq, struct vring_virtqueue, vq)
>  
> -/* Set up an indirect table of descriptors and add it to the queue. */
> -static inline int vring_add_indirect(struct vring_virtqueue *vq,
> -				     struct scatterlist *sgs[],
> -				     unsigned int total_sg,
> -				     unsigned int out_sgs,
> -				     unsigned int in_sgs,
> -				     gfp_t gfp)
> +static struct vring_desc *alloc_indirect(unsigned int total_sg, gfp_t gfp)
>  {
> -	struct vring_desc *desc;
> -	unsigned head;
> -	struct scatterlist *sg;
> -	int i, n;
> + 	struct vring_desc *desc;
> +	unsigned int i;
>  
>  	/*
>  	 * We require lowmem mappings for the descriptors because
> @@ -130,51 +122,13 @@ static inline int vring_add_indirect(struct vring_virtqueue *vq,
>  	if (record_stack == current)
>  		__asm__ __volatile__("movq %%rsp,%0" : "=g" (stack_top));
>  
> -	desc = kmalloc(total_sg * sizeof(struct vring_desc), gfp);
> -	if (!desc)
> -		return -ENOMEM;
> -
> -	/* Transfer entries from the sg lists into the indirect page */
> -	i = 0;
> -	for (n = 0; n < out_sgs; n++) {
> -		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
> -			desc[i].flags = VRING_DESC_F_NEXT;
> -			desc[i].addr = sg_phys(sg);
> -			desc[i].len = sg->length;
> -			desc[i].next = i+1;
> -			i++;
> -		}
> -	}
> -	for (; n < (out_sgs + in_sgs); n++) {
> -		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
> -			desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
> -			desc[i].addr = sg_phys(sg);
> -			desc[i].len = sg->length;
> -			desc[i].next = i+1;
> -			i++;
> -		}
> -	}
> -	BUG_ON(i != total_sg);
> -
> -	/* Last one doesn't continue. */
> -	desc[i-1].flags &= ~VRING_DESC_F_NEXT;
> -	desc[i-1].next = 0;
> -
> -	/* We're about to use a buffer */
> -	vq->vq.num_free--;
> -
> -	/* Use a single buffer which doesn't continue */
> -	head = vq->free_head;
> -	vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
> -	vq->vring.desc[head].addr = virt_to_phys(desc);
> -	/* kmemleak gives a false positive, as it's hidden by virt_to_phys */
> -	kmemleak_ignore(desc);
> -	vq->vring.desc[head].len = i * sizeof(struct vring_desc);
> -
> -	/* Update free pointer */
> -	vq->free_head = vq->vring.desc[head].next;
> + 	desc = kmalloc(total_sg * sizeof(struct vring_desc), gfp);
> + 	if (!desc)
> +		return NULL;
>  
> -	return head;
> +	for (i = 0; i < total_sg; i++)
> +		desc[i].next = i+1;
> +	return desc;

Hmm we are doing an extra walk over descriptors here.
This might hurt performance esp for big descriptors.

>  }
>  
>  static inline int virtqueue_add(struct virtqueue *_vq,
> @@ -187,6 +141,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  {
>  	struct vring_virtqueue *vq = to_vvq(_vq);
>  	struct scatterlist *sg;
> +	struct vring_desc *desc = NULL;
>  	unsigned int i, n, avail, uninitialized_var(prev);
>  	int head;
>  
> @@ -212,18 +167,32 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  	}
>  #endif
>  
> +	BUG_ON(total_sg > vq->vring.num);
> +	BUG_ON(total_sg == 0);
> +
> +	head = vq->free_head;
> +
>  	/* If the host supports indirect descriptor tables, and we have multiple
>  	 * buffers, then go indirect. FIXME: tune this threshold */
> -	if (vq->indirect && total_sg > 1 && vq->vq.num_free) {
> -		head = vring_add_indirect(vq, sgs, total_sg, 
> -					  out_sgs, in_sgs, gfp);
> -		if (likely(head >= 0))
> -			goto add_head;
> +	if (vq->indirect && total_sg > 1 && vq->vq.num_free)
> +		desc = alloc_indirect(total_sg, gfp);

else desc = NULL will be a bit clearer won't it?

> +
> +	if (desc) {
> +		/* Use a single buffer which doesn't continue */
> +		vq->vring.desc[head].flags = VRING_DESC_F_INDIRECT;
> +		vq->vring.desc[head].addr = virt_to_phys(desc);
> +		/* avoid kmemleak false positive (tis hidden by virt_to_phys) */
> +		kmemleak_ignore(desc);
> +		vq->vring.desc[head].len = total_sg * sizeof(struct vring_desc);
> +
> +		/* Set up rest to use this indirect table. */
> +		i = 0;
> +		total_sg = 1;
> +	} else {
> +		desc = vq->vring.desc;
> +		i = head;
>  	}
>  
> -	BUG_ON(total_sg > vq->vring.num);
> -	BUG_ON(total_sg == 0);
> -
>  	if (vq->vq.num_free < total_sg) {
>  		pr_debug("Can't add buf len %i - avail = %i\n",
>  			 total_sg, vq->vq.num_free);
> @@ -239,32 +208,33 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  	/* We're about to use some buffers from the free list. */
>  	vq->vq.num_free -= total_sg;
>  
> -	head = i = vq->free_head;
>  	for (n = 0; n < out_sgs; n++) {
>  		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
> -			vq->vring.desc[i].flags = VRING_DESC_F_NEXT;
> -			vq->vring.desc[i].addr = sg_phys(sg);
> -			vq->vring.desc[i].len = sg->length;
> +			desc[i].flags = VRING_DESC_F_NEXT;
> +			desc[i].addr = sg_phys(sg);
> +			desc[i].len = sg->length;
>  			prev = i;
> -			i = vq->vring.desc[i].next;
> +			i = desc[i].next;
>  		}
>  	}
>  	for (; n < (out_sgs + in_sgs); n++) {
>  		for (sg = sgs[n]; sg; sg = sg_next(sg)) {
> -			vq->vring.desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
> -			vq->vring.desc[i].addr = sg_phys(sg);
> -			vq->vring.desc[i].len = sg->length;
> +			desc[i].flags = VRING_DESC_F_NEXT|VRING_DESC_F_WRITE;
> +			desc[i].addr = sg_phys(sg);
> +			desc[i].len = sg->length;
>  			prev = i;
> -			i = vq->vring.desc[i].next;
> +			i = desc[i].next;
>  		}
>  	}
>  	/* Last one doesn't continue. */
> -	vq->vring.desc[prev].flags &= ~VRING_DESC_F_NEXT;
> +	desc[prev].flags &= ~VRING_DESC_F_NEXT;
>  
>  	/* Update free pointer */
> -	vq->free_head = i;
> +	if (desc == vq->vring.desc)
> +		vq->free_head = i;
> +	else
> +		vq->free_head = vq->vring.desc[head].next;

This one is slightly ugly isn't it?


>  
> -add_head:
>  	/* Set token. */
>  	vq->data[head] = data;
>  
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
