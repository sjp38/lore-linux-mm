Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77088620090
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 02:02:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3862Hcu011995
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Apr 2010 15:02:18 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED19345DE4F
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:02:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC20F45DE4E
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:02:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B26461DB8038
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:02:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D9D0E38003
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:02:13 +0900 (JST)
Date: Thu, 8 Apr 2010 14:58:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: update documentation v3
Message-Id: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, randy.dunlap@oracle.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Documentation update for memory cgroup

Some informations are old, and  I think current document doesn't work
as "a guide for users".
We need summary of all of our controls, at least.

This patch updates information for current implementations and add a
summary of interfaces. etc...

Changelog:
 - fixed tons of typos.
 - replaced "memcg" with "memory cgroup" AMAP.
 - replaced "mem+swap" with "memory+swap"

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |  210 ++++++++++++++++++++++++++++-----------
 1 file changed, 152 insertions(+), 58 deletions(-)

Index: mmotm-temp/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-temp.orig/Documentation/cgroups/memory.txt
+++ mmotm-temp/Documentation/cgroups/memory.txt
@@ -4,16 +4,6 @@ NOTE: The Memory Resource Controller has
 to as the memory controller in this document. Do not confuse memory controller
 used here with the memory controller that is used in hardware.
 
-Salient features
-
-a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
-   Swap Cache memory pages.
-b. The infrastructure allows easy addition of other types of memory to control
-c. Provides *zero overhead* for non memory controller users
-d. Provides a double LRU: global memory pressure causes reclaim from the
-   global LRU; a cgroup on hitting a limit, reclaims from the per
-   cgroup LRU
-
 Benefits and Purpose of the memory controller
 
 The memory controller isolates the memory behaviour of a group of tasks
@@ -33,6 +23,45 @@ d. A CD/DVD burner could control the amo
 e. There are several other use cases, find one or use the controller just
    for fun (to learn and hack on the VM subsystem).
 
+Current Status: linux-2.6.34-mmotm(development version of 2010/April)
+
+Features:
+ - accounting anonymous pages, file caches, swap caches usage and limit them.
+ - private LRU and reclaim routine. (system's global LRU and private LRU
+   work independently from each other)
+ - optionally, memory+swap usage can be accounted and limited.
+ - hierarchical accounting
+ - soft limit
+ - moving(recharging) account at moving a task is selectable.
+ - usage threshold notifier
+ - oom-killer disable knob and oom-notifier
+ - Root cgroup has no limit controls.
+
+ Kernel memory and Hugepages are not under control yet. We just manage
+ pages on LRU. To add more controls, we have to take care of performance.
+
+Brief summary of control files.
+
+ tasks				 # attach a task(thread)
+ cgroup.procs			 # attach a process(all threads under it)
+ cgroup.event_control		 # an interface for event_fd()
+ memory.usage_in_bytes		 # show current memory(RSS+Cache) usage.
+ memory.memsw.usage_in_bytes	 # show current memory+Swap usage
+ memory.limit_in_bytes		 # set/show limit of memory usage
+ memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
+ memory.failcnt			 # show the number of memory usage hit limits
+ memory.memsw.failcnt		 # show the number of memory+Swap hit limits
+ memory.max_usage_in_bytes	 # show max memory usage recorded
+ memory.memsw.usage_in_bytes	 # show max memory+Swap usage recorded
+ memory.soft_limit_in_bytes	 # set/show soft limit of memory usage
+ memory.stat			 # show various statistics
+ memory.use_hierarchy		 # set/show hierarchical account enabled
+ memory.force_empty		 # trigger forced move charge to parent
+ memory.swappiness		 # set/show swappiness parameter of vmscan
+ 				  (See sysctl's vm.swappiness)
+ memory.move_charge_at_immigrate # set/show controls of moving charges
+ memory.oom_control		 # set/show oom controls.
+
 1. History
 
 The memory controller has a long history. A request for comments for the memory
@@ -106,14 +135,14 @@ the necessary data structures and check 
 is over its limit. If it is then reclaim is invoked on the cgroup.
 More details can be found in the reclaim section of this document.
 If everything goes well, a page meta-data-structure called page_cgroup is
-allocated and associated with the page.  This routine also adds the page to
-the per cgroup LRU.
+updated. page_cgroup has its own LRU on cgroup.
+(*) page_cgroup structure is allocated at boot/memory-hotplug time.
 
 2.2.1 Accounting details
 
 All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
-(some pages which never be reclaimable and will not be on global LRU
- are not accounted. we just accounts pages under usual vm management.)
+Some pages which are never reclaimable and will not be on the global LRU
+are not accounted. We just accounts pages under usual VM management.
 
 RSS pages are accounted at page_fault unless they've already been accounted
 for earlier. A file page will be accounted for as Page Cache when it's
@@ -121,12 +150,18 @@ inserted into inode (radix-tree). While 
 processes, duplicate accounting is carefully avoided.
 
 A RSS page is unaccounted when it's fully unmapped. A PageCache page is
-unaccounted when it's removed from radix-tree.
+unaccounted when it's removed from radix-tree. Even if RSS pages are fully
+unmapped (by kswapd), they may exist as SwapCache in the system until they
+are really freed. Such SwapCaches also also accounted.
+A swapped-in page is not accounted until it's mapped. It's bacause we can't
+know a page will be finaly mapped at swapin-readahead happens.
+
+A Cache pages is unaccounted when it's removed from inode (radix-tree).
 
 At page migration, accounting information is kept.
 
 Note: we just account pages-on-lru because our purpose is to control amount
-of used pages. not-on-lru pages are tend to be out-of-control from vm view.
+of used pages. not-on-lru pages are tend to be out-of-control from VM view.
 
 2.3 Shared Page Accounting
 
@@ -143,6 +178,7 @@ caller of swapoff rather than the users 
 
 
 2.4 Swap Extension (CONFIG_CGROUP_MEM_RES_CTLR_SWAP)
+
 Swap Extension allows you to record charge for swap. A swapped-in page is
 charged back to original page allocator if possible.
 
@@ -150,13 +186,20 @@ When swap is accounted, following files 
  - memory.memsw.usage_in_bytes.
  - memory.memsw.limit_in_bytes.
 
-usage of mem+swap is limited by memsw.limit_in_bytes.
+memsw means memory+swap. Usage of memory+swap is limited by
+memsw.limit_in_bytes.
 
-* why 'mem+swap' rather than swap.
+Example) Assume a system with 4G of swap. A task which allocates 6G of memory
+(by mistake) under 2G memory limitation will use all swap.
+In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
+(Bad process will cause OOM under the memory cgroup. By using memsw limit,
+you can avoid system OOM which can be caused by swap shortage.)
+
+* why 'memory+swap' rather than swap.
 The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
 to move account from memory to swap...there is no change in usage of
