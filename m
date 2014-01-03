Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id D29EE6B0035
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 02:57:46 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id i8so14803734qcq.10
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 23:57:45 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id l3si57933257qac.14.2014.01.02.23.57.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 23:57:44 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 3 Jan 2014 00:57:43 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 8D3721FF001E
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 00:57:14 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s037vZn12294204
	for <linux-mm@kvack.org>; Fri, 3 Jan 2014 08:57:35 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s0380rfo016229
	for <linux-mm@kvack.org>; Fri, 3 Jan 2014 01:00:53 -0700
Date: Thu, 2 Jan 2014 23:57:27 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Memory allocator semantics
Message-ID: <20140103075727.GU19211@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <20140103033906.GB2983@leaf>
 <20140103051417.GT19211@linux.vnet.ibm.com>
 <20140103054700.GA4865@leaf>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140103054700.GA4865@leaf>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

On Thu, Jan 02, 2014 at 09:47:00PM -0800, Josh Triplett wrote:
> On Thu, Jan 02, 2014 at 09:14:17PM -0800, Paul E. McKenney wrote:
> > On Thu, Jan 02, 2014 at 07:39:07PM -0800, Josh Triplett wrote:
> > > On Thu, Jan 02, 2014 at 12:33:20PM -0800, Paul E. McKenney wrote:
> > > > Hello!
> > > > 
> > > > From what I can see, the Linux-kernel's SLAB, SLOB, and SLUB memory
> > > > allocators would deal with the following sort of race:
> > > > 
> > > > A.	CPU 0: r1 = kmalloc(...); ACCESS_ONCE(gp) = r1;
> > > > 
> > > > 	CPU 1: r2 = ACCESS_ONCE(gp); if (r2) kfree(r2);
> > > > 
> > > > However, my guess is that this should be considered an accident of the
> > > > current implementation rather than a feature.  The reason for this is
> > > > that I cannot see how you would usefully do (A) above without also allowing
> > > > (B) and (C) below, both of which look to me to be quite destructive:
> > > 
> > > (A) only seems OK if "gp" is guaranteed to be NULL beforehand, *and* if
> > > no other CPUs can possibly do what CPU 1 is doing in parallel.  Even
> > > then, it seems questionable how this could ever be used successfully in
> > > practice.
> > > 
> > > This seems similar to the TCP simultaneous-SYN case: theoretically
> > > possible, absurd in practice.
> > 
> > Heh!
> > 
> > Agreed on the absurdity, but my quick look and slab/slob/slub leads
> > me to believe that current Linux kernel would actually do something
> > sensible in this case.  But only because they don't touch the actual
> > memory.  DYNIX/ptx would have choked on it, IIRC.
> 
> Based on this and the discussion at the bottom of your mail, I think I'm
> starting to understand what you're getting at; this seems like less of a
> question of "could this usefully happen?" and more "does the allocator
> know how to protect *itself*?".

Or perhaps "What are the rules when a concurrent program interacts with
a memory allocator?"  Like the set you provided below.  ;-)

