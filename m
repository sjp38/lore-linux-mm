Date: Wed, 23 Oct 2002 16:23:42 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
Message-ID: <20021023142342.GC1912@dualathlon.random>
References: <20021023115026.GB30182@dualathlon.random> <Pine.LNX.4.44.0210231618150.10431-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210231618150.10431-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 23, 2002 at 04:20:30PM +0200, Ingo Molnar wrote:
> 
> On Wed, 23 Oct 2002, Andrea Arcangeli wrote:
> 
> > it's not another vma tree, furthmore another vma tree indexed by the
> > hole size wouldn't be able to defragment and it would find the best fit
> > not the first fit on the left.
> 
> what i was talking about was a hole-tree indexed by the hole start

yes an hole tree.

> address, not a vma tree indexed by the hole size. (the later is pretty

indexed by the hole start address? then it's still O(N), then your quick
cache for the first hole would not be much different. I above meant hole
size, then it would be O(log(N)), but it wouldn't defragment anymore.

> pointless.) And even this solution still has to search the tree linearly
> for a matching hole.

exactly, it's still O(N).

The final solution needed isn't a plain tree, it needs modifications to
the rbtree code to make the data structure more powerful, that will
provide that info in O(log(N)) without an additional tree and starting
from the left (i.e. it won't alter the retval of get_unmapped_area, just
its speed).  the design is just finished for some time, what's left is
to implement it and it isn't trivial ;).

Anyways this O(log(N)) complexity improvement is needed anyways, old
applications will be still around in particular when they will find they
don't need special API to work fast.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
