Date: Thu, 14 Feb 2008 11:32:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher
 order allocs
In-Reply-To: <47B49520.4070201@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802141128430.375@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com> <20080214040313.616551392@sgi.com>
 <20080214140614.GE17641@csn.ul.ie> <Pine.LNX.4.64.0802141108530.32613@schroedinger.engr.sgi.com>
 <47B49520.4070201@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Pekka Enberg wrote:

> Christoph Lameter wrote:
> > The kmalloc slab allocation will use order 3. The allocation for an
> > individual object via the page allocator only uses order 0. The order 0
> > alloc will succeed even if memory is extremely fragmented. Its a safety
> > valve that Nick probably finds important.
> 
> Hmm, shouldn't we then fix just fix calculate_order() to not try so hard to
> find better fitting higher orders?

That would mean reducing the number of objects that can be allocated from 
the fastpath before we have to go to the page allocator again. Increasing 
the number of fastpath uses vs slowpath increases the overall performance 
of a slab.

If we would use order 0 slab allocs for 4k slabs then every call to 
slab_alloc would lead to a corresponding call to the page allocator. The 
regression would not be fixed. We just add slab_alloc overhead to an 
already bad page allocator call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
