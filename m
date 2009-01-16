Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1A0156B0087
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 16:25:18 -0500 (EST)
Date: Fri, 16 Jan 2009 15:25:05 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090116034356.GM17810@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901161509160.27283@quilx.com>
References: <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
 <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
 <20090114150900.GC25401@wotan.suse.de> <20090114152207.GD25401@wotan.suse.de>
 <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>
 <20090114155923.GC1616@wotan.suse.de> <Pine.LNX.4.64.0901141219140.26507@quilx.com>
 <20090115061931.GC17810@wotan.suse.de> <Pine.LNX.4.64.0901151434150.28387@quilx.com>
 <20090116034356.GM17810@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009, Nick Piggin wrote:

> > The application that is interrupted has no control over when SLQB runs its
> > expiration. The longer the queues the longer the holdoff. Look at the
> > changelogs for various queue expiration things in the kernel. I fixed up a
> > couple of those over the years for latency reasons.
>
> Interrupts and timers etc. as well as preemption by kernel threads happen
> everywhere in the kernel. I have not seen any reason why slab queue reaping
> in particular is a problem.

The slab queues are a particular problem since they are combined with
timers. So the latency insensitive phase of an HPC app completes and then
the latency critical part starts to run. SLAB will happily every 2 seconds
expire a certain amount of objects from all its various queues.

> Any slab allocator is going to have a whole lot of theoretical problems and
> you simply won't be able to fix them all because some require an oracle or
> others fundamentally conflict with another theoretical problem.

I agree there is no point in working on theoretical problems. We are
talking about practical problems.

> I concentrate on the main practical problems and the end result. If I see
> evidence of some problem caused, then I will do my best to fix it.

You concentrate on the problems that are given to you I guess...

> > Well yes with enterprise app you are likely not going to see it. Run HPC
> > and other low latency tests (Infiniband based and such).
>
> So do you have any results or not?

Of course. I need to repost them? I am no longer employed by the company I
did the work for. So the test data is no longer accessible to me. You have
to rely on the material that was posted in the past.

> > It still will have to move objects between queues? Or does it adapt the
> > slub method of "queue" per page?
>
> It has several queues that objects can move between. You keep asserting
> that this is a problem.

> > SLUB obeys memory policies. It just uses the page allocator for this by
> > doing an allocation *without* specifying the node that memory has to come
> > from. SLAB manages memory strictly per node. So it always has to ask for
> > memory from a particular node. Hence the need to implement memory policies
> > in the allocator.
>
> You only go to the allocator when the percpu queue goes empty though, so
> if memory policy changes (eg context switch or something), then subsequent
> allocations will be of the wrong policy.

The per cpu queue size in SLUB is limited by the queues only containing
objects from the same page. If you have large queues like SLAB/SLQB(?)
then this could be an issue.

> That is what I call a hack, which is made in order to solve a percieved
> performance problem. The SLAB/SLQB method of checking policy is simple,
> obviously correct, and until there is a *demonstrated* performance problem
> with that, then I'm not going to change it.

Well so far it seems that your tests never even exercise that part of the
allocators.

> I don't think this is a problem. Anyway, rt systems that care about such
> tiny latencies can easily prioritise this. And ones that don't care so
> much have many other sources of interrupts and background processing by
> the kernel or hardware interrupts.

How do they prioritize this?

> If this actually *is* a problem, I will allow an option to turn of periodic
> trimming of queues, and allow objects to remain in queues (like the page
> allocator does with its queues). And just provide hooks to reap them at
> low memory time.

That means large amounts of memory are going to be caught in these queues.
If its per cpu and one cpu does allocation and the other frees then the
first cpu will consume more and more memory from the page allocator
whereas the second will build up huge per cpu lists.

> It's strange. You percieve these theoretical problems with things that I
> actually consider is a distinct *advantage* of SLAB/SLQB. order-0 allocations,
> queueing, strictly obeying NUMA policies...

These are issues that we encountered in practice with large systems.
Pointer chasing performance on many apps is bounded by TLB faults etc.
Strictly obeying NUMA policies causes performance problems in SLAB. Try
MPOL_INTERLEAVE vs a cpu local allocations.

> > I still dont see the problem that SLQB is addressing (aside from code
> > cleanup of SLAB). Seems that you feel that the queueing behavior of SLAB
> > is okay.
>
> It addresses O(NR_CPUS^2) memory consumption of kmem caches, and large
> constant consumption of array caches of SLAB. It addresses scalability
> eg in situations with lots of cores per node. It allows resizeable
> queues. It addresses the code complexity and bootstap hoops of SLAB.
>
> It addresses performance and higher order allocation problems of SLUB.

It seems that on SMP systems SLQB will actually increase the number of
queues since it needs 2 queues per cpu instead of the 1 of SLAB. SLAB also
has resizable queues. Code simplification and bootstrap: Great work on
that. Again good cleanup of SLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
