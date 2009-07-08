Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA52F6B0055
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 15:14:52 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 08 Jul 2009 15:24:53 -0400
Message-Id: <20090708192453.20687.2317.sendpatchset@lts-notebook>
In-Reply-To: <20090708192430.20687.30157.sendpatchset@lts-notebook>
References: <20090708192430.20687.30157.sendpatchset@lts-notebook>
Subject: [PATCH 3/3] hugetlb:  update hugetlb documentation for mempolicy based management.
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 3/3 hugetlb:  update hugetlb documentation for mempolicy based management.

Against:  25jun09 mmotm atop the "balance freeing of huge pages" series

This patch updates the kernel huge tlb documentation to describe the
numa memory policy based huge page management.  Additionaly, the patch
includes a fair amount of rework to improve consistency, eliminate
duplication and set the context for documenting the memory policy
interaction.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/hugetlbpage.txt |  228 ++++++++++++++++++++++++---------------
 1 file changed, 143 insertions(+), 85 deletions(-)

Index: linux-2.6.31-rc1-mmotm-090625-1549/Documentation/vm/hugetlbpage.txt
===================================================================
--- linux-2.6.31-rc1-mmotm-090625-1549.orig/Documentation/vm/hugetlbpage.txt	2009-07-07 09:58:14.000000000 -0400
+++ linux-2.6.31-rc1-mmotm-090625-1549/Documentation/vm/hugetlbpage.txt	2009-07-07 09:58:26.000000000 -0400
@@ -11,23 +11,21 @@ This optimization is more critical now a
 (several GBs) are more readily available.
 
 Users can use the huge page support in Linux kernel by either using the mmap
-system call or standard SYSv shared memory system calls (shmget, shmat).
+system call or standard SYSV shared memory system calls (shmget, shmat).
 
 First the Linux kernel needs to be built with the CONFIG_HUGETLBFS
 (present under "File systems") and CONFIG_HUGETLB_PAGE (selected
 automatically when CONFIG_HUGETLBFS is selected) configuration
 options.
 
-The kernel built with huge page support should show the number of configured
-huge pages in the system by running the "cat /proc/meminfo" command.
+The /proc/meminfo file provides information about the total number of hugetlb
+pages preallocated in the kernel's huge page pool.  It also displays
+information about the number of free, reserved and surplus huge pages and the
+[default] huge page size.  The huge page size is needed for generating the
+proper alignment and size of the arguments to system calls that map huge page
+regions.
 
-/proc/meminfo also provides information about the total number of hugetlb
-pages configured in the kernel.  It also displays information about the
-number of free hugetlb pages at any time.  It also displays information about
-the configured huge page size - this is needed for generating the proper
-alignment and size of the arguments to the above system calls.
-
-The output of "cat /proc/meminfo" will have lines like:
+The output of "cat /proc/meminfo" will include lines like:
 
 .....
 HugePages_Total: vvv
@@ -53,26 +51,25 @@ HugePages_Surp  is short for "surplus," 
 /proc/filesystems should also show a filesystem of type "hugetlbfs" configured
 in the kernel.
 
-/proc/sys/vm/nr_hugepages indicates the current number of configured hugetlb
-pages in the kernel.  Super user can dynamically request more (or free some
-pre-configured) huge pages.
-The allocation (or deallocation) of hugetlb pages is possible only if there are
-enough physically contiguous free pages in system (freeing of huge pages is
-possible only if there are enough hugetlb pages free that can be transferred
-back to regular memory pool).
-
-Pages that are used as hugetlb pages are reserved inside the kernel and cannot
-be used for other purposes.
-
-Once the kernel with Hugetlb page support is built and running, a user can
-use either the mmap system call or shared memory system calls to start using
-the huge pages.  It is required that the system administrator preallocate
-enough memory for huge page purposes.
-
-The administrator can preallocate huge pages on the kernel boot command line by
-specifying the "hugepages=N" parameter, where 'N' = the number of huge pages
-requested.  This is the most reliable method for preallocating huge pages as
-memory has not yet become fragmented.
+/proc/sys/vm/nr_hugepages indicates the current number of huge pages pre-
+allocated in the kernel's huge page pool.  These are called "persistent"
+huge pages.  A user with root privileges can dynamically allocate more or
+free some persistent huge pages by increasing or decreasing the value of
+'nr_hugepages'.
+
+Pages that are used as huge pages are reserved inside the kernel and cannot
+be used for other purposes.  Huge pages can not be swapped out under
+memory pressure.
+
+Once a number of huge pages have been pre-allocated to the kernel huge page
+pool, a user with appropriate privilege can use either the mmap system call
+or shared memory system calls to use the huge pages.  See the discussion of
+Using Huge Pages, below
+
+The administrator can preallocate persistent huge pages on the kernel boot
+command line by specifying the "hugepages=N" parameter, where 'N' = the
+number of requested huge pages requested.  This is the most reliable method
+or preallocating huge pages as memory has not yet become fragmented.
 
 Some platforms support multiple huge page sizes.  To preallocate huge pages
 of a specific size, one must preceed the huge pages boot command parameters
