Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C21F16B008C
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 16:37:38 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NKYSnv016489
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 16:34:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NKcCbt164354
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 16:38:12 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NKaN3W029007
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 16:36:24 -0400
Subject: Re: [PATCH V3] Fix Committed_AS underflow
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090423163148.GB5044@us.ibm.com>
References: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com>
	 <1240244120.32604.278.camel@nimitz> <1240256999.32604.330.camel@nimitz>
	 <20090423163148.GB5044@us.ibm.com>
Content-Type: text/plain
Date: Thu, 23 Apr 2009 13:38:08 -0700
Message-Id: <1240519088.10627.196.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-23 at 17:31 +0100, Eric B Munson wrote:
> On Mon, 20 Apr 2009, Dave Hansen wrote:
> 
> > On Mon, 2009-04-20 at 09:15 -0700, Dave Hansen wrote:
> > > On Mon, 2009-04-20 at 10:09 +0100, Eric B Munson wrote:
> > > > 1. Change NR_CPUS to min(64, NR_CPUS)
> > > >    This will limit the amount of possible skew on kernels compiled for very
> > > >    large SMP machines.  64 is an arbitrary number selected to limit the worst
> > > >    of the skew without using more cache lines.  min(64, NR_CPUS) is used
> > > >    instead of nr_online_cpus() because nr_online_cpus() requires a shared
> > > >    cache line and a call to hweight to make the calculation.  Its runtime
> > > >    overhead and keeping this counter accurate showed up in profiles and it's
> > > >    possible that nr_online_cpus() would also show.
> > 
> > Wow, that empty reply was really informative, wasn't it? :)
> > 
> > My worry with this min(64, NR_CPUS) approach is that you effectively
> > ensure that you're going to be doing a lot more cacheline bouncing, but
> > it isn't quite as explicit.
> 
> Unfortunately this is a choice we have to make, do we want to avoid cache
> line bouncing of fork-heavy workloads using more than 64 pages or bad
> information being used for overcommit decisions?

On SLES11, a new bash shell has ~9MB of mapped space.  A cat(1) has
~6.7MB.  The ACCT_THRESHOLD=64*2 pages with a 64k page is 8MB.  So,
you're basically *guaranteed* to go off-cpu every time a shell command
is performed.  So, I'd say 8MB is a bit on the low side.

Note that even with your suggested patch, we can still have 8GB of skew
on a 1024-way machine since there are still num_online_cpus()*8MB.  This
is better than what we have now, certainly.

> > Now, every time there's a mapping (or set of them) created or destroyed
> > that nets greater than 64 pages, you've got to go get a r/w cacheline to
> > a possibly highly contended atomic.  With a number this low, you're
> > almost guaranteed to hit it at fork() and exec().  Could you
> > double-check that this doesn't hurt any of the fork() AIM tests?
> 
> It is unlikely that the aim9 benchmarks would show if this patch was a
> problem because it forks in a tight loop and in a process that is not
> necessarily beig enough to hit ACCT_THRESHOLD, likely on a single CPU.
> In order to show any problems here we need a fork heavy workload with
> many threads on many CPUs.

That's true.  I'd suspect that aim is somewhere around the size of
'cat'.  It's a best-case scenario.  But, if you see degradation on the
best-case workload, we'll certainly see issues on worse workloads.

Also, I used fork as an obvious example here.  This issue will present
itself any time there is a mapping or set of mappings with a net change
in size of 8MB.

There's another alternative.  We could temporarily add statistics to
count how many times we go over ACCT_THRESHOLD to see just how bad the
situation is.  For instance, 64 causes 342.43 times as many touches of
the global counter as 8192 (or whatever it is).  You could also make
ACCT_THRESHOLD a tunable, at least for the duration of this testing.

There are also ways you can bias the global counter in controlled ways.
You could ensure, for instance, that a local counter never gets a
positive bias, causing the global one to be biased negatively.  That
would guarantee no underflows, although it would still be possible to
see vm_committed_space in an temporary *inflated* state.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
