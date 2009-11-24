Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF01A6B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 17:23:54 -0500 (EST)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAOMLiUv019952
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 17:21:44 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAOMNpa2704610
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 17:23:51 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAOMNpGV018303
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 17:23:51 -0500
Date: Tue, 24 Nov 2009 14:23:51 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep complaints in slab allocator
Message-ID: <20091124222351.GL6831@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx> <1259095580.4531.1788.camel@laptop> <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop> <alpine.DEB.2.00.0911241302370.6593@chino.kir.corp.google.com> <1259097150.4531.1822.camel@laptop> <alpine.DEB.2.00.0911241313220.12339@chino.kir.corp.google.com> <1259098552.4531.1857.camel@laptop> <alpine.DEB.2.00.0911241336550.12339@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0911241336550.12339@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 01:46:34PM -0800, David Rientjes wrote:
> On Tue, 24 Nov 2009, Peter Zijlstra wrote:
> 
> > We should cull something, just merging more and more of them is useless
> > and wastes everybody's time since you have to add features and
> > interfaces to all of them.
> 
> I agree, but it's difficult to get widespread testing or development 
> interest in an allocator that is sitting outside of mainline.  I don't 
> think any allocator could suddenly be merged as the kernel default, it 
> seems like a prerequisite to go through the preliminary merging and 
> development.  The severe netperf TCP_RR regression that slub has compared 
> to slab was never found before it became the default allocator, otherwise 
> there would probably have been more effort into its development as well.  
> Unfortunately, slub's design is such that it will probably never be able 
> to nullify the partial slab thrashing enough, even with the percpu counter 
> speedup that is now available because of Christoph's work, to make TCP_RR 
> perform as well as slab.

OK.  I threatened this over IRC, and I never make threats that I am not
prepared to carry out.

I therefore propose creating a staging area for memory allocators,
similar to the one for device drivers.  Have it in place for allocators
both coming and going.

> > Then maybe we should toss SLUB? But then there's people who say SLUB is
> > better for them. Without forcing something to happen we'll be stuck with
> > multiple allocators forever.
> 
> Slub is definitely superior in diagnostics and is a much simpler design 
> than slab.  I think it would be much easier to remove slub than slab, 
> though, simply because there are no great slab performance degradations 
> compared to slub.  I think the best candidate for removal might be slob, 
> however, because it hasn't been compared to slub and usage may not be as 
> widespread as expected for such a special case allocator.

And yes, the real problem is that each allocator has its advocates.

I would actually not be all that worried about a proliferation of
allocators if they were automatically selected based on machine
configuration, expected workload, or some such.  But the fact is
that while 5% is a life-or-death matter to benchmarkers, it is of no
consequence to the typical Linux user/workload.

The concern with simpler allocators is that making them competitive
across the board with SLAB will make them just as complex as SLAB is.
As long as CONFIG_EMBEDDED remains a euphemism for "don't use me", SLOB
will not see much use or testing outside of those people who care
passionately about memory footprint.  SLQB probably doesn't make it into
mainline until either Nick gets done with his VFS scalability work or
someone else starts pushing it.  Allocator proliferation continues as
long as allocators are perceived to be easy to write.  And so on...

As for me, as long as SLAB is in the kernel and is default for some
of the machines I use for testing, I will continue reporting any bugs
I find in it.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
