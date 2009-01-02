Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A21456B00C1
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 13:04:22 -0500 (EST)
From: Peter W Morreale <pmorreale@novell.com>
Subject: [PATCH] Update of Documentation/
Date: Fri, 02 Jan 2009 11:04:12 -0700
Message-ID: <20090102180412.3676.27341.stgit@hermosa.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pmorreale@novell.com, randy.dunlap@oracle.com, linux-kernel@vger.kernel.org, riel@nl.linux.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This patch updates Documentation/sysctl/vm.txt and
Documentation/filesystems/proc.txt.   More specifically, the section on
/proc/sys/vm in Documentation/filesystems/proc.txt was removed and a
link to Documentation/sysctl/vm.txt added.

Most of the verbiage from proc.txt was simply moved in vm.txt, with new
addtional text for "swappiness" and "stat_interval".

This update reflects the current state of 2.6.27.

Best,
-PWM
---

Signed-off-by: Peter W Morreale <pmorreale@novell.com>

 Documentation/filesystems/proc.txt |  265 -----------------
 Documentation/sysctl/vm.txt        |  574 +++++++++++++++++++++++++-----------
 2 files changed, 407 insertions(+), 432 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index f566ad9..6e6afe9 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -5,9 +5,11 @@
                   Bodo Bauer <bb@ricochet.net>
 
 2.4.x update	  Jorge Nerin <comandante@zaralinux.com>      November 14 2000
+2.6.x update	  Peter W. Morreale <pmorreale@novell.com>    December 31 2008
 ------------------------------------------------------------------------------
-Version 1.3                                              Kernel version 2.2.12
+Version 1.4                                              Kernel version 2.2.12
 					      Kernel version 2.4.0-test11-pre4
+					      section 2.4 update to 2.6.27
 ------------------------------------------------------------------------------
 
 Table of Contents
@@ -1362,265 +1364,8 @@ auto_msgmni default value is 1.
 2.4 /proc/sys/vm - The virtual memory subsystem
 -----------------------------------------------
 
