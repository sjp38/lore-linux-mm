Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 665D46B0098
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 04:33:20 -0400 (EDT)
Date: Fri, 10 Sep 2010 09:33:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH] fs,xfs: Use __GFP_MOVABLE for XFS buffers
Message-ID: <20100910083304.GD340@csn.ul.ie>
References: <20100909111131.GO29263@csn.ul.ie> <20100910003706.GC7032@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100910003706.GC7032@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, Alex Elder <aelder@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 10, 2010 at 10:37:06AM +1000, Dave Chinner wrote:
> On Thu, Sep 09, 2010 at 12:11:32PM +0100, Mel Gorman wrote:
> > Fragmentation avoidance in the kernel depends on reclaimable and movable
> > allocations being marked-up at page allocation time. Reclaimable allocations
> > refer to slab caches such as inode caches which can be reclaimed although
> > not necessarily in a targetted fashion. Movable pages are those pages that
> > can be moved to backing storage (during page reclaim) or migrated.
> > 
> > When testing against XFS, it was noticed that large page allocation rates
> > against XFS were far lower than expected in comparison to ext3. Investigation
> > showed that buffer pages allocated by XFS are placed on the LRU but not
> > marked __GFP_MOVABLE at allocation time.
> > 
> > This patch updates xb_to_gfp() to specify __GFP_MOVABLE and is correct iff
> > all pages allocated from a mask derived from xb_to_gfp() are guaranteed to
> > be movable be it via page reclaim or page migration. It needs an XFS expert
> > to make that determination but when applied, huge page allocation success
> > rates are similar to those seen on tests backed by ext3.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> I don't see any problems with this, but I don't think it's going to
> be useful for very long given the work I'm doing on the XFS buffer
> cache right now - converting it to caching buffers with a shrinker
> traversed LRU for reclaim instead of using the page cache and hoping
> reclaim doesn't trash the working set.
> 

THat's ok. After I sent the patch, I ran another test with just this
patch applied and the success rates are still much lower than ext3. My
initial results had other patches in the mix confusing the results.
There also appears to be allocations that should have got
__GFP_RECLAIMABLE.

> I'm hoping to have it done in time for the .37 merge window, so
> adding __GFP_MOVEABLE now might not to even see a release....
> 

I'll revisit it later so and see can I spot what allocations need to be
marked up to play nicely with fragmentation avoidance. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
