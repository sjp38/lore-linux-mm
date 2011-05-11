Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD6E96B0024
	for <linux-mm@kvack.org>; Wed, 11 May 2011 18:27:27 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p4BMRNML015168
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:27:23 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by hpaq13.eem.corp.google.com with ESMTP id p4BMQaTk032623
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:27:21 -0700
Received: by pzk9 with SMTP id 9so567828pzk.5
        for <linux-mm@kvack.org>; Wed, 11 May 2011 15:27:13 -0700 (PDT)
Date: Wed, 11 May 2011 15:27:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <20110511210907.GA17898@suse.de>
Message-ID: <alpine.DEB.2.00.1105111456220.24003@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305127773-10570-4-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com> <20110511210907.GA17898@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 11 May 2011, Mel Gorman wrote:

> I agree with you that there are situations where plenty of memory
> means that that it'll perform much better. However, indications are
> that it breaks down with high CPU usage when memory is low.  Worse,
> once fragmentation becomes a problem, large amounts of UNMOVABLE and
> RECLAIMABLE will make it progressively more expensive to find the
> necessary pages. Perhaps with patches 1 and 2, this is not as much
> of a problem but figures in the leader indicated that for a simple
> workload with large amounts of files and data exceeding physical
> memory that it was better off not to use high orders at all which
> is a situation I'd expect to be encountered by more users than
> performance-sensitive applications.
> 
> In other words, we're taking one hit or the other.
> 

Seems like the ideal solution would then be to find how to best set the 
default, and that can probably only be done with the size of the smallest 
node since it has a higher liklihood of encountering a large amount of 
unreclaimable slab when memory is low.

> > I can get numbers for a simple netperf TCP_RR benchmark with this change 
> > applied to show the degradation on a server with >32GB of RAM with this 
> > patch applied.
> > 
> 
> Agreed, I'd expect netperf TCP_RR or TCP_STREAM to take a hit,
> particularly on a local machine where the recycling of pages will
> impact it heavily.
> 

Ignoring the local machine for a second, TCP_RR probably shouldn't be 
taking any more of a hit with slub than it already is.  When I benchmarked 
slab vs. slub a couple months ago with two machines, each four quad-core 
Opterons with 64GB of memory, with this benchmark it showed slub was 
already 10-15% slower.  That's why slub has always been unusable for us, 
and I'm surprised that it's now becoming the favorite of distros 
everywhere (and, yes, Ubuntu now defaults to it as well).

> > It would be ideal if this default could be adjusted based on the amount of 
> > memory available in the smallest node to determine whether we're concerned 
> > about making higher order allocations. 
> 
> It's not a function of memory size, working set size is what
> is important or at least how many new pages have been allocated
> recently. Fit your workload in physical memory - high orders are
> great. Go larger than that and you hit problems. James' testing
> indicated that kswapd CPU usage dropped to far lower levels with this
> patch applied his test of untarring a large file for example.
> 

My point is that it would probably be better to tune the default based on 
how much memory is available at boot since it implies the probability of 
having an abundance of memory while populating the caches' partial lists 
up to min_partial rather than change it for everyone where it is known 
that it will cause performance degradations if memory is never low.  We 
probably don't want to be doing order-3 allocations for half the slab 
caches when we have 1G of memory available, but that's acceptable with 
64GB.

> > (Using the smallest node as a 
> > metric so that mempolicies and cpusets don't get unfairly biased against.)  
> > With the previous changes in this patchset, specifically avoiding waking 
> > kswapd and doing compaction for the higher order allocs before falling 
> > back to the min order, it shouldn't be devastating to try an order-3 alloc 
> > that will fail quickly.
> > 
> 
> Which is more reasonable? That an ordinary user gets a default that
> is fairly safe even if benchmarks that demand the highest performance
> from SLUB take a hit or that administrators running such workloads
> set slub_max_order=3?
> 

Not sure what is more reasonable since it depends on what the workload is, 
but what probably is unreasonable is changing a slub default that is known 
to directly impact performance by presenting a single benchmark under 
consideration without some due diligence in testing others like netperf.

We all know that slub has some disavantages compared to slab that are only 
now being realized because it has become the debian default, but it does 
excel at some workloads -- it was initially presented to beat slab in 
kernbench, hackbench, sysbench, and aim9 when it was merged.  Those 
advantages may never be fully realized on laptops or desktop machines, but 
with machines with plenty of memory available, slub ofter does perform 
better than slab.

That's why I suggested tuning the min order default based on total memory, 
it would probably be easier to justify than changing it for everyone and 
demanding users who are completely happy with using slub, the kernel.org 
default for years, now use command line options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