@@ -80,19 +77,23 @@ with a huge page size selection paramete
 be specified in bytes with optional scale suffix [kKmMgG].  The default huge
 page size may be selected with the "default_hugepagesz=<size>" boot parameter.
 
-/proc/sys/vm/nr_hugepages indicates the current number of configured [default
-size] hugetlb pages in the kernel.  Super user can dynamically request more
-(or free some pre-configured) huge pages.
-
-Use the following command to dynamically allocate/deallocate default sized
-huge pages:
+When multiple huge page sizes are supported, /proc/sys/vm/nr_hugepages
+indicates the current number of pre-allocated huge pages of the default size.
+Thus, one can use the following command to dynamically allocate/deallocate
+default sized persistent huge pages:
 
 	echo 20 > /proc/sys/vm/nr_hugepages
 
-This command will try to configure 20 default sized huge pages in the system.
+This command will try to adjust the number of default sized huge pages in the
+huge page pool to 20, allocating or freeing huge pages, as required.
+
 On a NUMA platform, the kernel will attempt to distribute the huge page pool
-over the all on-line nodes.  These huge pages, allocated when nr_hugepages
-is increased, are called "persistent huge pages".
+over the all the nodes specified by the NUMA memory policy of the task that
+modifies nr_hugepages that contain sufficient available contiguous memory.
+These nodes are called the huge pages "allowed nodes".  The default for the
+huge pages allowed nodes--when the task has default memory policy--is all
+on-line nodes.  See the discussion below of the interaction of task memory
+policy, cpusets and persistent huge page allocation and freeing.
 
 The success or failure of huge page allocation depends on the amount of
 physically contiguous memory that is preset in system at the time of the
@@ -101,11 +102,11 @@ some nodes in a NUMA system, it will att
 allocating extra pages on other nodes with sufficient available contiguous
 memory, if any.
 
-System administrators may want to put this command in one of the local rc init
-files.  This will enable the kernel to request huge pages early in the boot
-process when the possibility of getting physical contiguous pages is still
-very high.  Administrators can verify the number of huge pages actually
-allocated by checking the sysctl or meminfo.  To check the per node
+System administrators may want to put this command in one of the local rc
+init files.  This will enable the kernel to preallocate huge pages early in
+the boot process when the possibility of getting physical contiguous pages
+is still very high.  Administrators can verify the number of huge pages
+actually allocated by checking the sysctl or meminfo.  To check the per node
 distribution of huge pages in a NUMA system, use:
 
 	cat /sys/devices/system/node/node*/meminfo | fgrep Huge
@@ -113,39 +114,40 @@ distribution of huge pages in a NUMA sys
 /proc/sys/vm/nr_overcommit_hugepages specifies how large the pool of
 huge pages can grow, if more huge pages than /proc/sys/vm/nr_hugepages are
 requested by applications.  Writing any non-zero value into this file
-indicates that the hugetlb subsystem is allowed to try to obtain "surplus"
-huge pages from the buddy allocator, when the normal pool is exhausted. As
-these surplus huge pages go out of use, they are freed back to the buddy
-allocator.
+indicates that the hugetlb subsystem is allowed to try to obtain that
+number of "surplus" huge pages from the kernel's normal page pool, when the
+persistent huge page pool is exhausted. As these surplus huge pages become
+unused, they are freed back to the kernel's normal page pool.
 
