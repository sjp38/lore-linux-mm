From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 30 Aug 2007 14:51:30 -0400
Message-Id: <20070830185130.22619.93436.sendpatchset@localhost>
In-Reply-To: <20070830185053.22619.96398.sendpatchset@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
Subject: [PATCH/RFC 5/5] Mem Policy:  add MPOL_F_MEMS_ALLOWED get_mempolicy() flag
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 05/05 -  add MPOL_F_MEMS_ALLOWED get_mempolicy() flag

Against:  2.6.23-rc3-mm1

Allow an application to query the memories allowed by its context.

Updated numa_memory_policy.txt to mention that applications can use this
to obtain allowed memories for constructing valid policies.

TODO:  update out-of-tree libnuma wrapper[s], or maybe add a new 
wrapper--e.g.,  numa_get_mems_allowed() ?

Tested with memtoy V>=0.13.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |   28 +++++++++++-----------------
 include/linux/mempolicy.h               |    1 +
 mm/mempolicy.c                          |   14 +++++++++++++-
 3 files changed, 25 insertions(+), 18 deletions(-)

Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-08-29 11:44:18.000000000 -0400
+++ Linux/include/linux/mempolicy.h	2007-08-29 11:45:23.000000000 -0400
@@ -26,6 +26,7 @@
 /* Flags for get_mem_policy */
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
 #define MPOL_F_ADDR	(1<<1)	/* look up vma using address */
+#define MPOL_F_MEMS_ALLOWED (1<<2) /* return allowed memories */
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-08-29 11:45:09.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-08-29 11:45:23.000000000 -0400
@@ -560,8 +560,20 @@ static long do_get_mempolicy(int *policy
 	struct mempolicy *pol = current->mempolicy;
 
 	cpuset_update_task_memory_state();
-	if (flags & ~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR))
+	if (flags &
+		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
 		return -EINVAL;
+
+	if (flags & MPOL_F_MEMS_ALLOWED) {
+		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
+			return -EINVAL;
+		*policy = 0;	/* just so it's initialized */
+		if (!nmask)
+			return -EFAULT;
+		*nmask  = cpuset_current_mems_allowed;
+		return 0;
+	}
+
 	if (flags & MPOL_F_ADDR) {
 		down_read(&mm->mmap_sem);
 		vma = find_vma_intersection(mm, addr, addr+1);
Index: Linux/Documentation/vm/numa_memory_policy.txt
===================================================================
--- Linux.orig/Documentation/vm/numa_memory_policy.txt	2007-08-29 11:44:18.000000000 -0400
+++ Linux/Documentation/vm/numa_memory_policy.txt	2007-08-29 11:45:23.000000000 -0400
@@ -294,24 +294,20 @@ MEMORY POLICIES AND CPUSETS
 
 Memory policies work within cpusets as described above.  For memory policies
 that require a node or set of nodes, the nodes are restricted to the set of
-nodes whose memories are allowed by the cpuset constraints.  If the
-intersection of the set of nodes specified for the policy and the set of nodes
-allowed by the cpuset is the empty set, the policy is considered invalid and
-cannot be installed.
+nodes whose memories are allowed by the cpuset constraints.  If the nodemask
+specified for the policy contains nodes that are not allowed by the cpuset, or
+the intersection of the set of nodes specified for the policy and the set of
+nodes with memory is the empty set, the policy is considered invalid
+and cannot be installed.
 
 The interaction of memory policies and cpusets can be problematic for a
 couple of reasons:
 
-1) the memory policy APIs take physical node id's as arguments.  However, the
-   memory policy APIs do not provide a way to determine what nodes are valid
-   in the context where the application is running.  An application MAY consult
-   the cpuset file system [directly or via an out of tree, and not generally
-   available, libcpuset API] to obtain this information, but then the
-   application must be aware that it is running in a cpuset and use what are
-   intended primarily as administrative APIs.
-
-   However, as long as the policy specifies at least one node that is valid
-   in the controlling cpuset, the policy can be used.
+1) the memory policy APIs take physical node id's as arguments.  As mentioned
+   above, it is illegal to specify nodes that are not allowed in the cpuset.
+   The application must query the allowed nodes using the get_mempolicy()
+   API with the MPOL_F_MEMS_ALLOWED flag to determine the allowed nodes and
+   restrict itself to those nodes.
 
 2) when tasks in two cpusets share access to a memory region, such as shared
    memory segments created by shmget() of mmap() with the MAP_ANONYMOUS and
@@ -321,7 +317,5 @@ couple of reasons:
    the memory policy APIs, as well as knowing in what cpusets other task might
    be attaching to the shared region, to use the cpuset information.
    Furthermore, if the cpusets' allowed memory sets are disjoint, "local"
+   allocation and "contextual interleave" are the only valid policies.
 
-Note, however, that local allocation, whether specified by MPOL_DEFAULT or
-MPOL_PREFERRED with an empty nodemask and "contextual interleave"--
-MPOL_INTERLEAVE with an empty nodemask--are valid policies in any context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
