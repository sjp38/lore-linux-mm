Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCA6A280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:42:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 2so73057115pfs.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:42:39 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id a16si12818521pfc.204.2016.09.28.23.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 23:42:38 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id q2so25701156pfj.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:42:38 -0700 (PDT)
Date: Thu, 29 Sep 2016 16:42:31 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929164231.166d2910@roar.ozlabs.ibm.com>
In-Reply-To: <20160929062132.GG3318@worktop.controleur.wifipass.org>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
	<20160927083104.GC2838@techsingularity.net>
	<20160928005318.2f474a70@roar.ozlabs.ibm.com>
	<20160927165221.GP5016@twins.programming.kicks-ass.net>
	<20160928030621.579ece3a@roar.ozlabs.ibm.com>
	<20160928070546.GT2794@worktop>
	<20160929113132.5a85b887@roar.ozlabs.ibm.com>
	<20160929062132.GG3318@worktop.controleur.wifipass.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Alan Stern <stern@rowland.harvard.edu>

On Thu, 29 Sep 2016 08:21:32 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 29, 2016 at 11:31:32AM +1000, Nicholas Piggin wrote:
> > > Since the {set,clear}_bit operations are atomic, they must be ordered
> > > against one another. The subsequent test_bit is a load, which, since its
> > > to the same variable, and a CPU must appear to preserve Program-Order,
> > > must come after the RmW.
> > > 
> > > So I think you're right and that we can forgo the memory barriers here.
> > > I even think this must be true on all architectures.  
> > 
> > In generic code, I don't think so. We'd need an
> > smp_mb__between_bitops_to_the_same_aligned_long, wouldn't we?
> > 
> > x86 implements set_bit as 'orb (addr),bit_nr', and compiler could
> > implement test_bit as a byte load as well. If those bits are in
> > different bytes, then they could be reordered, no?
> > 
> > ia64 does 32-bit ops. If you make PG_waiter 64-bit only and put it
> > in the different side of the long, then this could be a problem too.  
> 
> Not on ia64, its atomics are full barriers too, just like x86 (even
> though its docs imply otherwise). But I get the point.

Oh yes of course I knew x86 atomics were barriers :)

Take Alpha instead. It's using 32-bit ops.

> I would however rather audit and attempt to fix affected archs before
> introducing such a barrier if at all possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
