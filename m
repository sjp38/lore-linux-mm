Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6948F6B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 11:23:59 -0400 (EDT)
Date: Thu, 13 Oct 2011 10:23:55 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
Message-ID: <20111013152355.GB6966@sgi.com>
References: <20111012160202.GA18666@sgi.com>
 <20111012120118.e948f40a.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1110121452220.31218@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110121452220.31218@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Wed, Oct 12, 2011 at 02:57:53PM -0500, Christoph Lameter wrote:
> On Wed, 12 Oct 2011, Andrew Morton wrote:
> 
> > > Note that this patch is simply to illustrate the gains that can be made here.
> > > What I'm looking for is some guidance on an acceptable way to accomplish the
> > > task of reducing contention in this area, either by caching these values in a
> > > way similar to the attached patch, or by some other mechanism if this is
> > > unacceptable.
> >
> > Yes, the global vm_stat[] array is a problem - I'm surprised it's hung
> > around for this long.  Altering the sysctl_overcommit_memory mode will
> > hide the problem, but that's no good.
> 
> The global vm_stat array is keeping the state for the zone. It would be
> even more expensive to calculate this at every point where we need such
> data.
> 
> > I think we've discussed switching vm_stat[] to a contention-avoiding
> > counter scheme.  Simply using <percpu_counter.h> would be the simplest
> > approach.  They'll introduce inaccuracies but hopefully any problems
> > from that will be minor for the global page counters.
> 
> We already have a contention avoiding scheme for counter updates in
> vmstat.c. The problem here is that vm_stat is frequently read. Updates
> from other cpus that fold counter updates in a deferred way into the
> global statistics cause cacheline eviction. The updates occur too frequent
> in this load.

The test I did slowed down the reads by __vm_enough_memory by caching the
values and updating them every two seconds (in the OVERCOMMIT_GUESS area).
> 
> > otoh, I think we've been round this loop before and I don't recall why
> > nothing happened.
> 
> The update behavior can be tuned using /proc/sys/vm/stat_interval.
> Increase the interval to reduce the folding into the global counter (set
> maybe to 10?). This will reduce contention. The other approach is to

Increasing this interval to 10 (or even 100) had no effect on the vm_stat
contention on a 640 cpu test system, so vmstat_update() is not the culprit.

> increase the allowed delta per zone if frequent updates occur via the
> overflow checks in vmstat.c. See calculate_*_threshold there.

I tried changing the threshold in both directions, with slower throughput in
both cases.

> 
> Note that the deltas are current reduced for memory pressure situations
> (after recent patches by Mel). This will cause a significant increase in
> vm_stat cacheline contention compared to earlier kernels.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
