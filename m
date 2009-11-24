Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4B95B6B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 14:23:51 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1259086459.4531.1752.camel@laptop>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi>
	 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop>
	 <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi>
	 <1259080406.4531.1645.camel@laptop>
	 <20091124170032.GC6831@linux.vnet.ibm.com>
	 <1259082756.17871.607.camel@calx>  <1259086459.4531.1752.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 Nov 2009 13:23:35 -0600
Message-ID: <1259090615.17871.696.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-24 at 19:14 +0100, Peter Zijlstra wrote:
> On Tue, 2009-11-24 at 11:12 -0600, Matt Mackall wrote:
> > On Tue, 2009-11-24 at 09:00 -0800, Paul E. McKenney wrote:
> > > On Tue, Nov 24, 2009 at 05:33:26PM +0100, Peter Zijlstra wrote:
> > > > On Mon, 2009-11-23 at 21:13 +0200, Pekka Enberg wrote:
> > > > > Matt Mackall wrote:
> > > > > > This seems like a lot of work to paper over a lockdep false positive in
> > > > > > code that should be firmly in the maintenance end of its lifecycle? I'd
> > > > > > rather the fix or papering over happen in lockdep.
> > > > > 
> > > > > True that. Is __raw_spin_lock() out of question, Peter?-) Passing the 
> > > > > state is pretty invasive because of the kmem_cache_free() call in 
> > > > > slab_destroy(). We re-enter the slab allocator from the outer edges 
> > > > > which makes spin_lock_nested() very inconvenient.
> > > > 
> > > > I'm perfectly fine with letting the thing be as it is, its apparently
> > > > not something that triggers very often, and since slab will be killed
> > > > off soon, who cares.
> > > 
> > > Which of the alternatives to slab should I be testing with, then?
> > 
> > I'm guessing your system is in the minority that has more than $10 worth
> > of RAM, which means you should probably be evaluating SLUB.
> 
> Well, I was rather hoping that'd die too ;-)
> 
> Weren't we going to go with SLQB?

News to me. Perhaps it was discussed at KS.

My understanding of the current state of play is:

SLUB: default allocator
SLAB: deep maintenance, will be removed if SLUB ever covers remaining
performance regressions
SLOB: useful for low-end (but high-volume!) embedded 
SLQB: sitting in slab.git#for-next for months, has some ground to cover

SLQB and SLUB have pretty similar target audiences, so I agree we should
eventually have only one of them. But I strongly expect performance
results to be mixed, just as they have been comparing SLUB/SLAB.
Similarly, SLQB still has of room for tuning left compared to SLUB, as
SLUB did compared to SLAB when it first emerged. It might be a while
before a clear winner emerges.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
