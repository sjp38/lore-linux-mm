Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B0CA36B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 10:36:17 -0400 (EDT)
Date: Tue, 18 Oct 2011 09:36:14 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <20111018134835.GA16222@sgi.com>
Message-ID: <alpine.DEB.2.00.1110180933470.687@router.home>
References: <20111013135032.7c2c54cd.akpm@linux-foundation.org> <alpine.DEB.2.00.1110131602020.26553@router.home> <20111013142434.4d05cbdc.akpm@linux-foundation.org> <20111014122506.GB26737@sgi.com> <20111014135055.GA28592@sgi.com> <alpine.DEB.2.00.1110140856420.6411@router.home>
 <20111014141921.GC28592@sgi.com> <alpine.DEB.2.00.1110140932530.6411@router.home> <alpine.DEB.2.00.1110140958550.6411@router.home> <20111014161603.GA30561@sgi.com> <20111018134835.GA16222@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Tue, 18 Oct 2011, Dimitri Sivanich wrote:

> After further testing, substantial increases in ZVC delta along with cache alignment
> of the vm_stat array bring the tmpfs writeback throughput numbers to about where
> they are with vm.overcommit_memory==OVERCOMMIT_NEVER.  I still need to determine how
> high the ZVC delta needs to be to achieve this performance, but it is greater than 125.

Sounds like this is the way to go then.

> Would it make sense to have the ZVC delta be tuneable (via /proc/sys/vm?), keeping the
> same default behavior as what we currently have?

I think so.

> If the thresholds get set higher, it could be that some values that don't normally have
> as big a delta may not get updated frequently enough.  Should we maybe update all values
> everytime a threshold is hit, as the patch below was intending?

Mel can probably chime in on the accuracy needed for reclaim etc. We
already have an automatic reduction of the delta if the vm gets into
problems.

> Note that having each counter in a separate cacheline does not have much, if any,
> effect.

It may have a good effect if you group the counters according to their
uses into different cachelines. Counters that are typically updates
together need to be close to each other. Also you could modify my patch to
only update counters in the same cacheline. I think doing all counters
caused the problems with that patch because we now touch multiple
cachelines and increase the cache footprint of critical vm functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