-The files  in  this directory can be used to tune the operation of the virtual
-memory (VM)  subsystem  of  the  Linux  kernel.
-
-vfs_cache_pressure
-------------------
-
-Controls the tendency of the kernel to reclaim the memory which is used for
-caching of directory and inode objects.
-
-At the default value of vfs_cache_pressure=100 the kernel will attempt to
-reclaim dentries and inodes at a "fair" rate with respect to pagecache and
-swapcache reclaim.  Decreasing vfs_cache_pressure causes the kernel to prefer
-to retain dentry and inode caches.  Increasing vfs_cache_pressure beyond 100
-causes the kernel to prefer to reclaim dentries and inodes.
-
-dirty_background_ratio
-----------------------
-
-Contains, as a percentage of total system memory, the number of pages at which
-the pdflush background writeback daemon will start writing out dirty data.
-
-dirty_ratio
------------------
-
-Contains, as a percentage of total system memory, the number of pages at which
-a process which is generating disk writes will itself start writing out dirty
-data.
-
-dirty_writeback_centisecs
--------------------------
-
-The pdflush writeback daemons will periodically wake up and write `old' data
-out to disk.  This tunable expresses the interval between those wakeups, in
-100'ths of a second.
-
-Setting this to zero disables periodic writeback altogether.
-
-dirty_expire_centisecs
-----------------------
-
-This tunable is used to define when dirty data is old enough to be eligible
-for writeout by the pdflush daemons.  It is expressed in 100'ths of a second. 
-Data which has been dirty in-memory for longer than this interval will be
-written out next time a pdflush daemon wakes up.
-
-highmem_is_dirtyable
---------------------
-
-Only present if CONFIG_HIGHMEM is set.
-
-This defaults to 0 (false), meaning that the ratios set above are calculated
-as a percentage of lowmem only.  This protects against excessive scanning
-in page reclaim, swapping and general VM distress.
-
-Setting this to 1 can be useful on 32 bit machines where you want to make
-random changes within an MMAPed file that is larger than your available
-lowmem without causing large quantities of random IO.  Is is safe if the
-behavior of all programs running on the machine is known and memory will
-not be otherwise stressed.
-
-legacy_va_layout
-----------------
-
-If non-zero, this sysctl disables the new 32-bit mmap mmap layout - the kernel
-will use the legacy (2.4) layout for all processes.
-
-lowmem_reserve_ratio
----------------------
-
-For some specialised workloads on highmem machines it is dangerous for
-the kernel to allow process memory to be allocated from the "lowmem"
-zone.  This is because that memory could then be pinned via the mlock()
-system call, or by unavailability of swapspace.
-
-And on large highmem machines this lack of reclaimable lowmem memory
-can be fatal.
-
-So the Linux page allocator has a mechanism which prevents allocations
-which _could_ use highmem from using too much lowmem.  This means that
-a certain amount of lowmem is defended from the possibility of being
-captured into pinned user memory.
-
-(The same argument applies to the old 16 megabyte ISA DMA region.  This
-mechanism will also defend that region from allocations which could use
-highmem or lowmem).
-
-The `lowmem_reserve_ratio' tunable determines how aggressive the kernel is
-in defending these lower zones.
-
-If you have a machine which uses highmem or ISA DMA and your
-applications are using mlock(), or if you are running with no swap then
-you probably should change the lowmem_reserve_ratio setting.
-
-The lowmem_reserve_ratio is an array. You can see them by reading this file.
--
-% cat /proc/sys/vm/lowmem_reserve_ratio
-256     256     32
--
-Note: # of this elements is one fewer than number of zones. Because the highest
-      zone's value is not necessary for following calculation.
-
-But, these values are not used directly. The kernel calculates # of protection
-pages for each zones from them. These are shown as array of protection pages
-in /proc/zoneinfo like followings. (This is an example of x86-64 box).
-Each zone has an array of protection pages like this.
-
--
-Node 0, zone      DMA
-  pages free     1355
-        min      3
-        low      3
-        high     4
-	:
-	:
-    numa_other   0
-        protection: (0, 2004, 2004, 2004)
-	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-  pagesets
-    cpu: 0 pcp: 0
-        :
--
-These protections are added to score to judge whether this zone should be used
-for page allocation or should be reclaimed.
-
-In this example, if normal pages (index=2) are required to this DMA zone and
-pages_high is used for watermark, the kernel judges this zone should not be
-used because pages_free(1355) is smaller than watermark + protection[2]
-(4 + 2004 = 2008). If this protection value is 0, this zone would be used for
-normal page requirement. If requirement is DMA zone(index=0), protection[0]
-(=0) is used.
-
-zone[i]'s protection[j] is calculated by following expression.
-
-(i < j):
-  zone[i]->protection[j]
-  = (total sums of present_pages from zone[i+1] to zone[j] on the node)
-    / lowmem_reserve_ratio[i];
-(i = j):
-   (should not be protected. = 0;
-(i > j):
-   (not necessary, but looks 0)
-
-The default values of lowmem_reserve_ratio[i] are
-    256 (if zone[i] means DMA or DMA32 zone)
-    32  (others).
-As above expression, they are reciprocal number of ratio.
-256 means 1/256. # of protection pages becomes about "0.39%" of total present
-pages of higher zones on the node.
-
-If you would like to protect more pages, smaller values are effective.
-The minimum value is 1 (1/1 -> 100%).
-
-page-cluster
-------------
-
-page-cluster controls the number of pages which are written to swap in
-a single attempt.  The swap I/O size.
-
-It is a logarithmic value - setting it to zero means "1 page", setting
-it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
-
-The default value is three (eight pages at a time).  There may be some
-small benefits in tuning this to a different value if your workload is
-swap-intensive.
-
-overcommit_memory
------------------
-
-Controls overcommit of system memory, possibly allowing processes
-to allocate (but not use) more memory than is actually available.
-
-
-0	-	Heuristic overcommit handling. Obvious overcommits of
-		address space are refused. Used for a typical system. It
-		ensures a seriously wild allocation fails while allowing
-		overcommit to reduce swap usage.  root is allowed to
-		allocate slightly more memory in this mode. This is the
-		default.
-
-1	-	Always overcommit. Appropriate for some scientific
-		applications.
-
-2	-	Don't overcommit. The total address space commit
-		for the system is not permitted to exceed swap plus a
-		configurable percentage (default is 50) of physical RAM.
-		Depending on the percentage you use, in most situations
-		this means a process will not be killed while attempting
-		to use already-allocated memory but will receive errors
-		on memory allocation as	appropriate.
-
-overcommit_ratio
-----------------
-
-Percentage of physical memory size to include in overcommit calculations
-(see above.)
-
-Memory allocation limit = swapspace + physmem * (overcommit_ratio / 100)
-
-	swapspace = total size of all swap areas
-	physmem = size of physical memory in system
-
-nr_hugepages and hugetlb_shm_group
-----------------------------------
-
-nr_hugepages configures number of hugetlb page reserved for the system.
-
-hugetlb_shm_group contains group id that is allowed to create SysV shared
-memory segment using hugetlb page.
-
-hugepages_treat_as_movable
---------------------------
-
-This parameter is only useful when kernelcore= is specified at boot time to
-create ZONE_MOVABLE for pages that may be reclaimed or migrated. Huge pages
-are not movable so are not normally allocated from ZONE_MOVABLE. A non-zero
-value written to hugepages_treat_as_movable allows huge pages to be allocated
-from ZONE_MOVABLE.
-
-Once enabled, the ZONE_MOVABLE is treated as an area of memory the huge
-pages pool can easily grow or shrink within. Assuming that applications are
-not running that mlock() a lot of memory, it is likely the huge pages pool
-can grow to the size of ZONE_MOVABLE by repeatedly entering the desired value
-into nr_hugepages and triggering page reclaim.
-
-laptop_mode
------------
-
-laptop_mode is a knob that controls "laptop mode". All the things that are
-controlled by this knob are discussed in Documentation/laptops/laptop-mode.txt.
-
-block_dump
-----------
-
-block_dump enables block I/O debugging when set to a nonzero value. More
-information on block I/O debugging is in Documentation/laptops/laptop-mode.txt.
-
-swap_token_timeout
-------------------
-
-This file contains valid hold time of swap out protection token. The Linux
-VM has token based thrashing control mechanism and uses the token to prevent
-unnecessary page faults in thrashing situation. The unit of the value is
-second. The value would be useful to tune thrashing behavior.
-
-drop_caches
------------
-
-Writing to this will cause the kernel to drop clean caches, dentries and
-inodes from memory, causing that memory to become free.
-
-To free pagecache:
-	echo 1 > /proc/sys/vm/drop_caches
-To free dentries and inodes:
-	echo 2 > /proc/sys/vm/drop_caches
-To free pagecache, dentries and inodes:
-	echo 3 > /proc/sys/vm/drop_caches
-
-As this is a non-destructive operation and dirty objects are not freeable, the
-user should run `sync' first.
+Please refer to: Documentation/sysctl/vm.txt for a complete description
+of these controls.
 
 
 2.5 /proc/sys/dev - Device specific parameters
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index d79eeda..5f55a50 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -1,12 +1,13 @@
-Documentation for /proc/sys/vm/*	kernel version 2.2.10
+Documentation for /proc/sys/vm/*	kernel version 2.6.27
 	(c) 1998, 1999,  Rik van Riel <riel@nl.linux.org>
+	(c) 2008         Peter W. Morreale <pmorreale@novell.com>
 
 For general info and legal blurb, please look in README.
 
 ==============================================================
 
 This file contains the documentation for the sysctl files in
-/proc/sys/vm and is valid for Linux kernel version 2.2.
+/proc/sys/vm and is valid for Linux kernel version 2.6.27.
 
 The files in this directory can be used to tune the operation
 of the virtual memory (VM) subsystem of the Linux kernel and
@@ -16,81 +17,221 @@ Default values and initialization routines for most of these
 files can be found in mm/swap.c.
 
 Currently, these files are in /proc/sys/vm:
-- overcommit_memory
-- page-cluster
-- dirty_ratio
+  
+- block_dump
 - dirty_background_ratio
 - dirty_expire_centisecs
+- dirty_ratio
 - dirty_writeback_centisecs
-- highmem_is_dirtyable   (only if CONFIG_HIGHMEM set)
+- drop_caches
+- hugepages_treat_as_movable
+- hugetlb_shm_group
+- laptop_mode
+- legacy_va_layout
+- lowmem_reserve_ratio
 - max_map_count
 - min_free_kbytes
-- laptop_mode
-- block_dump
-- drop-caches
-- zone_reclaim_mode
-- min_unmapped_ratio
 - min_slab_ratio
-- panic_on_oom
-- oom_dump_tasks
-- oom_kill_allocating_task
-- mmap_min_address
-- numa_zonelist_order
+- min_unmapped_ratio
+- mmap_min_addr
 - nr_hugepages
 - nr_overcommit_hugepages
+- nr_pdflush_threads
+- numa_zonelist_order
+- oom_dump_tasks
+- oom_kill_allocating_task
+- overcommit_memory
+- overcommit_ratio
+- page-cluster
+- panic_on_oom
+- percpu_pagelist_fraction
+- stat_interval
+- swappiness
+- vfs_cache_pressure
+- zone_reclaim_mode
+ 
+ 
+==============================================================
+ 
+block_dump
+
+block_dump enables block I/O debugging when set to a nonzero value. More
+information on block I/O debugging is in Documentation/laptops/laptop-mode.txt.
 
 ==============================================================
 
-dirty_ratio, dirty_background_ratio, dirty_expire_centisecs,
-dirty_writeback_centisecs, highmem_is_dirtyable,
-vfs_cache_pressure, laptop_mode, block_dump, swap_token_timeout,
-drop-caches, hugepages_treat_as_movable:
+dirty_background_ratio
 
-See Documentation/filesystems/proc.txt
+Contains, as a percentage of total system memory, the number of pages at which
+the pdflush background writeback daemon will start writing out dirty data.
 
 ==============================================================
 
-overcommit_memory:
+dirty_expire_centisecs
 
-This value contains a flag that enables memory overcommitment.
+This tunable is used to define when dirty data is old enough to be eligible
+for writeout by the pdflush daemons.  It is expressed in 100'ths of a second. 
+Data which has been dirty in-memory for longer than this interval will be
+written out next time a pdflush daemon wakes up.
 
-When this flag is 0, the kernel attempts to estimate the amount
-of free memory left when userspace requests more memory.
+==============================================================
 
-When this flag is 1, the kernel pretends there is always enough
-memory until it actually runs out.
+dirty_ratio
 
-When this flag is 2, the kernel uses a "never overcommit"
-policy that attempts to prevent any overcommit of memory.  
+Contains, as a percentage of total system memory, the number of pages at which
+a process which is generating disk writes will itself start writing out dirty
+data.
 
-This feature can be very useful because there are a lot of
-programs that malloc() huge amounts of memory "just-in-case"
-and don't use much of it.
+==============================================================
 
-The default value is 0.
+dirty_writeback_centisecs
 
-See Documentation/vm/overcommit-accounting and
-security/commoncap.c::cap_vm_enough_memory() for more information.
+The pdflush writeback daemons will periodically wake up and write `old' data
+out to disk.  This tunable expresses the interval between those wakeups, in
+100'ths of a second.
+
+Setting this to zero disables periodic writeback altogether.
 
 ==============================================================
 
-overcommit_ratio:
+drop_caches
 
-When overcommit_memory is set to 2, the committed address
-space is not permitted to exceed swap plus this percentage
-of physical RAM.  See above.
+Writing to this will cause the kernel to drop clean caches, dentries and
+inodes from memory, causing that memory to become free.
+
+To free pagecache:
+	echo 1 > /proc/sys/vm/drop_caches
+To free dentries and inodes:
+	echo 2 > /proc/sys/vm/drop_caches
+To free pagecache, dentries and inodes:
+	echo 3 > /proc/sys/vm/drop_caches
+
+As this is a non-destructive operation and dirty objects are not freeable, the
+user should run `sync' first.
 
 ==============================================================
 
-page-cluster:
+hugepages_treat_as_movable
 
-The Linux VM subsystem avoids excessive disk seeks by reading
-multiple pages on a page fault. The number of pages it reads
-is dependent on the amount of memory in your machine.
+This parameter is only useful when kernelcore= is specified at boot time to
+create ZONE_MOVABLE for pages that may be reclaimed or migrated. Huge pages
+are not movable so are not normally allocated from ZONE_MOVABLE. A non-zero
+value written to hugepages_treat_as_movable allows huge pages to be allocated
+from ZONE_MOVABLE.
 
-The number of pages the kernel reads in at once is equal to
-2 ^ page-cluster. Values above 2 ^ 5 don't make much sense
-for swap because we only cluster swap data in 32-page groups.
+Once enabled, the ZONE_MOVABLE is treated as an area of memory the huge
+pages pool can easily grow or shrink within. Assuming that applications are
+not running that mlock() a lot of memory, it is likely the huge pages pool
+can grow to the size of ZONE_MOVABLE by repeatedly entering the desired value
+into nr_hugepages and triggering page reclaim.
+
+==============================================================
+
+hugetlb_shm_group 
+
+hugetlb_shm_group contains group id that is allowed to create SysV
+shared memory segment using hugetlb page.
+
+==============================================================
+
+laptop_mode
+
+laptop_mode is a knob that controls "laptop mode". All the things that are
+controlled by this knob are discussed in Documentation/laptops/laptop-mode.txt.
+
+==============================================================
+
+legacy_va_layout
+
+If non-zero, this sysctl disables the new 32-bit mmap mmap layout - the kernel
+will use the legacy (2.4) layout for all processes.
+
+==============================================================
+
+lowmem_reserve_ratio
+
+For some specialised workloads on highmem machines it is dangerous for
+the kernel to allow process memory to be allocated from the "lowmem"
+zone.  This is because that memory could then be pinned via the mlock()
+system call, or by unavailability of swapspace.
+
+And on large highmem machines this lack of reclaimable lowmem memory
+can be fatal.
+
+So the Linux page allocator has a mechanism which prevents allocations
+which _could_ use highmem from using too much lowmem.  This means that
+a certain amount of lowmem is defended from the possibility of being
+captured into pinned user memory.
+
+(The same argument applies to the old 16 megabyte ISA DMA region.  This
+mechanism will also defend that region from allocations which could use
+highmem or lowmem).
+
+The `lowmem_reserve_ratio' tunable determines how aggressive the kernel is
+in defending these lower zones.
+
+If you have a machine which uses highmem or ISA DMA and your
+applications are using mlock(), or if you are running with no swap then
+you probably should change the lowmem_reserve_ratio setting.
+
+The lowmem_reserve_ratio is an array. You can see them by reading this file.
+-
+% cat /proc/sys/vm/lowmem_reserve_ratio
+256     256     32
+-
+Note: # of this elements is one fewer than number of zones. Because the highest
+      zone's value is not necessary for following calculation.
+
+But, these values are not used directly. The kernel calculates # of protection
+pages for each zones from them. These are shown as array of protection pages
+in /proc/zoneinfo like followings. (This is an example of x86-64 box).
+Each zone has an array of protection pages like this.
+
+-
+Node 0, zone      DMA
+  pages free     1355
+        min      3
+        low      3
+        high     4
+	:
+	:
+    numa_other   0
+        protection: (0, 2004, 2004, 2004)
+	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+  pagesets
+    cpu: 0 pcp: 0
+        :
+-
+These protections are added to score to judge whether this zone should be used
+for page allocation or should be reclaimed.
+
+In this example, if normal pages (index=2) are required to this DMA zone and
+pages_high is used for watermark, the kernel judges this zone should not be
+used because pages_free(1355) is smaller than watermark + protection[2]
+(4 + 2004 = 2008). If this protection value is 0, this zone would be used for
+normal page requirement. If requirement is DMA zone(index=0), protection[0]
+(=0) is used.
+
+zone[i]'s protection[j] is calculated by following expression.
+
+(i < j):
+  zone[i]->protection[j]
+  = (total sums of present_pages from zone[i+1] to zone[j] on the node)
+    / lowmem_reserve_ratio[i];
+(i = j):
+   (should not be protected. = 0;
+(i > j):
+   (not necessary, but looks 0)
+
+The default values of lowmem_reserve_ratio[i] are
+    256 (if zone[i] means DMA or DMA32 zone)
+    32  (others).
+As above expression, they are reciprocal number of ratio.
+256 means 1/256. # of protection pages becomes about "0.39%" of total present
+pages of higher zones on the node.
+
+If you would like to protect more pages, smaller values are effective.
+The minimum value is 1 (1/1 -> 100%).
 
 ==============================================================
 
@@ -122,59 +263,23 @@ become subtly broken, and prone to deadlock under high loads.
 
 Setting this too high will OOM your machine instantly.
 
-==============================================================
-
-percpu_pagelist_fraction
-
-This is the fraction of pages at most (high mark pcp->high) in each zone that
-are allocated for each per cpu page list.  The min value for this is 8.  It
-means that we don't allow more than 1/8th of pages in each zone to be
-allocated in any single per_cpu_pagelist.  This entry only changes the value
-of hot per cpu pagelists.  User can specify a number like 100 to allocate
-1/100th of each zone to each per cpu page list.
-
-The batch value of each per cpu pagelist is also updated as a result.  It is
-set to pcp->high/4.  The upper limit of batch is (PAGE_SHIFT * 8)
-
-The initial value is zero.  Kernel does not use this value at boot time to set
-the high water marks for each per cpu page list.
-
-===============================================================
-
-zone_reclaim_mode:
-
-Zone_reclaim_mode allows someone to set more or less aggressive approaches to
-reclaim memory when a zone runs out of memory. If it is set to zero then no
-zone reclaim occurs. Allocations will be satisfied from other zones / nodes
-in the system.
-
-This is value ORed together of
+=============================================================
 
-1	= Zone reclaim on
-2	= Zone reclaim writes dirty pages out
-4	= Zone reclaim swaps pages
+min_slab_ratio:
 
-zone_reclaim_mode is set during bootup to 1 if it is determined that pages
-from remote zones will cause a measurable performance reduction. The
-page allocator will then reclaim easily reusable pages (those page
-cache pages that are currently not used) before allocating off node pages.
+This is available only on NUMA kernels.
 
-It may be beneficial to switch off zone reclaim if the system is
-used for a file server and all of memory should be used for caching files
-from disk. In that case the caching effect is more important than
-data locality.
+A percentage of the total pages in each zone.  On Zone reclaim
+(fallback from the local zone occurs) slabs will be reclaimed if more
+than this percentage of pages in a zone are reclaimable slab pages.
+This insures that the slab growth stays under control even in NUMA
+systems that rarely perform global reclaim.
 
-Allowing zone reclaim to write out pages stops processes that are
-writing large amounts of data from dirtying pages on other nodes. Zone
-reclaim will write out dirty pages if a zone fills up and so effectively
-throttle the process. This may decrease the performance of a single process
-since it cannot use all of system memory to buffer the outgoing writes
-anymore but it preserve the memory on other nodes so that the performance
-of other processes running on other nodes will not be affected.
+The default is 5 percent.
 
-Allowing regular swap effectively restricts allocations to the local
-node unless explicitly overridden by memory policies or cpuset
-configurations.
+Note that slab reclaim is triggered in a per zone / node fashion.
+The process of reclaiming slab memory is currently not node specific
+and may not be fast.
 
 =============================================================
 
@@ -189,49 +294,92 @@ file I/O even if the node is overallocated.
 
 The default is 1 percent.
 
-=============================================================
+==============================================================
 
-min_slab_ratio:
+mmap_min_addr
 
-This is available only on NUMA kernels.
+This file indicates the amount of address space  which a user process will
+be restricted from mmaping.  Since kernel null dereference bugs could
+accidentally operate based on the information in the first couple of pages
+of memory userspace processes should not be allowed to write to them.  By
+default this value is set to 0 and no protections will be enforced by the
+security module.  Setting this value to something like 64k will allow the
+vast majority of applications to work correctly and provide defense in depth
+against future potential kernel bugs.
 
-A percentage of the total pages in each zone.  On Zone reclaim
-(fallback from the local zone occurs) slabs will be reclaimed if more
-than this percentage of pages in a zone are reclaimable slab pages.
-This insures that the slab growth stays under control even in NUMA
-systems that rarely perform global reclaim.
+==============================================================
 
-The default is 5 percent.
+nr_hugepages
 
-Note that slab reclaim is triggered in a per zone / node fashion.
-The process of reclaiming slab memory is currently not node specific
-and may not be fast.
+Change the minimum size of the hugepage pool.
 
-=============================================================
+See Documentation/vm/hugetlbpage.txt
 
-panic_on_oom
+==============================================================
 
-This enables or disables panic on out-of-memory feature.
+nr_overcommit_hugepages
 
-If this is set to 0, the kernel will kill some rogue process,
-called oom_killer.  Usually, oom_killer can kill rogue processes and
-system will survive.
+Change the maximum size of the hugepage pool. The maximum is
+nr_hugepages + nr_overcommit_hugepages.
 
-If this is set to 1, the kernel panics when out-of-memory happens.
-However, if a process limits using nodes by mempolicy/cpusets,
-and those nodes become memory exhaustion status, one process
-may be killed by oom-killer. No panic occurs in this case.
-Because other nodes' memory may be free. This means system total status
-may be not fatal yet.
+See Documentation/vm/hugetlbpage.txt
 
-If this is set to 2, the kernel panics compulsorily even on the
-above-mentioned.
+==============================================================
 
-The default value is 0.
-1 and 2 are for failover of clustering. Please select either
-according to your policy of failover.
+nr_pdflush_threads
 
-=============================================================
+The current number of pdflush threads.  This value is read-only.
+The value changes according to the number of dirty pages in the system. 
+
+When neccessary, additional pdflush threads are created, one per second, up to
+nr_pdflush_threads_max.
+
+==============================================================
+
+numa_zonelist_order
+
+This sysctl is only for NUMA.
+'where the memory is allocated from' is controlled by zonelists.
+(This documentation ignores ZONE_HIGHMEM/ZONE_DMA32 for simple explanation.
+ you may be able to read ZONE_DMA as ZONE_DMA32...)
+
+In non-NUMA case, a zonelist for GFP_KERNEL is ordered as following.
+ZONE_NORMAL -> ZONE_DMA
+This means that a memory allocation request for GFP_KERNEL will
+get memory from ZONE_DMA only when ZONE_NORMAL is not available.
+
+In NUMA case, you can think of following 2 types of order.
+Assume 2 node NUMA and below is zonelist of Node(0)'s GFP_KERNEL
+
+(A) Node(0) ZONE_NORMAL -> Node(0) ZONE_DMA -> Node(1) ZONE_NORMAL
+(B) Node(0) ZONE_NORMAL -> Node(1) ZONE_NORMAL -> Node(0) ZONE_DMA.
+
+Type(A) offers the best locality for processes on Node(0), but ZONE_DMA
+will be used before ZONE_NORMAL exhaustion. This increases possibility of
+out-of-memory(OOM) of ZONE_DMA because ZONE_DMA is tend to be small.
+
+Type(B) cannot offer the best locality but is more robust against OOM of
+the DMA zone.
+
+Type(A) is called as "Node" order. Type (B) is "Zone" order.
+
+"Node order" orders the zonelists by node, then by zone within each node.
+Specify "[Nn]ode" for zone order
+
+"Zone Order" orders the zonelists by zone type, then by node within each
+zone.  Specify "[Zz]one"for zode order.
+
+Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
+will select "node" order in following case.
+(1) if the DMA zone does not exist or
+(2) if the DMA zone comprises greater than 50% of the available memory or
+(3) if any node's DMA zone comprises greater than 60% of its local memory and
+    the amount of local memory is big enough.
+
+Otherwise, "zone" order will be selected. Default order is recommended unless
+this is causing problems for your system/application.
+
+==============================================================
 
 oom_dump_tasks
 
@@ -252,7 +400,7 @@ OOM killer actually kills a memory-hogging task.
 
 The default value is 0.
 
-=============================================================
+==============================================================
 
 oom_kill_allocating_task
 
@@ -275,75 +423,157 @@ The default value is 0.
 
 ==============================================================
 
-mmap_min_addr
+overcommit_memory:
 
-This file indicates the amount of address space  which a user process will
-be restricted from mmaping.  Since kernel null dereference bugs could
-accidentally operate based on the information in the first couple of pages
-of memory userspace processes should not be allowed to write to them.  By
-default this value is set to 0 and no protections will be enforced by the
-security module.  Setting this value to something like 64k will allow the
-vast majority of applications to work correctly and provide defense in depth
-against future potential kernel bugs.
+This value contains a flag that enables memory overcommitment.
+
+When this flag is 0, the kernel attempts to estimate the amount
+of free memory left when userspace requests more memory.
+
+When this flag is 1, the kernel pretends there is always enough
+memory until it actually runs out.
+
+When this flag is 2, the kernel uses a "never overcommit"
+policy that attempts to prevent any overcommit of memory.  
+
+This feature can be very useful because there are a lot of
+programs that malloc() huge amounts of memory "just-in-case"
+and don't use much of it.
+
+The default value is 0.
+
+See Documentation/vm/overcommit-accounting and
+security/commoncap.c::cap_vm_enough_memory() for more information.
 
 ==============================================================
 
-numa_zonelist_order
+overcommit_ratio:
 
-This sysctl is only for NUMA.
-'where the memory is allocated from' is controlled by zonelists.
-(This documentation ignores ZONE_HIGHMEM/ZONE_DMA32 for simple explanation.
- you may be able to read ZONE_DMA as ZONE_DMA32...)
+When overcommit_memory is set to 2, the committed address
+space is not permitted to exceed swap plus this percentage
+of physical RAM.  See above.
 
-In non-NUMA case, a zonelist for GFP_KERNEL is ordered as following.
-ZONE_NORMAL -> ZONE_DMA
-This means that a memory allocation request for GFP_KERNEL will
-get memory from ZONE_DMA only when ZONE_NORMAL is not available.
+==============================================================
 
-In NUMA case, you can think of following 2 types of order.
-Assume 2 node NUMA and below is zonelist of Node(0)'s GFP_KERNEL
+page-cluster
 
-(A) Node(0) ZONE_NORMAL -> Node(0) ZONE_DMA -> Node(1) ZONE_NORMAL
-(B) Node(0) ZONE_NORMAL -> Node(1) ZONE_NORMAL -> Node(0) ZONE_DMA.
+page-cluster controls the number of pages which are written to swap in
+a single attempt.  The swap I/O size.
 
-Type(A) offers the best locality for processes on Node(0), but ZONE_DMA
-will be used before ZONE_NORMAL exhaustion. This increases possibility of
-out-of-memory(OOM) of ZONE_DMA because ZONE_DMA is tend to be small.
+It is a logarithmic value - setting it to zero means "1 page", setting
+it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
 
-Type(B) cannot offer the best locality but is more robust against OOM of
-the DMA zone.
+The default value is three (eight pages at a time).  There may be some
+small benefits in tuning this to a different value if your workload is
+swap-intensive.
 
-Type(A) is called as "Node" order. Type (B) is "Zone" order.
+=============================================================
 
-"Node order" orders the zonelists by node, then by zone within each node.
-Specify "[Nn]ode" for zone order
+panic_on_oom
 
-"Zone Order" orders the zonelists by zone type, then by node within each
-zone.  Specify "[Zz]one"for zode order.
+This enables or disables panic on out-of-memory feature.
 
-Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
-will select "node" order in following case.
-(1) if the DMA zone does not exist or
-(2) if the DMA zone comprises greater than 50% of the available memory or
-(3) if any node's DMA zone comprises greater than 60% of its local memory and
-    the amount of local memory is big enough.
+If this is set to 0, the kernel will kill some rogue process,
+called oom_killer.  Usually, oom_killer can kill rogue processes and
+system will survive.
 
-Otherwise, "zone" order will be selected. Default order is recommended unless
-this is causing problems for your system/application.
+If this is set to 1, the kernel panics when out-of-memory happens.
+However, if a process limits using nodes by mempolicy/cpusets,
+and those nodes become memory exhaustion status, one process
+may be killed by oom-killer. No panic occurs in this case.
+Because other nodes' memory may be free. This means system total status
+may be not fatal yet.
+
+If this is set to 2, the kernel panics compulsorily even on the
+above-mentioned.
+
+The default value is 0.
+1 and 2 are for failover of clustering. Please select either
+according to your policy of failover.
+
+=============================================================
+
+percpu_pagelist_fraction
+
+This is the fraction of pages at most (high mark pcp->high) in each zone that
+are allocated for each per cpu page list.  The min value for this is 8.  It
+means that we don't allow more than 1/8th of pages in each zone to be
+allocated in any single per_cpu_pagelist.  This entry only changes the value
+of hot per cpu pagelists.  User can specify a number like 100 to allocate
+1/100th of each zone to each per cpu page list.
+
+The batch value of each per cpu pagelist is also updated as a result.  It is
+set to pcp->high/4.  The upper limit of batch is (PAGE_SHIFT * 8)
+
+The initial value is zero.  Kernel does not use this value at boot time to set
+the high water marks for each per cpu page list.
 
 ==============================================================
 
-nr_hugepages
+stat_interval
 
-Change the minimum size of the hugepage pool.
+The time interval between which vm statistics are updated.  The default
+is 1 second.
 
-See Documentation/vm/hugetlbpage.txt
+==============================================================
+
+swappiness
+
+This control is used to define how aggressive the kernel will swap
+memory pages.  Higher values will increase agressiveness, lower values
+descrease the amount of swap.  
+
+The default value is 60.
 
 ==============================================================
 
-nr_overcommit_hugepages
+vfs_cache_pressure
+------------------
 
-Change the maximum size of the hugepage pool. The maximum is
-nr_hugepages + nr_overcommit_hugepages.
+Controls the tendency of the kernel to reclaim the memory which is used for
+caching of directory and inode objects.
 
-See Documentation/vm/hugetlbpage.txt
+At the default value of vfs_cache_pressure=100 the kernel will attempt to
+reclaim dentries and inodes at a "fair" rate with respect to pagecache and
+swapcache reclaim.  Decreasing vfs_cache_pressure causes the kernel to prefer
+to retain dentry and inode caches.  Increasing vfs_cache_pressure beyond 100
+causes the kernel to prefer to reclaim dentries and inodes.
+
+==============================================================
+
+zone_reclaim_mode:
+
+Zone_reclaim_mode allows someone to set more or less aggressive approaches to
+reclaim memory when a zone runs out of memory. If it is set to zero then no
+zone reclaim occurs. Allocations will be satisfied from other zones / nodes
+in the system.
+
+This is value ORed together of
+
+1	= Zone reclaim on
+2	= Zone reclaim writes dirty pages out
+4	= Zone reclaim swaps pages
+
+zone_reclaim_mode is set during bootup to 1 if it is determined that pages
+from remote zones will cause a measurable performance reduction. The
+page allocator will then reclaim easily reusable pages (those page
+cache pages that are currently not used) before allocating off node pages.
+
+It may be beneficial to switch off zone reclaim if the system is
+used for a file server and all of memory should be used for caching files
+from disk. In that case the caching effect is more important than
+data locality.
+
+Allowing zone reclaim to write out pages stops processes that are
+writing large amounts of data from dirtying pages on other nodes. Zone
+reclaim will write out dirty pages if a zone fills up and so effectively
+throttle the process. This may decrease the performance of a single process
+since it cannot use all of system memory to buffer the outgoing writes
+anymore but it preserve the memory on other nodes so that the performance
+of other processes running on other nodes will not be affected.
+
+Allowing regular swap effectively restricts allocations to the local
+node unless explicitly overridden by memory policies or cpuset
+configurations.
+
+============ End of Document =================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
