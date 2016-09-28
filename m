Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C940F6B027F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 08:59:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 21so90134023pfy.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 05:59:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id xy10si8455764pac.60.2016.09.28.05.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 05:59:15 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8SCwubj120286
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 08:59:15 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25rc3mr6fd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 08:59:07 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 28 Sep 2016 06:58:35 -0600
Date: Wed, 28 Sep 2016 05:58:31 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: page_waitqueue() considered harmful
Reply-To: paulmck@linux.vnet.ibm.com
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
 <20160927165221.GP5016@twins.programming.kicks-ass.net>
 <20160928030621.579ece3a@roar.ozlabs.ibm.com>
 <20160928070546.GT2794@worktop>
 <20160928110530.GT14933@linux.vnet.ibm.com>
 <20160928111645.GT5016@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928111645.GT5016@twins.programming.kicks-ass.net>
Message-Id: <20160928125830.GX14933@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Alan Stern <stern@rowland.harvard.edu>

On Wed, Sep 28, 2016 at 01:16:45PM +0200, Peter Zijlstra wrote:
> On Wed, Sep 28, 2016 at 04:05:30AM -0700, Paul E. McKenney wrote:
> > On Wed, Sep 28, 2016 at 09:05:46AM +0200, Peter Zijlstra wrote:
> > > On Wed, Sep 28, 2016 at 03:06:21AM +1000, Nicholas Piggin wrote:
> > > > On Tue, 27 Sep 2016 18:52:21 +0200
> > > > Peter Zijlstra <peterz@infradead.org> wrote:
> > > > 
> > > > > On Wed, Sep 28, 2016 at 12:53:18AM +1000, Nicholas Piggin wrote:
> > > > > > The more interesting is the ability to avoid the barrier between fastpath
> > > > > > clearing a bit and testing for waiters.
> > > > > > 
> > > > > > unlock():                        lock() (slowpath):
> > > > > > clear_bit(PG_locked)             set_bit(PG_waiter)
> > > > > > test_bit(PG_waiter)              test_bit(PG_locked)
> > 
> > The point being that at least one of the test_bit() calls must return
> > true?
> 
> Yes, more or less. Either unlock() observes PG_waiters set, or lock()
> observes PG_locked unset. (opposed to all our 'normal' examples the
> initial state isn't all 0 and the stores aren't all 1 :-).

You lost me on unlock() doing any observation, but yes, I transliterated
to standard form, unintentionally, as it turns out.  ;-)

So the goal is that either test_bit(PG_waiter) sees the set_bit()
or test_bit(PG_locked) sees the clear_bit(), correct?

> > As far as I know, all architectures fully order aligned same-size
> > machine-sized accesses to the same location even without barriers.
> > In the example above, the PG_locked and PG_waiter are different bits in
> > the same location, correct?  (Looks that way, but the above also looks
> > a bit abbreviated.)
> 
> Correct, PG_* all live in the same word.

That should make things somewhat more reliable.  ;-)

> > So unless they operate on the same location or are accompanied by
> > something like the smp_mb__after_atomic() called out above, there
> > is no ordering.
> 
> Same word..
> 
> > > So I think you're right and that we can forgo the memory barriers here.
> > > I even think this must be true on all architectures.
> > > 
> > > Paul and Alan have a validation tool someplace, put them on Cc.
> > 
> > It does not yet fully handle atomics yet (but maybe Alan is ahead of
> > me here, in which case he won't be shy).  However, the point about
> > strong ordering of same-sized aligned accesses to a machine-sized
> > location can be made without atomics:
> 
> Great. That's what I remember from reading that stuff.

;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
