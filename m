Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 17B526B005A
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 04:32:37 -0500 (EST)
Date: Thu, 22 Nov 2012 09:32:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/46] Automatic NUMA Balancing V4
Message-ID: <20121122093230.GR8218@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <20121121165342.GH8218@suse.de>
 <20121121170306.GA28811@gmail.com>
 <20121121172011.GI8218@suse.de>
 <20121121173316.GA29311@gmail.com>
 <20121121180200.GK8218@suse.de>
 <20121121232715.GA4638@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121121232715.GA4638@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Nov 22, 2012 at 12:27:15AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > I did a quick SPECjbb 32-warehouses run as well:
> > > 
> > >                                 numa/core      balancenuma-v4
> > >       SPECjbb  +THP:               655 k/sec      607 k/sec
> > > 
> > 
> > Cool. Lets see what we have here. I have some questions;
> > 
> > You say you ran with 32 warehouses. Was this a single run with 
> > just 32 warehouses or you did a specjbb run up to 32 
> > warehouses and use the figure specjbb spits out? [...]
> 
> "32 warehouses" obviously means single instance...
> 

Considering the amount of flak you gave me over the THP problem, it is
not unreasonable to ask a questions in clarification.

On running just 32 warehouse, please remember what I said about specjbb
benchmarks. MMTests reports each warehouse figure because indications
are that the low number of warehouses regressed while the higher numbers
showed performance improvements. Further, specjbb itself uses only figures
from around the expected peak it estimates unless it is overridden by the
config file (I expect you left it at the default).

So, you've answered my first question. You did not run for multiple
warehouses so you do not know what the lower number of warehouses were.
That's ok, the comparison is still valid.  Can you now answer my other
questions please? They were;

	What is the comparison with a baseline kernel?

	You say you ran with balancenuma-v4. Was that the full series
	including the broken placement policy or did you test with just
	patches 1-37 as I asked in the patch leader?

I'll also reiterate my final point. The objective of balancenuma is to be
better than mainline and at worst, be no worse than mainline (which with
PTE updates may be impossible but it's the bar). It puts in place a *basic*
placement policy that could be summarised as "migrate on reference with
a two stage filter". It is a common foundation that either the policies
of numacore *or* autonuma could be rebased upon so they can be compared in
terms of placement policy, shared page identification, scheduler policy and
load balance policy. Where they share policies (e.g. scheduler accounting
and load balance), we'd agree on those patches and move on until the two

Of course, a rebase may require changes to the task_numa_fault() interface
betwen the VM and the scheduler depending on the information the policies
are interested. There also might be differing requirements of the PTE
scanner but they should be marginal.

balancenuma is not expected to beat a smart placement policy but when
it does, the question becomes if the difference is due to the underlying
mechanics such as how it updates PTEs and traps fauls or the scheduler and
placement policies built on top. If we can eliminate the possibility that
it's the underlying mechanics our lives will become a lot easier.

Is there a fundamental reason why the scheduler modifications, placement
policies, shared page identification etc. from numacore cannot be rebased on
top of balancenuma? If there are no fundamental reasons, then why will you
not rebase so that we can potentially compare autonuma's policies directly
if it gets rebased? That will tell us if autonumas policies (placement,
scheduler, load balancer) are really better or if it actually depended on
its implementation of the underlying mechanics (use of a kernel thread to
do the PTE updates for example).

> Any multi-instance configuration is explicitly referred to as 
> multi-instance. In my numbers I sometimes tabulate them as "4x8 
> multi-JVM", that means the obvious as well: 4 instances, 8 
> warehouses each.
> 

Understood.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
