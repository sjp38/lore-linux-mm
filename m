Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC866B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:55:10 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id n6VJtEw3031296
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 20:55:15 +0100
Received: from pzk16 (pzk16.prod.google.com [10.243.19.144])
	by wpaz9.hot.corp.google.com with ESMTP id n6VJtAwg000912
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 12:55:12 -0700
Received: by pzk16 with SMTP id 16so1620959pzk.20
        for <linux-mm@kvack.org>; Fri, 31 Jul 2009 12:55:10 -0700 (PDT)
Date: Fri, 31 Jul 2009 12:55:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
In-Reply-To: <20090731103632.GB28766@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0907311239190.22732@chino.kir.corp.google.com>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain> <20090729181205.23716.25002.sendpatchset@localhost.localdomain> <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com> <20090731103632.GB28766@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 31 Jul 2009, Mel Gorman wrote:

> > Google is going to need this support regardless of what finally gets
> > merged into mainline, so I'm thrilled you've implemented this version.
> > 
> 
> The fact that there is a definite use case in mind lends weight to this
> approach but I want to be 100% sure that a hugetlbfs-specific interface
> is required in this case.
> 

It's not necessarily required over the mempolicy approach for allocation 
since it's quite simple to just do

	numactl --membind nodemask echo 10 >			\
		/sys/kernel/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

on the nodemask for which you want to allocate 10 additional hugepages 
(or, if node-targeted allocations are really necessary, to use
numactl --preferred node in succession to get a balanced interleave, for 
example.)

> I don't know the setup, but lets say something like the following is
> happening
> 
> 1. job scheduler creates cpuset of subset of nodes
> 2. job scheduler creates memory policy for subset of nodes
> 3. initialisation job starts, reserves huge pages. If a memory policy is
>    already in place, it will reserve them in the correct places

This is where per-node nr_hugepages attributes would be helpful.  It may 
not be possible for the desired number of hugepages to be evenly allocated 
on each node in the subset for MPOL_INTERLEAVE.

If the subset is {1, 2, 3}, for instance, it's possible to get hugepage 
quantities on those nodes as {10, 5, 10}.  The preferred userspace 
solution may be to either change its subset of the cpuset nodes to 
allocate 10 hugepages on another node and not use node 2, or to deallocate 
hugepages on nodes 1 and 3 so it matches node 2.

With the per-node nr_hugepages attributes, that's trivial.  With the 
mempolicy based approach, you'd need to do this (I guess):

 - to change the subset of cpuset nodes: construct a mempolicy of
   MPOL_PREFERRED on node 2, deallocate via the global nr_hugepages file,
   select (or allocate) another cpuset node, construct another mempolicy
   of MPOL_PREFERRED on that new node, allocate, check, reiterate, and

 - to deallocate on nodes 1 and 3: construct a mempolicy of MPOL_BIND on
   nodes 1 and 3, deallocate via the global nr_hugepages.

I'm not sure at the moment that mempolicies work in freeing hugepages via 
/sys/kernel/mm/hugepages/*/nr_hugepags and it isn't simply a round-robin, 
so the second solution may not even work.

> 4. Job completes
> 5. job scheduler frees the pages reserved for the job freeing up pages
>    on the subset of nodes
> 
> i.e. if the job scheduler already has a memory policy of it's own, or
> even some child process of that job scheduler, it should just be able to
> set nr_hugepages and have them reserved on the correct nodes.
> 

Right, allocation is simple with the mempolicy based approach, but given 
the fact that hugepages are not always successfully allocated to what 
userspace wants and freeing is more difficult, it's easier to use per-node 
controls.

> With the per-node-attribute approach, little stops a process going
> outside of it's subset of allowed nodes.
> 

If you are allowed the capability to allocate system-wide resources for 
hugepages (and you can change your own mempolicy to MPOL_DEFAULT whenever 
you want, of course), that doesn't seem like an issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
