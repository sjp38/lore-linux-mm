Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 174126B004D
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 18:26:08 -0400 (EDT)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n5OMQrm2031242
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:26:54 +0100
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by zps36.corp.google.com with ESMTP id n5OMQoPQ032649
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 15:26:51 -0700
Received: by pzk41 with SMTP id 41so773941pzk.19
        for <linux-mm@kvack.org>; Wed, 24 Jun 2009 15:26:50 -0700 (PDT)
Date: Wed, 24 Jun 2009 15:26:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
In-Reply-To: <1245842724.6439.19.camel@lts-notebook>
Message-ID: <alpine.DEB.2.00.0906241451460.30523@chino.kir.corp.google.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090617130216.GF28529@csn.ul.ie> <1245258954.6235.58.camel@lts-notebook> <alpine.DEB.2.00.0906181154340.10979@chino.kir.corp.google.com> <alpine.DEB.2.00.0906240006540.16528@chino.kir.corp.google.com>
 <1245842724.6439.19.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Ranjit Manomohan <ranjitm@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jun 2009, Lee Schermerhorn wrote:

> David:
> 
> Nish mentioned this to me a while back when I asked about his patches.
> That's one of my reasons for seeing if the simpler [IMO] nodes_allowed
> would be sufficient.  I'm currently updating the nodes_allowed series
> per Mel's cleanup suggestions.

The /proc/sys/vm/hugepages_nodes_allowed support is troublesome because 
it's global and can race with other writers, such as for tasks in two 
disjoint cpusets attempting to allocate hugepages concurrently.

> I'll then prototype Mel's preferred
> method of using the task's mempolicy.

This proposal eliminates the aforementioned race, but now has the opposite 
problem: if a single task is allocating hugepages for multiple cpusets, it 
must setup the correct mempolicies to allocate (or free) for the new 
cpuset mems.

> I still have reservations about
> this:  static huge page allocation is currently not constrained by
> policy nor cpusets, and I can't tell whether the task's mempolicy was
> set explicitly to contstrain the huge pages or just inherited from the
> parent shell.
> 

Agreed.  I do think that we used to constrain hugepage allocations by 
cpuset in the past, though, when the allocation was simply done via 
alloc_pages_node().  We'd fallback to using nodes outside of 
cpuset_current_mems_allowed when the nodes were too full or fragmented.

> Next I'll also dust off Nish's old per node hugetlb control patches and
> see what it task to update them for the multiple sizes.  It will look
> pretty much as you suggest.  Do you have any suggestions for a boot
> command line syntax to specify per node huge page counts at boot time
> [assuming we still want this]?  Currently, for default huge page size,
> distributed across nodes, we have:
> 
> 	hugepages=<N>
> 
> I was thinking something like:
> 
> 	hugepages=(node:count,...)
> 
> using the '(' as a flag for per node counts, w/o needing to prescan for
> ':'
> 

The hugepages=(node:count,...) option would still need to be interleaved 
with hugepagesz= for the various sizes.  This could become pretty cryptic:

	hugepagesz=2M hugepages=(0:10,1:20) hugepagesz=1G 	\
		hugepages=(2:10,3:10)

and I assume we'd use `count' of 99999 for nodes of unknown sizes where we 
simply want to allocate as many hugepages as possible.

We'd still need to support hugepages=N for large NUMA machines so we don't 
have to specify the same number of hugepages per node for a true 
interleave, which would require an extremely large command line.  And then 
the behavior of

	hugepagesz=1G hugepages=(0:10,1:20) hugepages=30

needs to be defined.  In that case, does hugepages=30 override the 
previous settings if this system only has dual nodes?  If so, for SGI's 1K 
node systems it's going to be difficult to specify many nodes with 10 
hugepages and a few with 20.  So perhaps hugepages=(node:count,...) should 
increment or decrement the hugepages= value, if specified?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
