Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 300396B026F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 03:06:16 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j28so93978738iod.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 00:06:16 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id w184si8475527iod.17.2016.09.28.00.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 00:05:53 -0700 (PDT)
Date: Wed, 28 Sep 2016 09:05:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160928070546.GT2794@worktop>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
 <20160927165221.GP5016@twins.programming.kicks-ass.net>
 <20160928030621.579ece3a@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928030621.579ece3a@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Alan Stern <stern@rowland.harvard.edu>

On Wed, Sep 28, 2016 at 03:06:21AM +1000, Nicholas Piggin wrote:
> On Tue, 27 Sep 2016 18:52:21 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Wed, Sep 28, 2016 at 12:53:18AM +1000, Nicholas Piggin wrote:
> > > The more interesting is the ability to avoid the barrier between fastpath
> > > clearing a bit and testing for waiters.
> > > 
> > > unlock():                        lock() (slowpath):
> > > clear_bit(PG_locked)             set_bit(PG_waiter)
> > > test_bit(PG_waiter)              test_bit(PG_locked)
> > > 
> > > If this was memory ops to different words, it would require smp_mb each
> > > side.. Being the same word, can we avoid them?   
> > 
> > Ah, that is the reason I put that smp_mb__after_atomic() there. You have
> > a cute point on them being to the same word though. Need to think about
> > that.
> 
> This is all assuming the store accesses are ordered, which you should get
> if the stores to the different bits operate on the same address and size.
> That might not be the case for some architectures, but they might not
> require barriers for other reasons. That would call for an smp_mb variant
> that is used for bitops on different bits but same aligned long. 

Since the {set,clear}_bit operations are atomic, they must be ordered
against one another. The subsequent test_bit is a load, which, since its
to the same variable, and a CPU must appear to preserve Program-Order,
must come after the RmW.

So I think you're right and that we can forgo the memory barriers here.
I even think this must be true on all architectures.

Paul and Alan have a validation tool someplace, put them on Cc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
