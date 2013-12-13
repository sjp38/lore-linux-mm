Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id F3DD76B0062
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:55:04 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so1948399pdi.33
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:55:04 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id sa6si754647pbb.323.2013.12.12.22.55.02
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 22:55:03 -0800 (PST)
Date: Fri, 13 Dec 2013 15:58:06 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
Message-ID: <20131213065805.GC8845@lge.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
 <1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
 <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org>
 <20131204015218.GA19709@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131204015218.GA19709@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, Dec 04, 2013 at 10:52:18AM +0900, Joonsoo Kim wrote:
> On Tue, Dec 03, 2013 at 04:59:10PM -0800, Andrew Morton wrote:
> > On Tue,  8 Oct 2013 16:58:10 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > Buffer allocation has a very crude indefinite loop around waking the
> > > flusher threads and performing global NOFS direct reclaim because it
> > > can not handle allocation failures.
> > > 
> > > The most immediate problem with this is that the allocation may fail
> > > due to a memory cgroup limit, where flushers + direct reclaim might
> > > not make any progress towards resolving the situation at all.  Because
> > > unlike the global case, a memory cgroup may not have any cache at all,
> > > only anonymous pages but no swap.  This situation will lead to a
> > > reclaim livelock with insane IO from waking the flushers and thrashing
> > > unrelated filesystem cache in a tight loop.
> > > 
> > > Use __GFP_NOFAIL allocations for buffers for now.  This makes sure
> > > that any looping happens in the page allocator, which knows how to
> > > orchestrate kswapd, direct reclaim, and the flushers sensibly.  It
> > > also allows memory cgroups to detect allocations that can't handle
> > > failure and will allow them to ultimately bypass the limit if reclaim
> > > can not make progress.
> > 
> > Problem.
> > 
> > > --- a/fs/buffer.c
> > > +++ b/fs/buffer.c
> > > @@ -1005,9 +1005,19 @@ grow_dev_page(struct block_device *bdev, sector_t block,
> > >  	struct buffer_head *bh;
> > >  	sector_t end_block;
> > >  	int ret = 0;		/* Will call free_more_memory() */
> > > +	gfp_t gfp_mask;
> > >  
> > > -	page = find_or_create_page(inode->i_mapping, index,
> > > -		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
> > > +	gfp_mask = mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS;
> > > +	gfp_mask |= __GFP_MOVABLE;
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=65991
> > 
> > WARNING: CPU: 0 PID: 1 at mm/page_alloc.c:1539 get_page_from_freelist+0x8a9/0x8c0()
> > Modules linked in:
> > CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.13.0-rc1 #42
> > Hardware name: Acer Aspire 7750G/JE70_HR, BIOS V1.07 03/02/2011
> >  0000000000000009 ffff8801c6121650 ffffffff81898d39 0000000000000000
> >  ffff8801c6121688 ffffffff8107dc43 0000000000000002 0000000000000001
> >  0000000000284850 0000000000000000 ffff8801cec04680 ffff8801c6121698
> > Call Trace:
> >  [<ffffffff81898d39>] dump_stack+0x4e/0x7a
> >  [<ffffffff8107dc43>] warn_slowpath_common+0x73/0x90
> >  [<ffffffff8107dd15>] warn_slowpath_null+0x15/0x20
> >  [<ffffffff81116f69>] get_page_from_freelist+0x8a9/0x8c0
> >  [<ffffffff81330cdd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
> >  [<ffffffff81117070>] __alloc_pages_nodemask+0xf0/0x770
> >  [<ffffffff81330cdd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
> >  [<ffffffff81156823>] kmemcheck_alloc_shadow+0x53/0xf0
> >  [<ffffffff81152495>] new_slab+0x345/0x3e0
> >  [<ffffffff81897712>] __slab_alloc.isra.57+0x215/0x535
> >  [<ffffffff81328030>] ? __radix_tree_preload+0x60/0xf0
> >  [<ffffffff811545c8>] kmem_cache_alloc+0x118/0x150
> >  [<ffffffff81328030>] ? __radix_tree_preload+0x60/0xf0
> >  [<ffffffff81328030>] __radix_tree_preload+0x60/0xf0
> >  [<ffffffff81328125>] radix_tree_maybe_preload+0x25/0x30
> >  [<ffffffff8110faf7>] add_to_page_cache_locked+0x37/0x100
> >  [<ffffffff8110fbd5>] add_to_page_cache_lru+0x15/0x40
> >  [<ffffffff8110ff37>] find_or_create_page+0x57/0x90
> >  [<ffffffff8118e630>] __getblk+0xf0/0x2f0
> > 
> > That __GFP_NOFAIL is getting down into
> > radix_tree_preload->kmem_cache_alloc() and I expect that in its
> > boundless stupidity, slab has decided to inappropriately go and use an
> > unnecessarily massive page size for radix_tree_node_cachep's underlying
> > memory allocations.  So we end up using GFP_NOFAIL for an order=2 (or
> > more) allocation, which is unacceptably risky, methinks.
> > 
> > I really really wish slab wouldn't do this.  The benefit is surely very
> > small and these unnecessary higher-order allocations are quite abusive
> > of the page allocator.
> > 
> > Can we please make slab stop doing this?
> > 
> > radix_tree_nodes are 560 bytes and the kernel often allocates them in
> > times of extreme memory stress.  We really really want them to be
> > backed by order=0 pages.
> 
> Hello, Andrew.
> 
> Following patch would fix this problem.
> 
> Thanks.
> 
> -------------------8<------------------------
> >From 7f21232d1eeffccdbd0f6d79c04d297cf95a713e Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Wed, 4 Dec 2013 10:36:11 +0900
> Subject: [PATCH] slub: fix high order page allocation problem with
>  __GFP_NOFAIL
> 
> SLUB already try to allocate high order page with clearing __GFP_NOFAIL.
> But, when allocating shadow page for kmemcheck, it missed clearing
> the flag. This trigger WARN_ON_ONCE() reported by Christian Casteyde.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=65991
> 
> This patch fix this situation by using same allocation flag as original
> allocation.
> 
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 545a170..3dd28b1 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1335,11 +1335,12 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	page = alloc_slab_page(alloc_gfp, node, oo);
>  	if (unlikely(!page)) {
>  		oo = s->min;
> +		alloc_gfp = flags;
>  		/*
>  		 * Allocation may have failed due to fragmentation.
>  		 * Try a lower order alloc if possible
>  		 */
> -		page = alloc_slab_page(flags, node, oo);
> +		page = alloc_slab_page(alloc_gfp, node, oo);
>  
>  		if (page)
>  			stat(s, ORDER_FALLBACK);
> @@ -1349,7 +1350,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
>  		int pages = 1 << oo_order(oo);
>  
> -		kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
> +		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
>  
>  		/*
>  		 * Objects from caches that have a constructor don't get
> -- 
> 1.7.9.5

Hello, Pekka and Christoph.

Could you review this patch?
I think that we should merge it to fix the problem reported by Christian.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
