Date: Mon, 21 May 2007 12:03:20 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: swap prefetch improvements
Message-ID: <20070521100320.GA1801@elte.hu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <2c0942db0705092252n13a6a79aq39f13fcfae534de2@mail.gmail.com> <4642C416.3000205@yahoo.com.au> <200705121446.04191.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705121446.04191.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Con Kolivas <kernel@kolivas.org> wrote:

> It turns out that fixing swap prefetch was not that hard to fix and 
> improve upon, and since Andrew hasn't dropped swap prefetch, instead 
> here are a swag of fixes and improvements, [...]

it's a reliable win on my testbox too:

 # echo 1 > /proc/sys/vm/swap_prefetch
 # ./sp_tester
 Ram 1019540000  Swap 4096564000
 Total ram to be malloced: 1529310000 bytes
 Starting first malloc of 764655000 bytes
 Starting 1st read of first malloc
 Touching this much ram takes 4393 milliseconds
 Starting second malloc of 764655000 bytes
 Completed second malloc and free
 Sleeping for 600 seconds
 Important part - starting reread of first malloc
 Completed read of first malloc
 Timed portion 30279 milliseconds

versus:

 # echo 0 > /proc/sys/vm/swap_prefetch
 # ./sp_tester
 [...]

 Timed portion 36605 milliseconds

i've repeated these tests to make sure it's a stable win and indeed it 
is:

   # swap-prefetch-on:

   Timed portion 29704 milliseconds

   # swap-prefetch-off:

   Timed portion 34863 milliseconds
 
Nice work Con!

A suggestion for improvement: right now swap-prefetch does a small bit 
of swapin every 5 seconds and stays idle inbetween. Could this perhaps 
be made more agressive (optionally perhaps), if the system is not 
swapping otherwise? If block-IO level instrumentation is needed to 
determine idleness of block IO then that is justified too i think.

Another suggestion: swap-prefetch seems to be doing all the right 
decisions in the sp_test.c case - so would it be possible to add 
statistics so that it could be verified how much of the swapped-in pages 
were indeed a 'hit' - and how many were recycled without them being 
reused? That could give a reliable, objective metric about how efficient 
swap-prefetch is in any workload.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
