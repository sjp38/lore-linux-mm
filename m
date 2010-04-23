Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2316D6B01EE
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 21:06:42 -0400 (EDT)
Date: Fri, 23 Apr 2010 11:06:32 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100423010632.GA10390@dastard>
References: <20100413202021.GZ13327@think>
 <20100414014041.GD2493@dastard>
 <20100414155233.D153.A69D9226@jp.fujitsu.com>
 <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie>
 <20100415013436.GO2493@dastard>
 <20100415102837.GB10966@csn.ul.ie>
 <20100416041412.GY2493@dastard>
 <20100416151403.GM19264@csn.ul.ie>
 <20100419152034.GW19264@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100419152034.GW19264@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 19, 2010 at 04:20:34PM +0100, Mel Gorman wrote:
> On Fri, Apr 16, 2010 at 04:14:03PM +0100, Mel Gorman wrote:
> > > > Your patch fixes 2, avoids 1, breaks 3 and haven't thought about 4 but I
> > > > guess dirty pages can cycle around more so it'd need to be cared for.
> > > 
> > > Well, you keep saying that they break #3, but I haven't seen any
> > > test cases or results showing that. I've been unable to confirm that
> > > lumpy reclaim is broken by disallowing writeback in my testing, so
> > > I'm interested to know what tests you are running that show it is
> > > broken...
> > > 
> > 
> > Ok, I haven't actually tested this. The machines I use are tied up
> > retesting the compaction patches at the moment. The reason why I reckon
> > it'll be a problem is that when these sync-writeback changes were
> > introduced, it significantly helped lumpy reclaim for huge pages. I am
> > making an assumption that backing out those changes will hurt it.
> > 
> > I'll test for real on Monday and see what falls out.
> > 
> 
> One machine has completed the test and the results are as expected. When
> allocating huge pages under stress, your patch drops the success rates
> significantly. On X86-64, it showed
> 
> STRESS-HIGHALLOC
>               stress-highalloc   stress-highalloc
>             enable-directreclaim disable-directreclaim
> Under Load 1    89.00 ( 0.00)    73.00 (-16.00)
> Under Load 2    90.00 ( 0.00)    85.00 (-5.00)
> At Rest         90.00 ( 0.00)    90.00 ( 0.00)
> 
> So with direct reclaim, it gets 89% of memory as huge pages at the first
> attempt but 73% with your patch applied. The "Under Load 2" test happens
> immediately after. With the start kernel, the first and second attempts
> are usually the same or very close together. With your patch applied,
> there are big differences as it was no longer trying to clean pages.

What was the machine config you were testing on (RAM, CPUs, etc)?
And what are these loads? Do you have a script that generates
them? If so, can you share them, please?

OOC, what was the effect on the background load - did it go faster
or slower when writeback was disabled? i.e. did we trade of more
large pages for better overall throughput?

Also, I'm curious as to the repeatability of the tests you are
doing. I found that from run to run I could see a *massive*
variance in the results. e.g. one run might only get ~80 huge
pages at the first attempt, the test run from the same initial
conditions next might get 440 huge pages at the first attempt. I saw
the same variance with or without writeback from direct reclaim
enabled. Hence only after averaging over tens of runs could I see
any sort of trend emerge, and it makes me wonder if your testing is
also seeing this sort of variance....

FWIW, if we look results of the test I did, it showed a 20%
improvement in large page allocation with a 15% increase in load
throughput, while you're showing a 16% degradation in large page
allocation.  Effectively we've got two workloads that show results
at either end of the spectrum (perhaps they are best case vs worst
case) but there's no real in-between. What other tests can we run to
get a better picture of the effect?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
