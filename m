Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEA86B005D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 17:51:38 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 29 Jun 2009 17:52:50 -0400
Message-Id: <20090629215250.20038.43226.sendpatchset@lts-notebook>
In-Reply-To: <20090629215226.20038.42028.sendpatchset@lts-notebook>
References: <20090629215226.20038.42028.sendpatchset@lts-notebook>
Subject: [PATCH 3/3] Cleanup and update huge pages documentation
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 3/3 cleanup and update huge pages documentation.

Against:  25jun09 mmotm

This patch attempts to clarify huge page administration and usage,
and updates the doucmentation to mention the balancing of huge pages
across nodes when allocating and freeing.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/hugetlbpage.txt |  133 +++++++++++++++++++++++++--------------
 1 file changed, 87 insertions(+), 46 deletions(-)

Index: linux-2.6.31-rc1-mmotm-090625-1549/Documentation/vm/hugetlbpage.txt
===================================================================
--- linux-2.6.31-rc1-mmotm-090625-1549.orig/Documentation/vm/hugetlbpage.txt	2009-06-29 12:19:02.000000000 -0400
+++ linux-2.6.31-rc1-mmotm-090625-1549/Documentation/vm/hugetlbpage.txt	2009-06-29 17:29:48.000000000 -0400
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
@@ -37,25 +37,27 @@ HugePages_Surp:  yyy
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
+                but no allocation has yet been made.  Reserved huge pages
+                guarantee that an application will be able to allocate a
+                huge page from the pool of huge pages at fault time.
+HugePages_Surp  is short for "surplus," and is the number of huge pages in
+                the pool above the value in /proc/sys/vm/nr_hugepages. The
+                maximum number of surplus huge pages is controlled by
+                /proc/sys/vm/nr_overcommit_hugepages.
 
 /proc/filesystems should also show a filesystem of type "hugetlbfs" configured
 in the kernel.
 
 /proc/sys/vm/nr_hugepages indicates the current number of configured hugetlb
 pages in the kernel.  Super user can dynamically request more (or free some
-pre-configured) hugepages.
+pre-configured) huge pages.
 The allocation (or deallocation) of hugetlb pages is possible only if there are