> > > > But I thought I should ask the experts.
> > > > 
> > > > So, am I correct that kernel hackers are required to avoid "drive-by"
> > > > kfree()s of kmalloc()ed memory?
> > > 
> > > Don't kfree things that are in use, and synchronize to make sure all
> > > CPUs agree about "in use", yes.
> > 
> > For example, ensure that each kmalloc() happens unambiguously before the
> > corresponding kfree().  ;-)
> 
> That too, yes. :)
> 
> > > > PS.  To the question "Why would anyone care about (A)?", then answer
> > > >      is "Inquiring programming-language memory-model designers want
> > > >      to know."
> > > 
> > > I find myself wondering about the original form of the question, since
> > > I'd hope that programming-languge memory-model designers would
> > > understand the need for synchronization around reclaiming memory.
> > 
> > I think that they do now.  The original form of the question was as
> > follows:
> > 
> > 	But my intuition at the moment is that allowing racing
> > 	accesses and providing pointer atomicity leads to a much more
> > 	complicated and harder to explain model.  You have to deal
> > 	with initialization issues and OOTA problems without atomics.
> > 	And the implementation has to deal with cross-thread visibility
> > 	of malloc meta-information, which I suspect will be expensive.
> > 	You now essentially have to be able to malloc() in one thread,
> > 	transfer the pointer via a race to another thread, and free()
> > 	in the second thread.  Thata??s hard unless malloc() and free()
> > 	always lock (as I presume they do in the Linux kernel).
> 
> As mentioned above, this makes much more sense now.  This seems like a
> question of how the allocator protects its *own* internal data
> structures, rather than whether the allocator can usefully be used for
> the cases you mentioned above.  And that's a reasonable question to ask
> if you're building a language memory model for a language with malloc
> and free as part of its standard library.
> 
> To roughly sketch out some general rules that might work as a set of
> scalable design constraints for malloc/free:
> 
> - malloc may always return any unallocated memory; it has no obligation
>   to avoid returning memory that was just recently freed.  In fact, an
>   implementation may even be particularly *likely* to return memory that
>   was just recently freed, for performance reasons.  Any program which
>   assumes a delay or a memory barrier before memory reuse is broken.

Agreed.

> - Multiple calls to free on the same memory will produce undefined
>   behavior, and in particular may result in a well-known form of
>   security hole.  free has no obligation to protect itself against
>   multiple calls to free on the same memory, unless otherwise specified
>   as part of some debugging mode.  This holds whether the calls to free
>   occur in series or in parallel (e.g. two or more calls racing with
>   each other).  It is the job of the calling program to avoid calling
>   free multiple times on the same memory, such as via reference
>   counting, RCU, or some other mechanism.

Yep!

> - It is the job of the calling program to avoid calling free on memory
>   that is currently in use, such as via reference counting, RCU, or some
>   other mechanism.  Accessing memory after reclaiming it will produce
>   undefined behavior.  This includes calling free on memory concurrently
>   with accesses to that memory (e.g. via a race).

Yep!

> - malloc and free must work correctly when concurrently called from
>   multiple threads without synchronization.  Any synchronization or
>   memory barriers required internally by the implementations must be
>   provided by the implementation.  However, an implementation is not
>   required to use any particular form of synchronization, such as
>   locking or memory barriers, and the caller of malloc or free may not
>   make any assumptions about the ordering of its own operations
>   surrounding those calls.  For example, an implementation may use
>   per-CPU memory pools, and only use synchronization when it cannot
>   satisfy an allocation request from the current CPU's pool.

Yep, though in C/C++11 this comes out something very roughly like:
"A free() involving a given byte of memory synchronizes-with a later
alloc() returning a block containing that block of memory."

> - An implementation of free must support being called on any memory
>   allocated by the same implementation of malloc, at any time, from any
>   CPU.  In particular, a call to free on memory freshly malloc'd on
>   another CPU, with no intervening synchronization between the two
>   calls, must succeed and reclaim the memory.  However, the actual calls
>   to malloc and free must not race with each other; in particular, the
>   pointer value returned by malloc is not valid (for access or for calls
>   to free) until malloc itself has returned.  (Such a race would require
>   the caller of free to divine the value returned by malloc before
>   malloc returns.)  Thus, the implementations of malloc and free may
>   safely assume a data dependency (via the returned pointer value
>   itself) between the call to malloc and the call to free; such a
>   dependency may allow further assumptions about memory ordering based
>   on the platform's memory model.

I would be OK requiring the user to have a happens-before relationship
between an allocation and a subsequent matching free.

> > But the first I heard of it was something like litmus test (A) above.
> > 
> > (And yes, I already disabused them of their notion that Linux kernel
> > kmalloc() and kfree() always lock.)
> 
> That much does seem like an easy assumption to make if you've never
> thought about how to write a scalable allocator.  The concept of per-CPU
> memory pools is the very first thing that should come to mind when
> thinking the words "scalable" and "allocator" in the same sentence, but
> first you have to get programming-language memory-model designers
> thinking the word "scalable". ;)

Well, given that it was not obvious to me the first year or so that I
was doing parallel programming, I cannot give them too much trouble.
Of course, that was some time ago.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
