Date: Wed, 7 Nov 2007 19:02:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded
 insertions
Message-Id: <20071107190254.4e65812a.akpm@linux-foundation.org>
In-Reply-To: <20071108013723.GF3227@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de>
	<20071107170923.6cf3c389.akpm@linux-foundation.org>
	<20071108013723.GF3227@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

> On Thu, 8 Nov 2007 02:37:23 +0100 Nick Piggin <npiggin@suse.de> wrote:
> On Wed, Nov 07, 2007 at 05:09:23PM -0800, Andrew Morton wrote:
> > > On Thu, 8 Nov 2007 01:43:04 +0100 Nick Piggin <npiggin@suse.de> wrote:
>  
> I wouldn't have thought it should slow things down _too much_. The radix
> tree nodes are those unusual allocations (like pagetables) that don't
> really need to be allocated cache-hot. (If that's where you're thinking
> the slowdown will come from...)

Well, it's simply more work.  For each ratnode we presently do

	test radix_tree_preloads, do nothing
	kmem_cache_alloc()

now we do

	test radix_tree_preloads
		kmem_cache_alloc()
		store it in radix_tree_preloads()
	retrieve it from radix_tree_preloads()

it's not a _lot_ of work, but it's there.  Mainly the new dirtying of this
cpu's radix_tree_preload all the time.

> 
> > I'd have thought that a superior approach would be to just set
> > __GFP_NOWARN?
> 
> But given that the potential performance loss is so small, I think it is
> more important to avoid using reserves that we need for important things
> like networking.

Spose so.  We'll end up consuming a quarter of the atomic reserve in rare
situations for very short periods.

> Though even if we ignore the question of atomic allocations, I think it
> is really nice to be able to turn tree_lock into an innermost lock, and
> not transitively pollute it with zone->lock.

That would be nice if it were true.  But you still have a
kmem_cache_alloc() in radix_tree_node_alloc()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
