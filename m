Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id D70AC28024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:06:29 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id cg13so34876586pac.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:06:29 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id p64si3477288pfg.111.2016.09.27.10.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 10:06:29 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id 6so980858pfl.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:06:28 -0700 (PDT)
Date: Wed, 28 Sep 2016 03:06:21 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160928030621.579ece3a@roar.ozlabs.ibm.com>
In-Reply-To: <20160927165221.GP5016@twins.programming.kicks-ass.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
	<20160927083104.GC2838@techsingularity.net>
	<20160928005318.2f474a70@roar.ozlabs.ibm.com>
	<20160927165221.GP5016@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>

On Tue, 27 Sep 2016 18:52:21 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Wed, Sep 28, 2016 at 12:53:18AM +1000, Nicholas Piggin wrote:
> > The more interesting is the ability to avoid the barrier between fastpath
> > clearing a bit and testing for waiters.
> > 
> > unlock():                        lock() (slowpath):
> > clear_bit(PG_locked)             set_bit(PG_waiter)
> > test_bit(PG_waiter)              test_bit(PG_locked)
> > 
> > If this was memory ops to different words, it would require smp_mb each
> > side.. Being the same word, can we avoid them?   
> 
> Ah, that is the reason I put that smp_mb__after_atomic() there. You have
> a cute point on them being to the same word though. Need to think about
> that.

This is all assuming the store accesses are ordered, which you should get
if the stores to the different bits operate on the same address and size.
That might not be the case for some architectures, but they might not
require barriers for other reasons. That would call for an smp_mb variant
that is used for bitops on different bits but same aligned long. 

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
