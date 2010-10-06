Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BAF9C6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:37:15 -0400 (EDT)
Date: Wed, 6 Oct 2010 11:37:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <20101006162547.GA17987@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1010061133210.31538@router.home>
References: <20101005185725.088808842@linux.com> <87fwwjha2u.fsf@basil.nowhere.org> <alpine.DEB.2.00.1010061057160.31538@router.home> <20101006162547.GA17987@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Andi Kleen wrote:

> > True. The shared caches can compensate for that. Without this I got
> > regression because of too many atomic operations during draining and
> > refilling.
>
> Could you just do it by smaller units? (e.g. cores on SMT systems)

The shared caches are not per node but per sharing domain (l3).

The difficulty with making the partial lists work for a smaller unit is
that this would require a mechanism to fallback to other partial lists for
the same node if one would be exhausted?

Also how does one figure out which partial list a slab belongs to? Right
now this is by node. We would have to store the partial list number in the
page struct.

> I agree some sharing is a good idea, just a node is likely too large.

You can increase the batching in order to reduce the load on the node
locks. The sharing caches will take care of a lot of the intra node
movement also.

> > > > 2. SLUB object expiration is tied into the page reclaim logic. There
> > > >    is no periodic cache expiration.
> > >
> > > Hmm, but that means that you could fill a lot of memory with caches
> > > before they get pruned right? Is there another limit too?
> >
> > The cache all have an limit on the number of objects in them (like SLAB).
> > If you want less you can limit the sizes of the queues.
> > Otherwise there is no other limit.
>
> So it would depend on that total number of caches in the system?

Yes. Also the expiration is triggerable from user space. You can set up a
cron job that triggers cache expiration every minute or so.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
