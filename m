Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CA1BF6002CC
	for <linux-mm@kvack.org>; Tue, 25 May 2010 04:16:41 -0400 (EDT)
Date: Tue, 25 May 2010 18:16:35 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525081634.GE5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
 <20100525070734.GC5087@laptop>
 <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 11:03:49AM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Tue, May 25, 2010 at 10:07 AM, Nick Piggin <npiggin@suse.de> wrote:
> > There is nothing to stop incremental changes or tweaks on top of that
> > allocator, even to the point of completely changing the allocation
> > scheme. It is inevitable that with changes in workloads, SMP/NUMA, and
> > cache/memory costs and hierarchies, the best slab allocation schemes
> > will change over time.
> 
> Agreed.
> 
> On Tue, May 25, 2010 at 10:07 AM, Nick Piggin <npiggin@suse.de> wrote:
> > I think it is more important to have one allocator than trying to get
> > the absolute most perfect one for everybody. That way changes are
> > carefully and slowly reviewed and merged, with results to justify the
> > change. This way everybody is testing the same thing, and bisection will
> > work. The situation with SLUB is already a nightmare because now each
> > allocator has half the testing and half the work put into it.
> 
> I wouldn't say it's a nightmare, but yes, it could be better. From my
> point of view SLUB is the base of whatever the future will be because
> the code is much cleaner and simpler than SLAB. That's why I find
> Christoph's work on SLEB more interesting than SLQB, for example,
> because it's building on top of something that's mature and stable.

I don't think SLUB ever proved itself very well. The selling points
were some untestable handwaving about how queueing is bad and jitter
is bad, ignoring the fact that queues could be shortened and periodic
reaping disabled at runtime with SLAB style of allocator. It also
has relied heavily on higher order allocations which put great strain
on hugepage allocations and page reclaim (witness the big slowdown
in low memory conditions when tmpfs was using higher order allocations
via SLUB).


> That said, are you proposing that even without further improvements to
> SLUB, we should go ahead and, for example, remove SLAB from Kconfig
> for v2.6.36 and see if we can just delete the whole thing from, say,
> v2.6.38?

SLUB has not been able to displace SLAB for a long timedue to
performance and higher order allocation problems.

I think "clean code" is very important, but by far the hardest thing to
get right by far is the actual allocation and freeing strategies. So
it's crazy to base such a choice on code cleanliness. If that's the
deciding factor, then I can provide a patch to modernise SLAB and then
we can remove SLUB and start incremental improvements from there.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
