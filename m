Date: Tue, 1 Jul 2003 05:22:48 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030701032248.GM3040@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <20030630200237.473d5f82.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030630200237.473d5f82.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 30, 2003 at 08:02:37PM -0700, Andrew Morton wrote:
> NOFAIL is what 2.4 has always done, and has the deadlock opportunities

fair enough ;) but you're talking 2.4 mainline, 2.4-aa never did but I
didn't convince Linus or Marcelo to merge it. As usual my argument is
that it's better to have the slight risk to fail an allocation than to
be deadlock prone.

> which you mention.  The other modes allow the caller to say "don't try
> forever".
> 
> It's mainly a cleanup - it allowed the removal of lots of "try forever"
> loops by consolidating that behaviour in the page allocator.  If all

which is wrong since those loops should never exists, and this makes
their life easier, not harder.

> callers are fixed up to not require NOFAIL then we don't need it any more.

Agreed indeed.

> > as for the per-zone lists, sure they increase scalability, but it loses
> > aging information, the worst case will be reproducible on a 1.6G box,
> 
> Actually it improves aging information.  Think of a GFP_KERNEL allocation
> on an 8G 2.4.x box: an average of 10 or more highmem pages get bogusly
> rotated to the wrong end of the LRU for each scanned lowmem page.

if you assume GFP_KERNEL are more frequent or equal then GFP_HIGHMEM
then yes I would agree. if they would be equally frequent, there would
be nearly no problem at all.

But GFP_KERNEL allocations are normally an order of magnitude less
frequent than highmem allocations (even rmap should try not to allocate
a page for each page fault in some common case ;). Think allocating 1G
of ram and bzeroing it, it shouldn't generate a single GFP_KERNEL
allocation.  Of course if you've 1 page per vma the things is different
but it's usually not the common case.

IMHO there is an high risk that very old data lives in cache for very
long times. There can be as much as 800M of cache in zone normal, and
before you allocate 800M of GFP_KERNEL ram it can take a very long time.
Also think if you've a 1G box, the highmem list would be very small and
if you shrink it first, you'll waste an huge amount of cache. Maybe you
go shrink the zone normal list first in such case of unbalance?

Overall I think rotating too fast a global list sounds much better in this
respect (with less infrequent GFP_KERNELS compared to the
highmem/pagecache/anonmemory allocation rate) as far as I can tell, but
I admit I didn't do any math (I didn't feel the need of a demonstration
but maybe we should?).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
