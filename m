Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 657246B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 06:02:53 -0500 (EST)
Date: Thu, 8 Jan 2009 03:02:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
Message-Id: <20090108030245.e7c8ceaf.akpm@linux-foundation.org>
In-Reply-To: <20090107.125133.214628094.davem@davemloft.net>
References: <20090107154517.GA5565@duck.suse.cz>
	<1231345546.11687.314.camel@twins>
	<alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
	<20090107.125133.214628094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, peterz@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 07 Jan 2009 12:51:33 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 7 Jan 2009 08:39:01 -0800 (PST)
> 
> > On Wed, 7 Jan 2009, Peter Zijlstra wrote:
> > > 
> > > >   So the question is: What kind of workloads are lower limits supposed to
> > > > help? Desktop? Has anybody reported that they actually help? I'm asking
> > > > because we are probably going to increase limits to the old values for
> > > > SLES11 if we don't see serious negative impact on other workloads...
> > > 
> > > Adding some CCs.
> > > 
> > > The idea was that 40% of the memory is a _lot_ these days, and writeback
> > > times will be huge for those hitting sync or similar. By lowering these
> > > you'd smooth that out a bit.
> > 
> > Not just a bit. If you have 4GB of RAM (not at all unusual for even just a 
> > regular desktop, never mind a "real" workstation), it's simply crazy to 
> > allow 1.5GB of dirty memory. Not unless you have a really wicked RAID 
> > system with great write performance that can push it out to disk (with 
> > seeking) in just a few seconds.
> > 
> > And few people have that.
> > 
> > For a server, where throughput matters but latency generally does not, go 
> > ahead and raise it. But please don't raise it for anything sane. The only 
> > time it makes sense upping that percentage is for some odd special-case 
> > benchmark that otherwise can fit the dirty data set in memory, and never 
> > syncs it (ie it deletes all the files after generating them).
> > 
> > In other words, yes, 40% dirty can make a big difference to benchmarks, 
> > but is almost never actually a good idea any more.
> 
> I have to say that my workstation is still helped by reverting this
> change and all I do is play around in GIT trees and read email.
> 

The kernel can't get this right - it doesn't know the usage
patterns/workloads, etc.  It's rather disappointing that distros appear
to have put so little work into finding ways of setting suitable values
for this, and for other tunables.

Maybe we should set them to 1%, or 99% or something similarly stupid to
force the issue.

yes, perhaps the kernel's default percentage should be larger on
smaller-memory systems.  And smaller on slow-disk systems.  etc.  But
initscripts already have all the information to do this, and have the
advantage that any such scripts are backportable to five-year-old kernels.

So I say leave it as-is.  If suse can come up with a scriptlet which scales
this according to memory size, disk speed, workload, etc then good for
them - it'll produce a better end result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
