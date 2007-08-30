Date: Wed, 29 Aug 2007 19:08:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch][rfc] radix-tree: be a nice citizen
Message-Id: <20070829190804.c4a4587d.akpm@linux-foundation.org>
In-Reply-To: <20070830012237.GA19405@wotan.suse.de>
References: <20070829085039.GA32236@wotan.suse.de>
	<20070829015702.7c8567c2.akpm@linux-foundation.org>
	<20070829090301.GB32236@wotan.suse.de>
	<20070829022044.9730888e.akpm@linux-foundation.org>
	<20070829094503.GC32236@wotan.suse.de>
	<20070829154531.fd6d67bc.akpm@linux-foundation.org>
	<20070830012237.GA19405@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Aug 2007 03:22:37 +0200 Nick Piggin <npiggin@suse.de> wrote:

> On Wed, Aug 29, 2007 at 03:45:31PM -0700, Andrew Morton wrote:
> > On Wed, 29 Aug 2007 11:45:03 +0200 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > Yeah I'm sure the radix_tree_insert isn't failing, but the
> > > first kmem_cache_alloc in radix_tree_node_alloc is failing (page
> > > allocator is giving the backtrace). Because it is GFP_ATOMIC and
> > > being done under the spinlock.
> > 
> > OK, that's expected.  Add a __GFP_NOWARN to the caller's gfp_t?
> 
> It eats GFP_ATOMIC reserves

Really?  The caller does a great pile of GFP_HIGHUSER pagecache allocations
for each page which he allocates for ratnodes.  I guess if we're a highmem
machine then we could be low on ZONE_NORMAL, but have plenty of
ZONE_HIGHMEM available, so maybe in that situation the kernel could end up
chewing away a significant amount of the lowmem reserve, dunno.

But I'm more suspecting that your ZONE_NORMAL got eaten by something else
(networking?) and the radix-tree allocation failure you saw was collateral
damage?

> (and yes, we could ad a ~__GFP_HIGH, but
> the allocator still has a small reserve for non-sleeping GFP_KERNEL
> allocations, so it would eat that).

spose so.

I'm still struggling to see whether the value of the proposed fix is worth
the additional overhead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
