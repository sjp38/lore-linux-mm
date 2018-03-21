Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8C676B002B
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 96so2968722wrk.12
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d35si2661267edc.198.2018.03.21.12.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:40 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJMUt0078745
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:39 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2guwg9g1u3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:38 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:36 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 07/32] docs/vm: hugetlbpage.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:23 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/hugetlbpage.txt | 243 ++++++++++++++++++++++-----------------
 1 file changed, 139 insertions(+), 104 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index faf077d..3bb0d99 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -1,3 +1,11 @@
+.. _hugetlbpage:
+
+=============
+HugeTLB Pages
+=============
+
+Overview
+========
 
 The intent of this file is to give a brief summary of hugetlbpage support in
 the Linux kernel.  This support is built on top of multiple page size support
@@ -18,53 +26,59 @@ First the Linux kernel needs to be built with the CONFIG_HUGETLBFS
 automatically when CONFIG_HUGETLBFS is selected) configuration
 options.
 
-The /proc/meminfo file provides information about the total number of
+The ``/proc/meminfo`` file provides information about the total number of
 persistent hugetlb pages in the kernel's huge page pool.  It also displays
 default huge page size and information about the number of free, reserved
 and surplus huge pages in the pool of huge pages of default size.
 The huge page size is needed for generating the proper alignment and
 size of the arguments to system calls that map huge page regions.
 
-The output of "cat /proc/meminfo" will include lines like:
+The output of ``cat /proc/meminfo`` will include lines like::
 
-.....
-HugePages_Total: uuu
-HugePages_Free:  vvv
-HugePages_Rsvd:  www
-HugePages_Surp:  xxx
-Hugepagesize:    yyy kB
-Hugetlb:         zzz kB
+	HugePages_Total: uuu
+	HugePages_Free:  vvv
+	HugePages_Rsvd:  www
+	HugePages_Surp:  xxx
+	Hugepagesize:    yyy kB
+	Hugetlb:         zzz kB
 
 where:
-HugePages_Total is the size of the pool of huge pages.
-HugePages_Free  is the number of huge pages in the pool that are not yet
-                allocated.
-HugePages_Rsvd  is short for "reserved," and is the number of huge pages for
-                which a commitment to allocate from the pool has been made,
-                but no allocation has yet been made.  Reserved huge pages
-                guarantee that an application will be able to allocate a
-                huge page from the pool of huge pages at fault time.
-HugePages_Surp  is short for "surplus," and is the number of huge pages in
-                the pool above the value in /proc/sys/vm/nr_hugepages. The
-                maximum number of surplus huge pages is controlled by
-                /proc/sys/vm/nr_overcommit_hugepages.
-Hugepagesize    is the default hugepage size (in Kb).
-Hugetlb         is the total amount of memory (in kB), consumed by huge
-                pages of all sizes.
-                If huge pages of different sizes are in use, this number
-                will exceed HugePages_Total * Hugepagesize. To get more
-                detailed information, please, refer to
-                /sys/kernel/mm/hugepages (described below).
-
-
-/proc/filesystems should also show a filesystem of type "hugetlbfs" configured
-in the kernel.
-
-/proc/sys/vm/nr_hugepages indicates the current number of "persistent" huge
+
+HugePages_Total
+	is the size of the pool of huge pages.
+HugePages_Free
+	is the number of huge pages in the pool that are not yet
+        allocated.
+HugePages_Rsvd
+	is short for "reserved," and is the number of huge pages for
+        which a commitment to allocate from the pool has been made,
+        but no allocation has yet been made.  Reserved huge pages
+        guarantee that an application will be able to allocate a
+        huge page from the pool of huge pages at fault time.
+HugePages_Surp
+	is short for "surplus," and is the number of huge pages in
+        the pool above the value in ``/proc/sys/vm/nr_hugepages``. The
+        maximum number of surplus huge pages is controlled by
+        ``/proc/sys/vm/nr_overcommit_hugepages``.
+Hugepagesize
+	is the default hugepage size (in Kb).
+Hugetlb
+        is the total amount of memory (in kB), consumed by huge
+        pages of all sizes.
+        If huge pages of different sizes are in use, this number
+        will exceed HugePages_Total \* Hugepagesize. To get more
+        detailed information, please, refer to
+        ``/sys/kernel/mm/hugepages`` (described below).
+
+
+``/proc/filesystems`` should also show a filesystem of type "hugetlbfs"
+configured in the kernel.
+
+``/proc/sys/vm/nr_hugepages`` indicates the current number of "persistent" huge
 pages in the kernel's huge page pool.  "Persistent" huge pages will be
 returned to the huge page pool when freed by a task.  A user with root
 privileges can dynamically allocate more or free some persistent huge pages
