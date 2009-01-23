Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 763C56B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 23:09:17 -0500 (EST)
Date: Fri, 23 Jan 2009 05:09:13 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123040913.GG20098@wotan.suse.de>
References: <20090114152207.GD25401@wotan.suse.de> <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com> <20090114155923.GC1616@wotan.suse.de> <Pine.LNX.4.64.0901141219140.26507@quilx.com> <20090115061931.GC17810@wotan.suse.de> <Pine.LNX.4.64.0901151434150.28387@quilx.com> <20090116034356.GM17810@wotan.suse.de> <Pine.LNX.4.64.0901161509160.27283@quilx.com> <20090119061856.GB22584@wotan.suse.de> <alpine.DEB.1.10.0901211903540.18367@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0901211903540.18367@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 07:13:44PM -0500, Christoph Lameter wrote:
> On Mon, 19 Jan 2009, Nick Piggin wrote:
> 
> > > The per cpu queue size in SLUB is limited by the queues only containing
> > > objects from the same page. If you have large queues like SLAB/SLQB(?)
> > > then this could be an issue.
> >
> > And it could be a problem in SLUB too. Chances are that several allocations
> > will be wrong after every policy switch. I could describe situations in which
> > SLUB will allocate with the _wrong_ policy literally 100% of the time.
> 
> No it cannot because in SLUB objects must come from the same page.
> Multiple objects in a queue will only ever require a single page and not
> multiple like in SLAB.

I don't know how that solves the problem. Task with memory policy A
allocates an object, which allocates the "fast" page with policy A
and allocates an object. Then context switch to task with memory
policy B which allocates another object, which is taken from the page
allocated with policy A. Right?

(OK this doesn't give the wrong policy 100% of the time; I thought
there could have been a context switch race during page allocation
that would result in 100% incorrect, but anyway it could still be
significantly incorrect couldn't it?)

 
> > > That means large amounts of memory are going to be caught in these queues.
> > > If its per cpu and one cpu does allocation and the other frees then the
> > > first cpu will consume more and more memory from the page allocator
> > > whereas the second will build up huge per cpu lists.
> >
> > Wrong. I said I would allow an option to turn off *periodic trimming*.
> > Or just modify the existing tunables or look at making the trimming
> > more fine grained etc etc. I won't know until I see a workload where it
> > hurts, and I will try to solve it then.
> 
> You are not responding to the issue. If you have queues that contain
> objects from multiple pages then every object pointer in these queues can
> pin a page although this actually is a free object.

I am trying to respond to what you raise. "The" issue I thought you
raised above was that SLQB would grow freelists unbounded

 "the first cpu will consume more and more memory from the page allocator
  whereas the second will build up huge per cpu lists"

And this is wrong. There is another possible issue where every single
object on the freelist might come from a different (and otherwise free)
page, and thus eg 100 8 byte objects might consume 400K.

That's not an invalid concern, but I think it will be quite rare, and
the periodic queue trimming should naturally help this because it will
cycle out those objects and if new allocations are needed, they will
come from new pages which can be packed more densely.

 
> > > It seems that on SMP systems SLQB will actually increase the number of
> > > queues since it needs 2 queues per cpu instead of the 1 of SLAB.
> >
> > I don't know what you mean when you say queues, but SLQB has more
> > than 2 queues per CPU. Great. I like them ;)
> 
> This gets better and better.

So no response to my asking where the TLB improvement in SLUB helps,
or where queueing hurts? You complain about not being able to reproduce
Intel's OLTP problem, and yet you won't even _say_ what the problems
are for SLQB. Wheras Intel at least puts a lot of effort into running
tests and helping to analyse things.


> > > SLAB also
> > > has resizable queues.
> >
> > Not significantly because that would require large memory allocations for
> > large queues. And there is no code there to do runtime resizing.
> 
> Groan. Please have a look at do_tune_cpucache() in slab.c

Cool, I didn't realise it had hooks to do runtime resizing. The more
important issue of course is the one of extra cache footprint and
metadata in SLAB's scheme.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
