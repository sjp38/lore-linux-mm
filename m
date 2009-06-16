Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A9C226B005C
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 09:51:54 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 16 Jun 2009 09:53:15 -0400
Message-Id: <20090616135315.25248.7893.sendpatchset@lts-notebook>
In-Reply-To: <20090616135228.25248.22018.sendpatchset@lts-notebook>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
Subject: [PATCH 5/5] Update huge pages kernel documentation
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 5/5 - update huge pages kernel documentation

Against:  17may09 mmotm

Add description of nodes_allowed sysctl and boot parameter and
adjust surrounding context to accommodate the description.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/hugetlbpage.txt |  105 ++++++++++++++++++++++++++++-----------
 1 file changed, 77 insertions(+), 28 deletions(-)

Index: linux-2.6.30-rc8-mmotm-090603-1633/Documentation/vm/hugetlbpage.txt
===================================================================
--- linux-2.6.30-rc8-mmotm-090603-1633.orig/Documentation/vm/hugetlbpage.txt	2009-06-04 11:05:11.000000000 -0400
+++ linux-2.6.30-rc8-mmotm-090603-1633/Documentation/vm/hugetlbpage.txt	2009-06-04 12:59:52.000000000 -0400
@@ -18,13 +18,13 @@ First the Linux kernel needs to be built
 automatically when CONFIG_HUGETLBFS is selected) configuration
 options.
 
-The kernel built with hugepage support should show the number of configured
-hugepages in the system by running the "cat /proc/meminfo" command.
+The kernel built with huge page support should show the number of configured
+huge pages in the system by running the "cat /proc/meminfo" command.
 
 /proc/meminfo also provides information about the total number of hugetlb
 pages configured in the kernel.  It also displays information about the
 number of free hugetlb pages at any time.  It also displays information about
-the configured hugepage size - this is needed for generating the proper
+the configured huge page size - this is needed for generating the proper
 alignment and size of the arguments to the above system calls.
 
 The output of "cat /proc/meminfo" will have lines like:
@@ -37,25 +37,23 @@ HugePages_Surp:  yyy
 Hugepagesize:    zzz kB
 
 where:
-HugePages_Total is the size of the pool of hugepages.
-HugePages_Free is the number of hugepages in the pool that are not yet
-allocated.
-HugePages_Rsvd is short for "reserved," and is the number of hugepages
-for which a commitment to allocate from the pool has been made, but no
-allocation has yet been made. It's vaguely analogous to overcommit.
-HugePages_Surp is short for "surplus," and is the number of hugepages in
-the pool above the value in /proc/sys/vm/nr_hugepages. The maximum
-number of surplus hugepages is controlled by
-/proc/sys/vm/nr_overcommit_hugepages.
+HugePages_Total is the size of the pool of huge pages.
+HugePages_Free  is the number of huge pages in the pool that are not yet
+                allocated.
+HugePages_Rsvd  is short for "reserved," and is the number of huge pages for
+                which a commitment to allocate from the pool has been made,
+                but no allocation has yet been made. It's vaguely analogous
+                to overcommit.
+HugePages_Surp  is short for "surplus," and is the number of huge pages in
+                the pool above the value in /proc/sys/vm/nr_hugepages. The
+                maximum number of surplus huge pages is controlled by
+                /proc/sys/vm/nr_overcommit_hugepages.
 
 /proc/filesystems should also show a filesystem of type "hugetlbfs" configured
 in the kernel.
 
-/proc/sys/vm/nr_hugepages indicates the current number of configured hugetlb
-pages in the kernel.  Super user can dynamically request more (or free some
-pre-configured) hugepages.
 The allocation (or deallocation) of hugetlb pages is possible only if there are
