Date: Thu, 27 Dec 2007 11:40:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB
In-Reply-To: <4773B50B.6060206@hp.com>
Message-ID: <Pine.LNX.4.64.0712271137470.30555@schroedinger.engr.sgi.com>
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com>
 <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com>
 <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Seger <Mark.Seger@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Dec 2007, Mark Seger wrote:

> Now that I've had some more time to think about this and play around with the
> slabinfo tool I fear my problem had getting my head wrapped around the
> terminology, but that's my problem.  Since there are entries called
> object_size, objs_per_slab and slab_size I would have thought that
> object_size*objects_per_slab=slab_size but that clearly isn't the case.  Since
> slabs are allocated in pages, the actual size of the slabs is always a
> multiple of the page_size (actually by a power of 2) and that's why I see
> calculations in slabinfo like page_size << order, but I guess I'm still not
> sure what the  actual definition of 'order' actually is.

order is the shift you apply to PAGE_SIZE to get to the allocation size 
you want. Order 0 = PAGE_SIZE, order 1 = PAGE_SIZE << 1 (PAGE_SIZE *2), 
order 2 = PAGE_SIZE << 2 (PAGE_SIZE * 4) etc.

> Slabcache: skbuff_fclone_cache   Aliases:  0 Order :  0 Objects: 25
> ** Hardware cacheline aligned
> 
> Sizes (bytes)     Slabs              Debug                Memory
> ------------------------------------------------------------------------
> Object :     420  Total  :       4   Sanity Checks : Off  Total:   16384
> SlabObj:     448  Full   :       0   Redzoning     : Off  Used :   10500
> SlabSiz:    4096  Partial:       0   Poisoning     : Off  Loss :    5884
> Loss   :      28  CpuSlab:       4   Tracking      : Off  Lalig:     700
> Align  :       0  Objects:       9   Tracing       : Off  Lpadd:     256
> 
> according to the entries under /sys/slabs/skbuff_fclone_cache it looks like
> the slab_size field is being reported above as 'SlabObj' and objs_per_slab is
> being reported as 'Objects' and as I mentioned above, SlabSiz is based on
> 'order'.
> 
> Anyhow, as I understand what's going on at a very high level, memory is
> reserved for use as slabs (which themselves are multiples of pages) and
> processes allocate objects from within slabs as they need them.  Therefore the
> 2 high-level numbers that seem of interest from a memory usage perspective are
> the memory allocated and the amount in use.  I think these are the "Total" and
> "Used" fields in slabinfo.

Total is the total memory allocated from the page allocator. There are 4 
slab allocated with the size of 4096 bytes each. This is 16k.

The used value is the memory that was actually handed out through kmalloc 
and friends.
 
> Total = page_size << order

Order = 0. So Total would be 4096 << 0 = 4096. Wrong value.

> As for 'Used' that looks to be a straight calculation of objects * object_size

Right.

> The Slabs field in /proc/meminfo is the total of the individual 'Total's...

Right.

> Stay tuned and at some point I'll have support in collectl for reporting
> total/allocated usage by slab in collectl, though perhaps I'll post a
> 'proposal' first in the hopes of getting some constructive feedback as I want
> to present useful information rather than that columns of numbers.

Ahh Great. Thanks for all your work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