-by increasing or decreasing the value of 'nr_hugepages'.
+by increasing or decreasing the value of ``nr_hugepages``.
 
 Pages that are used as huge pages are reserved inside the kernel and cannot
 be used for other purposes.  Huge pages cannot be swapped out under
@@ -86,10 +100,10 @@ with a huge page size selection parameter "hugepagesz=<size>".  <size> must
 be specified in bytes with optional scale suffix [kKmMgG].  The default huge
 page size may be selected with the "default_hugepagesz=<size>" boot parameter.
 
-When multiple huge page sizes are supported, /proc/sys/vm/nr_hugepages
+When multiple huge page sizes are supported, ``/proc/sys/vm/nr_hugepages``
 indicates the current number of pre-allocated huge pages of the default size.
 Thus, one can use the following command to dynamically allocate/deallocate
-default sized persistent huge pages:
+default sized persistent huge pages::
 
 	echo 20 > /proc/sys/vm/nr_hugepages
 
@@ -98,7 +112,7 @@ huge page pool to 20, allocating or freeing huge pages, as required.
 
 On a NUMA platform, the kernel will attempt to distribute the huge page pool
 over all the set of allowed nodes specified by the NUMA memory policy of the
-task that modifies nr_hugepages.  The default for the allowed nodes--when the
+task that modifies ``nr_hugepages``. The default for the allowed nodes--when the
 task has default memory policy--is all on-line nodes with memory.  Allowed
 nodes with insufficient available, contiguous memory for a huge page will be
 silently skipped when allocating persistent huge pages.  See the discussion
@@ -117,51 +131,52 @@ init files.  This will enable the kernel to allocate huge pages early in
 the boot process when the possibility of getting physical contiguous pages
 is still very high.  Administrators can verify the number of huge pages
 actually allocated by checking the sysctl or meminfo.  To check the per node
-distribution of huge pages in a NUMA system, use:
+distribution of huge pages in a NUMA system, use::
 
 	cat /sys/devices/system/node/node*/meminfo | fgrep Huge
 
-/proc/sys/vm/nr_overcommit_hugepages specifies how large the pool of
-huge pages can grow, if more huge pages than /proc/sys/vm/nr_hugepages are
+``/proc/sys/vm/nr_overcommit_hugepages`` specifies how large the pool of
+huge pages can grow, if more huge pages than ``/proc/sys/vm/nr_hugepages`` are
 requested by applications.  Writing any non-zero value into this file
 indicates that the hugetlb subsystem is allowed to try to obtain that
 number of "surplus" huge pages from the kernel's normal page pool, when the
 persistent huge page pool is exhausted. As these surplus huge pages become
 unused, they are freed back to the kernel's normal page pool.
 
-When increasing the huge page pool size via nr_hugepages, any existing surplus
-pages will first be promoted to persistent huge pages.  Then, additional
+When increasing the huge page pool size via ``nr_hugepages``, any existing
+surplus pages will first be promoted to persistent huge pages.  Then, additional
 huge pages will be allocated, if necessary and if possible, to fulfill
 the new persistent huge page pool size.
 
 The administrator may shrink the pool of persistent huge pages for
-the default huge page size by setting the nr_hugepages sysctl to a
+the default huge page size by setting the ``nr_hugepages`` sysctl to a
 smaller value.  The kernel will attempt to balance the freeing of huge pages
-across all nodes in the memory policy of the task modifying nr_hugepages.
+across all nodes in the memory policy of the task modifying ``nr_hugepages``.
 Any free huge pages on the selected nodes will be freed back to the kernel's
 normal page pool.
 
