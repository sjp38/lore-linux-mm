Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9096B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 22:14:11 -0400 (EDT)
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.0906241451460.30523@chino.kir.corp.google.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
	 <20090617130216.GF28529@csn.ul.ie> <1245258954.6235.58.camel@lts-notebook>
	 <alpine.DEB.2.00.0906181154340.10979@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.0906240006540.16528@chino.kir.corp.google.com>
	 <1245842724.6439.19.camel@lts-notebook>
	 <alpine.DEB.2.00.0906241451460.30523@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Wed, 24 Jun 2009 22:14:20 -0400
Message-Id: <1245896060.6439.159.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Ranjit Manomohan <ranjitm@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-24 at 15:26 -0700, David Rientjes wrote:
> On Wed, 24 Jun 2009, Lee Schermerhorn wrote:
> 
> > David:
> > 
> > Nish mentioned this to me a while back when I asked about his patches.
> > That's one of my reasons for seeing if the simpler [IMO] nodes_allowed
> > would be sufficient.  I'm currently updating the nodes_allowed series
> > per Mel's cleanup suggestions.
> 
> The /proc/sys/vm/hugepages_nodes_allowed support is troublesome because 
> it's global and can race with other writers, such as for tasks in two 
> disjoint cpusets attempting to allocate hugepages concurrently.

Agreed.  If one has multiple administrators or privileged tasks trying
to modify the huge page pool simultaneously, this is problematic.  For
"single administrator" system, it might be workable.  And it seemed a
fairly minimal change at a time where I didn't see much interest in this
area in the community.

> 
> > I'll then prototype Mel's preferred
> > method of using the task's mempolicy.
> 
> This proposal eliminates the aforementioned race, but now has the opposite 
> problem: if a single task is allocating hugepages for multiple cpusets, it 
> must setup the correct mempolicies to allocate (or free) for the new 
> cpuset mems.

Agreed.  To support this proposal, we'll need to construct a "nodes
allowed" mask from the policy [and I don't think we want default policy
to mean "local" in this case--big change in behavior!] and pass that to
the allocation functions.  Racing allocators can then use different
masks.

> 
> > I still have reservations about
> > this:  static huge page allocation is currently not constrained by
> > policy nor cpusets, and I can't tell whether the task's mempolicy was
> > set explicitly to contstrain the huge pages or just inherited from the
> > parent shell.
> > 
> 
> Agreed.  I do think that we used to constrain hugepage allocations by 
> cpuset in the past, though, when the allocation was simply done via 
> alloc_pages_node().  We'd fallback to using nodes outside of 
> cpuset_current_mems_allowed when the nodes were too full or fragmented.

I do recall a discussion about huge page allocation being constrained by
cpusets or not.  I don't recall whether they were and this was changed,
or they weren't [as is currently the case] and someone [Nish?] proposed
to change that.  I'd need to search for that exchange.  

Would having cpusets constrain huge page pool allocation meet your
needs?

> 
> > Next I'll also dust off Nish's old per node hugetlb control patches and
> > see what it task to update them for the multiple sizes.  It will look
> > pretty much as you suggest.  Do you have any suggestions for a boot
> > command line syntax to specify per node huge page counts at boot time
> > [assuming we still want this]?  Currently, for default huge page size,
> > distributed across nodes, we have:
> > 
> > 	hugepages=<N>
> > 
> > I was thinking something like:
> > 
> > 	hugepages=(node:count,...)
> > 
> > using the '(' as a flag for per node counts, w/o needing to prescan for
> > ':'
> > 
> 
> The hugepages=(node:count,...) option would still need to be interleaved 
> with hugepagesz= for the various sizes.  

Well, yes.  I'd assumed that.  


> This could become pretty cryptic:
> 
> 	hugepagesz=2M hugepages=(0:10,1:20) hugepagesz=1G 	\
> 		hugepages=(2:10,3:10)
> 
> and I assume we'd use `count' of 99999 for nodes of unknown sizes where we 
> simply want to allocate as many hugepages as possible.

If one needed that capability--"allocate as many as possible"--then,
yes, I guess any ridiculously large count would do the trick.

> 
> We'd still need to support hugepages=N for large NUMA machines so we don't 
> have to specify the same number of hugepages per node for a true 
> interleave, which would require an extremely large command line.  And then 
> the behavior of
> 
> 	hugepagesz=1G hugepages=(0:10,1:20) hugepages=30
> 
> needs to be defined.  In that case, does hugepages=30 override the 
> previous settings if this system only has dual nodes?  If so, for SGI's 1K 
> node systems it's going to be difficult to specify many nodes with 10 
> hugepages and a few with 20.  So perhaps hugepages=(node:count,...) should 
> increment or decrement the hugepages= value, if specified?

Mel mentioned that we probably don't need boot command line hugepage
allocation all that much with lumpy reclaim, etc.  I can see his point.
If we can't allocate all the hugepages we need from an early init script
or similar, we probably don't have enough memory anyway.  For
compatibility, I supposed we need to retain the hugepages= parameter.
And, we've added the hugepagesz parameter, so we need to retain that.
But, maybe we should initially limit per node allocations to sysfs node
attributes post boot?

-------------
Related question:  do you think we need per node overcommit limits?  I'm
having difficulty understanding what the semantics of the global limit
would be with per node limits--i.e., how would one distribute the global
limit across nodes [for backwards compatibility].  With nr_hugepages,
today we just do a best effort to distribute the requested number of
pages over the on-line nodes.  If we fail to allocate that many, we
don't remember the initial request, just how many we actually allocated
where ever they landed.  But, I don't see how that works with limits.  I
suppose we could arrange that if you don't specify a per node limit, the
global limit applies when attempting to allocate a surplus page on a
given node.  If you do [so specify], then the respective node limit
applies, whether or not the sum of per node surplus pages exceeds the
global limit.

Thoughts?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
