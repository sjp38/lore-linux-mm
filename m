Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDI23sb019600
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 13:02:03 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDI23B3483284
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 13:02:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDI22DS003763
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 13:02:03 -0500
Date: Thu, 13 Dec 2007 10:01:16 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 3/3] Documetation: update hugetlb information
Message-ID: <20071213180116.GF17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com> <1197562629.21438.20.camel@localhost> <20071213164453.GC17526@us.ibm.com> <1197565364.21438.23.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1197565364.21438.23.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.12.2007 [09:02:44 -0800], Dave Hansen wrote:
> On Thu, 2007-12-13 at 08:44 -0800, Nishanth Aravamudan wrote:
> > Err, yes, will need to updated that. I note that the old sysctl is not
> > there...nor is nr_hugepages, for that matter. So maybe I'll just add a
> > 3rd patch to fix the Documentation? I really just wanted to get the
> > patches out there as soon as I got them tested... 
> 
> Yeah, that should be fine.  Adding nr_hugepages will probably get you
> bonus points. :)

Documentation: updated hugetlb information

The hugetlb documentation has gotten a bit out of sync with the current
code. Updated the sysctl file to refer to
Documentation/vm/hugetlbpage.txt. Update that file to contain the
current state of affairs (with the newer named sysctl in place).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
This is 3/3 because it depends on 1/2 and 2/2 ... Not sure if this is
complete enough, either. Adam, do you have any input?

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index b89570c..6f31f0a 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -34,6 +34,8 @@ Currently, these files are in /proc/sys/vm:
 - oom_kill_allocating_task
 - mmap_min_address
 - numa_zonelist_order
+- nr_hugepages
+- nr_overcommit_hugepages
 
 ==============================================================
 
@@ -305,3 +307,20 @@ will select "node" order in following case.
 
 Otherwise, "zone" order will be selected. Default order is recommended unless
 this is causing problems for your system/application.
+
+==============================================================
+
+nr_hugepages
+
+Change the minimum size of the hugepage pool.
+
+See Documentation/vm/hugetlbpage.txt
+
+==============================================================
+
+nr_overcommit_hugepages
+
+Change the maximum size of the hugepage pool. The maximum is
+nr_hugepages + nr_overcommit_hugepages.
+
+See Documentation/vm/hugetlbpage.txt
diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index 51ccc48..f962d01 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -30,9 +30,10 @@ alignment and size of the arguments to the above system calls.
 The output of "cat /proc/meminfo" will have lines like:
 
 .....
-HugePages_Total: xxx
-HugePages_Free:  yyy
-HugePages_Rsvd:  www
+HugePages_Total: vvv
+HugePages_Free:  www
+HugePages_Rsvd:  xxx
+HugePages_Surp:  yyy
 Hugepagesize:    zzz kB
 
 where:
@@ -42,6 +43,10 @@ allocated.
 HugePages_Rsvd is short for "reserved," and is the number of hugepages
 for which a commitment to allocate from the pool has been made, but no
 allocation has yet been made. It's vaguely analogous to overcommit.
+HugePages_Surp is short for "surplus," and is the number of hugepages in
+the pool above the value in /proc/sys/vm/nr_hugepages. The maximum
+number of surplus hugepages is controlled by
+/proc/sys/vm/nr_overcommit_hugepages.
 
 /proc/filesystems should also show a filesystem of type "hugetlbfs" configured
 in the kernel.
@@ -71,7 +76,25 @@ or failure of allocation depends on the amount of physically contiguous
 memory that is preset in system at this time.  System administrators may want
 to put this command in one of the local rc init files.  This will enable the
 kernel to request huge pages early in the boot process (when the possibility
-of getting physical contiguous pages is still very high).
+of getting physical contiguous pages is still very high). In either
+case, adminstrators will want to verify the number of hugepages actually
+allocated by checking the sysctl or meminfo.
+
+/proc/sys/vm/nr_overcommit_hugepages indicates how large the pool of
+hugepages can grow, if more hugepages than /proc/sys/vm/nr_hugepages are
+requested by applications. echo'ing any non-zero value into this file
+indicates that the hugetlb subsystem is allowed to try to obtain
+hugepages from the buddy allocator, if the normal pool is exhausted. As
+these surplus hugepages go out of use, they are freed back to the buddy
+allocator.
+
+Caveat: Shrinking the pool via nr_hugepages while a surplus is in effect
+will allow the number of surplus huge pages to exceed the overcommit
+value, as the pool hugepages (which must have been in use for a surplus
+hugepages to be allocated) will become surplus hugepages.  As long as
+this condition holds, however, no more surplus huge pages will be
+allowed on the system until one of the two sysctls are increased
+sufficiently, or the surplus huge pages go out of use and are freed.
 
 If the user applications are going to request hugepages using mmap system
 call, then it is required that system administrator mount a file system of
@@ -94,8 +117,8 @@ provided on command line then no limits are set.  For size and nr_inodes
 options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For
 example, size=2K has the same meaning as size=2048.
 
-read and write system calls are not supported on files that reside on hugetlb
-file systems.
+While read system calls are supported on files that reside on hugetlb
+file systems, write system calls are not.
 
 Regular chown, chgrp, and chmod commands (with right permissions) could be
 used to change the file attributes on hugetlbfs.

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