-Caveat: Shrinking the persistent huge page pool via nr_hugepages such that
+Caveat: Shrinking the persistent huge page pool via ``nr_hugepages`` such that
 it becomes less than the number of huge pages in use will convert the balance
 of the in-use huge pages to surplus huge pages.  This will occur even if
 the number of surplus pages it would exceed the overcommit value.  As long as
-this condition holds--that is, until nr_hugepages+nr_overcommit_hugepages is
+this condition holds--that is, until ``nr_hugepages+nr_overcommit_hugepages`` is
 increased sufficiently, or the surplus huge pages go out of use and are freed--
 no more surplus huge pages will be allowed to be allocated.
 
 With support for multiple huge page pools at run-time available, much of
-the huge page userspace interface in /proc/sys/vm has been duplicated in sysfs.
-The /proc interfaces discussed above have been retained for backwards
-compatibility. The root huge page control directory in sysfs is:
+the huge page userspace interface in ``/proc/sys/vm`` has been duplicated in
+sysfs.
+The ``/proc`` interfaces discussed above have been retained for backwards
+compatibility. The root huge page control directory in sysfs is::
 
 	/sys/kernel/mm/hugepages
 
 For each huge page size supported by the running kernel, a subdirectory
-will exist, of the form:
+will exist, of the form::
 
 	hugepages-${size}kB
 
-Inside each of these directories, the same set of files will exist:
+Inside each of these directories, the same set of files will exist::
 
 	nr_hugepages
 	nr_hugepages_mempolicy
@@ -176,33 +191,33 @@ which function as described above for the default huge page-sized case.
 Interaction of Task Memory Policy with Huge Page Allocation/Freeing
 ===================================================================
 
-Whether huge pages are allocated and freed via the /proc interface or
-the /sysfs interface using the nr_hugepages_mempolicy attribute, the NUMA
-nodes from which huge pages are allocated or freed are controlled by the
-NUMA memory policy of the task that modifies the nr_hugepages_mempolicy
-sysctl or attribute.  When the nr_hugepages attribute is used, mempolicy
+Whether huge pages are allocated and freed via the ``/proc`` interface or
+the ``/sysfs`` interface using the ``nr_hugepages_mempolicy`` attribute, the
+NUMA nodes from which huge pages are allocated or freed are controlled by the
+NUMA memory policy of the task that modifies the ``nr_hugepages_mempolicy``
+sysctl or attribute.  When the ``nr_hugepages`` attribute is used, mempolicy
 is ignored.
 
 The recommended method to allocate or free huge pages to/from the kernel
-huge page pool, using the nr_hugepages example above, is:
+huge page pool, using the ``nr_hugepages`` example above, is::
 
     numactl --interleave <node-list> echo 20 \
 				>/proc/sys/vm/nr_hugepages_mempolicy
 
-or, more succinctly:
+or, more succinctly::
 
     numactl -m <node-list> echo 20 >/proc/sys/vm/nr_hugepages_mempolicy
 
-This will allocate or free abs(20 - nr_hugepages) to or from the nodes
+This will allocate or free ``abs(20 - nr_hugepages)`` to or from the nodes
 specified in <node-list>, depending on whether number of persistent huge pages
 is initially less than or greater than 20, respectively.  No huge pages will be
 allocated nor freed on any node not included in the specified <node-list>.
 
-When adjusting the persistent hugepage count via nr_hugepages_mempolicy, any
+When adjusting the persistent hugepage count via ``nr_hugepages_mempolicy``, any
 memory policy mode--bind, preferred, local or interleave--may be used.  The
 resulting effect on persistent huge page allocation is as follows:
 
-1) Regardless of mempolicy mode [see Documentation/vm/numa_memory_policy.txt],
+#. Regardless of mempolicy mode [see Documentation/vm/numa_memory_policy.txt],
    persistent huge pages will be distributed across the node or nodes
    specified in the mempolicy as if "interleave" had been specified.
    However, if a node in the policy does not contain sufficient contiguous
@@ -212,7 +227,7 @@ resulting effect on persistent huge page allocation is as follows:
    possibly, allocation of persistent huge pages on nodes not allowed by
    the task's memory policy.
 
-2) One or more nodes may be specified with the bind or interleave policy.
+#. One or more nodes may be specified with the bind or interleave policy.
    If more than one node is specified with the preferred policy, only the
    lowest numeric id will be used.  Local policy will select the node where
    the task is running at the time the nodes_allowed mask is constructed.
