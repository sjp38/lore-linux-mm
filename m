From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swap prefetch improvements
Date: Mon, 21 May 2007 23:44:26 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705121446.04191.kernel@kolivas.org> <20070521100320.GA1801@elte.hu>
In-Reply-To: <20070521100320.GA1801@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705212344.27511.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 21 May 2007 20:03, Ingo Molnar wrote:
> * Con Kolivas <kernel@kolivas.org> wrote:
> > It turns out that fixing swap prefetch was not that hard to fix and
> > improve upon, and since Andrew hasn't dropped swap prefetch, instead
> > here are a swag of fixes and improvements, [...]
>
> it's a reliable win on my testbox too:
>
>  # echo 1 > /proc/sys/vm/swap_prefetch

>  Timed portion 30279 milliseconds
>
> versus:
>
>  # echo 0 > /proc/sys/vm/swap_prefetch
>  # ./sp_tester
>  [...]
>
>  Timed portion 36605 milliseconds
>
> i've repeated these tests to make sure it's a stable win and indeed it
> is:
>
>    # swap-prefetch-on:
>
>    Timed portion 29704 milliseconds
>
>    # swap-prefetch-off:
>
>    Timed portion 34863 milliseconds
>
> Nice work Con!

Thanks!

>
> A suggestion for improvement: right now swap-prefetch does a small bit
> of swapin every 5 seconds and stays idle inbetween. Could this perhaps
> be made more agressive (optionally perhaps), if the system is not
> swapping otherwise? If block-IO level instrumentation is needed to
> determine idleness of block IO then that is justified too i think.

Hmm.. The timer waits 5 seconds before trying to prefetch, but then only stops 
if it detects any activity elsewhere. It doesn't actually try to go idle in 
between but it doesn't take much activity to put it back to sleep, hence 
detecting yet another "not quite idle" period and then it goes to sleep 
again. I guess the sleep interval can actually be changed as another tunable 
from 5 seconds to whatever the user wanted.

> Another suggestion: swap-prefetch seems to be doing all the right
> decisions in the sp_test.c case - so would it be possible to add
> statistics so that it could be verified how much of the swapped-in pages
> were indeed a 'hit' - and how many were recycled without them being
> reused? That could give a reliable, objective metric about how efficient
> swap-prefetch is in any workload.

Well the advantage is twofold potentially; 1. the pages that have been 
prefecthed and become minor faults when they would have been major faults, 
and 2. those that become minor faults (via 1) and then become major faults 
again (since a copy is kept on backing store with swap prefetch). The 
sp_tester only tests for 1, although it would be easy enough to simply do 
another big malloc at the end and see how fast it swapped out again as a 
marker of 2. As for an in-kernel option, it could get kind of expensive 
tracking pages that have done one or both of these. I'll think about an 
affordable way to do this, perhaps it could be just done as a 
debugging/testing patch, but if would be nice to make it cheap enough to have 
there permanently as well. The pages end up in swap cache (in the reverse 
direction pages normally get to swap cache) so the accounting could be done 
somewhere around there.

> 	Ingo

Thanks for comments!

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
