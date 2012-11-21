Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 121CB6B0078
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:02:08 -0500 (EST)
Date: Wed, 21 Nov 2012 18:02:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/46] Automatic NUMA Balancing V4
Message-ID: <20121121180200.GK8218@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <20121121165342.GH8218@suse.de>
 <20121121170306.GA28811@gmail.com>
 <20121121172011.GI8218@suse.de>
 <20121121173316.GA29311@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121121173316.GA29311@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 21, 2012 at 06:33:16PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Wed, Nov 21, 2012 at 06:03:06PM +0100, Ingo Molnar wrote:
> > > 
> > > * Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > On Wed, Nov 21, 2012 at 10:21:06AM +0000, Mel Gorman wrote:
> > > > > 
> > > > > I am not including a benchmark report in this but will be posting one
> > > > > shortly in the "Latest numa/core release, v16" thread along with the latest
> > > > > schednuma figures I have available.
> > > > > 
> > > > 
> > > > Report is linked here https://lkml.org/lkml/2012/11/21/202
> > > > 
> > > > I ended up cancelling the remaining tests and restarted with
> > > > 
> > > > 1. schednuma + patches posted since so that works out as
> > > 
> > > Mel, I'd like to ask you to refer to our tree as numa/core or 
> > > 'numacore' in the future. Would such a courtesy to use the 
> > > current name of our tree be possible?
> > > 
> > 
> > Sure, no problem.
> 
> Thanks!
> 
> I ran a quick test with your 'balancenuma v4' tree and while 
> numa02 and numa01-THREAD-ALLOC performance is looking good, 
> numa01 performance does not look very good:
> 
>                     mainline    numa/core      balancenuma-v4
>      numa01:           340.3       139.4          276 secs
> 
> 97% slower than numa/core.
> 

It would be. numa01 is an adverse workload where all threads are hammering
the same memory.  The two-stage filter in balancenuma restricts the amount
of migration it does so it ends up in a situation where it cannot balance
properly. It'll do some migration if the PTE updates happen fast enough but
that's about it.  It needs a proper policy on top to detect this situation
and interleave the memory between nodes to at least maximise the available
memory bandwidth. This would replace the two-stage filter which is there
to mitigate a ping-pong effect.

> I did a quick SPECjbb 32-warehouses run as well:
> 
>                                 numa/core      balancenuma-v4
>       SPECjbb  +THP:               655 k/sec      607 k/sec
> 

Cool. Lets see what we have here. I have some questions;

You say you ran with 32 warehouses. Was this a single run with just 32
warehouses or you did a specjbb run up to 32 warehouses and use the figure
specjbb spits out? If it ran for multiple warehouses, how did each number
of warehouses do? I ask because sometimes we do worse for low numbers
of warehouses and better at high numbers, particularly around where the
workload peaks.

Was this a single JVM configuration?

What is the comparison with a baseline kernel?

You say you ran with balancenuma-v4. Was that the full series including
the broken placement policy or did you test with just patches 1-37 as I
asked in the patch leader?

> Here it's 7.9% slower.
> 

And in comparison to a vanilla kernel?

Bear in mind that my objective was to have a foundation that did noticably
better than mainline that a proper placement and scheduling policy could
be built on top of.

Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