-When increasing the huge page pool size via nr_hugepages, any surplus
+When increasing the huge page pool size via nr_hugepages, any existing surplus
 pages will first be promoted to persistent huge pages.  Then, additional
 huge pages will be allocated, if necessary and if possible, to fulfill
-the new huge page pool size.
+the new persistent huge page pool size.
 
 The administrator may shrink the pool of preallocated huge pages for
 the default huge page size by setting the nr_hugepages sysctl to a
 smaller value.  The kernel will attempt to balance the freeing of huge pages
-across all on-line nodes.  Any free huge pages on the selected nodes will
-be freed back to the buddy allocator.
-
-Caveat: Shrinking the pool via nr_hugepages such that it becomes less
-than the number of huge pages in use will convert the balance to surplus
-huge pages even if it would exceed the overcommit value.  As long as
-this condition holds, however, no more surplus huge pages will be
-allowed on the system until one of the two sysctls are increased
-sufficiently, or the surplus huge pages go out of use and are freed.
+across all nodes in the memory policy of the task modifying nr_hugepages.
+Any free huge pages on the selected nodes will be freed back to the kernel's
+normal page pool.
+
+Caveat: Shrinking the persistent huge page pool via nr_hugepages such that
+it becomes less than the number of huge pages in use will convert the balance
+of the in-use huge pages to surplus huge pages.  This will occur even if
+the number of surplus pages it would exceed the overcommit value.  As long as
+this condition holds--that is, until nr_hugepages+nr_overcommit_hugepages is
+increased sufficiently, or the surplus huge pages go out of use and are freed--
+no more surplus huge pages will be allowed to be allocated.
 
 With support for multiple huge page pools at run-time available, much of
-the huge page userspace interface has been duplicated in sysfs. The above
-information applies to the default huge page size which will be
-controlled by the /proc interfaces for backwards compatibility. The root
-huge page control directory in sysfs is:
+the huge page userspace interface in /proc/sys/vm has been duplicated in sysfs.
+The /proc interfaces discussed above have been retained for backwards
+compatibility. The root huge page control directory in sysfs is:
 
 	/sys/kernel/mm/hugepages
 
 For each huge page size supported by the running kernel, a subdirectory
-will exist, of the form
+will exist, of the form:
 
 	hugepages-${size}kB
 
@@ -159,6 +161,70 @@ Inside each of these directories, the sa
 
 which function as described above for the default huge page-sized case.
 
+
+Interaction of Task Memory Policy with Huge Page Allocation/Freeing:
+
+Whether huge pages are allocated and freed via the /proc interface or
+the /sysfs interface, the NUMA nodes from which huge pages are allocated
+or freed are controlled by the NUMA memory policy of the task that modifies
+the nr_hugepages parameter.  [nr_overcommit_hugepages is a global limit.]
+
+The recommended method to allocate or free huge pages to/from the kernel
+huge page pool, using the nr_hugepages example above, is:
+
+    numactl --interleave <node-list> echo 20 >/proc/sys/vm/nr_hugepages.
+
+or, more succinctly:
+
+    numactl -m <node-list> echo 20 >/proc/sys/vm/nr_hugepages.
+
+This will allocate or free abs(20 - nr_hugepages) to or from the nodes
+specified in <node-list>, depending on whether nr_hugepages is initially
+less than or greater than 20, respectively.  No huge pages will be
+allocated nor freed on any node not included in the specified <node-list>.
+
+Any memory policy mode--bind, preferred, local or interleave--may be
+used.  The effect on persistent huge page allocation will be as follows:
+
+1) Regardless of mempolicy mode [see Documentation/vm/numa_memory_policy.txt],
+   persistent huge pages will be distributed across the node or nodes
+   specified in the mempolicy as if "interleave" had been specified.
+   However, if a node in the policy does not contain sufficient contiguous
+   memory for a huge page, the allocation will not "fallback" to the nearest
+   neighbor node with sufficient contiguous memory.  To do this would cause
+   undesirable imbalance in the distribution of the huge page pool, or
+   possibly, allocation of persistent huge pages on nodes not allowed by
+   the task's memory policy.
+
+2) One or more nodes may be specified with the bind or interleave policy.
+   If more than one node is specified with the preferred policy, only the
+   lowest numeric id will be used.  Local policy will select the node where
+   the task is running at the time the nodes_allowed mask is constructed.
+
+3) For local policy to be deterministic, the task must be bound to a cpu or
+   cpus in a single node.  Otherwise, the task could be migrated to some
+   other node at any time after launch and the resulting node will be
+   indeterminate.  Thus, local policy is not very useful for this purpose.
+   Any of the other mempolicy modes may be used to specify a single node.
+
+4) The nodes allowed mask will be derived from any non-default task mempolicy,
+   whether this policy was set explicitly by the task itself or one of its
+   ancestors, such as numactl.  This means that if the task is invoked from a
+   shell with non-default policy, that policy will be used.  One can specify a
+   node list of "all" with numactl --interleave or --membind [-m] to achieve
+   interleaving over all nodes in the system or cpuset.
+
+5) Any task mempolicy specifed--e.g., using numactl--will be constrained by
+   the resource limits of any cpuset in which the task runs.  Thus, there will
+   be no way for a task with non-default policy running in a cpuset with a
+   subset of the system nodes to allocate huge pages outside the cpuset
+   without first moving to a cpuset that contains all of the desired nodes.
+
+6) Hugepages allocated at boot time always use the node_online_map.
+
+
+Using Huge Pages:
+
 If the user applications are going to request huge pages using mmap system
 call, then it is required that system administrator mount a file system of
 type hugetlbfs:
