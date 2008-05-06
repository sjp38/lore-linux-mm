Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m46E3lFD030879
	for <linux-mm@kvack.org>; Tue, 6 May 2008 10:03:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m46E6VTs190578
	for <linux-mm@kvack.org>; Tue, 6 May 2008 08:06:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m46E6UhV022868
	for <linux-mm@kvack.org>; Tue, 6 May 2008 08:06:30 -0600
Date: Tue, 6 May 2008 07:06:29 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 1/2] read_barrier_depends fixlets
Message-ID: <20080506140629.GE9443@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20080505112021.GC5018@wotan.suse.de> <20080505142746.GC14809@linux.vnet.ibm.com> <20080506090156.GC10141@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080506090156.GC10141@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 11:01:56AM +0200, Nick Piggin wrote:
> On Mon, May 05, 2008 at 07:27:46AM -0700, Paul E. McKenney wrote:
> > On Mon, May 05, 2008 at 01:20:21PM +0200, Nick Piggin wrote:
> > > While considering the impact of read_barrier_depends, it occurred to
> > > me that it should really be really a noop for the compiler. At least, it is
> > > better to have every arch the same than to have a few that are slightly
> > > different. (Does this mean SMP Alpha's read_barrier_depends could drop the
> > > "memory" clobber too?)
> > 
> > SMP Alpha's read_barrier_depends() needs the "memory" clobber
> > because the compiler is otherwise free to move code across the
> > smp_read_barrier_depends(), which would defeat its purpose.
> 
> Oh that's what does it. I was thinking of volatile, but I guess that is
> to prevent the statement from being eliminated.

Yep!!!

> > > It would be a highly unusual compiler that might try to issue a load of
> > > data1 before it loads a data2 which is data-dependant on data1.
> > 
> > A bit unusual, perhaps, but not unprecedented.  Value speculating
> > compilers, for example.
> 
> Yes very true. Actually I guess it may even not be far off if we ever
> used gcc's builtin_expect for predicting data rather than control values.
> OTOH, would it help significantly over simply prefetching and then having
> the compiler issue the (non speculative) loads in the correct order? You
> would avoid speculation and fixup code in the generated code that way.

You would still need to control the ordering in the case of failed
speculation -- so there would need to be some additional built-ins to
handle this.  Might take some time...

> > > There is the problem of the compiler trying to reload data1 _after_
> > > loading data2, and thus having a newer data1 than data2. However if the
> > > compiler is so inclined, then it could perform such a load at any point
> > > after the barrier, so the barrier itself will not guarantee correctness.
> > > 
> > > I think we've mostly hoped the compiler would not to do that.
> > 
> > Well, this does point me at one thing I missed with preemptable RCU,
> > namely all the open-coded sequences using smp_read_barrier_depends().
> > Quite embarrassing!!!  But a lot easier having you point me at it than
> > however long it would have taken me to figure it out on my own, so thank
> > you very much!!!
> 
> Heh, glad to be of help ;)

And the first couple I have looked at seem to need some help...

> > > This brings alpha and frv into line with all other architectures.
> > 
> > Assuming that we apply ACCESS_ONCE() as needed to the uses of
> > smp_read_barrier_depends():
> 
> Hmm, more on this in the next mail... (but I think it is important to
> bring other archs into line with the common case, even if the common
> case may have some issues that need sorting out).

I am not hung up on the order that the patches happen, as long as they
all happen.  ;-)

						Thanx, Paul

> > Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > 
> > > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > > 
> > > Index: linux-2.6/include/asm-alpha/barrier.h
> > > ===================================================================
> > > --- linux-2.6.orig/include/asm-alpha/barrier.h
> > > +++ linux-2.6/include/asm-alpha/barrier.h
> > > @@ -24,7 +24,7 @@ __asm__ __volatile__("mb": : :"memory")
> > >  #define smp_mb()	barrier()
> > >  #define smp_rmb()	barrier()
> > >  #define smp_wmb()	barrier()
> > > -#define smp_read_barrier_depends()	barrier()
> > > +#define smp_read_barrier_depends()	do { } while (0)
> > >  #endif
> > > 
> > >  #define set_mb(var, value) \
> > > Index: linux-2.6/include/asm-frv/system.h
> > > ===================================================================
> > > --- linux-2.6.orig/include/asm-frv/system.h
> > > +++ linux-2.6/include/asm-frv/system.h
> > > @@ -179,7 +179,7 @@ do {							\
> > >  #define mb()			asm volatile ("membar" : : :"memory")
> > >  #define rmb()			asm volatile ("membar" : : :"memory")
> > >  #define wmb()			asm volatile ("membar" : : :"memory")
> > > -#define read_barrier_depends()	barrier()
> > > +#define read_barrier_depends()	do { } while (0)
> > > 
> > >  #ifdef CONFIG_SMP
> > >  #define smp_mb()			mb()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
