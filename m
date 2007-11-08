Date: Thu, 8 Nov 2007 06:44:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded insertions
Message-ID: <20071108054445.GA20162@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de> <20071107170923.6cf3c389.akpm@linux-foundation.org> <20071108013723.GF3227@wotan.suse.de> <20071107190254.4e65812a.akpm@linux-foundation.org> <20071108031645.GI3227@wotan.suse.de> <20071107201242.390aec38.akpm@linux-foundation.org> <20071108045404.GJ3227@wotan.suse.de> <20071107210204.62070047.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107210204.62070047.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Wed, Nov 07, 2007 at 09:02:04PM -0800, Andrew Morton wrote:
> > On Thu, 8 Nov 2007 05:54:04 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > - doesn't solve the problem which it claims to be solving
> > >   (radix_tree_insert() doesn't deplete atomic reserves as long as the
> > >   caller uses radix_tree_preload(GFP_KERNEL))
> > 
> > I'm pretty sure it does. I don't follow exactly why you say it doesn't.
> >  
> 
> I was wrong.  The radix_tree_preloads will remain full and we'll just keep
> on doing GFP_ATOMIC allocations.

OK. Normally it's not a huge issue, because you've recently allocated a
page, but actually it can become a problem if: the page comes out of a
different zone than the radix tree node; or you're doing something like
mpage_readpages code that can do a lot of work between allocating the
pages and inserting them.

 
> > > - is probably desirable as a simplify-the-locking-hierarchy thing, but a)
> > >   should be presented as such and
> > 
> > It's primarily to avoid GFP_ATOMIC allocations. Simplify the locking
> > hierarcy is secondary and I put that in the changelog.
> > 
> > 
> > > b) needs code comments explaining why it
> > >   is correct and needs a big fat TODO explaining how we should get that
> > >   kmem_cache_alloc() out of there, an how we should do it.
> > > 
> > > OK?
> > 
> > I don't really know about getting that kmem_cache_alloc out of there.
> > For radix trees that are protected by sleeping locks, you don't actually
> > need to disable preempt and you can do sleeping allocations there.
> 
> If the radix tree's gfp_mask is GFP_ATOMIC, radix_tree_insert() can require
> that the preloads be full.

So we can put that invariant check in radix_tree_insert(), and I could
refactor / comment the radix_tree_node_alloc a bit so that it is clearer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
