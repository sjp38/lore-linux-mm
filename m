Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 574716B006A
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 12:21:30 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 08 Oct 2009 12:25:33 -0400
Message-Id: <20091008162533.23192.71981.sendpatchset@localhost.localdomain>
In-Reply-To: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
Subject: [PATCH 6/12] hugetlb:  add generic definition of NUMA_NO_NODE
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 6/12] - hugetlb:  promote NUMA_NO_NODE to generic constant

Move definition of NUMA_NO_NODE from ia64 and x86_64 arch specific
headers to generic header 'linux/numa.h' for use in generic code.
NUMA_NO_NODE replaces bare '-1' where it's used in this series to
indicate "no node id specified".  Ultimately, it can be used
to replace the -1 elsewhere where it is used similarly.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Andi Kleen <andi@firstfloor.org>

---

Against:  2.6.31-mmotm-090925-1435

New in V7 of series

V10  + move include of numa.h outside of #ifdef CONFIG_NUMA in
       x86 topology.h header to preserve visibility of NUMA_NO_NODE.
	[suggested by David Rientjes]

 arch/ia64/include/asm/numa.h    |    2 --
 arch/x86/include/asm/topology.h |    9 +++++++--
 include/linux/numa.h            |    2 ++
 3 files changed, 9 insertions(+), 4 deletions(-)

Index: linux-2.6.31-mmotm-090925-1435/arch/ia64/include/asm/numa.h
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/arch/ia64/include/asm/numa.h	2009-10-07 12:31:51.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/arch/ia64/include/asm/numa.h	2009-10-07 12:32:00.000000000 -0400
@@ -22,8 +22,6 @@
 
 #include <asm/mmzone.h>
 
-#define NUMA_NO_NODE	-1
-
 extern u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 extern pg_data_t *pgdat_list[MAX_NUMNODES];
Index: linux-2.6.31-mmotm-090925-1435/arch/x86/include/asm/topology.h
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/arch/x86/include/asm/topology.h	2009-10-07 12:31:51.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/arch/x86/include/asm/topology.h	2009-10-07 12:32:00.000000000 -0400
@@ -35,11 +35,16 @@
 # endif
 #endif
 
-/* Node not present */
-#define NUMA_NO_NODE	(-1)
+/*
+ * to preserve the visibility of NUMA_NO_NODE definition,
+ * moved to there from here.  May be used independent of
+ * CONFIG_NUMA.
+ */
+#include <linux/numa.h>
 
 #ifdef CONFIG_NUMA
 #include <linux/cpumask.h>
+
 #include <asm/mpspec.h>
 
 #ifdef CONFIG_X86_32
Index: linux-2.6.31-mmotm-090925-1435/include/linux/numa.h
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/include/linux/numa.h	2009-10-07 12:31:51.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/include/linux/numa.h	2009-10-07 12:32:00.000000000 -0400
@@ -10,4 +10,6 @@
 
 #define MAX_NUMNODES    (1 << NODES_SHIFT)
 
+#define	NUMA_NO_NODE	(-1)
+
 #endif /* _LINUX_NUMA_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
