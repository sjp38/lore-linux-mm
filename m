Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5877B6B026B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 22:12:18 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id bv10so115245220pad.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:12:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f4si10728992paw.146.2016.09.28.19.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 19:12:16 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T2BKWX119632
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 22:12:16 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25rj78cjsp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 22:12:15 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 28 Sep 2016 20:12:15 -0600
Date: Wed, 28 Sep 2016 19:12:11 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: page_waitqueue() considered harmful
Reply-To: paulmck@linux.vnet.ibm.com
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
 <20160927165221.GP5016@twins.programming.kicks-ass.net>
 <20160928030621.579ece3a@roar.ozlabs.ibm.com>
 <20160928070546.GT2794@worktop>
 <20160929113132.5a85b887@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929113132.5a85b887@roar.ozlabs.ibm.com>
Message-Id: <20160929021211.GJ14933@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Alan Stern <stern@rowland.harvard.edu>

On Thu, Sep 29, 2016 at 11:31:32AM +1000, Nicholas Piggin wrote:
> On Wed, 28 Sep 2016 09:05:46 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Wed, Sep 28, 2016 at 03:06:21AM +1000, Nicholas Piggin wrote:
> > > On Tue, 27 Sep 2016 18:52:21 +0200
> > > Peter Zijlstra <peterz@infradead.org> wrote:
> > >   
> > > > On Wed, Sep 28, 2016 at 12:53:18AM +1000, Nicholas Piggin wrote:  
> > > > > The more interesting is the ability to avoid the barrier between fastpath
> > > > > clearing a bit and testing for waiters.
> > > > > 
> > > > > unlock():                        lock() (slowpath):
> > > > > clear_bit(PG_locked)             set_bit(PG_waiter)
> > > > > test_bit(PG_waiter)              test_bit(PG_locked)
> > > > > 
> > > > > If this was memory ops to different words, it would require smp_mb each
> > > > > side.. Being the same word, can we avoid them?     
> > > > 
> > > > Ah, that is the reason I put that smp_mb__after_atomic() there. You have
> > > > a cute point on them being to the same word though. Need to think about
> > > > that.  
> > > 
> > > This is all assuming the store accesses are ordered, which you should get
> > > if the stores to the different bits operate on the same address and size.
> > > That might not be the case for some architectures, but they might not
> > > require barriers for other reasons. That would call for an smp_mb variant
> > > that is used for bitops on different bits but same aligned long.   
> > 
> > Since the {set,clear}_bit operations are atomic, they must be ordered
> > against one another. The subsequent test_bit is a load, which, since its
> > to the same variable, and a CPU must appear to preserve Program-Order,
> > must come after the RmW.
> > 
> > So I think you're right and that we can forgo the memory barriers here.
> > I even think this must be true on all architectures.
> 
> In generic code, I don't think so. We'd need an
> smp_mb__between_bitops_to_the_same_aligned_long, wouldn't we?
> 
> x86 implements set_bit as 'orb (addr),bit_nr', and compiler could
> implement test_bit as a byte load as well. If those bits are in
> different bytes, then they could be reordered, no?
> 
> ia64 does 32-bit ops. If you make PG_waiter 64-bit only and put it
> in the different side of the long, then this could be a problem too.

Fair point, that would defeat the same-location ordering...

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
