Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C52BC6B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 19:14:51 -0400 (EDT)
Date: Fri, 26 Jul 2013 19:14:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/3] mm: improve page aging fairness between zones/nodes
Message-ID: <20130726231444.GT715@cmpxchg.org>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <20130726154533.aebd39c603ffe8de3b2c76fb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130726154533.aebd39c603ffe8de3b2c76fb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 26, 2013 at 03:45:33PM -0700, Andrew Morton wrote:
> On Fri, 19 Jul 2013 16:55:22 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > The way the page allocator interacts with kswapd creates aging
> > imbalances, where the amount of time a userspace page gets in memory
> > under reclaim pressure is dependent on which zone, which node the
> > allocator took the page frame from.
> > 
> > #1 fixes missed kswapd wakeups on NUMA systems, which lead to some
> >    nodes falling behind for a full reclaim cycle relative to the other
> >    nodes in the system
> > 
> > #3 fixes an interaction where kswapd and a continuous stream of page
> >    allocations keep the preferred zone of a task between the high and
> >    low watermark (allocations succeed + kswapd does not go to sleep)
> >    indefinitely, completely underutilizing the lower zones and
> >    thrashing on the preferred zone
> > 
> > These patches are the aging fairness part of the thrash-detection
> > based file LRU balancing.  Andrea recommended to submit them
> > separately as they are bugfixes in their own right.
> > 
> > The following test ran a foreground workload (memcachetest) with
> > background IO of various sizes on a 4 node 8G system (similar results
> > were observed with single-node 4G systems):
> > 
> > parallelio
> >                                                BAS                    FAIRALLO
> >                                               BASE                   FAIRALLOC
> > Ops memcachetest-0M              5170.00 (  0.00%)           5283.00 (  2.19%)
> > Ops memcachetest-791M            4740.00 (  0.00%)           5293.00 ( 11.67%)
> > Ops memcachetest-2639M           2551.00 (  0.00%)           4950.00 ( 94.04%)
> > Ops memcachetest-4487M           2606.00 (  0.00%)           3922.00 ( 50.50%)
> > Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> > Ops io-duration-791M               55.00 (  0.00%)             18.00 ( 67.27%)
> > Ops io-duration-2639M             235.00 (  0.00%)            103.00 ( 56.17%)
> > Ops io-duration-4487M             278.00 (  0.00%)            173.00 ( 37.77%)
> > Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)
> > Ops swaptotal-791M             245184.00 (  0.00%)              0.00 (  0.00%)
> > Ops swaptotal-2639M            468069.00 (  0.00%)         108778.00 ( 76.76%)
> > Ops swaptotal-4487M            452529.00 (  0.00%)          76623.00 ( 83.07%)
> > Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)
> > Ops swapin-791M                108297.00 (  0.00%)              0.00 (  0.00%)
> > Ops swapin-2639M               169537.00 (  0.00%)          50031.00 ( 70.49%)
> > Ops swapin-4487M               167435.00 (  0.00%)          34178.00 ( 79.59%)
> > Ops minorfaults-0M            1518666.00 (  0.00%)        1503993.00 (  0.97%)
> > Ops minorfaults-791M          1676963.00 (  0.00%)        1520115.00 (  9.35%)
> > Ops minorfaults-2639M         1606035.00 (  0.00%)        1799717.00 (-12.06%)
> > Ops minorfaults-4487M         1612118.00 (  0.00%)        1583825.00 (  1.76%)
> > Ops majorfaults-0M                  6.00 (  0.00%)              0.00 (  0.00%)
> > Ops majorfaults-791M            13836.00 (  0.00%)             10.00 ( 99.93%)
> > Ops majorfaults-2639M           22307.00 (  0.00%)           6490.00 ( 70.91%)
> > Ops majorfaults-4487M           21631.00 (  0.00%)           4380.00 ( 79.75%)
> 
> A reminder whether positive numbers are good or bad would be useful ;)

It depends on the datapoint, but a positive percentage number is an
improvement, a negative one a regression.

> >                  BAS    FAIRALLO
> >                 BASE   FAIRALLOC
> > User          287.78      460.97
> > System       2151.67     3142.51
> > Elapsed      9737.00     8879.34
> 
> Confused.  Why would the amount of user time increase so much?
> 
> And that's a tremendous increase in system time.  Am I interpreting
> this correctly?

It is because each memcachetest is running for a fixed duration (only
the background IO is fixed in size).  The time memcachetest previously
spent waiting on major faults is now spent doing actual work (more
user time, more syscalls).  The number of operations memcachetest
could actually perform increased.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