@@ -204,9 +270,11 @@ mount of filesystem will be required for
  * requesting huge pages.
  *
  * For the ia64 architecture, the Linux kernel reserves Region number 4 for
- * huge pages.  That means the addresses starting with 0x800000... will need
- * to be specified.  Specifying a fixed address is not required on ppc64,
- * i386 or x86_64.
+ * huge pages.  That means that if one requires a fixed address, a huge page
+ * aligned address starting with 0x800000... will be required.  If a fixed
+ * address is not required, the kernel will select an address in the proper
+ * range.
+ * Other architectures, such as ppc64, i386 or x86_64 are not so constrained.
  *
  * Note: The default shared memory limit is quite low on many kernels,
  * you may need to increase it via:
@@ -235,14 +303,8 @@ mount of filesystem will be required for
 
 #define dprintf(x)  printf(x)
 
-/* Only ia64 requires this */
-#ifdef __ia64__
-#define ADDR (void *)(0x8000000000000000UL)
-#define SHMAT_FLAGS (SHM_RND)
-#else
-#define ADDR (void *)(0x0UL)
+#define ADDR (void *)(0x0UL)	/* let kernel choose address */
 #define SHMAT_FLAGS (0)
-#endif
 
 int main(void)
 {
@@ -300,10 +362,12 @@ int main(void)
  * example, the app is requesting memory of size 256MB that is backed by
  * huge pages.
  *
- * For ia64 architecture, Linux kernel reserves Region number 4 for huge pages.
- * That means the addresses starting with 0x800000... will need to be
- * specified.  Specifying a fixed address is not required on ppc64, i386
- * or x86_64.
+ * For the ia64 architecture, the Linux kernel reserves Region number 4 for
+ * huge pages.  That means that if one requires a fixed address, a huge page
+ * aligned address starting with 0x800000... will be required.  If a fixed
+ * address is not required, the kernel will select an address in the proper
+ * range.
+ * Other architectures, such as ppc64, i386 or x86_64 are not so constrained.
  */
 #include <stdlib.h>
 #include <stdio.h>
@@ -315,14 +379,8 @@ int main(void)
 #define LENGTH (256UL*1024*1024)
 #define PROTECTION (PROT_READ | PROT_WRITE)
 
-/* Only ia64 requires this */
-#ifdef __ia64__
-#define ADDR (void *)(0x8000000000000000UL)
-#define FLAGS (MAP_SHARED | MAP_FIXED)
-#else
-#define ADDR (void *)(0x0UL)
+#define ADDR (void *)(0x0UL)	/* let kernel choose address */
 #define FLAGS (MAP_SHARED)
-#endif
 
 void check_bytes(char *addr)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
