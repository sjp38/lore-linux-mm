Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 034B46B0087
	for <linux-mm@kvack.org>; Wed, 27 May 2009 20:15:28 -0400 (EDT)
Date: Thu, 28 May 2009 02:14:32 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc][patch] swap: virtual swap readahead
Message-ID: <20090528001432.GA6911@cmpxchg.org>
References: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org> <20090527144851.832a0375.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090527144851.832a0375.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh.dickins@tiscali.co.uk, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 02:48:51PM -0700, Andrew Morton wrote:
> On Wed, 27 May 2009 17:05:46 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > The current swap readahead implementation reads a physically
> > contiguous group of swap slots around the faulting page to take
> > advantage of the disk head's position and in the hope that the
> > surrounding pages will be needed soon as well.
> > 
> > This works as long as the physical swap slot order approximates the
> > LRU order decently, otherwise it wastes memory and IO bandwidth to
> > read in pages that are unlikely to be needed soon.
> > 
> > However, the physical swap slot layout diverges from the LRU order
> > with increasing swap activity, i.e. high memory pressure situations,
> > and this is exactly the situation where swapin should not waste any
> > memory or IO bandwidth as both are the most contended resources at
> > this point.
> > 
> > This patch makes swap-in base its readaround window on the virtual
> > proximity of pages in the faulting VMA, as an indicator for pages
> > needed in the near future, while still taking physical locality of
> > swap slots into account.
> > 
> > This has the advantage of reading in big batches when the LRU order
> > matches the swap slot order while automatically throttling readahead
> > when the system is thrashing and swap slots are no longer nicely
> > grouped by LRU order.
> > 
> 
> Well.  It would be better to _not_ shrink readaround, but to make it
> read the right pages (see below).
> 
> Or perhaps the readaround size is just too large.  I did spend some
> time playing with its size back in the dark ages and ended up deciding
> that the current setting is OK, but that was across a range of
> workloads.
> 
> Did you try simply decreasing the cluster size and seeing if that had a
> similar effect upon this workload?

No, I will try that.

> Back in 2002 or thereabouts I had a patch <rummage, rummage.  Appended>
> which does this the other way.  It attempts to ensure that swap space
> is allocated so that virtually contiguous pages get physically
> contiguous blocks on disk.  So that when swapspace readaround does its
> thing, the blocks which it reads are populating pages which are
> virtually "close" to the page which got the major fault.
> 
> Unfortunately I wasn't able to demonstrate much performance benefit
> from it and didn't get around to working out why.

I did something similar once: broke down swap space into contiguous
clusters sized 1 << page_cluster and that were maintained on
free/partial/full lists per swap device.  Then, every anon vma got a
group of clusters that backed its pages.  I think it's best described
as extent-based backing of anon VMAs.  I didn't hash offsets into the
swap device, just allocated a new cluster from the freelist if there
wasn't already one for that particular part of the vma and then used
page->index & some_mask for the static in-cluster offset.

But IIRC it was defeated by the extra seeking that came with the
internal fragmentation of the extents and separation of lru-related
pages (see below).

> iirc, the way it worked was: divide swap into 1MB hunks.  When we
> decide to add an anon page to swapcache, grab a 1MB hunk of swap and
> then add the pages which are virtual neighbours of the target page to
> swapcache as well.
> 
> Obviously the algorithm could be tweaked/tuned/fixed, but the idea
> seems sound - the cost of reading a contiguous hunk of blocks is not a
> lot more than reading the single block.
> 
> Maybe it's something you might like to have a think about.

I gave up the idea because I think the VMA order is a good hint but
not useful to layout swap slots based exclusively on it.  The reason
for that being that one slice of LRU pages with the same access
frequency (in scan time granularity) doesn't come from one VMA only
but from several ones and doing strict VMA grouping separates
LRU-related pages physically on swap and thus unavoidably adds holes
between data that are used in similar frequencies.

I think this is a realistic memory state:

	vma 1:		 [a b c d e f g]
	vma 2:		 [h i j k l m n]
	LRU/swap layout: [c d e i j k l]

A major fault on page d would readahead [c d e] with my patch (and
maybe also i and j with the current readahead algorithm).

Having swap pages explicitely vma-grouped instead could now very well
read [a b c d] or [d e f g].  Which is fine unless we need that memory
for pages like i, j, k and l that are likely to be needed earlier than
a, b, f and g.

And due to the hashing into swap space by a rather arbitrary value
like the anon vma address, and the slots for [a b], [f g] and h with
different access frequency in between, you might now have quite some
distance between [c d e] and [i j k l] which are likely to be used
together.

I think our current swap allocation layout is great at keeping things
compact.  But it will not always keep the LRU order intact, which I
found very hard to fix without moving the performance hits someplace
else.

> > - * Primitive swap readahead code. We simply read an aligned block of
> > - * (1 << page_cluster) entries in the swap area. This method is chosen
> > - * because it doesn't cost us any seek time.  We also make sure to queue
> > - * the 'original' request together with the readahead ones...
> > - *
> > -	/*
> > -	 * Get starting offset for readaround, and number of pages to read.
> > -	 * Adjust starting address by readbehind (for NUMA interleave case)?
> > -	 * No, it's very unlikely that swap layout would follow vma layout,
> > -	 * more likely that neighbouring swap pages came from the same node:
> > -	 * so use the same "addr" to choose the same node for each swap read.
> > -	 */
> 
> The patch deletes the old design description but doesn't add a
> description of the new design :(

Bad indeed, I will fix it up.

Thanks for your time,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