-mem+swap. In other words, when we want to limit the usage of swap without
-affecting global LRU, mem+swap limit is better than just limiting swap from
+memory+swap. In other words, when we want to limit the usage of swap without
+affecting global LRU, memory+swap limit is better than just limiting swap from
 OS point of view.
 
 * What happens when a cgroup hits memory.memsw.limit_in_bytes
@@ -168,12 +211,12 @@ it by cgroup.
 
 2.5 Reclaim
 
-Each cgroup maintains a per cgroup LRU that consists of an active
-and inactive list. When a cgroup goes over its limit, we first try
+Each cgroup maintains a per cgroup LRU which has the same structure as
+global VM. When a cgroup goes over its limit, we first try
 to reclaim memory from the cgroup so as to make space for the new
 pages that the cgroup has touched. If the reclaim is unsuccessful,
 an OOM routine is invoked to select and kill the bulkiest task in the
-cgroup.
+cgroup. (See 10. OOM Control below.)
 
 The reclaim algorithm has not been modified for cgroups, except that
 pages that are selected for reclaiming come from the per cgroup LRU
@@ -189,11 +232,17 @@ When oom event notifier is registered, e
 
 2. Locking
 
-The memory controller uses the following hierarchy
+   lock_page_cgroup()/unlock_page_cgroup() should not be called under
+   mapping->tree_lock.
 
-1. zone->lru_lock is used for selecting pages to be isolated
-2. mem->per_zone->lru_lock protects the per cgroup LRU (per zone)
-3. lock_page_cgroup() is used to protect page->page_cgroup
+   Other lock order is following:
+   PG_locked.
+   mm->page_table_lock
+       zone->lru_lock
+	  lock_page_cgroup.
+  In many cases, just lock_page_cgroup() is called.
+  per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
+  zone->lru_lock, it has no lock of its own.
 
 3. User Interface
 
@@ -202,6 +251,7 @@ The memory controller uses the following
 a. Enable CONFIG_CGROUPS
 b. Enable CONFIG_RESOURCE_COUNTERS
 c. Enable CONFIG_CGROUP_MEM_RES_CTLR
+d. Enable CONFIG_CGROUP_MEM_RES_CTLR_SWAP (to use swap extension)
 
 1. Prepare the cgroups
 # mkdir -p /cgroups
