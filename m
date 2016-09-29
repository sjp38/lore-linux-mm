Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64C5F280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:22:08 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o21so18978407itb.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:22:08 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id p63si21424794itc.2.2016.09.28.23.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 23:21:44 -0700 (PDT)
Date: Thu, 29 Sep 2016 08:21:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929062132.GG3318@worktop.controleur.wifipass.org>
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
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Alan Stern <stern@rowland.harvard.edu>

On Thu, Sep 29, 2016 at 11:31:32AM +1000, Nicholas Piggin wrote:
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

Not on ia64, its atomics are full barriers too, just like x86 (even
though its docs imply otherwise). But I get the point.

I would however rather audit and attempt to fix affected archs before
introducing such a barrier if at all possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
