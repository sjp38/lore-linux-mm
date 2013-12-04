Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B67226B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 20:49:51 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so22338283pbb.31
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 17:49:51 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id sl10si24002227pab.41.2013.12.03.17.49.49
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 17:49:50 -0800 (PST)
Date: Wed, 4 Dec 2013 10:52:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
Message-ID: <20131204015218.GA19709@lge.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
 <1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
 <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Tue, Dec 03, 2013 at 04:59:10PM -0800, Andrew Morton wrote:
> On Tue,  8 Oct 2013 16:58:10 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Buffer allocation has a very crude indefinite loop around waking the
> > flusher threads and performing global NOFS direct reclaim because it
> > can not handle allocation failures.
> > 
> > The most immediate problem with this is that the allocation may fail
> > due to a memory cgroup limit, where flushers + direct reclaim might
> > not make any progress towards resolving the situation at all.  Because
> > unlike the global case, a memory cgroup may not have any cache at all,
> > only anonymous pages but no swap.  This situation will lead to a
> > reclaim livelock with insane IO from waking the flushers and thrashing
> > unrelated filesystem cache in a tight loop.
> > 
> > Use __GFP_NOFAIL allocations for buffers for now.  This makes sure
> > that any looping happens in the page allocator, which knows how to
> > orchestrate kswapd, direct reclaim, and the flushers sensibly.  It
> > also allows memory cgroups to detect allocations that can't handle
> > failure and will allow them to ultimately bypass the limit if reclaim
> > can not make progress.
> 
> Problem.
> 
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -1005,9 +1005,19 @@ grow_dev_page(struct block_device *bdev, sector_t block,
> >  	struct buffer_head *bh;
> >  	sector_t end_block;
> >  	int ret = 0;		/* Will call free_more_memory() */
> > +	gfp_t gfp_mask;
> >  
> > -	page = find_or_create_page(inode->i_mapping, index,
> > -		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
> > +	gfp_mask = mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS;
> > +	gfp_mask |= __GFP_MOVABLE;
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=65991
> 
> WARNING: CPU: 0 PID: 1 at mm/page_alloc.c:1539 get_page_from_freelist+0x8a9/0x8c0()
> Modules linked in:
> CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.13.0-rc1 #42
> Hardware name: Acer Aspire 7750G/JE70_HR, BIOS V1.07 03/02/2011
>  0000000000000009 ffff8801c6121650 ffffffff81898d39 0000000000000000
>  ffff8801c6121688 ffffffff8107dc43 0000000000000002 0000000000000001
>  0000000000284850 0000000000000000 ffff8801cec04680 ffff8801c6121698
> Call Trace:
>  [<ffffffff81898d39>] dump_stack+0x4e/0x7a
>  [<ffffffff8107dc43>] warn_slowpath_common+0x73/0x90
>  [<ffffffff8107dd15>] warn_slowpath_null+0x15/0x20
>  [<ffffffff81116f69>] get_page_from_freelist+0x8a9/0x8c0
>  [<ffffffff81330cdd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff81117070>] __alloc_pages_nodemask+0xf0/0x770
>  [<ffffffff81330cdd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff81156823>] kmemcheck_alloc_shadow+0x53/0xf0
>  [<ffffffff81152495>] new_slab+0x345/0x3e0
>  [<ffffffff81897712>] __slab_alloc.isra.57+0x215/0x535
>  [<ffffffff81328030>] ? __radix_tree_preload+0x60/0xf0
>  [<ffffffff811545c8>] kmem_cache_alloc+0x118/0x150
>  [<ffffffff81328030>] ? __radix_tree_preload+0x60/0xf0
>  [<ffffffff81328030>] __radix_tree_preload+0x60/0xf0
>  [<ffffffff81328125>] radix_tree_maybe_preload+0x25/0x30
>  [<ffffffff8110faf7>] add_to_page_cache_locked+0x37/0x100
>  [<ffffffff8110fbd5>] add_to_page_cache_lru+0x15/0x40
>  [<ffffffff8110ff37>] find_or_create_page+0x57/0x90
>  [<ffffffff8118e630>] __getblk+0xf0/0x2f0
> 
> That __GFP_NOFAIL is getting down into
> radix_tree_preload->kmem_cache_alloc() and I expect that in its
> boundless stupidity, slab has decided to inappropriately go and use an
> unnecessarily massive page size for radix_tree_node_cachep's underlying
> memory allocations.  So we end up using GFP_NOFAIL for an order=2 (or
> more) allocation, which is unacceptably risky, methinks.
> 
> I really really wish slab wouldn't do this.  The benefit is surely very
> small and these unnecessary higher-order allocations are quite abusive
> of the page allocator.
> 
> Can we please make slab stop doing this?
> 
> radix_tree_nodes are 560 bytes and the kernel often allocates them in
> times of extreme memory stress.  We really really want them to be
> backed by order=0 pages.

Hello, Andrew.

Following patch would fix this problem.

Thanks.

-------------------8<------------------------
