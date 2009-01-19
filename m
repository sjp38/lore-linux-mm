Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 174FB6B00A9
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 01:19:01 -0500 (EST)
Date: Mon, 19 Jan 2009 07:18:56 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090119061856.GB22584@wotan.suse.de>
References: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com> <20090114150900.GC25401@wotan.suse.de> <20090114152207.GD25401@wotan.suse.de> <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com> <20090114155923.GC1616@wotan.suse.de> <Pine.LNX.4.64.0901141219140.26507@quilx.com> <20090115061931.GC17810@wotan.suse.de> <Pine.LNX.4.64.0901151434150.28387@quilx.com> <20090116034356.GM17810@wotan.suse.de> <Pine.LNX.4.64.0901161509160.27283@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901161509160.27283@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 16, 2009 at 03:25:05PM -0600, Christoph Lameter wrote:
> On Fri, 16 Jan 2009, Nick Piggin wrote:
> 
> > > The application that is interrupted has no control over when SLQB runs its
> > > expiration. The longer the queues the longer the holdoff. Look at the
> > > changelogs for various queue expiration things in the kernel. I fixed up a
> > > couple of those over the years for latency reasons.
> >
> > Interrupts and timers etc. as well as preemption by kernel threads happen
> > everywhere in the kernel. I have not seen any reason why slab queue reaping
> > in particular is a problem.
> 
> The slab queues are a particular problem since they are combined with
> timers. So the latency insensitive phase of an HPC app completes and then
> the latency critical part starts to run. SLAB will happily every 2 seconds
> expire a certain amount of objects from all its various queues.

Didn't you just earlier say that HPC apps will do all their memory
allocations up front before the critical part of the run? Anyway,
I have not seen any particular problem of cache reaping every 2 seconds
that would be worse than hardware interrupts or other timers.

But as I said, if I do see evidence of that, I will tweak the queue
reaping. But I prefer to keep it simple and closer to SLAB behaviour
until that time.


> > Any slab allocator is going to have a whole lot of theoretical problems and
> > you simply won't be able to fix them all because some require an oracle or
> > others fundamentally conflict with another theoretical problem.
> 
> I agree there is no point in working on theoretical problems. We are
> talking about practical problems.

You are not saying what the practical problem is, though. Ie. what
exactly is the workload where cache reaping is causing a problem and
what are the results of eliminating that reaping?


> > I concentrate on the main practical problems and the end result. If I see
> > evidence of some problem caused, then I will do my best to fix it.
> 
> You concentrate on the problems that are given to you I guess...

Of course. That would include any problems SGI or you would give me, I would
try to fix them. But I not only concentrate on those, but also ones that
I seek out myself. Eg. the OLTP problem.

 
> > > Well yes with enterprise app you are likely not going to see it. Run HPC
> > > and other low latency tests (Infiniband based and such).
> >
> > So do you have any results or not?
> 
> Of course. I need to repost them? I am no longer employed by the company I
> did the work for. So the test data is no longer accessible to me. You have
> to rely on the material that was posted in the past.

Just links are fine. I could find nothing concrete in the mm/slqb.c
changelogs.

 
> > > It still will have to move objects between queues? Or does it adapt the
> > > slub method of "queue" per page?
> >
> > It has several queues that objects can move between. You keep asserting
> > that this is a problem.
> 
> > > SLUB obeys memory policies. It just uses the page allocator for this by
> > > doing an allocation *without* specifying the node that memory has to come
> > > from. SLAB manages memory strictly per node. So it always has to ask for
> > > memory from a particular node. Hence the need to implement memory policies
> > > in the allocator.
> >
> > You only go to the allocator when the percpu queue goes empty though, so
> > if memory policy changes (eg context switch or something), then subsequent
> > allocations will be of the wrong policy.
> 
> The per cpu queue size in SLUB is limited by the queues only containing
> objects from the same page. If you have large queues like SLAB/SLQB(?)
> then this could be an issue.

