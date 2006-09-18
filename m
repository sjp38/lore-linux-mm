Date: Sun, 17 Sep 2006 22:09:05 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917220905.18be27fa.akpm@osdl.org>
In-Reply-To: <20060917191101.1dfbfb1a.pj@sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915012810.81d9b0e3.akpm@osdl.org>
	<20060915203816.fd260a0b.pj@sgi.com>
	<20060915214822.1c15c2cb.akpm@osdl.org>
	<20060916043036.72d47c90.pj@sgi.com>
	<20060916081846.e77c0f89.akpm@osdl.org>
	<20060917022834.9d56468a.pj@sgi.com>
	<20060917092926.01dc0012.akpm@osdl.org>
	<20060917191101.1dfbfb1a.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Sun, 17 Sep 2006 19:11:01 -0700
Paul Jackson <pj@sgi.com> wrote:

> Andrew wrote:
> > IOW: in which operational scenarios and configurations would you view this
> > go-back-to-the-earlier-zone-if-some-memory-came-free-in-it approach
> > to be needed?
> 
> On fake numa systems, I agree that going back to earlier zones is
> not needed.  As you have stated, all nodes are equally good on such
> a system.
> 
> And besides, right now, I could not give you -any- operational scenario
> in which the fake numa approach would be needed.  Perhaps you have
> some in mind ...?  I'd be interested to learn how you view these fake
> numa based memory containers being used.
> 

Confused.  It's pretty obvious isn't it?  To partition the machine with
jobA taking 10% of memory, jobB using 50% and jobC the rest.  If any job
exceeds its allocation it gets subjected to page reclaim and disruption of
other jobs is minimised.

Crude, simple and, I hope, effective.

The beauty of this is that it 100% leverages the existing page reclaim
code.  All the other containerisation approaches I've seen thus far are a
house of horrors in that area.

> 
> On real numa systems, if we don't go back to earlier zones fairly
> soon after it is possible to do so, then we are significantly changing
> the memory placement behaviour of the system.  That can be risky and is
> better not done without good motivation.
> 
> If some app running for a while on one cpu, allowed to use memory
> on several nodes, had its allocations temporarilly pushed off its
> local node, further down its zonelist, it might expect to have its
> allocations go back to its local node, just by freeing up memory there.
> 
> Many of our most important HPC (High Performance Computing) apps rely
> on what they call 'first touch' placement.  That means to them that
> memory will be allocated on the node associated with the allocating
> thread, or on the closest node thereto.  They will run massive jobs,
> with sometimes just a few of the many threads in the job allocating
> massive amounts of memory, by the simple expedient of controlling
> on which cpu the allocator thread is running as it allocates by
> touching the memory pages for the first time.
> 
> Their performance can depend critically on getting that memory
> placement correct, so that the computational threads are, on average,
> as close as can be to their data.
> 
> This is the sort of memory placement change that has a decent chance
> of coming back around and biting me in the backside, a year or two
> down the road, when some app that happened, perhaps unwittingly,
> to be sensitive to this change, tripped over it.
> 
> I am certainly not saying for sure such a problem would arise.
> Good programming practices would suggest not relying on such node
> overflow to get memory placed.  But good programming practices are
> not always perfectly followed.
> 

Yeah, I can certainly sympathise with that concern.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
