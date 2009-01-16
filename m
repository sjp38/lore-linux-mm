Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EDB7E6B0044
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:43:59 -0500 (EST)
Date: Fri, 16 Jan 2009 04:43:56 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090116034356.GM17810@wotan.suse.de>
References: <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com> <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com> <20090114150900.GC25401@wotan.suse.de> <20090114152207.GD25401@wotan.suse.de> <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com> <20090114155923.GC1616@wotan.suse.de> <Pine.LNX.4.64.0901141219140.26507@quilx.com> <20090115061931.GC17810@wotan.suse.de> <Pine.LNX.4.64.0901151434150.28387@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901151434150.28387@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 15, 2009 at 02:47:02PM -0600, Christoph Lameter wrote:
> On Thu, 15 Jan 2009, Nick Piggin wrote:
> 
> > Definitely it is not uncontrollable. And not unchangeable. It is
> > about the least sensitive part of the allocator because in a serious
> > workload, the queues will continually be bounded by watermarks rather
> > than timer reaping.
> 
> The application that is interrupted has no control over when SLQB runs its
> expiration. The longer the queues the longer the holdoff. Look at the
> changelogs for various queue expiration things in the kernel. I fixed up a
> couple of those over the years for latency reasons.

Interrupts and timers etc. as well as preemption by kernel threads happen
everywhere in the kernel. I have not seen any reason why slab queue reaping
in particular is a problem.

Any slab allocator is going to have a whole lot of theoretical problems and
you simply won't be able to fix them all because some require an oracle or
others fundamentally conflict with another theoretical problem.

I concentrate on the main practical problems and the end result. If I see
evidence of some problem caused, then I will do my best to fix it.


> > > Object dispersal
> > > in the kernel address space.
> >
> > You mean due to lower order allocations?
> > 1. I have not seen any results showing this gives a practical performance
> >    increase, let alone one that offsets the downsides of using higher
> >    order allocations.
> 
> Well yes with enterprise app you are likely not going to see it. Run HPC
> and other low latency tests (Infiniband based and such).

So do you have any results or not?

 
> > 2. Increased internal fragmentation may also have the opposite effect and
> >    result in worse packing.
> 
> Memory allocations in latency critical appls are generally done in
> contexts where high latencies are tolerable (f.e. at startup).
> 
> > 3. There is no reason why SLQB can't use higher order allocations if this
> >    is a significant win.
> 
> It still will have to move objects between queues? Or does it adapt the
> slub method of "queue" per page?

It has several queues that objects can move between. You keep asserting
that this is a problem.

 
> > > Memory policy handling in the slab
> > > allocator.
> >
> > I see no reason why this should be a problem. The SLUB merge just asserted
> > it would be a problem. But actually SLAB seems to handle it just fine, and
> > SLUB also doesn't always obey memory policies, so I consider that to be a
> > worse problem, at least until it is justified by performance numbers that
> > show otherwise.
> 
> Well I wrote the code in SLAB that does this. And AFAICT this was a very
> bad hack that I had to put in after all the original developers of the
> NUMA slab stuff vanished and things began to segfault.
> 
> SLUB obeys memory policies. It just uses the page allocator for this by
> doing an allocation *without* specifying the node that memory has to come
> from. SLAB manages memory strictly per node. So it always has to ask for
> memory from a particular node. Hence the need to implement memory policies
> in the allocator.

You only go to the allocator when the percpu queue goes empty though, so
if memory policy changes (eg context switch or something), then subsequent
allocations will be of the wrong policy.

That is what I call a hack, which is made in order to solve a percieved
performance problem. The SLAB/SLQB method of checking policy is simple,
obviously correct, and until there is a *demonstrated* performance problem
with that, then I'm not going to change it.


> > > Even seems to include periodic moving of objects between
> > > queues.
> >
> > The queues expire slowly. Same as SLAB's arrays. You are describing the
> > implementation, and not the problems it has.
> 
> Periodic movement again introduces processing spikes and pollution of the
> cpu caches.

I don't think this is a problem. Anyway, rt systems that care about such
tiny latencies can easily prioritise this. And ones that don't care so
much have many other sources of interrupts and background processing by
the kernel or hardware interrupts.

If this actually *is* a problem, I will allow an option to turn of periodic
trimming of queues, and allow objects to remain in queues (like the page
allocator does with its queues). And just provide hooks to reap them at
low memory time.

 
> > There needs to be some fallback cases added to slowpaths to handle
> > these things, but I don't see why it would take much work.
> 
> The need for that fallback comes from the SLAB methodology used....

The fallback will probably be adapted from SLUB.

 
> > > SLQB maybe a good cleanup for SLAB. Its good that it is based on the
> > > cleaned up code in SLUB but the fundamental design is SLAB (or rather the
> > > Solaris allocator from which we got the design for all the queuing stuff
> > > in the first place). It preserves many of the drawbacks of that code.
> >
> > It is _like_ slab. It avoids the major drawbacks of large footprint of
> > array caches, and O(N^2) memory consumption behaviour, and corner cases
> > where scalability is poor. The queueing behaviour of SLAB IMO is not
> > a drawback and it is a big reaon why SLAB is so good.
> 
> Queuing and the explosions of the number of queues with the alien caches
> resulted in the potential of portions of memory vanishing into these
> queues. Queueing means unused objects are in those queues stemming from
> pages that would otherwise (if the the free object would be "moved" back
> to the page) be available for other kernel uses.

It's strange. You percieve these theoretical problems with things that I
actually consider is a distinct *advantage* of SLAB/SLQB. order-0 allocations,
queueing, strictly obeying NUMA policies... 


> > > If SLQB would replace SLAB then there would be a lot of shared code
> > > (debugging for example). Having a generic slab allocator framework may
> > > then be possible within which a variety of algorithms may be implemented.
> >
> > The goal is to replace SLAB and SLUB. Anything less would be a failure
> > on behalf of SLQB. Shared code is not a bad thing, but the major problem
> > is the actual core behaviour of the allocator because it affects almost
> > everywhere in the kernel and splitting userbase is not a good thing.
> 
> I still dont see the problem that SLQB is addressing (aside from code
> cleanup of SLAB). Seems that you feel that the queueing behavior of SLAB
> is okay.

It addresses O(NR_CPUS^2) memory consumption of kmem caches, and large
constant consumption of array caches of SLAB. It addresses scalability
eg in situations with lots of cores per node. It allows resizeable
queues. It addresses the code complexity and bootstap hoops of SLAB.

It addresses performance and higher order allocation problems of SLUB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
