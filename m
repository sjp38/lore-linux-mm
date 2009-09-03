Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 66AFC6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 17:25:57 -0400 (EDT)
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n83LQ12I005485
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 14:26:01 -0700
Received: from pxi39 (pxi39.prod.google.com [10.243.27.39])
	by zps78.corp.google.com with ESMTP id n83LPk2Z008021
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 14:25:59 -0700
Received: by pxi39 with SMTP id 39so191617pxi.8
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 14:25:59 -0700 (PDT)
Date: Thu, 3 Sep 2009 14:25:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for mempolicy
 based management.
In-Reply-To: <1252012158.6029.215.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160351.11080.21379.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031254380.26408@chino.kir.corp.google.com>
 <1252012158.6029.215.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009, Lee Schermerhorn wrote:

> > > @@ -53,26 +51,25 @@ HugePages_Surp  is short for "surplus,"
> > >  /proc/filesystems should also show a filesystem of type "hugetlbfs" configured
> > >  in the kernel.
> > >  
> > > -/proc/sys/vm/nr_hugepages indicates the current number of configured hugetlb
> > > -pages in the kernel.  Super user can dynamically request more (or free some
> > > -pre-configured) huge pages.
> > > -The allocation (or deallocation) of hugetlb pages is possible only if there are
> > > -enough physically contiguous free pages in system (freeing of huge pages is
> > > -possible only if there are enough hugetlb pages free that can be transferred
> > > -back to regular memory pool).
> > > -
> > > -Pages that are used as hugetlb pages are reserved inside the kernel and cannot
> > > -be used for other purposes.
> > > -
> > > -Once the kernel with Hugetlb page support is built and running, a user can
> > > -use either the mmap system call or shared memory system calls to start using
> > > -the huge pages.  It is required that the system administrator preallocate
> > > -enough memory for huge page purposes.
> > > -
> > > -The administrator can preallocate huge pages on the kernel boot command line by
> > > -specifying the "hugepages=N" parameter, where 'N' = the number of huge pages
> > > -requested.  This is the most reliable method for preallocating huge pages as
> > > -memory has not yet become fragmented.
> > > +/proc/sys/vm/nr_hugepages indicates the current number of huge pages pre-
> > > +allocated in the kernel's huge page pool.  These are called "persistent"
> > > +huge pages.  A user with root privileges can dynamically allocate more or
> > > +free some persistent huge pages by increasing or decreasing the value of
> > > +'nr_hugepages'.
> > > +
> > 
> > So they're not necessarily "preallocated" then if they're already in use.
> 
> I don't see what in the text you're referring to"  "preallocated" vs
> "already in use" ???
> 

Your new line, "/proc/sys/vm/nr_hugepages indicates the current number of 
huge pages preallocated in the kernel's huge page pool" doesn't seem 
correct since pages are not "pre"-allocated if they are used by an 
application.  Preallocation is only when pages are allocated for a 
performance optimization in a later hotpath (such as in a slab allocator) 
or when the allocation cannot be done later in a non-blocking context.  If 
you were to remove "pre" from that line it would be clear.

> > Not sure if you need to spell out that they're called "huge page allowed 
> > nodes," isn't that an implementation detail?  The way Paul Jackson used to 
> > describe nodes_allowed is "set of allowable nodes," and I can't think of a 
> > better phrase.  That's also how the cpuset documentation describes them.
> 
> I wanted to refer to "huge pages allowed nodes" to differentiate from,
> e.g., cpusets mems_allowed"--i.e., I wanted the "huge pages" qualifier.
> I suppose I could introduce the phrase you suggest:  "set of allowable
> nodes" and emphasize that in this doc, it only refers to nodes from
> which persistent huge pages will be allocated.
> 

It's a different story if you want to use the phrase "allowed nodes" 
throughout this document to mean "the set of allowed nodes from which to 
allocate hugepages depending on the allocating task's mempolicy," but I 
didn't see any future reference to that phrase in your changes anyway.

> I understand.  However, I do think it's useful to support both a mask
> [and Mel prefers it be based on mempolicy] and per node attributes.  On
> some of our platforms, we do want explicit control over the placement of
> huge pages--e.g., for a data base shared area or such.  So, we can say,
> "I need <N> huge pages, and I want them on nodes 1, 3, 4 and 5", and
> then, assuming we start with no huge pages allocated [free them all if
> this is not the case]:
> 
> 	numactl -m 1,3-5 hugeadm --pool-pages-min 2M:<N>
> 
> Later, if I decide that maybe I want to adjust the number on node 1, I
> can:
> 
> 	numactl -m 1 --pool-pages-min 2M:{+|-}<count>
> 
> or:
> 
> 	echo <new-value> >/sys/devices/system/node/node1/hugepages/hugepages-2048KB/nr_hugepages
> 
> [Of course, I'd probably do this in a script to avoid all that typing :)]
> 

Yes, but the caveat I'm pointing out (and is really clearly described in 
your documentation changes here) is that existing applications, shell 
scripts, job schedulers, whatever, which currently free all system 
hugepages (or do so at a consistent interval down to the surplus 
value to reclaim memory) will now leak disjoint pages since the freeing is 
now governed by its mempolicy.  If the benefits of doing this 
significantly outweigh that potential for userspace breakage, I have no 
objection to it.  I just can't say for certain that it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
