Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 21A496B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 23:46:23 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n963kInj027388
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 20:46:19 -0700
Received: from pzk14 (pzk14.prod.google.com [10.243.19.142])
	by spaceape11.eur.corp.google.com with ESMTP id n963kFfZ023207
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 20:46:16 -0700
Received: by pzk14 with SMTP id 14so2515282pzk.23
        for <linux-mm@kvack.org>; Mon, 05 Oct 2009 20:46:14 -0700 (PDT)
Date: Mon, 5 Oct 2009 20:46:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] nodemask: make NODEMASK_ALLOC more general
In-Reply-To: <alpine.DEB.1.10.0910021839470.11884@gentwo.org>
Message-ID: <alpine.DEB.1.00.0910052036380.17606@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910021511030.18180@chino.kir.corp.google.com> <alpine.DEB.1.10.0910021839470.11884@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009, Christoph Lameter wrote:

> > NODEMASK_ALLOC(x, m) assumes x is a type of struct, which is unnecessary.
> > It's perfectly reasonable to use this macro to allocate a nodemask_t,
> > which is anonymous, either dynamically or on the stack depending on
> > NODES_SHIFT.
> 
> There is currently only one user of NODEMASK_ALLOC which is
> NODEMASK_SCRATCH.
> 

That changes with Lee's patchset for mempolicy hugepage allocations and 
freeing, he'll be using it in generic hugetlb code.

> Can we generalize the functionality here? The macro is basically choosing
> between a slab allocation or a stack allocation depending on the
> configured system size.
> 
> NUMA_COND__ALLOC(<type>, <min numa nodes for not using stack>,
> <variablename>)
> 
> or so?
> 

I assume we could, although it would be slightly messy because we'd be 
coding a stack allocation in a macro when comparing the passed value 
against CONFIG_NODES_SHIFT.

> Its likely that one way want to allocate other structures on the stack
> that may get too big if large systems need to be supported.
> 

I don't think we currently have any examples of that other than 
nodemask_t.  We allocate arrays of length MAX_NUMNODES quite often for 
things like node_to_cpumask_map, struct bootnode, etc, but no longer on 
the stack even in NUMA emulation.  I'd be interested to see any 
non-nodemask use cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
