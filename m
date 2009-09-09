Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 407766B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 04:16:26 -0400 (EDT)
Date: Wed, 9 Sep 2009 09:16:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for
	mempolicy based management.
Message-ID: <20090909081631.GB24614@csn.ul.ie>
References: <20090828160351.11080.21379.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031254380.26408@chino.kir.corp.google.com> <1252012158.6029.215.camel@useless.americas.hpqcorp.net> <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com> <20090908104409.GB28127@csn.ul.ie> <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com> <20090908200451.GA6481@csn.ul.ie> <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com> <20090908214109.GB6481@csn.ul.ie> <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 08, 2009 at 03:54:40PM -0700, David Rientjes wrote:
> On Tue, 8 Sep 2009, Mel Gorman wrote:
> 
> > Why is a job scheduler that is expecting to affect memory on a global
> > basis running inside a mempolicy that restricts it to a subset of nodes?
> 
> Because hugepage allocation and freeing has always been on a global basis, 
> there was no previous restriction.
> 

And to beat a dead horse, it does make sense that an application
allocating hugepages obey memory policies. It does with dynamic hugepage
resizing for example. It should have been done years ago and
unfortunately wasn't but it's not the first time that the behaviour of
hugepages differed from the core VM.

> > In addition, if it is the case that the jobs performance is directly
> > proportional to the number of hugepages it gets access to, why is it starting
> > up with access to only a subset of the available hugepages?
> 
> It's not, that particular job is allocated the entire machine other than 
> the job scheduler. The point is that the machine pool treats each machine 
> equally so while they are all booted with hugepages=<large number>, 
> machines that don't serve this application immediately free them.  If 
> hugepages cannot be dynamically allocated up to a certain threshold that 
> the application requires, a reboot is necessary if no other machines are 
> available.
> 
> Since the only way to achieve the absolute maximum number of hugepages 
> possible on a machine is through the command line, it's completely 
> reasonable to use it on every boot and then subsequently free them when 
> they're unnecessary.
> 

But less reasonable that an application within a memory policy be able
to affect memory on a global basis. Why not let it break cpusets or
something else as well?

> > Why is it not
> > being setup to being the first job to start on a freshly booting machine,
> > starting on the subset of nodes allowed and requesting the maximum number
> > of hugepages it needs such that it achieves maximum performance? With the
> > memory policy approach, it's very straight-forward to do this because all
> > it has to do is write to nr_hugepages when it starts-up.
> > 
> 
> The job scheduler will always be the first job to start on the machine and 
> it may have a mempolicy of its own.  When it attempts to free all 
> hugepages allocated by the command line, it will then leak pages because 
> of these changes.
> 
> Arguing that applications should always dynamically allocate their 
> hugepages on their own subset of nodes when they are started is wishful 
> thinking: it's much easier to allocate as many as possible on the command 
> line and then free unnecessary hugepages than allocate on the mempolicy's 
> nodes for the maximal number of hugepages.
> 

Only in your particular case where you're willing to reboot the machine to
satisfy a jobs hugepage requirement. This is not always the situation. On
shared-machines, there can be many jobs running, each with different hugepage
requirements. The objective of things like anti-fragmentation, lumpy reclaim
and the like was to allow these sort of jobs to allocate the pages they
need at run-time. In the event these jobs are running on a subset of nodes,
it's of benefit to have nr_hugepages obey memory policies or else userspace
or the administrator has to try a number of different tricks to get the
hugepages they need on the nodes they want.

> > > That 
> > > was not the behavior over the past three or four years until this 
> > > patchset.
> > > 
> > 
> > While this is true, I know people have also been bitten by the expectation
> > that writing to nr_hugepages would obey a memory policy and were surprised
> > when it didn't happen and sent me whinging emails.
> 
> Ok, but I doubt the inverse is true: people probably haven't emailed you 
> letting you know that they've coded their application for hugepage 
> allocations based on how the kernel has implemented it for years, so 
> there's no context. 

