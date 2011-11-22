Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9283D6B00A1
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 16:45:57 -0500 (EST)
Received: by iaek3 with SMTP id k3so957838iae.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 13:45:54 -0800 (PST)
Date: Tue, 22 Nov 2011 13:45:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] block: initialize request_queue's numa node during
 allocation
In-Reply-To: <20111122211954.GA17120@redhat.com>
Message-ID: <alpine.DEB.2.00.1111221342320.2621@chino.kir.corp.google.com>
References: <4ECB5C80.8080609@redhat.com> <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com> <20111122152739.GA5663@redhat.com> <20111122211954.GA17120@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>, Jens Axboe <axboe@kernel.dk>
Cc: Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Tue, 22 Nov 2011, Mike Snitzer wrote:

> From: Mike Snitzer <snitzer@redhat.com>
> Subject: block: initialize request_queue's numa node during allocation
> 
> Set request_queue's node in blk_alloc_queue_node() rather than
> blk_init_allocated_queue_node().  This avoids blk_throtl_init() using
> q->node before it is initialized.
> 
> Rename blk_init_allocated_queue_node() to blk_init_allocated_queue().
> 
> Signed-off-by: Mike Snitzer <snitzer@redhat.com>

When I debug an issue and suggest a patch to fix it in addition to 
suggesting the possible cleanup for blk_init_allocated_queue_node(), I 
don't expect that you'll just take it and claim it as your own, sheesh.

Signed-off-by: David Rientjes <rientjes@google.com>

Also, your changelog is inadequate since it doesn't convey that his should 
be merged for 3.2 because it fixes an oops when there is no node 0!  That 
could have been done by adding a

Reported-by: Dave Young <dyoung@redhat.com>

and copying his stack trace in the changelog and adding my analysis of 
what the problem is, thanks.

> ---
>  block/blk-core.c       |   14 +++-----------
>  include/linux/blkdev.h |    3 ---
>  2 files changed, 3 insertions(+), 14 deletions(-)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index ea70e6c..20d69f6 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -467,6 +467,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
>  	q->backing_dev_info.state = 0;
>  	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
>  	q->backing_dev_info.name = "block";
> +	q->node = node_id;
>  
>  	err = bdi_init(&q->backing_dev_info);
>  	if (err) {
> @@ -551,7 +552,7 @@ blk_init_queue_node(request_fn_proc *rfn, spinlock_t *lock, int node_id)
>  	if (!uninit_q)
>  		return NULL;
>  
> -	q = blk_init_allocated_queue_node(uninit_q, rfn, lock, node_id);
> +	q = blk_init_allocated_queue(uninit_q, rfn, lock);
>  	if (!q)
>  		blk_cleanup_queue(uninit_q);
>  
> @@ -563,18 +564,9 @@ struct request_queue *
>  blk_init_allocated_queue(struct request_queue *q, request_fn_proc *rfn,
>  			 spinlock_t *lock)
>  {
> -	return blk_init_allocated_queue_node(q, rfn, lock, -1);
> -}
> -EXPORT_SYMBOL(blk_init_allocated_queue);
> -
> -struct request_queue *
> -blk_init_allocated_queue_node(struct request_queue *q, request_fn_proc *rfn,
> -			      spinlock_t *lock, int node_id)
> -{
>  	if (!q)
>  		return NULL;
>  
> -	q->node = node_id;
>  	if (blk_init_free_list(q))
>  		return NULL;
>  
> @@ -604,7 +596,7 @@ blk_init_allocated_queue_node(struct request_queue *q, request_fn_proc *rfn,
>  
>  	return NULL;
>  }
> -EXPORT_SYMBOL(blk_init_allocated_queue_node);
> +EXPORT_SYMBOL(blk_init_allocated_queue);
>  
>  int blk_get_queue(struct request_queue *q)
>  {
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index c7a6d3b..94acd81 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -805,9 +805,6 @@ extern void blk_unprep_request(struct request *);
>   */
>  extern struct request_queue *blk_init_queue_node(request_fn_proc *rfn,
>  					spinlock_t *lock, int node_id);
> -extern struct request_queue *blk_init_allocated_queue_node(struct request_queue *,
> -							   request_fn_proc *,
> -							   spinlock_t *, int node_id);
>  extern struct request_queue *blk_init_queue(request_fn_proc *, spinlock_t *);
>  extern struct request_queue *blk_init_allocated_queue(struct request_queue *,
>  						      request_fn_proc *, spinlock_t *);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