@@ -216,16 +266,14 @@ We can alter the memory limit:
 # echo 4M > /cgroups/0/memory.limit_in_bytes
 
 NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
-mega or gigabytes.
+mega or gigabytes. (Here, Kilo, Mega, Giga are Kibibytes, Mebibytes, Gibibytes.)
+
 NOTE: We can write "-1" to reset the *.limit_in_bytes(unlimited).
 NOTE: We cannot set limits on the root cgroup any more.
 
 # cat /cgroups/0/memory.limit_in_bytes
 4194304
 
-NOTE: The interface has now changed to display the usage in bytes
-instead of pages
-
 We can check the usage:
 # cat /cgroups/0/memory.usage_in_bytes
 1216512
@@ -248,15 +296,24 @@ caches, RSS and Active pages/Inactive pa
 
 4. Testing
 
-Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
-Apart from that v6 has been tested with several applications and regular
-daily use. The controller has also been tested on the PPC64, x86_64 and
-UML platforms.
+For testing features and implementation, see memcg_test.txt.
+
+Performance test is also important. To see pure memory cgroup's overhead,
+testing on tmpfs will give you good numbers of small overheads.
+Example) do kernel make on tmpfs.
+
+Page-fault scalability is also important. At measuring parallel
+page fault test, multi-process test may be better than multi-thread
+test because it has noise of shared objects/status.
+
+But above 2 is testing extreme situation. Trying usual test under memory cgroup
+is always helpful.
+
 
 4.1 Troubleshooting
 
 Sometimes a user might find that the application under a cgroup is
-terminated. There are several causes for this:
+terminated by OOM killer. There are several causes for this:
 
 1. The cgroup limit is too low (just too low to do anything useful)
 2. The user is using anonymous memory and swap is turned off or too low
@@ -264,6 +321,9 @@ terminated. There are several causes for
 A sync followed by echo 1 > /proc/sys/vm/drop_caches will help get rid of
 some of the pages cached in the cgroup (page cache pages).
 
+To know what happens, disable OOM_Kill by 10. OOM Control(see below) and
+seeing what happens will be helpful.
+
 4.2 Task migration
 
 When a task migrates from one cgroup to another, it's charge is not
@@ -271,16 +331,19 @@ carried forward by default. The pages al
 remain charged to it, the charge is dropped when the page is freed or
 reclaimed.
 
-Note: You can move charges of a task along with task migration. See 8.
+You can move charges of a task along with task migration.
+See 8. "Move charges at task migration"
 
 4.3 Removing a cgroup
 
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
 cgroup might have some charge associated with it, even though all
-tasks have migrated away from it.
-Such charges are freed(at default) or moved to its parent. When moved,
-both of RSS and CACHES are moved to parent.
-If both of them are busy, rmdir() returns -EBUSY. See 5.1 Also.
+tasks have migrated away from it. (because we charge against pages, not
+against tasks.)
+
+Such charges are freed or moved to their parent. At moving, both of RSS
+and CACHES are moved to parent.
+rmdir() may return -EBUSY if freeing/moving fails. See 5.1 also.
 
 Charges recorded in swap information is not updated at removal of cgroup.
 Recorded information is discarded and a cgroup which uses swap (swapcache)
@@ -296,10 +359,10 @@ will be charged as a new owner of it.
 
   # echo 0 > memory.force_empty
 
-  Almost all pages tracked by this memcg will be unmapped and freed. Some of
-  pages cannot be freed because it's locked or in-use. Such pages are moved
-  to parent and this cgroup will be empty. But this may return -EBUSY in
-  some too busy case.
+  Almost all pages tracked by this memory cgroup will be unmapped and freed.
+  Some of pages cannot be freed because it's locked or in-use. Such pages are
+  moved to parent and this cgroup will be empty. This may return -EBUSY if
+  VM is too busy to free/move all pages immediately.
 
   Typical use case of this interface is that calling this before rmdir().
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
@@ -309,19 +372,41 @@ will be charged as a new owner of it.
 
 memory.stat file includes following statistics
 
+# per-memory cgroup local status
 cache		- # of bytes of page cache memory.
 rss		- # of bytes of anonymous and swap cache memory.
+mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
 pgpgin		- # of pages paged in (equivalent to # of charging events).
 pgpgout		- # of pages paged out (equivalent to # of uncharging events).
-active_anon	- # of bytes of anonymous and  swap cache memory on active
-		  lru list.
+swap		- # of bytes of swap usage
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
+		  lru list.
+active_anon	- # of bytes of anonymous and  swap cache memory on active
 		  inactive lru list.
-active_file	- # of bytes of file-backed memory on active lru list.
 inactive_file	- # of bytes of file-backed memory on inactive lru list.
