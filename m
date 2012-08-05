Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 615896B0073
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 20:11:03 -0400 (EDT)
Date: Sun, 5 Aug 2012 01:10:51 +0100
From: "Dr. David Alan Gilbert" <dave@treblig.org>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120805001051.GC1255@gallifrey>
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <20120804143719.GB10459@redhat.com>
 <20120804220245.GB3307@linux.vnet.ibm.com>
 <20120804224705.GD10459@redhat.com>
 <20120804225910.GB1255@gallifrey>
 <20120804231151.GK3307@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120804231151.GK3307@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

* Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> On Sat, Aug 04, 2012 at 11:59:10PM +0100, Dr. David Alan Gilbert wrote:

<snip>

> > A compiler could decide to dereference it using a non-faulting load,
> > do the calculations or whatever on the returned value of the non-faulting
> > load, and then check whether the load actually faulted, and whether the
> > address matched the prediction before it did a store based on it's
> > guess.
> 
> Or the compiler could record a recovery address in a per-thread variable
> before doing the speculative reference.  The page-fault handler could
> consult the per-thread variable and take appropriate action.

The difference is that I'd expect a compiler writer to think that
they've got a free hand in terms of instruction usage that the OS/library
doesn't see - if it's in the instruction manual and it's marked as user
space and non-faulting I'd say it's fair game; once they know that they're
going to take a fault or mark pages specially then they already know they're
going to have to cooperate with the OS, or worry about what other
normal library calls are going to do.
(A bit of googling seems to suggest IA64 and SPARC have played around
with non-faulting load optimisations, but I can't tell how much.)

> But both this approach and your approach are vulnerable to things like
> having the speculation area mapped to (say) MMIO space.  Not good!

Not good for someone doing MMIO, but from an evil-compiler point
of view, they might well assume that a pointer is to memory
unless someone has made an effort to tell them otherwise (not that
there is a good standard to do that).

> So I am with Andrea on this one -- there would need to be some handshake
> between kernel and compiler to avoid messing with possibly-unsafe
> mappings.  And I am still not much in favor of value speculation.  ;-)

Dave
-- 
 -----Open up your eyes, open up your mind, open up your code -------   
/ Dr. David Alan Gilbert    |       Running GNU/Linux       | Happy  \ 
\ gro.gilbert @ treblig.org |                               | In Hex /
 \ _________________________|_____ http://www.treblig.org   |_______/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
