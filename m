Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1416A6B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 11:10:21 -0500 (EST)
Date: Fri, 23 Jan 2009 17:10:17 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123161017.GC14517@wotan.suse.de>
References: <20090114150900.GC25401@wotan.suse.de> <Pine.LNX.4.64.0901141158090.26507@quilx.com> <20090115060330.GB17810@wotan.suse.de> <Pine.LNX.4.64.0901151320250.26467@quilx.com> <20090116031940.GL17810@wotan.suse.de> <Pine.LNX.4.64.0901161500080.27283@quilx.com> <20090119054730.GA22584@wotan.suse.de> <alpine.DEB.1.10.0901211914140.18367@qirst.com> <20090123041756.GH20098@wotan.suse.de> <alpine.DEB.1.10.0901231042380.32253@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0901231042380.32253@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 10:52:43AM -0500, Christoph Lameter wrote:
> On Fri, 23 Jan 2009, Nick Piggin wrote:
> 
> > > Typically we traverse lists of objects that are in the same slab cache.
> >
> > Very often that is not the case. And the price you pay for that is that
> > you have to drain and switch freelists whenever you encounter an object
> > that is not on the same page.
> 
> SLUB can directly free an object to any slab page. "Queuing" on free via
> the per cpu slab is only possible if the object came from that per cpu
> slab. This is typically only the case for objects that were recently
> allocated.

Ah yes ok that's right. But then you don't get LIFO allocation
behaviour for those cases.

 
> > This gives your freelists a chaotic and unpredictable behaviour IMO in
> > a running system where pages succumb to fragmentation so your freelist
> > maximum sizes are limited. It also means you can lose track of cache
> > hot objects when you switch to different "fast" pages. I don't consider
> > this to be "queueing done right".
> 
> Yes you can loose track of caching hot objects. That is one of the
> concerns with the SLUB approach. On the other hand: Caching architectures
> get more and more complex these days (especially in a NUMA system). The

Because it is more important to get good cache behaviour. 


> SLAB approach is essentially trying to guess which objects are cache hot
> and queue them. Sometimes the queueing is advantageous (may be a reason
> that SLAB is better than SLUB in some cases). In other cases SLAB keeps
> objects on queues but the object have become sale (context switch, slab
> unused for awhile). Then its no advantage anymore.

But in those cases would be expected to be encountered if that slab
is not used as frequently, ergo less performance critical. And
ones that are used frequently should be more likely to have recently
freed cache hot objects.


> > > If all objects are from the same page then you need not check
> > > the NUMA locality of any object on that queue.
> >
> > In SLAB and SLQB, all objects on the freelist are on the same node. So
> > tell me how does same-page objects simplify numa  handling?
> 
> F.e. On free you need to determine the node to find the right queue in
> SLAB. SLUB does not need to do that. It simply determines the page address
> and does not care about the node when freeing the object. It is irrelevant
> on which node the object sits.

OK, but how much does that help?

 
> Also on alloc: The per cpu slab can be from a foreign node. NUMA locality
> does only matter if the caller wants memory from a particular node. So
> cpus that have no local memory can still use the per cpu slabs to have
> fast allocations etc etc.

Yeah. In my experience I haven't needed to optimise this type of behaviour
yet, but other allocators could definitely do similar things to switch their
queues to different nodes.


> > > > And you found you have to increase the size of your pages because you
> > > > need bigger queues. (must we argue semantics? it is a list of free
> > > > objects)
> > >
> > > Right. That may be the case and its a similar tuning to what SLAB does.
> >
> > SLAB and SLQB doesn't need bigger pages to do that.
> 
> But they require more metadata handling because they need to manage lists
> of order-0 pages. metadata handling is reduced by orders of magnitude in
> SLUB.

SLQB's page lists typically get accessed eg. 1% of the time (sometimes far
less, other workloads more). So it is several orders of magnitude removed
from the fastpath which is handled by the freelist.

So I think it is wrong to say it requires more metadata handling. SLUB
will have to switch pages more often or free objects to pages other than
the "fast" page (what do you call it?), so quite often I think you'll
find SLUB has just as much if not more metadata handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
