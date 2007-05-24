Date: Thu, 24 May 2007 09:36:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524061153.GP11115@waste.org>
Message-ID: <Pine.LNX.4.64.0705240928020.27844@schroedinger.engr.sgi.com>
References: <20070523071200.GB9449@wotan.suse.de>
 <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com>
 <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com>
 <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com>
 <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com>
 <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
 <20070524061153.GP11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Matt Mackall wrote:

> So, here's three possible approaches to this issue:
> 
> A) Continue to ignore it. Doing something about it would add
> complexity and it's not clear that it's a win.
> 
> B) Set NR_SLAB_RECLAIMABLE to 1. If the VM starts checking that to
> decide whether it should call shrinkers, things will continue to work.
> Increment and decrement NR_SLAB_UNRECLAIMABLE when we grow/shrink the
> SLOB pool. This is probably 3 lines of code total.
> 
> C) Fake NR_SLAB_RECLAIMABLE/NR_SLAB_UNRECLAIMABLE based on actual
> allocs and slab flags such that they sum to the total pages in the
> SLOB pool. This would need a third global counter in bytes of how many
> allocs we had in the "reclaimable" slabs. Probably 10-20 lines of
> code of marginal utility. 
> 
> So, nothing insurmountable here. Just not convinced we should bother.
> But the cost of B is so low, perhaps I might as well.

D) Do the right thing and implement the counters.

At the time of calling alloc_pages() you know that you have to increment 
either counter but you do not know which.

For that purpose you add another byte counter (reclaim_counter) that 
contains the number of reclaimable bytes allocated. Sum them up during 
slob_alloc if flags & SLAB_RECLAIM_ACCOUNT is set.

Then after a page allocator alloc you check the following:

If (NR_SLAB_RECLAIMABLE << PAGE_SHIFT) >= reclaim_counter then increment 
NR_SLAB_UNRECLAIMABLE otherwise NR_SLAB_RECLAIMABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
