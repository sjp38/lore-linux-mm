Date: Mon, 6 Mar 2006 17:11:07 -0800
From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: Re: [PATCH] avoid atomic op on page free
Message-ID: <20060307011107.GI32565@linux.intel.com>
References: <20060307001015.GG32565@linux.intel.com> <20060306165039.1c3b66d8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060306165039.1c3b66d8.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 06, 2006 at 04:50:39PM -0800, Andrew Morton wrote:
> Am a bit surprised at those numbers.

> Because userspace has to do peculiar things to get its pages taken off the
> LRU.  What exactly was that application doing?

It's just a simple send() and recv() pair of processes.  Networking uses 
pages for the buffer on user transmits.  Those pages tend to be freed 
in irq context on transmit or in the receiver if the traffic is local.

> The patch adds slight overhead to the common case while providing
> improvement to what I suspect is a very uncommon case?

At least on any modern CPU with branch prediction, the test is essentially 
free (2 memory reads that pipeline well, iow 1 cycle, maybe 2).  The 
upside is that you get to avoid the atomic (~17 cycles on a P4 with a 
simple test program, the penalty doubles if there is one other instruction 
that operates on memory in the loop), disabling interrupts (~20 cycles?, I 
don't remember) another atomic for the spinlock, another atomic for 
TestClearPageLRU() and the pushf/popf (expensive as they rely on whatever 
instruction that might still be in flight to complete and add the penalty 
for changing irq state).  That's at least 70 cycles without including the 
memory barrier side effects which can cost 100 cycles+.  Add in the costs 
for the cacheline bouncing of the lru_lock and we're talking *expensive*.

So, a 1-2 cycle cost for a case that normally takes from 17 to 100+ cycles?  
I think that's worth it given the benefits.

Also, I think the common case (page cache read / map) is something that 
should be done differently, as those atomics really do add up to major 
pain.  Using rcu for page cache reads would be truely wonderful, but that 
will take some time.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
