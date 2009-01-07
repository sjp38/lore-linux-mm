Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 045CA6B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 11:40:00 -0500 (EST)
Date: Wed, 7 Jan 2009 08:39:01 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
In-Reply-To: <1231345546.11687.314.camel@twins>
Message-ID: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
References: <20090107154517.GA5565@duck.suse.cz> <1231345546.11687.314.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>



On Wed, 7 Jan 2009, Peter Zijlstra wrote:
> 
> >   So the question is: What kind of workloads are lower limits supposed to
> > help? Desktop? Has anybody reported that they actually help? I'm asking
> > because we are probably going to increase limits to the old values for
> > SLES11 if we don't see serious negative impact on other workloads...
> 
> Adding some CCs.
> 
> The idea was that 40% of the memory is a _lot_ these days, and writeback
> times will be huge for those hitting sync or similar. By lowering these
> you'd smooth that out a bit.

Not just a bit. If you have 4GB of RAM (not at all unusual for even just a 
regular desktop, never mind a "real" workstation), it's simply crazy to 
allow 1.5GB of dirty memory. Not unless you have a really wicked RAID 
system with great write performance that can push it out to disk (with 
seeking) in just a few seconds.

And few people have that.

For a server, where throughput matters but latency generally does not, go 
ahead and raise it. But please don't raise it for anything sane. The only 
time it makes sense upping that percentage is for some odd special-case 
benchmark that otherwise can fit the dirty data set in memory, and never 
syncs it (ie it deletes all the files after generating them).

In other words, yes, 40% dirty can make a big difference to benchmarks, 
but is almost never actually a good idea any more.

That said, the _right_ thing to do is to 

 (a) limit dirty by number of bytes (in addition to having a percentage 
     limit). Current -git adds support for that.

 (b) scale it dynamically by your IO performance. No, current -git does 
     _not_ support this.

but just upping the percentage is not a good idea.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
