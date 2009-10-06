Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2882A6B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 23:13:39 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 05 Oct 2009 23:17:39 -0400
Message-Id: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/11] hugetlb: V9 numa control of persistent huge pages alloc/free
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 0/11 hugetlb: numa control of persistent huge pages alloc/free

Against:  2.6.31-mmotm-090925-1435 plus David Rientjes'
"nodemask: make NODEMASK_ALLOC more general" patch applied

This is V9 of a series of patches to provide control over the location
of the allocation and freeing of persistent huge pages on a NUMA
platform.   Please consider for merging into mmotm.

This series uses two mechanisms to constrain the nodes from which
persistent huge pages are allocated:  1) the task NUMA mempolicy of
the task modifying  a new sysctl "nr_hugepages_mempolicy", based on
a suggestion by Mel Gorman; and 2) a subset of the hugepages hstate
sysfs attributes have been added [in V4] to each node system device
under:

	/sys/devices/node/node[0-9]*/hugepages.

The per node attibutes allow direct assignment of a huge page
count on a specific node, regardless of the task's mempolicy or
cpuset constraints.

V5 addressed review comments -- changes described in patch descriptions.

V6 addressed more review comments, described in the patches.

V6 also included a 3 patch series that implements an enhancement suggested
by David Rientjes:   the default huge page nodes allowed mask will be the
nodes with memory rather than all on-line nodes and we will allocate per
node hstate attributes only for nodes with memory.  This requires that we
register a memory on/off-line notifier and [un]register the attributes on
transitions to/from memoryless state.

V7 addressed review comments, described in the patches, and included a
new patch, originally from Mel Gorman, to define a new vm sysctl and
sysfs global hugepages attribute "nr_hugepages_mempolicy" rather than
apply mempolicy contraints to pool adujstments via the pre-existing
"nr_hugepages".  The 3 patches to restrict hugetlb to visiting only
nodes with memory and to add/remove per node hstate attributes on
memory hotplug completed V7.

V8 reorganized the sysctl and sysfs attribute handlers to default
the nodes to default or define the nodes_allowed mask up in the
handlers and pass nodes_allowed [pointer] to set_max_huge_pages().
This cleanup was suggested by David Rientjes.  V8 also merged Mel
Gorman's "nr_hugepages_mempolicy" back into the patch to compute
nodes_allowed from mempolicy.

V8 turned out to be too large a reorg to pull off without botching
something.  V9 fixes these.  In the meantime, David Rientjes has
posted a patch to generalize NODEMASK_ALLOC.  This causes a build error
in my series.  David provided a patch to fix the build failure.  I
have included David's fixup as patch NN.  This causes V9 to depend
on David's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