-enough physically contiguous free pages in system (freeing of hugepages is
+enough physically contiguous free pages in system (freeing of huge pages is
 possible only if there are enough hugetlb pages free that can be transferred
 back to regular memory pool).
 
@@ -67,43 +69,82 @@ use either the mmap system call or share
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
+(or free some pre-configured) huge pages.
+
+Use the following command to dynamically allocate/deallocate default sized
+huge pages:
 
 	echo 20 > /proc/sys/vm/nr_hugepages
 
-This command will try to configure 20 hugepages in the system.  The success
-or failure of allocation depends on the amount of physically contiguous
-memory that is preset in system at this time.  System administrators may want
-to put this command in one of the local rc init files.  This will enable the
-kernel to request huge pages early in the boot process (when the possibility
-of getting physical contiguous pages is still very high). In either
-case, administrators will want to verify the number of hugepages actually
-allocated by checking the sysctl or meminfo.
-
-/proc/sys/vm/nr_overcommit_hugepages indicates how large the pool of
-hugepages can grow, if more hugepages than /proc/sys/vm/nr_hugepages are
-requested by applications. echo'ing any non-zero value into this file
-indicates that the hugetlb subsystem is allowed to try to obtain
-hugepages from the buddy allocator, if the normal pool is exhausted. As
-these surplus hugepages go out of use, they are freed back to the buddy
+This command will try to configure 20 default sized huge pages in the system.
+On a NUMA platform, the kernel will attempt to distribute the huge page pool
+over the all on-line nodes.  These huge pages, allocated when nr_hugepages
+is increased, are called "persistent huge pages".
+
+The success or failure of huge page allocation depends on the amount of
+physically contiguous memory that is preset in system at the time of the
+allocation attempt.  If the kernel is unable to allocate huge pages from
+some nodes in a NUMA system, it will attempt to make up the difference by
+allocating extra pages on other nodes with sufficient available contiguous
+memory, if any.
+
+System administrators may want to put this command in one of the local rc init
+files.  This will enable the kernel to request huge pages early in the boot
+process when the possibility of getting physical contiguous pages is still
+very high.  Administrators can verify the number of huge pages actually
+allocated by checking the sysctl or meminfo.  To check the per node
+distribution of huge pages in a NUMA system, use:
+
+	cat /sys/devices/system/node/node*/meminfo | fgrep Huge
+
+/proc/sys/vm/nr_overcommit_hugepages specifies how large the pool of
+huge pages can grow, if more huge pages than /proc/sys/vm/nr_hugepages are
+requested by applications.  Writing any non-zero value into this file
+indicates that the hugetlb subsystem is allowed to try to obtain "surplus"
+huge pages from the buddy allocator, when the normal pool is exhausted. As
+these surplus huge pages go out of use, they are freed back to the buddy
 allocator.
 
+When increasing the huge page pool size via nr_hugepages, any surplus
+pages will first be promoted to persistent huge pages.  Then, additional
+huge pages will be allocated, if necessary and if possible, to fulfill
+the new huge page pool size.
+
+The administrator may shrink the pool of preallocated huge pages for
+the default huge page size by setting the nr_hugepages sysctl to a
+smaller value.  The kernel will attempt to balance the freeing of huge pages
+across all on-line nodes.  Any free huge pages on the selected nodes will
+be freed back to the buddy allocator.
+
 Caveat: Shrinking the pool via nr_hugepages such that it becomes less
-than the number of hugepages in use will convert the balance to surplus
+than the number of huge pages in use will convert the balance to surplus
 huge pages even if it would exceed the overcommit value.  As long as
 this condition holds, however, no more surplus huge pages will be
 allowed on the system until one of the two sysctls are increased
 sufficiently, or the surplus huge pages go out of use and are freed.
 
-With support for multiple hugepage pools at run-time available, much of
-the hugepage userspace interface has been duplicated in sysfs. The above
-information applies to the default hugepage size (which will be
-controlled by the proc interfaces for backwards compatibility). The root
-hugepage control directory is
+With support for multiple huge page pools at run-time available, much of
+the huge page userspace interface has been duplicated in sysfs. The above
+information applies to the default huge page size which will be
+controlled by the /proc interfaces for backwards compatibility. The root
+huge page control directory in sysfs is:
 
 	/sys/kernel/mm/hugepages
 
-For each hugepage size supported by the running kernel, a subdirectory
+For each huge page size supported by the running kernel, a subdirectory
 will exist, of the form
 
 	hugepages-${size}kB
@@ -116,9 +157,9 @@ Inside each of these directories, the sa
 	resv_hugepages
 	surplus_hugepages
 
-which function as described above for the default hugepage-sized case.
+which function as described above for the default huge page-sized case.
 
-If the user applications are going to request hugepages using mmap system
+If the user applications are going to request huge pages using mmap system
 call, then it is required that system administrator mount a file system of
 type hugetlbfs:
 
@@ -127,7 +168,7 @@ type hugetlbfs:
 	none /mnt/huge
 
 This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
-/mnt/huge.  Any files created on /mnt/huge uses hugepages.  The uid and gid
+/mnt/huge.  Any files created on /mnt/huge uses huge pages.  The uid and gid
 options sets the owner and group of the root of the file system.  By default
 the uid and gid of the current process are taken.  The mode option sets the
 mode of root of file system to value & 0777.  This value is given in octal.
@@ -156,14 +197,14 @@ mount of filesystem will be required for
 *******************************************************************
 
 /*
- * Example of using hugepage memory in a user application using Sys V shared
+ * Example of using huge page memory in a user application using Sys V shared
  * memory system calls.  In this example the app is requesting 256MB of
  * memory that is backed by huge pages.  The application uses the flag
  * SHM_HUGETLB in the shmget system call to inform the kernel that it is
- * requesting hugepages.
+ * requesting huge pages.
  *
  * For the ia64 architecture, the Linux kernel reserves Region number 4 for
- * hugepages.  That means the addresses starting with 0x800000... will need
+ * huge pages.  That means the addresses starting with 0x800000... will need
  * to be specified.  Specifying a fixed address is not required on ppc64,
  * i386 or x86_64.
  *
@@ -252,14 +293,14 @@ int main(void)
 *******************************************************************
 
 /*
- * Example of using hugepage memory in a user application using the mmap
+ * Example of using huge page memory in a user application using the mmap
  * system call.  Before running this application, make sure that the
  * administrator has mounted the hugetlbfs filesystem (on some directory
  * like /mnt) using the command mount -t hugetlbfs nodev /mnt. In this
  * example, the app is requesting memory of size 256MB that is backed by
  * huge pages.
  *
- * For ia64 architecture, Linux kernel reserves Region number 4 for hugepages.
+ * For ia64 architecture, Linux kernel reserves Region number 4 for huge pages.
  * That means the addresses starting with 0x800000... will need to be
  * specified.  Specifying a fixed address is not required on ppc64, i386
  * or x86_64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
