Date: Thu, 8 Nov 2007 02:37:23 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded insertions
Message-ID: <20071108013723.GF3227@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de> <20071107170923.6cf3c389.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107170923.6cf3c389.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Wed, Nov 07, 2007 at 05:09:23PM -0800, Andrew Morton wrote:
> > On Thu, 8 Nov 2007 01:43:04 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > OK, here's this patch again. This time I come with real failures on real
> > systems (in this case, David is running some 'dd' pagecache throughput
> > tests).
> > 
> > I haven't got him to retest it yet, but I think the idea is just a no-brainer.
> > We significantly reduce maximum tree_lock(W) hold time, and we reduce the
> > amount of GFP_ATOMIC allocations.
> > 
> > --
> > 
> > Most pagecache (and some other) radix tree insertions have the great
> > opportunity to preallocate a few nodes with relaxed gfp flags. But
> > the preallocation is squandered when it comes time to allocate a node,
> > we default to first attempting a GFP_ATOMIC allocation -- that doesn't
> > normally fail, but it can eat into atomic memory reserves that we
> > don't need to be using.
> > 
> > Another upshot of this is that it removes the sometimes highly contended
> > zone->lock from underneath tree_lock.
> > 
> > David Miller reports seeing this allocation fail on a highly threaded
> > sparc64 system when running a parallel 'dd' test:
> > 
> > [527319.459981] dd: page allocation failure. order:0, mode:0x20
> > [527319.460403] Call Trace:
> > [527319.460568]  [00000000004b71e0] __slab_alloc+0x1b0/0x6a8
> > [527319.460636]  [00000000004b7bbc] kmem_cache_alloc+0x4c/0xa8
> > [527319.460698]  [000000000055309c] radix_tree_node_alloc+0x20/0x90
> > [527319.460763]  [0000000000553238] radix_tree_insert+0x12c/0x260
> > [527319.460830]  [0000000000495cd0] add_to_page_cache+0x38/0xb0
> > [527319.460893]  [00000000004e4794] mpage_readpages+0x6c/0x134
> > [527319.460955]  [000000000049c7fc] __do_page_cache_readahead+0x170/0x280
> > [527319.461028]  [000000000049cc88] ondemand_readahead+0x208/0x214
> > [527319.461094]  [0000000000496018] do_generic_mapping_read+0xe8/0x428
> > [527319.461152]  [0000000000497948] generic_file_aio_read+0x108/0x170
> > [527319.461217]  [00000000004badac] do_sync_read+0x88/0xd0
> > [527319.461292]  [00000000004bb5cc] vfs_read+0x78/0x10c
> > [527319.461361]  [00000000004bb920] sys_read+0x34/0x60
> > [527319.461424]  [0000000000406294] linux_sparc_syscall32+0x3c/0x40
> > 
> > The calltrace is significant: __do_page_cache_readahead allocates a number
> > of pages with GFP_KERNEL, and hence it should have reclaimed sufficient
> > memory to satisfy GFP_ATOMIC allocations. However after the list of pages
> > goes to mpage_readpages, there can be significant intervals (including
> > disk IO) before all the pages are inserted into the radix-tree. So the
> > reserves can easily be depleted at that point.
> > 
> 
> So now I've got to re-re-remember why I didn't like this the first time. 
> Do you recall?

Sorry, can't recall why you didn't like it the first time. Maybe I was
misremembering, and you simply didn't merge it because I didn't present
it as a submission.. I honestly can't find the mail anywhere.

You didn't like it the second time because I didn't offer a realistic
test were it mattered.


> Why not just stomp the warning with __GFP_NOWARN?
 
Yeah, but it's still using up a lot of atomic reserves.


> Did you consider turning off __GFP_HIGH?  (Dunno why)

That would help, although that still allows one to eat a (smaller) amount
of reserves, which would be nice to avoid. 


> This change will slow things down - has this been quantified?  Probably
> it's unmeasurable, but it's still there.
 
I wouldn't have thought it should slow things down _too much_. The radix
tree nodes are those unusual allocations (like pagetables) that don't
really need to be allocated cache-hot. (If that's where you're thinking
the slowdown will come from...)


> I'd have thought that a superior approach would be to just set
> __GFP_NOWARN?

But given that the potential performance loss is so small, I think it is
more important to avoid using reserves that we need for important things
like networking.

Though even if we ignore the question of atomic allocations, I think it
is really nice to be able to turn tree_lock into an innermost lock, and
not transitively pollute it with zone->lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
