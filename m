Date: Fri, 2 Mar 2007 10:45:29 -0800
From: Mark Gross <mgross@linux.intel.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302184529.GA8761@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E7835A.8000908@in.ibm.com> <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org> <20070301195943.8ceb221a.akpm@linux-foundation.org> <Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org> <20070302162023.GA4691@linux.intel.com> <Pine.LNX.4.64.0703020903190.3953@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703020903190.3953@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 02, 2007 at 09:16:17AM -0800, Linus Torvalds wrote:
> 
> 
> On Fri, 2 Mar 2007, Mark Gross wrote:
> > > 
> > > Yes, the same issues exist for other DRAM forms too, but to a *much* 
> > > smaller degree.
> > 
> > DDR3-1333 may be better than FBDIMM's but don't count on it being much
> > better.
> 
> Hey, fair enough. But it's not a problem (and it doesn't have a solution) 
> today. I'm not sure it's going to have a solution tomorrow either.
> 
> > > Also, IN PRACTICE you're never ever going to see this anyway. Almost 
> > > everybody wants bank interleaving, because it's a huge performance win on 
> > > many loads. That, in turn, means that your memory will be spread out over 
> > > multiple DIMM's even for a single page, much less any bigger area.
> > 
> > 4-way interleave across banks on systems may not be as common as you may
> > think for future chip sets.  2-way interleave across DIMMs within a bank
> > will stay.
> 
> .. and think about a realistic future.
> 
> EVERYBODY will do on-die memory controllers. Yes, Intel doesn't do it 
> today, but in the one- to two-year timeframe even Intel will.

True.

> 
> What does that mean? It means that in bigger systems, you will no longer 
> even *have* 8 or 16 banks where turning off a few banks makes sense. 
> You'll quite often have just a few DIMM's per die, because that's what you 
> want for latency. Then you'll have CSI or HT or another interconnect.
> 
> And with a few DIMM's per die, you're back where even just 2-way 
> interleaving basically means that in order to turn off your DIMM, you 
> probably need to remove HALF the memory for that CPU.

I think there will be more than just 2 dims per cpu socket on systems
that care about this type of capability.

> 
> In other words: TURNING OFF DIMM's IS A BEDTIME STORY FOR DIMWITTED 
> CHILDREN.


Its very true that taking advantage of the first incarnations of this
type of thing will be limited to specific workloads you personally don't
care about, but its got applications and customers.

BTW I hope we aren't talking past each other, there are low power states
where the ram contents are persevered.

> 
> There are maybe a couple machines IN EXISTENCE TODAY that can do it. But 
> nobody actually does it in practice, and nobody even knows if it's going 
> to be viable (yes, DRAM takes energy, but trying to keep memory free will 
> likely waste power *too*, and I doubt anybody has any real idea of how 
> much any of this would actually help in practice).
> 
> And I don't think that will change. See above. The future is *not* moving 
> towards more and more DIMMS. Quite the reverse. On workstations, we are 
> currently in the "one or two DIMM's per die". Do you really think that 
> will change? Hell no. And in big servers, pretty much everybody agrees 
> that we will move towards that, rather than away from it.
> 
> So:
>  - forget about turning DIMM's off. There is *no* actual data supporting 
>    the notion that it's a good idea today, and I seriously doubt you can 
>    really argue that it will be a good idea in five or ten years. It's a 
>    hardware hack for a hardware problem, and the problems are way too 
>    complex for us to solve in time for the solution to be relevant.
> 
>  - aim for NUMA memory allocation and turning off whole *nodes*. That's 
>    much more likely to be productive in the longer timeframe. And yes, we 
>    may well want to do memory compaction for that too, but I suspect that 
>    the issues are going to be different (ie the way to do it is to simply 
>    prefer certain nodes for certain allocations, and then try to keep the 
>    jobs that you know can be idle on other nodes)

We doing the NUMA approach.  

> 
> Do you actually have real data supporting the notion that turning DIMM's 
> off will be reasonable and worthwhile? 
> 

Yes we have data from our internal and external customers showing that
this stuff is worthwhile for specific workload that some people care
about.  However; you need to understand that its by definition marketing data.

--mgross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
