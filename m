Date: Sun, 29 Aug 2004 16:15:27 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040829141526.GC10955@suse.de>
References: <412E13DB.6040102@seagha.com> <412E31EE.3090102@pandora.be> <41308C62.7030904@seagha.com> <20040828125028.2fa2a12b.akpm@osdl.org> <4130F55A.90705@pandora.be> <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829033031.01c5f78c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040829033031.01c5f78c.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 29 2004, Andrew Morton wrote:
> William Lee Irwin III <wli@holomorphy.com> wrote:
> >
> >  On Sat, Aug 28, 2004 at 03:13:49PM -0700, Andrew Morton wrote:
> >  > Separate issue.
> > 
> >  It certainly appears to be the deciding factor from the thread.
> > 
> 
> It's all very bizarre.
> 
> If you do a big `usemem -m 250' on a 256MB box, you end up with all memory
> in swapcache _after_ usemem exits.  That's wrong: all the memory which
> usemem allocated should now be free.
> 
> But all that swapcache is reclaimable under memory pressure.  It seems to
> be floating about on the LRU still.
> 
> It only happens with the CFQ elevator, and this backout patch makes it go
> away.

It's not bizarre, if you backout that fix (it is a fix!), ->nr_requests
isn't initialized when cfq gets there. So it'll throttle incorrectly in
may_queue, not a good idea.

> The main effect of this patch is to increase the elevator's nr_requests
> from 128 to 8192.  Something to do with that, I guess.

How do you reach that conclusion?

I think the correct fix, for now, is to remove the 8192 in CFQ. It's not
the right thing to do anyways, it should just be set from user space.
But the patch below should definitely not be backed out.

> --- 25/drivers/block/ll_rw_blk.c~a	2004-08-29 03:21:41.678895384 -0700
> +++ 25-akpm/drivers/block/ll_rw_blk.c	2004-08-29 03:21:50.230595328 -0700
> @@ -1534,6 +1534,9 @@ request_queue_t *blk_init_queue(request_
>  		printk("Using %s io scheduler\n", chosen_elevator->elevator_name);
>  	}
>  
> +	if (elevator_init(q, chosen_elevator))
> +		goto out_elv;
> +
>  	q->request_fn		= rfn;
>  	q->back_merge_fn       	= ll_back_merge_fn;
>  	q->front_merge_fn      	= ll_front_merge_fn;
> @@ -1551,12 +1554,8 @@ request_queue_t *blk_init_queue(request_
>  	blk_queue_max_hw_segments(q, MAX_HW_SEGMENTS);
>  	blk_queue_max_phys_segments(q, MAX_PHYS_SEGMENTS);
>  
> -	/*
> -	 * all done
> -	 */
> -	if (!elevator_init(q, chosen_elevator))
> -		return q;
> -
> +	return q;
> +out_elv:
>  	blk_cleanup_queue(q);
>  out_init:
>  	kmem_cache_free(requestq_cachep, q);

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