@@ -222,20 +237,20 @@ resulting effect on persistent huge page allocation is as follows:
    indeterminate.  Thus, local policy is not very useful for this purpose.
    Any of the other mempolicy modes may be used to specify a single node.
 
-3) The nodes allowed mask will be derived from any non-default task mempolicy,
+#. The nodes allowed mask will be derived from any non-default task mempolicy,
    whether this policy was set explicitly by the task itself or one of its
    ancestors, such as numactl.  This means that if the task is invoked from a
    shell with non-default policy, that policy will be used.  One can specify a
    node list of "all" with numactl --interleave or --membind [-m] to achieve
    interleaving over all nodes in the system or cpuset.
 
-4) Any task mempolicy specified--e.g., using numactl--will be constrained by
+#. Any task mempolicy specified--e.g., using numactl--will be constrained by
    the resource limits of any cpuset in which the task runs.  Thus, there will
    be no way for a task with non-default policy running in a cpuset with a
    subset of the system nodes to allocate huge pages outside the cpuset
    without first moving to a cpuset that contains all of the desired nodes.
 
-5) Boot-time huge page allocation attempts to distribute the requested number
+#. Boot-time huge page allocation attempts to distribute the requested number
    of huge pages over all on-lines nodes with memory.
 
 Per Node Hugepages Attributes
@@ -243,22 +258,22 @@ Per Node Hugepages Attributes
 
 A subset of the contents of the root huge page control directory in sysfs,
 described above, will be replicated under each the system device of each
-NUMA node with memory in:
+NUMA node with memory in::
 
 	/sys/devices/system/node/node[0-9]*/hugepages/
 
 Under this directory, the subdirectory for each supported huge page size
-contains the following attribute files:
+contains the following attribute files::
 
 	nr_hugepages
 	free_hugepages
 	surplus_hugepages
 
-The free_' and surplus_' attribute files are read-only.  They return the number
+The free\_' and surplus\_' attribute files are read-only.  They return the number
 of free and surplus [overcommitted] huge pages, respectively, on the parent
 node.
 
-The nr_hugepages attribute returns the total number of huge pages on the
+The ``nr_hugepages`` attribute returns the total number of huge pages on the
 specified node.  When this attribute is written, the number of persistent huge
 pages on the parent node will be adjusted to the specified value, if sufficient
 resources exist, regardless of the task's mempolicy or cpuset constraints.
@@ -273,37 +288,51 @@ Using Huge Pages
 
 If the user applications are going to request huge pages using mmap system
 call, then it is required that system administrator mount a file system of
-type hugetlbfs:
+type hugetlbfs::
 
   mount -t hugetlbfs \
 	-o uid=<value>,gid=<value>,mode=<value>,pagesize=<value>,size=<value>,\
 	min_size=<value>,nr_inodes=<value> none /mnt/huge
 
 This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
