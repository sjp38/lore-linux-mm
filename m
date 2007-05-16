Date: Wed, 16 May 2007 12:00:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/2] Only check absolute watermarks for ALLOC_HIGH and
 ALLOC_HARDER allocations
In-Reply-To: <20070516184819.GF10225@skynet.ie>
Message-ID: <Pine.LNX.4.64.0705161153540.10368@schroedinger.engr.sgi.com>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie> <464AF589.2000000@yahoo.com.au>
 <20070516132419.GA18542@skynet.ie> <464B089C.9070805@yahoo.com.au>
 <20070516140038.GA10225@skynet.ie> <464B110E.2040309@yahoo.com.au>
 <464B4D43.9020002@shadowen.org> <20070516184819.GF10225@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > few pages at those orders and some (where possible) are reserved for
> > PF_MEM tasks, for reclaim itself.  However, the reservation system takes
> > no account of higher orders, so we can always end up in a situation

Could we change the reservation system to take account of higher orders?

> > My understanding is all slabs within a slub slab cache have to be the
> > same order.  So we need to ensure that any slab that might be used from
> > the reclaim path must only use order-0 pages.  Also it seems that any
> > slab that is allocated from atomically will have to use order-0 pages in
> > order to remain reliable.  Christoph, do we have any facility to tag
> > caches to use a specific allocation order?

I would like to avoid adding such a flag. Forcing low orders on a 
slab limits its scalability. Higher orders mean less frequent taking of 
locks. We adding more special casing to the VM. Its better if we could 
handle the reserves in such a way that higher allocs are possible.

Another solution may be to make sure that we can tolerate failures of 
atomic allocs? GFP_ATOMIC has always had the stigma of being able to fail 
after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