-enough physically contiguous free pages in system (freeing of hugepages is
+enough physically contiguous free pages in system (freeing of huge pages is
 possible only if there are enough hugetlb pages free that can be transferred
 back to regular memory pool).
 
@@ -67,26 +65,76 @@ use either the mmap system call or share
 the huge pages.  It is required that the system administrator preallocate
 enough memory for huge page purposes.
 
-Use the following command to dynamically allocate/deallocate hugepages:
+The administrator can preallocate huge pages on the kernel boot command line by
+specifying the "hugepages=N" parameter, where 'N' = the number of huge pages
+requested.  This is the most reliable method for preallocating huge pages as
+memory has not yet become fragmented.
+
+Some platforms support multiple huge page sizes.  To preallocate huge pages
+of a specific size, one must preceed the huge pages boot command parameters
+with a huge page size selection parameter "hugepagesz=<size>".  <size> must
+be specified in bytes with optional scale suffix [kKmMgG].  The default huge
+page size may be selected with the "default_hugepagesz=<size>" boot parameter.
+
+/proc/sys/vm/nr_hugepages indicates the current number of configured [default
+size] hugetlb pages in the kernel.  Super user can dynamically request more
+(or free some pre-configured) hugepages.
+
+Use the following command to dynamically allocate/deallocate default sized
+hugepages:
 
 	echo 20 > /proc/sys/vm/nr_hugepages
 
-This command will try to configure 20 hugepages in the system.  The success
-or failure of allocation depends on the amount of physically contiguous
-memory that is preset in system at this time.  System administrators may want
-to put this command in one of the local rc init files.  This will enable the
-kernel to request huge pages early in the boot process (when the possibility
-of getting physical contiguous pages is still very high). In either
-case, administrators will want to verify the number of hugepages actually
-allocated by checking the sysctl or meminfo.
+This command will try to configure 20 default sized hugepages in the system.
+On a NUMA platform, the kernel will attempt to distribute the hugepage pool
+over the nodes specified by the /proc/sys/vm/hugepages_nodes_allowed node mask.
+hugepages_nodes_allowed defaults to all on-line nodes.
+
+To control the nodes on which huge pages are preallocated, the administrator
+may set the hugepages_nodes_allowed for the default huge page size using:
+
+	echo <nodelist> >/proc/sys/vm/hugepages_nodes_allowed
+
+where <nodelist> is a comma separated list of one or more node ranges.  For
+example, "1,3-5" specifies nodes 1, 3, 4 and 5.  Specify "all" to request
+huge page preallocation on all on-line nodes.  The hugepages_nodes_allowed
+parameter may be specified on the kernel boot command line.
+
+The success or failure of allocation depends on the amount of physically
+contiguous memory that is preset in system at this time.  If the kernel is
+unable to allocate hugepages from some nodes in a NUMA system, it will
+attempt to make up the difference by allocating extra pages on other nodes
+with available contiguous memory, if any, within the constraints of the
+allowed nodes.
+
+System administrators may want to put this command in one of the local rc init
+files.  This will enable the kernel to request hugepages early in the boot
+process (when the possibility of getting physical contiguous pages is still
+very high). In either case, administrators will want to verify the number of
+hugepages actually allocated by checking the sysctl or meminfo.  To check the
+per node distribution of huge pages, use:
+
+	cat /sys/devices/system/node/node*/meminfo | fgrep Huge
 
 /proc/sys/vm/nr_overcommit_hugepages indicates how large the pool of
 hugepages can grow, if more hugepages than /proc/sys/vm/nr_hugepages are
 requested by applications. echo'ing any non-zero value into this file
-indicates that the hugetlb subsystem is allowed to try to obtain
+indicates that the hugetlb subsystem is allowed to try to obtain "surplus"
 hugepages from the buddy allocator, if the normal pool is exhausted. As
 these surplus hugepages go out of use, they are freed back to the buddy
-allocator.
+allocator.  Note that surplus hugepages are not constrained by the
+hugepages_nodes_allowed mask.
+
+When increasing the huge page pool size via nr_hugepages, any surplus
+pages on the allowed nodes will first be promoted to persistent huge
+pages.  Then, additional huge pages will be allocated from the allowed
+nodes, if necessary and if possible, to fulfil the new pool size.
+
+The administrator may shrink the pool of preallocated huge pages for
+the default huge page size by setting the nr_hugepages sysctl to a
+smaller value.  The kernel will attempt to free huge pages "round robin"
+across all on-line nodes, ignoring the nodes_allowed mask.  Any free huge
+pages on the selected nodes will be freed back to the buddy allocator.
 
 Caveat: Shrinking the pool via nr_hugepages such that it becomes less
 than the number of hugepages in use will convert the balance to surplus
@@ -112,6 +160,7 @@ Inside each of these directories, the sa
 
 	nr_hugepages
 	nr_overcommit_hugepages
+	nodes_allowed
 	free_hugepages
 	resv_hugepages
 	surplus_hugepages

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
