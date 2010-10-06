Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 211CC6B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:25:55 -0400 (EDT)
Date: Wed, 6 Oct 2010 18:25:47 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
Message-ID: <20101006162547.GA17987@basil.fritz.box>
References: <20101005185725.088808842@linux.com>
 <87fwwjha2u.fsf@basil.nowhere.org>
 <alpine.DEB.2.00.1010061057160.31538@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010061057160.31538@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 10:59:55AM -0500, Christoph Lameter wrote:
> On Wed, 6 Oct 2010, Andi Kleen wrote:
> 
> > Christoph Lameter <cl@linux.com> writes:
> >
> > Not looked at code so far, but just comments based on the
> > description. But thanks for working on this, it's good
> > to have alternatives to the ugly slab.c
> >
> > > V3->V4:
> > > - Lots of debugging
> > > - Performance optimizations (more would be good)...
> > > - Drop per slab locking in favor of per node locking for
> > >   partial lists (queuing implies freeing large amounts of objects
> > >   to per node lists of slab).
> >
> > Is that really a good idea? Nodes (= sockets) are getting larger and
> > larger and they are quite substantial SMPs by themselves now.
> > On Xeon 75xx you have 16 virtual CPUs per node.
> 
> True. The shared caches can compensate for that. Without this I got
> regression because of too many atomic operations during draining and
> refilling.

Could you just do it by smaller units? (e.g. cores on SMT systems)

I agree some sharing is a good idea, just a node is likely too large.

> > > 2. SLUB object expiration is tied into the page reclaim logic. There
> > >    is no periodic cache expiration.
> >
> > Hmm, but that means that you could fill a lot of memory with caches
> > before they get pruned right? Is there another limit too?
> 
> The cache all have an limit on the number of objects in them (like SLAB).
> If you want less you can limit the sizes of the queues.
> Otherwise there is no other limit.

So it would depend on that total number of caches in the system?
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
