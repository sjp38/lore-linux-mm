Date: Thu, 31 Jul 2008 11:31:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080731103137.GD1704@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com> <20080730014308.2a447e71.akpm@linux-foundation.org> <20080730172317.GA14138@csn.ul.ie> <20080730103407.b110afc2.akpm@linux-foundation.org> <20080730193010.GB14138@csn.ul.ie> <20080730130709.eb541475.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080730130709.eb541475.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On (30/07/08 13:07), Andrew Morton didst pronounce:
> On Wed, 30 Jul 2008 20:30:10 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > With Erics patch and libhugetlbfs, we can automatically back text/data[1],
> > malloc[2] and stacks without source modification. Fairly soon, libhugetlbfs
> > will also be able to override shmget() to add SHM_HUGETLB. That should cover
> > a lot of the memory-intensive apps without source modification.
> 
> The weak link in all of this still might be the need to reserve
> hugepages and the unreliability of dynamically allocating them.
> 
> The dynamic allocation should be better nowadays, but I've lost track
> of how reliable it really is.  What's our status there?
> 

We are a lot more reliable than we were although exact quantification is
difficult because it's workload dependent. For a long time, I've been able
to test bits and pieces with hugepages by allocating the pool at the time
I needed it even after days of uptime. Previously this required a reboot.

I've also been able to use the dynamic hugepage pool resizing effectively
and we track how much it is succeeding and failing in /proc/vmstat (see the
htlb fields) to watch for problems. Between that and /proc/pagetypeinfo, I am
expecting to be able to identify availablilty problems. As an administrator
can now set a minimum pool size and the maximum size of the pool (nr_hugepages
and nr_overcommit_hugepages), the configuration difficulties should be relaxed.

If it is found that anti-fragmentation can be broken down and pool
resizing starts failing after X amount of time on Y workloads, there is
still the option of using movablecore=BiggestPoolSizeIWillEverNeed
and writing 1 to /proc/sys/vm/hugepages_treat_as_movable so the hugepage
pool can grow/shrink reliably there.

Overall, it's in pretty good shape.

To be fair, one snag is that that swap is almost required for pool
resizing to work as I never pushed to complete memory compaction
(http://lwn.net/Articles/238837/).  Hence, we depend on the workload to
have lots of filesystem-backed data for lumpy-reclaim to do its job, for
pool resizing to take place between batch jobs or for swap to be configured
even if it's just for the duration of a pool resize.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
