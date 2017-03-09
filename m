Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 078422808E3
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 17:15:28 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u108so23573505wrb.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 14:15:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si10311986wrp.270.2017.03.09.14.15.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 14:15:26 -0800 (PST)
Date: Thu, 9 Mar 2017 22:15:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] Enable parallel page migration
Message-ID: <20170309221522.hwk4wyaqx2jonru6@suse.de>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
 <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
 <20170309150904.pnk6ejeug4mktxjv@suse.de>
 <2a2827d0-53d0-175b-8ed4-262629e01984@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2a2827d0-53d0-175b-8ed4-262629e01984@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Nellans <dnellans@nvidia.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, Mar 09, 2017 at 11:38:00AM -0600, David Nellans wrote:
> On 03/09/2017 09:09 AM, Mel Gorman wrote:
> > I didn't look into the patches in detail except to get a general feel
> > for how it works and I'm not convinced that it's a good idea at all.
> >
> > I accept that memory bandwidth utilisation may be higher as a result but
> > consider the impact. THP migrations are relatively rare and when they
> > occur, it's in the context of a single thread. To parallelise the copy,
> > an allocation, kmap and workqueue invocation are required. There may be a
> > long delay before the workqueue item can start which may exceed the time
> > to do a single copy if the CPUs on a node are saturated. Furthermore, a
> > single thread can preempt operations of other unrelated threads and incur
> > CPU cache pollution and future misses on unrelated CPUs. It's compounded by
> > the fact that a high priority system workqueue is used to do the operation,
> > one that is used for CPU hotplug operations and rolling back when a netdevice
> > fails to be registered. It treats a hugepage copy as an essential operation
> > that can preempt all other work which is very questionable.
> >
> > The series leader has no details on a workload that is bottlenecked by
> > THP migrations and even if it is, the primary question should be *why*
> > THP migrations are so frequent and alleviating that instead of
> > preempting multiple CPUs to do the work.
> >
> >
>
> Mel - I sense on going frustration around some of the THP migration,
> migration acceleration, CDM, and other patches.  Here is a 10k foot
> description that I hope adds to what John & Anshuman have said in other
> threads.
> 

Hi David,

I recognise the motivation for some of these patches but disagree on the
mechanisms used, more on this later.

> Vendors are currently providing systems that have both traditional
> DDR3/4 memory (lets call it 100GB/s) and high bandwidth memory (HBM)
> (lets call it 1TB/s) within a single system.  GPUs have been doing this
> with HBM on the GPU and DDR on the CPU complex, but they've been
> attached via PCIe and thus HBM has been GPU private memory. 

I completely understand although I'd point out that HBM is slightly
different in that it could be expressed in terms of a hierarchical node
system whereby some nodes migrate to each other -- from faster to slower by
a "migrate on LRU reclaim" and from slower to faster with automatic NUMA
balancing using sampling. However, HBM is extremely specific and dealing
with that is not necessarily compatible with devices that are not coherent.

> <SNIP>

Again, I understand the motivation and have no further comment to make.
In the interest of trying to be helpful, I'll propose an alternative to
this series and expand upon why I think it's problematic.

> the HBM node from the DDR node. The expectation is that on such systems
> either the user, a daemon, or kernel/autonuma is going to be migrating
> (TH)pages between the NUMA zones to optimize overall system
> bandwidth/throughput.  Because of the 10x discrepancy in memory
> bandwidth, despite the best paging policies to optimize for page
> locality in the HBM nodes, pages will often still be moving at a high
> rate between zones.  This differs from a traditional NUMA system where
> moving a page from one 100GB/s node to the other 100GB/s node has
> dubious value, like you say.
> 
> To your specific question - what workloads benefit from this improved
> migration throughput and why THPs? 

So the key potential issue here in my mind is that THP migration is too slow
in some cases. What I object to is improving that using a high priority
workqueue that potentially starves other CPUs and pollutes their cache
which is generally very expensive.

Lets look at the core of what copy_huge_page does in mm/migrate.c which
is the function that gets parallelised by the series in question. For
a !HIGHMEM system, it's woefully inefficient. Historically, it was an
implementation that would work generically which was fine but maybe not
for future systems. It was also fine back when hugetlbfs was the only huge
page implementation and COW operations were incredibly rare on the grounds
due to the risk that they could terminate the process with prejudice.

The function takes a huge page, splits it into PAGE_SIZE chunks, kmap_atomics
the source and destination for each PAGE_SIZE chunk and copies it. The
parallelised version does one kmap and copies it in chunks assuming the
THP is fully mapped and accessible. Fundamentally, this is broken in the
generic sense as the kmap is not guaranteed to make the whole page necessary
but it happens to work on !highmem systems.  What is more important to
note is that it's multiple preempt and pagefault enables and disables
on a per-page basis that happens 512 times (for THP on x86-64 at least),
all of which are expensive operations depending on the kernel config and
I suspect that the parallisation is actually masking that stupid overhead.

At the very least, I would have expected an initial attempt of one patch that
optimised for !highmem systems to ignore kmap, simply disable preempt (if
that is even necessary, I didn't check) and copy a pinned physical->physical
page as a single copy without looping on a PAGE_SIZE basis and see how
much that gained. Do it initially for THP only and worry about gigantic
pages when or if that is a problem.

That would be patch 1 of a series.  Maybe that'll be enough, maybe not but
I feel it's important to optimise the serialised case as much as possible
before considering parallelisation to highlight and justify why it's
necessary[1]. If nothing else, what if two CPUs both parallelise a migration
at the same time and end up preempting each other? Between that and the
workqueue setup, it's potentially much slower than an optimised serial copy.

It would be tempting to experiment but the test case was not even included
with the series (maybe it's somewhere else)[2]. While it's obvious how
such a test case could be constructed, it feels unnecessary to construct
it when it should be in the changelog.

To some extent, CDM suffered from the same pushback. Like this series,
it introduced something new, complex and with high maintenance overhead
without considering whether the existing mechanisms (cpuset, mempolicies
or some combination of both) or out-of tree proposals such as HMM that
could be added to and finalised[3].

[1] If nothing else, it would make it clear to the reviewer that
    additional complexity is 100% justified which is woefully missing in
    this series.

[2] For complex series that have an alleged performance improvement, it
    should always be possible to supply a test case that can demonstrate
    that. Granted, this does not always happen but at least for my own
    series I have the test case in question automated and can point people
    to the repository that stores the test case and if necessary, supply
    instructions on how to reproduce the results.

[3] Preferably with an in-tree user because the lack of such a user was
    one of the major factors that gave HMM a kicking.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
