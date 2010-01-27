Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0AA6B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 10:13:34 -0500 (EST)
Message-ID: <4B605802.7010401@cs.helsinki.fi>
Date: Wed, 27 Jan 2010 17:13:06 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] slab: fix regression in touched logic
References: <20100127112740.GA14790@laptop>
In-Reply-To: <20100127112740.GA14790@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi,
> 
> This hasn't actually shown up in any real workloads, but if my following
> logic is correct then it should be a good fix. Comments?
> 
> Thanks,
> Nick
> --
> 
> When factoring common code into transfer_objects, the 'touched' logic
> got a bit broken. When refilling from the shared array (taking objects
> from the shared array), we are making use of the shared array so it
> should be marked as touched.
> 
> Subsequently pulling an element from the cpu array and allocating it
> should also touch the cpu array, but that is taken care of after the
> alloc_done label. (So yes, the cpu array was getting touched = 1
> twice).
> 
> So revert this logic to how it worked in earlier kernels.
> 
> This also affects the behaviour in __drain_alien_cache, which would
> previously 'touch' the shared array and now does not. I think it is
> more logical not to touch there, because we are pushing objects into
> the shared array rather than pulling them off. So there is no good
> reason to postpone reaping them -- if the shared array is getting
> utilized, then it will get 'touched' in the alloc path (where this
> patch now restores the touch).
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Makes sense but the rework doesn't ring a bell for me and I didn't check 
the git logs yet. Christoph, comments?

> ---
> Index: linux-2.6/mm/slab.c
> ===================================================================
> --- linux-2.6.orig/mm/slab.c
> +++ linux-2.6/mm/slab.c
> @@ -935,7 +935,6 @@ static int transfer_objects(struct array
>  
>  	from->avail -= nr;
>  	to->avail += nr;
> -	to->touched = 1;
>  	return nr;
>  }
>  
> @@ -2963,8 +2962,10 @@ retry:
>  	spin_lock(&l3->list_lock);
>  
>  	/* See if we can refill from the shared array */
> -	if (l3->shared && transfer_objects(ac, l3->shared, batchcount))
> +	if (l3->shared && transfer_objects(ac, l3->shared, batchcount)) {
> +		l3->shared->touched = 1;
>  		goto alloc_done;
> +	}
>  
>  	while (batchcount > 0) {
>  		struct list_head *entry;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
