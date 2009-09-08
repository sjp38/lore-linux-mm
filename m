Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D5EF46B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 17:41:07 -0400 (EDT)
Date: Tue, 8 Sep 2009 22:41:10 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for
	mempolicy based management.
Message-ID: <20090908214109.GB6481@csn.ul.ie>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160351.11080.21379.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031254380.26408@chino.kir.corp.google.com> <1252012158.6029.215.camel@useless.americas.hpqcorp.net> <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com> <20090908104409.GB28127@csn.ul.ie> <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com> <20090908200451.GA6481@csn.ul.ie> <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 08, 2009 at 01:18:01PM -0700, David Rientjes wrote:
> On Tue, 8 Sep 2009, Mel Gorman wrote:
> 
> > > Au contraire, the hugepages= kernel parameter is not restricted to any 
> > > mempolicy.
> > > 
> > 
> > I'm not seeing how it would be considered symmetric to compare allocation
> > at a boot-time parameter with freeing happening at run-time within a mempolicy.
> > It's more plausible to me that such a scenario will having the freeing
> > thread either with no policy or the ability to run with no policy
> > applied.
> > 
> 
> Imagine a cluster of machines that are all treated equally to serve a 
> variety of different production jobs.  One of those production jobs 
> requires a very high percentage of hugepages.  In fact, its performance 
> gain is directly proportional to the number of hugepages allocated.
> 
> It is quite plausible for all machines to be booted with hugepages= to 
> achieve the maximum number of hugepages that those machines may support.  
> Depending on what jobs they will serve, however, those hugepages may 
> immediately be freed (or a subset, depending on other smaller jobs that 
> may want them.)  If the job scheduler is bound to a mempolicy which does 
> not include all nodes with memory, those hugepages are now leaked. 

Why is a job scheduler that is expecting to affect memory on a global
basis running inside a mempolicy that restricts it to a subset of nodes?
It seems inconsistent that an isolated job starting could affect the global
state potentially affecting other jobs starting up.

In addition, if it is the case that the jobs performance is directly
proportional to the number of hugepages it gets access to, why is it starting
up with access to only a subset of the available hugepages? Why is it not
being setup to being the first job to start on a freshly booting machine,
starting on the subset of nodes allowed and requesting the maximum number
of hugepages it needs such that it achieves maximum performance? With the
memory policy approach, it's very straight-forward to do this because all
it has to do is write to nr_hugepages when it starts-up.

> That 
> was not the behavior over the past three or four years until this 
> patchset.
> 

While this is true, I know people have also been bitten by the expectation
that writing to nr_hugepages would obey a memory policy and were surprised
when it didn't happen and sent me whinging emails. It also appeared obvious
to me that it's how the interface should behave even if it wasn't doing it
in practice. Once nr_hugepages obeys memory policies, it's fairly convenient
to size the number of pages on a subset of nodes using numactl - a tool that
people would generally expect to be used when operating on nodes. Hence the
example usage being

numactl -m x,y,z hugeadm --pool-pages-min $PAGESIZE:$NUMPAGES

> That example is not dealing in hypotheticals or assumptions on how people 
> use hugepages, it's based on reality.  As I said previously, I don't 
> necessarily have an objection to that if it can be shown that the 
> advantages significantly outweigh the disadvantages.  I'm not sure I see 
> the advantage in being implict vs. explicit, however. 

The advantage is that with memory policies on nr_hugepages, it's very
convenient to allocate pages within a subset of nodes without worrying about
where exactly those huge pages are being allocated from. It will allocate
them on a round-robin basis allocating more pages on one node over another
if fragmentation requires it rather than shifting the burden to a userspace
application figuring out what nodes might succeed an allocation or shifting
the burden onto the system administrator. It's likely that writing to the
global nr_hugepages within a mempolicy will end up with a more sensible
result than a userspace application dealing with the individual node-specific
nr_hugepages files.

To do the same with the explicit interface, a userspace application
or administrator would have to keep reading the existing nr_hugepages,
writing existing_nr_hugepages+1 to each node in the allowed set, re-reading
to check for allocating failure and round-robining by hand.  This seems
awkward-for-the-sake-of-being-awkward when the kernel is already prefectly
aware of how to round-robin allocate the requested number of nodes allocating
more on one node if necessary.

> Mempolicy 
> allocation and freeing is now _implicit_ because its restricted to 
> current's mempolicy when it wasn't before, yet node-targeted hugepage 
> allocation and freeing is _explicit_ because it's a new interface and on 
> the same granularity.
> 

Arguably because the application was restricted by a memory policy, it
should not be able to operating outside of that policy and be forbidden
from writing to per-node-nr_hugepages outside the allowed set.  However,
that would appear awkward for the sake of it.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
