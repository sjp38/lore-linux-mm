Date: Wed, 7 Nov 2007 22:02:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded
 insertions
Message-Id: <20071107220200.85e9cb59.akpm@linux-foundation.org>
In-Reply-To: <20071108054445.GA20162@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de>
	<20071107170923.6cf3c389.akpm@linux-foundation.org>
	<20071108013723.GF3227@wotan.suse.de>
	<20071107190254.4e65812a.akpm@linux-foundation.org>
	<20071108031645.GI3227@wotan.suse.de>
	<20071107201242.390aec38.akpm@linux-foundation.org>
	<20071108045404.GJ3227@wotan.suse.de>
	<20071107210204.62070047.akpm@linux-foundation.org>
	<20071108054445.GA20162@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

> On Thu, 8 Nov 2007 06:44:46 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > I don't really know about getting that kmem_cache_alloc out of there.
> > > For radix trees that are protected by sleeping locks, you don't actually
> > > need to disable preempt and you can do sleeping allocations there.
> > 
> > If the radix tree's gfp_mask is GFP_ATOMIC, radix_tree_insert() can require
> > that the preloads be full.
> 
> So we can put that invariant check in radix_tree_insert(),

Well, ultimately.  If we do that right now the powerpc irq management will
trigger it.  But it deserves to ;)

> and I could
> refactor / comment the radix_tree_node_alloc a bit so that it is clearer?

Please.

I guess we can't actually remove the kmem_cache_alloc() call in there
because of possible future code which uses sleeping locks.  AFAICT all
callers persently use GFP_ATOMIC.   So it's going to end up trickier than
one would like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
