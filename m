Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB136B0088
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 14:09:26 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 29 Jul 2009 14:11:39 -0400
Message-Id: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/4] hugetlb: V1 Per Node Hugepages attributes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 0/4  V1 Add Per Node Hugepages Attributes

Against:  2.6.31-rc3-mmotm-090716-1432
atop the previously posted alloc_bootmem_hugepages fix.
[http://marc.info/?l=linux-mm&m=124775468226290&w=4]

This is V1 of a third alternative for controlling allocation of
persistent huge pages on a NUMA system.  [Prior alternatives were
separate "hugepages_nodes_allowed" mask and mempolicy-based mask.]
This series implements a per node, per huge pages size, read/write
attribute--nr_hugepages--to query and modify the persistent huge
pages on a specific node.  The series also implements read only
attributes to query free_huge_pages and surplus_free_pages.

This implementation continues to pass the libhugetlbfs functional test
suite.

Some issues/limitations with this series:

1) The series includes a rework/cleanup patch from the "mempolicy-
   based" huge pages series.  I think this rework is worth doing
   which ever method we chose for controlling per node huge pages.

2) The series extends the struct kobject with a private bit field
   to aid the correlation of kobjects with the global or per node
   hstate attributes.  This is not absolutely required, but did 
   simplify the back mapping of kobjects to subsystem objects.

3) The reserved and overcommit counts remain global.  This seems to
   be the most straightforward usage, even in the context of per node
   persistent huge page attributes.  Global reserve and overcommit
   values allow mempolicy to be applied to the huge page allocation
   to satisfy a page fault.  [Some work appears to be needed in
   the per cpuset overcommit limit and reserve accounting, but
   outside of the scope of this series.]

4) This series does not implement a boot command line parameter to
   control per node allocations.  This could be added if needed.

5) Using this method--per node attributes--to control persistent
   huge page allocation will require enhancments to hugeadm, 
   including a new command line syntax for specifying specific
   nodes if we wish to avoid direct accessing of the attributes.

6) I have yet to update the hugetlbfs doc for this alternative.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
