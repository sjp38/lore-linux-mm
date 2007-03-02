Date: Fri, 2 Mar 2007 11:03:58 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070302184529.GA8761@linux.intel.com>
Message-ID: <Pine.LNX.4.64.0703021051580.3953@woody.linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
 <45E7835A.8000908@in.ibm.com> <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
 <20070301195943.8ceb221a.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
 <20070302162023.GA4691@linux.intel.com> <Pine.LNX.4.64.0703020903190.3953@woody.linux-foundation.org>
 <20070302184529.GA8761@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Gross <mgross@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Fri, 2 Mar 2007, Mark Gross wrote:
> 
> I think there will be more than just 2 dims per cpu socket on systems
> that care about this type of capability.

I agree. I think you'll have a nice mix of 2 and 4, although not likely a 
lot more. You want to have independent channels, and then within a channel 
you want to have as close to point-to-point as possible. 

But the reason that I think you're better off looking at a "node level" is 
that 

 (a) describing the DIMM setup is a total disaster. The interleaving is 
     part of it, but even in the absense of interleaving, we have so far 
     seen that describing DIMM mapping simply isn't a realistic thing to 
     be widely deplyed, judging by the fact that we cannot even get a 
     first-order approximate mapping for the ECC error events.

     Going node-level means that we just piggy-back on the existing node 
     mapping, which is a lot more likely to actually be correct and 
     available (ie you may not know which bank is bank0 and how the 
     interleaving works, but you usually *do* know which bank is connected 
     to which CPU package)

     (Btw, I shouldn't have used the word "die", since it's really about 
     package - Intel obviously has a penchant for putting two dies per 
     package)

 (b) especially if you can actually shut down the memory, going node-wide 
     may mean that you can shut down the CPU's too (ie per-package sleep). 
     I bet the people who care enough to care about DIMM's would want to 
     have that *anyway*, so tying them together simplifies the problem.

> BTW I hope we aren't talking past each other, there are low power states
> where the ram contents are persevered.

Yes. They are almost as hard to handle, but the advantage is that if we 
get things wrong, it can still work most of the time (ie we don't have to 
migrate everything off, we just need to try to migrate the stuff that gets 
*used* off a DIMM, and hardware will hopefully end up quiescing the right 
memory controller channel totally automatically, without us having to know 
the exact mapping or even having to 100% always get it 100% right).

With FBDIMM in particular, I guess the biggest power cost isn't actually 
the DRAM content, but just the controllers.

Of course, I wonder how much actual point there is to FBDIMM's once you 
have on-die memory controllers and thus the reason for deep queueing is 
basically gone (since you'd spread out the memory rather than having it 
behind a few central controllers).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