-/mnt/huge.  Any files created on /mnt/huge uses huge pages.  The uid and gid
-options sets the owner and group of the root of the file system.  By default
-the uid and gid of the current process are taken.  The mode option sets the
-mode of root of file system to value & 01777.  This value is given in octal.
-By default the value 0755 is picked. If the platform supports multiple huge
-page sizes, the pagesize option can be used to specify the huge page size and
-associated pool.  pagesize is specified in bytes.  If pagesize is not specified
-the platform's default huge page size and associated pool will be used. The
-size option sets the maximum value of memory (huge pages) allowed for that
-filesystem (/mnt/huge).  The size option can be specified in bytes, or as a
-percentage of the specified huge page pool (nr_hugepages).  The size is
-rounded down to HPAGE_SIZE boundary.  The min_size option sets the minimum
-value of memory (huge pages) allowed for the filesystem.  min_size can be
-specified in the same way as size, either bytes or a percentage of the
-huge page pool.  At mount time, the number of huge pages specified by
-min_size are reserved for use by the filesystem.  If there are not enough
-free huge pages available, the mount will fail.  As huge pages are allocated
-to the filesystem and freed, the reserve count is adjusted so that the sum
-of allocated and reserved huge pages is always at least min_size.  The option
-nr_inodes sets the maximum number of inodes that /mnt/huge can use.  If the
-size, min_size or nr_inodes option is not provided on command line then
-no limits are set.  For pagesize, size, min_size and nr_inodes options, you
-can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For example, size=2K
-has the same meaning as size=2048.
+``/mnt/huge``.  Any files created on ``/mnt/huge`` uses huge pages.
+
+The ``uid`` and ``gid`` options sets the owner and group of the root of the
+file system.  By default the ``uid`` and ``gid`` of the current process
+are taken.
+
+The ``mode`` option sets the mode of root of file system to value & 01777.
+This value is given in octal. By default the value 0755 is picked.
+
+If the platform supports multiple huge page sizes, the ``pagesize`` option can
+be used to specify the huge page size and associated pool. ``pagesize``
+is specified in bytes. If ``pagesize`` is not specified the platform's
+default huge page size and associated pool will be used.
+
+The ``size`` option sets the maximum value of memory (huge pages) allowed
+for that filesystem (``/mnt/huge``). The ``size`` option can be specified
+in bytes, or as a percentage of the specified huge page pool (``nr_hugepages``).
+The size is rounded down to HPAGE_SIZE boundary.
+
+The ``min_size`` option sets the minimum value of memory (huge pages) allowed
+for the filesystem. ``min_size`` can be specified in the same way as ``size``,
+either bytes or a percentage of the huge page pool.
+At mount time, the number of huge pages specified by ``min_size`` are reserved
+for use by the filesystem.
+If there are not enough free huge pages available, the mount will fail.
+As huge pages are allocated to the filesystem and freed, the reserve count
+is adjusted so that the sum of allocated and reserved huge pages is always
+at least ``min_size``.
+
+The option ``nr_inodes`` sets the maximum number of inodes that ``/mnt/huge``
+can use.
+
+If the ``size``, ``min_size`` or ``nr_inodes`` option is not provided on
+command line then no limits are set.
+
+For ``pagesize``, ``size``, ``min_size`` and ``nr_inodes`` options, you can
+use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo.
+For example, size=2K has the same meaning as size=2048.
 
 While read system calls are supported on files that reside on hugetlb
 file systems, write system calls are not.
@@ -313,12 +342,12 @@ used to change the file attributes on hugetlbfs.
 
 Also, it is important to note that no such mount command is required if
 applications are going to use only shmat/shmget system calls or mmap with
-MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see map_hugetlb
-below.
+MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see
+:ref:`map_hugetlb <map_hugetlb>` below.
 
 Users who wish to use hugetlb memory via shared memory segment should be a
 member of a supplementary group and system admin needs to configure that gid
-into /proc/sys/vm/hugetlb_shm_group.  It is possible for same or different
+into ``/proc/sys/vm/hugetlb_shm_group``.  It is possible for same or different
 applications to use any combination of mmaps and shm* calls, though the mount of
 filesystem will be required for using mmap calls without MAP_HUGETLB.
 
@@ -332,15 +361,21 @@ a hugetlb page and the length is smaller than the hugepage size.
 Examples
 ========
 
-1) map_hugetlb: see tools/testing/selftests/vm/map_hugetlb.c
+.. _map_hugetlb:
+
+``map_hugetlb``
+	see tools/testing/selftests/vm/map_hugetlb.c
+
+``hugepage-shm``
+	see tools/testing/selftests/vm/hugepage-shm.c
 
-2) hugepage-shm:  see tools/testing/selftests/vm/hugepage-shm.c
+``hugepage-mmap``
+	see tools/testing/selftests/vm/hugepage-mmap.c
 
-3) hugepage-mmap:  see tools/testing/selftests/vm/hugepage-mmap.c
+The `libhugetlbfs`_  library provides a wide range of userspace tools
+to help with huge page usability, environment setup, and control.
 
-4) The libhugetlbfs (https://github.com/libhugetlbfs/libhugetlbfs) library
-   provides a wide range of userspace tools to help with huge page usability,
-   environment setup, and control.
+.. _libhugetlbfs: https://github.com/libhugetlbfs/libhugetlbfs
 
 Kernel development regression testing
 =====================================
-- 
2.7.4
