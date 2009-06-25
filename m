Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 48B786B005A
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:21:42 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n5PJMGVU002445
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 20:22:17 +0100
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by wpaz21.hot.corp.google.com with ESMTP id n5PJMDsw030866
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 12:22:14 -0700
Received: by pxi9 with SMTP id 9so311631pxi.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 12:22:13 -0700 (PDT)
Date: Thu, 25 Jun 2009 12:22:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
In-Reply-To: <1245896060.6439.159.camel@lts-notebook>
Message-ID: <alpine.DEB.2.00.0906251155250.30090@chino.kir.corp.google.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090617130216.GF28529@csn.ul.ie> <1245258954.6235.58.camel@lts-notebook> <alpine.DEB.2.00.0906181154340.10979@chino.kir.corp.google.com> <alpine.DEB.2.00.0906240006540.16528@chino.kir.corp.google.com>
 <1245842724.6439.19.camel@lts-notebook> <alpine.DEB.2.00.0906241451460.30523@chino.kir.corp.google.com> <1245896060.6439.159.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Ranjit Manomohan <ranjitm@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jun 2009, Lee Schermerhorn wrote:

> Would having cpusets constrain huge page pool allocation meet your
> needs?
> 

It would, but it seems like an unnecessary inconvenience.  It would 
require the admin task to join a cpuset to allocate hugepages for an 
application while allocating them.  It also is more difficult to expand a 
cpuset to include a new node that has a specific threshold of hugepages 
available if writing to 
/sys/devices/system/node/node*/hugepages-<size>kB/nr_hugepages is used to 
preallocate hugepages to determine which node has the least fragmentation 
to support such an allocation in the first place (and then freeing them if 
they cannot be allocated).

It also doesn't support users who don't have CONFIG_CPUSETS, but do 
mbind their memory to a subset of nodes that need hugepages while others 
do not.

> > This could become pretty cryptic:
> > 
> > 	hugepagesz=2M hugepages=(0:10,1:20) hugepagesz=1G 	\
> > 		hugepages=(2:10,3:10)
> > 
> > and I assume we'd use `count' of 99999 for nodes of unknown sizes where we 
> > simply want to allocate as many hugepages as possible.
> 
> If one needed that capability--"allocate as many as possible"--then,
> yes, I guess any ridiculously large count would do the trick.
> 

I remember on older kernels that large hugepages= values would cause the 
system not to boot because subsequent kernel allocations would fail 
because it's oom.  We need to do hugepages= allocation as early as 
possible to avoid additional fragmentation later, but not enough to 
completely oom the kernel.  The only way to prevent that is with a 
maximum hugepage watermark (which would no longer be global but per zone 
with the hugepages=(node:count,...) support to allow at least a certain 
threshold of memory to be free to the kernel for boot.

> > We'd still need to support hugepages=N for large NUMA machines so we don't 
> > have to specify the same number of hugepages per node for a true 
> > interleave, which would require an extremely large command line.  And then 
> > the behavior of
> > 
> > 	hugepagesz=1G hugepages=(0:10,1:20) hugepages=30
> > 
> > needs to be defined.  In that case, does hugepages=30 override the 
> > previous settings if this system only has dual nodes?  If so, for SGI's 1K 
> > node systems it's going to be difficult to specify many nodes with 10 
> > hugepages and a few with 20.  So perhaps hugepages=(node:count,...) should 
> > increment or decrement the hugepages= value, if specified?
> 
> Mel mentioned that we probably don't need boot command line hugepage
> allocation all that much with lumpy reclaim, etc.  I can see his point.

Understood, especially with the complexity of specifying them on the 
command line in the first place :)  The only concern I have is for users 
who want hugepages preallocated on a specific set of nodes at boot and are 
required to use much higher hugepages= values to allocate on all system 
nodes and then just free the pages on the nodes they aren't interested in.

> If we can't allocate all the hugepages we need from an early init script
> or similar, we probably don't have enough memory anyway.  For
> compatibility, I supposed we need to retain the hugepages= parameter.
> And, we've added the hugepagesz parameter, so we need to retain that.
> But, maybe we should initially limit per node allocations to sysfs node
> attributes post boot?
> 

Agreed, it solves the early boot oom failures as well.

> -------------
> Related question:  do you think we need per node overcommit limits?

I do, because applications constrained to an exclusive cpuset will only be 
able to allocate from its set of allowable nodes anyway, so the global 
overcommit limits aren't in effect.  There needs to be a mechanism to 
allow such allocations to take place for such constrained tasks.

The only reason I've proposed these hugepage tunables to be attributes of 
the system's nodes and not attributes of the individual cpusets is because 
non-exclusive cpusets may share nodes among siblings and parents will 
always share nodes with children, so the tunables could become 
inconsistent with one another.  For all other purposes, they really are a 
characteristic of the cpuset's job, however.

> I'm
> having difficulty understanding what the semantics of the global limit
> would be with per node limits--i.e., how would one distribute the global
> limit across nodes [for backwards compatibility].  With nr_hugepages,
> today we just do a best effort to distribute the requested number of
> pages over the on-line nodes.  If we fail to allocate that many, we
> don't remember the initial request, just how many we actually allocated
> where ever they landed.  But, I don't see how that works with limits.  I
> suppose we could arrange that if you don't specify a per node limit, the
> global limit applies when attempting to allocate a surplus page on a
> given node.  If you do [so specify], then the respective node limit
> applies, whether or not the sum of per node surplus pages exceeds the
> global limit.
> 

Hmm, yes, that's a concern.  I think the easiest way to do it would be to 
respect both the global and node surplus limits when the node limit is 0, 
and respect the node surplus limit when it is positive.  The setting of 
either the global limit or the node limit does not change the other.  This 
deals with the cpuset case where applications constrained to a cpuset may 
only allocate from their own nodes.

This would allow the global limit to exceed the sum of the node limits and 
for hugepage allocation to fail, but that would have required a node limit 
to be set on each online node.  In such a situation, the global limit has, 
in effect, been obsoleted and its value no longer matters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
