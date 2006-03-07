Message-ID: <440D0755.5010902@yahoo.com.au>
Date: Tue, 07 Mar 2006 15:08:53 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] avoid atomic op on page free
References: <20060307001015.GG32565@linux.intel.com> <20060306165039.1c3b66d8.akpm@osdl.org> <20060307011107.GI32565@linux.intel.com> <440CEA34.1090205@yahoo.com.au> <20060307021002.GL32565@linux.intel.com>
In-Reply-To: <20060307021002.GL32565@linux.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@linux.intel.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> On Tue, Mar 07, 2006 at 01:04:36PM +1100, Nick Piggin wrote:
> 
>>I'd say it will turn out to be more trouble than its worth, for the 
>>miserly cost
>>avoiding one atomic_inc, and one atomic_dec_and_test on page-local data 
>>that will
>>be in L1 cache. I'd never turn my nose up at anyone just having a go 
>>though :)
> 
> 
> The cost is anything but miserly.  Consider that every lock instruction is 
> a memory barrier which takes your OoO CPU with lots of instructions in flight 
> to ramp down to just 1 for the time it takes that instruction to execute.  
> That synchronization is what makes the atomic expensive.
> 

Yeah x86(-64) is a _little_ worse off in that regard because its locks
imply rmbs.

But I'm saying the cost is miserly compared to the likely overheads
of using RCU-ed page freeing, when taken as impact on the system as a
whole.

Though definitely if we can get rid of atomic ops for free in any low
level page handling functions in mm/ then we want to do that.

> In the case of netperf, I ended up with a 2.5Gbit/s (~30%) performance 
> improvement through nothing but microoptimizations.  There is method to 
> my madness. ;-)
> 

Well... it was wrong too ;)

But as you can see, I'm not against microoptimisations either and I'm
glad others, like yourself, are looking at the problem too.

The 30% number is very impressive. I'd be interested to see what the
stuff currently in -mm is worth.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
