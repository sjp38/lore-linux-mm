Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 502F36B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 14:29:46 -0500 (EST)
Subject: Re: [PATCH/RFC 5/8] numa: Introduce numa_mem_id()- effective local
 memory node id
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.1003041250290.21776@router.home>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
	 <20100304170817.10606.29049.sendpatchset@localhost.localdomain>
	 <alpine.DEB.2.00.1003041250290.21776@router.home>
Content-Type: text/plain
Date: Thu, 04 Mar 2010 14:28:23 -0500
Message-Id: <1267730903.29020.64.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-03-04 at 12:52 -0600, Christoph Lameter wrote:
> On Thu, 4 Mar 2010, Lee Schermerhorn wrote:
> 
> > numa_mem_id() - returns node number of "local memory" node
> 
> Can we call that numa_nearest_node or so? 

Or "numa_local_memory_node"?  We think/hope it's the nearest one...

We'll choose something for the next respin.

> What happens if multiple nodes
> are at the same distance? 

This is handled by build_all_zonelists().  It attempts to distribute
the various nodes' zonelists to avoid multiple nodes falling back to the
same node when distances are equal--e.g., with a default SLIT.  However,
if the SLIT distances indicate that a node [A] is closer to 2 or more
other nodes [B...] than any other node, all of nodes B... will fallback
to node A.  

> Still feel unsecure about what happens if there
> are N closest nodes to M cpuless cpus. Will each of the M cpus use the
> first of the N closest nodes for allocation?

Each of the M cpus [memless, right?] will use the first node in their
respective node's zonelist.  If the cpu's node has local memory, the cpu
will allocate from there.  If the cpu's node is memoryless, the cpu will
allocate from the node that build_all_zonelists/find_next_best_node
assigned as the first node-with-memory in the cpu's node's zonelist.

I.e., the same logic all "local" mempolicy based allocations will use.

Lee


> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