And it could be a problem in SLUB too. Chances are that several allocations
will be wrong after every policy switch. I could describe situations in which
SLUB will allocate with the _wrong_ policy literally 100% of the time. 


> > That is what I call a hack, which is made in order to solve a percieved
> > performance problem. The SLAB/SLQB method of checking policy is simple,
> > obviously correct, and until there is a *demonstrated* performance problem
> > with that, then I'm not going to change it.
> 
> Well so far it seems that your tests never even exercise that part of the
> allocators.

It uses code and behaviour from SLAB, which I know that has been
extensively tested in enterprise distros and on just about every
serious production NUMA installation and every hardware vendor
including SGI.

That will satisfy me until somebody reports a problem. Again, I could
only find handwaving in the SLUB changelog, which I definitely have
looked at because I want to find and solve as many issues in this
subsystem as I can.


> > I don't think this is a problem. Anyway, rt systems that care about such
> > tiny latencies can easily prioritise this. And ones that don't care so
> > much have many other sources of interrupts and background processing by
> > the kernel or hardware interrupts.
> 
> How do they prioritize this?

In -rt, by prioritising interrupts. As I said, in the mainline kernel
I am skeptical that this is a problem. If it was a problem, I have
never seen a report, or an obvious simple improvmeent of moving the
reaping into a workqueue which can be prioritised, like was done with
the multi-cpu scheduler when there were problems iwth it.


> > If this actually *is* a problem, I will allow an option to turn of periodic
> > trimming of queues, and allow objects to remain in queues (like the page
> > allocator does with its queues). And just provide hooks to reap them at
> > low memory time.
> 
> That means large amounts of memory are going to be caught in these queues.
> If its per cpu and one cpu does allocation and the other frees then the
> first cpu will consume more and more memory from the page allocator
> whereas the second will build up huge per cpu lists.

Wrong. I said I would allow an option to turn off *periodic trimming*.
Or just modify the existing tunables or look at making the trimming
more fine grained etc etc. I won't know until I see a workload where it
hurts, and I will try to solve it then.


> > It's strange. You percieve these theoretical problems with things that I
> > actually consider is a distinct *advantage* of SLAB/SLQB. order-0 allocations,
> > queueing, strictly obeying NUMA policies...
> 
> These are issues that we encountered in practice with large systems.
> Pointer chasing performance on many apps is bounded by TLB faults etc.

I would be surprised if SLUB somehow fixed such apps. Especially on
large systems, if you look at the maths.

But I don't dismiss the possibility, and SLQB as I keep repeating,
can do higher order allocations. The reason I bring it up is
because SLUB will get significantly slower for many workloads if
higher order allocations *are not* done. Which is the advantage of
SLAB and SLQB here. This cannot be turned into an advantage for
SLUB because of this TLB issue.


> Strictly obeying NUMA policies causes performance problems in SLAB. Try
> MPOL_INTERLEAVE vs a cpu local allocations.

I will try testing that. Note that I have of course been testing
NUMA things on our small Altix, but I just haven't found anything
interesting enough to post...

 
> > > I still dont see the problem that SLQB is addressing (aside from code
> > > cleanup of SLAB). Seems that you feel that the queueing behavior of SLAB
> > > is okay.
> >
> > It addresses O(NR_CPUS^2) memory consumption of kmem caches, and large
> > constant consumption of array caches of SLAB. It addresses scalability
> > eg in situations with lots of cores per node. It allows resizeable
> > queues. It addresses the code complexity and bootstap hoops of SLAB.
> >
> > It addresses performance and higher order allocation problems of SLUB.
> 
> It seems that on SMP systems SLQB will actually increase the number of
> queues since it needs 2 queues per cpu instead of the 1 of SLAB.

I don't know what you mean when you say queues, but SLQB has more
than 2 queues per CPU. Great. I like them ;)


> SLAB also
> has resizable queues.

Not significantly because that would require large memory allocations for
large queues. And there is no code there to do runtime resizing.


> Code simplification and bootstrap: Great work on
> that. Again good cleanup of SLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
