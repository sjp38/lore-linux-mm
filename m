Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD2F6B005C
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 13:52:35 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 29 Jul 2009 13:54:50 -0400
Message-Id: <20090729175450.23681.75547.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/4] hugetlb: V3 constrain allocation/free based on task mempolicy
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 0/4 hugetlb: constrain allocation/free based on task mempolicy

I'm sending these out again, slightly revised, for comparison
with a 3rd alternative for controlling where persistent huge
pages are allocated which I'll send out as a separate series.

Against:  2.6.31-rc3-mmotm-090716-1432
atop previously submitted "alloc_bootmem_huge_pages() fix"
[http://marc.info/?l=linux-mm&m=124775468226290&w=4]

This is V3 of a series of patches to constrain the allocation and
freeing of persistent huge pages using the task NUMA mempolicy of
the task modifying "nr_hugepages".  This series is based on Mel
Gorman's suggestion to use task mempolicy.  One of the benefits
of this method is that it does not *require* modification to
hugeadm(8) to use this feature.

V3 factors the "rework" of the hstate_next_node_to_{alloc|free}
functions out of the patch to derive huge pages nodes_allowed
from mempolicy, and moves it before the patch to add nodemasks
to the alloc/free functions.  See patch patch 1/4.

A couple of limitations [still] in this version:

1) I haven't implemented a boot time parameter to constrain the
   boot time allocation of huge pages.  This can be added if
   anyone feels strongly that it is required.

2) I have not implemented a per node nr_overcommit_hugepages as
   David Rientjes and I discussed earlier.  Again, this can be
   added and specific nodes can be addressed using the mempolicy
   as this series does for allocation and free.  However, after
   some experience with the libhugetlbfs test suite, specifically
   attempting to run the test suite constrained by mempolicy and
   a cpuset, I'm thinking that per node overcommit limits might
   not be such a good idea.  This would require an application
   [or the library] to sum the per node limits over the allowed
   nodes and possibly compare to global limits to determine the
   available resources.  Per cpuset limits might work better.
   This are requires more investigation, but this patch series
   doesn't seem to make things worse than they already are in
   this regard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
