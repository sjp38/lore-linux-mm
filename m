Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 265FA6B026B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 21:31:41 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id bv10so113897687pad.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:31:41 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id mj3si11399194pab.160.2016.09.28.18.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 18:31:40 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id s13so22971102pfd.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:31:40 -0700 (PDT)
Date: Thu, 29 Sep 2016 11:31:32 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929113132.5a85b887@roar.ozlabs.ibm.com>
In-Reply-To: <20160928070546.GT2794@worktop>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
	<20160927083104.GC2838@techsingularity.net>
	<20160928005318.2f474a70@roar.ozlabs.ibm.com>
	<20160927165221.GP5016@twins.programming.kicks-ass.net>
	<20160928030621.579ece3a@roar.ozlabs.ibm.com>
	<20160928070546.GT2794@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Alan Stern <stern@rowland.harvard.edu>

On Wed, 28 Sep 2016 09:05:46 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

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
> > > > 
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
> 
> Since the {set,clear}_bit operations are atomic, they must be ordered
> against one another. The subsequent test_bit is a load, which, since its
> to the same variable, and a CPU must appear to preserve Program-Order,
> must come after the RmW.
> 
> So I think you're right and that we can forgo the memory barriers here.
> I even think this must be true on all architectures.

In generic code, I don't think so. We'd need an
smp_mb__between_bitops_to_the_same_aligned_long, wouldn't we?

x86 implements set_bit as 'orb (addr),bit_nr', and compiler could
implement test_bit as a byte load as well. If those bits are in
different bytes, then they could be reordered, no?

ia64 does 32-bit ops. If you make PG_waiter 64-bit only and put it
in the different side of the long, then this could be a problem too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
