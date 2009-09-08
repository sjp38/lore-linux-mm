Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA9E6B0085
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 18:54:40 -0400 (EDT)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n88MsiwO024822
	for <linux-mm@kvack.org>; Tue, 8 Sep 2009 15:54:44 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by zps36.corp.google.com with ESMTP id n88MsgpB001921
	for <linux-mm@kvack.org>; Tue, 8 Sep 2009 15:54:42 -0700
Received: by pzk37 with SMTP id 37so1978514pzk.26
        for <linux-mm@kvack.org>; Tue, 08 Sep 2009 15:54:42 -0700 (PDT)
Date: Tue, 8 Sep 2009 15:54:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for mempolicy
 based management.
In-Reply-To: <20090908214109.GB6481@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160351.11080.21379.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031254380.26408@chino.kir.corp.google.com> <1252012158.6029.215.camel@useless.americas.hpqcorp.net>
 <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com> <20090908104409.GB28127@csn.ul.ie> <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com> <20090908200451.GA6481@csn.ul.ie> <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com>
 <20090908214109.GB6481@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Mel Gorman wrote:

> Why is a job scheduler that is expecting to affect memory on a global
> basis running inside a mempolicy that restricts it to a subset of nodes?

Because hugepage allocation and freeing has always been on a global basis, 
there was no previous restriction.

> In addition, if it is the case that the jobs performance is directly
> proportional to the number of hugepages it gets access to, why is it starting
> up with access to only a subset of the available hugepages?

It's not, that particular job is allocated the entire machine other than 
the job scheduler.  The point is that the machine pool treats each machine 
equally so while they are all booted with hugepages=<large number>, 
machines that don't serve this application immediately free them.  If 
hugepages cannot be dynamically allocated up to a certain threshold that 
the application requires, a reboot is necessary if no other machines are 
available.

Since the only way to achieve the absolute maximum number of hugepages 
possible on a machine is through the command line, it's completely 
reasonable to use it on every boot and then subsequently free them when 
they're unnecessary.

> Why is it not
> being setup to being the first job to start on a freshly booting machine,
> starting on the subset of nodes allowed and requesting the maximum number
> of hugepages it needs such that it achieves maximum performance? With the
> memory policy approach, it's very straight-forward to do this because all
> it has to do is write to nr_hugepages when it starts-up.
> 

The job scheduler will always be the first job to start on the machine and 
it may have a mempolicy of its own.  When it attempts to free all 
hugepages allocated by the command line, it will then leak pages because 
of these changes.

Arguing that applications should always dynamically allocate their 
hugepages on their own subset of nodes when they are started is wishful 
thinking: it's much easier to allocate as many as possible on the command 
line and then free unnecessary hugepages than allocate on the mempolicy's 
nodes for the maximal number of hugepages.

> > That 
> > was not the behavior over the past three or four years until this 
> > patchset.
> > 
> 
> While this is true, I know people have also been bitten by the expectation
> that writing to nr_hugepages would obey a memory policy and were surprised
> when it didn't happen and sent me whinging emails.

Ok, but I doubt the inverse is true: people probably haven't emailed you 
letting you know that they've coded their application for hugepage 
allocations based on how the kernel has implemented it for years, so 
there's no context.  That's the population that I'm worried about (and is 
also solved by node-targeted hugepage allocation, btw).

 [ Such users who have emailed you could always use cpusets for the
   desired effect, it's not like there isn't a solution. ]

> It also appeared obvious
> to me that it's how the interface should behave even if it wasn't doing it
> in practice. Once nr_hugepages obeys memory policies, it's fairly convenient
> to size the number of pages on a subset of nodes using numactl - a tool that
> people would generally expect to be used when operating on nodes. Hence the
> example usage being
> 
> numactl -m x,y,z hugeadm --pool-pages-min $PAGESIZE:$NUMPAGES
> 

We need a new mempolicy flag, then, such as MPOL_F_HUGEPAGES to constrain 
hugepage allocation and freeing via the global tunable to such a 
mempolicy.

> The advantage is that with memory policies on nr_hugepages, it's very
> convenient to allocate pages within a subset of nodes without worrying about
> where exactly those huge pages are being allocated from. It will allocate
> them on a round-robin basis allocating more pages on one node over another
> if fragmentation requires it rather than shifting the burden to a userspace
> application figuring out what nodes might succeed an allocation or shifting
> the burden onto the system administrator.

That "burden" is usually for good reason: if my MPOL_INTERLEAVE policy 
gets hugepages that are relatively unbalanced across a set of nodes that I 
arbitrarily picked, my interleave it's going to be nearly as optimized 
compared to what userspace can allocate with the node-targeted approach: 
allocate [desired nr of hugepages] / [nr nodes in policy] hugepages via 
/sys/devices/system/node/node*/nr_hugepages, and construct a policy out of 
the nodes that give a true interleave.  That's not a trivial performance 
gain and can rarely be dismissed by simply picking an arbitrary set.

> It's likely that writing to the
> global nr_hugepages within a mempolicy will end up with a more sensible
> result than a userspace application dealing with the individual node-specific
> nr_hugepages files.
> 

Disagree for the interleave example above without complex userspace logic 
to determine how successful hugepage allocation will be based on 
fragmentation.

> To do the same with the explicit interface, a userspace application
> or administrator would have to keep reading the existing nr_hugepages,
> writing existing_nr_hugepages+1 to each node in the allowed set, re-reading
> to check for allocating failure and round-robining by hand.  This seems
> awkward-for-the-sake-of-being-awkward when the kernel is already prefectly
> aware of how to round-robin allocate the requested number of nodes allocating
> more on one node if necessary.
> 

No need for an iteration, simply allocate the ratio I specified above on 
each node and then construct a mempolicy from those nodes based on actual 
results instead of arbitrarily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
