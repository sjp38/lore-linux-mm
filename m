Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A89A600744
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 19:22:01 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.2.00.0911301512250.12038@chino.kir.corp.google.com>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop>
	 <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi>
	 <1259080406.4531.1645.camel@laptop>
	 <20091124170032.GC6831@linux.vnet.ibm.com>
	 <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop>
	 <1259090615.17871.696.camel@calx>
	 <84144f020911241307u14cd2cf0h614827137e42378e@mail.gmail.com>
	 <1259103315.17871.895.camel@calx>
	 <alpine.DEB.2.00.0911251356130.11347@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.0911271127130.20368@router.home>
	 <alpine.DEB.2.00.0911301512250.12038@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 30 Nov 2009 18:21:15 -0600
Message-ID: <1259626875.29740.193.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-30 at 15:14 -0800, David Rientjes wrote:
> On Fri, 27 Nov 2009, Christoph Lameter wrote:
> 
> > > > I'm afraid I have only anecdotal reports from SLOB users, and embedded
> > > > folks are notorious for lack of feedback, but I only need a few people
> > > > to tell me they're shipping 100k units/mo to be confident that SLOB is
> > > > in use in millions of devices.
> > > >
> > >
> > > It's much more popular than I had expected; do you think it would be
> > > possible to merge slob's core into another allocator or will it require
> > > seperation forever?
> > 
> > It would be possible to create a slab-common.c and isolate common handling
> > of all allocators. SLUB and SLQB share quite a lot of code and SLAB could
> > be cleaned up and made to fit into such a framework.
> > 
> 
> Right, but the user is still left with a decision of which slab allocator 
> to compile into their kernel, each with distinct advantages and 
> disadvantages that get exploited for the wide range of workloads that it 
> runs.  If slob could be merged into another allocator, it would be simple 
> to remove the distinction of it being seperate altogether, the differences 
> would depend on CONFIG_EMBEDDED instead.

No no no wrong wrong wrong. Again, SLOB is the least mergeable of the
set. It has vastly different priorities, design, and code from the rest.
Literally the only thing it has in common with the other three is the
interface.

And it's not even something that -most- of embedded devices will want to
use, so it can't be keyed off CONFIG_EMBEDDED anyway. If you've got even
16MB of memory, you probably want to use a SLAB-like allocator (ie not
SLOB). But there are -millions- of devices being shipped that don't have
that much memory, a situation that's likely to continue until you can
fit a larger Linux system entirely in a <$1 microcontroller-sized device
(probably 5 years off still).


This thread is annoying. The problem that triggered this thread is not
in SLOB/SLUB/SLQB, nor even in our bog-standard 10yo deep-maintenance
known-to-work SLAB code. The problem was a FALSE POSITIVE from lockdep
on code that PREDATES lockdep itself. There is nothing in this thread to
indicate that there is a serious problem maintaining multiple
allocators. In fact, considerably more time has been spent (as usual)
debating non-existent problems than fixing real ones.

I agree that having only one of SLAB/SLUB/SLQB would be nice, but it's
going to take a lot of heavy lifting in the form of hacking and
benchmarking to have confidence that there's a clear performance winner.
Given the multiple dimensions of performance
(scalability/throughput/latency for starters), I don't even think
there's good a priori reason to believe that a clear winner CAN exist.
SLUB may always have better latency, and SLQB may always have better
throughput. If you're NYSE, you might have different performance
priorities than if you're Google or CERN or Sony that amount to millions
of dollars. Repeatedly saying "but we should have only one allocator"
isn't going to change that.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
