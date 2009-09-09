Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C7CC46B004F
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 12:28:02 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 09 Sep 2009 12:31:27 -0400
Message-Id: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/6] hugetlb: V6 constrain allocation/free based on task mempolicy
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 0/6 hugetlb: numa control of persistent huge pages alloc/free

Against:  2.6.31-rc7-mmotm-090827-1651

This is V6 of a series of patches to provide control over the location
of the allocation and freeing of persistent huge pages on a NUMA
platform.   Please consider V6 [patches 1-6] for merging into mmotm.

This series uses two mechanisms to constrain the nodes from which
persistent huge pages are allocated:  1) the task NUMA mempolicy of
the task modifying "nr_hugepages", based on a suggestion by Mel Gorman;
and 2) a subset of the hugepages hstate sysfs attributes have been
added [in V4] to each node system device under:

	/sys/devices/node/node[0-9]*/hugepages.

The per node attibutes allow direct assignment of a huge page
count on a specific node, regardless of the task's mempolicy or
cpuset constraints.

V5 addressed review comments -- changes described in patch descriptions.

V6 addresses more review comments, described in the patches.

Attached to V6, I'm sending a 3 patch series that implements an
enhancement suggested by David Rientjes:   the default huge page nodes
allowed mask will be the nodes with memory rather than all on-line nodes.
The "nodes with memory" state already tracks memory/node hot-plug.
Further, we will allocate per node hstate attributes only for nodes with
memory.  This requires that we register a memory on/off-line notifier
and [un]register the attributes on transitions to/from memoryless state.

Because of the interaction with memory hotplug, these 3 patches will
likely require more work and testing before merging.  The first six
patches do not depend on these 3 and, IMO, need not wait for them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
