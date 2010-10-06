Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1C68C6B0071
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:02:10 -0400 (EDT)
Date: Wed, 6 Oct 2010 10:59:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <87fwwjha2u.fsf@basil.nowhere.org>
Message-ID: <alpine.DEB.2.00.1010061057160.31538@router.home>
References: <20101005185725.088808842@linux.com> <87fwwjha2u.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Andi Kleen wrote:

> Christoph Lameter <cl@linux.com> writes:
>
> Not looked at code so far, but just comments based on the
> description. But thanks for working on this, it's good
> to have alternatives to the ugly slab.c
>
> > V3->V4:
> > - Lots of debugging
> > - Performance optimizations (more would be good)...
> > - Drop per slab locking in favor of per node locking for
> >   partial lists (queuing implies freeing large amounts of objects
> >   to per node lists of slab).
>
> Is that really a good idea? Nodes (= sockets) are getting larger and
> larger and they are quite substantial SMPs by themselves now.
> On Xeon 75xx you have 16 virtual CPUs per node.

True. The shared caches can compensate for that. Without this I got
regression because of too many atomic operations during draining and
refilling.

The other alternative is to stay with the current approach
which minimizes the queuing etc overhead and can affort to have the
overhead.

> > 2. SLUB object expiration is tied into the page reclaim logic. There
> >    is no periodic cache expiration.
>
> Hmm, but that means that you could fill a lot of memory with caches
> before they get pruned right? Is there another limit too?

The cache all have an limit on the number of objects in them (like SLAB).
If you want less you can limit the sizes of the queues.
Otherwise there is no other limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
