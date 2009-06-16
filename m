Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1686B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 09:50:55 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 16 Jun 2009 09:52:28 -0400
Message-Id: <20090616135228.25248.22018.sendpatchset@lts-notebook>
Subject: [PATCH 0/5] Huge Pages Nodes Allowed
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Because of assymmetries in some NUMA platforms, and "interesting"
topologies emerging in the "scale up x86" world, we have need for
better control over the placement of "fresh huge pages".  A while
back Nish Aravamundan floated a series of patches to add per node
controls for allocating pages to the hugepage pool and removing
them.  Nish apparently moved on to other tasks before those patches
were accepted.  I have kept a copy of Nish's patches and have
intended to rebase and test them and resubmit.

In an [off-list] exchange with Mel Gorman, who admits to knowledge
in the huge pages area, I asked his opinion of per node controls
for huge pages and he suggested another approach:  using the mempolicy
of the task that changes nr_hugepages to constrain the fresh huge
page allocations.  I considered this approach but it seemed to me
to be a misuse of mempolicy for populating the huge pages free
pool.  Interleave policy doesn't have same "this node" semantics
that we want and bind policy would require constructing a custom
node mask for node as well as addressing OOM, which we don't want
during fresh huge page allocation.  One could derive a node mask
of allowed nodes for huge pages from the mempolicy of the task
that is modifying nr_hugepages and use that for fresh huge pages
with GFP_THISNODE.  However, if we're not going to use mempolicy
directly--e.g., via alloc_page_current() or alloc_page_vma() [with
yet another on-stack pseudo-vma :(]--I thought it cleaner to
define a "nodes allowed" nodemask for populating the [persistent]
huge pages free pool.

This patch series introduces a [per hugepage size] "sysctl",
hugepages_nodes_allowed, that specifies a nodemask to constrain
the allocation of persistent, fresh huge pages.   The nodemask
may be specified by a sysctl, a sysfs huge pages attribute and
on the kernel boot command line.  

The series includes a patch to free hugepages from the pool in a
"round robin" fashion, interleaved across all on-line nodes to
balance the hugepage pool across nodes.  Nish had a patch to do
this, too.

Together, these changes don't provide the fine grain of control
that per node attributes would.  Specifically, there is no easy
way to reduce the persistent huge page count for a specific node.
I think the degree of control provided by these patches is the
minimal necessary and sufficient for managing the persistent the
huge page pool.  However, with a bit more reorganization,  we
could implement per node controls if others would find that
useful.

For more info, see the patch descriptions and the updated kernel
hugepages documentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