+active_file	- # of bytes of file-backed memory on active lru list.
 unevictable	- # of bytes of memory that cannot be reclaimed (mlocked etc).
 
-The following additional stats are dependent on CONFIG_DEBUG_VM.
+# status considering hierarchy (see memory.use_hierarchy settings)
+
+hierarchical_memory_limit - # of bytes of memory limit with regard to hierarchy
+			under which the memory cgroup is
+hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
+			hierarchy under which memory cgroup is.
+
+total_cache		- sum of all children's "cache"
+total_rss		- sum of all children's "rss"
+total_mapped_file	- sum of all children's "cache"
+total_pgpgin		- sum of all children's "pgpgin"
+total_pgpgout		- sum of all children's "pgpgout"
+total_swap		- sum of all children's "swap"
+total_inactive_anon	- sum of all children's "inactive_anon"
+total_active_anon	- sum of all children's "active_anon"
+total_inactive_file	- sum of all children's "inactive_file"
+total_active_file	- sum of all children's "active_file"
+total_unevictable	- sum of all children's "unevictable"
+
+# The following additional stats are dependent on CONFIG_DEBUG_VM.
 
 inactive_ratio		- VM internal parameter. (see mm/page_alloc.c)
 recent_rotated_anon	- VM internal parameter. (see mm/vmscan.c)
@@ -337,17 +422,26 @@ Memo:
 Note:
 	Only anonymous and swap cache memory is listed as part of 'rss' stat.
 	This should not be confused with the true 'resident set size' or the
-	amount of physical memory used by the cgroup. Per-cgroup rss
-	accounting is not done yet.
+	amount of physical memory used by the cgroup.
+	'rss + file_mapped" will give you resident set size of cgroup.
+	(Note: file and shmem may be shared amoung other cgroups. In that case,
+	 file_mapped is accounted only when the memory cgroup is owner of page
+	 cache.)
 
 5.3 swappiness
   Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
 
   Following cgroups' swappiness can't be changed.
   - root cgroup (uses /proc/sys/vm/swappiness).
-  - a cgroup which uses hierarchy and it has child cgroup.
+  - a cgroup which uses hierarchy and it has other cgroup(s) below it.
   - a cgroup which uses hierarchy and not the root of hierarchy.
 
+5.4 failcnt
+
+The memory controller provides memory.failcnt and memory.memsw.failcnt files.
+This failcnt(== failure count) shows the number of times that a usage counter
+hit its limit. When a memory controller hit a limit, failcnt increases and
+memory under it will be reclaimed.
 
 6. Hierarchy support
 
@@ -395,7 +489,7 @@ is to allow control groups to use as muc
 a. There is no memory contention
 b. They do not exceed their hard limit
 
-When the system detects memory contention or low memory control groups
+When the system detects memory contention or low memory, control groups
 are pushed back to their soft limits. If the soft limit of each control
 group is very high, they are pushed back as much as possible to make
 sure that one control group does not starve the others of memory.
@@ -409,7 +503,7 @@ it gets invoked from balance_pgdat (kswa
 7.1 Interface
 
 Soft limits can be setup by using the following commands (in this example we
-assume a soft limit of 256 megabytes)
+assume a soft limit of 256 MiB)
 
 # echo 256M > memory.soft_limit_in_bytes
 
@@ -445,7 +539,7 @@ Note: Charges are moved only when you mo
 Note: If we cannot find enough space for the task in the destination cgroup, we
       try to make space by reclaiming memory. Task migration may fail if we
       cannot make enough space.
-Note: It can take several seconds if you move charges in giga bytes order.
+Note: It can take several seconds if you move charges much.
 
 And if you want disable it again:
 
@@ -513,9 +607,9 @@ As.
 
 This operation is only allowed to the top cgroup of subhierarchy.
 If oom-killer is disabled, tasks under cgroup will hang/sleep
-in memcg's oom-waitq when they request accountable memory.
+in memory cgroup's oom-waitq when they request accountable memory.
 
-For running them, you have to relax the memcg's oom sitaution by
+For running them, you have to relax the memory cgroup's oom sitaution by
 	* enlarge limit or reduce usage.
 To reduce usage,
 	* kill some tasks.
@@ -526,7 +620,7 @@ Then, stopped tasks will work again.
 
 At reading, current status of OOM is shown.
 	oom_kill_disable 0 or 1 (if 1, oom-killer is disabled)
-	under_oom	 0 or 1 (if 1, the memcg is under OOM,tasks may
+	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM,tasks may
 				 be stopped.)
 
 11. TODO

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
