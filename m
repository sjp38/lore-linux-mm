Date: Wed, 7 Nov 2007 21:02:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded
 insertions
Message-Id: <20071107210204.62070047.akpm@linux-foundation.org>
In-Reply-To: <20071108045404.GJ3227@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de>
	<20071107170923.6cf3c389.akpm@linux-foundation.org>
	<20071108013723.GF3227@wotan.suse.de>
	<20071107190254.4e65812a.akpm@linux-foundation.org>
	<20071108031645.GI3227@wotan.suse.de>
	<20071107201242.390aec38.akpm@linux-foundation.org>
	<20071108045404.GJ3227@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

> On Thu, 8 Nov 2007 05:54:04 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > - doesn't solve the problem which it claims to be solving
> >   (radix_tree_insert() doesn't deplete atomic reserves as long as the
> >   caller uses radix_tree_preload(GFP_KERNEL))
> 
> I'm pretty sure it does. I don't follow exactly why you say it doesn't.
>  

I was wrong.  The radix_tree_preloads will remain full and we'll just keep
on doing GFP_ATOMIC allocations.

> > - is probably desirable as a simplify-the-locking-hierarchy thing, but a)
> >   should be presented as such and
> 
> It's primarily to avoid GFP_ATOMIC allocations. Simplify the locking
> hierarcy is secondary and I put that in the changelog.
> 
> 
> > b) needs code comments explaining why it
> >   is correct and needs a big fat TODO explaining how we should get that
> >   kmem_cache_alloc() out of there, an how we should do it.
> > 
> > OK?
> 
> I don't really know about getting that kmem_cache_alloc out of there.
> For radix trees that are protected by sleeping locks, you don't actually
> need to disable preempt and you can do sleeping allocations there.

If the radix tree's gfp_mask is GFP_ATOMIC, radix_tree_insert() can require
that the preloads be full.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