They didn't code their application specifically to this case. What happened
is that their jobs needed to run on a subset of nodes and they wanted the
hugepages only available on those nodes. They wrote the value under a memory
policy to nr_hugepages and were suprised when that didn't work. cpusets were
not an obvious choice.

> That's the population that I'm worried about (and is 
> also solved by node-targeted hugepage allocation, btw).
> 

I disagree because it pushes the burden of interleaving to the userspace
application or the administrator, something the kernel can and is able
to deal with.

>  [ Such users who have emailed you could always use cpusets for the
>    desired effect, it's not like there isn't a solution. ]
>  

Which is very convulated. numactl is the expected administrative interface
to restrict allocations on a set of nodes, not cpusets.

> > It also appeared obvious
> > to me that it's how the interface should behave even if it wasn't doing it
> > in practice. Once nr_hugepages obeys memory policies, it's fairly convenient
> > to size the number of pages on a subset of nodes using numactl - a tool that
> > people would generally expect to be used when operating on nodes. Hence the
> > example usage being
> > 
> > numactl -m x,y,z hugeadm --pool-pages-min $PAGESIZE:$NUMPAGES
> > 
> 
> We need a new mempolicy flag, then, such as MPOL_F_HUGEPAGES to constrain 
> hugepage allocation and freeing via the global tunable to such a 
> mempolicy.
> 

This would be somewhat inconsistent. When dynamic hugepage pool resizing
is enabled, the application obeys the memory policy that is in place.
Your suggested policy would only apply when nr_hugepages is being
written to.

It would also appear as duplicated and redundant functionality to numactl
because it would have --interleave meaning interleaving and --hugepages
meaning interleave but only when nr_hugepages is being written to.

> > The advantage is that with memory policies on nr_hugepages, it's very
> > convenient to allocate pages within a subset of nodes without worrying about
> > where exactly those huge pages are being allocated from. It will allocate
> > them on a round-robin basis allocating more pages on one node over another
> > if fragmentation requires it rather than shifting the burden to a userspace
> > application figuring out what nodes might succeed an allocation or shifting
> > the burden onto the system administrator.
> 
> That "burden" is usually for good reason: if my MPOL_INTERLEAVE policy 
> gets hugepages that are relatively unbalanced across a set of nodes that I 
> arbitrarily picked, my interleave it's going to be nearly as optimized 
> compared to what userspace can allocate with the node-targeted approach: 
> allocate [desired nr of hugepages] / [nr nodes in policy] hugepages via 
> /sys/devices/system/node/node*/nr_hugepages, and construct a policy out of 
> the nodes that give a true interleave.

Except that knowledge and awareness of having to do this is pushed out
to userspace and the system administrator, when again it's something
the kernel can trivially do on their behalf.

> That's not a trivial performance 
> gain and can rarely be dismissed by simply picking an arbitrary set.
> 
> > It's likely that writing to the
> > global nr_hugepages within a mempolicy will end up with a more sensible
> > result than a userspace application dealing with the individual node-specific
> > nr_hugepages files.
> > 
> 
> Disagree for the interleave example above without complex userspace logic 
> to determine how successful hugepage allocation will be based on 
> fragmentation.
> 

It can read the value back for nr_hugepages to see was the total number
of allocation successful. hugeadm does this for example and warns when the
desired number of pages were not allocated (or not freed for that example). It
would not detect if the memory allocations were imbalanced without taking
further steps but it would depend on whether being evenly interleaved was
more important than having the maximum number of hugepages.

> > To do the same with the explicit interface, a userspace application
> > or administrator would have to keep reading the existing nr_hugepages,
> > writing existing_nr_hugepages+1 to each node in the allowed set, re-reading
> > to check for allocating failure and round-robining by hand.  This seems
> > awkward-for-the-sake-of-being-awkward when the kernel is already prefectly
> > aware of how to round-robin allocate the requested number of nodes allocating
> > more on one node if necessary.
> > 
> 
> No need for an iteration, simply allocate the ratio I specified above on 
> each node and then construct a mempolicy from those nodes based on actual 
> results instead of arbitrarily.
> 

They would still need to read back the values, determine if the full
allocation was successful and if not, figure out where it failed and
recalculate. 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
