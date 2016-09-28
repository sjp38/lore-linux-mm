Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7F76B0293
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 07:05:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l132so36013098wmf.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 04:05:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m5si19358903wmi.65.2016.09.28.04.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 04:05:38 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8SB3arc054380
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 07:05:37 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25r7khcc39-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 07:05:36 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 28 Sep 2016 05:05:36 -0600
Date: Wed, 28 Sep 2016 04:05:30 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: page_waitqueue() considered harmful
Reply-To: paulmck@linux.vnet.ibm.com
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
 <20160927165221.GP5016@twins.programming.kicks-ass.net>
 <20160928030621.579ece3a@roar.ozlabs.ibm.com>
 <20160928070546.GT2794@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928070546.GT2794@worktop>
Message-Id: <20160928110530.GT14933@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Alan Stern <stern@rowland.harvard.edu>

On Wed, Sep 28, 2016 at 09:05:46AM +0200, Peter Zijlstra wrote:
> On Wed, Sep 28, 2016 at 03:06:21AM +1000, Nicholas Piggin wrote:
> > On Tue, 27 Sep 2016 18:52:21 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Wed, Sep 28, 2016 at 12:53:18AM +1000, Nicholas Piggin wrote:
> > > > The more interesting is the ability to avoid the barrier between fastpath
> > > > clearing a bit and testing for waiters.
> > > > 
> > > > unlock():                        lock() (slowpath):
> > > > clear_bit(PG_locked)             set_bit(PG_waiter)
> > > > test_bit(PG_waiter)              test_bit(PG_locked)

The point being that at least one of the test_bit() calls must return
true?

> > > > If this was memory ops to different words, it would require smp_mb each
> > > > side.. Being the same word, can we avoid them?   
> > > 
> > > Ah, that is the reason I put that smp_mb__after_atomic() there. You have
> > > a cute point on them being to the same word though. Need to think about
> > > that.
> > 
> > This is all assuming the store accesses are ordered, which you should get
> > if the stores to the different bits operate on the same address and size.
> > That might not be the case for some architectures, but they might not
> > require barriers for other reasons. That would call for an smp_mb variant
> > that is used for bitops on different bits but same aligned long. 

As far as I know, all architectures fully order aligned same-size
machine-sized accesses to the same location even without barriers.
In the example above, the PG_locked and PG_waiter are different bits in
the same location, correct?  (Looks that way, but the above also looks
a bit abbreviated.)

Not sure that Docuemntation/memory-barriers.txt is as clear as it
should be on this one, though.

> Since the {set,clear}_bit operations are atomic, they must be ordered
> against one another. The subsequent test_bit is a load, which, since its
> to the same variable, and a CPU must appear to preserve Program-Order,
> must come after the RmW.

But from Documentation/atomic_ops.h:

------------------------------------------------------------------------

	void set_bit(unsigned long nr, volatile unsigned long *addr);
	void clear_bit(unsigned long nr, volatile unsigned long *addr);
	void change_bit(unsigned long nr, volatile unsigned long *addr);

These routines set, clear, and change, respectively, the bit number
indicated by "nr" on the bit mask pointed to by "ADDR".

They must execute atomically, yet there are no implicit memory barrier
semantics required of these interfaces.

------------------------------------------------------------------------

So unless they operate on the same location or are accompanied by
something like the smp_mb__after_atomic() called out above, there
is no ordering.

> So I think you're right and that we can forgo the memory barriers here.
> I even think this must be true on all architectures.
> 
> Paul and Alan have a validation tool someplace, put them on Cc.

It does not yet fully handle atomics yet (but maybe Alan is ahead of
me here, in which case he won't be shy).  However, the point about
strong ordering of same-sized aligned accesses to a machine-sized
location can be made without atomics:

------------------------------------------------------------------------

C C-piggin-SB+samevar.litmus

{
	x=0;
}

P0(int *x)
{
	WRITE_ONCE(*x, 1);
	r1 = READ_ONCE(*x);
}

P1(int *x)
{
	WRITE_ONCE(*x, 2);
	r1 = READ_ONCE(*x);
}

exists
(0:r1=0 /\ 1:r1=0)

------------------------------------------------------------------------

This gets us the following, as expected:

Test C-piggin-SB+samevar Allowed
States 3
0:r1=1; 1:r1=1;
0:r1=1; 1:r1=2;
0:r1=2; 1:r1=2;
No
Witnesses
Positive: 0 Negative: 4
Condition exists (0:r1=0 /\ 1:r1=0)
Observation C-piggin-SB+samevar Never 0 4
Hash=31466d003c10c07836583f5879824502

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
