Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF9A6B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 07:24:44 -0400 (EDT)
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.0906240006540.16528@chino.kir.corp.google.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
	 <20090617130216.GF28529@csn.ul.ie> <1245258954.6235.58.camel@lts-notebook>
	 <alpine.DEB.2.00.0906181154340.10979@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.0906240006540.16528@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Wed, 24 Jun 2009 07:25:24 -0400
Message-Id: <1245842724.6439.19.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Ranjit Manomohan <ranjitm@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-24 at 00:11 -0700, David Rientjes wrote:
> On Thu, 18 Jun 2009, David Rientjes wrote:
> 
> > Manipulating hugepages via a nodemask seems less ideal than, as you 
> > mentioned, per-node hugepage controls, probably via 
> > /sys/kernel/system/node/node*/nr_hugepages.  This type of interface 
> > provides all the functionality that this patchset does, including hugepage 
> > allocation and freeing, but with more power to explicitly allocate and 
> > free on targeted nodes.  /proc/sys/vm/nr_hugepages would remain to 
> > round-robin the allocation (and freeing, with your patch 1/5 which I 
> > ack'd).
> > 
> > Such an interface would also automatically deal with all memory 
> > hotplug/remove issues without storing or keeping a nodemask updated.
> > 
> 
> Expanding this proposal out a little bit, we'd want all the power of the 
> /sys/kernel/mm/hugepages tunables for each node.  The best way of doing 
> that is probably to keep the current /sys/kernel/mm/hugepages directory as 
> is (already published Documentation/ABI/testing/sysfs-kernel-mm-hugepages) 
> for the system-wide hugepage state and then add individual 
> `hugepages-<size>kB' directories to each /sys/devices/system/node/node* to 
> target allocations and freeing for the per-node hugepage state.  
> Otherwise, we lack node targeted support for multiple hugepagesz= users.

David:

Nish mentioned this to me a while back when I asked about his patches.
That's one of my reasons for seeing if the simpler [IMO] nodes_allowed
would be sufficient.  I'm currently updating the nodes_allowed series
per Mel's cleanup suggestions.  I'll then prototype Mel's preferred
method of using the task's mempolicy.  I still have reservations about
this:  static huge page allocation is currently not constrained by
policy nor cpusets, and I can't tell whether the task's mempolicy was
set explicitly to contstrain the huge pages or just inherited from the
parent shell.

Next I'll also dust off Nish's old per node hugetlb control patches and
see what it task to update them for the multiple sizes.  It will look
pretty much as you suggest.  Do you have any suggestions for a boot
command line syntax to specify per node huge page counts at boot time
[assuming we still want this]?  Currently, for default huge page size,
distributed across nodes, we have:

	hugepages=<N>

I was thinking something like:

	hugepages=(node:count,...)

using the '(' as a flag for per node counts, w/o needing to prescan for
':'

Thoughts?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
