Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 979216B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 06:36:33 -0400 (EDT)
Date: Fri, 31 Jul 2009 11:36:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
Message-ID: <20090731103632.GB28766@csn.ul.ie>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain> <20090729181205.23716.25002.sendpatchset@localhost.localdomain> <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30, 2009 at 12:39:09PM -0700, David Rientjes wrote:
> On Wed, Jul 29, 2009 at 11:12 AM, Lee
> Schermerhorn<lee.schermerhorn@hp.com> wrote:
> > PATCH/RFC 4/4 hugetlb:  register per node hugepages attributes
> >
> > Against: 2.6.31-rc3-mmotm-090716-1432
> > atop the previously posted alloc_bootmem_hugepages fix.
> > [http://marc.info/?l=linux-mm&m=124775468226290&w=4]
> >
> > This patch adds the per huge page size control/query attributes
> > to the per node sysdevs:
> >
> > /sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
> >        nr_hugepages       - r/w
> >        free_huge_pages    - r/o
> >        surplus_huge_pages - r/o
> >
> > The patch attempts to re-use/share as much of the existing
> > global hstate attribute initialization and handling as possible.
> > Throughout, a node id < 0 indicates global hstate parameters.
> >
> > Note:  computation of "min_count" in set_max_huge_pages() for a
> > specified node needs careful review.
> >
> > Issue:  dependency of base driver [node] dependency on hugetlbfs module.
> > We want to keep all of the hstate attribute registration and handling
> > in the hugetlb module.  However, we need to call into this code to
> > register the per node hstate attributes on node hot plug.
> >
> > With this patch:
> >
> > (me):ls /sys/devices/system/node/node0/hugepages/hugepages-2048kB
> > ./  ../  free_hugepages  nr_hugepages  surplus_hugepages
> >
> > Starting from:
> > Node 0 HugePages_Total:     0
> > Node 0 HugePages_Free:      0
> > Node 0 HugePages_Surp:      0
> > Node 1 HugePages_Total:     0
> > Node 1 HugePages_Free:      0
> > Node 1 HugePages_Surp:      0
> > Node 2 HugePages_Total:     0
> > Node 2 HugePages_Free:      0
> > Node 2 HugePages_Surp:      0
> > Node 3 HugePages_Total:     0
> > Node 3 HugePages_Free:      0
> > Node 3 HugePages_Surp:      0
> > vm.nr_hugepages = 0
> >
> > Allocate 16 persistent huge pages on node 2:
> > (me):echo 16 >/sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages
> >
> > Yields:
> > Node 0 HugePages_Total:     0
> > Node 0 HugePages_Free:      0
> > Node 0 HugePages_Surp:      0
> > Node 1 HugePages_Total:     0
> > Node 1 HugePages_Free:      0
> > Node 1 HugePages_Surp:      0
> > Node 2 HugePages_Total:    16
> > Node 2 HugePages_Free:     16
> > Node 2 HugePages_Surp:      0
> > Node 3 HugePages_Total:     0
> > Node 3 HugePages_Free:      0
> > Node 3 HugePages_Surp:      0
> > vm.nr_hugepages = 16
> >
> > Global controls work as expected--reduce pool to 8 persistent huge pages:
> > (me):echo 8 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
> >
> > Node 0 HugePages_Total:     0
> > Node 0 HugePages_Free:      0
> > Node 0 HugePages_Surp:      0
> > Node 1 HugePages_Total:     0
> > Node 1 HugePages_Free:      0
> > Node 1 HugePages_Surp:      0
> > Node 2 HugePages_Total:     8
> > Node 2 HugePages_Free:      8
> > Node 2 HugePages_Surp:      0
> > Node 3 HugePages_Total:     0
> > Node 3 HugePages_Free:      0
> > Node 3 HugePages_Surp:      0
> >
> >
> >
> >
> >
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> >
> 
> Thank you very much for doing this.
> 
> Google is going to need this support regardless of what finally gets
> merged into mainline, so I'm thrilled you've implemented this version.
> 

The fact that there is a definite use case in mind lends weight to this
approach but I want to be 100% sure that a hugetlbfs-specific interface
is required in this case.

> I hugely (get it? hugely :) favor this approach because it's much
> simpler to reserve hugepages from this interface than a mempolicy
> based approach once hugepages have already been allocated before.  For
> cpusets users in particular, jobs typically get allocated on a subset
> of nodes that are required for that application and they don't last
> for the duration of the machine's uptime.  When a job exits and the
> nodes need to be reallocated to a new cpuset, it may be a very
> different set of mems based on the memory requirements or interleave
> optimizations for the new job.  Allocating resources such as hugepages
> are possible in this scenario via mempolicies, but it would require a
> temporary mempolicy to then allocate additional hugepages from which
> seems like an unnecessary requirement, especially if the job scheduler
> that is governing hugepage allocations already has a mempolicy of its
> own.
> 

I don't know the setup, but lets say something like the following is
happening

1. job scheduler creates cpuset of subset of nodes
2. job scheduler creates memory policy for subset of nodes
3. initialisation job starts, reserves huge pages. If a memory policy is
   already in place, it will reserve them in the correct places
4. Job completes
5. job scheduler frees the pages reserved for the job freeing up pages
   on the subset of nodes

i.e. if the job scheduler already has a memory policy of it's own, or
even some child process of that job scheduler, it should just be able to
set nr_hugepages and have them reserved on the correct nodes.

With the per-node-attribute approach, little stops a process going
outside of it's subset of allowed nodes.

> So it's my opinion that the mempolicy based approach is very
> appropriate for tasks that allocate hugepages itself.  Other users,
> particularly cpusets users, however, would require preallocation of
> hugepages prior to a job being scheduled in which case a temporary
> mempolicy would be required for that job scheduler. 

And why is it such a big difficulty for the job scheduler just to create a
child that does

numactl -m $NODES_SUBSET hugeadm --pool-pages-min 2M:+$PAGES_NEEDED

?

> That seems like
> an inconvenience when the entire state of the system's hugepages could
> easily be governed with the per-node hstate attributes and a slightly
> modified user library.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
