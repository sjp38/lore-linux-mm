Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l9PNfNKp004624
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 19:41:23 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l9PNfMr8025136
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 19:41:22 -0400
Received: from bernoulli.boston.redhat.com (bernoulli.boston.redhat.com [172.16.81.92])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id l9PNfABv018654
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 19:41:20 -0400
Message-ID: <4721298C.60504@redhat.com>
Date: Thu, 25 Oct 2007 19:41:00 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Toward a generic pooled buddy allocator
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hey folks --

	In a brief moment of either clarity or insanity, I came up with a possible 
solution, or rather a framework for a solution, to several different memory 
management problems.  The current buddy allocator divides the system into nodes 
(if NUMA) and divides those nodes into zones, which may overlap, which can cause 
headaches, and isn't as flexible as we'd sometimes like it to be, particularly 
when dealing with strange hardware or attempting to optimize for unusual memory 
topologies.

	I would like to treat nodes and zones as special cases of more generic physical 
memory pools.  By giving physical memory pools various properties (node mask, 
cpu mask, permissions, priority, owner, etc.) we get more flexibility and also 
shrink the problem size of many specific memory management tasks on large 
systems.  By keeping them exclusive of each other, and allowing pages or groups 
of pages to be moved between them when necessary, we reduce the amount of 
locking necessary for common-case operations.  Several problems come to mind as 
things that this could help:

1)	special DMA rules

There are many devices which can DMA to 64-bit addresses, but only if 32 bits 
(or 34, or 26, etc.) are the same at any given time.  If, at module load time, a 
driver can look for an existing dma pool that follows its rules, or create a new 
one if necessary, driver writers will have a lot more flexibility.

2)	DMA NUMA locality

If I have a 4-node NUMA box with legacy I/O attached to node 0, RAID controller 
attached node 1, network controller attached to node 2, and FC HBA attached to 
node 3, I want them each to be DMAing to the closest memory.  There is currently 
no framework to ensure this.

3)	preallocation

There are plenty of circumstances in which users want to set aside a pool of 
memory for one particular purpose, and to do this at boot time.  At present we 
have vm.nr_hugepages, which is userspace-only and suitable only for limited 
applications.

4)	containers

This should be obvious.

5)	NUMA page replication

Replicating pages across multiple nodes requires coordinated allocation on 
multiple nodes, something that is not at all straightforward with the current 
NUMA allocator.  A similar strategy would make NUMA migration relatively 
straightforward, even without using swap.

6)	NUMA allocation policies

If a system is running a workload with multiple different numactl memory 
policies, the task of optimally allocating pages starts to look like a knapsack 
problem, which we do not want the kernel in the business of trying to solve. 
These sorts of configurations, typical in HPC, are generally hand-tuned, so we 
should let the application/administrator tweak allocations between these pools 
explicitly with the knowledge they have of how the application behaves.

7)	realtime

Currently, many realtime applications try to use hugetlbfs whenever possible to 
minimize VM overhead and variability.  Unfortunately, hugetlbfs is not very 
convenient, and using the regular VM sucks for some realtime work. 
Configurable, resizable, prioritized realtime memory pools would solve this problem.

8)	embedded

So far, most of what I've been talking about has been about scaling up, not 
down.  If we do it right (and I think we can) we can eliminate the overhead of 
the scale-up code at compile time or dynamically at boot time.  Embedded 
developers like to carefully manage their resources, since they are so precious. 
  If we put memory pool management in the kernel with some userspace hooks, 
embedded developers won't need to rely so much on heavily-customized kernel 
patches, libc re-implementations, etc.  There are a lot of excellent performance 
engineers in the embedded world, and I'd really like them doing more work on the 
same piece of code that powers my desktop.

9)	{anti,de}-fragmentation

By tracking the utilization of large memory chunks (say, MAX_ORDER) we can tell 
which ones would be cheapest to reclaim to satisfy large physically contiguous 
allocations.  Moreover, by segregating this tracking into multiple pools with 
different properties, we can avoid wasting cycles on unreclaimable memory, and 
delay wasting cycles on expensively-reclaimable memory until we absolutely need to.

10)	paravirtualization

At present, paravirt implementations either use locked, dedicated RAM for guest 
memory, which is fast but not space-efficient, or make normal virtual 
allocations and let the host VM sort it out, which is space-efficient but can be 
very slow.  A hybrid approach would allow the host to provide a guest with a 
chunk of guaranteed-fast memory for critical stuff, while still allowing it to 
use as much capacity as is available when other guests are idle.  This would be 
particularly good if the guest was also equipped with generic physical memory 
pool support.

	I recognize that what I'm suggesting may sound like a radical change, but it 
need not be.  My intention is to add the framework and move the existing 
architecture inside it, and then gradually start using it to do new things that 
can't be done with the current allocator.  I would very much like feedback now 
before I start experimenting with this, because my knowledge in this area of OS 
design is more academic than practical, and I will invariably do stupid things 
and reinvent many wheels if I work on this in a vacuum until I submit a 
thousand-line patch.  In particular, comments on things I should *not* do would 
be most welcome.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
