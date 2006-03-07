Date: Mon, 6 Mar 2006 18:10:02 -0800
From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: Re: [PATCH] avoid atomic op on page free
Message-ID: <20060307021002.GL32565@linux.intel.com>
References: <20060307001015.GG32565@linux.intel.com> <20060306165039.1c3b66d8.akpm@osdl.org> <20060307011107.GI32565@linux.intel.com> <440CEA34.1090205@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <440CEA34.1090205@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 07, 2006 at 01:04:36PM +1100, Nick Piggin wrote:
> I'd say it will turn out to be more trouble than its worth, for the 
> miserly cost
> avoiding one atomic_inc, and one atomic_dec_and_test on page-local data 
> that will
> be in L1 cache. I'd never turn my nose up at anyone just having a go 
> though :)

The cost is anything but miserly.  Consider that every lock instruction is 
a memory barrier which takes your OoO CPU with lots of instructions in flight 
to ramp down to just 1 for the time it takes that instruction to execute.  
That synchronization is what makes the atomic expensive.

In the case of netperf, I ended up with a 2.5Gbit/s (~30%) performance 
improvement through nothing but microoptimizations.  There is method to 
my madness. ;-)

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
