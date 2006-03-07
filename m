Message-ID: <440CEA34.1090205@yahoo.com.au>
Date: Tue, 07 Mar 2006 13:04:36 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] avoid atomic op on page free
References: <20060307001015.GG32565@linux.intel.com> <20060306165039.1c3b66d8.akpm@osdl.org> <20060307011107.GI32565@linux.intel.com>
In-Reply-To: <20060307011107.GI32565@linux.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@linux.intel.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:

>On Mon, Mar 06, 2006 at 04:50:39PM -0800, Andrew Morton wrote:
>
>>Am a bit surprised at those numbers.
>>
>
>>Because userspace has to do peculiar things to get its pages taken off the
>>LRU.  What exactly was that application doing?
>>
>
>It's just a simple send() and recv() pair of processes.  Networking uses 
>pages for the buffer on user transmits.  Those pages tend to be freed 
>in irq context on transmit or in the receiver if the traffic is local.
>
>
>>The patch adds slight overhead to the common case while providing
>>improvement to what I suspect is a very uncommon case?
>>
>
>At least on any modern CPU with branch prediction, the test is essentially 
>free (2 memory reads that pipeline well, iow 1 cycle, maybe 2).  The 
>upside is that you get to avoid the atomic (~17 cycles on a P4 with a 
>simple test program, the penalty doubles if there is one other instruction 
>that operates on memory in the loop), disabling interrupts (~20 cycles?, I 
>don't remember) another atomic for the spinlock, another atomic for 
>TestClearPageLRU() and the pushf/popf (expensive as they rely on whatever 
>instruction that might still be in flight to complete and add the penalty 
>for changing irq state).  That's at least 70 cycles without including the 
>memory barrier side effects which can cost 100 cycles+.  Add in the costs 
>for the cacheline bouncing of the lru_lock and we're talking *expensive*.
>
>

My patches in -mm avoid the lru_lock and disabling/enabling interrupts
if the page is not on lru too, btw.

>So, a 1-2 cycle cost for a case that normally takes from 17 to 100+ cycles?  
>I think that's worth it given the benefits.
>
>Also, I think the common case (page cache read / map) is something that 
>should be done differently, as those atomics really do add up to major 
>pain.  Using rcu for page cache reads would be truely wonderful, but that 
>will take some time.
>
>

It is not very difficult to implement (and is something I intend to look
at after I finish my lockless pagecache). But it has quite a lot of 
problems,
including a potentially big (temporal) increase of cache footprint to 
process
the pages, more CPU time in general to traverse the lists, increased over /
underflows in the per cpu pagelists. Possibly even worse would be the 
increased
overhead on the RCU infrastructure and potential OOM conditions.

Not to mention the extra logic involved to either retry, or fall back to 
get/put
in the case that the userspace target page is not resident.

I'd say it will turn out to be more trouble than its worth, for the 
miserly cost
avoiding one atomic_inc, and one atomic_dec_and_test on page-local data 
that will
be in L1 cache. I'd never turn my nose up at anyone just having a go 
though :)

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
