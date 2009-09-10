Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4046B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 10:26:25 -0400 (EDT)
Subject: Re: [PATCH 5/6] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090910123233.GB31153@csn.ul.ie>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
	 <20090909163158.12963.49725.sendpatchset@localhost.localdomain>
	 <20090910123233.GB31153@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 10 Sep 2009 10:26:14 -0400
Message-Id: <1252592774.6947.163.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-10 at 13:32 +0100, Mel Gorman wrote:
> On Wed, Sep 09, 2009 at 12:31:58PM -0400, Lee Schermerhorn wrote:
> > [PATCH 5/6] hugetlb:  register per node hugepages attributes
> > 
> > V6:  + Use NUMA_NO_NODE for unspecified node id throughout hugetlb.c
> >        to indicate that we didn't get there via a per node attribute.
> >        Drop redundant "NO_NODEID_SPECIFIED" definition.
> >      + handle movement of defaulting of nodes_allowed up to
> >        set_max_huge_pages()
> > 
> 
> ppc64 doesn't define NUMA_NO_NODE so this fails to build. Maybe move the
> definition to include/linux/node.h as a pre-requisite patch?


Rats!  should have looked before I leaped.  Only ia64 and x86_64 define
NUMA_NO_NODE, both in arch dependent code, and in different headers to
boot.  I don't think node.h is the right place.  The ia64/x86_64 arch
code uses it for acpi and cpu management.  How about <linux/numa.h>?
It's currently a minimal header with no external dependencies.  The ia64
numa.h [where NUMA_NO_NODE is defined] already includes it, and the
x86_64 can include it.

This patch, inserted before the subject patch [for bisect-ability],
seems to work on x86_64.  Can you try it on ppc?

------------------

PATCH 5/7 - hugetlb:  promote NUMA_NO_NODE to generic constant

Against:  2.6.31-rc7-mmotm-090827-1651

Move definition of NUMA_NO_NODE from ia64 and x86_64 arch specific
headers to generic header 'linux/numa.h' for use in generic code.
NUMA_NO_NODE replaces bare '-1' where it's used in this series to
indicate "no node id specified".  Ultimately, it can be used
to replace the -1 elsewhere where it is used similarly.

Note that in arch/x86/include/asm/topology.h, NUMA_NO_NODE is
now only defined when CONFIG_NUMA is defined.  This seems to work
for current usage of NUMA_NO_NODE in x86_64 arch code, with or
without CONFIG_NUMA defined.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 arch/ia64/include/asm/numa.h    |    2 --
 arch/x86/include/asm/topology.h |    5 ++---
 include/linux/numa.h            |    2 ++
 3 files changed, 4 insertions(+), 5 deletions(-)

Index: linux-2.6.31-rc7-mmotm-090827-1651/arch/ia64/include/asm/numa.h
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/arch/ia64/include/asm/numa.h	2009-06-09 23:05:27.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/arch/ia64/include/asm/numa.h	2009-09-10 08:57:40.000000000 -0400
@@ -22,8 +22,6 @@
 
 #include <asm/mmzone.h>
 
-#define NUMA_NO_NODE	-1
-
 extern u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 extern pg_data_t *pgdat_list[MAX_NUMNODES];
Index: linux-2.6.31-rc7-mmotm-090827-1651/arch/x86/include/asm/topology.h
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/arch/x86/include/asm/topology.h	2009-09-09 10:05:28.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/arch/x86/include/asm/topology.h	2009-09-10 09:07:04.000000000 -0400
@@ -35,11 +35,10 @@
 # endif
 #endif
 
-/* Node not present */
-#define NUMA_NO_NODE	(-1)
-
 #ifdef CONFIG_NUMA
 #include <linux/cpumask.h>
+#include <linux/numa.h>
+
 #include <asm/mpspec.h>
 
 #ifdef CONFIG_X86_32
Index: linux-2.6.31-rc7-mmotm-090827-1651/include/linux/numa.h
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-1651.orig/include/linux/numa.h	2009-09-04 08:47:02.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-1651/include/linux/numa.h	2009-09-10 09:00:10.000000000 -0400
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
