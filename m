Date: Mon, 27 Aug 2007 11:50:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/6] Per cpu structures for SLUB
In-Reply-To: <20070824143848.a1ecb6bc.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708271144440.4667@schroedinger.engr.sgi.com>
References: <20070823064653.081843729@sgi.com> <20070824143848.a1ecb6bc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2007, Andrew Morton wrote:

> I'm struggling a bit to understand these numbers.  Bigger is better, I
> assume?  In what units are these numbers?

No less is better. These are cycle counts. Hmmm... We discussed these 
cycle counts so much in the last week that I forgot to mention that.

> > Page allocator pass through
> > ---------------------------
> > There is a significant difference in the columns marked with a * because
> > of the way that allocations for page sized objects are handled.
> 
> OK, but what happened to the third pair of columns (Concurrent Alloc,
> Kmalloc) for 1024 and 2048-byte allocations?  They seem to have become
> significantly slower?

There is a significant performance increase there. That is the main point 
of the patch.

> Thanks for running the numbers, but it's still a bit hard to work out
> whether these changes are an aggregate benefit?

There is a drawback because of the additional code introduced in the fast 
path. However, the regular kmalloc case shows improvements throughout. 
This is in particular of importance for SMP systems. We see an improvement 
even for 2 processors.

> > If we handle
> > the allocations in the slab allocator (Norm) then the alloc free tests
> > results are superb since we can use the per cpu slab to just pass a pointer
> > back and forth. The page allocator pass through (PCPU) shows that the page
> > allocator may have problems with giving back the same page after a free.
> > Or there something else in the page allocator that creates significant
> > overhead compared to slab. Needs to be checked out I guess.
> > 
> > However, the page allocator pass through is a win in the other cases
> > since we can cut out the page allocator overhead. That is the more typical
> > load of allocating a sequence of objects and we should optimize for that.
> > 
> > (+ = Must be some cache artifact here or code crossing a TLB boundary.
> > The result is reproducable)
> > 
> 
> Most Linux machines are uniprocessor.  We should keep an eye on what effect
> a change like this has on code size and performance for CONFIG_SMP=n
> builds..

There is an #ifdef around ther per cpu structure management code. All of 
this will vanish (including the lookup of the per cpu address from the 
fast path) if SMP is off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
