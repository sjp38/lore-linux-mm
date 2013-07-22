Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id ADF4B6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 16:30:34 -0400 (EDT)
Date: Mon, 22 Jul 2013 22:30:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] lib: Make radix_tree_node_alloc() irq safe
Message-ID: <20130722203031.GI23658@quack.suse.cz>
References: <1373994390-5479-1-git-send-email-jack@suse.cz>
 <20130717161200.40a97074623be2685beb8156@linux-foundation.org>
 <20130718130932.GA10419@quack.suse.cz>
 <20130718143715.ce4bef65d01040fbbcd90f95@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130718143715.ce4bef65d01040fbbcd90f95@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jens Axboe <jaxboe@fusionio.com>

On Thu 18-07-13 14:37:15, Andrew Morton wrote:
> On Thu, 18 Jul 2013 15:09:32 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > On Wed 17-07-13 16:12:00, Andrew Morton wrote:
> > > On Tue, 16 Jul 2013 19:06:30 +0200 Jan Kara <jack@suse.cz> wrote:
> > > 
> > > BUG_ON(in_interrupt()) :)
> >   Or maybe WARN_ON()... But it's not so easy :) Currently radix tree code
> > assumes that if gfp_mask doesn't have __GFP_WAIT set caller has performed
> > radix_tree_preload(). Clearly this will stop working for in-interrupt users
> > of radix tree. So how do we propagate the information from the caller of
> > radix_tree_insert() down to radix_tree_node_alloc() whether the preload has
> > been performed or not? Will we rely on in_interrupt() or use some special
> > gfp_mask bit?
> 
> Well, it won't stop working.  The interrupt-time
> radix_tree_node_alloc() call will try to grab a node from the cpu-local
> magazine and if that failed, will call kmem_cache_alloc().  Presumably
> the caller has passed in GFP_ATOMIC, so the kmem_cache_alloc() will use
> page reserves, which seems appropriate.
  True. But then we have to make radix_tree_node_alloc() irq safe as I did
in my patch.

> This will mean that the interrupt-time node allocation will sometimes
> steal a preloaded node from process-context code.  In the absolutely
> worst case, the process-context code will then need to try
> kmem_cache_alloc(), which will probably succeed anyway.
  What I found somewhat nasty about stealing of preallocated nodes by
interrupt is that process-context user can do preload which succeeds so he
assumes radix_tree_node_alloc() cannot fail. If interrupt steals nodes,
radix_tree_node_alloc() can return NULL for process-context user and that
may oops or whatever (I've checked and there are users where this would
currently happen - e.g. mm/vmalloc.c:new_vmap_block()). And it will be
quite hard to track down why that happened.

So the question is more about the status of radix_tree_preload() - do we
make it just an optimization (so that allocations have higher chance of
success / stress the system less) or do we want to guarantee the caller
that nodes are there to be used? In the first case we have to fix some
users of radix_tree_preload() in the second case we have to tweak
radix_tree_node_alloc() like you suggest below.

> It's not perfect - we'd prefer that process-context node allocations
> not get stolen in this fashion.  That's easily fixed with
> 
> --- a/lib/radix-tree.c~a
> +++ a/lib/radix-tree.c
> @@ -207,7 +207,10 @@ radix_tree_node_alloc(struct radix_tree_
>  	struct radix_tree_node *ret = NULL;
>  	gfp_t gfp_mask = root_gfp_mask(root);
>  
> -	if (!(gfp_mask & __GFP_WAIT)) {
> +	/*
> +	 * Lengthy comment goes here
> +	 */
> +	if (!(gfp_mask & __GFP_WAIT) && !in_interrupt()) {
>  		struct radix_tree_preload *rtp;
>  
>  		/*
> 
> But I don't know if it's worth it.
> 
> > Secondly, CFQ has this unpleasant property that some functions are
> > sometimes called from interrupt context and sometimes not. So these
> > functions would have to check in what context they are called and either
> > perform preload or not. That's doable but it's going to be a bit ugly and
> > has to match the check in radix_tree_node_alloc() whether preload should be
> > used or not. So leaving the checking to the users of radix tree looks
> > fragile.
> 
> mm...  The CFQ code should be passing around a gfp_t anyway - GFP_NOIO
> or GFP_ATOMIC, depending on the calling context.  So don't call
> radix_tree_preload() if it's GFP_ATOMIC.
  I've checked and there are other users which can end up calling
radix_tree_preload() with GFP_ATOMIC or similar gfp masks (e.g. some
add_to_swap_cache() users). So I think it would be better to handle that
case inside a common function. Maybe we could have a separate function like
radix_tree_try_preload() which would just skip any preloading if mask
doesn't have __GFP_WAIT set and radix_tree_preload() will complain if it is
passed a gfp mask without __GFP_WAIT. Hm?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
