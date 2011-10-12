Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B404E6B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:57:56 -0400 (EDT)
Date: Wed, 12 Oct 2011 14:57:53 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <20111012120118.e948f40a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1110121452220.31218@router.home>
References: <20111012160202.GA18666@sgi.com> <20111012120118.e948f40a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Wed, 12 Oct 2011, Andrew Morton wrote:

> > Note that this patch is simply to illustrate the gains that can be made here.
> > What I'm looking for is some guidance on an acceptable way to accomplish the
> > task of reducing contention in this area, either by caching these values in a
> > way similar to the attached patch, or by some other mechanism if this is
> > unacceptable.
>
> Yes, the global vm_stat[] array is a problem - I'm surprised it's hung
> around for this long.  Altering the sysctl_overcommit_memory mode will
> hide the problem, but that's no good.

The global vm_stat array is keeping the state for the zone. It would be
even more expensive to calculate this at every point where we need such
data.

> I think we've discussed switching vm_stat[] to a contention-avoiding
> counter scheme.  Simply using <percpu_counter.h> would be the simplest
> approach.  They'll introduce inaccuracies but hopefully any problems
> from that will be minor for the global page counters.

We already have a contention avoiding scheme for counter updates in
vmstat.c. The problem here is that vm_stat is frequently read. Updates
from other cpus that fold counter updates in a deferred way into the
global statistics cause cacheline eviction. The updates occur too frequent
in this load.

> otoh, I think we've been round this loop before and I don't recall why
> nothing happened.

The update behavior can be tuned using /proc/sys/vm/stat_interval.
Increase the interval to reduce the folding into the global counter (set
maybe to 10?). This will reduce contention. The other approach is to
increase the allowed delta per zone if frequent updates occur via the
overflow checks in vmstat.c. See calculate_*_threshold there.

Note that the deltas are current reduced for memory pressure situations
(after recent patches by Mel). This will cause a significant increase in
vm_stat cacheline contention compared to earlier kernels.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
