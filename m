Date: Thu, 14 Feb 2008 11:57:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher
 order allocs
In-Reply-To: <47B49ADD.9010001@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802141153300.809@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com> <20080214040313.616551392@sgi.com>
 <20080214140614.GE17641@csn.ul.ie> <Pine.LNX.4.64.0802141108530.32613@schroedinger.engr.sgi.com>
 <47B49520.4070201@cs.helsinki.fi> <Pine.LNX.4.64.0802141128430.375@schroedinger.engr.sgi.com>
 <47B49ADD.9010001@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Pekka Enberg wrote:

> Aah, I see. I wonder if we can fix up allocate_slab() to try with a smaller
> order as long as the size allows that? The only problem I can see is
> s->objects but I think we can just move that to be a per-slab variable. So
> sort of variable-order slabs kind of a thing.

Urgh. This is going to require a count of the maximum number of objects 
per individual slab page. Adds more overhead to the fast path and means 
that not all the slabs may have the same order. Which may in turn result 
in a mix of order 3 2 1 pages. Not good for fragmentation. I think the 
do order 3 always and then order 0 if we are in a bad fragmentation 
state the best compromise. In particular because these bad fragmented 
memory scenarios seems to be very difficult to produce and occur only in 
specialized situations (f.e. minimal ram with lots of page pinned by I/O, 
stuff like that).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
