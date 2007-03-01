From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301101042.30048.96532.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
References: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 8/8] Add documentation for additional boot parameter and sysctl
Date: Thu,  1 Mar 2007 10:10:42 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Once all patches are applied, a new command-line parameter exist and a new
sysctl. This patch adds the necessary documentation.


Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 filesystems/proc.txt  |   15 +++++++++++++++
 kernel-parameters.txt |   16 ++++++++++++++++
 sysctl/vm.txt         |    3 ++-
 3 files changed, 33 insertions(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-007_ia64_set_kernelcore/Documentation/filesystems/proc.txt linux-2.6.20-mm2-008_documentation/Documentation/filesystems/proc.txt
--- linux-2.6.20-mm2-007_ia64_set_kernelcore/Documentation/filesystems/proc.txt	2007-02-19 01:19:19.000000000 +0000
+++ linux-2.6.20-mm2-008_documentation/Documentation/filesystems/proc.txt	2007-02-19 09:24:19.000000000 +0000
@@ -1289,6 +1289,21 @@ nr_hugepages configures number of hugetl
 hugetlb_shm_group contains group id that is allowed to create SysV shared
 memory segment using hugetlb page.
 
+hugepages_treat_as_movable
+--------------------------
+
+This parameter is only useful when kernelcore= is specified at boot time to
+create ZONE_MOVABLE for pages that may be reclaimed or migrated. Huge pages
+are not movable so are not normally allocated from ZONE_MOVABLE. A non-zero
+value written to hugepages_treat_as_movable allows huge pages to be allocated
+from ZONE_MOVABLE.
+
+Once enabled, the ZONE_MOVABLE is treated as an area of memory the huge
+pages pool can easily grow or shrink within. Assuming that applications are
+not running that mlock() a lot of memory, it is likely the huge pages pool
+can grow to the size of ZONE_MOVABLE by repeatedly entering the desired value
+into nr_hugepages and triggering page reclaim.
+
 laptop_mode
 -----------
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-007_ia64_set_kernelcore/Documentation/kernel-parameters.txt linux-2.6.20-mm2-008_documentation/Documentation/kernel-parameters.txt
--- linux-2.6.20-mm2-007_ia64_set_kernelcore/Documentation/kernel-parameters.txt	2007-02-19 01:19:20.000000000 +0000
+++ linux-2.6.20-mm2-008_documentation/Documentation/kernel-parameters.txt	2007-02-19 09:24:19.000000000 +0000
@@ -762,6 +762,22 @@ and is between 256 and 4096 characters. 
 	js=		[HW,JOY] Analog joystick
 			See Documentation/input/joystick.txt.
 
+	kernelcore=nn[KMG]	[KNL,IA-32,IA-64,PPC,X86-64] This parameter
+			specifies the amount of memory usable by the kernel
+			for non-movable allocations.  The requested amount is
+			spread evenly throughout all nodes in the system. The
+			remaining memory in each node is used for Movable
+			pages. In the event, a node is too small to have both
+			kernelcore and Movable pages, kernelcore pages will
+			take priority and other nodes will have a larger number
+			of kernelcore pages.  The Movable zone is used for the
+			allocation of pages that may be reclaimed or moved
+			by the page migration subsystem.  This means that
+			HugeTLB pages may not be allocated from this zone.
+			Note that allocations like PTEs-from-HighMem still
+			use the HighMem zone if it exists, and the Normal
+			zone if it does not.
+
 	keepinitrd	[HW,ARM]
 
 	kstack=N	[IA-32,X86-64] Print N words from the kernel stack
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-007_ia64_set_kernelcore/Documentation/sysctl/vm.txt linux-2.6.20-mm2-008_documentation/Documentation/sysctl/vm.txt
--- linux-2.6.20-mm2-007_ia64_set_kernelcore/Documentation/sysctl/vm.txt	2007-02-19 01:19:20.000000000 +0000
+++ linux-2.6.20-mm2-008_documentation/Documentation/sysctl/vm.txt	2007-02-19 09:24:19.000000000 +0000
@@ -39,7 +39,8 @@ Currently, these files are in /proc/sys/
 
 dirty_ratio, dirty_background_ratio, dirty_expire_centisecs,
 dirty_writeback_centisecs, vfs_cache_pressure, laptop_mode,
-block_dump, swap_token_timeout, drop-caches:
+block_dump, swap_token_timeout, drop-caches,
+hugepages_treat_as_movable:
 
 See Documentation/filesystems/proc.txt
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
